#import "/lib/trino-docs.typ": *

#anchor("doc-udf-sql")
= SQL user-defined functions

A SQL user-defined function, also known as SQL routine, is a #link(label("doc-udf"))[user-defined function] that uses the SQL routine language and statements for the definition of the function.

== SQL UDF declaration

Declare a SQL UDF using the #link(label("doc-udf-function"))[FUNCTION] keyword and the following statements can be used in addition to #link(label("doc-functions"))[built-in functions and operators] and other UDFs:

- #link(label("doc-udf-sql-begin"))[BEGIN]
- #link(label("doc-udf-sql-case"))[CASE]
- #link(label("doc-udf-sql-declare"))[DECLARE]
- #link(label("doc-udf-sql-if"))[IF]
- #link(label("doc-udf-sql-iterate"))[ITERATE]
- #link(label("doc-udf-sql-leave"))[LEAVE]
- #link(label("doc-udf-sql-loop"))[LOOP]
- #link(label("doc-udf-sql-repeat"))[REPEAT]
- #link(label("doc-udf-sql-return"))[RETURN]
- #link(label("doc-udf-sql-set"))[SET]
- #link(label("doc-udf-sql-while"))[WHILE]

- #link(label("doc-udf-sql-examples"))[Example SQL UDFs]
- #link(label("doc-udf-sql-begin"))[BEGIN]
- #link(label("doc-udf-sql-case"))[CASE]
- #link(label("doc-udf-sql-declare"))[DECLARE]
- #link(label("doc-udf-sql-if"))[IF]
- #link(label("doc-udf-sql-iterate"))[ITERATE]
- #link(label("doc-udf-sql-leave"))[LEAVE]
- #link(label("doc-udf-sql-loop"))[LOOP]
- #link(label("doc-udf-sql-repeat"))[REPEAT]
- #link(label("doc-udf-sql-return"))[RETURN]
- #link(label("doc-udf-sql-set"))[SET]
- #link(label("doc-udf-sql-while"))[WHILE]

A minimal example declares the UDF #raw("doubleup") that returns the input integer value #raw("x") multiplied by two. The example shows declaration as #link(label("ref-udf-inline"))[Introduction to UDFs] and invocation with the value 21 to yield the result 42:

#code-block("sql", "WITH
  FUNCTION doubleup(x integer)
    RETURNS integer
    RETURN x * 2
SELECT doubleup(21);
-- 42")

The same UDF can also be declared as #link(label("ref-udf-catalog"))[Introduction to UDFs].

Find simple examples in each statement documentation, and refer to the #link(label("doc-udf-sql-examples"))[Example SQL UDFs] for more complex use cases that combine multiple statements.

#anchor("ref-udf-sql-named-arguments")

== Named arguments

Because a SQL UDF declares its parameters by name, you can invoke it using the named-argument form #raw("name => value") in addition to passing arguments by position. Named arguments can appear in any order, and you can mix positional arguments \(which must come first\) with named ones:

#code-block("sql", "WITH
  FUNCTION clamp(value bigint, lo bigint, hi bigint)
    RETURNS bigint
    RETURN CASE
        WHEN value < lo THEN lo
        WHEN value > hi THEN hi
        ELSE value
    END
SELECT
    clamp(7, 0, 5),                       -- positional: 5
    clamp(value => 7, lo => 0, hi => 5),  -- all named: 5
    clamp(7, hi => 5, lo => 0);           -- mixed: 5")

If you pass a name the function does not declare, the query fails with a diagnostic that points at the offending identifier. Passing a positional argument after a named one is a syntax error.

#anchor("ref-udf-sql-label")

== Labels

SQL UDFs can contain labels as markers for a specific block in the declaration before the following keywords:

- #raw("CASE")
- #raw("IF")
- #raw("LOOP")
- #raw("REPEAT")
- #raw("WHILE")

The label is used to name the block to continue processing with the #raw("ITERATE") statement or exit the block with the #raw("LEAVE") statement. This flow control is supported for nested blocks, allowing to continue or exit an outer block, not just the innermost block. For example, the following snippet uses the label #raw("top") to name the complete block from #raw("REPEAT") to #raw("END REPEAT"):

#code-block("sql", "top: REPEAT
  SET a = a + 1;
  IF a <= 3 THEN
    ITERATE top;
  END IF;
  SET b = b + 1;
  UNTIL a >= 10
END REPEAT;")

Labels can be used with the #raw("ITERATE") and #raw("LEAVE") statements to continue processing the block or leave the block. This flow control is also supported for nested blocks and labels.

== Limitations

The following limitations apply to SQL UDFs.

- UDFs must be declared before they are referenced.
- Recursion cannot be declared or processed.
- Mutual recursion can not be declared or processed.
- Queries cannot be processed in a UDF.

Specifically this means that UDFs can not use #raw("SELECT") queries to retrieve data or any other queries to process data within the UDF. Instead queries can use UDFs to process data. UDFs only work on data provided as input values and only provide output data from the #raw("RETURN") statement.
