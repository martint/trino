#import "/lib/trino-docs.typ": *

#anchor("doc-release-release-434")
= Release 434 \(29 Nov 2023\)

== General

- Add support for a #raw("FILTER") clause to the #raw("LISTAGG") function. \(#issue("19869", "https://github.com/trinodb/trino/issues/19869")\)
- #breaking-marker("../release.html#breaking-changes") Rename the #raw("query.max-writer-tasks-count") configuration property and the related #raw("max_writer_tasks_count") session property to #raw("query.max-writer-task-count") and #raw("max_writer_task_count"). \(#issue("19793", "https://github.com/trinodb/trino/issues/19793")\)
- Improve performance of #raw("INSERT ... SELECT") queries that contain a redundant #raw("ORDER BY") clause. \(#issue("19916", "https://github.com/trinodb/trino/issues/19916")\)
- Fix incorrect results for queries involving comparisons between #raw("double") and #raw("real") zero and negative zero. \(#issue("19828", "https://github.com/trinodb/trino/issues/19828")\)
- Fix performance regression caused by suboptimal scalar subqueries planning. \(#issue("19922", "https://github.com/trinodb/trino/issues/19922")\)
- Fix failure when queries on data stored on HDFS involve table functions. \(#issue("19849", "https://github.com/trinodb/trino/issues/19849")\)
- Prevent sudden increases in memory consumption in some queries with joins involving #raw("UNNEST"). \(#issue("19762", "https://github.com/trinodb/trino/issues/19762")\)

== BigQuery connector

- Add support for reading #raw("json") columns. \(#issue("19790", "https://github.com/trinodb/trino/issues/19790")\)
- Add support for #raw("DELETE") statement. \(#issue("6870", "https://github.com/trinodb/trino/issues/6870")\)
- Improve performance when writing rows. \(#issue("18897", "https://github.com/trinodb/trino/issues/18897")\)

== ClickHouse connector

- Add support for separate metadata caching configuration for schemas, tables, and metadata. \(#issue("19859", "https://github.com/trinodb/trino/issues/19859")\)

== Delta Lake connector

- #breaking-marker("../release.html#breaking-changes") Disallow invalid configuration options. Previously, they were silently ignored.  \(#issue("19735", "https://github.com/trinodb/trino/issues/19735")\)
- Improve performance when reading large checkpoint files on partitioned tables. \(#issue("19588", "https://github.com/trinodb/trino/issues/19588"), #issue("19848", "https://github.com/trinodb/trino/issues/19848")\)
- Push down filters involving columns of type #raw("timestamp(p) with time zone"). \(#issue("18664", "https://github.com/trinodb/trino/issues/18664")\)
- Fix query failure when reading Parquet column index for timestamp columns. \(#issue("16801", "https://github.com/trinodb/trino/issues/16801")\)

== Druid connector

- Add support for separate metadata caching configuration for schemas, tables, and metadata. \(#issue("19859", "https://github.com/trinodb/trino/issues/19859")\)

== Hive connector

- Add support for columns that changed from #raw("timestamp") to #raw("date") type. \(#issue("19513", "https://github.com/trinodb/trino/issues/19513")\)
- Fix query failure when reading Parquet column index for timestamp columns. \(#issue("16801", "https://github.com/trinodb/trino/issues/16801")\)

== Hudi connector

- Fix query failure when reading Parquet column index for timestamp columns. \(#issue("16801", "https://github.com/trinodb/trino/issues/16801")\)

== Iceberg connector

- #breaking-marker("../release.html#breaking-changes") Remove support for legacy table statistics tracking. \(#issue("19803", "https://github.com/trinodb/trino/issues/19803")\)
- #breaking-marker("../release.html#breaking-changes") Disallow invalid configuration options. Previously, they were silently ignored.  \(#issue("19735", "https://github.com/trinodb/trino/issues/19735")\)
- Fix query failure when reading Parquet column index for timestamp columns. \(#issue("16801", "https://github.com/trinodb/trino/issues/16801")\)
- Don't set owner for Glue materialized views when system security is enabled. \(#issue("19681", "https://github.com/trinodb/trino/issues/19681")\)

== Ignite connector

- Add support for separate metadata caching configuration for schemas, tables, and metadata. \(#issue("19859", "https://github.com/trinodb/trino/issues/19859")\)

== MariaDB connector

- Add support for separate metadata caching configuration for schemas, tables, and metadata. \(#issue("19859", "https://github.com/trinodb/trino/issues/19859")\)

== MySQL connector

- Add support for separate metadata caching configuration for schemas, tables, and metadata. \(#issue("19859", "https://github.com/trinodb/trino/issues/19859")\)

== Oracle connector

- Add support for separate metadata caching configuration for schemas, tables, and metadata. \(#issue("19859", "https://github.com/trinodb/trino/issues/19859")\)

== Phoenix connector

- Add support for separate metadata caching configuration for schemas, tables, and metadata. \(#issue("19859", "https://github.com/trinodb/trino/issues/19859")\)

== PostgreSQL connector

- Add support for separate metadata caching configuration for schemas, tables, and metadata. \(#issue("19859", "https://github.com/trinodb/trino/issues/19859")\)
- Prevent possible query failures when join is pushed down. \(#issue("18984", "https://github.com/trinodb/trino/issues/18984")\)

== Redshift connector

- Add support for separate metadata caching configuration for schemas, tables, and metadata. \(#issue("19859", "https://github.com/trinodb/trino/issues/19859")\)
- Prevent possible query failures when join is pushed down. \(#issue("18984", "https://github.com/trinodb/trino/issues/18984")\)

== SingleStore connector

- Add support for separate metadata caching configuration for schemas, tables, and metadata. \(#issue("19859", "https://github.com/trinodb/trino/issues/19859")\)

== SQL Server connector

- Add support for separate metadata caching configuration for schemas, tables, and metadata. \(#issue("19859", "https://github.com/trinodb/trino/issues/19859")\)
- Prevent possible query failures when join is pushed down. \(#issue("18984", "https://github.com/trinodb/trino/issues/18984")\)

== SPI

- Add bulk append methods to #raw("BlockBuilder"). \(#issue("19577", "https://github.com/trinodb/trino/issues/19577")\)
- #breaking-marker("../release.html#breaking-changes") Remove the #raw("VariableWidthBlockBuilder.buildEntry") method. \(#issue("19577", "https://github.com/trinodb/trino/issues/19577")\)
- #breaking-marker("../release.html#breaking-changes") Add required  #raw("ConnectorSession") parameter to the method #raw("TableFunctionProcessorProvider.getDataProcessor"). \(#issue("19778", "https://github.com/trinodb/trino/issues/19778")\)
