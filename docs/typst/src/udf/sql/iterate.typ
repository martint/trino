#import "/lib/trino-docs.typ": *

#anchor("doc-udf-sql-iterate")
= ITERATE

== Synopsis

#code-block("text", "ITERATE label")

== Description

The #raw("ITERATE") statement allows processing of blocks in #link(label("doc-udf-sql"))[SQL user-defined functions] to move processing back to the start of a context block. Contexts are defined by a #link(label("ref-udf-sql-label"))[#raw("label")]. If no label is found, the functions fails with an error message.

== Examples

#code-block("sql", "FUNCTION count()
RETURNS bigint
BEGIN
  DECLARE a int DEFAULT 0;
  DECLARE b int DEFAULT 0;
  top: REPEAT
    SET a = a + 1;
    IF a <= 3 THEN
        ITERATE top;
    END IF;
    SET b = b + 1;
  RETURN b;
END")

Further examples of varying complexity that cover usage of the #raw("ITERATE") statement in combination with other statements are available in the #link(label("doc-udf-sql-examples"))[Example SQL UDFs].

== See also

- #link(label("doc-udf-sql"))[SQL user-defined functions]
- #link(label("doc-udf-sql-leave"))[LEAVE]
