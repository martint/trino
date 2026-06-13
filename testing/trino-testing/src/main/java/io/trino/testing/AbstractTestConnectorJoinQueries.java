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
import io.trino.Session;
import io.trino.SystemSessionProperties;
import io.trino.tpch.TpchTable;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.Timeout;

import java.util.List;

import static io.trino.sql.planner.OptimizerConfig.JoinDistributionType;
import static io.trino.tpch.TpchTable.CUSTOMER;
import static io.trino.tpch.TpchTable.LINE_ITEM;
import static io.trino.tpch.TpchTable.NATION;
import static io.trino.tpch.TpchTable.ORDERS;
import static io.trino.tpch.TpchTable.PART;
import static io.trino.tpch.TpchTable.REGION;
import static java.lang.String.format;

/**
 * The representative subset of join query tests worth running against a real connector backend: the
 * join shapes that exercise the connector dimension a TPCH-backed run does not — real splits from a
 * file/metastore split source, dynamic-filter pushdown consumed at that split source, broadcast vs.
 * partitioned remote exchanges, and probe/build short-circuiting over real data. The exhaustive join
 * algebra (coercion/normalization, inequality joins, constant-equality and predicate-inference
 * families, null-handling, VALUES-only shapes) is pure-engine and lives in
 * {@link AbstractTestJoinQueries}, which extends this class and is run by the TPCH-backed engine
 * suites (local, spill, no-dynamic-filtering, fault-tolerant).
 */
public abstract class AbstractTestConnectorJoinQueries
        extends AbstractTestQueryFramework
{
    protected static final List<TpchTable<?>> REQUIRED_TPCH_TABLES = ImmutableList.of(
            CUSTOMER,
            LINE_ITEM,
            NATION,
            ORDERS,
            PART,
            REGION);

    @Test
    public void testSimpleJoin()
    {
        assertQuery("SELECT COUNT(*) FROM lineitem JOIN orders ON lineitem.orderkey = orders.orderkey");
        assertQuery("" +
                "SELECT COUNT(*) FROM " +
                "(SELECT orderkey FROM lineitem WHERE orderkey < 1000) a " +
                "JOIN " +
                "(SELECT orderkey FROM orders WHERE orderkey < 2000) b " +
                "ON NOT (a.orderkey <= b.orderkey)");
    }

    @Test
    public void testSimpleLeftJoin()
    {
        assertQuery("SELECT COUNT(*) FROM lineitem LEFT JOIN orders ON lineitem.orderkey = orders.orderkey");
        assertQuery("SELECT COUNT(*) FROM lineitem LEFT OUTER JOIN orders ON lineitem.orderkey = orders.orderkey");

        // With null base (null row value) in dereference expression
        assertQuery(
                "SELECT x.val FROM " +
                        "(SELECT CAST(ROW(v) AS ROW(val integer)) FROM (VALUES 1, 2, 3) t(v)) ta (x) " +
                        "LEFT OUTER JOIN " +
                        "(SELECT CAST(ROW(v) AS ROW(val integer)) FROM (VALUES 1, 2, 3) t(v)) tb (y) " +
                        "ON x.val=y.val " +
                        "WHERE y.val=1",
                "SELECT 1");
    }

    @Test
    public void testSimpleRightJoin()
    {
        assertQuery("SELECT COUNT(*) FROM lineitem RIGHT JOIN orders ON lineitem.orderkey = orders.orderkey");
        assertQuery("SELECT COUNT(*) FROM lineitem RIGHT OUTER JOIN orders ON lineitem.orderkey = orders.orderkey");

        assertQuery("SELECT COUNT(*) FROM lineitem RIGHT JOIN orders ON lineitem.orderkey = orders.custkey");
        assertQuery("SELECT COUNT(*) FROM lineitem RIGHT OUTER JOIN orders ON lineitem.orderkey = orders.custkey");
    }

    @Test
    public void testSimpleFullJoin()
    {
        assertQuery(
                "SELECT a, b FROM (VALUES (1), (2)) t (a) FULL OUTER JOIN (VALUES (1), (3)) u (b) ON a = b",
                "SELECT * FROM (VALUES (1, 1), (2, NULL), (NULL, 3))");
        assertQuery("SELECT COUNT(*) FROM lineitem FULL JOIN orders ON lineitem.orderkey = orders.orderkey",
                "SELECT COUNT(*) FROM (" +
                        "SELECT lineitem.orderkey, orders.orderkey AS o2 FROM lineitem LEFT OUTER JOIN orders ON lineitem.orderkey = orders.orderkey " +
                        "UNION ALL " +
                        "SELECT lineitem.orderkey, orders.orderkey AS o2 FROM lineitem RIGHT OUTER JOIN orders ON lineitem.orderkey = orders.orderkey " +
                        "WHERE lineitem.orderkey IS NULL" +
                        ")");
        assertQuery("SELECT COUNT(*) FROM lineitem FULL OUTER JOIN orders ON lineitem.orderkey = orders.orderkey",
                "SELECT COUNT(*) FROM (" +
                        "SELECT lineitem.orderkey, orders.orderkey AS o2 FROM lineitem LEFT OUTER JOIN orders ON lineitem.orderkey = orders.orderkey " +
                        "UNION ALL " +
                        "SELECT lineitem.orderkey, orders.orderkey AS o2 FROM lineitem RIGHT OUTER JOIN orders ON lineitem.orderkey = orders.orderkey " +
                        "WHERE lineitem.orderkey IS NULL" +
                        ")");

        // The above outer join queries will produce the same result even if they are inner join.
        // The below query uses "orderkey = custkey" as join condition.
        assertQuery("SELECT COUNT(*) FROM lineitem FULL JOIN orders ON lineitem.orderkey = orders.custkey",
                "SELECT COUNT(*) FROM (" +
                        "SELECT lineitem.orderkey, orders.orderkey AS o2 FROM lineitem LEFT OUTER JOIN orders ON lineitem.orderkey = orders.custkey " +
                        "UNION ALL " +
                        "SELECT lineitem.orderkey, orders.orderkey AS o2 FROM lineitem RIGHT OUTER JOIN orders ON lineitem.orderkey = orders.custkey " +
                        "WHERE lineitem.orderkey IS NULL" +
                        ")");
    }

    @Test
    public void testCrossJoins()
    {
        assertQuery("" +
                "SELECT a.custkey, b.orderkey " +
                "FROM (SELECT * FROM orders ORDER BY orderkey LIMIT 5) a " +
                "CROSS JOIN (SELECT * FROM lineitem ORDER BY orderkey LIMIT 5) b");
    }

    @Test
    public void testSemiJoin()
    {
        assertQuery("SELECT linenumber, min(orderkey) " +
                "FROM lineitem " +
                "GROUP BY linenumber " +
                "HAVING min(orderkey) IN (SELECT orderkey FROM orders WHERE orderkey > 1)");
        //
        // constant literal versus a subquery
        assertQuery("SELECT 10 in (SELECT orderkey FROM orders)");

        // the same IN subquery used twice
        assertQuery(
                "SELECT * FROM (VALUES (1,1), (2,2), (3, 3)) t(x, y) WHERE (x+y in (VALUES 4, 5)) AND (x*y in (VALUES 4, 5))",
                "VALUES (2,2)");

        // test multiple IN subqueries with coercions
        assertQuery("SELECT 1.0 IN (SELECT 1), 1 IN (SELECT 1)");
        assertQuery("SELECT 1 WHERE 1 IN (SELECT 1) AND 1.0 IN (SELECT 1)");
        assertQuery("SELECT 1.0 in (values (1), (2), (3))", "SELECT true");

        // test IN subqueries with supertype coercions
        assertQuery("SELECT CAST(1 AS decimal(3,2)) IN (SELECT CAST(1 AS decimal(3,1)))", "SELECT true");
        assertQuery("SELECT CAST(1 AS decimal(3,2)) IN (values (cast(1 AS decimal(3,1))), (cast (2 AS decimal(3,1))))", "SELECT true");

        // test multi level IN subqueries
        assertQuery("SELECT 1 IN (SELECT 1), 2 IN (SELECT 1) WHERE 1 IN (SELECT 1)");

        // test with subqueries on left
        assertQuery("SELECT (SELECT 1) IN (SELECT 1)");
        assertQuery("SELECT (SELECT 2) IN (1, (SELECT 2))");
        assertQuery("SELECT (2 + (SELECT 1)) IN (SELECT 1)");
        assertQuery("SELECT (1 IN (SELECT 1)) IN (SELECT TRUE)");
        assertQuery("SELECT ((SELECT 1) IN (SELECT 1)) IN (SELECT TRUE)");
        assertQuery("SELECT (EXISTS(SELECT 1)) IN (SELECT TRUE)");
        assertQuery("SELECT (1 = ANY(SELECT 1)) IN (SELECT TRUE)");

        // Throw in a bunch of IN subquery predicates
        assertQuery("" +
                "SELECT *, o2.custkey\n" +
                "  IN (\n" +
                "    SELECT orderkey\n" +
                "    FROM lineitem\n" +
                "    WHERE orderkey % 5 = 0)\n" +
                "FROM (SELECT * FROM orders WHERE custkey % 256 = 0) o1\n" +
                "JOIN (SELECT * FROM orders WHERE custkey % 256 = 0) o2\n" +
                "  ON (o1.orderkey IN (SELECT orderkey FROM lineitem WHERE orderkey % 4 = 0)) = (o2.orderkey IN (SELECT orderkey FROM lineitem WHERE orderkey % 4 = 0))\n" +
                "WHERE o1.orderkey\n" +
                "  IN (\n" +
                "    SELECT orderkey\n" +
                "    FROM lineitem\n" +
                "    WHERE orderkey % 4 = 0)\n" +
                "ORDER BY o1.orderkey\n" +
                "  IN (\n" +
                "    SELECT orderkey\n" +
                "    FROM lineitem\n" +
                "    WHERE orderkey % 7 = 0)");
        assertQuery("" +
                "SELECT orderkey\n" +
                "  IN (\n" +
                "    SELECT orderkey\n" +
                "    FROM lineitem\n" +
                "    WHERE partkey % 4 = 0),\n" +
                "  SUM(\n" +
                "    CASE\n" +
                "      WHEN orderkey\n" +
                "        IN (\n" +
                "          SELECT orderkey\n" +
                "          FROM lineitem\n" +
                "          WHERE suppkey % 4 = 0)\n" +
                "      THEN 1\n" +
                "      ELSE 0\n" +
                "      END)\n" +
                "FROM orders\n" +
                "GROUP BY orderkey\n" +
                "  IN (\n" +
                "    SELECT orderkey\n" +
                "    FROM lineitem\n" +
                "    WHERE partkey % 4 = 0)\n" +
                "HAVING SUM(\n" +
                "  CASE\n" +
                "    WHEN orderkey\n" +
                "      IN (\n" +
                "        SELECT orderkey\n" +
                "        FROM lineitem\n" +
                "        WHERE suppkey % 4 = 0)\n" +
                "      THEN 1\n" +
                "      ELSE 0\n" +
                "      END) > 1");
    }

    @Test
    public void testAntiJoin()
    {
        assertQuery("" +
                "SELECT *, orderkey\n" +
                "  NOT IN (\n" +
                "    SELECT orderkey\n" +
                "    FROM lineitem\n" +
                "    WHERE orderkey % 3 = 0)\n" +
                "FROM orders");
    }

    @Test
    public void testJoinPredicatePushdown()
    {
        assertQuery("" +
                "SELECT COUNT(*)\n" +
                "FROM lineitem \n" +
                "JOIN (\n" +
                "  SELECT * FROM orders\n" +
                ") orders \n" +
                "ON lineitem.orderkey = orders.orderkey \n" +
                "WHERE orders.orderkey % 4 = 0\n" +
                "  AND lineitem.suppkey > orders.orderkey");
    }

    @Test
    public void testEquijoinOnDifferentTypesWithFilter()
    {
        // Exercises a join on integer vs bigint with a filter on the integer column that can be pushed down
        // below the join. Needs to run in distributed mode to reproduce the issue (i.e., with AddExchanges enabled)
        assertQuery("" +
                "WITH" +
                "   t1 AS (SELECT linenumber AS id1 FROM lineitem), " +
                "   t2 AS (SELECT nationkey AS id2 FROM nation) " +
                "SELECT id1 " +
                "FROM t1 " +
                "JOIN t2 ON id1 = id2 " +
                "WHERE id1 = 10");

        assertQuery("" +
                "WITH " +
                "   t1 AS (SELECT linenumber AS id1 FROM lineitem), " +
                "   t2 AS (SELECT nationkey AS id2 FROM nation), " +
                "   t3 AS (SELECT linenumber AS id3 FROM lineitem), " +
                "   t4 AS (SELECT nationkey AS id4 FROM nation) " +
                "SELECT id3 " +
                "FROM (SELECT * FROM t1 JOIN t2 ON id1 = id2) u " +
                "JOIN (SELECT * FROM t3 JOIN t4 ON id3 = id4) v " +
                "ON id1 = id4 " +
                "WHERE id3 = 10");
    }

    @Test
    public void testLeftJoinWithEmptyBuildSide()
    {
        assertQuery(
                noJoinReordering(),
                "WITH small_part AS (SELECT * FROM part WHERE name = 'a') SELECT lineitem.orderkey FROM lineitem LEFT JOIN small_part ON lineitem.partkey = small_part.partkey");
    }

    @Test
    @Timeout(120)
    public void testInnerJoinWithEmptyProbeSide()
    {
        // TODO: increase lineitem schema size when probe side short-circuit is fixed
        assertQuery(
                noJoinReordering(),
                "WITH empty_table AS (SELECT partkey as value FROM part WHERE name = 'a'), " +
                        "slow_table AS (SELECT count(*) as value FROM tpch.\"sf0.1\".lineitem) " +
                        "SELECT slow_table.value FROM empty_table INNER JOIN slow_table ON slow_table.value = empty_table.value",
                "SELECT 0 WHERE false");
    }

    @Test
    public void testMultiJoinWithEligibleForDynamicFiltering()
    {
        assertQuery(
                "" +
                        "SELECT customer.name, lineitem.partkey " +
                        "FROM lineitem " +
                        "LEFT JOIN orders ON lineitem.orderkey = orders.orderkey " + // with dynamic filters enabled, gets converted to INNER CROSS JOIN
                        "LEFT JOIN customer ON orders.custkey = customer.custkey " + // gets converted to INNER join
                        "WHERE lineitem.orderkey = 31718 " +
                        "AND customer.name >= 'Customer#000001463' ",
                "VALUES ('Customer#000001471', 474), ('Customer#000001471', 1969), ('Customer#000001471', 32)");

        assertQuery(
                "" +
                        "SELECT count(*) " +
                        "FROM lineitem " +
                        "LEFT JOIN orders ON lineitem.orderkey = orders.orderkey " + // with dynamic filters enabled, gets converted to INNER CROSS JOIN
                        "LEFT JOIN customer ON orders.custkey = customer.custkey " + // gets converted to INNER join
                        "WHERE lineitem.orderkey = 31718 " +
                        "AND customer.name >= 'Customer#000001463' ",
                "VALUES 3");
    }

    @Test
    public void testJoinWithStatefulFilterFunction()
    {
        assertQuery(
                "SELECT *\n" +
                        "FROM (VALUES 1, 2) a(id)\n" +
                        "FULL JOIN (VALUES 2, 3) b(id)\n" +
                        "ON (array_intersect(array[a.id], array[b.id]) = array[a.id])",
                "VALUES (1, null), (2, 2), (null, 3)");

        // Stateful function is placed in LEFT JOIN's ON clause and involves left & right symbols to prevent any kind of push down/pull down.
        Session session = Session.builder(getSession())
                // With broadcast join, lineitem would be source-distributed and not executed concurrently.
                .setSystemProperty(SystemSessionProperties.JOIN_DISTRIBUTION_TYPE, JoinDistributionType.PARTITIONED.toString())
                .build();
        long joinOutputRowCount = 60175;
        assertQuery(
                session,
                format(
                        "SELECT count(*) FROM lineitem l LEFT OUTER JOIN orders o ON l.orderkey = o.orderkey AND stateful_sleeping_sum(%s, 100, l.linenumber, o.shippriority) > 0",
                        10 * 1. / joinOutputRowCount),
                format("VALUES %s", joinOutputRowCount));
    }
}
