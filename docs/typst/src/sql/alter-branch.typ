#import "/lib/trino-docs.typ": *

#anchor("doc-sql-alter-branch")
= ALTER BRANCH

== Synopsis

#code-block("text", "ALTER BRANCH source_branch IN TABLE table_name FAST FORWARD TO target_branch")

== Description

Fast-forward the current snapshot of one branch to the latest snapshot of another.

== Examples

Fast-forward the #raw("main") branch to the head of #raw("audit") branch in the #raw("orders") table:

#code-block("sql", "ALTER BRANCH main IN TABLE orders FAST FORWARD TO audit")

== See also

- create-branch
- drop-branch
