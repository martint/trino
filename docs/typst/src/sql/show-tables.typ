#import "/lib/trino-docs.typ": *

#anchor("doc-sql-show-tables")
= SHOW TABLES

== Synopsis

#code-block("text", "SHOW TABLES [ FROM schema ] [ LIKE pattern ]")

== Description

List the tables and views in the current schema, for example set with #link(label("doc-sql-use"))[USE] or by a client connection.

Use a fully qualified path to a schema in the form of #raw("catalog_name.schema_name") to specify any schema in any catalog in the #raw("FROM") clause.

#link(label("ref-like-operator"))[Specify a pattern] in the optional #raw("LIKE") clause to filter the results to the desired subset.

== Examples

The following query lists tables and views that begin with #raw("p") in the #raw("tiny") schema of the #raw("tpch") catalog:

#code-block("sql", "SHOW TABLES FROM tpch.tiny LIKE 'p%';")

== See also

- #link(label("ref-sql-schema-table-management"))[SQL statement support]
- #link(label("ref-sql-view-management"))[SQL statement support]
