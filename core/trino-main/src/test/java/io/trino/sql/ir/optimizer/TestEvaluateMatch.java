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
package io.trino.sql.ir.optimizer;

import com.google.common.collect.ImmutableList;
import com.google.common.collect.ImmutableMap;
import io.trino.sql.ir.Bind;
import io.trino.sql.ir.Comparison;
import io.trino.sql.ir.Constant;
import io.trino.sql.ir.Expression;
import io.trino.sql.ir.Lambda;
import io.trino.sql.ir.Match;
import io.trino.sql.ir.MatchClause;
import io.trino.sql.ir.Reference;
import io.trino.sql.ir.optimizer.rule.EvaluateMatch;
import io.trino.sql.planner.Symbol;
import org.junit.jupiter.api.Test;

import java.util.Optional;

import static io.trino.spi.type.BigintType.BIGINT;
import static io.trino.spi.type.VarcharType.VARCHAR;
import static io.trino.sql.ir.Comparison.Operator.EQUAL;
import static io.trino.sql.ir.IrExpressions.equalityClause;
import static io.trino.sql.planner.TestingPlannerContext.PLANNER_CONTEXT;
import static io.trino.testing.TestingSession.testSession;
import static org.assertj.core.api.Assertions.assertThat;

public class TestEvaluateMatch
{
    @Test
    void test()
    {
        assertThat(optimize(
                new Match(
                        new Reference(BIGINT, "x"),
                        ImmutableList.of(equalityClause(new Constant(BIGINT, 1L), new Reference(VARCHAR, "a"))),
                        new Reference(VARCHAR, "b"))))
                .isEqualTo(Optional.empty());

        assertThat(optimize(
                new Match(
                        new Constant(BIGINT, 1L),
                        ImmutableList.of(equalityClause(new Constant(BIGINT, 1L), new Reference(VARCHAR, "a"))),
                        new Reference(VARCHAR, "b"))))
                .describedAs("match")
                .isEqualTo(Optional.of(new Reference(VARCHAR, "a")));

        assertThat(optimize(
                new Match(
                        new Constant(BIGINT, 1L),
                        ImmutableList.of(equalityClause(new Constant(BIGINT, 2L), new Reference(VARCHAR, "a"))),
                        new Reference(VARCHAR, "b"))))
                .describedAs("no match")
                .isEqualTo(Optional.of(new Reference(VARCHAR, "b")));

        // A clause whose Bind captures a non-constant outer reference must not be evaluated even
        // when the operand is constant: the body depends on a value unknown at planning time.
        Symbol capturedX = new Symbol(BIGINT, "captured_x");
        Symbol parameter = new Symbol(BIGINT, "p");
        MatchClause clauseWithCapture = new MatchClause(
                new Bind(
                        ImmutableList.of(new Reference(BIGINT, "x")),
                        new Lambda(
                                ImmutableList.of(capturedX, parameter),
                                new Comparison(EQUAL, new Reference(BIGINT, parameter.name()), new Reference(BIGINT, capturedX.name())))),
                new Reference(VARCHAR, "a"));
        assertThat(optimize(
                new Match(
                        new Constant(BIGINT, 1L),
                        ImmutableList.of(clauseWithCapture),
                        new Reference(VARCHAR, "b"))))
                .describedAs("non-constant capture")
                .isEqualTo(Optional.empty());
    }

    private Optional<Expression> optimize(Expression expression)
    {
        return new EvaluateMatch(PLANNER_CONTEXT).apply(expression, testSession(), ImmutableMap.of());
    }
}
