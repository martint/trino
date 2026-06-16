#import "/lib/trino-docs.typ": *

#anchor("doc-udf")
= User-defined functions

A user-defined function \(UDF\) is a custom function authored by a user of Trino in a client application. UDFs are scalar functions that return a single output value, similar to #link(label("doc-functions"))[built-in functions].

More details are available in the following sections:

- #link(label("doc-udf-introduction"))[Introduction to UDFs]
- #link(label("doc-udf-function"))[FUNCTION]
- #link(label("doc-udf-sql"))[SQL user-defined functions]
  - #link(label("doc-udf-sql-examples"))[Example SQL UDFs]
  - #link(label("doc-udf-sql-begin"))[BEGIN]
  - #link(label("doc-udf-sql-case"))[CASE]
  - #link(label("doc-udf-sql-declare"))[DECLARE]
  - #link(label("doc-udf-sql-if"))[IF]
  - #link(label("doc-udf-sql-iterate"))[ITERATE]
  - #link(label("doc-udf-sql-leave"))[LEAVE]
  - #link(label("doc-udf-sql-loop"))[LOOP]
  - #link(label("doc-udf-sql-repeat"))[REPEAT]
  - #link(label("doc-udf-sql-return"))[RETURN]
  - #link(label("doc-udf-sql-set"))[SET]
  - #link(label("doc-udf-sql-while"))[WHILE]
- #link(label("doc-udf-python"))[Python user-defined functions]
  - \/udf\/python\/examples
