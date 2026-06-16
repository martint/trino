#import "/lib/trino-docs.typ": *

#anchor("doc-sql-truncate")
= TRUNCATE

== Synopsis

#code-block("none", "TRUNCATE TABLE table_name")

== Description

Delete all rows from a table.

== Examples

Truncate the table #raw("orders"):

#code-block(none, "TRUNCATE TABLE orders;")
