#import "/lib/trino-docs.typ": *

#anchor("doc-udf-sql-declare")
= DECLARE

== Synopsis

#code-block("text", "DECLARE identifier [, ...] type [ DEFAULT expression ]")

== Description

Use the #raw("DECLARE") statement directly after the #link(label("doc-udf-sql-begin"))[BEGIN] keyword in #link(label("doc-udf-sql"))[SQL user-defined functions] to define one or more variables with an #raw("identifier") as name. Each statement must specify the #link(label("doc-language-types"))[data type] of the variable with #raw("type"). It can optionally include a default, initial value defined by an #raw("expression"). The default value is #raw("NULL") if not specified.

== Examples

A simple declaration of the variable #raw("x") with the #raw("tinyint") data type and the implicit default value of #raw("null"):

#code-block("sql", "DECLARE x tinyint;")

A declaration of multiple string variables with length restricted to 25 characters:

#code-block("sql", "DECLARE first_name, last_name, middle_name varchar(25);")

A declaration of an exact decimal number with a default value:

#code-block("sql", "DECLARE uptime_requirement decimal DEFAULT 99.999;")

A declaration with a default value from an expression:

#code-block("sql", "DECLARE start_time timestamp(3) with time zone DEFAULT now();")

Further examples of varying complexity that cover usage of the #raw("DECLARE") statement in combination with other statements are available in the #link(label("doc-udf-sql-examples"))[Example SQL UDFs].

== See also

- #link(label("doc-udf-sql"))[SQL user-defined functions]
- #link(label("doc-language-types"))[Data types]
