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
package io.trino.testing;

import com.google.common.collect.ImmutableList;
import com.google.common.collect.ImmutableSet;
import io.trino.tpch.TpchTable;
import org.apache.commons.math3.stat.descriptive.DescriptiveStatistics;
import org.junit.jupiter.api.Test;

import java.util.List;
import java.util.Set;

import static com.google.common.collect.ImmutableSet.toImmutableSet;
import static io.trino.connector.informationschema.InformationSchemaTable.INFORMATION_SCHEMA;
import static io.trino.spi.type.BigintType.BIGINT;
import static io.trino.spi.type.VarcharType.VARCHAR;
import static io.trino.testing.MaterializedResult.resultBuilder;
import static io.trino.testing.QueryAssertions.assertContains;
import static io.trino.tpch.TpchTable.NATION;
import static io.trino.tpch.TpchTable.ORDERS;
import static io.trino.tpch.TpchTable.REGION;
import static java.lang.String.format;
import static java.util.stream.Collectors.joining;
import static java.util.stream.IntStream.range;
import static org.assertj.core.api.Assertions.assertThat;

/**
 * Connector-facing query tests: metadata listing, predicate/filter pushdown and table sampling, which
 * legitimately vary by connector and so are run once per connector. Pure SQL-engine semantics (DISTINCT,
 * LIMIT, TopN, IN, aggregation, comparison predicates) are covered once by the single-node
 * {@code io.trino.sql.query} suite and by {@link AbstractTestEngineOnlyQueries}, not here.
 */
public abstract class AbstractTestQueries
        extends AbstractTestQueryFramework
{
    protected static final List<TpchTable<?>> REQUIRED_TPCH_TABLES = ImmutableList.of(NATION, ORDERS, REGION);

    @Test
    public void testLargeIn()
    {
        for (int count : largeInValuesCountData()) {
            String longValues = range(0, count)
                    .map(value -> value * 2) // Make the values discontinuous to avoid getting optimized to a BETWEEN filter
                    .mapToObj(Integer::toString)
                    .collect(joining(", "));
            assertQuery("SELECT orderkey FROM orders WHERE orderkey IN (" + longValues + ")");
            assertQuery("SELECT orderkey FROM orders WHERE orderkey NOT IN (" + longValues + ")");

            assertQuery("SELECT orderkey FROM orders WHERE orderkey IN (mod(1000, orderkey), " + longValues + ")");
            assertQuery("SELECT orderkey FROM orders WHERE orderkey NOT IN (mod(1000, orderkey), " + longValues + ")");
        }
    }

    protected List<Integer> largeInValuesCountData()
    {
        return ImmutableList.of(200, 500, 1000, 5000);
    }

    @Test
    public void testShowSchemas()
    {
        MaterializedResult result = computeActual("SHOW SCHEMAS");
        assertThat(result.getOnlyColumnAsSet()).contains(getSession().getSchema().get(), INFORMATION_SCHEMA);
    }

    @Test
    public void testShowTables()
    {
        Set<String> expectedTables = REQUIRED_TPCH_TABLES.stream()
                .map(TpchTable::getTableName)
                .collect(toImmutableSet());

        MaterializedResult result = computeActual("SHOW TABLES");
        assertThat(result.getOnlyColumnAsSet()).containsAll(expectedTables);
    }

    @Test
    public void testShowColumns()
    {
        MaterializedResult actual = computeActual("SHOW COLUMNS FROM orders");

        MaterializedResult expectedUnparametrizedVarchar = resultBuilder(getSession(), VARCHAR, VARCHAR, VARCHAR, VARCHAR)
                .row("orderkey", "bigint", "", "")
                .row("custkey", "bigint", "", "")
                .row("orderstatus", "varchar", "", "")
                .row("totalprice", "double", "", "")
                .row("orderdate", "date", "", "")
                .row("orderpriority", "varchar", "", "")
                .row("clerk", "varchar", "", "")
                .row("shippriority", "integer", "", "")
                .row("comment", "varchar", "", "")
                .build();

        MaterializedResult expectedParametrizedVarchar = resultBuilder(getSession(), VARCHAR, VARCHAR, VARCHAR, VARCHAR)
                .row("orderkey", "bigint", "", "")
                .row("custkey", "bigint", "", "")
                .row("orderstatus", "varchar(1)", "", "")
                .row("totalprice", "double", "", "")
                .row("orderdate", "date", "", "")
                .row("orderpriority", "varchar(15)", "", "")
                .row("clerk", "varchar(15)", "", "")
                .row("shippriority", "integer", "", "")
                .row("comment", "varchar(79)", "", "")
                .build();

        // Until we migrate all connectors to parametrized varchar we check two options
        assertThat(actual.equals(expectedParametrizedVarchar) || actual.equals(expectedUnparametrizedVarchar))
                .describedAs(format("%s does not match neither of %s and %s", actual, expectedParametrizedVarchar, expectedUnparametrizedVarchar))
                .isTrue();
    }

    @Test
    public void testInformationSchemaFiltering()
    {
        assertQuery(
                "SELECT table_name FROM information_schema.tables WHERE table_name = 'orders' LIMIT 1",
                "SELECT 'orders' table_name");
        assertQuery(
                "SELECT table_name FROM information_schema.columns WHERE data_type = 'bigint' AND table_name = 'nation' and column_name = 'nationkey' LIMIT 1",
                "SELECT 'nation' table_name");
    }

    @Test
    public void testInformationSchemaUppercaseName()
    {
        assertQuery(
                "SELECT table_name FROM information_schema.tables WHERE table_catalog = 'LOCAL'",
                "SELECT '' WHERE false");
        assertQuery(
                "SELECT table_name FROM information_schema.tables WHERE table_schema = 'TINY'",
                "SELECT '' WHERE false");
        assertQuery(
                "SELECT table_name FROM information_schema.tables WHERE table_name = 'ORDERS'",
                "SELECT '' WHERE false");
    }

    @Test
    public void testTableSampleBernoulliBoundaryValues()
    {
        MaterializedResult fullSample = computeActual("SELECT orderkey FROM orders TABLESAMPLE BERNOULLI (100)");
        MaterializedResult emptySample = computeActual("SELECT orderkey FROM orders TABLESAMPLE BERNOULLI (0)");
        MaterializedResult all = computeExpected("SELECT orderkey FROM orders", fullSample.getTypes());

        assertContains(all, fullSample);
        assertThat(emptySample.getMaterializedRows()).isEmpty();
    }

    @Test
    public void testTableSampleBernoulli()
    {
        DescriptiveStatistics stats = new DescriptiveStatistics();

        int total = computeExpected("SELECT orderkey FROM orders", ImmutableList.of(BIGINT)).getMaterializedRows().size();

        for (int i = 0; i < 100; i++) {
            List<MaterializedRow> values = computeActual("SELECT orderkey FROM orders TABLESAMPLE BERNOULLI (50)").getMaterializedRows();

            assertThat(values.size())
                    .describedAs("TABLESAMPLE produced duplicate rows")
                    .isEqualTo(ImmutableSet.copyOf(values).size());
            stats.addValue(values.size() * 1.0 / total);
        }

        double mean = stats.getGeometricMean();
        assertThat(mean > 0.45 && mean < 0.55)
                .describedAs(format("Expected mean sampling rate to be ~0.5, but was %s", mean))
                .isTrue();
    }

    @Test
    public void testFilterPushdownWithAggregation()
    {
        assertQuery("SELECT * FROM (SELECT count(*) FROM orders) WHERE 0=1");
        assertQuery("SELECT * FROM (SELECT count(*) FROM orders) WHERE null");
    }
}
