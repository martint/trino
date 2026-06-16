#import "/lib/trino-docs.typ": *

#anchor("doc-sql-show-session")
= SHOW SESSION

== Synopsis

#code-block("text", "SHOW SESSION [ LIKE pattern ]")

== Description

List the current #link(label("ref-session-properties-definition"))[session properties].

#link(label("ref-like-operator"))[Specify a pattern] in the optional #raw("LIKE") clause to filter the results to the desired subset. For example, the following query allows you to find session properties that begin with #raw("query"):

#code-block(none, "SHOW SESSION LIKE 'query%'")

== See also

reset-session, set-session
