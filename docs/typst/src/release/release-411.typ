#import "/lib/trino-docs.typ": *

#anchor("doc-release-release-411")
= Release 411 \(29 Mar 2023\)

== General

- Add spilled data size to query statistics. \(#issue("16442", "https://github.com/trinodb/trino/issues/16442")\)
- Add #link(label("fn-sinh"), raw("sinh")) function. \(#issue("16494", "https://github.com/trinodb/trino/issues/16494")\)
- Add #link(label("fn-quantile-at-value"), raw("quantile_at_value")) function. \(#issue("16736", "https://github.com/trinodb/trino/issues/16736")\)
- Add support for a #raw("GRACE PERIOD") clause in the #raw("CREATE MATERIALIZED VIEW") task. For backwards compatibility, the existing materialized views are interpreted as having a #raw("GRACE PERIOD") of zero, however, new materialized views have an unlimited grace period by default. This is a backwards incompatible change, and the previous behavior can be restored with the #raw("legacy.materialized-view-grace-period") configuration property or the #raw("legacy_materialized_view_grace_period") session property. \(#issue("15842", "https://github.com/trinodb/trino/issues/15842")\)
- Fix potential incorrect query stats when tasks are waiting on running drivers to fully terminate. \(#issue("15478", "https://github.com/trinodb/trino/issues/15478")\)
- Add support for specifying the number of nodes that will write data during #raw("INSERT"), #raw("CREATE TABLE ... AS SELECT"), or #raw("EXECUTE") queries with the #raw("query.max-writer-tasks-count") configuration property. \(#issue("16238", "https://github.com/trinodb/trino/issues/16238")\)
- Improve performance of queries that contain predicates involving the #raw("year") function. \(#issue("14078", "https://github.com/trinodb/trino/issues/14078")\)
- Improve performance of queries that contain a #raw("sum") aggregation. \(#issue("16624", "https://github.com/trinodb/trino/issues/16624")\)
- Improve performance of #raw("filter") function on arrays. \(#issue("16681", "https://github.com/trinodb/trino/issues/16681")\)
- Reduce coordinator memory usage. \(#issue("16668", "https://github.com/trinodb/trino/issues/16668"), #issue("16669", "https://github.com/trinodb/trino/issues/16669")\)
- Reduce redundant data exchanges for queries with multiple aggregations. \(#issue("16328", "https://github.com/trinodb/trino/issues/16328")\)
- Fix incorrect query results when using #raw("keyvalue()") methods in the #link(label("ref-json-path-language"))[JSON path]. \(#issue("16482", "https://github.com/trinodb/trino/issues/16482")\)
- Fix potential incorrect results in queries involving joins and a non-deterministic value. \(#issue("16512", "https://github.com/trinodb/trino/issues/16512")\)
- Fix potential query failure when exchange compression is enabled. \(#issue("16541", "https://github.com/trinodb/trino/issues/16541")\)
- Fix query failure when calling a function with a large number of parameters. \(#issue("15979", "https://github.com/trinodb/trino/issues/15979")\)

== BigQuery connector

- Fix failure of aggregation queries when executed against a materialized view, external table, or snapshot table. \(#issue("15546", "https://github.com/trinodb/trino/issues/15546")\)

== Delta Lake connector

- Add support for inserting into tables that have #link("https://github.com/delta-io/delta/blob/master/PROTOCOL.md#column-invariants")[simple invariants]. \(#issue("16136", "https://github.com/trinodb/trino/issues/16136")\)
- Add #link("https://docs.delta.io/latest/delta-batch.html#use-generated-columns")[generated column expressions] to the #raw("Extra") column in the results of #raw("DESCRIBE") and #raw("SHOW COLUMNS"). \(#issue("16631", "https://github.com/trinodb/trino/issues/16631")\)
- Expand the #raw("flush_metadata_cache") table procedure to also flush the internal caches of table snapshots and active data files. \(#issue("16466", "https://github.com/trinodb/trino/issues/16466")\)
- Collect statistics for newly-created columns. \(#issue("16109", "https://github.com/trinodb/trino/issues/16109")\)
- Remove the #raw("$data") system table. \(#issue("16650", "https://github.com/trinodb/trino/issues/16650")\)
- Fix query failure when evaluating a #raw("WHERE") clause on a partition column. \(#issue("16388", "https://github.com/trinodb/trino/issues/16388")\)

== Druid connector

- Fix failure when the query passed to the #raw("query") table function contains a column alias. \(#issue("16225", "https://github.com/trinodb/trino/issues/16225")\)

== Elasticsearch connector

- Remove the deprecated pass-through query, which has been replaced with the #raw("raw_query") table function. \(#issue("13050", "https://github.com/trinodb/trino/issues/13050")\)

== Hive connector

- Add a native OpenX JSON file format reader and writer. These can be disabled with the #raw("openx_json_native_reader_enabled") and #raw("openx_json_native_writer_enabled") session properties or the #raw("openx-json.native-reader.enabled") and #raw("openx-json.native-writer.enabled") configuration properties. \(#issue("16073", "https://github.com/trinodb/trino/issues/16073")\)
- Add support for implicit coercions between #raw("char") types of different lengths. \(#issue("16402", "https://github.com/trinodb/trino/issues/16402")\)
- Improve performance of queries with joins where both sides of a join have keys with the same table bucketing definition. \(#issue("16381", "https://github.com/trinodb/trino/issues/16381")\)
- Improve query planning performance for queries scanning tables with a large number of columns. \(#issue("16203", "https://github.com/trinodb/trino/issues/16203")\)
- Improve scan performance for #raw("COUNT(*)") queries on row-oriented formats. \(#issue("16595", "https://github.com/trinodb/trino/issues/16595")\)
- Ensure the value of the #raw("hive.metastore-stats-cache-ttl") configuration property always is greater than or equal to the value specified in the #raw("hive.metastore-cache-ttl") configuration property. \(#issue("16625", "https://github.com/trinodb/trino/issues/16625")\)
- Skip listing Glue metastore tables with invalid column types. \(#issue("16677", "https://github.com/trinodb/trino/issues/16677")\)
- Fix query failure when a file that is using a text file format with a single header row that is large enough to be split into multiple files. \(#issue("16492", "https://github.com/trinodb/trino/issues/16492")\)
- Fix potential query failure when Kerberos is enabled and the query execution takes longer than a Kerberos ticket's lifetime. \(#issue("16680", "https://github.com/trinodb/trino/issues/16680")\)

== Hudi connector

- Add a #raw("$timeline") system table which can be queried to inspect the Hudi table timeline. \(#issue("16149", "https://github.com/trinodb/trino/issues/16149")\)

== Iceberg connector

- Add a #raw("migrate") procedure that converts a Hive table to an Iceberg table. \(#issue("13196", "https://github.com/trinodb/trino/issues/13196")\)
- Add support for materialized views with a freshness grace period. \(#issue("15842", "https://github.com/trinodb/trino/issues/15842")\)
- Add a #raw("$refs") system table which can be queried to inspect snapshot references. \(#issue("15649", "https://github.com/trinodb/trino/issues/15649")\)
- Add support for creation of materialized views partitioned with a temporal partitioning function on a #raw("timestamp with time zone") column. \(#issue("16637", "https://github.com/trinodb/trino/issues/16637")\)
- Improve performance of queries run after data was written by Trino. \(#issue("15441", "https://github.com/trinodb/trino/issues/15441")\)
- Remove the #raw("$data") system table. \(#issue("16650", "https://github.com/trinodb/trino/issues/16650")\)
- Fix failure when the #raw("$files") system table contains non-null values in the #raw("key_metadata"), #raw("split_offsets"), and #raw("equality_ids") columns. \(#issue("16473", "https://github.com/trinodb/trino/issues/16473")\)
- Fix failure when partitioned column names contain uppercase characters. \(#issue("16622", "https://github.com/trinodb/trino/issues/16622")\)

== Ignite connector

- Add support for predicate pushdown with a #raw("LIKE") clause. \(#issue("16396", "https://github.com/trinodb/trino/issues/16396")\)
- Add support for pushdown of joins. \(#issue("16428", "https://github.com/trinodb/trino/issues/16428")\)
- Add support for #link(label("doc-sql-delete"))[DELETE]. \(#issue("16720", "https://github.com/trinodb/trino/issues/16720")\)

== MariaDB connector

- Fix failure when the query passed to the #raw("query") table function contains a column alias. \(#issue("16225", "https://github.com/trinodb/trino/issues/16225")\)

== MongoDB connector

- Fix incorrect results when the query passed to the MongoDB #raw("query") table function contains helper functions such as #raw("ISODate"). \(#issue("16626", "https://github.com/trinodb/trino/issues/16626")\)

== MySQL connector

- Fix failure when the query passed to the #raw("query") table function contains a column alias. \(#issue("16225", "https://github.com/trinodb/trino/issues/16225")\)

== Oracle connector

- Improve performance of queries when the network latency between Trino and Oracle is high, or when selecting a small number of columns. \(#issue("16644", "https://github.com/trinodb/trino/issues/16644")\)

== PostgreSQL connector

- Improve performance of queries when the network latency between Trino and PostgreSQL is high, or when selecting a small number of columns. \(#issue("16644", "https://github.com/trinodb/trino/issues/16644")\)

== Redshift connector

- Improve performance of queries when the network latency between Trino and Redshift is high, or when selecting a small number of columns. \(#issue("16644", "https://github.com/trinodb/trino/issues/16644")\)

== SingleStore connector

- Fix failure when the query passed to the #raw("query") table function contains a column alias. \(#issue("16225", "https://github.com/trinodb/trino/issues/16225")\)

== SQL Server connector

- Add support for executing stored procedures using the #raw("procedure") table function. \(#issue("16696", "https://github.com/trinodb/trino/issues/16696")\)
