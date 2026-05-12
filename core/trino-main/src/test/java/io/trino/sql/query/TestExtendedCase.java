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
package io.trino.sql.query;

import org.junit.jupiter.api.AfterAll;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.TestInstance;
import org.junit.jupiter.api.parallel.Execution;

import static org.assertj.core.api.Assertions.assertThat;
import static org.junit.jupiter.api.TestInstance.Lifecycle.PER_CLASS;
import static org.junit.jupiter.api.parallel.ExecutionMode.CONCURRENT;

/**
 * End-to-end tests for SQL:2023 F262 (Extended {@code CASE} expression). Each WHEN may carry a
 * predicate fragment whose LHS is supplied by the surrounding CASE operand. The operand evaluates
 * once across all clauses, which we exercise here with non-deterministic operands.
 *
 * <p>Tests use integer THEN results to side-step varchar-length type inference; the F262
 * semantics being verified are independent of result type.
 */
@TestInstance(PER_CLASS)
@Execution(CONCURRENT)
public class TestExtendedCase
{
    private final QueryAssertions assertions = new QueryAssertions();

    @AfterAll
    public void teardown()
    {
        assertions.close();
    }

    @Test
    public void testComparison()
    {
        assertThat(assertions.query(
                """
                SELECT CASE x
                            WHEN > 100 THEN 1
                            WHEN < 0 THEN 2
                            ELSE 3
                       END
                FROM (VALUES 200, -1, 50) t(x)
                """))
                .matches("VALUES 1, 2, 3");
    }

    @Test
    public void testBetween()
    {
        assertThat(assertions.query(
                """
                SELECT CASE x
                            WHEN BETWEEN 1 AND 10 THEN 1
                            WHEN BETWEEN 11 AND 20 THEN 2
                            ELSE 3
                       END
                FROM (VALUES 5, 15, 25) t(x)
                """))
                .matches("VALUES 1, 2, 3");

        assertThat(assertions.query(
                """
                SELECT CASE x
                            WHEN NOT BETWEEN 1 AND 10 THEN 1
                            ELSE 0
                       END
                FROM (VALUES 5, 11) t(x)
                """))
                .matches("VALUES 0, 1");
    }

    @Test
    public void testInList()
    {
        assertThat(assertions.query(
                """
                SELECT CASE x
                            WHEN IN (1, 2, 3) THEN 1
                            WHEN IN (4, 5) THEN 2
                            ELSE 3
                       END
                FROM (VALUES 2, 5, 9) t(x)
                """))
                .matches("VALUES 1, 2, 3");
    }

    @Test
    public void testIsNull()
    {
        assertThat(assertions.query(
                """
                SELECT CASE x
                            WHEN IS NULL THEN 1
                            WHEN IS NOT NULL THEN 2
                       END
                FROM (VALUES CAST(NULL AS integer), 1) t(x)
                """))
                .matches("VALUES 1, 2");
    }

    @Test
    public void testLike()
    {
        assertThat(assertions.query(
                """
                SELECT CASE x
                            WHEN LIKE 'a%' THEN 1
                            WHEN LIKE 'b%' THEN 2
                            ELSE 3
                       END
                FROM (VALUES VARCHAR 'apple', 'banana', 'cherry') t(x)
                """))
                .matches("VALUES 1, 2, 3");
    }

    @Test
    public void testDistinctFrom()
    {
        // IS [NOT] DISTINCT FROM uses three-valued-logic-free equality, so NULL operands match.
        assertThat(assertions.query(
                """
                SELECT CASE x
                            WHEN IS NOT DISTINCT FROM CAST(NULL AS integer) THEN 1
                            ELSE 2
                       END
                FROM (VALUES CAST(NULL AS integer), 1) t(x)
                """))
                .matches("VALUES 1, 2");
    }

    @Test
    public void testMixedWithBareEquality()
    {
        // The legacy bare-equality WHEN form coexists with F262 predicate-fragment WHENs.
        assertThat(assertions.query(
                """
                SELECT CASE x
                            WHEN 0 THEN 1
                            WHEN > 0 THEN 2
                            ELSE 3
                       END
                FROM (VALUES 0, 5, -3) t(x)
                """))
                .matches("VALUES 1, 2, 3");
    }

    @Test
    public void testFirstMatchWins()
    {
        // Clause order matters: a value matching multiple predicates returns the first clause's
        // result, identical to the legacy simple-CASE semantics.
        assertThat(assertions.query(
                """
                SELECT CASE x
                            WHEN < 100 THEN 1
                            WHEN < 1000 THEN 2
                            ELSE 3
                       END
                FROM (VALUES 5) t(x)
                """))
                .matches("VALUES 1");
    }

    @Test
    public void testSingleOperandEvaluation()
    {
        // The operand evaluates exactly once per row across all clause predicates and the result.
        // Re-evaluating a non-deterministic operand per clause would let a row simultaneously
        // satisfy multiple non-overlapping predicates — we count rows producing nothing in
        // {a, b, c} and expect zero, which only holds if the operand is sampled once.
        assertThat(assertions.query(
                """
                SELECT count(*)
                FROM (
                    SELECT CASE random()
                                WHEN < 0.34 THEN 'a'
                                WHEN < 0.67 THEN 'b'
                                ELSE 'c'
                           END AS bucket
                    FROM unnest(sequence(1, 200)) AS t(x))
                WHERE bucket IS NULL OR bucket NOT IN ('a', 'b', 'c')
                """))
                .matches("VALUES BIGINT '0'");
    }

    @Test
    public void testRejectsInSearchedCase()
    {
        // Searched CASE has no implicit LHS, so predicate-fragment WHENs are syntactically
        // allowed by the grammar but rejected by the analyzer.
        assertThat(assertions.query(
                """
                SELECT CASE
                            WHEN > 5 THEN 1
                            ELSE 0
                       END
                FROM (VALUES 7) t(x)
                """))
                .failure()
                .hasMessageMatching("(?s).*WHEN with a predicate fragment is only allowed in simple CASE expressions.*");
    }
}
