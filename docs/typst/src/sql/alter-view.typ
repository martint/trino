#import "/lib/trino-docs.typ": *

#anchor("doc-sql-alter-view")
= ALTER VIEW

== Synopsis

#code-block("text", "ALTER VIEW name RENAME TO new_name
ALTER VIEW name REFRESH
ALTER VIEW name SET AUTHORIZATION ( user | USER user | ROLE role )")

== Description

Change the definition of an existing view.

== Examples

Rename view #raw("people") to #raw("users"):

#code-block(none, "ALTER VIEW people RENAME TO users")

Refresh view #raw("people"):

#code-block(none, "ALTER VIEW people REFRESH")

Change owner of VIEW #raw("people") to user #raw("alice"):

#code-block(none, "ALTER VIEW people SET AUTHORIZATION alice")

== See also

create-view
