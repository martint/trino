#import "/lib/trino-docs.typ": *

#anchor("doc-sql-drop-materialized-view")
= DROP MATERIALIZED VIEW

== Synopsis

#code-block("text", "DROP MATERIALIZED VIEW [ IF EXISTS ] view_name")

== Description

Drop an existing materialized view #raw("view_name").

The optional #raw("IF EXISTS") clause causes the error to be suppressed if the materialized view does not exist.

== Examples

Drop the materialized view #raw("orders_by_date"):

#code-block(none, "DROP MATERIALIZED VIEW orders_by_date;")

Drop the materialized view #raw("orders_by_date") if it exists:

#code-block(none, "DROP MATERIALIZED VIEW IF EXISTS orders_by_date;")

== See also

- create-materialized-view
- show-create-materialized-view
- refresh-materialized-view
