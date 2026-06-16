#import "/lib/trino-docs.typ": *

#anchor("doc-sql-drop-view")
= DROP VIEW

== Synopsis

#code-block("text", "DROP VIEW [ IF EXISTS ] view_name")

== Description

Drop an existing view.

The optional #raw("IF EXISTS") clause causes the error to be suppressed if the view does not exist.

== Examples

Drop the view #raw("orders_by_date"):

#code-block(none, "DROP VIEW orders_by_date")

Drop the view #raw("orders_by_date") if it exists:

#code-block(none, "DROP VIEW IF EXISTS orders_by_date")

== See also

create-view
