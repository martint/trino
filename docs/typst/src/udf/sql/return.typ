#import "/lib/trino-docs.typ": *

#anchor("doc-udf-sql-return")
= RETURN

== Synopsis

#code-block("text", "RETURN expression")

== Description

Provide the value from a #link(label("doc-udf-sql"))[SQL user-defined functions] to the caller. The value is the result of evaluating the expression. It can be a static value, a declared variable or a more complex expression.

== Examples

The following examples return a static value, the result of an expression, and the value of the variable x:

#code-block("sql", "RETURN 42;
RETURN 6 * 7;
RETURN x;")

Further examples of varying complexity that cover usage of the #raw("RETURN") statement in combination with other statements are available in the #link(label("doc-udf-sql-examples"))[Example SQL UDFs].

All SQL UDFs must contain a #raw("RETURN") statement at the end of the top-level block in the #raw("FUNCTION") declaration, even if it's unreachable.

== See also

- #link(label("doc-udf-sql"))[SQL user-defined functions]
- #link(label("doc-udf-function"))[FUNCTION]
