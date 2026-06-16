#import "/lib/trino-docs.typ": *

#anchor("doc-sql-set-session-authorization")
= SET SESSION AUTHORIZATION

== Synopsis

#code-block("text", "SET SESSION AUTHORIZATION username")

== Description

Changes the current user of the session. For the #raw("SET SESSION AUTHORIZATION username") statement to succeed, the original user \(that the client connected with\) must be able to impersonate the specified user. User impersonation can be enabled in the system access control.

== Examples

In the following example, the original user when the connection to Trino is made is Kevin. The following sets the session authorization user to John:

#code-block("sql", "SET SESSION AUTHORIZATION 'John';")

Queries will now execute as John instead of Kevin.

All supported syntax to change the session authorization users are shown below.

Changing the session authorization with single quotes:

#code-block("sql", "SET SESSION AUTHORIZATION 'John';")

Changing the session authorization with double quotes:

#code-block("sql", "SET SESSION AUTHORIZATION \"John\";")

Changing the session authorization without quotes:

#code-block("sql", "SET SESSION AUTHORIZATION John;")

== See also

reset-session-authorization
