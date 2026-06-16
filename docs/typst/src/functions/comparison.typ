#import "/lib/trino-docs.typ": *

#anchor("doc-functions-comparison")
= Comparison functions and operators

#anchor("ref-comparison-operators")

== Comparison operators

#list-table((
  ([Operator], [Description],),
  ([#raw("<")], [Less than],),
  ([#raw(">")], [Greater than],),
  ([#raw("<=")], [Less than or equal to],),
  ([#raw(">=")], [Greater than or equal to],),
  ([#raw("=")], [Equal],),
  ([#raw("<>")], [Not equal],),
  ([#raw("!=")], [Not equal \(non-standard but popular syntax\)],)
), header-rows: 1)

#anchor("ref-range-operator")

== Range operator: BETWEEN

The #raw("BETWEEN") operator tests if a value is within a specified range. It uses the syntax #raw("value BETWEEN min AND max"):

#code-block("sql", "SELECT 3 BETWEEN 2 AND 6;")

The preceding statement is equivalent to the following statement:

#code-block("sql", "SELECT 3 >= 2 AND 3 <= 6;")

To test if a value does not fall within the specified range use #raw("NOT BETWEEN"):

#code-block("sql", "SELECT 3 NOT BETWEEN 2 AND 6;")

The statement shown above is equivalent to the following statement:

#code-block("sql", "SELECT 3 < 2 OR 3 > 6;")

A #raw("NULL") in a #raw("BETWEEN") or #raw("NOT BETWEEN") statement is evaluated using the standard #raw("NULL") evaluation rules applied to the equivalent expression above:

#code-block("sql", "SELECT NULL BETWEEN 2 AND 4; -- null

SELECT 2 BETWEEN NULL AND 6; -- null

SELECT 2 BETWEEN 3 AND NULL; -- false

SELECT 8 BETWEEN NULL AND 6; -- false")

The #raw("BETWEEN") and #raw("NOT BETWEEN") operators can also be used to evaluate any orderable type. For example, a #raw("VARCHAR"):

#code-block("sql", "SELECT 'Paul' BETWEEN 'John' AND 'Ringo'; -- true")

Note that the value, min, and max parameters to #raw("BETWEEN") and #raw("NOT BETWEEN") must be the same type. For example, Trino produces an error if you ask it if #raw("John") is between #raw("2.3") and #raw("35.2").

#anchor("ref-is-null-operator")

== IS NULL and IS NOT NULL

The #raw("IS NULL") and #raw("IS NOT NULL") operators test whether a value is null \(undefined\).  Both operators work for all data types.

Using #raw("NULL") with #raw("IS NULL") evaluates to #raw("true"):

#code-block("sql", "SELECT NULL IS NULL; -- true")

But any other constant does not:

#code-block("sql", "SELECT 3.0 IS NULL; -- false")

#anchor("ref-is-distinct-operator")

== IS DISTINCT FROM and IS NOT DISTINCT FROM

In SQL a #raw("NULL") value signifies an unknown value, so any comparison involving a #raw("NULL") produces #raw("NULL").  The  #raw("IS DISTINCT FROM") and #raw("IS NOT DISTINCT FROM") operators treat #raw("NULL") as a known value and both operators guarantee either a true or false outcome even in the presence of #raw("NULL") input:

#code-block("sql", "SELECT NULL IS DISTINCT FROM NULL; -- false

SELECT NULL IS NOT DISTINCT FROM NULL; -- true")

In the preceding example a #raw("NULL") value is not considered distinct from #raw("NULL"). When you are comparing values which may include #raw("NULL") use these operators to guarantee either a #raw("TRUE") or #raw("FALSE") result.

The following truth table demonstrate the handling of #raw("NULL") in #raw("IS DISTINCT FROM") and #raw("IS NOT DISTINCT FROM"):

#list-table((
  ([a], [b], [a = b], [a \<\> b], [a DISTINCT b], [a NOT DISTINCT b],),
  ([#raw("1")], [#raw("1")], [#raw("TRUE")], [#raw("FALSE")], [#raw("FALSE")], [#raw("TRUE")],),
  ([#raw("1")], [#raw("2")], [#raw("FALSE")], [#raw("TRUE")], [#raw("TRUE")], [#raw("FALSE")],),
  ([#raw("1")], [#raw("NULL")], [#raw("NULL")], [#raw("NULL")], [#raw("TRUE")], [#raw("FALSE")],),
  ([#raw("NULL")], [#raw("NULL")], [#raw("NULL")], [#raw("NULL")], [#raw("FALSE")], [#raw("TRUE")],)
), header-rows: 1)

== GREATEST and LEAST

These functions are not in the SQL standard, but are a common extension. Like most other functions in Trino, they return null if any argument is null. Note that in some other databases, such as PostgreSQL, they only return null if all arguments are null.

The following types are supported:

- #raw("DOUBLE")
- #raw("BIGINT")
- #raw("VARCHAR")
- #raw("TIMESTAMP")
- #raw("TIMESTAMP WITH TIME ZONE")
- #raw("DATE")

#function-def("fn-greatest", "greatest(value1, value2, ..., valueN)", "[same as input]")[
Returns the largest of the provided values.
]

#function-def("fn-least", "least(value1, value2, ..., valueN)", "[same as input]")[
Returns the smallest of the provided values.
]

#anchor("ref-quantified-comparison-predicates")

== Quantified comparison predicates: ALL, ANY and SOME

The #raw("ALL"), #raw("ANY") and #raw("SOME") quantifiers can be used together with comparison operators in the following way:

#code-block("text", "expression operator quantifier ( subquery )")

For example:

#code-block("sql", "SELECT 'hello' = ANY (VALUES 'hello', 'world'); -- true

SELECT 21 < ALL (VALUES 19, 20, 21); -- false

SELECT 42 >= SOME (SELECT 41 UNION ALL SELECT 42 UNION ALL SELECT 43); -- true")

Following are the meanings of some quantifier and comparison operator combinations:

#list-table((
  ([Expression], [Meaning],),
  ([#raw("A = ALL (...)")], [Evaluates to #raw("true") when #raw("A") is equal to all values.],),
  ([#raw("A <> ALL (...)")], [Evaluates to #raw("true") when #raw("A") doesn't match any value.],),
  ([#raw("A < ALL (...)")], [Evaluates to #raw("true") when #raw("A") is smaller than the smallest value.],),
  ([#raw("A = ANY (...)")], [Evaluates to #raw("true") when #raw("A") is equal to any of the values. This form is equivalent to #raw("A IN (...)").],),
  ([#raw("A <> ANY (...)")], [Evaluates to #raw("true") when #raw("A") doesn't match one or more values.],),
  ([#raw("A < ANY (...)")], [Evaluates to #raw("true") when #raw("A") is smaller than the biggest value.],)
), header-rows: 1)

#raw("ANY") and #raw("SOME") have the same meaning and can be used interchangeably.

#anchor("ref-like-operator")

== Pattern comparison: LIKE

The #raw("LIKE") operator can be used to compare values with a pattern:

#code-block(none, "... column [NOT] LIKE 'pattern' ESCAPE 'character';")

Matching characters is case sensitive, and the pattern supports two symbols for matching:

- #raw("_") matches any single character
- #raw("%") matches zero or more characters

Typically it is often used as a condition in #raw("WHERE") statements. An example is a query to find all continents starting with #raw("E"), which returns #raw("Europe"):

#code-block("sql", "SELECT * FROM (VALUES 'America', 'Asia', 'Africa', 'Europe', 'Australia', 'Antarctica') AS t (continent)
WHERE continent LIKE 'E%';")

You can negate the result by adding #raw("NOT"), and get all other continents, all not starting with #raw("E"):

#code-block("sql", "SELECT * FROM (VALUES 'America', 'Asia', 'Africa', 'Europe', 'Australia', 'Antarctica') AS t (continent)
WHERE continent NOT LIKE 'E%';")

If you only have one specific character to match, you can use the #raw("_") symbol for each character. The following query uses two underscores and produces only #raw("Asia") as result:

#code-block("sql", "SELECT * FROM (VALUES 'America', 'Asia', 'Africa', 'Europe', 'Australia', 'Antarctica') AS t (continent)
WHERE continent LIKE 'A__a';")

The wildcard characters #raw("_") and #raw("%") must be escaped to allow you to match them as literals. This can be achieved by specifying the #raw("ESCAPE") character to use:

#code-block("sql", "SELECT 'South_America' LIKE 'South\\_America' ESCAPE '\\';")

The above query returns #raw("true") since the escaped underscore symbol matches. If you need to match the used escape character as well, you can escape it.

If you want to match for the chosen escape character, you simply escape itself. For example, you can use #raw("\\\\") to match for #raw("\\").

#anchor("ref-in-operator")

== Row comparison: IN

The #raw("IN") operator can be used in a #raw("WHERE") clause to compare column values with a list of values. The list of values can be supplied by a subquery or directly as static values in an array:

#code-block("sql", "... WHERE column [NOT] IN ('value1','value2');
... WHERE column [NOT] IN ( subquery );")

Use the optional #raw("NOT") keyword to negate the condition.

The following example shows a simple usage with a static array:

#code-block("sql", "SELECT * FROM region WHERE name IN ('AMERICA', 'EUROPE');")

The values in the clause are used for multiple comparisons that are combined as a logical #raw("OR"). The preceding query is equivalent to the following query:

#code-block("sql", "SELECT * FROM region WHERE name = 'AMERICA' OR name = 'EUROPE';")

You can negate the comparisons by adding #raw("NOT"), and get all other regions except the values in list:

#code-block("sql", "SELECT * FROM region WHERE name NOT IN ('AMERICA', 'EUROPE');")

When using a subquery to determine the values to use in the comparison, the subquery must return a single column and one or more rows. For example, the following query returns nation name of countries in regions starting with the letter #raw("A"), specifically Africa, America, and Asia:

#code-block("sql", "SELECT nation.name
FROM nation
WHERE regionkey IN (
  SELECT regionkey
  FROM region
  WHERE starts_with(name, 'A')
)
ORDER by nation.name;")

== Examples

The following example queries showcase aspects of using comparison functions and operators related to implied ordering of values, implicit casting, and different types.

Ordering:

#code-block("sql", "SELECT 'M' BETWEEN 'A' AND 'Z'; -- true
SELECT 'A' < 'B'; -- true
SELECT 'A' < 'a'; -- true
SELECT TRUE > FALSE; -- true
SELECT 'M' BETWEEN 'A' AND 'Z'; -- true
SELECT 'm' BETWEEN 'A' AND 'Z'; -- false")

The following queries show a subtle difference between #raw("char") and #raw("varchar") types. The length parameter for #raw("varchar") is an optional maximum length parameter and comparison is based on the data only, ignoring the length:

#code-block("sql", "SELECT cast('Test' as varchar(20)) = cast('Test' as varchar(25)); --true
SELECT cast('Test' as varchar(20)) = cast('Test   ' as varchar(25)); --false")

The length parameter for #raw("char") defines a fixed length character array. Comparison with different length automatically includes a cast to the same larger length. The cast is performed as automatic padding with spaces, and therefore both queries in the following return #raw("true"):

#code-block("sql", "SELECT cast('Test' as char(20)) = cast('Test' as char(25)); -- true
SELECT cast('Test' as char(20)) = cast('Test   ' as char(25)); -- true")

The following queries show how date types are ordered, and how date is implicitly cast to timestamp with zero time values:

#code-block("sql", "SELECT DATE '2024-08-22' < DATE '2024-08-31';
SELECT DATE '2024-08-22' < TIMESTAMP '2024-08-22 8:00:00';")
