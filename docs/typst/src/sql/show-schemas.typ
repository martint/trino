#import "/lib/trino-docs.typ": *

#anchor("doc-sql-show-schemas")
= SHOW SCHEMAS

== Synopsis

#code-block("text", "SHOW SCHEMAS [ FROM catalog ] [ LIKE pattern ]")

== Description

List the schemas in #raw("catalog") or in the current catalog.

#link(label("ref-like-operator"))[Specify a pattern] in the optional #raw("LIKE") clause to filter the results to the desired subset. For example, the following query allows you to find schemas that have #raw("3") as the third character:

#code-block(none, "SHOW SCHEMAS FROM tpch LIKE '__3%'")
