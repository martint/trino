#import "/lib/trino-docs.typ": *

#anchor("doc-sql-show-role-grants")
= SHOW ROLE GRANTS

== Synopsis

#code-block("text", "SHOW ROLE GRANTS [ FROM catalog ]")

== Description

List non-recursively the system roles or roles in #raw("catalog") that have been granted to the session user.
