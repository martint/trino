#import "/lib/trino-docs.typ": *

#anchor("doc-sql-create-function")
= CREATE FUNCTION

== Synopsis

#code-block("text", "CREATE [OR REPLACE] FUNCTION
  udf_definition")

== Description

Create or replace a #link(label("ref-udf-catalog"))[Introduction to UDFs]. The #raw("udf_definition") is composed of the usage of #link(label("doc-udf-function"))[FUNCTION] and nested statements. The name of the UDF must be fully qualified with catalog and schema location, unless the #link(label("doc-admin-properties-sql-environment"))[default UDF storage catalog and schema] are configured. The connector used in the catalog must support UDF storage.

The optional #raw("OR REPLACE") clause causes the UDF to be replaced if it already exists rather than raising an error.

== Examples

The following example creates the #raw("meaning_of_life") UDF in the #raw("default") schema of the #raw("example") catalog:

#code-block("sql", "CREATE FUNCTION example.default.meaning_of_life()
  RETURNS bigint
  BEGIN
    RETURN 42;
  END;")

If the #link(label("doc-admin-properties-sql-environment"))[default catalog and schema for UDF storage] is configured, you can use the following more compact syntax:

#code-block("sql", "CREATE FUNCTION meaning_of_life() RETURNS bigint RETURN 42;")

Further examples of varying complexity that cover usage of the #raw("FUNCTION") statement in combination with other statements are available in the #link(label("doc-udf-sql-examples"))[SQL UDF examples documentation].

== See also

- #link(label("doc-sql-drop-function"))[DROP FUNCTION]
- #link(label("doc-sql-show-create-function"))[SHOW CREATE FUNCTION]
- #link(label("doc-sql-show-functions"))[SHOW FUNCTIONS]
- #link(label("doc-udf"))[User-defined functions]
- #link(label("doc-admin-properties-sql-environment"))[SQL environment properties]
