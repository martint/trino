#import "/lib/trino-docs.typ": *

#anchor("doc-release-release-342")
= Release 342 \(24 Sep 2020\)

== General

- Add #link(label("fn-from-iso8601-timestamp-nanos"), raw("from_iso8601_timestamp_nanos")) function. \(#issue("5048", "https://github.com/trinodb/trino/issues/5048")\)
- Improve performance of queries that use the #raw("DECIMAL") type. \(#issue("4886", "https://github.com/trinodb/trino/issues/4886")\)
- Improve performance of queries involving #raw("IN") with subqueries by extending support for dynamic filtering. \(#issue("5017", "https://github.com/trinodb/trino/issues/5017")\)
- Improve performance and latency of queries leveraging dynamic filters. \(#issue("4988", "https://github.com/trinodb/trino/issues/4988")\)
- Improve performance of queries joining tables with missing or incomplete column statistics when cost based optimization is enabled \(which is the default\). \(#issue("5141", "https://github.com/trinodb/trino/issues/5141")\)
- Reduce latency for queries that perform a broadcast join of a large table. \(#issue("5237", "https://github.com/trinodb/trino/issues/5237")\)
- Allow collection of dynamic filters for joins with large build side using the #raw("enable-large-dynamic-filters") configuration property or the #raw("enable_large_dynamic_filters") session property. \(#issue("5262", "https://github.com/trinodb/trino/issues/5262")\)
- Fix query failure when lambda expression references a table column containing a dot. \(#issue("5087", "https://github.com/trinodb/trino/issues/5087")\)

== Atop connector

- Fix incorrect query results when query contains predicates on #raw("start_time") or #raw("end_time") column. \(#issue("5125", "https://github.com/trinodb/trino/issues/5125")\)

== Elasticsearch connector

- Allow reading boolean values stored as strings. \(#issue("5269", "https://github.com/trinodb/trino/issues/5269")\)

== Hive connector

- Add support for S3 encrypted files. \(#issue("2536", "https://github.com/trinodb/trino/issues/2536")\)
- Add support for ABFS OAuth authentication. \(#issue("5052", "https://github.com/trinodb/trino/issues/5052")\)
- Support reading timestamp with microsecond or nanosecond precision. This can be enabled with the #raw("hive.timestamp-precision") configuration property. \(#issue("4953", "https://github.com/trinodb/trino/issues/4953")\)
- Allow overwrite on insert by default using the #raw("hive.insert-existing-partitions-behavior") configuration property. \(#issue("4999", "https://github.com/trinodb/trino/issues/4999")\)
- Allow delaying table scans until dynamic filtering can be performed more efficiently. This can be enabled using the #raw("hive.dynamic-filtering-probe-blocking-timeout") configuration property or the #raw("dynamic_filtering_probe_blocking_timeout") session property. \(#issue("4991", "https://github.com/trinodb/trino/issues/4991")\)
- Disable matching the existing user and group of the table or partition when creating new files on HDFS. The functionality was added in 341 and is now disabled by default. It can be enabled using the #raw("hive.fs.new-file-inherit-ownership") configuration property. \(#issue("5187", "https://github.com/trinodb/trino/issues/5187")\)
- Improve performance when reading small files in #raw("RCTEXT") or #raw("RCBINARY") format. \(#issue("2536", "https://github.com/trinodb/trino/issues/2536")\)
- Improve planning time for queries with non-equality filters on partition columns when using the Glue metastore. \(#issue("5060", "https://github.com/trinodb/trino/issues/5060")\)
- Improve performance when reading #raw("JSON") and #raw("CSV") file formats. \(#issue("5142", "https://github.com/trinodb/trino/issues/5142")\)

== Iceberg connector

- Fix partition transforms for temporal columns for dates before 1970. \(#issue("5273", "https://github.com/trinodb/trino/issues/5273")\)

== Kafka connector

- Expose message headers as a #raw("_headers") column of #raw("MAP(VARCHAR, ARRAY(VARBINARY))") type. \(#issue("4462", "https://github.com/trinodb/trino/issues/4462")\)
- Add write support for #raw("TIME"), #raw("TIME WITH TIME ZONE"), #raw("TIMESTAMP") and #raw("TIMESTAMP WITH TIME ZONE") for Kafka connector when using the JSON encoder. \(#issue("4743", "https://github.com/trinodb/trino/issues/4743")\)
- Remove JSON decoder support for nonsensical combinations of input-format-type \/ data-type. The following combinations are no longer supported: \(#issue("4743", "https://github.com/trinodb/trino/issues/4743")\)
  
  - #raw("rfc2822"):  #raw("DATE"), #raw("TIME"), #raw("TIME WITH TIME ZONE")
  - #raw("milliseconds-since-epoch"): #raw("TIME WITH TIME ZONE"), #raw("TIMESTAMP WITH TIME ZONE")
  - #raw("seconds-since-epoch"): #raw("TIME WITH TIME ZONE"), #raw("TIMESTAMP WITH TIME ZONE")

== MySQL connector

- Improve performance of #raw("INSERT") queries when GTID mode is disabled in MySQL. \(#issue("4995", "https://github.com/trinodb/trino/issues/4995")\)

== PostgreSQL connector

- Add support for variable-precision TIMESTAMP and TIMESTAMP WITH TIME ZONE types. \(#issue("5124", "https://github.com/trinodb/trino/issues/5124"), #issue("5105", "https://github.com/trinodb/trino/issues/5105")\)

== SQL Server connector

- Fix failure when inserting #raw("NULL") into a #raw("VARBINARY") column. \(#issue("4846", "https://github.com/trinodb/trino/issues/4846")\)
- Improve performance of aggregation queries by computing aggregations within SQL Server database. Currently, the following aggregate functions are eligible for pushdown: #raw("count"),  #raw("min"), #raw("max"), #raw("sum") and #raw("avg"). \(#issue("4139", "https://github.com/trinodb/trino/issues/4139")\)

== SPI

- Add #raw("DynamicFilter.isAwaitable()") method that returns whether or not the dynamic filter is complete and can be awaited for using the #raw("isBlocked()") method. \(#issue("5043", "https://github.com/trinodb/trino/issues/5043")\)
- Enable connectors to wait for dynamic filters derived from replicated joins before generating splits. \(#issue("4685", "https://github.com/trinodb/trino/issues/4685")\)
