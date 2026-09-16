/*
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */
package io.trino.operator;

import com.google.common.collect.ImmutableList;
import io.trino.Session;
import io.trino.metadata.FunctionManager;
import io.trino.metadata.Metadata;
import io.trino.spi.connector.ColumnHandle;
import io.trino.spi.connector.DynamicFilter;
import io.trino.spi.type.Type;
import io.trino.spi.type.TypeOperators;
import io.trino.sql.ir.ComparisonOperator;
import io.trino.sql.planner.plan.PlanFragmentId;
import io.trino.sql.planner.plan.PlanNodeId;
import io.trino.sql.planner.runtimeconstraint.DistributedCompletionPolicy;
import io.trino.sql.planner.runtimeconstraint.RuntimeConstraintDynamicFilter;
import io.trino.sql.planner.runtimeconstraint.RuntimeConstraintId;
import io.trino.sql.planner.runtimeconstraint.RuntimeConstraintWiringReport;

import java.util.ArrayDeque;
import java.util.ArrayList;
import java.util.Deque;
import java.util.LinkedHashMap;
import java.util.LinkedHashSet;
import java.util.List;
import java.util.Map;
import java.util.Set;
import java.util.function.Consumer;
import java.util.stream.IntStream;

import static com.google.common.base.Preconditions.checkArgument;
import static io.trino.SystemSessionProperties.getRetryPolicy;
import static java.util.Objects.requireNonNull;

public final class RuntimeConstraintWiringContext
{
    private final TaskRuntimeConstraintManager manager;
    private final boolean enabled;
    private final Metadata metadata;
    private final FunctionManager functionManager;
    private final TypeOperators typeOperators;
    private final Session session;
    private final List<ScanBinding> scanBindings = new ArrayList<>();
    private final List<StoppedRequest> stoppedRequests = new ArrayList<>();
    private final Set<PlanNodeId> completedScans = new LinkedHashSet<>();
    private final Set<RuntimeConstraintWiringReport.Source> sources = new LinkedHashSet<>();
    private final List<Runnable> deferred = new ArrayList<>();
    private final Set<RuntimeConstraintWiringReport.RemoteRequest> remoteRequests = new LinkedHashSet<>();
    private final Map<PlanNodeId, ScanRegistration> scanRegistrations = new LinkedHashMap<>();
    private final Set<RuntimeConstraintRequest> appliedOutputRequests = new LinkedHashSet<>();
    private final Set<RuntimeConstraintRequest> rejectedOutputRequests = new LinkedHashSet<>();
    private final Map<Object, Set<RuntimeConstraintRequest>> localRequests = new LinkedHashMap<>();
    private final Map<Object, List<Consumer<List<RuntimeConstraintRequest>>>> localConsumers = new LinkedHashMap<>();
    private final Deque<Runnable> pendingScanInstallations = new ArrayDeque<>();
    private boolean installingScanFilters;

    public RuntimeConstraintWiringContext()
    {
        manager = null;
        enabled = true;
        metadata = null;
        functionManager = null;
        typeOperators = null;
        session = null;
    }

    public RuntimeConstraintWiringContext(TaskRuntimeConstraintManager manager)
    {
        this(manager, true);
    }

    public RuntimeConstraintWiringContext(TaskRuntimeConstraintManager manager, boolean enabled)
    {
        this(manager, enabled, null, null, null, null);
    }

    public RuntimeConstraintWiringContext(
            TaskRuntimeConstraintManager manager,
            boolean enabled,
            Metadata metadata,
            FunctionManager functionManager,
            TypeOperators typeOperators,
            Session session)
    {
        this.manager = requireNonNull(manager, "manager is null");
        this.enabled = enabled;
        this.metadata = metadata;
        this.functionManager = functionManager;
        this.typeOperators = typeOperators;
        this.session = session;
    }

    public boolean isEnabled()
    {
        return enabled;
    }

    public boolean isTaskRetry()
    {
        return session != null && getRetryPolicy(session) == RetryPolicy.TASK;
    }

    public void bindScan(PlanNodeId scanId, ColumnHandle column, RuntimeConstraintRequest request)
    {
        if (!request.isConstraint()) {
            stop("scan", request);
            return;
        }
        ScanBinding binding = new ScanBinding(scanId, column, request);
        synchronized (this) {
            if (!scanBindings.contains(binding)) {
                scanBindings.add(binding);
                ScanRegistration registration = scanRegistrations.get(scanId);
                if (manager != null && registration != null) {
                    enqueueScanInstallation(
                            registration,
                            ImmutableList.of(new RuntimeConstraintWiringReport.Binding(request, column)));
                }
            }
        }
        installScanFilters();
    }

    public synchronized void defer(Runnable action)
    {
        deferred.add(requireNonNull(action, "action is null"));
    }

    public void finish()
    {
        List<Runnable> actions;
        synchronized (this) {
            actions = ImmutableList.copyOf(deferred);
            deferred.clear();
        }
        actions.forEach(Runnable::run);
    }

    public void completeScan(PlanNodeId scanId, List<ColumnHandle> columns, Consumer<DynamicFilter> installer)
    {
        requireNonNull(scanId, "scanId is null");
        requireNonNull(columns, "columns is null");
        requireNonNull(installer, "installer is null");
        synchronized (this) {
            completedScans.add(scanId);
            ScanRegistration registration = new ScanRegistration(columns, installer);
            ScanRegistration previous = scanRegistrations.putIfAbsent(scanId, registration);
            if (previous == null && manager != null) {
                enqueueScanInstallation(registration, getBindings(scanId));
            }
        }
        installScanFilters();
    }

    private void enqueueScanInstallation(
            ScanRegistration registration,
            List<RuntimeConstraintWiringReport.Binding> bindings)
    {
        pendingScanInstallations.add(() -> registration.installer().accept(createDynamicFilter(bindings, registration.columns())));
    }

    private void installScanFilters()
    {
        synchronized (this) {
            if (installingScanFilters || pendingScanInstallations.isEmpty()) {
                return;
            }
            installingScanFilters = true;
        }
        while (true) {
            Runnable installation;
            synchronized (this) {
                installation = pendingScanInstallations.poll();
                if (installation == null) {
                    installingScanFilters = false;
                    return;
                }
            }
            try {
                installation.run();
            }
            catch (Throwable failure) {
                synchronized (this) {
                    installingScanFilters = false;
                }
                throw failure;
            }
        }
    }

    private DynamicFilter createDynamicFilter(List<RuntimeConstraintWiringReport.Binding> bindings, List<ColumnHandle> columns)
    {
        if (metadata == null) {
            return RuntimeConstraintDynamicFilter.create(manager, bindings, columns);
        }
        return RuntimeConstraintDynamicFilter.create(manager, bindings, columns, metadata, functionManager, typeOperators, session);
    }

    public synchronized void completeScan(PlanNodeId scanId)
    {
        completedScans.add(requireNonNull(scanId, "scanId is null"));
    }

    public void registerSource(PlanNodeId sourceId, List<Type> types)
    {
        registerSource(sourceId, types, DistributedCompletionPolicy.UNION_ALL_PARTITIONS);
    }

    public void registerSource(PlanNodeId sourceId, List<Type> types, DistributedCompletionPolicy completionPolicy)
    {
        List<RuntimeConstraintId> constraintIds = IntStream.range(0, types.size())
                .mapToObj(index -> RuntimeConstraintRequest.joinConstraintId(sourceId, index))
                .toList();
        registerSource(sourceId, constraintIds, types, completionPolicy);
    }

    public void registerSource(
            PlanNodeId sourceId,
            List<RuntimeConstraintId> constraintIds,
            List<Type> types)
    {
        registerSource(sourceId, constraintIds, types, DistributedCompletionPolicy.UNION_ALL_PARTITIONS);
    }

    public void registerSource(
            PlanNodeId sourceId,
            List<RuntimeConstraintId> constraintIds,
            List<Type> types,
            DistributedCompletionPolicy completionPolicy)
    {
        registerSource(
                sourceId,
                constraintIds,
                types,
                completionPolicy,
                constraintIds.stream().map(_ -> ComparisonOperator.EQUAL).toList(),
                constraintIds.stream().map(_ -> false).toList(),
                IntStream.range(0, constraintIds.size()).boxed().toList());
    }

    public void registerSource(
            PlanNodeId sourceId,
            List<RuntimeConstraintId> constraintIds,
            List<Type> types,
            DistributedCompletionPolicy completionPolicy,
            List<ComparisonOperator> operators,
            List<Boolean> nullAllowed,
            List<Integer> collectedLaneIndexes)
    {
        registerSource(sourceId, constraintIds, types, completionPolicy, operators, nullAllowed, collectedLaneIndexes, completionPolicy == DistributedCompletionPolicy.EQUIVALENT_REPLICAS);
    }

    public void registerSource(
            PlanNodeId sourceId,
            List<RuntimeConstraintId> constraintIds,
            List<Type> types,
            DistributedCompletionPolicy completionPolicy,
            List<ComparisonOperator> operators,
            List<Boolean> nullAllowed,
            List<Integer> collectedLaneIndexes,
            boolean replicated)
    {
        RuntimeConstraintWiringReport.Source source = new RuntimeConstraintWiringReport.Source(sourceId, constraintIds, types, completionPolicy, operators, nullAllowed, collectedLaneIndexes, replicated);
        boolean added;
        synchronized (this) {
            added = sources.add(source);
        }
        if (added && manager != null) {
            manager.registerSource(source);
        }
    }

    public void stop(OperatorFactory operatorFactory, RuntimeConstraintRequest request)
    {
        stop(operatorFactory.getClass().getSimpleName(), request);
    }

    public synchronized void stop(String operatorType, RuntimeConstraintRequest request)
    {
        stoppedRequests.add(new StoppedRequest(operatorType, request));
    }

    public void disableCollection(RuntimeConstraintRequest request)
    {
        checkArgument(request.isCollection(), "request is not a collection request");
        Type targetType = request.targetType().orElseThrow();
        registerSource(
                request.collectionSourceId(),
                ImmutableList.of(request.constraintId()),
                ImmutableList.of(targetType),
                DistributedCompletionPolicy.UNION_ALL_PARTITIONS,
                ImmutableList.of(request.operator()),
                ImmutableList.of(request.nullAllowed()),
                ImmutableList.of(0),
                request.isReplicatedCollection());
        if (manager != null) {
            manager.addUnrestrictedContribution(request.collectionSourceId(), targetType);
        }
    }

    public synchronized void bindRemoteSource(List<PlanFragmentId> sourceFragmentIds, RuntimeConstraintRequest request)
    {
        remoteRequests.add(new RuntimeConstraintWiringReport.RemoteRequest(sourceFragmentIds, request));
    }

    public void bindLocalSource(Object exchange, RuntimeConstraintRequest request)
    {
        List<Consumer<List<RuntimeConstraintRequest>>> consumers;
        synchronized (this) {
            if (!localRequests.computeIfAbsent(requireNonNull(exchange, "exchange is null"), _ -> new LinkedHashSet<>()).add(requireNonNull(request, "request is null"))) {
                return;
            }
            consumers = ImmutableList.copyOf(localConsumers.getOrDefault(exchange, ImmutableList.of()));
        }
        consumers.forEach(consumer -> consumer.accept(ImmutableList.of(request)));
    }

    public void registerLocalConsumer(Object exchange, Consumer<List<RuntimeConstraintRequest>> consumer)
    {
        List<RuntimeConstraintRequest> pending;
        synchronized (this) {
            localConsumers.computeIfAbsent(requireNonNull(exchange, "exchange is null"), _ -> new ArrayList<>())
                    .add(requireNonNull(consumer, "consumer is null"));
            pending = ImmutableList.copyOf(localRequests.getOrDefault(exchange, Set.of()));
        }
        if (!pending.isEmpty()) {
            consumer.accept(pending);
        }
    }

    public void registerOutput(DriverFactory outputDriver)
    {
        requireNonNull(outputDriver, "outputDriver is null");
        if (manager != null && enabled) {
            manager.registerRuntimeConstraintWiring(requests -> {
                List<RuntimeConstraintRequest> applied = requests.stream()
                        .filter(request -> outputDriver.propagateRuntimeConstraints(ImmutableList.of(request), this))
                        .toList();
                synchronized (this) {
                    appliedOutputRequests.addAll(applied);
                    rejectedOutputRequests.addAll(requests);
                    rejectedOutputRequests.removeAll(applied);
                }
            });
        }
    }

    public synchronized List<ScanBinding> getScanBindings()
    {
        return ImmutableList.copyOf(scanBindings);
    }

    public synchronized List<StoppedRequest> getStoppedRequests()
    {
        return ImmutableList.copyOf(stoppedRequests);
    }

    public synchronized RuntimeConstraintWiringReport getReport()
    {
        return new RuntimeConstraintWiringReport(completedScans.stream()
                .map(scanId -> new RuntimeConstraintWiringReport.ScanWiring(
                        scanId,
                        getBindings(scanId)))
                .toList(), ImmutableList.copyOf(sources), ImmutableList.copyOf(remoteRequests), ImmutableList.copyOf(appliedOutputRequests), ImmutableList.copyOf(rejectedOutputRequests));
    }

    private List<RuntimeConstraintWiringReport.Binding> getBindings(PlanNodeId scanId)
    {
        return scanBindings.stream()
                .filter(binding -> binding.scanId().equals(scanId))
                .map(binding -> new RuntimeConstraintWiringReport.Binding(binding.request(), binding.column()))
                .distinct()
                .toList();
    }

    public record ScanBinding(PlanNodeId scanId, ColumnHandle column, RuntimeConstraintRequest request)
    {
        public ScanBinding
        {
            requireNonNull(scanId, "scanId is null");
            requireNonNull(column, "column is null");
            requireNonNull(request, "request is null");
        }
    }

    public record StoppedRequest(String operatorType, RuntimeConstraintRequest request)
    {
        public StoppedRequest
        {
            requireNonNull(operatorType, "operatorType is null");
            requireNonNull(request, "request is null");
        }
    }

    private record ScanRegistration(List<ColumnHandle> columns, Consumer<DynamicFilter> installer)
    {
        private ScanRegistration
        {
            columns = ImmutableList.copyOf(requireNonNull(columns, "columns is null"));
            requireNonNull(installer, "installer is null");
        }
    }
}
