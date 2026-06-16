#import "/lib/trino-docs.typ": *

#anchor("doc-udf-sql-loop")
= LOOP

== Synopsis

#code-block("text", "[label :] LOOP
    statements
END LOOP")

== Description

The #raw("LOOP") statement is an optional construct in #link(label("doc-udf-sql"))[SQL user-defined functions] to allow processing of a block of statements repeatedly.

The block of #raw("statements") is processed until an explicit use of #raw("LEAVE") causes processing to exit the loop. If processing reaches #raw("END LOOP"), another iteration of processing from the beginning starts. #raw("LEAVE") statements are typically wrapped in an #raw("IF") statement that declares a condition to stop the loop.

The optional #raw("label") before the #raw("LOOP") keyword can be used to #link(label("ref-udf-sql-label"))[name the block].

== Examples

The following function counts up to #raw("100") with a step size #raw("step") in a loop starting from the start value #raw("start_value"), and returns the number of incremental steps in the loop to get to a value of #raw("100") or higher:

#code-block("sql", "FUNCTION to_one_hundred(start_value int, step int)
  RETURNS int
  BEGIN
    DECLARE count int DEFAULT 0;
    DECLARE current int DEFAULT 0;
    SET current = start_value;
    abc: LOOP
      IF current >= 100 THEN
        LEAVE abc;
      END IF;
      SET count = count + 1;
      SET current = current + step;
    END LOOP;
    RETURN count;
  END")

Example invocations:

#code-block("sql", "SELECT to_one_hundred(90, 1); --10
SELECT to_one_hundred(0, 5); --20
SELECT to_one_hundred(12, 3); -- 30")

Further examples of varying complexity that cover usage of the #raw("LOOP") statement in combination with other statements are available in the #link(label("doc-udf-sql-examples"))[SQL UDF examples documentation].

== See also

- #link(label("doc-udf-sql"))[SQL user-defined functions]
- #link(label("doc-udf-sql-leave"))[LEAVE]
