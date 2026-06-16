#import "/lib/trino-docs.typ": *

#anchor("doc-sql-grant-roles")
= GRANT role

== Synopsis

#code-block("text", "GRANT role_name [, ...]
TO ( user | USER user_name | ROLE role_name) [, ...]
[ GRANTED BY ( user | USER user | ROLE role | CURRENT_USER | CURRENT_ROLE ) ]
[ WITH ADMIN OPTION ]
[ IN catalog ]")

== Description

Grants the specified role\(s\) to the specified principal\(s\).

If the #raw("WITH ADMIN OPTION") clause is specified, the role\(s\) are granted to the users with #raw("GRANT") option.

For the #raw("GRANT") statement for roles to succeed, the user executing it either should be the role admin or should possess the #raw("GRANT") option for the given role.

The optional #raw("GRANTED BY") clause causes the role\(s\) to be granted with the specified principal as a grantor. If the #raw("GRANTED BY") clause is not specified, the roles are granted with the current user as a grantor.

The optional #raw("IN catalog") clause grants the roles in a catalog as opposed to a system roles.

== Examples

Grant role #raw("bar") to user #raw("foo")

#code-block(none, "GRANT bar TO USER foo;")

Grant roles #raw("bar") and #raw("foo") to user #raw("baz") and role #raw("qux") with admin option

#code-block(none, "GRANT bar, foo TO USER baz, ROLE qux WITH ADMIN OPTION;")

== Limitations

Some connectors do not support role management. See connector documentation for more details.

== See also

create-role, drop-role, set-role, revoke-roles
