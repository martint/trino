#import "/lib/trino-docs.typ": *

#anchor("doc-sql-deny")
= DENY

== Synopsis

#code-block("text", "DENY ( privilege [, ...] | ( ALL PRIVILEGES ) )
ON [ BRANCH branch_name IN ] ( table_name | TABLE table_name | SCHEMA schema_name)
TO ( user | USER user | ROLE role )")

== Description

Denies the specified privileges to the specified grantee.

Deny on a table rejects the specified privilege on all current and future columns of the table.

Deny on a schema rejects the specified privilege on all current and future columns of all current and future tables of the schema.

== Examples

Deny #raw("INSERT") and #raw("SELECT") privileges on the table #raw("orders") to user #raw("alice"):

#code-block(none, "DENY INSERT, SELECT ON orders TO alice;")

Deny #raw("DELETE") privilege on the schema #raw("finance") to user #raw("bob"):

#code-block(none, "DENY DELETE ON SCHEMA finance TO bob;")

Deny #raw("SELECT") privilege on the table #raw("orders") to everyone:

#code-block(none, "DENY SELECT ON orders TO ROLE PUBLIC;")

Deny #raw("INSERT") privilege on the #raw("audit") branch of the #raw("orders") table to user #raw("alice"):

#code-block("sql", "DENY INSERT ON BRANCH audit IN orders TO alice;")

== Limitations

The system access controls as well as the connectors provided by default in Trino have no support for #raw("DENY").

== See also

grant, revoke, show-grants
