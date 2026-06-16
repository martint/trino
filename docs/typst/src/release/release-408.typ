#import "/lib/trino-docs.typ": *

#anchor("doc-release-release-408")
= Release 408 \(23 Feb 2023\)

== General

- Add physical input read time to query statistics and the output of #raw("EXPLAIN ANALYZE"). \(#issue("16190", "https://github.com/trinodb/trino/issues/16190")\)
- Fix query failure for queries involving joins or aggregations with a #link(label("ref-structural-data-types"))[structural type] that contains #raw("NULL") elements. \(#issue("16140", "https://github.com/trinodb/trino/issues/16140")\)

== Security

- Deprecate using groups with OAuth 2.0 authentication, and rename the #raw("http-server.authentication.oauth2.groups-field") configuration property to #raw("deprecated.http-server.authentication.oauth2.groups-field"). \(#issue("15669", "https://github.com/trinodb/trino/issues/15669")\)

== CLI

- Add #raw("AUTO") output format which switches from #raw("ALIGNED") to #raw("VERTICAL") if the output doesn't fit the current terminal. \(#issue("12208", "https://github.com/trinodb/trino/issues/12208")\)
- Add #raw("--pager") and #raw("--history-file") options to match the existing #raw("TRINO_PAGER") and #raw("TRINO_HISTORY_FILE") environmental variables. Also allow setting these options in a configuration file. \(#issue("16151", "https://github.com/trinodb/trino/issues/16151")\)

== BigQuery connector

- Add support for writing #raw("decimal") types to BigQuery. \(#issue("16145", "https://github.com/trinodb/trino/issues/16145")\)

== Delta Lake connector

- Rename the connector to #raw("delta_lake"). The old name #raw("delta-lake") is now deprecated and will be removed in a future release. \(#issue("13931", "https://github.com/trinodb/trino/issues/13931")\)
- Add support for creating tables with the Trino #raw("change_data_feed_enabled") table property. \(#issue("16129", "https://github.com/trinodb/trino/issues/16129")\)
- Improve query performance on tables that Trino has written to with #raw("INSERT"). \(#issue("16026", "https://github.com/trinodb/trino/issues/16026")\)
- Improve performance of reading #link(label("ref-structural-data-types"))[structural types] from Parquet files. This optimization can be disabled with the #raw("parquet_optimized_nested_reader_enabled") catalog session property or the #raw("parquet.optimized-nested-reader.enabled") catalog configuration property. \(#issue("16177", "https://github.com/trinodb/trino/issues/16177")\)
- Retry dropping Delta tables registered in the Glue catalog to avoid failures due to concurrent modifications. \(#issue("13199", "https://github.com/trinodb/trino/issues/13199")\)
- Allow updating the #raw("reader_version") and #raw("writer_version") table properties. \(#issue("15932", "https://github.com/trinodb/trino/issues/15932")\)
- Fix inaccurate change data feed entries for #raw("MERGE") queries. \(#issue("16127", "https://github.com/trinodb/trino/issues/16127")\)
- Fix performance regression when writing to partitioned tables if table statistics are absent. \(#issue("16152", "https://github.com/trinodb/trino/issues/16152")\)

== Hive connector

- Remove support for the deprecated #raw("hive-hadoop2") connector name, requiring the #raw("connector.name") property to be set to #raw("hive"). \(#issue("16166", "https://github.com/trinodb/trino/issues/16166")\)
- Retry dropping Delta tables registered in the Glue catalog to avoid failures due to concurrent modifications. \(#issue("13199", "https://github.com/trinodb/trino/issues/13199")\)
- Fix performance regression when writing to partitioned tables if table statistics are absent. \(#issue("16152", "https://github.com/trinodb/trino/issues/16152")\)

== Iceberg connector

- Reduce memory usage when reading #raw("$files") system tables. \(#issue("15991", "https://github.com/trinodb/trino/issues/15991")\)
- Require the #raw("iceberg.jdbc-catalog.driver-class") configuration property to be set to prevent a "driver not found" error after initialization. \(#issue("16196", "https://github.com/trinodb/trino/issues/16196")\)
- Fix performance regression when writing to partitioned tables if table statistics are absent. \(#issue("16152", "https://github.com/trinodb/trino/issues/16152")\)

== Ignite connector

- Add #link(label("doc-connector-ignite"))[Ignite connector]. \(#issue("8098", "https://github.com/trinodb/trino/issues/8098")\)

== SingleStore connector

- Remove support for the deprecated #raw("memsql") connector name, requiring the #raw("connector.name") property to be set to #raw("singlestore"). \(#issue("16180", "https://github.com/trinodb/trino/issues/16180")\)

== SQL Server connector

- Add support for pushing down #raw("="), #raw("<>") and #raw("IN") predicates over text columns if the column uses a case-sensitive collation within SQL Server. \(#issue("15714", "https://github.com/trinodb/trino/issues/15714")\)

== Thrift connector

- Rename the connector to #raw("trino_thrift"). The old name #raw("trino-thrift") is now deprecated and will be removed in a future release. \(#issue("13931", "https://github.com/trinodb/trino/issues/13931")\)
