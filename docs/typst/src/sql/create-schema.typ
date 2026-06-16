#import "/lib/trino-docs.typ": *

#anchor("doc-sql-create-schema")
= CREATE SCHEMA

== Synopsis

#code-block("text", "CREATE SCHEMA [ IF NOT EXISTS ] schema_name
[ AUTHORIZATION ( user | USER user | ROLE role ) ]
[ WITH ( property_name = expression [, ...] ) ]")

== Description

Create a new, empty schema. A schema is a container that holds tables, views and other database objects.

The optional #raw("IF NOT EXISTS") clause causes the error to be suppressed if the schema already exists.

The optional #raw("AUTHORIZATION") clause can be used to set the owner of the newly created schema to a user or role.

The optional #raw("WITH") clause can be used to set properties on the newly created schema.  To list all available schema properties, run the following query:

#code-block(none, "SELECT * FROM system.metadata.schema_properties")

== Examples

Create a new schema #raw("web") in the current catalog:

#code-block(none, "CREATE SCHEMA web")

Create a new schema #raw("sales") in the #raw("hive") catalog:

#code-block(none, "CREATE SCHEMA hive.sales")

Create the schema #raw("traffic") if it does not already exist:

#code-block(none, "CREATE SCHEMA IF NOT EXISTS traffic")

Create a new schema #raw("web") and set the owner to user #raw("alice"):

#code-block(none, "CREATE SCHEMA web AUTHORIZATION alice")

Create a new schema #raw("web"), set the #raw("LOCATION") property to #raw("/hive/data/web") and set the owner to user #raw("alice"):

#code-block(none, "CREATE SCHEMA web AUTHORIZATION alice WITH ( LOCATION = '/hive/data/web' )")

Create a new schema #raw("web") and allow everyone to drop schema and create tables in schema #raw("web"):

#code-block(none, "CREATE SCHEMA web AUTHORIZATION ROLE PUBLIC")

Create a new schema #raw("web"), set the #raw("LOCATION") property to #raw("/hive/data/web") and allow everyone to drop schema and create tables in schema #raw("web"):

#code-block(none, "CREATE SCHEMA web AUTHORIZATION ROLE PUBLIC WITH ( LOCATION = '/hive/data/web' )")

== See also

alter-schema, drop-schema
