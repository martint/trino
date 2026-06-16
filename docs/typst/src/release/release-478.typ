#import "/lib/trino-docs.typ": *

#anchor("doc-release-release-478")
= Release 478 \(29 Oct 2025\)

== General

- Include lineage information for columns used in #raw("UNNEST") expressions. \(#issue("16946", "https://github.com/trinodb/trino/issues/16946")\)
- Add support for limiting which retry policies a user can select. This can be configured using the #raw("retry-policy.allowed") option. \(#issue("26628", "https://github.com/trinodb/trino/issues/26628")\)
- Add support for loading plugins from multiple directories. \(#issue("26855", "https://github.com/trinodb/trino/issues/26855")\)
- Allow dropping catalogs that failed to load correctly. \(#issue("26918", "https://github.com/trinodb/trino/issues/26918")\)
- Improve performance of queries with an #raw("ORDER BY") clause using #raw("varchar") or #raw("varbinary") types. \(#issue("26725", "https://github.com/trinodb/trino/issues/26725")\)
- Improve performance of #raw("MERGE") statements involving a #raw("NOT MATCHED") case. \(#issue("26759", "https://github.com/trinodb/trino/issues/26759")\)
- Improve performance of queries involving #raw("JOIN") when the join spills to disk. \(#issue("26076", "https://github.com/trinodb/trino/issues/26076")\)
- Fix potential incorrect results when query uses #raw("row") type. \(#issue("26806", "https://github.com/trinodb/trino/issues/26806")\)
- Include catalogs that failed to load in the #raw("metadata.catalogs") table. \(#issue("26918", "https://github.com/trinodb/trino/issues/26918")\)
- Fix #raw("EXPLAIN ANALYZE") planning so that it executes with the same plan as would be used to execute the query being analyzed. \(#issue("26938", "https://github.com/trinodb/trino/issues/26938")\)
- Fix incorrect results when using logical navigation function #raw("FIRST") in row pattern recognition. \(#issue("26981", "https://github.com/trinodb/trino/issues/26981")\)

== Security

- Propagate #raw("queryId") to the #link(label("doc-security-opa-access-control"))[Open Policy Agent] authorizer. \(#issue("26851", "https://github.com/trinodb/trino/issues/26851")\)

== Docker image

- Run Trino on JDK 25.0.0 \(build 36\). \(#issue("26693", "https://github.com/trinodb/trino/issues/26693")\)

== Delta Lake connector

- Fix failure when reading a #raw("map(..., json)") column when the map item value is #raw("NULL"). \(#issue("26700", "https://github.com/trinodb/trino/issues/26700")\)
- Deprecate the #raw("gcs.use-access-token") configuration property. Use #raw("gcs.auth-type") instead. \(#issue("26681", "https://github.com/trinodb/trino/issues/26681")\)

== Google Sheets connector

- Fix potential query failure when the #raw("gsheets.delegated-user-email") configuration property is used. \(#issue("26501", "https://github.com/trinodb/trino/issues/26501")\)

== Hive connector

- Add support for reading encrypted Parquet files. \(#issue("24517", "https://github.com/trinodb/trino/issues/24517"), #issue("9383", "https://github.com/trinodb/trino/issues/9383")\)
- Deprecate the #raw("gcs.use-access-token") configuration property. Use #raw("gcs.auth-type") instead. \(#issue("26681", "https://github.com/trinodb/trino/issues/26681")\)
- Improve performance of queries using complex predicates on #raw("$path") column. \(#issue("27000", "https://github.com/trinodb/trino/issues/27000")\)
- Fix writing ORC files to ensure that dates and timestamps before #raw("1582-10-15") are read correctly by Apache Hive. \(#issue("26507", "https://github.com/trinodb/trino/issues/26507")\)
- Fix #raw("flush_metadata_cache") procedure failure when metastore impersonation is enabled. \(#issue("27059", "https://github.com/trinodb/trino/issues/27059")\)

== Hudi connector

- Deprecate the #raw("gcs.use-access-token") configuration property. Use #raw("gcs.auth-type") instead. \(#issue("26681", "https://github.com/trinodb/trino/issues/26681")\)

== Iceberg connector

- Improve performance when writing sorted tables and #raw("iceberg.sorted-writing.local-staging-path") is set. \(#issue("24376", "https://github.com/trinodb/trino/issues/24376")\)
- Improve performance of #raw("ALTER TABLE EXECUTE OPTIMIZE") on tables with bucket transform partitioning. \(#issue("27104", "https://github.com/trinodb/trino/issues/27104")\)
- Return execution metrics while running the #raw("remove_orphan_files") command. \(#issue("26661", "https://github.com/trinodb/trino/issues/26661")\)
- Deprecate the #raw("gcs.use-access-token") configuration property. Use #raw("gcs.auth-type") instead. \(#issue("26681", "https://github.com/trinodb/trino/issues/26681")\)
- Collect distinct values count on all columns when replacing tables. \(#issue("26983", "https://github.com/trinodb/trino/issues/26983")\)
- Fix failure due to column count mismatch when executing the #raw("add_files_from_table") procedure. \(#issue("26774", "https://github.com/trinodb/trino/issues/26774")\)
- Fix failure when executing #raw("optimize_manifests") on tables without a snapshot. \(#issue("26970", "https://github.com/trinodb/trino/issues/26970")\)
- Fix incorrect results when reading Avro files migrated from Hive. \(#issue("26863", "https://github.com/trinodb/trino/issues/26863")\)
- Fix failure when executing #raw("SHOW CREATE SCHEMA") on a schema with unsupported properties with REST, Glue or Nessie catalog. \(#issue("24744", "https://github.com/trinodb/trino/issues/24744")\)
- Fix failure when running #raw("EXPLAIN") or #raw("EXPLAIN ANALYZE") on #raw("OPTIMIZE") command. \(#issue("26598", "https://github.com/trinodb/trino/issues/26598")\)

== Kafka connector

- Fix failure when filtering partitions by timestamp offset. \(#issue("26787", "https://github.com/trinodb/trino/issues/26787")\)

== SPI

- Remove default implementation from #raw("Connector.shutdown()"). \(#issue("26718", "https://github.com/trinodb/trino/issues/26718")\)
- Remove the deprecated #raw("ConnectorSplit.getSplitInfo") method. \(#issue("27063", "https://github.com/trinodb/trino/issues/27063")\)
- Deprecate #raw("io.trino.spi.type.Type#appendTo") method. \(#issue("26922", "https://github.com/trinodb/trino/issues/26922")\)
