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
import io.trino.operator.RuntimeConstraintRequest;
import io.trino.spi.connector.ColumnHandle;
import io.trino.spi.type.Type;
import io.trino.sql.ir.ComparisonOperator;
import io.trino.sql.planner.plan.PlanFragmentId;
import io.trino.sql.planner.plan.PlanNodeId;

import java.util.List;
import java.util.stream.IntStream;

import static java.util.Objects.requireNonNull;

public record RuntimeConstraintWiringReport(
        List<ScanWiring> scans,
        List<Source> sources,
        List<RemoteRequest> remoteRequests,
        List<RuntimeConstraintRequest> appliedOutputRequests,
        List<RuntimeConstraintRequest> rejectedOutputRequests)
{
    public static final RuntimeConstraintWiringReport EMPTY = new RuntimeConstraintWiringReport(ImmutableList.of(), ImmutableList.of(), ImmutableList.of(), ImmutableList.of(), ImmutableList.of());

    public RuntimeConstraintWiringReport(List<ScanWiring> scans)
    {
        this(scans, ImmutableList.of(), ImmutableList.of(), ImmutableList.of(), ImmutableList.of());
    }

    public RuntimeConstraintWiringReport(List<ScanWiring> scans, List<Source> sources)
    {
        this(scans, sources, ImmutableList.of(), ImmutableList.of(), ImmutableList.of());
    }

    public RuntimeConstraintWiringReport(List<ScanWiring> scans, List<Source> sources, List<RemoteRequest> remoteRequests)
    {
        this(scans, sources, remoteRequests, ImmutableList.of(), ImmutableList.of());
    }

    public RuntimeConstraintWiringReport(
            List<ScanWiring> scans,
            List<Source> sources,
            List<RemoteRequest> remoteRequests,
            List<RuntimeConstraintRequest> appliedOutputRequests)
    {
        this(scans, sources, remoteRequests, appliedOutputRequests, ImmutableList.of());
    }

    public RuntimeConstraintWiringReport
    {
        scans = ImmutableList.copyOf(requireNonNull(scans, "scans is null"));
        sources = ImmutableList.copyOf(requireNonNull(sources, "sources is null"));
        remoteRequests = remoteRequests == null ? ImmutableList.of() : ImmutableList.copyOf(remoteRequests);
        appliedOutputRequests = appliedOutputRequests == null ? ImmutableList.of() : ImmutableList.copyOf(appliedOutputRequests);
        rejectedOutputRequests = rejectedOutputRequests == null ? ImmutableList.of() : ImmutableList.copyOf(rejectedOutputRequests);
    }

    public record Source(
            PlanNodeId sourceId,
            List<RuntimeConstraintId> constraintIds,
            List<Type> types,
            DistributedCompletionPolicy completionPolicy,
            List<ComparisonOperator> operators,
            List<Boolean> nullAllowed,
            List<Integer> collectedLaneIndexes,
            boolean replicated)
    {
        public Source(PlanNodeId sourceId, List<RuntimeConstraintId> constraintIds, List<Type> types)
        {
            this(sourceId, constraintIds, types, DistributedCompletionPolicy.UNION_ALL_PARTITIONS);
        }

        public Source(PlanNodeId sourceId, List<RuntimeConstraintId> constraintIds, List<Type> types, DistributedCompletionPolicy completionPolicy)
        {
            this(sourceId,
                    constraintIds,
                    types,
                    completionPolicy,
                    constraintIds.stream().map(_ -> ComparisonOperator.EQUAL).toList(),
                    constraintIds.stream().map(_ -> false).toList(),
                    IntStream.range(0, constraintIds.size()).boxed().toList(),
                    completionPolicy == DistributedCompletionPolicy.EQUIVALENT_REPLICAS);
        }

        public Source(
                PlanNodeId sourceId,
                List<RuntimeConstraintId> constraintIds,
                List<Type> types,
                DistributedCompletionPolicy completionPolicy,
                List<ComparisonOperator> operators,
                List<Boolean> nullAllowed,
                List<Integer> collectedLaneIndexes)
        {
            this(sourceId, constraintIds, types, completionPolicy, operators, nullAllowed, collectedLaneIndexes, completionPolicy == DistributedCompletionPolicy.EQUIVALENT_REPLICAS);
        }

        public Source
        {
            requireNonNull(sourceId, "sourceId is null");
            constraintIds = ImmutableList.copyOf(requireNonNull(constraintIds, "constraintIds is null"));
            types = ImmutableList.copyOf(requireNonNull(types, "types is null"));
            completionPolicy = completionPolicy == null ? DistributedCompletionPolicy.UNION_ALL_PARTITIONS : completionPolicy;
            operators = ImmutableList.copyOf(requireNonNull(operators, "operators is null"));
            nullAllowed = ImmutableList.copyOf(requireNonNull(nullAllowed, "nullAllowed is null"));
            collectedLaneIndexes = ImmutableList.copyOf(requireNonNull(collectedLaneIndexes, "collectedLaneIndexes is null"));
            if (constraintIds.size() != operators.size() || constraintIds.size() != nullAllowed.size() || constraintIds.size() != collectedLaneIndexes.size()) {
                throw new IllegalArgumentException("runtime constraint source attributes have different sizes");
            }
            int laneCount = types.size();
            if (collectedLaneIndexes.stream().anyMatch(index -> index < 0 || index >= laneCount)) {
                throw new IllegalArgumentException("runtime constraint source lane index is out of bounds");
            }
        }
    }

    public record ScanWiring(PlanNodeId scanId, List<Binding> bindings)
    {
        public ScanWiring
        {
            requireNonNull(scanId, "scanId is null");
            bindings = ImmutableList.copyOf(requireNonNull(bindings, "bindings is null"));
        }
    }

    public record Binding(RuntimeConstraintRequest request, ColumnHandle column)
    {
        public Binding(RuntimeConstraintId constraintId, ColumnHandle column)
        {
            this(new RuntimeConstraintRequest(constraintId, 0), column);
        }

        public Binding
        {
            requireNonNull(request, "request is null");
            if (!request.isConstraint()) {
                throw new IllegalArgumentException("scan binding must contain a constraint request");
            }
            requireNonNull(column, "column is null");
        }

        public RuntimeConstraintId constraintId()
        {
            return request.constraintId();
        }
    }

    public record RemoteRequest(List<PlanFragmentId> sourceFragmentIds, RuntimeConstraintRequest request)
    {
        public RemoteRequest
        {
            sourceFragmentIds = ImmutableList.copyOf(requireNonNull(sourceFragmentIds, "sourceFragmentIds is null"));
            if (sourceFragmentIds.isEmpty()) {
                throw new IllegalArgumentException("sourceFragmentIds is empty");
            }
            requireNonNull(request, "request is null");
        }
    }
}
