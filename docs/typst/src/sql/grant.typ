#import "/lib/trino-docs.typ": *

#anchor("doc-sql-grant")
= GRANT privilege

== Synopsis

#code-block("text", "GRANT ( privilege [, ...] | ( ALL PRIVILEGES ) )
ON [ BRANCH branch_name IN ] ( table_name | TABLE table_name | SCHEMA schema_name)
TO ( user | USER user | ROLE role )
[ WITH GRANT OPTION ]")

== Description

Grants the specified privileges to the specified grantee.

Specifying #raw("ALL PRIVILEGES") grants delete, insert, update and select privileges.

Specifying #raw("ROLE PUBLIC") grants privileges to the #raw("PUBLIC") role and hence to all users.

The optional #raw("WITH GRANT OPTION") clause allows the grantee to grant these same privileges to others.

For #raw("GRANT") statement to succeed, the user executing it should possess the specified privileges as well as the #raw("GRANT OPTION") for those privileges.

Grant on a table grants the specified privilege on all current and future columns of the table.

Grant on a schema grants the specified privilege on all current and future columns of all current and future tables of the schema.

== Examples

Grant #raw("INSERT") and #raw("SELECT") privileges on the table #raw("orders") to user #raw("alice"):

#code-block(none, "GRANT INSERT, SELECT ON orders TO alice;")

Grant #raw("DELETE") privilege on the schema #raw("finance") to user #raw("bob"):

#code-block(none, "GRANT DELETE ON SCHEMA finance TO bob;")

Grant #raw("SELECT") privilege on the table #raw("nation") to user #raw("alice"), additionally allowing #raw("alice") to grant #raw("SELECT") privilege to others:

#code-block(none, "GRANT SELECT ON nation TO alice WITH GRANT OPTION;")

Grant #raw("SELECT") privilege on the table #raw("orders") to everyone:

#code-block(none, "GRANT SELECT ON orders TO ROLE PUBLIC;")

Grant #raw("INSERT") privilege on the #raw("audit") branch of the #raw("orders") table to user #raw("alice"):

#code-block("sql", "GRANT INSERT ON BRANCH audit IN orders TO alice;")

== Limitations

Some connectors have no support for #raw("GRANT"). See connector documentation for more details.

== See also

deny, revoke, show-grants
