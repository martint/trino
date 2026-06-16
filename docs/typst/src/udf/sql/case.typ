#import "/lib/trino-docs.typ": *

#anchor("doc-udf-sql-case")
= CASE

== Synopsis

Simple case:

#code-block("text", "CASE
  WHEN condition THEN statements
  [ ... ]
  [ ELSE statements ]
END CASE")

Searched case:

#code-block("text", "CASE expression
  WHEN expression THEN statements
  [ ... ]
  [ ELSE statements ]
END")

== Description

The #raw("CASE") statement is an optional construct to allow conditional processing in #link(label("doc-udf-sql"))[SQL user-defined functions].

The #raw("WHEN") clauses are evaluated sequentially, stopping after the first match, and therefore the order of the statements is significant. The statements of the #raw("ELSE") clause are executed if none of the #raw("WHEN") clauses match.

Unlike other languages like C or Java, SQL does not support case fall through, so processing stops at the end of the first matched case.

One or more #raw("WHEN") clauses can be used.

== Examples

The following example shows a simple #raw("CASE") statement usage:

#code-block("sql", "FUNCTION simple_case(a bigint)
  RETURNS varchar
  BEGIN
    CASE a
      WHEN 0 THEN RETURN 'zero';
      WHEN 1 THEN RETURN 'one';
      ELSE RETURN 'more than one or negative';
    END CASE;
    RETURN NULL;
  END")

Further examples of varying complexity that cover usage of the #raw("CASE") statement in combination with other statements are available in the #link(label("doc-udf-sql-examples"))[Example SQL UDFs].

== See also

- #link(label("doc-udf-sql"))[SQL user-defined functions]
- #link(label("ref-case-expression"))[Conditional expressions using #raw("CASE")]
