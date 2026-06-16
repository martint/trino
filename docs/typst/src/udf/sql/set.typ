#import "/lib/trino-docs.typ": *

#anchor("doc-udf-sql-set")
= SET

== Synopsis

#code-block("text", "SET identifier = expression")

== Description

Use the #raw("SET") statement in #link(label("doc-udf-sql"))[SQL user-defined functions] to assign a value to a variable, referenced by comma-separated #raw("identifier")s. The value is determined by evaluating the #raw("expression") after the #raw("=") sign.

Before the assignment the variable must be defined with a #raw("DECLARE") statement. The data type of the variable must be identical to the data type of evaluating the #raw("expression").

== Examples

The following functions returns the value #raw("1") after setting the counter variable multiple times to different values:

#code-block("sql", "FUNCTION one()
  RETURNS int
  BEGIN
    DECLARE counter int DEFAULT 1;
    SET counter = 0;
    SET counter = counter + 2;
    SET counter = counter / counter;
    RETURN counter;
  END")

Further examples of varying complexity that cover usage of the #raw("SET") statement in combination with other statements are available in the #link(label("doc-udf-sql-examples"))[Example SQL UDFs].

== See also

- #link(label("doc-udf-sql"))[SQL user-defined functions]
- #link(label("doc-udf-sql-declare"))[DECLARE]
