#import "/lib/trino-docs.typ": *

#anchor("doc-sql-create-role")
= CREATE ROLE

== Synopsis

#code-block("text", "CREATE ROLE role_name
[ WITH ADMIN ( user | USER user | ROLE role | CURRENT_USER | CURRENT_ROLE ) ]
[ IN catalog ]")

== Description

#raw("CREATE ROLE") creates the specified role.

The optional #raw("WITH ADMIN") clause causes the role to be created with the specified user as a role admin. A role admin has permission to drop or grant a role. If the optional #raw("WITH ADMIN") clause is not specified, the role is created with current user as admin.

The optional #raw("IN catalog") clause creates the role in a catalog as opposed to a system role.

== Examples

Create role #raw("admin")

#code-block(none, "CREATE ROLE admin;")

Create role #raw("moderator") with admin #raw("bob"):

#code-block(none, "CREATE ROLE moderator WITH ADMIN USER bob;")

== Limitations

Some connectors do not support role management. See connector documentation for more details.

== See also

drop-role, set-role, grant-roles, revoke-roles
