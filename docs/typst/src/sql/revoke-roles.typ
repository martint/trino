#import "/lib/trino-docs.typ": *

#anchor("doc-sql-revoke-roles")
= REVOKE role

== Synopsis

#code-block("text", "REVOKE
[ ADMIN OPTION FOR ]
role_name [, ...]
FROM ( user | USER user | ROLE role) [, ...]
[ GRANTED BY ( user | USER user | ROLE role | CURRENT_USER | CURRENT_ROLE ) ]
[ IN catalog ]")

== Description

Revokes the specified role\(s\) from the specified principal\(s\).

If the #raw("ADMIN OPTION FOR") clause is specified, the #raw("GRANT") permission is revoked instead of the role.

For the #raw("REVOKE") statement for roles to succeed, the user executing it either should be the role admin or should possess the #raw("GRANT") option for the given role.

The optional #raw("GRANTED BY") clause causes the role\(s\) to be revoked with the specified principal as a revoker. If the #raw("GRANTED BY") clause is not specified, the roles are revoked by the current user as a revoker.

The optional #raw("IN catalog") clause revokes the roles in a catalog as opposed to a system roles.

== Examples

Revoke role #raw("bar") from user #raw("foo")

#code-block(none, "REVOKE bar FROM USER foo;")

Revoke admin option for roles #raw("bar") and #raw("foo") from user #raw("baz") and role #raw("qux")

#code-block(none, "REVOKE ADMIN OPTION FOR bar, foo FROM USER baz, ROLE qux;")

== Limitations

Some connectors do not support role management. See connector documentation for more details.

== See also

create-role, drop-role, set-role, grant-roles
