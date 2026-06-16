#import "/lib/trino-docs.typ": *

#anchor("doc-sql-drop-table")
= DROP TABLE

== Synopsis

#code-block("text", "DROP TABLE  [ IF EXISTS ] table_name")

== Description

Drops an existing table.

The optional #raw("IF EXISTS") clause causes the error to be suppressed if the table does not exist. The error is not suppressed if a Trino view with the same name exists.

== Examples

Drop the table #raw("orders_by_date"):

#code-block(none, "DROP TABLE orders_by_date")

Drop the table #raw("orders_by_date") if it exists:

#code-block(none, "DROP TABLE IF EXISTS orders_by_date")

== See also

alter-table, create-table
