#import "/lib/trino-docs.typ": *

#anchor("doc-sql-alter-schema")
= ALTER SCHEMA

== Synopsis

#code-block("text", "ALTER SCHEMA name RENAME TO new_name
ALTER SCHEMA name SET AUTHORIZATION ( user | USER user | ROLE role )")

== Description

Change the definition of an existing schema.

== Examples

Rename schema #raw("web") to #raw("traffic"):

#code-block(none, "ALTER SCHEMA web RENAME TO traffic")

Change owner of schema #raw("web") to user #raw("alice"):

#code-block(none, "ALTER SCHEMA web SET AUTHORIZATION alice")

Allow everyone to drop schema and create tables in schema #raw("web"):

#code-block(none, "ALTER SCHEMA web SET AUTHORIZATION ROLE PUBLIC")

== See Also

create-schema
