#import "/lib/trino-docs.typ": *

#anchor("doc-udf-function")
= FUNCTION

== Synopsis

#code-block("text", "FUNCTION name ( [ parameter_name data_type [, ...] ] )
  RETURNS type
  [ LANGUAGE language]
  [ NOT? DETERMINISTIC ]
  [ RETURNS NULL ON NULL INPUT ]
  [ CALLED ON NULL INPUT ]
  [ SECURITY { DEFINER | INVOKER } ]
  [ COMMENT description]
  [ WITH ( property_name = expression [, ...] ) ]
  { statements | AS definition }")

== Description

Declare a #link(label("doc-udf"))[user-defined function].

The #raw("name") of the UDF. #link(label("ref-udf-inline"))[Introduction to UDFs] can use a simple string. #link(label("ref-udf-catalog"))[Introduction to UDFs] must qualify the name of the catalog and schema, delimited by #raw("."), to store the UDF or rely on the #link(label("doc-admin-properties-sql-environment"))[default catalog and schema for UDF storage].

The list of parameters is a comma-separated list of names #raw("parameter_name") and data types #raw("data_type"), see #link(label("doc-language-types"))[data type]. An empty list, specified as #raw("()") is also valid.

The #raw("type") value after the #raw("RETURNS") keyword identifies the #link(label("doc-language-types"))[data type] of the UDF output.

The optional #raw("LANGUAGE") characteristic identifies the language used for the UDF definition with #raw("language"). The #raw("SQL") and #raw("PYTHON") languages are supported by default. Additional languages may be supported via a language engine plugin. If not specified, the default language is #raw("SQL").

The optional #raw("DETERMINISTIC") or #raw("NOT DETERMINISTIC") characteristic declares that the UDF is deterministic. This means that repeated UDF calls with identical input parameters yield the same result. A UDF is non-deterministic if it calls any non-deterministic UDFs and #link(label("doc-functions"))[functions]. By default, UDFs are assumed to have a deterministic behavior.

The optional #raw("RETURNS NULL ON NULL INPUT") characteristic declares that the UDF returns a #raw("NULL") value when any of the input parameters are #raw("NULL"). The UDF is not invoked with a #raw("NULL") input value.

The #raw("CALLED ON NULL INPUT") characteristic declares that the UDF is invoked with #raw("NULL") input parameter values.

The #raw("RETURNS NULL ON NULL INPUT") and #raw("CALLED ON NULL INPUT") characteristics are mutually exclusive, with #raw("CALLED ON NULL INPUT") as the default.

The security declaration of #raw("SECURITY INVOKER") or #raw("SECURITY DEFINER") is only valid for catalog UDFs. It sets the mode for processing the UDF with the permissions of the user who calls the UDF \(#raw("INVOKER")\) or the user who created the UDF \(#raw("DEFINER")\).

The #raw("COMMENT") characteristic can be used to provide information about the function to other users as #raw("description"). The information is accessible with #link(label("doc-sql-show-functions"))[SHOW FUNCTIONS].

The optional #raw("WITH") clause can be used to specify properties for the function. The available properties vary based on the function language. For #link(label("doc-udf-python"))[Python user-defined functions], the #raw("handler") property specifies the name of the Python function to invoke.

For SQL UDFs the body of the UDF can either be a simple single #raw("RETURN") statement with an expression, or compound list of #raw("statements") in a #raw("BEGIN") block. UDF must contain a #raw("RETURN") statement at the end of the top-level block, even if it's unreachable.

For UDFs in other languages, the #raw("definition") is enclosed in a #raw("$$")-quoted string.

== Examples

A simple catalog function:

#code-block("sql", "CREATE FUNCTION example.default.meaning_of_life()
  RETURNS BIGINT
  RETURN 42;")

And used:

#code-block("sql", "SELECT example.default.meaning_of_life(); -- returns 42")

Equivalent usage with an inline function:

#code-block("sql", "WITH FUNCTION meaning_of_life()
  RETURNS BIGINT
  RETURN 42
SELECT meaning_of_life();")

Further examples of varying complexity that cover usage of the #raw("FUNCTION") statement in combination with other statements are available in the #link(label("doc-udf-sql-examples"))[SQL UDF documentation] and the #link(label("doc-udf-python"))[Python UDF documentation].

== See also

- #link(label("doc-udf"))[User-defined functions]
- #link(label("doc-udf-sql"))[SQL user-defined functions]
- #link(label("doc-udf-python"))[Python user-defined functions]
- #link(label("doc-sql-create-function"))[CREATE FUNCTION]
