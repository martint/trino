#import "/lib/trino-docs.typ": *

#anchor("doc-udf-sql-begin")
= BEGIN

== Synopsis

#code-block("text", "BEGIN
  [ DECLARE ... ]
  statements
END")

== Description

Marks the start and end of a block in a #link(label("doc-udf-sql"))[SQL user-defined functions]. #raw("BEGIN") can be used wherever a statement can be used to group multiple statements together and to declare variables local to the block. A typical use case is as first statement within a #link(label("doc-udf-function"))[FUNCTION]. Blocks can also be nested.

After the #raw("BEGIN") keyword, you can add variable declarations using #link(label("doc-udf-sql-declare"))[DECLARE] statements, followed by one or more statements that define the main body of the SQL UDF, separated by #raw(";"). The following statements can be used:

- #link(label("doc-udf-sql-case"))[CASE]
- #link(label("doc-udf-sql-if"))[IF]
- #link(label("doc-udf-sql-iterate"))[ITERATE]
- #link(label("doc-udf-sql-leave"))[LEAVE]
- #link(label("doc-udf-sql-loop"))[LOOP]
- #link(label("doc-udf-sql-repeat"))[REPEAT]
- #link(label("doc-udf-sql-return"))[RETURN]
- #link(label("doc-udf-sql-set"))[SET]
- #link(label("doc-udf-sql-while"))[WHILE]
- Nested #link(label("doc-udf-sql-begin"))[BEGIN] blocks

== Examples

The following example computes the value #raw("42"):

#code-block("sql", "FUNCTION meaning_of_life()
  RETURNS integer
  BEGIN
    DECLARE a integer DEFAULT 6;
    DECLARE b integer DEFAULT 7;
    RETURN a * b;
  END")

Further examples of varying complexity that cover usage of the #raw("BEGIN") statement in combination with other statements are available in the #link(label("doc-udf-sql-examples"))[Example SQL UDFs].

== See also

- #link(label("doc-udf"))[User-defined functions]
- #link(label("doc-udf-sql"))[SQL user-defined functions]
- #link(label("doc-udf-function"))[FUNCTION]
