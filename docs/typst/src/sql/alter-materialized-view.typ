#import "/lib/trino-docs.typ": *

#anchor("doc-sql-alter-materialized-view")
= ALTER MATERIALIZED VIEW

== Synopsis

#code-block("text", "ALTER MATERIALIZED VIEW [ IF EXISTS ] name RENAME TO new_name
ALTER MATERIALIZED VIEW name SET PROPERTIES property_name = expression [, ...]
ALTER MATERIALIZED VIEW name SET AUTHORIZATION ( user | USER user | ROLE role )")

== Description

Change the name of an existing materialized view.

The optional #raw("IF EXISTS") clause causes the error to be suppressed if the materialized view does not exist. The error is not suppressed if the materialized view does not exist, but a table or view with the given name exists.

#anchor("ref-alter-materialized-view-set-properties")

=== SET PROPERTIES

The #raw("ALTER MATERIALIZED VIEW SET PROPERTIES")  statement followed by some number of #raw("property_name") and #raw("expression") pairs applies the specified properties and values to a materialized view. Omitting an already-set property from this statement leaves that property unchanged in the materialized view.

A property in a #raw("SET PROPERTIES") statement can be set to #raw("DEFAULT"), which reverts its value back to the default in that materialized view.

Support for #raw("ALTER MATERIALIZED VIEW SET PROPERTIES") varies between connectors. Refer to the connector documentation for more details.

== Examples

Rename materialized view #raw("people") to #raw("users") in the current schema:

#code-block(none, "ALTER MATERIALIZED VIEW people RENAME TO users;")

Rename materialized view #raw("people") to #raw("users"), if materialized view #raw("people") exists in the current catalog and schema:

#code-block(none, "ALTER MATERIALIZED VIEW IF EXISTS people RENAME TO users;")

Set view properties \(#raw("x = y")\) in materialized view #raw("people"):

#code-block(none, "ALTER MATERIALIZED VIEW people SET PROPERTIES x = 'y';")

Set multiple view properties \(#raw("foo = 123") and #raw("foo bar = 456")\) in materialized view #raw("people"):

#code-block(none, "ALTER MATERIALIZED VIEW people SET PROPERTIES foo = 123, \"foo bar\" = 456;")

Set view property #raw("x") to its default value in materialized view #raw("people"):

#code-block(none, "ALTER MATERIALIZED VIEW people SET PROPERTIES x = DEFAULT;")

Change owner of materialized view #raw("people") to user #raw("alice"):

#code-block(none, "ALTER MATERIALIZED VIEW people SET AUTHORIZATION alice")

== See also

- create-materialized-view
- refresh-materialized-view
- drop-materialized-view
