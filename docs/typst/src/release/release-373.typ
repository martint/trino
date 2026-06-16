#import "/lib/trino-docs.typ": *

#anchor("doc-release-release-373")
= Release 373 \(9 Mar 2022\)

== General

- Add #link(label("doc-connector-delta-lake"))[Delta Lake connector]. \(#issue("11296", "https://github.com/trinodb/trino/issues/11296"), #issue("10897", "https://github.com/trinodb/trino/issues/10897")\)
- Improve query performance by reducing overhead of cluster internal communication. \(#issue("11146", "https://github.com/trinodb/trino/issues/11146")\)
- Handle #raw("varchar") to #raw("timestamp") conversion errors in #link(label("fn-try"), raw("try")). \(#issue("11259", "https://github.com/trinodb/trino/issues/11259")\)
- Add redirection awareness for #raw("DROP COLUMN") task. \(#issue("11304", "https://github.com/trinodb/trino/issues/11304")\)
- Add redirection awareness for #raw("RENAME COLUMN") task. \(#issue("11226", "https://github.com/trinodb/trino/issues/11226")\)
- Disallow table redirections in #raw("SHOW GRANTS") statement. \(#issue("11270", "https://github.com/trinodb/trino/issues/11270")\)
- Allow low memory killer to abort individual tasks when #raw("retry-mode") is set to #raw("TASK"). This requires #raw("query.low-memory-killer.policy") set to #raw("total-reservation-on-blocked-nodes"). \(#issue("11129", "https://github.com/trinodb/trino/issues/11129")\)
- Fix incorrect results when distinct or ordered aggregation are used and spilling is enabled. \(#issue("11353", "https://github.com/trinodb/trino/issues/11353")\)

== Web UI

- Add CPU time, scheduled time, and cumulative memory statistics regarding failed tasks in a query. \(#issue("10754", "https://github.com/trinodb/trino/issues/10754")\)

== BigQuery connector

- Allow configuring view expiration time via the #raw("bigquery.view-expire-duration") config property. \(#issue("11272", "https://github.com/trinodb/trino/issues/11272")\)

== Elasticsearch connector

- Improve performance of queries involving #raw("LIKE") by pushing predicate computation to the Elasticsearch cluster. \(#issue("7994", "https://github.com/trinodb/trino/issues/7994"), #issue("11308", "https://github.com/trinodb/trino/issues/11308")\)

== Hive connector

- Support access to S3 via a HTTP proxy. \(#issue("11255", "https://github.com/trinodb/trino/issues/11255")\)
- Improve query performance by better estimating partitioned tables statistics. \(#issue("11333", "https://github.com/trinodb/trino/issues/11333")\)
- Prevent failure for queries with the final number of partitions below #raw("HIVE_EXCEEDED_PARTITION_LIMIT"). \(#issue("10215", "https://github.com/trinodb/trino/issues/10215")\)
- Fix issue where duplicate rows could be inserted into a partition when #raw("insert_existing_partitions_behavior") was set to #raw("OVERWRITE") and #raw("retry-policy") was #raw("TASK"). \(#issue("11196", "https://github.com/trinodb/trino/issues/11196")\)
- Fix failure when querying Hive views containing column aliases that differ in case only. \(#issue("11159", "https://github.com/trinodb/trino/issues/11159")\)

== Iceberg connector

- Support access to S3 via a HTTP proxy. \(#issue("11255", "https://github.com/trinodb/trino/issues/11255")\)
- Delete table data when dropping table. \(#issue("11062", "https://github.com/trinodb/trino/issues/11062")\)
- Fix #raw("SHOW TABLES") failure when a materialized view is removed during query execution. \(#issue("10976", "https://github.com/trinodb/trino/issues/10976")\)
- Fix query failure when reading from #raw("information_schema.tables") or #raw("information_schema.columns") and a materialized view is removed during query execution. \(#issue("10976", "https://github.com/trinodb/trino/issues/10976")\)

== Oracle connector

- Fix query failure when performing concurrent write operations. \(#issue("11318", "https://github.com/trinodb/trino/issues/11318")\)

== Phoenix connector

- Prevent writing incorrect results when arrays contain #raw("null") values. \(#issue("11351", "https://github.com/trinodb/trino/issues/11351")\)

== PostgreSQL connector

- Improve performance of queries involving #raw("LIKE") by pushing predicate computation to the underlying database. \(#issue("11045", "https://github.com/trinodb/trino/issues/11045")\)

== SQL Server connector

- Fix incorrect results when querying SQL Server #raw("tinyint") columns by mapping them to Trino #raw("smallint"). \(#issue("11209", "https://github.com/trinodb/trino/issues/11209")\)

== SPI

- Add CPU time, scheduled time, and cumulative memory statistics regarding failed tasks in a query to query-completion events. \(#issue("10734", "https://github.com/trinodb/trino/issues/10734")\)
