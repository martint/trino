#import "/lib/trino-docs.typ": *

#anchor("doc-release-release-0-147")
= Release 0.147

== General

- Fix race condition that can cause queries that process data from non-columnar data sources to fail.
- Fix incorrect formatting of dates and timestamps before year 1680.
- Fix handling of syntax errors when parsing #raw("EXTRACT").
- Fix potential scheduling deadlock for connectors that expose node-partitioned data.
- Fix performance regression that increased planning time.
- Fix incorrect results for grouping sets for some queries with filters.
- Add #link(label("doc-sql-show-create-view"))[SHOW CREATE VIEW] and #link(label("doc-sql-show-create-table"))[SHOW CREATE TABLE].
- Add support for column aliases in #raw("WITH") clause.
- Support #raw("LIKE") clause for #link(label("doc-sql-show-catalogs"))[SHOW CATALOGS] and #link(label("doc-sql-show-schemas"))[SHOW SCHEMAS].
- Add support for #raw("INTERSECT").
- Add support for casting row types.
- Add #link(label("fn-sequence"), raw("sequence")) function.
- Add #link(label("fn-sign"), raw("sign")) function.
- Add #link(label("fn-flatten"), raw("flatten")) function.
- Add experimental implementation of #link(label("doc-admin-resource-groups"))[resource groups].
- Add localfile connector.
- Remove experimental intermediate aggregation optimizer. The #raw("optimizer.use-intermediate-aggregations") config option and #raw("task_intermediate_aggregation") session property are no longer supported.
- Add support for colocated joins for connectors that expose node-partitioned data.
- Improve the performance of #link(label("fn-array-intersect"), raw("array_intersect")).
- Generalize the intra-node parallel execution system to work with all query stages. The #raw("task.concurrency") configuration property replaces the old #raw("task.join-concurrency") and #raw("task.default-concurrency") options. Similarly, the #raw("task_concurrency") session property replaces the #raw("task_join_concurrency"), #raw("task_hash_build_concurrency"), and #raw("task_aggregation_concurrency") properties.

== Hive

- Fix reading symlinks when the target is in a different HDFS instance.
- Fix #raw("NoClassDefFoundError") for #raw("SubnetUtils") in HDFS client.
- Fix error when reading from Hive tables with inconsistent bucketing metadata.
- Correctly report read bytes when reading Parquet data.
- Include path in unrecoverable S3 exception messages.
- When replacing an existing Presto view, update the view data in the Hive metastore rather than dropping and recreating it.
- Rename table property #raw("clustered_by") to #raw("bucketed_by").
- Add support for #raw("varchar(n)").

== Kafka

- Fix #raw("error code 6") when reading data from Kafka.
- Add support for #raw("varchar(n)").

== Redis

- Add support for #raw("varchar(n)").

== MySQL and PostgreSQL

- Cleanup temporary data when a #raw("CREATE TABLE AS") fails.
- Add support for #raw("varchar(n)").
