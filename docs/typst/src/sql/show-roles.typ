#import "/lib/trino-docs.typ": *

#anchor("doc-sql-show-roles")
= SHOW ROLES

== Synopsis

#code-block("text", "SHOW [CURRENT] ROLES [ FROM catalog ]")

== Description

#raw("SHOW ROLES") lists all the system roles or all the roles in #raw("catalog").

#raw("SHOW CURRENT ROLES") lists the enabled system roles or roles in #raw("catalog").
