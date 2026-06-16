#import "/lib/trino-docs.typ": *

#anchor("doc-sql-deallocate-prepare")
= DEALLOCATE PREPARE

== Synopsis

#code-block("text", "DEALLOCATE PREPARE statement_name")

== Description

Removes a statement with the name #raw("statement_name") from the list of prepared statements in a session.

== Examples

Deallocate a statement with the name #raw("my_query"):

#code-block(none, "DEALLOCATE PREPARE my_query;")

== See also

prepare, execute, execute-immediate
