#import "/lib/trino-docs.typ": *

#anchor("doc-sql-show-branches")
= SHOW BRANCHES

== Synopsis

#code-block("text", "SHOW BRANCHES ( FROM | IN ) TABLE table_name")

== Description

List the available branches.

== Examples

List the branches in the table #raw("orders"):

#code-block("sql", "SHOW BRANCHES IN TABLE orders")
