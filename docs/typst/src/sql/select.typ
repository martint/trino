#import "/lib/trino-docs.typ": *

#anchor("doc-sql-select")
= SELECT

== Synopsis

#code-block("text", "[ WITH SESSION [ name = expression [, ...] ]
[ WITH [ FUNCTION udf ] [, ...] ]
[ WITH [ RECURSIVE ] with_query [, ...] ]
SELECT [ ALL | DISTINCT ] select_expression [, ...]
[ FROM from_item [, ...] ]
[ WHERE condition ]
[ GROUP BY [ ALL | DISTINCT ] grouping_element [, ...] ]
[ HAVING condition]
[ WINDOW window_definition_list]
[ { UNION | INTERSECT | EXCEPT } [ ALL | DISTINCT ] select ]
[ ORDER BY expression [ ASC | DESC ] [, ...] ]
[ OFFSET count [ ROW | ROWS ] ]
[ LIMIT { count | ALL } ]
[ FETCH { FIRST | NEXT } [ count ] { ROW | ROWS } { ONLY | WITH TIES } ]")

where #raw("from_item") is one of

#code-block("text", "table_name [ [ AS ] alias [ ( column_alias [, ...] ) ] ]")

#code-block("text", "from_item join_type from_item
  [ ON join_condition | USING ( join_column [, ...] ) ]")

#code-block("text", "table_name [ [ AS ] alias [ ( column_alias [, ...] ) ] ]
  MATCH_RECOGNIZE pattern_recognition_specification
    [ [ AS ] alias [ ( column_alias [, ...] ) ] ]")

For detailed description of #raw("MATCH_RECOGNIZE") clause, see #link(label("doc-sql-match-recognize"))[pattern recognition in FROM clause].

#code-block("text", "TABLE (table_function_invocation) [ [ AS ] alias [ ( column_alias [, ...] ) ] ]")

For description of table functions usage, see #link(label("doc-functions-table"))[table functions].

and #raw("join_type") is one of

#code-block("text", "[ INNER ] JOIN
LEFT [ OUTER ] JOIN
RIGHT [ OUTER ] JOIN
FULL [ OUTER ] JOIN
CROSS JOIN")

and #raw("grouping_element") is one of

#code-block("text", "()
expression
AUTO
GROUPING SETS ( ( column [, ...] ) [, ...] )
CUBE ( column [, ...] )
ROLLUP ( column [, ...] )")

== Description

Retrieve rows from zero or more tables.

#anchor("ref-select-with-session")

== WITH SESSION clause

The #raw("WITH SESSION") clause allows you to #link(label("doc-sql-set-session"))[set session and catalog session property values] applicable for the processing of the current SELECT statement only. The defined values override any other configuration and session property settings. Multiple properties are separated by commas.

The following example overrides the global configuration property #raw("query.max-execution-time") with the session property #raw("query_max_execution_time") to reduce the time to #raw("2h"). It also overrides the catalog property #raw("iceberg.query-partition-filter-required") from the #raw("example") catalog using #link(label("doc-connector-iceberg"))[Iceberg connector] setting the catalog session property #raw("query_partition_filter_required") to #raw("true"):

#code-block("sql", "WITH
  SESSION
    query_max_execution_time='2h',
    example.query_partition_filter_required=true
SELECT *
FROM example.default.thetable
LIMIT 100;")

== WITH FUNCTION clause

The #raw("WITH FUNCTION") clause allows you to define a list of #link(label("ref-udf-inline"))[Introduction to UDFs] that are available for use in the rest of the query.

The following example declares and uses two inline UDFs:

#code-block("sql", "WITH 
  FUNCTION hello(name varchar)
    RETURNS varchar
    RETURN format('Hello %s!', name),
  FUNCTION bye(name varchar)
    RETURNS varchar
    RETURN format('Bye %s!', name)
SELECT hello('Finn') || ' and ' || bye('Joe');
-- Hello Finn! and Bye Joe!")

Find further information about UDFs in general, inline UDFs, all supported statements, and examples in #link(label("doc-udf"))[User-defined functions].

== WITH clause

The #raw("WITH") clause defines named relations for use within a query. It allows flattening nested queries or simplifying subqueries. For example, the following queries are equivalent:

#code-block(none, "SELECT a, b
FROM (
  SELECT a, MAX(b) AS b FROM t GROUP BY a
) AS x;

WITH x AS (SELECT a, MAX(b) AS b FROM t GROUP BY a)
SELECT a, b FROM x;")

This also works with multiple subqueries:

#code-block(none, "WITH
  t1 AS (SELECT a, MAX(b) AS b FROM x GROUP BY a),
  t2 AS (SELECT a, AVG(d) AS d FROM y GROUP BY a)
SELECT t1.*, t2.*
FROM t1
JOIN t2 ON t1.a = t2.a;")

Additionally, the relations within a #raw("WITH") clause can chain:

#code-block(none, "WITH
  x AS (SELECT a FROM t),
  y AS (SELECT a AS b FROM x),
  z AS (SELECT b AS c FROM y)
SELECT c FROM z;")

#warning[
Currently, the SQL for the #raw("WITH") clause will be inlined anywhere the named relation is used. This means that if the relation is used more than once and the query is non-deterministic, the results may be different each time.
]

== WITH RECURSIVE clause

The #raw("WITH RECURSIVE") clause is a variant of the #raw("WITH") clause. It defines a list of queries to process, including recursive processing of suitable queries.

#warning[
This feature is experimental only. Proceed to use it only if you understand potential query failures and the impact of the recursion processing on your workload.
]

A recursive #raw("WITH")-query must be shaped as a #raw("UNION") of two relations. The first relation is called the #emph[recursion base], and the second relation is called the #emph[recursion step]. Trino supports recursive #raw("WITH")-queries with a single recursive reference to a #raw("WITH")-query from within the query. The name #raw("T") of the query #raw("T") can be mentioned once in the #raw("FROM") clause of the recursion step relation.

The following listing shows a simple example, that displays a commonly used form of a single query in the list:

#code-block("text", "WITH RECURSIVE t(n) AS (
    VALUES (1)
    UNION ALL
    SELECT n + 1 FROM t WHERE n < 4
)
SELECT sum(n) FROM t;")

In the preceding query the simple assignment #raw("VALUES (1)") defines the recursion base relation. #raw("SELECT n + 1 FROM t WHERE n < 4") defines the recursion step relation. The recursion processing performs these steps:

- recursive base yields #raw("1")
- first recursion yields #raw("1 + 1 = 2")
- second recursion uses the result from the first and adds one: #raw("2 + 1 = 3")
- third recursion uses the result from the second and adds one again: #raw("3 + 1 = 4")
- fourth recursion aborts since #raw("n = 4")
- this results in #raw("t") having values #raw("1"), #raw("2"), #raw("3") and #raw("4")
- the final statement performs the sum operation of these elements with the final result value #raw("10")

The types of the returned columns are those of the base relation. Therefore it is required that types in the step relation can be coerced to base relation types.

The #raw("RECURSIVE") clause applies to all queries in the #raw("WITH") list, but not all of them must be recursive. If a #raw("WITH")-query is not shaped according to the rules mentioned above or it does not contain a recursive reference, it is processed like a regular #raw("WITH")-query. Column aliases are mandatory for all the queries in the recursive #raw("WITH") list.

The following limitations apply as a result of following the SQL standard and due to implementation choices, in addition to #raw("WITH") clause limitations:

- only single-element recursive cycles are supported. Like in regular #raw("WITH")-queries, references to previous queries in the #raw("WITH") list are allowed. References to following queries are forbidden.
- usage of outer joins, set operations, limit clause, and others is not always allowed in the step relation
- recursion depth is fixed, defaults to #raw("10"), and doesn't depend on the actual query results

You can adjust the recursion depth with the #link(label("doc-sql-set-session"))[session property] #raw("max_recursion_depth"). When changing the value consider that the size of the query plan growth is quadratic with the recursion depth.

== SELECT clause

The #raw("SELECT") clause specifies the output of the query. Each #raw("select_expression") defines a column or columns to be included in the result.

#code-block("text", "SELECT [ ALL | DISTINCT ] select_expression [, ...]")

The #raw("ALL") and #raw("DISTINCT") quantifiers determine whether duplicate rows are included in the result set. If the argument #raw("ALL") is specified, all rows are included. If the argument #raw("DISTINCT") is specified, only unique rows are included in the result set. In this case, each output column must be of a type that allows comparison. If neither argument is specified, the behavior defaults to #raw("ALL").

=== Select expressions

Each #raw("select_expression") must be in one of the following forms:

#code-block("text", "expression [ [ AS ] column_alias ]")

#code-block("text", "row_expression.* [ AS ( column_alias [, ...] ) ]")

#code-block("text", "relation.*")

#code-block("text", "*")

In the case of #raw("expression [ [ AS ] column_alias ]"), a single output column is defined.

In the case of #raw("row_expression.* [ AS ( column_alias [, ...] ) ]"), the #raw("row_expression") is an arbitrary expression of type #raw("ROW"). All fields of the row define output columns to be included in the result set.

In the case of #raw("relation.*"), all columns of #raw("relation") are included in the result set. In this case column aliases are not allowed.

In the case of #raw("*"), all columns of the relation defined by the query are included in the result set.

In the result set, the order of columns is the same as the order of their specification by the select expressions. If a select expression returns multiple columns, they are ordered the same way they were ordered in the source relation or row type expression.

If column aliases are specified, they override any preexisting column or row field names:

#code-block(none, "SELECT (CAST(ROW(1, true) AS ROW(field1 bigint, field2 boolean))).* AS (alias1, alias2);")

#code-block("text", " alias1 | alias2
--------+--------
      1 | true
(1 row)")

Otherwise, the existing names are used:

#code-block(none, "SELECT (CAST(ROW(1, true) AS ROW(field1 bigint, field2 boolean))).*;")

#code-block("text", " field1 | field2
--------+--------
      1 | true
(1 row)")

and in their absence, anonymous columns are produced:

#code-block(none, "SELECT (ROW(1, true)).*;")

#code-block("text", " _col0 | _col1
-------+-------
     1 | true
(1 row)")

== GROUP BY clause

The #raw("GROUP BY") clause divides the output of a #raw("SELECT") statement into groups of rows containing matching values. A simple #raw("GROUP BY") clause may contain any expression composed of input columns or it may be an ordinal number selecting an output column by position \(starting at one\).

The following queries are equivalent. They both group the output by the #raw("nationkey") input column with the first query using the ordinal position of the output column and the second query using the input column name:

#code-block(none, "SELECT count(*), nationkey FROM customer GROUP BY 2;

SELECT count(*), nationkey FROM customer GROUP BY nationkey;")

#raw("GROUP BY") clauses can group output by input column names not appearing in the output of a select statement. For example, the following query generates row counts for the #raw("customer") table using the input column #raw("mktsegment"):

#code-block(none, "SELECT count(*) FROM customer GROUP BY mktsegment;")

#code-block("text", " _col0
-------
 29968
 30142
 30189
 29949
 29752
(5 rows)")

When a #raw("GROUP BY") clause is used in a #raw("SELECT") statement all output expressions must be either aggregate functions or columns present in the #raw("GROUP BY") clause.

#anchor("ref-complex-grouping-operations")

=== Complex grouping operations

Trino also supports complex aggregations using the #raw("GROUPING SETS"), #raw("CUBE") and #raw("ROLLUP") syntax. This syntax allows users to perform analysis that requires aggregation on multiple sets of columns in a single query. Complex grouping operations do not support grouping on expressions composed of input columns. Only column names are allowed.

Complex grouping operations are often equivalent to a #raw("UNION ALL") of simple #raw("GROUP BY") expressions, as shown in the following examples. This equivalence does not apply, however, when the source of data for the aggregation is non-deterministic.

=== AUTO

When #raw("AUTO") is specified, the Trino engine automatically determines the grouping columns instead of requiring them to be listed explicitly. In this mode, any column in the #raw("SELECT") list that is not part of an aggregate function is implicitly treated as a grouping column.

This example query calculates the total account balance per market segment. The #raw("AUTO") clause derives #raw("mktsegment") as the grouping key, since it is not used in any aggregate function \(i.e., #raw("sum")\).

#code-block("sql", "SELECT mktsegment, sum(acctbal) FROM shipping GROUP BY AUTO;")

#code-block("text", " mktsegment |       _col1
------------+--------------------
 BUILDING   |          1444587.8
 MACHINERY  |         1296958.61
 HOUSEHOLD  |         1279340.66
 FURNITURE  |          1265282.8
 AUTOMOBILE | 1395695.7200000004
(5 rows)")

=== GROUPING SETS

Grouping sets allow users to specify multiple lists of columns to group on. The columns not part of a given sublist of grouping columns are set to #raw("NULL").

#code-block(none, "SELECT * FROM shipping;")

#code-block("text", " origin_state | origin_zip | destination_state | destination_zip | package_weight
--------------+------------+-------------------+-----------------+----------------
 California   |      94131 | New Jersey        |            8648 |             13
 California   |      94131 | New Jersey        |            8540 |             42
 New Jersey   |       7081 | Connecticut       |            6708 |            225
 California   |      90210 | Connecticut       |            6927 |           1337
 California   |      94131 | Colorado          |           80302 |              5
 New York     |      10002 | New Jersey        |            8540 |              3
(6 rows)")

#raw("GROUPING SETS") semantics are demonstrated by this example query:

#code-block(none, "SELECT origin_state, origin_zip, destination_state, sum(package_weight)
FROM shipping
GROUP BY GROUPING SETS (
    (origin_state),
    (origin_state, origin_zip),
    (destination_state));")

#code-block("text", " origin_state | origin_zip | destination_state | _col0
--------------+------------+-------------------+-------
 New Jersey   | NULL       | NULL              |   225
 California   | NULL       | NULL              |  1397
 New York     | NULL       | NULL              |     3
 California   |      90210 | NULL              |  1337
 California   |      94131 | NULL              |    60
 New Jersey   |       7081 | NULL              |   225
 New York     |      10002 | NULL              |     3
 NULL         | NULL       | Colorado          |     5
 NULL         | NULL       | New Jersey        |    58
 NULL         | NULL       | Connecticut       |  1562
(10 rows)")

The preceding query may be considered logically equivalent to a #raw("UNION ALL") of multiple #raw("GROUP BY") queries:

#code-block(none, "SELECT origin_state, NULL, NULL, sum(package_weight)
FROM shipping GROUP BY origin_state

UNION ALL

SELECT origin_state, origin_zip, NULL, sum(package_weight)
FROM shipping GROUP BY origin_state, origin_zip

UNION ALL

SELECT NULL, NULL, destination_state, sum(package_weight)
FROM shipping GROUP BY destination_state;")

However, the query with the complex grouping syntax \(#raw("GROUPING SETS"), #raw("CUBE") or #raw("ROLLUP")\) will only read from the underlying data source once, while the query with the #raw("UNION ALL") reads the underlying data three times. This is why queries with a #raw("UNION ALL") may produce inconsistent results when the data source is not deterministic.

=== CUBE

The #raw("CUBE") operator generates all possible grouping sets \(i.e. a power set\) for a given set of columns. For example, the query:

#code-block(none, "SELECT origin_state, destination_state, sum(package_weight)
FROM shipping
GROUP BY CUBE (origin_state, destination_state);")

is equivalent to:

#code-block(none, "SELECT origin_state, destination_state, sum(package_weight)
FROM shipping
GROUP BY GROUPING SETS (
    (origin_state, destination_state),
    (origin_state),
    (destination_state),
    ()
);")

#code-block("text", " origin_state | destination_state | _col0
--------------+-------------------+-------
 California   | New Jersey        |    55
 California   | Colorado          |     5
 New York     | New Jersey        |     3
 New Jersey   | Connecticut       |   225
 California   | Connecticut       |  1337
 California   | NULL              |  1397
 New York     | NULL              |     3
 New Jersey   | NULL              |   225
 NULL         | New Jersey        |    58
 NULL         | Connecticut       |  1562
 NULL         | Colorado          |     5
 NULL         | NULL              |  1625
(12 rows)")

=== ROLLUP

The #raw("ROLLUP") operator generates all possible subtotals for a given set of columns. For example, the query:

#code-block(none, "SELECT origin_state, origin_zip, sum(package_weight)
FROM shipping
GROUP BY ROLLUP (origin_state, origin_zip);")

#code-block("text", " origin_state | origin_zip | _col2
--------------+------------+-------
 California   |      94131 |    60
 California   |      90210 |  1337
 New Jersey   |       7081 |   225
 New York     |      10002 |     3
 California   | NULL       |  1397
 New York     | NULL       |     3
 New Jersey   | NULL       |   225
 NULL         | NULL       |  1625
(8 rows)")

is equivalent to:

#code-block(none, "SELECT origin_state, origin_zip, sum(package_weight)
FROM shipping
GROUP BY GROUPING SETS ((origin_state, origin_zip), (origin_state), ());")

=== Combining multiple grouping expressions

Multiple grouping expressions in the same query are interpreted as having cross-product semantics. For example, the following query:

#code-block(none, "SELECT origin_state, destination_state, origin_zip, sum(package_weight)
FROM shipping
GROUP BY
    GROUPING SETS ((origin_state, destination_state)),
    ROLLUP (origin_zip);")

which can be rewritten as:

#code-block(none, "SELECT origin_state, destination_state, origin_zip, sum(package_weight)
FROM shipping
GROUP BY
    GROUPING SETS ((origin_state, destination_state)),
    GROUPING SETS ((origin_zip), ());")

is logically equivalent to:

#code-block(none, "SELECT origin_state, destination_state, origin_zip, sum(package_weight)
FROM shipping
GROUP BY GROUPING SETS (
    (origin_state, destination_state, origin_zip),
    (origin_state, destination_state)
);")

#code-block("text", " origin_state | destination_state | origin_zip | _col3
--------------+-------------------+------------+-------
 New York     | New Jersey        |      10002 |     3
 California   | New Jersey        |      94131 |    55
 New Jersey   | Connecticut       |       7081 |   225
 California   | Connecticut       |      90210 |  1337
 California   | Colorado          |      94131 |     5
 New York     | New Jersey        | NULL       |     3
 New Jersey   | Connecticut       | NULL       |   225
 California   | Colorado          | NULL       |     5
 California   | Connecticut       | NULL       |  1337
 California   | New Jersey        | NULL       |    55
(10 rows)")

The #raw("ALL") and #raw("DISTINCT") quantifiers determine whether duplicate grouping sets each produce distinct output rows. This is particularly useful when multiple complex grouping sets are combined in the same query. For example, the following query:

#code-block(none, "SELECT origin_state, destination_state, origin_zip, sum(package_weight)
FROM shipping
GROUP BY ALL
    CUBE (origin_state, destination_state),
    ROLLUP (origin_state, origin_zip);")

is equivalent to:

#code-block(none, "SELECT origin_state, destination_state, origin_zip, sum(package_weight)
FROM shipping
GROUP BY GROUPING SETS (
    (origin_state, destination_state, origin_zip),
    (origin_state, origin_zip),
    (origin_state, destination_state, origin_zip),
    (origin_state, origin_zip),
    (origin_state, destination_state),
    (origin_state),
    (origin_state, destination_state),
    (origin_state),
    (origin_state, destination_state),
    (origin_state),
    (destination_state),
    ()
);")

However, if the query uses the #raw("DISTINCT") quantifier for the #raw("GROUP BY"):

#code-block(none, "SELECT origin_state, destination_state, origin_zip, sum(package_weight)
FROM shipping
GROUP BY DISTINCT
    CUBE (origin_state, destination_state),
    ROLLUP (origin_state, origin_zip);")

only unique grouping sets are generated:

#code-block(none, "SELECT origin_state, destination_state, origin_zip, sum(package_weight)
FROM shipping
GROUP BY GROUPING SETS (
    (origin_state, destination_state, origin_zip),
    (origin_state, origin_zip),
    (origin_state, destination_state),
    (origin_state),
    (destination_state),
    ()
);")

The default set quantifier is #raw("ALL").

=== GROUPING operation

#raw("grouping(col1, ..., colN) -> bigint")

The grouping operation returns a bit set converted to decimal, indicating which columns are present in a grouping. It must be used in conjunction with #raw("GROUPING SETS"), #raw("ROLLUP"), #raw("CUBE")  or #raw("GROUP BY") and its arguments must match exactly the columns referenced in the corresponding #raw("GROUPING SETS"), #raw("ROLLUP"), #raw("CUBE") or #raw("GROUP BY") clause.

To compute the resulting bit set for a particular row, bits are assigned to the argument columns with the rightmost column being the least significant bit. For a given grouping, a bit is set to 0 if the corresponding column is included in the grouping and to 1 otherwise. For example, consider the query below:

#code-block(none, "SELECT origin_state, origin_zip, destination_state, sum(package_weight),
       grouping(origin_state, origin_zip, destination_state)
FROM shipping
GROUP BY GROUPING SETS (
    (origin_state),
    (origin_state, origin_zip),
    (destination_state)
);")

#code-block("text", "origin_state | origin_zip | destination_state | _col3 | _col4
--------------+------------+-------------------+-------+-------
California   | NULL       | NULL              |  1397 |     3
New Jersey   | NULL       | NULL              |   225 |     3
New York     | NULL       | NULL              |     3 |     3
California   |      94131 | NULL              |    60 |     1
New Jersey   |       7081 | NULL              |   225 |     1
California   |      90210 | NULL              |  1337 |     1
New York     |      10002 | NULL              |     3 |     1
NULL         | NULL       | New Jersey        |    58 |     6
NULL         | NULL       | Connecticut       |  1562 |     6
NULL         | NULL       | Colorado          |     5 |     6
(10 rows)")

The first grouping in the above result only includes the #raw("origin_state") column and excludes the #raw("origin_zip") and #raw("destination_state") columns. The bit set constructed for that grouping is #raw("011") where the most significant bit represents #raw("origin_state").

== HAVING clause

The #raw("HAVING") clause is used in conjunction with aggregate functions and the #raw("GROUP BY") clause to control which groups are selected. A #raw("HAVING") clause eliminates groups that do not satisfy the given conditions. #raw("HAVING") filters groups after groups and aggregates are computed.

The following example queries the #raw("customer") table and selects groups with an account balance greater than the specified value:

#code-block(none, "SELECT count(*), mktsegment, nationkey,
       CAST(sum(acctbal) AS bigint) AS totalbal
FROM customer
GROUP BY mktsegment, nationkey
HAVING sum(acctbal) > 5700000
ORDER BY totalbal DESC;")

#code-block("text", " _col0 | mktsegment | nationkey | totalbal
-------+------------+-----------+----------
  1272 | AUTOMOBILE |        19 |  5856939
  1253 | FURNITURE  |        14 |  5794887
  1248 | FURNITURE  |         9 |  5784628
  1243 | FURNITURE  |        12 |  5757371
  1231 | HOUSEHOLD  |         3 |  5753216
  1251 | MACHINERY  |         2 |  5719140
  1247 | FURNITURE  |         8 |  5701952
(7 rows)")

#anchor("ref-window-clause")

== WINDOW clause

The #raw("WINDOW") clause is used to define named window specifications. The defined named window specifications can be referred to in the #raw("SELECT") and #raw("ORDER BY") clauses of the enclosing query:

#code-block(none, "SELECT orderkey, clerk, totalprice,
      rank() OVER w AS rnk
FROM orders
WINDOW w AS (PARTITION BY clerk ORDER BY totalprice DESC)
ORDER BY count() OVER w, clerk, rnk")

The window definition list of #raw("WINDOW") clause can contain one or multiple named window specifications of the form

#code-block("none", "window_name AS (window_specification)")

A window specification has the following components:

- The existing window name, which refers to a named window specification in the #raw("WINDOW") clause. The window specification associated with the referenced name is the basis of the current specification.
- The partition specification, which separates the input rows into different partitions. This is analogous to how the #raw("GROUP BY") clause separates rows into different groups for aggregate functions.
- The ordering specification, which determines the order in which input rows will be processed by the window function.
- The window frame, which specifies a sliding window of rows to be processed by the function for a given row. If the frame is not specified, it defaults to #raw("RANGE UNBOUNDED PRECEDING"), which is the same as #raw("RANGE BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW"). This frame contains all rows from the start of the partition up to the last peer of the current row. In the absence of #raw("ORDER BY"), all rows are considered peers, so #raw("RANGE BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW") is equivalent to #raw("BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING"). The window frame syntax supports additional clauses for row pattern recognition. If the row pattern recognition clauses are specified, the window frame for a particular row consists of the rows matched by a pattern starting from that row. Additionally, if the frame specifies row pattern measures, they can be called over the window, similarly to window functions. For more details, see #link(label("doc-sql-pattern-recognition-in-window"))[Row pattern recognition in window structures] .

Each window component is optional. If a window specification does not specify window partitioning, ordering or frame, those components are obtained from the window specification referenced by the #raw("existing window name"), or from another window specification in the reference chain. In case when there is no #raw("existing window name") specified, or none of the referenced window specifications contains the component, the default value is used.

== Set operations

#raw("UNION")  #raw("INTERSECT") and #raw("EXCEPT") are all set operations.  These clauses are used to combine the results of more than one select statement into a single result set:

#code-block("text", "query UNION [ALL | DISTINCT] [CORRESPONDING] query")

#code-block("text", "query INTERSECT [ALL | DISTINCT] [CORRESPONDING] query")

#code-block("text", "query EXCEPT [ALL | DISTINCT] [CORRESPONDING] query")

The argument #raw("ALL") or #raw("DISTINCT") controls which rows are included in the final result set. If the argument #raw("ALL") is specified all rows are included even if the rows are identical.  If the argument #raw("DISTINCT") is specified only unique rows are included in the combined result set. If neither is specified, the behavior defaults to #raw("DISTINCT").

Multiple set operations are processed left to right, unless the order is explicitly specified via parentheses. Additionally, #raw("INTERSECT") binds more tightly than #raw("EXCEPT") and #raw("UNION"). That means #raw("A UNION B INTERSECT C EXCEPT D") is the same as #raw("A UNION (B INTERSECT C) EXCEPT D").

=== UNION clause

#raw("UNION") combines all the rows that are in the result set from the first query with those that are in the result set for the second query. The following is an example of one of the simplest possible #raw("UNION") clauses. It selects the value #raw("13") and combines this result set with a second query that selects the value #raw("42"):

#code-block(none, "SELECT 13
UNION
SELECT 42;")

#code-block("text", " _col0
-------
    13
    42
(2 rows)")

The following query demonstrates the difference between #raw("UNION") and #raw("UNION ALL"). It selects the value #raw("13") and combines this result set with a second query that selects the values #raw("42") and #raw("13"):

#code-block(none, "SELECT 13
UNION
SELECT * FROM (VALUES 42, 13);")

#code-block("text", " _col0
-------
    13
    42
(2 rows)")

#code-block(none, "SELECT 13
UNION ALL
SELECT * FROM (VALUES 42, 13);")

#code-block("text", " _col0
-------
    13
    42
    13
(2 rows)")

#raw("CORRESPONDING") matches columns by name instead of by position:

#code-block("sql", "SELECT * FROM (VALUES (1, 'alice')) AS t(id, name)
UNION ALL CORRESPONDING
SELECT * FROM (VALUES ('bob', 2)) AS t(name, id);")

#code-block("text", " id | name
----+-------
  1 | alice
  2 | bob
(2 rows)")

#code-block("sql", "SELECT * FROM (VALUES (DATE '2025-04-23', 'alice')) AS t(order_date, name)
UNION ALL CORRESPONDING
SELECT * FROM (VALUES ('bob', 123.45)) AS t(name, price);")

#code-block("text", " name
-------
 alice
 bob
(2 rows)")

=== INTERSECT clause

#raw("INTERSECT") returns only the rows that are in the result sets of both the first and the second queries. The following is an example of one of the simplest possible #raw("INTERSECT") clauses. It selects the values #raw("13") and #raw("42") and combines this result set with a second query that selects the value #raw("13").  Since #raw("42") is only in the result set of the first query, it is not included in the final results.:

#code-block(none, "SELECT * FROM (VALUES 13, 42)
INTERSECT
SELECT 13;")

#code-block("text", " _col0
-------
    13
(2 rows)")

#raw("CORRESPONDING") matches columns by name instead of by position:

#code-block("sql", "SELECT * FROM (VALUES (1, 'alice')) AS t(id, name)
INTERSECT CORRESPONDING
SELECT * FROM (VALUES ('alice', 1)) AS t(name, id);")

#code-block("text", " id | name
----+-------
  1 | alice
(1 row)")

=== EXCEPT clause

#raw("EXCEPT") returns the rows that are in the result set of the first query, but not the second. The following is an example of one of the simplest possible #raw("EXCEPT") clauses. It selects the values #raw("13") and #raw("42") and combines this result set with a second query that selects the value #raw("13").  Since #raw("13") is also in the result set of the second query, it is not included in the final result.:

#code-block(none, "SELECT * FROM (VALUES 13, 42)
EXCEPT
SELECT 13;")

#code-block("text", " _col0
-------
   42
(2 rows)")

#raw("CORRESPONDING") matches columns by name instead of by position:

#code-block("sql", "SELECT * FROM (VALUES (1, 'alice'), (2, 'bob')) AS t(id, name)
EXCEPT CORRESPONDING
SELECT * FROM (VALUES ('alice', 1)) AS t(name, id);")

#code-block("text", " id | name
----+------
  2 | bob
(1 row)")

#anchor("ref-order-by-clause")

== ORDER BY clause

The #raw("ORDER BY") clause is used to sort a result set by one or more output expressions:

#code-block("text", "ORDER BY expression [ ASC | DESC ] [ NULLS { FIRST | LAST } ] [, ...]")

Each expression may be composed of output columns, or it may be an ordinal number selecting an output column by position, starting at one. The #raw("ORDER BY") clause is evaluated after any #raw("GROUP BY") or #raw("HAVING") clause, and before any #raw("OFFSET"), #raw("LIMIT") or #raw("FETCH FIRST") clause. The default null ordering is #raw("NULLS LAST"), regardless of the ordering direction.

Note that, following the SQL specification, an #raw("ORDER BY") clause only affects the order of rows for queries that immediately contain the clause. Trino follows that specification, and drops redundant usage of the clause to avoid negative performance impacts.

In the following example, the clause only applies to the select statement.

#code-block("SQL", "INSERT INTO some_table
SELECT * FROM another_table
ORDER BY field;")

Since tables in SQL are inherently unordered, and the #raw("ORDER BY") clause in this case does not result in any difference, but negatively impacts performance of running the overall insert statement, Trino skips the sort operation.

Another example where the #raw("ORDER BY") clause is redundant, and does not affect the outcome of the overall statement, is a nested query:

#code-block("SQL", "SELECT *
FROM some_table
    JOIN (SELECT * FROM another_table ORDER BY field) u
    ON some_table.key = u.key;")

More background information and details can be found in #link("https://trino.io/blog/2019/06/03/redundant-order-by.html")[a blog post about this optimization].

#anchor("ref-offset-clause")

== OFFSET clause

The #raw("OFFSET") clause is used to discard a number of leading rows from the result set:

#code-block("text", "OFFSET count [ ROW | ROWS ]")

If the #raw("ORDER BY") clause is present, the #raw("OFFSET") clause is evaluated over a sorted result set, and the set remains sorted after the leading rows are discarded:

#code-block(none, "SELECT name FROM nation ORDER BY name OFFSET 22;")

#code-block("text", "      name
----------------
 UNITED KINGDOM
 UNITED STATES
 VIETNAM
(3 rows)")

Otherwise, it is arbitrary which rows are discarded. If the count specified in the #raw("OFFSET") clause equals or exceeds the size of the result set, the final result is empty.

#anchor("ref-limit-clause")

== LIMIT or FETCH FIRST clause

The #raw("LIMIT") or #raw("FETCH FIRST") clause restricts the number of rows in the result set.

#code-block("text", "LIMIT { count | ALL }")

#code-block("text", "FETCH { FIRST | NEXT } [ count ] { ROW | ROWS } { ONLY | WITH TIES }")

The following example queries a large table, but the #raw("LIMIT") clause restricts the output to only have five rows \(because the query lacks an #raw("ORDER BY"), exactly which rows are returned is arbitrary\):

#code-block(none, "SELECT orderdate FROM orders LIMIT 5;")

#code-block("text", " orderdate
------------
 1994-07-25
 1993-11-12
 1992-10-06
 1994-01-04
 1997-12-28
(5 rows)")

#raw("LIMIT ALL") is the same as omitting the #raw("LIMIT") clause.

The #raw("FETCH FIRST") clause supports either the #raw("FIRST") or #raw("NEXT") keywords and the #raw("ROW") or #raw("ROWS") keywords. These keywords are equivalent and the choice of keyword has no effect on query execution.

If the count is not specified in the #raw("FETCH FIRST") clause, it defaults to #raw("1"):

#code-block(none, "SELECT orderdate FROM orders FETCH FIRST ROW ONLY;")

#code-block("text", " orderdate
------------
 1994-02-12
(1 row)")

If the #raw("OFFSET") clause is present, the #raw("LIMIT") or #raw("FETCH FIRST") clause is evaluated after the #raw("OFFSET") clause:

#code-block(none, "SELECT * FROM (VALUES 5, 2, 4, 1, 3) t(x) ORDER BY x OFFSET 2 LIMIT 2;")

#code-block("text", " x
---
 3
 4
(2 rows)")

For the #raw("FETCH FIRST") clause, the argument #raw("ONLY") or #raw("WITH TIES") controls which rows are included in the result set.

If the argument #raw("ONLY") is specified, the result set is limited to the exact number of leading rows determined by the count.

If the argument #raw("WITH TIES") is specified, it is required that the #raw("ORDER BY") clause be present. The result set consists of the same set of leading rows and all of the rows in the same peer group as the last of them \('ties'\) as established by the ordering in the #raw("ORDER BY") clause. The result set is sorted:

#code-block(none, "SELECT name, regionkey
FROM nation
ORDER BY regionkey FETCH FIRST ROW WITH TIES;")

#code-block("text", "    name    | regionkey
------------+-----------
 ETHIOPIA   |         0
 MOROCCO    |         0
 KENYA      |         0
 ALGERIA    |         0
 MOZAMBIQUE |         0
(5 rows)")

#anchor("ref-tablesample")

== TABLESAMPLE

There are multiple sample methods:

/ #raw("BERNOULLI"): Each row is selected to be in the table sample with a probability of the sample percentage. When a table is sampled using the Bernoulli method, all physical blocks of the table are scanned and certain rows are skipped \(based on a comparison between the sample percentage and a random value calculated at runtime\).  The probability of a row being included in the result is independent from any other row. This does not reduce the time required to read the sampled table from disk. It may have an impact on the total query time if the sampled output is processed further.
/ #raw("SYSTEM"): This sampling method divides the table into logical segments of data and samples the table at this granularity. This sampling method either selects all the rows from a particular segment of data or skips it \(based on a comparison between the sample percentage and a random value calculated at runtime\).  The rows selected in a system sampling will be dependent on which connector is used. For example, when used with Hive, it is dependent on how the data is laid out on HDFS. This method does not guarantee independent sampling probabilities.

#note[
Neither of the two methods allow deterministic bounds on the number of rows returned.
]

Examples:

#code-block(none, "SELECT *
FROM users TABLESAMPLE BERNOULLI (50);

SELECT *
FROM users TABLESAMPLE SYSTEM (75);")

Using sampling with joins:

#code-block(none, "SELECT o.*, i.*
FROM orders o TABLESAMPLE SYSTEM (10)
JOIN lineitem i TABLESAMPLE BERNOULLI (40)
  ON o.orderkey = i.orderkey;")

#anchor("ref-unnest")

== UNNEST

#raw("UNNEST") can be used to expand an #link(label("ref-array-type"))[array-type] or #link(label("ref-map-type"))[map-type] into a relation. Arrays are expanded into a single column:

#code-block(none, "SELECT * FROM UNNEST(ARRAY[1,2]) AS t(number);")

#code-block("text", " number
--------
      1
      2
(2 rows)")

Maps are expanded into two columns \(key, value\):

#code-block(none, "SELECT * FROM UNNEST(
        map_from_entries(
            ARRAY[
                ('SQL',1974),
                ('Java', 1995)
            ]
        )
) AS t(language, first_appeared_year);")

#code-block("text", " language | first_appeared_year
----------+---------------------
 SQL      |                1974
 Java     |                1995
(2 rows)")

#raw("UNNEST") can be used in combination with an #raw("ARRAY") of #link(label("ref-row-type"))[row-type] structures for expanding each field of the #raw("ROW") into a corresponding column:

#code-block(none, "SELECT *
FROM UNNEST(
        ARRAY[
            ROW('Java',  1995),
            ROW('SQL' , 1974)],
        ARRAY[
            ROW(false),
            ROW(true)]
) as t(language,first_appeared_year,declarative);")

#code-block("text", " language | first_appeared_year | declarative
----------+---------------------+-------------
 Java     |                1995 | false
 SQL      |                1974 | true
(2 rows)")

#raw("UNNEST") can optionally have a #raw("WITH ORDINALITY") clause, in which case an additional ordinality column is added to the end:

#code-block(none, "SELECT a, b, rownumber
FROM UNNEST (
    ARRAY[2, 5],
    ARRAY[7, 8, 9]
     ) WITH ORDINALITY AS t(a, b, rownumber);")

#code-block("text", "  a   | b | rownumber
------+---+-----------
    2 | 7 |         1
    5 | 8 |         2
 NULL | 9 |         3
(3 rows)")

#raw("UNNEST") returns zero entries when the array\/map is empty:

#code-block(none, "SELECT * FROM UNNEST (ARRAY[]) AS t(value);")

#code-block("text", " value
-------
(0 rows)")

#raw("UNNEST") returns zero entries when the array\/map is null:

#code-block(none, "SELECT * FROM UNNEST (CAST(null AS ARRAY(integer))) AS t(number);")

#code-block("text", " number
--------
(0 rows)")

#raw("UNNEST") is normally used with a #raw("JOIN"), and can reference columns from relations on the left side of the join:

#code-block(none, "SELECT student, score
FROM (
   VALUES
      ('John', ARRAY[7, 10, 9]),
      ('Mary', ARRAY[4, 8, 9])
) AS tests (student, scores)
CROSS JOIN UNNEST(scores) AS t(score);")

#code-block("text", " student | score
---------+-------
 John    |     7
 John    |    10
 John    |     9
 Mary    |     4
 Mary    |     8
 Mary    |     9
(6 rows)")

#raw("UNNEST") can also be used with multiple arguments, in which case they are expanded into multiple columns, with as many rows as the highest cardinality argument \(the other columns are padded with nulls\):

#code-block(none, "SELECT numbers, animals, n, a
FROM (
  VALUES
    (ARRAY[2, 5], ARRAY['dog', 'cat', 'bird']),
    (ARRAY[7, 8, 9], ARRAY['cow', 'pig'])
) AS x (numbers, animals)
CROSS JOIN UNNEST(numbers, animals) AS t (n, a);")

#code-block("text", "  numbers  |     animals      |  n   |  a
-----------+------------------+------+------
 [2, 5]    | [dog, cat, bird] |    2 | dog
 [2, 5]    | [dog, cat, bird] |    5 | cat
 [2, 5]    | [dog, cat, bird] | NULL | bird
 [7, 8, 9] | [cow, pig]       |    7 | cow
 [7, 8, 9] | [cow, pig]       |    8 | pig
 [7, 8, 9] | [cow, pig]       |    9 | NULL
(6 rows)")

#raw("LEFT JOIN") is preferable in order to avoid losing the row containing the array\/map field in question when referenced columns from relations on the left side of the join can be empty or have #raw("NULL") values:

#code-block(none, "SELECT runner, checkpoint
FROM (
   VALUES
      ('Joe', ARRAY[10, 20, 30, 42]),
      ('Roger', ARRAY[10]),
      ('Dave', ARRAY[]),
      ('Levi', NULL)
) AS marathon (runner, checkpoints)
LEFT JOIN UNNEST(checkpoints) AS t(checkpoint) ON TRUE;")

#code-block("text", " runner | checkpoint
--------+------------
 Joe    |         10
 Joe    |         20
 Joe    |         30
 Joe    |         42
 Roger  |         10
 Dave   |       NULL
 Levi   |       NULL
(7 rows)")

Note that in case of using #raw("LEFT JOIN") the only condition supported by the current implementation is #raw("ON TRUE").

#anchor("ref-select-json-table")

== JSON\_TABLE

#raw("JSON_TABLE") transforms JSON data into a relational table format. Like #raw("UNNEST") and #raw("LATERAL"), use #raw("JSON_TABLE") in the #raw("FROM") clause of a #raw("SELECT") statement. For more information, see #link(label("ref-json-table"))[#raw("JSON_TABLE")].

== Joins

Joins allow you to combine data from multiple relations.

=== CROSS JOIN

A cross join returns the Cartesian product \(all combinations\) of two relations. Cross joins can either be specified using the explit #raw("CROSS JOIN") syntax or by specifying multiple relations in the #raw("FROM") clause.

Both of the following queries are equivalent:

#code-block(none, "SELECT *
FROM nation
CROSS JOIN region;

SELECT *
FROM nation, region;")

The #raw("nation") table contains 25 rows and the #raw("region") table contains 5 rows, so a cross join between the two tables produces 125 rows:

#code-block(none, "SELECT n.name AS nation, r.name AS region
FROM nation AS n
CROSS JOIN region AS r
ORDER BY 1, 2;")

#code-block("text", "     nation     |   region
----------------+-------------
 ALGERIA        | AFRICA
 ALGERIA        | AMERICA
 ALGERIA        | ASIA
 ALGERIA        | EUROPE
 ALGERIA        | MIDDLE EAST
 ARGENTINA      | AFRICA
 ARGENTINA      | AMERICA
...
(125 rows)")

=== LATERAL

Subqueries appearing in the #raw("FROM") clause can be preceded by the keyword #raw("LATERAL"). This allows them to reference columns provided by preceding #raw("FROM") items.

A #raw("LATERAL") join can appear at the top level in the #raw("FROM") list, or anywhere within a parenthesized join tree. In the latter case, it can also refer to any items that are on the left-hand side of a #raw("JOIN") for which it is on the right-hand side.

When a #raw("FROM") item contains #raw("LATERAL") cross-references, evaluation proceeds as follows: for each row of the #raw("FROM") item providing the cross-referenced columns, the #raw("LATERAL") item is evaluated using that row set's values of the columns. The resulting rows are joined as usual with the rows they were computed from. This is repeated for set of rows from the column source tables.

#raw("LATERAL") is primarily useful when the cross-referenced column is necessary for computing the rows to be joined:

#code-block(none, "SELECT name, x, y
FROM nation
CROSS JOIN LATERAL (SELECT name || ' :-' AS x)
CROSS JOIN LATERAL (SELECT x || ')' AS y);")

When #raw("LATERAL") appears on the right side of a #raw("FULL JOIN"), the only condition supported by the current implementation is #raw("ON TRUE").

=== NEAREST

#raw("NEAREST") is a relation that selects at most one row from a #raw("FROM") relation for each row on the left side of a join.

Use #raw("NEAREST") on the right side of an explicit #raw("CROSS JOIN"), #raw("INNER JOIN") with #raw("ON TRUE"), #raw("LEFT JOIN") with #raw("ON TRUE"), or an implicit comma join:

#code-block("text", "CROSS JOIN NEAREST (
    FROM relation
    [ WHERE condition ]
    MATCH comparison
)

INNER JOIN NEAREST (
    FROM relation
    [ WHERE condition ]
    MATCH comparison
) ON TRUE

relation,
NEAREST (
    FROM relation
    [ WHERE condition ]
    MATCH comparison
)

LEFT JOIN NEAREST (
    FROM relation
    [ WHERE condition ]
    MATCH comparison
 ) ON TRUE")

The #raw("MATCH") clause is required. It must be a single comparison using one expression from the #raw("FROM") relation and one non-#raw("FROM") expression, with one of the operators #raw("<"), #raw("<="), #raw(">"), or #raw(">=").

The comparison determines both the matching direction and the ordering of candidate rows:

- #raw("<") and #raw("<=") select the closest row from the #raw("FROM") relation whose match key is smaller than, or smaller than or equal to, the other expression.
- #raw(">") and #raw(">=") select the closest row from the #raw("FROM") relation whose match key is greater than, or greater than or equal to, the other expression.

The optional #raw("WHERE") clause filters candidate rows before the nearest row is selected.

#raw("NEAREST") can be understood as shorthand for a lateral subquery that filters to matching candidate rows, orders them by the #raw("FROM") relation match key, and keeps only the first row. For example:

- #raw("NEAREST (     FROM ...     WHERE ...     MATCH right_key <= left_key )") is equivalent to:
  
  #code-block("sql", "LATERAL (
      SELECT *
      FROM ...
      WHERE ...
          AND right_key <= left_key
      ORDER BY right_key DESC
      FETCH FIRST 1 ROW ONLY
  )")
- #raw("NEAREST (     FROM ...     WHERE ...     MATCH right_key >= left_key )") is equivalent to:
  
  #code-block("sql", "LATERAL (
      SELECT *
      FROM ...
      WHERE ...
          AND right_key >= left_key
      ORDER BY right_key ASC
      FETCH FIRST 1 ROW ONLY
  )")

More generally, #raw("<") and #raw("<=") order the #raw("FROM") relation match key descending, while #raw(">") and #raw(">=") order it ascending.

For example, the following query matches each trade with the most recent quote for the same symbol:

#code-block("sql", "SELECT trades.symbol, trades.ts, quotes.price
FROM trades
CROSS JOIN NEAREST (
    FROM quotes
    WHERE quotes.symbol = trades.symbol
    MATCH quotes.ts <= trades.ts
);")

To preserve rows from the left side when no nearest row exists, use #raw("LEFT JOIN NEAREST"):

#code-block("sql", "SELECT trades.symbol, quotes.price
FROM trades
LEFT JOIN NEAREST (
    FROM quotes
    WHERE quotes.symbol = trades.symbol
    MATCH quotes.ts >= trades.ts
) ON TRUE;")

The current implementation supports #raw("CROSS JOIN NEAREST (...)"), #raw("INNER JOIN NEAREST (...) ON TRUE"), implicit comma joins with #raw("NEAREST (...)"), and #raw("LEFT JOIN NEAREST (...) ON TRUE"). #raw("JOIN USING"), #raw("NATURAL JOIN"), and join conditions other than #raw("ON TRUE") are not supported for #raw("NEAREST").

=== Qualifying column names

When two relations in a join have columns with the same name, the column references must be qualified using the relation alias \(if the relation has an alias\), or with the relation name:

#code-block(none, "SELECT nation.name, region.name
FROM nation
CROSS JOIN region;

SELECT n.name, r.name
FROM nation AS n
CROSS JOIN region AS r;

SELECT n.name, r.name
FROM nation n
CROSS JOIN region r;")

The following query will fail with the error #raw("Column 'name' is ambiguous"):

#code-block(none, "SELECT name
FROM nation
CROSS JOIN region;")

== Subqueries

A subquery is an expression which is composed of a query. The subquery is correlated when it refers to columns outside of the subquery. Logically, the subquery will be evaluated for each row in the surrounding query. The referenced columns will thus be constant during any single evaluation of the subquery.

#note[
Support for correlated subqueries is limited. Not every standard form is supported.
]

=== EXISTS

The #raw("EXISTS") predicate determines if a subquery returns any rows:

#code-block(none, "SELECT name
FROM nation
WHERE EXISTS (
     SELECT *
     FROM region
     WHERE region.regionkey = nation.regionkey
);")

=== IN

The #raw("IN") predicate determines if any values produced by the subquery are equal to the provided expression. The result of #raw("IN") follows the standard rules for nulls. The subquery must produce exactly one column:

#code-block(none, "SELECT name
FROM nation
WHERE regionkey IN (
     SELECT regionkey
     FROM region
     WHERE name = 'AMERICA' OR name = 'AFRICA'
);")

=== Scalar subquery

A scalar subquery is a non-correlated subquery that returns zero or one row. It is an error for the subquery to produce more than one row. The returned value is #raw("NULL") if the subquery produces no rows:

#code-block(none, "SELECT name
FROM nation
WHERE regionkey = (SELECT max(regionkey) FROM region);")

#note[
Currently only single column can be returned from the scalar subquery.
]
