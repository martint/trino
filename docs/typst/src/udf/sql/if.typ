#import "/lib/trino-docs.typ": *

#anchor("doc-udf-sql-if")
= IF

== Synopsis

#code-block("text", "IF condition
  THEN statements
  [ ELSEIF condition THEN statements ]
  [ ... ]
  [ ELSE statements ]
END IF")

== Description

The #raw("IF THEN") statement is an optional construct to allow conditional processing in #link(label("doc-udf-sql"))[SQL user-defined functions]. Each #raw("condition")  following an #raw("IF") or #raw("ELSEIF") must evaluate to a boolean. The result of processing the expression must result in a boolean #raw("true") value to process the #raw("statements") in the #raw("THEN") block. A result of #raw("false") results in skipping the #raw("THEN") block and moving to evaluate the next #raw("ELSEIF") and #raw("ELSE") blocks in order.

The #raw("ELSEIF") and #raw("ELSE") segments are optional.

== Examples

#code-block("sql", "FUNCTION simple_if(a bigint)
  RETURNS varchar
  BEGIN
    IF a = 0 THEN
      RETURN 'zero';
    ELSEIF a = 1 THEN
      RETURN 'one';
    ELSE
      RETURN 'more than one or negative';
    END IF;
  END")

Further examples of varying complexity that cover usage of the #raw("IF") statement in combination with other statements are available in the #link(label("doc-udf-sql-examples"))[Example SQL UDFs].

== See also

- #link(label("doc-udf-sql"))[SQL user-defined functions]
- #link(label("ref-if-expression"))[Conditional expressions using #raw("IF")]
