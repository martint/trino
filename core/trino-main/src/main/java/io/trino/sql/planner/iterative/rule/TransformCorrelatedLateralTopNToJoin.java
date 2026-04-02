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
package io.trino.sql.planner.iterative.rule;

import com.google.common.collect.ImmutableList;
import com.google.common.collect.ImmutableMap;
import com.google.common.collect.ImmutableSet;
import io.trino.matching.Captures;
import io.trino.matching.Pattern;
import io.trino.sql.PlannerContext;
import io.trino.sql.ir.Comparison;
import io.trino.sql.ir.Constant;
import io.trino.sql.ir.Expression;
import io.trino.sql.planner.OrderingScheme;
import io.trino.sql.planner.Symbol;
import io.trino.sql.planner.iterative.Rule;
import io.trino.sql.planner.optimizations.PlanNodeDecorrelator;
import io.trino.sql.planner.plan.AssignUniqueId;
import io.trino.sql.planner.plan.Assignments;
import io.trino.sql.planner.plan.CorrelatedJoinNode;
import io.trino.sql.planner.plan.DataOrganizationSpecification;
import io.trino.sql.planner.plan.EnforceSingleRowNode;
import io.trino.sql.planner.plan.FilterNode;
import io.trino.sql.planner.plan.JoinNode;
import io.trino.sql.planner.plan.LimitNode;
import io.trino.sql.planner.plan.PlanNode;
import io.trino.sql.planner.plan.ProjectNode;
import io.trino.sql.planner.plan.SortNode;
import io.trino.sql.planner.plan.TopNNode;
import io.trino.sql.planner.plan.WindowNode;

import java.util.ArrayList;
import java.util.Collections;
import java.util.List;
import java.util.Optional;
import java.util.Set;

import static com.google.common.base.Preconditions.checkArgument;
import static io.trino.matching.Pattern.nonEmpty;
import static io.trino.spi.type.BigintType.BIGINT;
import static io.trino.sql.ir.Booleans.TRUE;
import static io.trino.sql.ir.Comparison.Operator.LESS_THAN_OR_EQUAL;
import static io.trino.sql.ir.IrUtils.combineConjuncts;
import static io.trino.sql.planner.optimizations.PlanNodeSearcher.searchFrom;
import static io.trino.sql.planner.plan.JoinType.INNER;
import static io.trino.sql.planner.plan.JoinType.LEFT;
import static io.trino.sql.planner.plan.Patterns.CorrelatedJoin.correlation;
import static io.trino.sql.planner.plan.Patterns.CorrelatedJoin.filter;
import static io.trino.sql.planner.plan.Patterns.correlatedJoin;
import static io.trino.sql.planner.plan.WindowNode.Frame.DEFAULT_FRAME;
import static java.util.Objects.requireNonNull;

public class TransformCorrelatedLateralTopNToJoin
        implements Rule<CorrelatedJoinNode>
{
    private static final Pattern<CorrelatedJoinNode> PATTERN = correlatedJoin()
            .with(nonEmpty(correlation()))
            .with(filter().equalTo(TRUE));

    private final PlannerContext plannerContext;

    public TransformCorrelatedLateralTopNToJoin(PlannerContext plannerContext)
    {
        this.plannerContext = requireNonNull(plannerContext, "plannerContext is null");
    }

    @Override
    public Pattern<CorrelatedJoinNode> getPattern()
    {
        return PATTERN;
    }

    @Override
    public Result apply(CorrelatedJoinNode correlatedJoinNode, Captures captures, Context context)
    {
        checkArgument(correlatedJoinNode.getType() == INNER || correlatedJoinNode.getType() == LEFT, "unexpected correlated join type: %s", correlatedJoinNode.getType());

        PlanNode subquery = context.getLookup().resolve(correlatedJoinNode.getSubquery());

        // Let the scalar query decorrelator handle scalar queries (i.e., those containing EnforceSingleRow)
        if (searchFrom(subquery, context.getLookup())
                .where(EnforceSingleRowNode.class::isInstance)
                .recurseOnlyWhen(ProjectNode.class::isInstance)
                .matches()) {
            return Result.empty();
        }

        Optional<CorrelatedTopNDescriptor> topN = extractCorrelatedTopN(subquery, context);
        if (topN.isEmpty()) {
            return Result.empty();
        }
        // The rule doesn't support correlations in the ORDER BY clause
        if (topN.get().orderingScheme().orderBy().stream().anyMatch(correlatedJoinNode.getInput().getOutputSymbols()::contains)) {
            return Result.empty();
        }

        PlanNodeDecorrelator decorrelator = new PlanNodeDecorrelator(plannerContext, context.getSymbolAllocator(), context.getLookup());
        Optional<PlanNodeDecorrelator.DecorrelatedNode> decorrelatedSource = decorrelator.decorrelateFilters(topN.get().source(), correlatedJoinNode.getCorrelation());
        if (decorrelatedSource.isEmpty()) {
            return Result.empty();
        }

        Symbol uniqueSymbol = context.getSymbolAllocator().newSymbol("unique", BIGINT);
        PlanNode inputWithUniqueId = new AssignUniqueId(
                context.getIdAllocator().getNextId(),
                correlatedJoinNode.getInput(),
                uniqueSymbol);

        Expression joinFilter = combineConjuncts(
                decorrelatedSource.get().getCorrelatedPredicates().orElse(TRUE),
                correlatedJoinNode.getFilter());
        JoinNode joinNode = new JoinNode(
                context.getIdAllocator().getNextId(),
                correlatedJoinNode.getType(),
                inputWithUniqueId,
                decorrelatedSource.get().getNode(),
                ImmutableList.of(),
                inputWithUniqueId.getOutputSymbols(),
                decorrelatedSource.get().getNode().getOutputSymbols(),
                false,
                joinFilter.equals(TRUE) ? Optional.empty() : Optional.of(joinFilter),
                Optional.empty(),
                Optional.empty(),
                ImmutableMap.of(),
                Optional.empty());

        Symbol rowNumberSymbol = context.getSymbolAllocator().newSymbol("row_number", BIGINT);
        WindowNode.Function rowNumberFunction = new WindowNode.Function(
                plannerContext.getMetadata().resolveBuiltinFunction("row_number", ImmutableList.of()),
                ImmutableList.of(),
                Optional.empty(),
                DEFAULT_FRAME,
                false,
                false);
        PlanNode rewritten = new FilterNode(
                context.getIdAllocator().getNextId(),
                new WindowNode(
                        context.getIdAllocator().getNextId(),
                        joinNode,
                        new DataOrganizationSpecification(ImmutableList.of(uniqueSymbol), Optional.of(topN.get().orderingScheme())),
                        ImmutableMap.of(rowNumberSymbol, rowNumberFunction),
                        ImmutableSet.of(),
                        0),
                new Comparison(LESS_THAN_OR_EQUAL, rowNumberSymbol.toSymbolReference(), new Constant(BIGINT, topN.get().count())));

        for (ProjectNode project : topN.get().projections()) {
            Assignments.Builder assignments = Assignments.builder();
            Set<Symbol> outputs = project.getAssignments().outputs();
            rewritten.getOutputSymbols().stream()
                    .filter(symbol -> !outputs.contains(symbol))
                    .forEach(assignments::putIdentity);
            assignments.putAll(project.getAssignments());
            rewritten = new ProjectNode(project.getId(), rewritten, assignments.build());
        }

        return Result.ofPlanNode(new ProjectNode(
                correlatedJoinNode.getId(),
                rewritten,
                Assignments.identity(correlatedJoinNode.getOutputSymbols())));
    }

    private Optional<CorrelatedTopNDescriptor> extractCorrelatedTopN(PlanNode query, Context context)
    {
        PlanNode resolved = context.getLookup().resolve(query);
        List<ProjectNode> projections = new ArrayList<>();
        while (resolved instanceof ProjectNode project) {
            projections.add(project);
            resolved = context.getLookup().resolve(project.getSource());
        }
        Collections.reverse(projections);

        if (resolved instanceof TopNNode topN && topN.getCount() > 0 && topN.getStep() == TopNNode.Step.SINGLE) {
            return Optional.of(new CorrelatedTopNDescriptor(topN.getSource(), topN.getCount(), topN.getOrderingScheme(), ImmutableList.copyOf(projections)));
        }

        if (resolved instanceof LimitNode limitNode &&
                !limitNode.isWithTies() &&
                !limitNode.requiresPreSortedInputs() &&
                limitNode.getCount() > 0 &&
                context.getLookup().resolve(limitNode.getSource()) instanceof SortNode sortNode &&
                !sortNode.isPartial()) {
            return Optional.of(new CorrelatedTopNDescriptor(sortNode.getSource(), limitNode.getCount(), sortNode.getOrderingScheme(), ImmutableList.copyOf(projections)));
        }

        return Optional.empty();
    }

    private record CorrelatedTopNDescriptor(PlanNode source, long count, OrderingScheme orderingScheme, List<ProjectNode> projections) {}
}
