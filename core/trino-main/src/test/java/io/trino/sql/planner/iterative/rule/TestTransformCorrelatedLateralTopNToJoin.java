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
import io.trino.sql.ir.Comparison;
import io.trino.sql.ir.Constant;
import io.trino.sql.ir.Logical;
import io.trino.sql.ir.Reference;
import io.trino.sql.planner.iterative.rule.test.BaseRuleTest;
import io.trino.sql.planner.plan.Assignments;
import org.junit.jupiter.api.Test;

import static io.trino.spi.connector.SortOrder.ASC_NULLS_FIRST;
import static io.trino.spi.type.BigintType.BIGINT;
import static io.trino.sql.ir.Booleans.TRUE;
import static io.trino.sql.ir.Comparison.Operator.EQUAL;
import static io.trino.sql.ir.Comparison.Operator.LESS_THAN_OR_EQUAL;
import static io.trino.sql.ir.Logical.Operator.AND;
import static io.trino.sql.planner.assertions.PlanMatchPattern.assignUniqueId;
import static io.trino.sql.planner.assertions.PlanMatchPattern.expression;
import static io.trino.sql.planner.assertions.PlanMatchPattern.filter;
import static io.trino.sql.planner.assertions.PlanMatchPattern.join;
import static io.trino.sql.planner.assertions.PlanMatchPattern.project;
import static io.trino.sql.planner.assertions.PlanMatchPattern.specification;
import static io.trino.sql.planner.assertions.PlanMatchPattern.values;
import static io.trino.sql.planner.assertions.PlanMatchPattern.window;
import static io.trino.sql.planner.assertions.PlanMatchPattern.windowFunction;
import static io.trino.sql.planner.plan.JoinType.INNER;
import static io.trino.sql.planner.plan.JoinType.LEFT;
import static io.trino.sql.planner.plan.WindowNode.Frame.DEFAULT_FRAME;

public class TestTransformCorrelatedLateralTopNToJoin
        extends BaseRuleTest
{
    @Test
    public void rewritesInnerCorrelatedTopN()
    {
        tester().assertThat(new TransformCorrelatedLateralTopNToJoin(tester().getPlannerContext()))
                .on(p -> {
                    var corr = p.symbol("corr", BIGINT);
                    var limit = p.symbol("limit", BIGINT);
                    var match = p.symbol("match", BIGINT);
                    var ordering = p.symbol("ordering", BIGINT);
                    var payload = p.symbol("payload", BIGINT);

                    return p.correlatedJoin(
                            ImmutableList.of(corr, limit),
                            p.values(corr, limit),
                            INNER,
                            TRUE,
                            p.topN(
                                    1,
                                    ImmutableList.of(ordering),
                                    p.filter(
                                            new Logical(
                                                    AND,
                                                    ImmutableList.of(
                                                            new Comparison(EQUAL, match.toSymbolReference(), corr.toSymbolReference()),
                                                            new Comparison(LESS_THAN_OR_EQUAL, ordering.toSymbolReference(), limit.toSymbolReference()))),
                                            p.values(match, ordering, payload))));
                })
                .matches(
                        project(
                                filter(
                                        new Comparison(LESS_THAN_OR_EQUAL, new Reference(BIGINT, "row_number"), new Constant(BIGINT, 1L)),
                                        window(builder -> builder
                                                        .specification(specification(
                                                                ImmutableList.of("unique"),
                                                                ImmutableList.of("ordering"),
                                                                ImmutableMap.of("ordering", ASC_NULLS_FIRST)))
                                                        .addFunction("row_number", windowFunction("row_number", ImmutableList.of(), DEFAULT_FRAME)),
                                                join(INNER, builder -> builder
                                                        .filter(new Logical(
                                                                AND,
                                                                ImmutableList.of(
                                                                        new Comparison(EQUAL, new Reference(BIGINT, "match"), new Reference(BIGINT, "corr")),
                                                                        new Comparison(LESS_THAN_OR_EQUAL, new Reference(BIGINT, "ordering"), new Reference(BIGINT, "limit")))))
                                                        .left(assignUniqueId("unique", values("corr", "limit")))
                                                        .right(filter(TRUE, values("match", "ordering", "payload"))))))));
    }

    @Test
    public void rewritesLeftCorrelatedTopNWithProjection()
    {
        tester().assertThat(new TransformCorrelatedLateralTopNToJoin(tester().getPlannerContext()))
                .on(p -> {
                    var corr = p.symbol("corr", BIGINT);
                    var limit = p.symbol("limit", BIGINT);
                    var match = p.symbol("match", BIGINT);
                    var ordering = p.symbol("ordering", BIGINT);
                    var payload = p.symbol("payload", BIGINT);
                    var payloadAlias = p.symbol("payload_alias", BIGINT);

                    return p.correlatedJoin(
                            ImmutableList.of(corr, limit),
                            p.values(corr, limit),
                            LEFT,
                            TRUE,
                            p.project(
                                    Assignments.of(payloadAlias, new Constant(BIGINT, 11L)),
                                    p.topN(
                                            1,
                                            ImmutableList.of(ordering),
                                            p.filter(
                                                    new Logical(
                                                            AND,
                                                            ImmutableList.of(
                                                                    new Comparison(EQUAL, match.toSymbolReference(), corr.toSymbolReference()),
                                                                    new Comparison(LESS_THAN_OR_EQUAL, ordering.toSymbolReference(), limit.toSymbolReference()))),
                                                    p.values(match, ordering, payload)))));
                })
                .matches(
                        project(
                                project(
                                        ImmutableMap.of("payload_alias", expression(new Constant(BIGINT, 11L))),
                                        filter(
                                                new Comparison(LESS_THAN_OR_EQUAL, new Reference(BIGINT, "row_number"), new Constant(BIGINT, 1L)),
                                                window(builder -> builder
                                                                .specification(specification(
                                                                        ImmutableList.of("unique"),
                                                                        ImmutableList.of("ordering"),
                                                                        ImmutableMap.of("ordering", ASC_NULLS_FIRST)))
                                                                .addFunction("row_number", windowFunction("row_number", ImmutableList.of(), DEFAULT_FRAME)),
                                                        join(LEFT, builder -> builder
                                                                .filter(new Logical(
                                                                        AND,
                                                                        ImmutableList.of(
                                                                                new Comparison(EQUAL, new Reference(BIGINT, "match"), new Reference(BIGINT, "corr")),
                                                                                new Comparison(LESS_THAN_OR_EQUAL, new Reference(BIGINT, "ordering"), new Reference(BIGINT, "limit")))))
                                                                .left(assignUniqueId("unique", values("corr", "limit")))
                                                                .right(filter(TRUE, values("match", "ordering", "payload")))))))));
    }

    @Test
    public void rewritesCorrelatedLimitWithSort()
    {
        tester().assertThat(new TransformCorrelatedLateralTopNToJoin(tester().getPlannerContext()))
                .on(p -> {
                    var corr = p.symbol("corr", BIGINT);
                    var limit = p.symbol("limit", BIGINT);
                    var match = p.symbol("match", BIGINT);
                    var ordering = p.symbol("ordering", BIGINT);
                    var payload = p.symbol("payload", BIGINT);

                    return p.correlatedJoin(
                            ImmutableList.of(corr, limit),
                            p.values(corr, limit),
                            INNER,
                            TRUE,
                            p.limit(
                                    1,
                                    p.sort(
                                            ImmutableList.of(ordering),
                                            p.filter(
                                                    new Logical(
                                                            AND,
                                                            ImmutableList.of(
                                                                    new Comparison(EQUAL, match.toSymbolReference(), corr.toSymbolReference()),
                                                                    new Comparison(LESS_THAN_OR_EQUAL, ordering.toSymbolReference(), limit.toSymbolReference()))),
                                                    p.values(match, ordering, payload)))));
                })
                .matches(
                        project(
                                filter(
                                        new Comparison(LESS_THAN_OR_EQUAL, new Reference(BIGINT, "row_number"), new Constant(BIGINT, 1L)),
                                        window(builder -> builder
                                                        .specification(specification(
                                                                ImmutableList.of("unique"),
                                                                ImmutableList.of("ordering"),
                                                                ImmutableMap.of("ordering", ASC_NULLS_FIRST)))
                                                        .addFunction("row_number", windowFunction("row_number", ImmutableList.of(), DEFAULT_FRAME)),
                                                join(INNER, builder -> builder
                                                        .filter(new Logical(
                                                                AND,
                                                                ImmutableList.of(
                                                                        new Comparison(EQUAL, new Reference(BIGINT, "match"), new Reference(BIGINT, "corr")),
                                                                        new Comparison(LESS_THAN_OR_EQUAL, new Reference(BIGINT, "ordering"), new Reference(BIGINT, "limit")))))
                                                        .left(assignUniqueId("unique", values("corr", "limit")))
                                                        .right(filter(TRUE, values("match", "ordering", "payload"))))))));
    }

    @Test
    public void doesNotFireOnScalarSubqueryShape()
    {
        tester().assertThat(new TransformCorrelatedLateralTopNToJoin(tester().getPlannerContext()))
                .on(p -> {
                    var corr = p.symbol("corr", BIGINT);
                    var match = p.symbol("match", BIGINT);
                    var ordering = p.symbol("ordering", BIGINT);

                    return p.correlatedJoin(
                            ImmutableList.of(corr),
                            p.values(corr),
                            p.project(
                                    Assignments.identity(ordering),
                                    p.enforceSingleRow(
                                            p.topN(
                                                    1,
                                                    ImmutableList.of(ordering),
                                                    p.filter(
                                                            new Comparison(EQUAL, match.toSymbolReference(), corr.toSymbolReference()),
                                                            p.values(match, ordering))))));
                })
                .doesNotFire();
    }
}
