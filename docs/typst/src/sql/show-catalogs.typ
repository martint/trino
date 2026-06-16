#import "/lib/trino-docs.typ": *

#anchor("doc-sql-show-catalogs")
= SHOW CATALOGS

== Synopsis

#code-block("text", "SHOW CATALOGS [ LIKE pattern ]")

== Description

List the available catalogs.

#link(label("ref-like-operator"))[Specify a pattern] in the optional #raw("LIKE") clause to filter the results to the desired subset. For example, the following query allows you to find catalogs that begin with #raw("t"):

#code-block(none, "SHOW CATALOGS LIKE 't%'")
