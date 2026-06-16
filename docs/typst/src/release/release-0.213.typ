#import "/lib/trino-docs.typ": *

#anchor("doc-release-release-0-213")
= Release 0.213

== General

- Fix split scheduling backpressure when plan contains colocated join. Previously, splits for the second and subsequent scan nodes \(in scheduling order\) were scheduled continuously until completion, rather than pausing due to sufficient pending splits.
- Fix query execution failure or indefinite hang during grouped execution when all splits for any lifespan are completely filtered out.
- Fix grouped execution to respect the configured concurrent lifespans per task. Previously, it always used a single lifespan per task.
- Fix execution failure when using grouped execution with right or full outer joins where the right side is not partitioned on the join key.
- Fix a scenario where too many rows are returned to clients in a single response.
- Do not allow setting invalid property values with #link(label("doc-sql-set-session"))[SET SESSION].
- Disable stats calculator by default as it can cause a planning failure for certain complex queries. It can be enabled with the #raw("experimental.enable-stats-calculator") configuration property or the #raw("enable_stats_calculator") session property.
- Avoid making guesses when estimating filters for joins. Previously, if nothing was known about the filter, a #raw("0.9") coefficient was applied as a filter factor. Now, if nothing is known about a filter, the estimate will be unknown. A #raw("0.9") coefficient will be applied for all additional conjuncts if at least a single conjunct can be reasonably estimated.
- Improve inference of predicates for inner joins.
- Improve #raw("EXPLAIN ANALYZE") output by adding CPU time and enhancing accuracy of CPU fraction.
- Include stats and cost estimates in textual plans created on query completion.
- Enhance #raw("SHOW STATS") to support #raw("IN") and #raw("BETWEEN") predicates in the #raw("WHERE") condition of the #raw("SELECT") clause.
- Remove transaction from explain plan for indexes joins.
- Add #raw("max_drivers_per_task") session property, allowing users to limit concurrency by specifying a number lower than the system configured maximum. This can cause the query to run slower and consume less resources.
- Add #raw("join-max-broadcast-table-size") configuration property and #raw("join_max_broadcast_table_size") session property to control the maximum estimated size of a table that can be broadcast when using #raw("AUTOMATIC") join distribution type \(#issue("11667", "https://github.com/prestodb/presto/issues/11667")\).
- Add experimental config option #raw("experimental.reserved-pool-enabled") to disable the reserved memory pool.
- Add #raw("targetResultSize") query parameter to #raw("/v1/statement") endpoint to control response data size.

== Geospatial

- Fix #link(label("fn-st-distance"), raw("ST_Distance")) function to return #raw("NULL") if any of the inputs is an empty geometry as required by the SQL\/MM specification.
- Add #link(label("fn-st-multipoint"), raw("ST_MultiPoint")) function to construct multi-point geometry from an array of points.
- Add #link(label("fn-geometry-union"), raw("geometry_union")) function to efficiently union arrays of geometries.
- Add support for distributed spatial joins \(#issue("11072", "https://github.com/prestodb/presto/issues/11072")\).

== Server RPM

- Allow running on a JVM from any vendor.

== Web UI

- Remove legacy plan UI.
- Add support for filtering queries by all error categories.
- Add dialog to show errors refreshing data from coordinator.
- Change worker thread list to not show thread stacks by default to improve page peformance.

== Hive connector

- Fix LZO and LZOP decompression to work with certain data compressed by Hadoop.
- Fix ORC writer validation percentage so that zero does not result in 100% validation.
- Fix potential out-of-bounds read for ZSTD on corrupted input.
- Stop assuming no distinct values when column null fraction statistic is less than #raw("1.0").
- Treat #raw("-1") as an absent null count for compatibility with statistics written by #link("https://issues.apache.org/jira/browse/IMPALA-7497")[Impala].
- Preserve original exception for metastore network errors.
- Preserve exceptions from Avro deserializer
- Categorize text line length exceeded error.
- Remove the old Parquet reader. The #raw("hive.parquet-optimized-reader.enabled") configuration property and #raw("parquet_optimized_reader_enabled") session property no longer exist.
- Remove the #raw("hive.parquet-predicate-pushdown.enabled") configuration property and #raw("parquet_predicate_pushdown_enabled") session property. Pushdown is always enabled now in the Parquet reader.
- Enable optimized ORC writer by default. It can be disabled using the #raw("hive.orc.optimized-writer.enabled") configuration property or the #raw("orc_optimized_writer_enabled") session property.
- Use ORC file format as the default for new tables or partitions.
- Add support for Avro tables where the Avro schema URL is an HDFS location.
- Add #raw("hive.parquet.writer.block-size") and #raw("hive.parquet.writer.page-size") configuration properties and #raw("parquet_writer_block_size") and #raw("parquet_writer_page_size") session properties for tuning Parquet writer options.

== Memory connector

- Improve table data size accounting.

== Thrift connector

- Include constraint in explain plan for index joins.
- Improve readability of columns, tables, layouts, and indexes in explain plans.

== Verifier

- Rewrite queries in parallel when shadowing writes.
