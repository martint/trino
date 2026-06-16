#import "/lib/trino-docs.typ": *

#anchor("doc-release-release-395")
= Release 395 \(7 Sep 2022\)

== General

- Reduce memory consumption when fault-tolerant execution is enabled. \(#issue("13855", "https://github.com/trinodb/trino/issues/13855")\)
- Reduce memory consumption of aggregations. \(#issue("12512", "https://github.com/trinodb/trino/issues/12512")\)
- Improve performance of aggregations with decimals. \(#issue("13573", "https://github.com/trinodb/trino/issues/13573")\)
- Improve concurrency for large clusters. \(#issue("13934", "https://github.com/trinodb/trino/issues/13934"), #raw("13986")\)
- Remove #raw("information_schema.role_authorization_descriptors") table. \(#issue("11341", "https://github.com/trinodb/trino/issues/11341")\)
- Fix #raw("SHOW CREATE TABLE") or #raw("SHOW COLUMNS") showing an invalid type for columns that use a reserved keyword as column name. \(#issue("13483", "https://github.com/trinodb/trino/issues/13483")\)

== ClickHouse connector

- Fix query failure when renaming or dropping a column with a name which matches a reserved keyword or has special characters which require it to be quoted. \(#issue("13839", "https://github.com/trinodb/trino/issues/13839")\)

== Delta Lake connector

- Add support for the #raw("ALTER TABLE ... RENAME TO") statement with a Glue metastore. \(#issue("12985", "https://github.com/trinodb/trino/issues/12985")\)
- Improve performance of inserts by automatically scaling the number of writers within a worker node. \(#issue("13111", "https://github.com/trinodb/trino/issues/13111")\)
- Enforce #raw("delta.checkpoint.writeStatsAsJson") and #raw("delta.checkpoint.writeStatsAsStruct") table properties to ensure table statistics are written in the correct format. \(#issue("12031", "https://github.com/trinodb/trino/issues/12031")\)

== Hive connector

- Improve performance of inserts by automatically scaling the number of writers within a worker node. \(#issue("13111", "https://github.com/trinodb/trino/issues/13111")\)
- Improve performance of S3 Select when using CSV files as an input. \(#issue("13754", "https://github.com/trinodb/trino/issues/13754")\)
- Fix error where the S3 KMS key is not searched in the proper AWS region when S3 client-side encryption is used. \(#issue("13715", "https://github.com/trinodb/trino/issues/13715")\)

== Iceberg connector

- Improve performance of inserts by automatically scaling the number of writers within a worker node. \(#issue("13111", "https://github.com/trinodb/trino/issues/13111")\)
- Fix creating metadata and manifest files with a URL-encoded name on S3 when the metadata location has trailing slashes. \(#issue("13759", "https://github.com/trinodb/trino/issues/13759")\)

== MariaDB connector

- Fix query failure when renaming or dropping a column with a name which matches a reserved keyword or has special characters which require it to be quoted. \(#issue("13839", "https://github.com/trinodb/trino/issues/13839")\)

== Memory connector

- Add support for table and column comments. \(#issue("13936", "https://github.com/trinodb/trino/issues/13936")\)

== MongoDB connector

- Fix query failure when filtering on columns of #raw("json") type. \(#issue("13536", "https://github.com/trinodb/trino/issues/13536")\)

== MySQL connector

- Fix query failure when renaming or dropping a column with a name which matches a reserved keyword or has special characters which require it to be quoted. \(#issue("13839", "https://github.com/trinodb/trino/issues/13839")\)

== Oracle connector

- Fix query failure when renaming or dropping a column with a name which matches a reserved keyword or has special characters which require it to be quoted. \(#issue("13839", "https://github.com/trinodb/trino/issues/13839")\)

== Phoenix connector

- Fix query failure when adding, renaming, or dropping a column with a name which matches a reserved keyword or has special characters which require it to be quoted. \(#issue("13839", "https://github.com/trinodb/trino/issues/13839")\)

== PostgreSQL connector

- Fix query failure when renaming or dropping a column with a name which matches a reserved keyword or has special characters which require it to be quoted. \(#issue("13839", "https://github.com/trinodb/trino/issues/13839")\)

== Prometheus connector

- Add support for case-insensitive table name matching with the #raw("prometheus.case-insensitive-name-matching") configuration property. \(#issue("8740", "https://github.com/trinodb/trino/issues/8740")\)

== Redshift connector

- Fix query failure when renaming or dropping a column with a name which matches a reserved keyword or has special characters which require it to be quoted. \(#issue("13839", "https://github.com/trinodb/trino/issues/13839")\)

== SingleStore \(MemSQL\) connector

- Fix query failure when renaming or dropping a column with a name which matches a reserved keyword or has special characters which require it to be quoted. \(#issue("13839", "https://github.com/trinodb/trino/issues/13839")\)

== SQL Server connector

- Fix query failure when renaming or dropping a column with a name which matches a reserved keyword or has special characters which require it to be quoted. \(#issue("13839", "https://github.com/trinodb/trino/issues/13839")\)

== SPI

- Add support for dynamic function resolution. \(#issue("8", "https://github.com/trinodb/trino/issues/8")\)
- Rename #raw("LIKE_PATTERN_FUNCTION_NAME") to #raw("LIKE_FUNCTION_NAME") in #raw("StandardFunctions"). \(#issue("13965", "https://github.com/trinodb/trino/issues/13965")\)
- Remove the #raw("listAllRoleGrants") method from #raw("ConnectorMetadata"). \(#issue("11341", "https://github.com/trinodb/trino/issues/11341")\)
