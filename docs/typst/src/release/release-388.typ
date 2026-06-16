#import "/lib/trino-docs.typ": *

#anchor("doc-release-release-388")
= Release 388 \(29 Jun 2022\)

== General

- Add support for #raw("EXPLAIN (TYPE LOGICAL, FORMAT JSON)"). \(#issue("12694", "https://github.com/trinodb/trino/issues/12694")\)
- Add #raw("use_exact_partitioning") session property to re-partition data when the upstream stage's partitioning does not exactly match what the downstream stage expects. \(#issue("12495", "https://github.com/trinodb/trino/issues/12495")\)
- Improve read performance for #raw("row") data types. \(#issue("12926", "https://github.com/trinodb/trino/issues/12926")\)
- Remove the grouped execution mechanism, including the #raw("grouped-execution-enabled"), #raw("dynamic-schedule-for-grouped-execution"), and #raw("concurrent-lifespans-per-task") configuration properties and the #raw("grouped_execution"), #raw("dynamic_schedule_for_grouped_execution"), and #raw("concurrent_lifespans_per_task") session properties. \(#issue("12916", "https://github.com/trinodb/trino/issues/12916")\)

== Security

- Add #link("https://oauth.net/2/refresh-tokens/")[refresh token] support in OAuth 2.0. \(#issue("12664", "https://github.com/trinodb/trino/issues/12664")\)

== Delta Lake connector

- Add support for setting table and column comments with the #raw("COMMENT") statement. \(#issue("12971", "https://github.com/trinodb/trino/issues/12971")\)
- Support reading tables with the property #raw("delta.columnMapping.mode=name"). \(#issue("12675", "https://github.com/trinodb/trino/issues/12675")\)
- Allow renaming tables with an explicitly set location. \(#issue("11400", "https://github.com/trinodb/trino/issues/11400")\)

== Elasticsearch connector

- Remove support for Elasticsearch versions below 6.6.0. \(#issue("11263", "https://github.com/trinodb/trino/issues/11263")\)

== Hive connector

- Improve performance of listing files and generating splits when recursive directory listings are enabled and tables are stored in S3. \(#issue("12443", "https://github.com/trinodb/trino/issues/12443")\)
- Fix incompatibility that prevents Apache Hive 3 and older from reading timestamp columns in files produced by Trino's optimized Parquet writer. \(#issue("12857 ", "https://github.com/trinodb/trino/issues/12857 ")\)
- Prevent reading from a table that was modified within the same Trino transaction. Previously, this returned incorrect query results. \(#issue("11769", "https://github.com/trinodb/trino/issues/11769")\)

== Iceberg connector

- Add support for reading #raw("tinyint") columns from ORC files. \(#issue("8919", "https://github.com/trinodb/trino/issues/8919")\)
- Add the ability to configure the schema for materialized view storage tables. \(#issue("12591", "https://github.com/trinodb/trino/issues/12591")\)
- Remove old deletion-tracking files when running #raw("optimize"). \(#issue("12617", "https://github.com/trinodb/trino/issues/12617")\)
- Fix failure when invoking the #raw("rollback_to_snapshot") procedure. \(#issue("12887", "https://github.com/trinodb/trino/issues/12887")\)
- Fix query failure when reading the #raw("$partitions") table after table partitioning changed. \(#issue("12874", "https://github.com/trinodb/trino/issues/12874")\)
