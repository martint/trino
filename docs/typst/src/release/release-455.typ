#import "/lib/trino-docs.typ": *

#anchor("doc-release-release-455")
= Release 455 \(29 Aug 2024\)

== General

- Add query starting time in #raw("QueryStatistics") in all #link(label("ref-admin-event-listeners"))[Administration]. \(#issue("23113", "https://github.com/trinodb/trino/issues/23113")\)
- Add JMX metrics for the bean #raw("trino.execution.executor.timesharing:name=TimeSharingTaskExecutor") replacing metrics previously found in #raw("trino.execution.executor:name=TaskExecutor"). \(#issue("22914", "https://github.com/trinodb/trino/issues/22914")\)
- Add support S3 file system encryption with fault-tolerant execution mode. \(#issue("22529", "https://github.com/trinodb/trino/issues/22529")\)
- Fix memory tracking issue for aggregations that could cause worker crashes with out-of-memory errors. \(#issue("23098", "https://github.com/trinodb/trino/issues/23098")\)

== Delta Lake connector

- Allow configuring endpoint for the native Azure filesystem. \(#issue("23071", "https://github.com/trinodb/trino/issues/23071")\)
- Improve stability for concurrent Glue connections. \(#issue("23039", "https://github.com/trinodb/trino/issues/23039")\)

== ClickHouse connector

- Add support for creating tables with the #raw("MergeTree") engine without the #raw("order_by") table property. \(#issue("23048", "https://github.com/trinodb/trino/issues/23048")\)

== Hive connector

- Allow configuring endpoint for the native Azure filesystem. \(#issue("23071", "https://github.com/trinodb/trino/issues/23071")\)
- Improve stability for concurrent Glue connections. \(#issue("23039", "https://github.com/trinodb/trino/issues/23039")\)
- Fix query failures when Parquet files contain column names that only differ in case. \(#issue("23050", "https://github.com/trinodb/trino/issues/23050")\)

== Hudi connector

- Allow configuring endpoint for the native Azure filesystem. \(#issue("23071", "https://github.com/trinodb/trino/issues/23071")\)

== Iceberg connector

- Allow configuring endpoint for the native Azure filesystem. \(#issue("23071", "https://github.com/trinodb/trino/issues/23071")\)
- Improve stability for concurrent Glue connections. \(#issue("23039", "https://github.com/trinodb/trino/issues/23039")\)
- Fix #raw("$files") table not showing delete files with the Iceberg v2 format. \(#issue("16233", "https://github.com/trinodb/trino/issues/16233")\)

== OpenSearch connector

- Improve performance of queries that reference nested fields from OpenSearch documents. \(#issue("22646", "https://github.com/trinodb/trino/issues/22646")\)

== PostgreSQL

- Fix potential failure for pushdown of #raw("euclidean_distance"), #raw("cosine_distance") and #raw("dot_product") functions. \(#issue("23152", "https://github.com/trinodb/trino/issues/23152")\)

== Prometheus connector

- Add support for the catalog session properties #raw("query_chunk_size_duration") and #raw("max_query_range_duration"). \(#issue("22319", "https://github.com/trinodb/trino/issues/22319")\)

== Redshift connector

- Release resources in Redshift promptly when a query is cancelled. \(#issue("22774", "https://github.com/trinodb/trino/issues/22774")\)
