#import "/lib/trino-docs.typ": *

#anchor("doc-release-release-469")
= Release 469 \(27 Jan 2025\)

== General

- Add support for the #raw("FIRST"), #raw("AFTER"), and #raw("LAST") clauses to #raw("ALTER TABLE ... ADD COLUMN"). \(#issue("20091", "https://github.com/trinodb/trino/issues/20091")\)
- Add the #link(label("fn-st-geomfromkml"), raw("ST_GeomFromKML")) function. \(#issue("24297", "https://github.com/trinodb/trino/issues/24297")\)
- Allow configuring the spooling client protocol behaviour with session properties. \(#issue("24655", "https://github.com/trinodb/trino/issues/24655"), #issue("24757", "https://github.com/trinodb/trino/issues/24757")\)
- Improve stability of the cluster under load. \(#issue("24572", "https://github.com/trinodb/trino/issues/24572")\)
- Prevent planning failures resulting from join pushdown for modified tables. \(#issue("24447", "https://github.com/trinodb/trino/issues/24447")\)
- Fix parsing of negative hexadecimal, octal, and binary numeric literals. \(#issue("24601", "https://github.com/trinodb/trino/issues/24601")\)
- Fix failures with recursive delete operations on S3Express preventing usage for fault-tolerant execution. \(#issue("24763", "https://github.com/trinodb/trino/issues/24763")\)

== Web UI

- Add support for filtering queries by client tags. \(#issue("24494", "https://github.com/trinodb/trino/issues/24494")\)

== JDBC driver

- Add #raw("planningTimeMillis"), #raw("analysisTimeMillis"), #raw("finishingTimeMillis"), #raw("physicalInputBytes"), #raw("physicalWrittenBytes"), #raw("internalNetworkInputBytes") and #raw("physicalInputTimeMillis") to #raw("io.trino.jdbc.QueryStats"). \(#issue("24571", "https://github.com/trinodb/trino/issues/24571"), #issue("24604", "https://github.com/trinodb/trino/issues/24604")\)
- Improve the #raw("Connection.isValid(int)") method so it validates the connection and credentials, and add the #raw("validateConnection") connection property. \(#issue("24127", "https://github.com/trinodb/trino/issues/24127"), #issue("22684", "https://github.com/trinodb/trino/issues/22684")\)
- Prevent failures when using the spooling protocol with a cluster using its own certificate chain. \(#issue("24595", "https://github.com/trinodb/trino/issues/24595")\)
- Fix deserialization failures with #raw("SetDigest"), #raw("BingTile"), and #raw("Color") types. \(#issue("24612", "https://github.com/trinodb/trino/issues/24612")\)

== CLI

- Prevent failures when using the spooling protocol with a cluster using its own certificate chain. \(#issue("24595", "https://github.com/trinodb/trino/issues/24595")\)
- Fix deserialization of #raw("SetDigest"), #raw("BingTile"), and #raw("Color") types. \(#issue("24612", "https://github.com/trinodb/trino/issues/24612")\)

== BigQuery connector

- Allow configuration of the channel pool for gRPC communication with BigQuery. \(#issue("24638", "https://github.com/trinodb/trino/issues/24638")\)

== ClickHouse connector

- #breaking-marker("../release.html#breaking-changes") Raise minimum required versions to ClickHouse 24.3 and Altinity 22.3. \(#issue("24515", "https://github.com/trinodb/trino/issues/24515")\)
- Fix failure when updating values to #raw("NULL"). \(#issue("24204", "https://github.com/trinodb/trino/issues/24204")\)

== Delta Lake connector

- Add support for SSE-C in S3 security mapping. \(#issue("24566", "https://github.com/trinodb/trino/issues/24566")\)
- Allow configuring the endpoint for the Google Storage file system with the #raw("gcs.endpoint") property. \(#issue("24626", "https://github.com/trinodb/trino/issues/24626")\)
- Improve performance of reading from new Delta Lake table data by compressing files with #raw("ZSTD") by default, instead of the previous #raw("SNAPPY"). \(#issue("17426", "https://github.com/trinodb/trino/issues/17426")\)
- Improve performance of queries on tables with large transaction log JSON files. \(#issue("24491", "https://github.com/trinodb/trino/issues/24491")\)
- Improve performance of reading from Parquet files with a large number of row groups. \(#issue("24618", "https://github.com/trinodb/trino/issues/24618")\)
- Improve performance for the #raw("OPTIMIZE") statement by enabling concurrent execution. \(#issue("16985", "https://github.com/trinodb/trino/issues/16985")\)
- Improve performance of reading from large files on S3. \(#issue("24521", "https://github.com/trinodb/trino/issues/24521")\)
- Correct catalog information in JMX metrics when using file system caching with multiple catalogs. \(#issue("24510", "https://github.com/trinodb/trino/issues/24510")\)
- Fix table read failures when using the Alluxio file system. \(#issue("23815", "https://github.com/trinodb/trino/issues/23815")\)
- Fix incorrect results when updating tables with deletion vectors enabled. \(#issue("24648", "https://github.com/trinodb/trino/issues/24648")\)
- Fix incorrect results when reading from tables with deletion vectors enabled. \(#issue("22972", "https://github.com/trinodb/trino/issues/22972")\)

== Elasticsearch connector

- Improve performance of queries that reference nested fields from Elasticsearch documents. \(#issue("23069", "https://github.com/trinodb/trino/issues/23069")\)

== Faker connector

- Add support for views. \(#issue("24242", "https://github.com/trinodb/trino/issues/24242")\)
- Support generating sequences. \(#issue("24590", "https://github.com/trinodb/trino/issues/24590")\)
- #breaking-marker("../release.html#breaking-changes") Replace specifying constraints using #raw("WHERE") clauses with the #raw("min"), #raw("max"), and #raw("options") column properties. \(#issue("24147", "https://github.com/trinodb/trino/issues/24147")\)

== Hive connector

- Add support for SSE-C in S3 security mapping. \(#issue("24566", "https://github.com/trinodb/trino/issues/24566")\)
- Allow configuring the endpoint for the Google Storage file system with the #raw("gcs.endpoint") property. \(#issue("24626", "https://github.com/trinodb/trino/issues/24626")\)
- Split AWS SDK client retry count metrics into separate client-level, logical retries and lower-level HTTP client retries. \(#issue("24606", "https://github.com/trinodb/trino/issues/24606")\)
- Improve performance of reading from Parquet files with a large number of row groups. \(#issue("24618", "https://github.com/trinodb/trino/issues/24618")\)
- Improve performance of reading from large files on S3. \(#issue("24521", "https://github.com/trinodb/trino/issues/24521")\)
- Correct catalog information in JMX metrics when using file system caching with multiple catalogs. \(#issue("24510", "https://github.com/trinodb/trino/issues/24510")\)
- Fix table read failures when using the Alluxio file system. \(#issue("23815", "https://github.com/trinodb/trino/issues/23815")\)
- Prevent writing of invalid data for NaN, Infinity, -Infinity values to JSON files. \(#issue("24558", "https://github.com/trinodb/trino/issues/24558")\)

== Hudi connector

- Add support for SSE-C in S3 security mapping. \(#issue("24566", "https://github.com/trinodb/trino/issues/24566")\)
- Allow configuring the endpoint for the Google Storage file system with the #raw("gcs.endpoint") property. \(#issue("24626", "https://github.com/trinodb/trino/issues/24626")\)
- Improve performance of reading from Parquet files with a large number of row groups. \(#issue("24618", "https://github.com/trinodb/trino/issues/24618")\)
- Improve performance of reading from large files on S3. \(#issue("24521", "https://github.com/trinodb/trino/issues/24521")\)

== Iceberg connector

- Add support for the #raw("FIRST"), #raw("AFTER"), and #raw("LAST") clauses to #raw("ALTER TABLE ... ADD COLUMN"). \(#issue("20091", "https://github.com/trinodb/trino/issues/20091")\)
- Add support for SSE-C in S3 security mapping. \(#issue("24566", "https://github.com/trinodb/trino/issues/24566")\)
- Allow configuring the endpoint for the Google Storage file system with the #raw("gcs.endpoint") property. \(#issue("24626", "https://github.com/trinodb/trino/issues/24626")\)
- Add #raw("$entries") metadata table. \(#issue("24172", "https://github.com/trinodb/trino/issues/24172")\)
- Add #raw("$all_entries") metadata table. \(#issue("24543", "https://github.com/trinodb/trino/issues/24543")\)
- Allow configuring the #raw("parquet_bloom_filter_columns") table property. \(#issue("24573", "https://github.com/trinodb/trino/issues/24573")\)
- Allow configuring the #raw("orc_bloom_filter_columns") table property. \(#issue("24584", "https://github.com/trinodb/trino/issues/24584")\)
- Add the #raw("rollback_to_snapshot") table procedure. The existing #raw("system.rollback_to_snapshot") procedure is deprecated. \(#issue("24580", "https://github.com/trinodb/trino/issues/24580")\)
- Improve performance when listing columns. \(#issue("23909", "https://github.com/trinodb/trino/issues/23909")\)
- Improve performance of reading from Parquet files with a large number of row groups. \(#issue("24618", "https://github.com/trinodb/trino/issues/24618")\)
- Improve performance of reading from large files on S3. \(#issue("24521", "https://github.com/trinodb/trino/issues/24521")\)
- Remove the oldest tracked version metadata files when #raw("write.metadata.delete-after-commit.enabled") is set to #raw("true"). \(#issue("19582", "https://github.com/trinodb/trino/issues/19582")\)
- Correct catalog information in JMX metrics when using file system caching with multiple catalogs. \(#issue("24510", "https://github.com/trinodb/trino/issues/24510")\)
- Fix table read failures when using the Alluxio file system. \(#issue("23815", "https://github.com/trinodb/trino/issues/23815")\)
- Prevent return of incomplete results by the #raw("table_changes") table function. \(#issue("24709", "https://github.com/trinodb/trino/issues/24709")\)
- Prevent failures on queries accessing tables with multiple nested partition columns. \(#issue("24628", "https://github.com/trinodb/trino/issues/24628")\)

== Ignite connector

- Add support for #raw("MERGE") statements. \(#issue("24443", "https://github.com/trinodb/trino/issues/24443")\)
- Fix failure when updating values to #raw("NULL"). \(#issue("24204", "https://github.com/trinodb/trino/issues/24204")\)

== Kudu connector

- Add support for unpartitioned tables. \(#issue("24661", "https://github.com/trinodb/trino/issues/24661")\)

== MariaDB connector

- Add support for the #raw("FIRST"), #raw("AFTER"), and #raw("LAST") clauses to #raw("ALTER TABLE ... ADD COLUMN"). \(#issue("24735", "https://github.com/trinodb/trino/issues/24735")\)
- Fix failure when updating values to #raw("NULL"). \(#issue("24204", "https://github.com/trinodb/trino/issues/24204")\)

== MySQL connector

- Add support for the #raw("FIRST"), #raw("AFTER"), and #raw("LAST") clauses to #raw("ALTER TABLE ... ADD COLUMN"). \(#issue("24735", "https://github.com/trinodb/trino/issues/24735")\)
- Fix failure when updating values to #raw("NULL"). \(#issue("24204", "https://github.com/trinodb/trino/issues/24204")\)

== Oracle connector

- Fix failure when updating values to #raw("NULL"). \(#issue("24204", "https://github.com/trinodb/trino/issues/24204")\)

== Phoenix connector

- Allow configuring scan page timeout with the #raw("phoenix.server-scan-page-timeout") configuration property. \(#issue("24689", "https://github.com/trinodb/trino/issues/24689")\)
- Fix failure when updating values to #raw("NULL"). \(#issue("24204", "https://github.com/trinodb/trino/issues/24204")\)

== PostgreSQL connector

- Fix failure when updating values to #raw("NULL"). \(#issue("24204", "https://github.com/trinodb/trino/issues/24204")\)

== Redshift connector

- Improve performance of reading from Redshift tables. \(#issue("24117", "https://github.com/trinodb/trino/issues/24117")\)
- Fix failure when updating values to #raw("NULL"). \(#issue("24204", "https://github.com/trinodb/trino/issues/24204")\)

== SingleStore connector

- Fix failure when updating values to #raw("NULL"). \(#issue("24204", "https://github.com/trinodb/trino/issues/24204")\)

== Snowflake connector

- Fix failure when updating values to #raw("NULL"). \(#issue("24204", "https://github.com/trinodb/trino/issues/24204")\)

== SQL Server connector

- Fix failure when updating values to #raw("NULL"). \(#issue("24204", "https://github.com/trinodb/trino/issues/24204")\)

== Vertica connector

- Fix failure when updating values to #raw("NULL"). \(#issue("24204", "https://github.com/trinodb/trino/issues/24204")\)

== SPI

- Remove support for connector-level event listeners and the related #raw("Connector.getEventListeners()") method. \(#issue("24609", "https://github.com/trinodb/trino/issues/24609")\)
