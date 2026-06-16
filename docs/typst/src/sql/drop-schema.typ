#import "/lib/trino-docs.typ": *

#anchor("doc-sql-drop-schema")
= DROP SCHEMA

== Synopsis

#code-block("text", "DROP SCHEMA [ IF EXISTS ] schema_name [ CASCADE | RESTRICT ]")

== Description

Drop an existing schema. The schema must be empty.

The optional #raw("IF EXISTS") clause causes the error to be suppressed if the schema does not exist.

== Examples

Drop the schema #raw("web"):

#code-block(none, "DROP SCHEMA web")

Drop the schema #raw("sales") if it exists:

#code-block(none, "DROP SCHEMA IF EXISTS sales")

Drop the schema #raw("archive"), along with everything it contains:

#code-block(none, "DROP SCHEMA archive CASCADE")

Drop the schema #raw("archive"), only if there are no objects contained in the schema:

#code-block(none, "DROP SCHEMA archive RESTRICT")

== See also

alter-schema, create-schema
