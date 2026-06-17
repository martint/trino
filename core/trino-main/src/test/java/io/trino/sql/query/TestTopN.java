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
public class TestTopN
{
    private final QueryAssertions assertions = new QueryAssertions();

    @AfterAll
    public void teardown()
    {
        assertions.close();
    }

    @Test
    public void testTopN()
    {
        assertThat(assertions.query("SELECT x FROM (VALUES 5, 3, 1, 4, 2) t(x) ORDER BY x LIMIT 3"))
                .ordered()
                .matches("VALUES 1, 2, 3");

        assertThat(assertions.query("SELECT x FROM (VALUES 5, 3, 1, 4, 2) t(x) ORDER BY x DESC LIMIT 3"))
                .ordered()
                .matches("VALUES 5, 4, 3");

        // TopN with a filter
        assertThat(assertions.query("SELECT x FROM (VALUES 5, 3, 1, 4, 2) t(x) WHERE x > 2 ORDER BY x DESC LIMIT 2"))
                .ordered()
                .matches("VALUES 5, 4");
    }

    @Test
    public void testTopNOverAggregation()
    {
        // sums per group: k=1 -> 10, k=2 -> 5, k=3 -> 20; order by the aggregate and keep the two smallest
        assertThat(assertions.query(
                "SELECT k, sum(v) FROM (VALUES (1, 10), (2, 5), (3, 20)) t(k, v) GROUP BY k ORDER BY sum(v) LIMIT 2"))
                .ordered()
                .matches("VALUES (2, BIGINT '5'), (1, BIGINT '10')");
    }

    @Test
    public void testTopNOverTopN()
    {
        // inner TopN keeps the four smallest (1, 2, 3, 4); outer TopN keeps the two largest of those
        assertThat(assertions.query(
                "SELECT x FROM (SELECT x FROM (VALUES 5, 3, 1, 4, 2) t(x) ORDER BY x LIMIT 4) ORDER BY x DESC LIMIT 2"))
                .ordered()
                .matches("VALUES 4, 3");
    }

    @Test
    public void testTopNByMultipleFields()
    {
        // mixed ascending/descending ordering across two keys
        assertThat(assertions.query(
                "SELECT a, b FROM (VALUES (1, 2), (1, 1), (2, 1)) t(a, b) ORDER BY a ASC, b DESC LIMIT 3"))
                .ordered()
                .matches("VALUES (1, 2), (1, 1), (2, 1)");
    }

    @Test
    public void testTopNWithNullOrdering()
    {
        // NULLS FIRST places the null ahead of the values
        assertThat(assertions.query(
                "SELECT a FROM (VALUES 1, 2, 3, CAST(NULL AS integer)) t(a) ORDER BY a ASC NULLS FIRST LIMIT 2"))
                .ordered()
                .matches("VALUES CAST(NULL AS integer), 1");

        // the default for ascending order is NULLS LAST, so the null is not among the first rows
        assertThat(assertions.query(
                "SELECT a FROM (VALUES 1, 2, 3, CAST(NULL AS integer)) t(a) ORDER BY a ASC LIMIT 2"))
                .ordered()
                .matches("VALUES 1, 2");
    }
}
