#import "/lib/trino-docs.typ": *

#anchor("doc-sql-set-role")
= SET ROLE

== Synopsis

#code-block("text", "SET ROLE ( role | ALL | NONE )
[ IN catalog ]")

== Description

#raw("SET ROLE") sets the enabled role for the current session.

#raw("SET ROLE role") enables a single specified role for the current session. For the #raw("SET ROLE role") statement to succeed, the user executing it should have a grant for the given role.

#raw("SET ROLE ALL") enables all roles that the current user has been granted for the current session.

#raw("SET ROLE NONE") disables all the roles granted to the current user for the current session.

The optional #raw("IN catalog") clause sets the role in a catalog as opposed to a system role.

== Limitations

Some connectors do not support role management. See connector documentation for more details.

== See also

create-role, drop-role, grant-roles, revoke-roles
