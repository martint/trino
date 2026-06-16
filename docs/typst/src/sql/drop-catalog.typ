#import "/lib/trino-docs.typ": *

#anchor("doc-sql-drop-catalog")
= DROP CATALOG

== Synopsis

#code-block("text", "DROP CATALOG catalog_name")

== Description

Drops an existing catalog. Dropping a catalog does not interrupt any running queries that use it, but makes it unavailable to any new queries.

#warning[
Some connectors are known not to release all resources when dropping a catalog that uses such connector. This includes all connectors that can read data from HDFS, S3, GCS, or Azure, which are #link(label("doc-connector-hive"))[Hive connector], #link(label("doc-connector-iceberg"))[Iceberg connector], #link(label("doc-connector-delta-lake"))[Delta Lake connector], and #link(label("doc-connector-hudi"))[Hudi connector].
]

#note[
This command requires the #link(label("doc-admin-properties-catalog"))[catalog management type] to be set to #raw("dynamic").
]

== Examples

Drop the catalog #raw("example"):

#code-block(none, "DROP CATALOG example;")

== See also

- #link(label("doc-sql-create-catalog"))[CREATE CATALOG]
- #link(label("doc-admin-properties-catalog"))[Catalog management properties]
