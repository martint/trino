#import "/lib/trino-docs.typ": *

#anchor("doc-sql-drop-branch")
= DROP BRANCH

== Synopsis

#code-block("text", "DROP BRANCH [ IF EXISTS ] branch_name
IN TABLE table_name")

== Description

Drops an existing branch.

The optional #raw("IF EXISTS") clause causes the error to be suppressed if the branch does not exist.

== Examples

Drop the branch #raw("audit") in the table #raw("orders"):

#code-block("sql", "DROP BRANCH audit IN TABLE orders")

== See also

create-branch
