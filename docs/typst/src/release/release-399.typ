#import "/lib/trino-docs.typ": *

#anchor("doc-release-release-399")
= Release 399 \(6 Oct 2022\)

== General

- Add operator CPU and wall time distribution to #raw("EXPLAIN ANALYZE VERBOSE"). \(#issue("14370", "https://github.com/trinodb/trino/issues/14370")\)
- Improve performance of joins. \(#issue("13352", "https://github.com/trinodb/trino/issues/13352")\)
- Remove support for the deprecated #raw("row") to #raw("json") cast behavior, and remove the #raw("deprecated.legacy-row-to-json-cast") configuration property. \(#issue("14388", "https://github.com/trinodb/trino/issues/14388")\)
- Fix error when using #raw("PREPARE") with #raw("DROP VIEW") when the view name is quoted. \(#issue("14196", "https://github.com/trinodb/trino/issues/14196")\)
- Fix potential planning failure for queries involving #raw("UNION"). \(#issue("14472", "https://github.com/trinodb/trino/issues/14472")\)
- Fix error when using aggregations in window expressions when the function loaded from a plugin. \(#issue("14486", "https://github.com/trinodb/trino/issues/14486")\)

== Accumulo connector

- Change the default value of the #raw("accumulo.zookeeper.metadata.root") configuration property to #raw("/trino-accumulo") from #raw("/presto-accumulo"). \(#issue("14326", "https://github.com/trinodb/trino/issues/14326")\)

== BigQuery connector

- Add support for writing #raw("array"), #raw("row"), and #raw("timestamp") columns. \(#issue("14418", "https://github.com/trinodb/trino/issues/14418"), #issue("14473", "https://github.com/trinodb/trino/issues/14473")\)

== ClickHouse connector

- Fix bug where the intended default value of the #raw("domain-compaction-threshold") configuration property was incorrectly used as a maximum limit. \(#issue("14350", "https://github.com/trinodb/trino/issues/14350")\)

== Delta Lake connector

- Improve performance of reading decimal columns from Parquet files. \(#issue("14260", "https://github.com/trinodb/trino/issues/14260")\)
- Allow setting the AWS Security Token Service endpoint and region when using a Glue metastore. \(#issue("14412", "https://github.com/trinodb/trino/issues/14412")\)

== Hive connector

- Add #raw("max-partition-drops-per-query") configuration property to limit the number of partition drops. \(#issue("12386", "https://github.com/trinodb/trino/issues/12386")\)
- Add #raw("hive.s3.region") configuration property to force S3 to connect to a specific region. \(#issue("14398", "https://github.com/trinodb/trino/issues/14398")\)
- Improve performance of reading decimal columns from Parquet files. \(#issue("14260", "https://github.com/trinodb/trino/issues/14260")\)
- Reduce memory usage on the coordinator. \(#issue("14408", "https://github.com/trinodb/trino/issues/14408")\)
- Reduce query memory usage during inserts to S3. \(#issue("14212", "https://github.com/trinodb/trino/issues/14212")\)
- Change the name of the #raw("partition_column") and #raw("partition_value") arguments for the #raw("flush_metadata_cache") procedure to #raw("partition_columns") and #raw("partition_values"), respectively, for parity with other procedures. \(#issue("13566", "https://github.com/trinodb/trino/issues/13566")\)
- Change field name matching to be case insensitive. \(#issue("13423", "https://github.com/trinodb/trino/issues/13423")\)
- Allow setting the AWS STS endpoint and region when using a Glue metastore. \(#issue("14412", "https://github.com/trinodb/trino/issues/14412")\)

== Hudi connector

- Fix failure when reading hidden columns. \(#issue("14341", "https://github.com/trinodb/trino/issues/14341")\)

== Iceberg connector

- Improve performance of reading decimal columns from Parquet files. \(#issue("14260", "https://github.com/trinodb/trino/issues/14260")\)
- Reduce planning time for complex queries. \(#issue("14443", "https://github.com/trinodb/trino/issues/14443")\)
- Store metastore #raw("table_type") property value in uppercase for compatibility with other Iceberg catalog implementations. \(#issue("14384", "https://github.com/trinodb/trino/issues/14384")\)
- Allow setting the AWS STS endpoint and region when using a Glue metastore. \(#issue("14412", "https://github.com/trinodb/trino/issues/14412")\)

== Phoenix connector

- Fix bug where the intended default value of the #raw("domain-compaction-threshold") configuration property was incorrectly used as a maximum limit. \(#issue("14350", "https://github.com/trinodb/trino/issues/14350")\)

== SQL Server connector

- Fix error when querying or listing tables with names that contain special characters. \(#issue("14286", "https://github.com/trinodb/trino/issues/14286")\)

== SPI

- Add stage output buffer distribution to #raw("EventListener"). \(#issue("14400", "https://github.com/trinodb/trino/issues/14400")\)
- Remove deprecated #raw("TimeType.TIME"), #raw("TimestampType.TIMESTAMP") and #raw("TimestampWithTimeZoneType.TIMESTAMP_WITH_TIME_ZONE") constants. \(#issue("14414", "https://github.com/trinodb/trino/issues/14414")\)
