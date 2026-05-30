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

import io.trino.Session;
import io.trino.matching.Captures;
import io.trino.matching.Pattern;
import io.trino.metadata.Metadata;
import io.trino.sql.planner.iterative.Rule;
import io.trino.sql.planner.optimizations.unnest.DependentJoinUnnester;
import io.trino.sql.planner.plan.CorrelatedJoinNode;
import io.trino.sql.planner.plan.PlanNode;

import java.util.Optional;

import static io.trino.SystemSessionProperties.getDecorrelationStrategy;
import static io.trino.matching.Pattern.nonEmpty;
import static io.trino.sql.planner.OptimizerConfig.DecorrelationStrategy.UNIFIED;
import static io.trino.sql.planner.plan.Patterns.CorrelatedJoin.correlation;
import static io.trino.sql.planner.plan.Patterns.correlatedJoin;
import static java.util.Objects.requireNonNull;

/**
 * Decorrelates a {@link CorrelatedJoinNode} using the dependent-join algebra of Neumann &amp;
 * Kemper (BTW 2015). Active only when `decorrelation_strategy = UNIFIED`. When the framework
 * cannot push the dependent join through some operator in the subquery (see
 * {@link DependentJoinUnnester} for the supported shapes), this rule does nothing and lets the
 * legacy `TransformCorrelated*` rules try.
 */
public class UnnestCorrelatedJoinViaDependentJoinFramework
        implements Rule<CorrelatedJoinNode>
{
    private static final Pattern<CorrelatedJoinNode> PATTERN = correlatedJoin()
            .with(nonEmpty(correlation()));

    private final Metadata metadata;

    public UnnestCorrelatedJoinViaDependentJoinFramework(Metadata metadata)
    {
        this.metadata = requireNonNull(metadata, "metadata is null");
    }

    @Override
    public Pattern<CorrelatedJoinNode> getPattern()
    {
        return PATTERN;
    }

    @Override
    public boolean isEnabled(Session session)
    {
        return getDecorrelationStrategy(session) == UNIFIED;
    }

    @Override
    public Result apply(CorrelatedJoinNode node, Captures captures, Context context)
    {
        DependentJoinUnnester unnester = new DependentJoinUnnester(
                context.getIdAllocator(),
                context.getSymbolAllocator(),
                context.getLookup(),
                metadata);
        Optional<PlanNode> decorrelated = unnester.unnest(node);
        return decorrelated.map(Result::ofPlanNode).orElseGet(Result::empty);
    }
}
