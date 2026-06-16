#import "/lib/trino-docs.typ": *

#anchor("doc-sql-drop-role")
= DROP ROLE

== Synopsis

#code-block("text", "DROP ROLE [ IF EXISTS ] role_name
[ IN catalog ]")

== Description

#raw("DROP ROLE") drops the specified role.

For #raw("DROP ROLE") statement to succeed, the user executing it should possess admin privileges for the given role.

The optional #raw("IF EXISTS") prevents the statement from failing if the role isn't found.

The optional #raw("IN catalog") clause drops the role in a catalog as opposed to a system role.

== Examples

Drop role #raw("admin")

#code-block(none, "DROP ROLE admin;")

== Limitations

Some connectors do not support role management. See connector documentation for more details.

== See also

create-role, set-role, grant-roles, revoke-roles
