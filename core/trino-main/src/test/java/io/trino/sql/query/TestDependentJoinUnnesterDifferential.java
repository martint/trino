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

import io.trino.Session;
import io.trino.testing.MaterializedResult;
import org.junit.jupiter.api.AfterAll;
import org.junit.jupiter.api.TestInstance;
import org.junit.jupiter.api.parallel.Execution;
import org.junit.jupiter.params.ParameterizedTest;
import org.junit.jupiter.params.provider.ValueSource;

import static io.trino.SystemSessionProperties.DECORRELATION_STRATEGY;
import static io.trino.sql.planner.OptimizerConfig.DecorrelationStrategy.LEGACY;
import static io.trino.sql.planner.OptimizerConfig.DecorrelationStrategy.UNIFIED;
import static org.assertj.core.api.Assertions.assertThat;
import static org.junit.jupiter.api.TestInstance.Lifecycle.PER_CLASS;
import static org.junit.jupiter.api.parallel.ExecutionMode.CONCURRENT;

/**
 * Differential correctness check for the unified dependent-join framework: every query is run
 * under both `decorrelation_strategy = LEGACY` and `= UNIFIED`, and the two result sets must
 * match (order-independent). This validates the framework against the legacy decorrelator as the
 * oracle across a broad set of correlated-subquery shapes, without hand-computing expected values.
 * Queries the framework can't handle fall through to legacy under UNIFIED, so they trivially agree;
 * the interesting cases are the ones the framework actually rewrites.
 */
@TestInstance(PER_CLASS)
@Execution(CONCURRENT)
public class TestDependentJoinUnnesterDifferential
{
    private final QueryAssertions assertions = new QueryAssertions();

    @AfterAll
    public void teardown()
    {
        assertions.close();
    }

    @ParameterizedTest
    @ValueSource(strings = {
            // correlated EXISTS / NOT EXISTS
            "SELECT a FROM (VALUES 1, 2, 3, 4) t(a) WHERE EXISTS (SELECT 1 FROM (VALUES 2, 4, 6) u(b) WHERE u.b = t.a)",
            "SELECT a FROM (VALUES 1, 2, 3, 4) t(a) WHERE NOT EXISTS (SELECT 1 FROM (VALUES 2, 4, 6) u(b) WHERE u.b = t.a)",
            "SELECT a FROM (VALUES 1, 5, 10) t(a) WHERE EXISTS (SELECT 1 FROM (VALUES 3, 7) u(b) WHERE u.b < t.a)",
            // correlated IN
            "SELECT a FROM (VALUES 1, 2, 3) t(a) WHERE a IN (SELECT u.b FROM (VALUES 1, 3, 5) u(b) WHERE u.b <> t.a + 1)",
            // correlated IN / NOT IN three-valued NULL semantics (legacy IN rule is the oracle):
            // a NULL in the subquery turns a non-match into UNKNOWN (filtered in WHERE), a match
            // still wins, and an empty subquery is FALSE even for a NULL probe.
            "SELECT a FROM (VALUES 1, 2, 3) t(a) WHERE a IN (SELECT u.b FROM (VALUES 2, CAST(NULL AS INTEGER)) u(b) WHERE u.b IS NULL OR u.b <> t.a + 100)",
            "SELECT a FROM (VALUES 1, 2, 3) t(a) WHERE a NOT IN (SELECT u.b FROM (VALUES 2, CAST(NULL AS INTEGER)) u(b) WHERE u.b IS NULL OR u.b > t.a - 100)",
            "SELECT a FROM (VALUES 1, CAST(NULL AS INTEGER), 2) t(a) WHERE a IN (SELECT u.b FROM (VALUES 1, 2) u(b) WHERE u.b >= t.a - 100)",
            // correlated IN whose subquery has NO matching row for some outer rows (empty → FALSE)
            "SELECT a FROM (VALUES 1, 2, 3) t(a) WHERE a IN (SELECT u.b FROM (VALUES 10, 20) u(b) WHERE u.b = t.a * 10)",
            // correlated scalar subqueries (fall back to legacy, must still agree)
            "SELECT a, (SELECT max(u.b) FROM (VALUES 10, 20, 30) u(b) WHERE u.b > t.a * 10) FROM (VALUES 1, 2, 3) t(a)",
            "SELECT a, (SELECT count(*) FROM (VALUES 1, 2, 3, 4, 5) u(b) WHERE u.b < t.a) FROM (VALUES 1, 3, 5) t(a)",
            // correlated aggregate in WHERE (the COUNT-bug shape)
            "SELECT a FROM (VALUES 1, 5, 10) t(a) WHERE (SELECT count(*) FROM (VALUES 2, 4, 6) u(b) WHERE u.b < t.a) >= 2",
            // scalar aggregate with a projection ON TOP of the aggregate (legacy …WithProjection)
            "SELECT a, (SELECT count(*) + 1 FROM (VALUES 1, 2, 3) u(b) WHERE u.b < t.a) FROM (VALUES 1, 2, 3) t(a)",
            "SELECT a, (SELECT max(u.b) * 10 FROM (VALUES 1, 2, 3) u(b) WHERE u.b < t.a) FROM (VALUES 2, 3) t(a)",
            "SELECT a, (SELECT count(DISTINCT u.b) + 1 FROM (VALUES 1, 1, 2, 3) u(b) WHERE u.b < t.a) FROM (VALUES 2, 3) t(a)",
            // correlation referenced in the projection on top of the aggregate
            "SELECT a, (SELECT t.a + count(*) FROM (VALUES 1, 2, 3) u(b) WHERE u.b < t.a) FROM (VALUES 1, 2, 3) t(a)",
            // grouped aggregate with a projection on top, inside EXISTS
            "SELECT a FROM (VALUES 1, 2, 3) t(a) WHERE EXISTS (SELECT max(u.b) + 1 FROM (VALUES 1, 2, 3) u(b) WHERE u.b < t.a GROUP BY u.b)",
            // scalar global aggregates exercising the non_null mask: empty group → count 0 / sum NULL
            "SELECT a, (SELECT count(*) FROM (VALUES 100) u(b) WHERE u.b = t.a) FROM (VALUES 1, 2, 3) t(a)",
            "SELECT a, (SELECT sum(u.b) FROM (VALUES 10) u(b) WHERE u.b > t.a * 100) FROM (VALUES 1, 2) t(a)",
            "SELECT a, (SELECT count(*) FROM (VALUES 1, 2, 3, 4) u(b) WHERE u.b <= t.a) FROM (VALUES 0, 2, 4, 9) t(a)",
            "SELECT a, (SELECT avg(CAST(u.b AS double)) FROM (VALUES 2, 4, 6) u(b) WHERE u.b <= t.a) FROM (VALUES 1, 4, 10) t(a)",
            // non-aggregate scalar subquery (EnforceSingleRowNode): ≤1 match per outer, NULL if 0
            "SELECT a, (SELECT u.b FROM (VALUES (1, 10), (2, 20)) u(k, b) WHERE u.k = t.a) FROM (VALUES 1, 2, 3) t(a)",
            // outer input contains a SemiJoin (uncorrelated IN) under a correlated LEFT subquery —
            // PlanCopier can't clone a SemiJoin, so the magic-set must bail gracefully to legacy
            // (not crash) and still produce the right answer.
            "SELECT t.a, l.b FROM (VALUES 1, 2, 3) t(a) " +
                    "LEFT JOIN LATERAL (SELECT u.b FROM (VALUES 2, 3, 4) u(b) WHERE u.b > t.a) l(b) ON true " +
                    "WHERE t.a IN (VALUES 1, 2)",
                    // quantified comparisons
            "SELECT a FROM (VALUES 1, 5, 10) t(a) WHERE a > ALL (SELECT u.b FROM (VALUES 2, 4) u(b) WHERE u.b < t.a + 100)",
            "SELECT a FROM (VALUES 1, 5, 10) t(a) WHERE a = ANY (SELECT u.b FROM (VALUES 5, 10, 15) u(b) WHERE u.b <= t.a)",
            // LATERAL inner join with correlation in the filter (legacy handles this shape too)
            "SELECT t.a, l.b FROM (VALUES 1, 2, 3) t(a), LATERAL (SELECT u.b FROM (VALUES 2, 4, 6) u(b) WHERE u.b > t.a) l(b)",
            // LATERAL LEFT join with correlation in the filter (legacy handles filter-only LEFT)
            "SELECT t.a, l.b FROM (VALUES 1, 2, 3) t(a) LEFT JOIN LATERAL (SELECT u.b FROM (VALUES 2, 4, 6) u(b) WHERE u.b > t.a) l(b) ON true",
            // NOTE: correlation-in-projection and LATERAL LIMIT/TopN are framework-only (legacy
            // can't decorrelate them), so they have no oracle here — they're hand-verified in
            // TestDependentJoinUnnester instead.
            // inner join inside the subquery, both sides correlated
            "SELECT a FROM (VALUES 1, 2, 3) t(a) WHERE EXISTS (SELECT 1 FROM (VALUES 1, 2) u(b) JOIN (VALUES 2, 3) v(c) ON u.b = v.c WHERE u.b = t.a AND v.c = t.a)",
            // nested correlation (EXISTS within EXISTS)
            "SELECT a FROM (VALUES 1, 2, 3) t(a) WHERE EXISTS (SELECT 1 FROM (VALUES 1, 2, 3) u(b) WHERE u.b = t.a AND EXISTS (SELECT 1 FROM (VALUES 2, 3) w(c) WHERE w.c = u.b))",
            // correlation referencing multiple outer columns
            "SELECT a, b FROM (VALUES (1, 10), (2, 20), (3, 30)) t(a, b) WHERE EXISTS (SELECT 1 FROM (VALUES (1, 10), (2, 99)) u(c, d) WHERE u.c = t.a AND u.d = t.b)",
            // NULL correlation values
            "SELECT t.a, l.b FROM (VALUES 1, CAST(NULL AS INTEGER), 2) t(a) LEFT JOIN LATERAL (SELECT u.b FROM (VALUES 2, 3) u(b) WHERE u.b > t.a) l(b) ON true",
            // -- edge cases / stress --
            // empty outer input
            "SELECT a FROM (SELECT 1 WHERE false) t(a) WHERE EXISTS (SELECT 1 FROM (VALUES 1, 2) u(b) WHERE u.b = t.a)",
            // subquery empty for every outer row
            "SELECT a FROM (VALUES 1, 2, 3) t(a) WHERE EXISTS (SELECT 1 FROM (VALUES 100) u(b) WHERE u.b = t.a)",
            // subquery empty for every outer row, NOT EXISTS (all pass)
            "SELECT a FROM (VALUES 1, 2, 3) t(a) WHERE NOT EXISTS (SELECT 1 FROM (VALUES 100) u(b) WHERE u.b = t.a)",
            // two correlated subqueries in one predicate
            "SELECT a FROM (VALUES 1, 2, 3, 4) t(a) WHERE EXISTS (SELECT 1 FROM (VALUES 2, 4) u(b) WHERE u.b = t.a) OR EXISTS (SELECT 1 FROM (VALUES 1, 3) v(c) WHERE v.c = t.a)",
            // correlated subquery in SELECT and in WHERE
            "SELECT a, (SELECT count(*) FROM (VALUES 1, 2, 3) u(b) WHERE u.b <= t.a) FROM (VALUES 1, 2, 3) t(a) WHERE EXISTS (SELECT 1 FROM (VALUES 2, 3) v(c) WHERE v.c = t.a)",
            // EXISTS with a disjunctive correlated predicate
            "SELECT a FROM (VALUES 1, 2, 3, 4) t(a) WHERE EXISTS (SELECT 1 FROM (VALUES 2, 3) u(b) WHERE u.b = t.a OR u.b = t.a - 1)",
            // three-level nested correlation
            "SELECT a FROM (VALUES 1, 2, 3) t(a) WHERE EXISTS (SELECT 1 FROM (VALUES 1, 2, 3) u(b) WHERE u.b = t.a AND EXISTS (SELECT 1 FROM (VALUES 2, 3) v(c) WHERE v.c = u.b AND EXISTS (SELECT 1 FROM (VALUES 3) w(d) WHERE w.d = v.c)))",
            // (DISTINCT inside a correlated IN subquery is unsupported by LEGACY — no oracle —
            //  so it's not a differential case.)
            // <> ALL / >= ANY
            "SELECT a FROM (VALUES 1, 5, 10) t(a) WHERE a <> ALL (SELECT u.b FROM (VALUES 5, 10) u(b) WHERE u.b <= t.a)",
            "SELECT a FROM (VALUES 1, 5, 10) t(a) WHERE a >= ANY (SELECT u.b FROM (VALUES 2, 7) u(b) WHERE u.b < t.a + 100)",
            // correlated subquery whose outer side is itself a join
            "SELECT t.a, s.x FROM (VALUES 1, 2) t(a) JOIN (VALUES (1, 'p'), (2, 'q')) s(k, x) ON t.a = s.k WHERE EXISTS (SELECT 1 FROM (VALUES 1) u(b) WHERE u.b = t.a)",
            // correlation compared with arithmetic on both sides
            "SELECT a FROM (VALUES 2, 4, 6) t(a) WHERE EXISTS (SELECT 1 FROM (VALUES 1, 2, 3) u(b) WHERE u.b * 2 = t.a)",
            // LATERAL inner with two correlated filter conjuncts
            "SELECT t.a, l.b FROM (VALUES (1, 5), (2, 6)) t(a, k), LATERAL (SELECT u.b FROM (VALUES (1, 5), (1, 9), (2, 6)) u(c, b) WHERE u.c = t.a AND u.b = t.k) l(b)",
            // correlated UNNEST (the array is a correlation reference) — legacy DecorrelateUnnest
            // is the oracle. CROSS JOIN UNNEST is an INNER correlated join → INNER unnest pushdown.
            "SELECT t.a, u.x FROM (VALUES (1, ARRAY[10, 20]), (2, ARRAY[30])) t(a, arr) CROSS JOIN UNNEST(arr) u(x)",
            // LEFT JOIN UNNEST with an empty array null-extends — exercises the magic-set + the
            // CorrelationRebinder UnnestNode path.
            "SELECT t.a, u.x FROM (VALUES (1, ARRAY[10, 20]), (2, CAST(ARRAY[] AS ARRAY(integer)))) t(a, arr) LEFT JOIN UNNEST(arr) u(x) ON true",
            // UNNEST WITH ORDINALITY — the ordinality column must survive the pushdown.
            "SELECT t.a, u.x, u.ord FROM (VALUES (1, ARRAY[10, 20, 30])) t(a, arr) CROSS JOIN UNNEST(arr) WITH ORDINALITY u(x, ord)",
            // UNNEST of two arrays at once, with a projection over the unnested values.
            "SELECT t.a, u.x + u.y FROM (VALUES (1, ARRAY[10, 20], ARRAY[1, 2])) t(a, arr1, arr2) CROSS JOIN UNNEST(arr1, arr2) u(x, y)",
            // NOTE: UNNEST nested inside a LATERAL with a correlated filter (e.g.
            // `LATERAL (SELECT sum(x) FROM UNNEST(arr) WHERE x > a)`) is framework-only — legacy
            // DecorrelateUnnest rejects the correlated filter on the unnested value — so it's
            // hand-verified in TestDependentJoinUnnester (it exercises visitUnnest).
            // NOTE: outer joins inside the subquery are framework-only (legacy throws "not
            // supported"), so they're hand-verified in TestDependentJoinUnnester, not here.
            // GROUPING SETS / ROLLUP / CUBE inside EXISTS — planned as an aggregation over a
            // GroupIdNode; legacy handles the EXISTS form, so it's an oracle. The empty grouping set
            // must not manufacture phantom EXISTS-true rows for outer rows with no matching source.
            "SELECT t.a FROM (VALUES 1, 2, 5) t(a) WHERE EXISTS (" +
                    "SELECT count(*) FROM (VALUES (1, 10), (1, 20), (2, 30)) u(k, b) WHERE u.k = t.a GROUP BY GROUPING SETS ((u.k), ()))",
            "SELECT t.a FROM (VALUES 1, 2, 5) t(a) WHERE EXISTS (" +
                    "SELECT u.k, count(*) FROM (VALUES (1, 10), (1, 20), (2, 30)) u(k, b) WHERE u.k = t.a GROUP BY ROLLUP (u.k))",
            "SELECT t.a FROM (VALUES 1, 2, 5) t(a) WHERE EXISTS (" +
                    "SELECT u.k, u.b, count(*) FROM (VALUES (1, 10), (1, 20), (2, 30)) u(k, b) WHERE u.k = t.a GROUP BY CUBE (u.k, u.b))",
    })
    public void unifiedMatchesLegacy(String query)
    {
        MaterializedResult legacy = assertions.execute(withStrategy(LEGACY.name()), query);
        MaterializedResult unified = assertions.execute(withStrategy(UNIFIED.name()), query);

        assertThat(unified.getTypes()).isEqualTo(legacy.getTypes());
        assertThat(unified.getMaterializedRows())
                .containsExactlyInAnyOrderElementsOf(legacy.getMaterializedRows());
    }

    private Session withStrategy(String strategy)
    {
        return assertions.sessionBuilder()
                .setSystemProperty(DECORRELATION_STRATEGY, strategy)
                .build();
    }
}
