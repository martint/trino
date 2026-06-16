#import "/lib/trino-docs.typ": *

#anchor("doc-sql-rollback")
= ROLLBACK

== Synopsis

#code-block("text", "ROLLBACK [ WORK ]")

== Description

Rollback the current transaction.

== Examples

#code-block("sql", "ROLLBACK;
ROLLBACK WORK;")

== See also

commit, start-transaction
