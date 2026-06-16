#import "/lib/trino-docs.typ": *

#anchor("doc-functions-conditional")
= Conditional expressions

#anchor("ref-case-expression")

== CASE

The standard SQL #raw("CASE") expression has two forms. The "simple" form searches each #raw("value") expression from left to right until it finds one that equals #raw("expression"):

#code-block("text", "CASE expression
    WHEN value THEN result
    [ WHEN ... ]
    [ ELSE result ]
END")

The #raw("result") for the matching #raw("value") is returned. If no match is found, the #raw("result") from the #raw("ELSE") clause is returned if it exists, otherwise null is returned. Example:

#code-block(none, "SELECT a,
       CASE a
           WHEN 1 THEN 'one'
           WHEN 2 THEN 'two'
           ELSE 'many'
       END")

The "searched" form evaluates each boolean #raw("condition") from left to right until one is true and returns the matching #raw("result"):

#code-block("text", "CASE
    WHEN condition THEN result
    [ WHEN ... ]
    [ ELSE result ]
END")

If no conditions are true, the #raw("result") from the #raw("ELSE") clause is returned if it exists, otherwise null is returned. Example:

#code-block(none, "SELECT a, b,
       CASE
           WHEN a = 1 THEN 'aaa'
           WHEN b = 2 THEN 'bbb'
           ELSE 'ccc'
       END")

SQL UDFs can use #link(label("doc-udf-sql-case"))[#raw("CASE") statements] that use a slightly different syntax from the CASE expressions. Specifically note the requirements for terminating each clause with a semicolon #raw(";") and the usage of #raw("END CASE").

#anchor("ref-if-expression")

== IF

The #raw("IF") expression has two forms, one supplying only a #raw("true_value") and the other supplying both a #raw("true_value") and a #raw("false_value"):

#function-def("fn-if", "if(condition, true_value)", none)[
Evaluates and returns #raw("true_value") if #raw("condition") is true, otherwise null is returned and #raw("true_value") is not evaluated.
]

#function-def("fn-if-2", "if(condition, true_value, false_value)", none, ref: false)[
Evaluates and returns #raw("true_value") if #raw("condition") is true, otherwise evaluates and returns #raw("false_value").
]

The following #raw("IF") and #raw("CASE") expressions are equivalent:

#code-block("sql", "SELECT
  orderkey,
  totalprice,
  IF(totalprice >= 150000, 'High Value', 'Low Value')
FROM tpch.sf1.orders;")

#code-block("sql", "SELECT
  orderkey,
  totalprice,
  CASE
    WHEN totalprice >= 150000 THEN 'High Value'
    ELSE 'Low Value'
  END
FROM tpch.sf1.orders;")

SQL UDFs can use #link(label("doc-udf-sql-if"))[#raw("IF") statements] that use a slightly different syntax from #raw("IF") expressions. Specifically note the requirement for terminating each clause with a semicolon #raw(";") and the usage of #raw("END IF").

#anchor("ref-coalesce-function")

== COALESCE

#function-def("fn-coalesce", "coalesce(value1, value2[, ...])", none)[
Returns the first non-null #raw("value") in the argument list. Like a #raw("CASE") expression, arguments are only evaluated if necessary.
]

#anchor("ref-nullif-function")

== NULLIF

#function-def("fn-nullif", "nullif(value1, value2)", none)[
Returns null if #raw("value1") equals #raw("value2"), otherwise returns #raw("value1").
]

#anchor("ref-try-function")

== TRY

#function-def("fn-try", "try(expression)", none)[
Evaluate an expression and handle certain types of errors by returning #raw("NULL").
]

In cases where it is preferable that queries produce #raw("NULL") or default values instead of failing when corrupt or invalid data is encountered, the #raw("TRY") function may be useful. To specify default values, the #raw("TRY") function can be used in conjunction with the #raw("COALESCE") function.

The following errors are handled by #raw("TRY"):

- Division by zero
- Invalid cast or function argument
- Numeric value out of range
- Invalid JSON literal
- JSON input or output conversion errors
- JSON path evaluation errors
- JSON value function result errors

=== Examples

Source table with some invalid data:

#code-block("sql", "SELECT * FROM shipping;")

#code-block("text", " origin_state | origin_zip | packages | total_cost
--------------+------------+----------+------------
 California   |      94131 |       25 |        100
 California   |      P332a |        5 |         72
 California   |      94025 |        0 |        155
 New Jersey   |      08544 |      225 |        490
(4 rows)")

Query failure without #raw("TRY"):

#code-block("sql", "SELECT CAST(origin_zip AS BIGINT) FROM shipping;")

#code-block("text", "Query failed: Cannot cast 'P332a' to BIGINT")

#raw("NULL") values with #raw("TRY"):

#code-block("sql", "SELECT TRY(CAST(origin_zip AS BIGINT)) FROM shipping;")

#code-block("text", " origin_zip
------------
      94131
 NULL
      94025
      08544
(4 rows)")

Query failure without #raw("TRY"):

#code-block("sql", "SELECT total_cost / packages AS per_package FROM shipping;")

#code-block("text", "Query failed: Division by zero")

Default values with #raw("TRY") and #raw("COALESCE"):

#code-block("sql", "SELECT COALESCE(TRY(total_cost / packages), 0) AS per_package FROM shipping;")

#code-block("text", " per_package
-------------
          4
         14
          0
         19
(4 rows)")
