#import "/lib/trino-docs.typ": *

#anchor("doc-udf-sql-repeat")
= REPEAT

== Synopsis

#code-block("text", "[label :] REPEAT
    statements
UNTIL condition
END REPEAT")

== Description

The #raw("REPEAT UNTIL") statement is an optional construct in #link(label("doc-udf-sql"))[SQL user-defined functions] to allow processing of a block of statements as long as a condition is met. The condition is validated as a last step of each iteration.

The block of statements is processed at least once. After the first, and every subsequent processing the expression #raw("condidtion") is validated. If the result is #raw("true"), processing moves to #raw("END REPEAT") and continues with the next statement in the function. If the result is #raw("false"), the statements are processed again.

The optional #raw("label") before the #raw("REPEAT") keyword can be used to #link(label("ref-udf-sql-label"))[name the block].

Note that a #raw("WHILE") statement is very similar, with the difference that for #raw("REPEAT") the statements are processed at least once, and for #raw("WHILE") blocks the statements might not be processed at all.

== Examples

The following SQL UDF shows a UDF with a #raw("REPEAT") statement that runs until the value of #raw("a") is greater or equal to #raw("10").

#code-block("sql", "FUNCTION test_repeat(a bigint)
  RETURNS bigint
  BEGIN
    REPEAT
      SET a = a + 1;
    UNTIL a >= 10
    END REPEAT;
    RETURN a;
  END")

Since #raw("a") is also the input value and it is increased before the check the UDF always returns #raw("10") for input values of #raw("9") or less, and the input value

- 1 for all higher values.

Following are a couple of example invocations with result and explanation:

#code-block("sql", "SELECT test_repeat(5); -- 10
SELECT test_repeat(9); -- 10
SELECT test_repeat(10); -- 11
SELECT test_repeat(11); -- 12
SELECT test_repeat(12); -- 13")

Further examples of varying complexity that cover usage of the #raw("REPEAT") statement in combination with other statements are available in the #link(label("doc-udf-sql-examples"))[Example SQL UDFs].

== See also

- #link(label("doc-udf-sql"))[SQL user-defined functions]
- #link(label("doc-udf-sql-loop"))[LOOP]
- #link(label("doc-udf-sql-while"))[WHILE]
