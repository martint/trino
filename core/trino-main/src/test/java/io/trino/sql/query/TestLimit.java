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

@TestInstance(PER_CLASS)
@Execution(CONCURRENT)
public class TestLimit
{
    private final QueryAssertions assertions = new QueryAssertions();

    @AfterAll
    public void teardown()
    {
        assertions.close();
    }

    @Test
    public void testLimitCardinality()
    {
        // LIMIT smaller than the input returns exactly that many rows
        assertThat(assertions.query("SELECT count(*) FROM (SELECT x FROM (VALUES 1, 2, 3, 4, 5) t(x) LIMIT 3)"))
                .matches("VALUES BIGINT '3'");

        // LIMIT larger than the input is a no-op
        assertThat(assertions.query("SELECT x FROM (VALUES 1, 2, 3) t(x) ORDER BY x LIMIT 100"))
                .ordered()
                .matches("VALUES 1, 2, 3");

        // LIMIT 0 returns no rows
        assertThat(assertions.query("SELECT x FROM (VALUES 1, 2, 3) t(x) LIMIT 0"))
                .returnsEmptyResult();
    }

    @Test
    public void testLimitOverUnionAll()
    {
        assertThat(assertions.query(
                "SELECT count(*) FROM (" +
                        "SELECT x FROM (VALUES 1, 2, 3) t(x) UNION ALL " +
                        "SELECT x FROM (VALUES 4, 5, 6) u(x) " +
                        "LIMIT 4)"))
                .matches("VALUES BIGINT '4'");
    }

    @Test
    public void testLimitWithOrderBy()
    {
        assertThat(assertions.query("SELECT x FROM (VALUES 3, 1, 2) t(x) ORDER BY x LIMIT 2"))
                .ordered()
                .matches("VALUES 1, 2");
    }

    @Test
    public void testLimitRemovedAboveGlobalAggregation()
    {
        // a global aggregation produces a single row, so the LIMIT is redundant and must not change the result
        assertThat(assertions.query("SELECT max(x) FROM (VALUES 1, 2, 3) t(x) LIMIT 5"))
                .matches("VALUES 3");
    }

    @Test
    public void testLimitWithAggregation()
    {
        // GROUP BY produces one row per group; LIMIT returns a subset of the groups
        assertThat(assertions.query(
                "SELECT count(*) FROM (" +
                        "SELECT k, sum(v) FROM (VALUES (1, 10), (2, 20), (3, 30)) t(k, v) GROUP BY k LIMIT 2)"))
                .matches("VALUES BIGINT '2'");
    }

    @Test
    public void testLimitInInlineView()
    {
        // nested LIMIT: the outer limit further restricts the inner one
        assertThat(assertions.query(
                "SELECT count(*) FROM (SELECT x FROM (SELECT x FROM (VALUES 1, 2, 3, 4, 5) t(x) LIMIT 4) LIMIT 2)"))
                .matches("VALUES BIGINT '2'");
    }

    @Test
    public void testDistinctLimit()
    {
        // DISTINCT followed by LIMIT (DistinctLimitNode) returns the requested number of distinct rows
        assertThat(assertions.query(
                "SELECT count(*) FROM (SELECT DISTINCT x FROM (VALUES 1, 1, 2, 2, 3) t(x) LIMIT 2)"))
                .matches("VALUES BIGINT '2'");

        // DISTINCT + LIMIT above a join
        assertThat(assertions.query(
                "SELECT DISTINCT x " +
                        "FROM (VALUES 1) t(x) JOIN (VALUES 10, 20) u(a) ON t.x < u.a " +
                        "LIMIT 100"))
                .matches("VALUES 1");
    }

    @Test
    public void testLimitMaxValues()
    {
        // LIMIT at Integer.MAX_VALUE and Long.MAX_VALUE is accepted and behaves as a no-op here
        assertThat(assertions.query("SELECT x FROM (VALUES 1, 2, 3) t(x) ORDER BY x LIMIT " + Integer.MAX_VALUE))
                .ordered()
                .matches("VALUES 1, 2, 3");
        assertThat(assertions.query("SELECT x FROM (VALUES 1, 2, 3) t(x) LIMIT " + Long.MAX_VALUE))
                .matches("VALUES 1, 2, 3");

        // ORDER BY ... LIMIT above Integer.MAX_VALUE (a TopN) is not supported
        assertThat(assertions.query("SELECT x FROM (VALUES 1, 2, 3) t(x) ORDER BY x LIMIT " + Long.MAX_VALUE))
                .failure().hasMessageContaining("ORDER BY LIMIT > 2147483647 is not supported");
    }
}
