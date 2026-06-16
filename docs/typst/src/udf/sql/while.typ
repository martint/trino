#import "/lib/trino-docs.typ": *

#anchor("doc-udf-sql-while")
= WHILE

== Synopsis

#code-block("text", "[label :] WHILE condition DO
  statements
END WHILE")

== Description

The #raw("WHILE") statement is an optional construct in #link(label("doc-udf-sql"))[SQL user-defined functions] to allow processing of a block of statements as long as a condition is met. The condition is validated as a first step of each iteration.

The expression that defines the #raw("condition") is evaluated at least once. If the result is #raw("true"), processing moves to #raw("DO"), through following #raw("statements") and back to #raw("WHILE") and the #raw("condition"). If the result is #raw("false"), processing moves to #raw("END WHILE")  and continues with the next statement in the function.

The optional #raw("label") before the #raw("WHILE") keyword can be used to #link(label("ref-udf-sql-label"))[name the block].

Note that a #raw("WHILE") statement is very similar, with the difference that for #raw("REPEAT") the statements are processed at least once, and for #raw("WHILE") blocks the statements might not be processed at all.

== Examples

#code-block("sql", "WHILE p > 1 DO
  SET r = r * n;
  SET p = p - 1;
END WHILE;")

Further examples of varying complexity that cover usage of the #raw("WHILE") statement in combination with other statements are available in the #link(label("doc-udf-sql-examples"))[Example SQL UDFs].

== See also

- #link(label("doc-udf-sql"))[SQL user-defined functions]
- #link(label("doc-udf-sql-loop"))[LOOP]
- #link(label("doc-udf-sql-repeat"))[REPEAT]
