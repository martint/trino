#import "/lib/trino-docs.typ": *

#anchor("doc-sql-show-functions")
= SHOW FUNCTIONS

== Synopsis

#code-block("text", "SHOW FUNCTIONS [ FROM schema ] [ LIKE pattern ]")

== Description

List functions in #raw("schema") or all functions in the current session path. This can include built-in functions, #link(label("doc-develop-functions"))[functions from a custom plugin], and #link(label("doc-udf"))[User-defined functions].

For each function returned, the following information is displayed:

- Function name
- Return type
- Argument types
- Function type
- Deterministic
- Description

Use the optional #raw("FROM") keyword to only list functions in a specific catalog and schema. The location in #raw("schema") must be specified as #raw("cataglog_name.schema_name").

#link(label("ref-like-operator"))[Specify a pattern] in the optional #raw("LIKE") clause to filter the results to the desired subset.

== Examples

List all UDFs and plugin functions in the #raw("default") schema of the #raw("example") catalog:

#code-block("sql", "SHOW FUNCTIONS FROM example.default;")

List all functions with a name beginning with #raw("array"):

#code-block("sql", "SHOW FUNCTIONS LIKE 'array%';")

List all functions with a name beginning with #raw("cf"):

#code-block("sql", "SHOW FUNCTIONS LIKE 'cf%';")

Example output:

#code-block("text", "     Function      | Return Type | Argument Types | Function Type | Deterministic |               Description
 ------------------+-------------+----------------+---------------+---------------+-----------------------------------------
 cf_getgroups      | varchar     |                | scalar        | true          | Returns the current session's groups
 cf_getprincipal   | varchar     |                | scalar        | true          | Returns the current session's principal
 cf_getuser        | varchar     |                | scalar        | true          | Returns the current session's user")

== See also

- #link(label("doc-functions"))[Functions and operators]
- #link(label("doc-udf"))[User-defined functions]
- #link(label("doc-develop-functions"))[Functions]
- #link(label("doc-sql-create-function"))[CREATE FUNCTION]
- #link(label("doc-sql-drop-function"))[DROP FUNCTION]
- #link(label("doc-sql-show-create-function"))[SHOW CREATE FUNCTION]
