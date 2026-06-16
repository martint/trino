#import "/lib/trino-docs.typ": *

#anchor("doc-udf-sql-leave")
= LEAVE

== Synopsis

#code-block("text", "LEAVE label")

== Description

The #raw("LEAVE") statement allows processing of blocks in #link(label("doc-udf-sql"))[SQL user-defined functions] to move out of a specified context. Contexts are defined by a #link(label("ref-udf-sql-label"))[#raw("label")]. If no label is found, the functions fails with an error message.

== Examples

The following function includes a #raw("LOOP") labelled #raw("top"). The conditional #raw("IF") statement inside the loop can cause the exit from processing the loop when the value for the parameter #raw("p") is 1 or less. This can be the case if the value is passed in as 1 or less or after a number of iterations through the loop.

#code-block("sql", "FUNCTION my_pow(n int, p int)
RETURNS int
BEGIN
  DECLARE r int DEFAULT n;
  top: LOOP
    IF p <= 1 THEN
      LEAVE top;
    END IF;
    SET r = r * n;
    SET p = p - 1;
  END LOOP;
  RETURN r;
END")

Further examples of varying complexity that cover usage of the #raw("LEAVE") statement in combination with other statements are available in the #link(label("doc-udf-sql-examples"))[Example SQL UDFs].

== See also

- #link(label("doc-udf-sql"))[SQL user-defined functions]
- #link(label("doc-udf-sql-iterate"))[ITERATE]
