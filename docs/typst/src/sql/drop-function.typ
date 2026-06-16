#import "/lib/trino-docs.typ": *

#anchor("doc-sql-drop-function")
= DROP FUNCTION

== Synopsis

#code-block("text", "DROP FUNCTION [ IF EXISTS ] udf_name ( [ [ parameter_name ] data_type [, ...] ] )")

== Description

Removes a #link(label("ref-udf-catalog"))[catalog UDF]. The value of #raw("udf_name") must be fully qualified with catalog and schema location of the UDF, unless the #link(label("doc-admin-properties-sql-environment"))[default UDF storage catalog and schema] are configured.

The #raw("data_type")s must be included for UDFs that use parameters to ensure the UDF with the correct name and parameter signature is removed.

The optional #raw("IF EXISTS") clause causes the error to be suppressed if the function does not exist.

== Examples

The following example removes the #raw("meaning_of_life") UDF in the #raw("default") schema of the #raw("example") catalog:

#code-block("sql", "DROP FUNCTION example.default.meaning_of_life();")

If the UDF uses an input parameter, the type must be added:

#code-block("sql", "DROP FUNCTION multiply_by_two(bigint);")

If the #link(label("doc-admin-properties-sql-environment"))[default catalog and schema for UDF storage] is configured, you can use the following more compact syntax:

#code-block("sql", "DROP FUNCTION meaning_of_life();")

== See also

- #link(label("doc-sql-create-function"))[CREATE FUNCTION]
- #link(label("doc-sql-show-create-function"))[SHOW CREATE FUNCTION]
- #link(label("doc-sql-show-functions"))[SHOW FUNCTIONS]
- #link(label("doc-udf"))[User-defined functions]
- #link(label("doc-admin-properties-sql-environment"))[SQL environment properties]
