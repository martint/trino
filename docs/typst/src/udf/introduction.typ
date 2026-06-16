#import "/lib/trino-docs.typ": *

#anchor("doc-udf-introduction")
= Introduction to UDFs

A user-defined function \(UDF\) is a custom function authored by a user of Trino in a client application. UDFs are scalar functions that return a single output value, similar to #link(label("doc-functions"))[built-in functions].

#note[
Custom functions can alternatively be written in Java and deployed as a plugin. Details are available in the #link(label("doc-develop-functions"))[developer guide].
]

#anchor("ref-udf-declaration")

== UDF declaration

Declare the UDF with the SQL #link(label("doc-udf-function"))[FUNCTION] keyword and the supported statements for #link(label("doc-udf-sql"))[SQL user-defined functions] or #link(label("doc-udf-python"))[Python user-defined functions].

A UDF can be declared as an #link(label("ref-udf-inline"))[inline UDF] to be used in the current query, or declared as a #link(label("ref-udf-catalog"))[catalog UDF] to be used in any future query.

#anchor("ref-udf-inline")

== Inline user-defined functions

An inline user-defined function \(inline UDF\) declares and uses the UDF within a query processing context. The UDF is declared in a #raw("WITH") block before the query:

#code-block("sql", "WITH
  FUNCTION doubleup(x integer)
    RETURNS integer
    RETURN x * 2
SELECT doubleup(21);
-- 42")

Inline UDF names must follow SQL identifier naming conventions, and cannot contain #raw(".") characters.

The UDF declaration is only valid within the context of the query. A separate later invocation of the UDF is not possible. If this is desired, use a #link(label("ref-udf-catalog"))[catalog UDF].

Multiple inline UDF declarations are comma-separated, and can include UDFs calling each other, as long as a called UDF is declared before the first invocation.

#code-block("sql", "WITH
  FUNCTION doubleup(x integer)
    RETURNS integer
    RETURN x * 2,
  FUNCTION doubleupplusone(x integer)
    RETURNS integer
    RETURN doubleup(x) + 1
SELECT doubleupplusone(21);
-- 43")

Note that inline UDFs can mask and override the meaning of a built-in function:

#code-block("sql", "WITH
  FUNCTION abs(x integer)
    RETURNS integer
    RETURN x * 2
SELECT abs(-10); -- -20, not 10!")

#anchor("ref-udf-catalog")

== Catalog user-defined functions

You can store a UDF in the context of a catalog, if the connector used in the catalog supports UDF storage. The following connectors support catalog UDF storage:

- #link(label("doc-connector-hive"))[Hive connector]
- #link(label("doc-connector-memory"))[Memory connector]

In this scenario, the following commands can be used:

- #link(label("doc-sql-create-function"))[CREATE FUNCTION] to create and store a UDF.
- #link(label("doc-sql-drop-function"))[DROP FUNCTION] to remove a UDF.
- #link(label("doc-sql-show-functions"))[SHOW FUNCTIONS] to display a list of UDFs in a catalog.

Catalog UDFs must use a name that combines the catalog name and schema name with the UDF name, such as #raw("example.default.power") for the #raw("power") UDF in the #raw("default") schema of the #raw("example") catalog.

Invocation must use the fully qualified name, such as #raw("example.default.power").

#anchor("ref-udf-sql-environment")

== SQL environment configuration for UDFs

Configuration of the #raw("sql.default-function-catalog") and #raw("sql.default-function-schema") #link(label("doc-admin-properties-sql-environment"))[SQL environment properties] allows you to set the default storage for UDFs. The catalog and schema must be added to the #raw("sql.path") as well. This enables users to call UDFs and perform all #link(label("ref-udf-management"))[SQL statement support] without specifying the full path to the UDF.

#note[
Use the #link(label("doc-connector-memory"))[Memory connector] in a catalog for simple storing and testing of your UDFs.
]

== Recommendations

Processing UDFs can potentially be resource intensive on the cluster in terms of memory and processing. Take the following considerations into account when writing and running UDFs:

- Some checks for the runtime behavior of queries, and therefore UDF processing, are in place. For example, if a query takes longer to process than a hardcoded threshold, processing is automatically terminated.
- Avoid creation of arrays in a looping construct. Each iteration creates a separate new array with all items and copies the data for each modification, leaving the prior array in memory for automated clean up later. Use a #link(label("doc-functions-lambda"))[lambda expression] instead of the loop.
- Avoid concatenating strings in a looping construct. Each iteration creates a separate new string and copying the old string for each modification, leaving the prior string in memory for automated clean up later. Use a #link(label("doc-functions-lambda"))[lambda expression] instead of the loop.
- Most UDFs should declare the #raw("RETURNS NULL ON NULL INPUT") characteristics unless the code has some special handling for null values. You must declare this explicitly since #raw("CALLED ON NULL INPUT") is the default characteristic.
