#import "/lib/trino-docs.typ": *

#anchor("doc-sql-create-branch")
= CREATE BRANCH

== Synopsis

#code-block("text", "CREATE [ OR REPLACE ] BRANCH [ IF NOT EXISTS ] branch_name
[ WITH ( property_name = expression [, ...] ) ]
IN TABLE table_name
[ FROM source_branch ]")

== Description

Create a branch.

The optional #raw("OR REPLACE") clause causes an existing branch with the specified name to be replaced with the new branch definition. Support for branch replacement varies across connectors. Refer to the connector documentation for details.

The optional #raw("IF NOT EXISTS") clause causes the error to be suppressed if the branch already exists.

The optional #raw("WITH") clause can be used to set properties on the newly created branch.

The optional #raw("FROM") clause can be used to set the source branch from which the new branch is created.

== Examples

Create a new branch #raw("audit") in the table #raw("orders"):

#code-block("sql", "CREATE BRANCH audit IN TABLE orders")

Create a new branch #raw("audit") in the table #raw("orders") from the branch #raw("dev"):

#code-block("sql", "CREATE BRANCH audit IN TABLE orders FROM dev")

== See also

drop-branch
