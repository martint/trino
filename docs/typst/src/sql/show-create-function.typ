#import "/lib/trino-docs.typ": *

#anchor("doc-sql-show-create-function")
= SHOW CREATE FUNCTION

== Synopsis

#code-block("text", "SHOW CREATE FUNCTION function_name")

== Description

Show the SQL statement that creates the specified function.

== Examples

Show the SQL that can be run to create the #raw("meaning_of_life") function:

#code-block(none, "SHOW CREATE FUNCTION example.default.meaning_of_life;")

== See also

- #link(label("doc-sql-create-function"))[CREATE FUNCTION]
- #link(label("doc-sql-drop-function"))[DROP FUNCTION]
- #link(label("doc-sql-show-functions"))[SHOW FUNCTIONS]
- #link(label("doc-udf"))[User-defined functions]
- #link(label("doc-admin-properties-sql-environment"))[SQL environment properties]
