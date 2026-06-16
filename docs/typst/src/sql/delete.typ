#import "/lib/trino-docs.typ": *

#anchor("doc-sql-delete")
= DELETE

== Synopsis

#code-block("text", "DELETE FROM table_name [ @ branch_name ] [ WHERE condition ]")

== Description

Delete rows from a table. If the #raw("WHERE") clause is specified, only the matching rows are deleted. Otherwise, all rows from the table are deleted.

== Examples

Delete all line items shipped by air:

#code-block(none, "DELETE FROM lineitem WHERE shipmode = 'AIR';")

Delete all line items for low priority orders:

#code-block(none, "DELETE FROM lineitem
WHERE orderkey IN (SELECT orderkey FROM orders WHERE priority = 'LOW');")

Delete all orders:

#code-block(none, "DELETE FROM orders;")

Delete all orders in the #raw("audit") branch:

#code-block("sql", "DELETE FROM orders @ audit;")

== Limitations

Some connectors have limited or no support for #raw("DELETE"). See connector documentation for more details.
