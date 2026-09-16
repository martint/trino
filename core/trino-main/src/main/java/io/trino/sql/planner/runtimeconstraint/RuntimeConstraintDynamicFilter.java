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
package io.trino.sql.planner.runtimeconstraint;

import com.google.common.collect.ImmutableList;
import com.google.common.collect.ImmutableSet;
import com.google.errorprone.annotations.concurrent.GuardedBy;
import io.trino.Session;
import io.trino.metadata.FunctionManager;
import io.trino.metadata.Metadata;
import io.trino.operator.TaskRuntimeConstraintManager;
import io.trino.spi.connector.ColumnHandle;
import io.trino.spi.connector.DynamicFilter;
import io.trino.spi.predicate.Domain;
import io.trino.spi.predicate.TupleDomain;
import io.trino.spi.type.Type;
import io.trino.spi.type.TypeOperators;
import io.trino.sql.ir.ComparisonOperator;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.HashSet;
import java.util.List;
import java.util.Map;
import java.util.Set;
import java.util.concurrent.CompletableFuture;
import java.util.function.BiFunction;
import java.util.function.Function;

import static com.google.common.base.Preconditions.checkArgument;
import static com.google.common.base.Verify.verify;
import static com.google.common.collect.ImmutableMap.toImmutableMap;
import static com.google.common.collect.ImmutableSet.toImmutableSet;
import static io.trino.sql.planner.DomainCoercer.applySaturatedCasts;
import static io.trino.sql.planner.runtimeconstraint.RuntimeConstraintNullMatchMode.NULL_SAFE;
import static java.util.Objects.requireNonNull;

public final class RuntimeConstraintDynamicFilter
        implements DynamicFilter
{
    private final Set<ColumnHandle> columnsCovered;
    private final Map<RuntimeConstraintId, List<ConstraintBinding>> bindings;
    private final CoercionContext coercionContext;
    @GuardedBy("this")
    private final Set<RuntimeConstraintId> pending;
    @GuardedBy("this")
    private final Set<RuntimeConstraintId> pendingAwaitable;

    @GuardedBy("this")
    private TupleDomain<ColumnHandle> currentPredicate = TupleDomain.all();
    @GuardedBy("this")
    private CompletableFuture<Void> blocked;

    private RuntimeConstraintDynamicFilter(
            BiFunction<RuntimeConstraintId, Long, CompletableFuture<RuntimeConstraintSnapshot>> updates,
            Function<RuntimeConstraintId, CompletableFuture<Void>> initialUnblock,
            List<RuntimeConstraintWiringReport.Binding> scanBindings,
            List<ColumnHandle> columns,
            CoercionContext coercionContext)
    {
        requireNonNull(updates, "updates is null");
        requireNonNull(scanBindings, "scanBindings is null");
        requireNonNull(columns, "columns is null");

        Map<RuntimeConstraintId, List<ConstraintBinding>> bindings = new HashMap<>();
        for (RuntimeConstraintWiringReport.Binding binding : scanBindings) {
            int channel = columns.indexOf(binding.column());
            checkArgument(channel >= 0, "runtime constraint column is not produced by scan");
            ConstraintBinding constraintBinding = new ConstraintBinding(
                    ImmutableList.of(columns.get(channel)),
                    binding.request().targetType().map(ImmutableList::of).orElseGet(ImmutableList::of),
                    true,
                    binding.request().operator(),
                    binding.request().nullAllowed());
            bindings.computeIfAbsent(binding.constraintId(), _ -> new ArrayList<>()).add(constraintBinding);
        }
        this.bindings = bindings.entrySet().stream()
                .collect(toImmutableMap(Map.Entry::getKey, entry -> List.copyOf(entry.getValue())));
        this.coercionContext = coercionContext;
        this.columnsCovered = bindings.values().stream()
                .flatMap(List::stream)
                .flatMap(binding -> binding.columns().stream())
                .collect(toImmutableSet());
        this.pending = new HashSet<>(bindings.keySet());
        this.pendingAwaitable = new HashSet<>(bindings.entrySet().stream()
                .filter(entry -> entry.getValue().stream().anyMatch(ConstraintBinding::awaitable))
                .map(Map.Entry::getKey)
                .collect(toImmutableSet()));
        this.blocked = pendingAwaitable.isEmpty() ? null : new NonCancellableCompletableFuture<>();

        Set<RuntimeConstraintId> initiallyAwaitable = ImmutableSet.copyOf(pendingAwaitable);
        bindings.keySet().forEach(id -> updates.apply(id, 0L).thenAccept(snapshot -> update(id, snapshot)));
        if (initialUnblock != null) {
            initiallyAwaitable.forEach(id -> initialUnblock.apply(id).thenRun(() -> unblock(id)));
        }
    }

    public static DynamicFilter create(
            TaskRuntimeConstraintManager manager,
            List<RuntimeConstraintWiringReport.Binding> scanBindings,
            List<ColumnHandle> columns)
    {
        if (scanBindings.isEmpty()) {
            return EMPTY;
        }
        manager.registerConsumers(scanBindings);
        return new RuntimeConstraintDynamicFilter(manager::waitForUpdate, null, scanBindings, columns, null);
    }

    public static DynamicFilter create(
            TaskRuntimeConstraintManager manager,
            List<RuntimeConstraintWiringReport.Binding> scanBindings,
            List<ColumnHandle> columns,
            Metadata metadata,
            FunctionManager functionManager,
            TypeOperators typeOperators,
            Session session)
    {
        if (scanBindings.isEmpty()) {
            return EMPTY;
        }
        manager.registerConsumers(scanBindings);
        return new RuntimeConstraintDynamicFilter(
                manager::waitForUpdate,
                null,
                scanBindings,
                columns,
                new CoercionContext(metadata, functionManager, typeOperators, session));
    }

    public static DynamicFilter create(
            RuntimeConstraintHub hub,
            List<RuntimeConstraintWiringReport.Binding> scanBindings,
            List<ColumnHandle> columns,
            Metadata metadata,
            FunctionManager functionManager,
            TypeOperators typeOperators,
            Session session)
    {
        if (scanBindings.isEmpty()) {
            return EMPTY;
        }
        return new RuntimeConstraintDynamicFilter(hub::waitForUpdate, hub::waitForInitialUnblock, scanBindings, columns, new CoercionContext(metadata, functionManager, typeOperators, session));
    }

    public static DynamicFilter combine(DynamicFilter first, DynamicFilter second)
    {
        requireNonNull(first, "first is null");
        requireNonNull(second, "second is null");
        if (first == EMPTY) {
            return second;
        }
        if (second == EMPTY) {
            return first;
        }
        return new CombinedDynamicFilter(first, second);
    }

    private void update(RuntimeConstraintId id, RuntimeConstraintSnapshot snapshot)
    {
        CompletableFuture<Void> currentBlocked;
        synchronized (this) {
            verify(pending.remove(id), "runtime constraint completed more than once: %s", id);
            pendingAwaitable.remove(id);
            if (snapshot.state() == RuntimeConstraintPublicationState.FINAL) {
                RuntimeConstraintPayload payload = snapshot.payload().orElseThrow();
                checkArgument(payload instanceof RuntimeMembershipPayload, "unsupported runtime constraint payload: %s", payload.getClass().getSimpleName());
                RuntimeMembershipPayload membership = (RuntimeMembershipPayload) payload;
                List<ConstraintBinding> constraintBindings = requireNonNull(bindings.get(id), "constraint binding is missing");
                Map<ColumnHandle, Domain> domains = new HashMap<>();
                for (ConstraintBinding binding : constraintBindings) {
                    checkArgument(binding.columns().size() == membership.scalarDomains().size(), "runtime constraint payload has wrong lane count");
                    for (int lane = 0; lane < binding.columns().size(); lane++) {
                        Domain domain = membership.scalarDomains().get(lane);
                        domain = RuntimeConstraintDeriver.applyComparison(
                                domain,
                                binding.operator(),
                                binding.nullAllowed(),
                                membership.sawInputRow(),
                                membership.sawNulls().get(lane));
                        if (membership.nullMatchMode() == NULL_SAFE && !membership.sawInputRow() && domain.isNone()) {
                            domain = Domain.onlyNull(domain.getType());
                        }
                        if (!binding.targetTypes().isEmpty()) {
                            Type targetType = binding.targetTypes().get(lane);
                            if (!domain.getType().equals(targetType)) {
                                CoercionContext context = requireNonNull(coercionContext, "runtime constraint cast preimage context is missing");
                                domain = applySaturatedCasts(context.metadata(), context.functionManager(), context.typeOperators(), context.session(), domain, targetType);
                            }
                        }
                        domains.merge(binding.columns().get(lane), domain, Domain::intersect);
                    }
                }
                currentPredicate = currentPredicate.intersect(TupleDomain.withColumnDomains(domains));
            }
            currentBlocked = blocked;
            blocked = pendingAwaitable.isEmpty() ? null : new NonCancellableCompletableFuture<>();
        }
        if (currentBlocked != null) {
            currentBlocked.complete(null);
        }
    }

    private void unblock(RuntimeConstraintId id)
    {
        CompletableFuture<Void> currentBlocked;
        synchronized (this) {
            if (!pendingAwaitable.remove(id)) {
                return;
            }
            currentBlocked = blocked;
            blocked = pendingAwaitable.isEmpty() ? null : new NonCancellableCompletableFuture<>();
        }
        if (currentBlocked != null) {
            currentBlocked.complete(null);
        }
    }

    @Override
    public Set<ColumnHandle> getColumnsCovered()
    {
        return columnsCovered;
    }

    @Override
    public synchronized CompletableFuture<?> isBlocked()
    {
        return blocked == null ? NOT_BLOCKED : blocked;
    }

    @Override
    public synchronized boolean isComplete()
    {
        return pending.isEmpty();
    }

    @Override
    public synchronized boolean isAwaitable()
    {
        return !pendingAwaitable.isEmpty();
    }

    @Override
    public synchronized TupleDomain<ColumnHandle> getCurrentPredicate()
    {
        return currentPredicate;
    }

    private record ConstraintBinding(
            List<ColumnHandle> columns,
            List<Type> targetTypes,
            boolean awaitable,
            ComparisonOperator operator,
            boolean nullAllowed)
    {
        private ConstraintBinding
        {
            columns = List.copyOf(requireNonNull(columns, "columns is null"));
            targetTypes = List.copyOf(requireNonNull(targetTypes, "targetTypes is null"));
            checkArgument(targetTypes.isEmpty() || targetTypes.size() == columns.size(), "targetTypes and columns have different sizes");
            requireNonNull(operator, "operator is null");
        }
    }

    private record CoercionContext(Metadata metadata, FunctionManager functionManager, TypeOperators typeOperators, Session session)
    {
        private CoercionContext
        {
            requireNonNull(metadata, "metadata is null");
            requireNonNull(functionManager, "functionManager is null");
            requireNonNull(typeOperators, "typeOperators is null");
            requireNonNull(session, "session is null");
        }
    }

    private static final class CombinedDynamicFilter
            implements DynamicFilter
    {
        private final DynamicFilter first;
        private final DynamicFilter second;
        private final Set<ColumnHandle> columnsCovered;

        private CombinedDynamicFilter(DynamicFilter first, DynamicFilter second)
        {
            this.first = requireNonNull(first, "first is null");
            this.second = requireNonNull(second, "second is null");
            this.columnsCovered = ImmutableSet.<ColumnHandle>builder()
                    .addAll(first.getColumnsCovered())
                    .addAll(second.getColumnsCovered())
                    .build();
        }

        @Override
        public Set<ColumnHandle> getColumnsCovered()
        {
            return columnsCovered;
        }

        @Override
        public CompletableFuture<?> isBlocked()
        {
            List<CompletableFuture<?>> futures = new ArrayList<>();
            if (first.isAwaitable()) {
                futures.add(first.isBlocked());
            }
            if (second.isAwaitable()) {
                futures.add(second.isBlocked());
            }
            if (futures.isEmpty()) {
                return NOT_BLOCKED;
            }
            NonCancellableCompletableFuture<Object> blocked = new NonCancellableCompletableFuture<>();
            CompletableFuture.anyOf(futures.toArray(CompletableFuture[]::new))
                    .whenComplete((value, failure) -> {
                        if (failure != null) {
                            blocked.completeExceptionally(failure);
                        }
                        else {
                            blocked.complete(value);
                        }
                    });
            return blocked;
        }

        @Override
        public boolean isComplete()
        {
            return first.isComplete() && second.isComplete();
        }

        @Override
        public boolean isAwaitable()
        {
            return first.isAwaitable() || second.isAwaitable();
        }

        @Override
        public TupleDomain<ColumnHandle> getCurrentPredicate()
        {
            return first.getCurrentPredicate().intersect(second.getCurrentPredicate());
        }
    }

    private static final class NonCancellableCompletableFuture<T>
            extends CompletableFuture<T>
    {
        @Override
        public boolean cancel(boolean mayInterruptIfRunning)
        {
            return false;
        }
    }
}
