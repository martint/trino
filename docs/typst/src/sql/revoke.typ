#import "/lib/trino-docs.typ": *

#anchor("doc-sql-revoke")
= REVOKE privilege

== Synopsis

#code-block("text", "REVOKE [ GRANT OPTION FOR ]
( privilege [, ...] | ALL PRIVILEGES )
ON [ BRANCH branch_name IN ] ( table_name | TABLE table_name | SCHEMA schema_name )
FROM ( user | USER user | ROLE role )")

== Description

Revokes the specified privileges from the specified grantee.

Specifying #raw("ALL PRIVILEGES") revokes delete, insert and select privileges.

Specifying #raw("ROLE PUBLIC") revokes privileges from the #raw("PUBLIC") role. Users will retain privileges assigned to them directly or via other roles.

If the optional #raw("GRANT OPTION FOR") clause is specified, only the #raw("GRANT OPTION") is removed. Otherwise, both the #raw("GRANT") and #raw("GRANT OPTION") are revoked.

For #raw("REVOKE") statement to succeed, the user executing it should possess the specified privileges as well as the #raw("GRANT OPTION") for those privileges.

Revoke on a table revokes the specified privilege on all columns of the table.

Revoke on a schema revokes the specified privilege on all columns of all tables of the schema.

== Examples

Revoke #raw("INSERT") and #raw("SELECT") privileges on the table #raw("orders") from user #raw("alice"):

#code-block(none, "REVOKE INSERT, SELECT ON orders FROM alice;")

Revoke #raw("DELETE") privilege on the schema #raw("finance") from user #raw("bob"):

#code-block(none, "REVOKE DELETE ON SCHEMA finance FROM bob;")

Revoke #raw("SELECT") privilege on the table #raw("nation") from everyone, additionally revoking the privilege to grant #raw("SELECT") privilege:

#code-block(none, "REVOKE GRANT OPTION FOR SELECT ON nation FROM ROLE PUBLIC;")

Revoke all privileges on the table #raw("test") from user #raw("alice"):

#code-block(none, "REVOKE ALL PRIVILEGES ON test FROM alice;")

Revoke #raw("INSERT") privilege on the #raw("audit") branch of the #raw("orders") table from user #raw("alice"):

#code-block("sql", "REVOKE INSERT ON BRANCH audit IN orders FROM alice;")

== Limitations

Some connectors have no support for #raw("REVOKE"). See connector documentation for more details.

== See also

deny, grant, show-grants
