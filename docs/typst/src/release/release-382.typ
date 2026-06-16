#import "/lib/trino-docs.typ": *

#anchor("doc-release-release-382")
= Release 382 \(25 May 2022\)

== General

- Add support for fault-tolerant execution with #link(label("ref-fte-exchange-gcs"))[exchange spooling on Google Cloud Storage]. \(#issue("12360", "https://github.com/trinodb/trino/issues/12360")\)
- Drop support for exchange spooling on S3 with for the legacy schemes #raw("s3n://") and #raw("s3a://"). \(#issue("12360", "https://github.com/trinodb/trino/issues/12360")\)
- Improve join performance when one side of the join is small. \(#issue("12257", "https://github.com/trinodb/trino/issues/12257")\)
- Fix potential query failures due to #raw("EXCEEDED_TASK_DESCRIPTOR_STORAGE_CAPACITY") errors with task-based fault-tolerant execution. \(#issue("12478", "https://github.com/trinodb/trino/issues/12478")\)

== BigQuery connector

- Add support for #link("https://cloud.google.com/bigquery/docs/cached-results")[using BigQuery's cached query results]. This can be enabled using the #raw("bigquery.query-results-cache.enabled") configuration property. \(#issue("12408", "https://github.com/trinodb/trino/issues/12408")\)
- Support reading wildcard tables. \(#issue("4124", "https://github.com/trinodb/trino/issues/4124")\)

== Delta Lake connector

- Improve performance of queries that include filters on columns of #raw("timestamp with time zone") type. \(#issue("12007", "https://github.com/trinodb/trino/issues/12007")\)
- Add support for adding columns with #raw("ALTER TABLE"). \(#issue("12371", "https://github.com/trinodb/trino/issues/12371")\)

== Hive connector

- Add support for disabling partition caching in the Hive metastore with the #raw("hive.metastore-cache.cache-partitions") catalog configuration property. \(#issue("12343", "https://github.com/trinodb/trino/issues/12343")\)
- Fix potential query failure when metastore caching is enabled. \(#issue("12513", "https://github.com/trinodb/trino/issues/12513")\)
- Fix query failure when a transactional table contains a column named #raw("operation"), #raw("originalTransaction"), #raw("bucket"), #raw("rowId"), #raw("row"), or #raw("currentTransaction"). \(#issue("12401", "https://github.com/trinodb/trino/issues/12401")\)
- Fix #raw("sync_partition_metadata") procedure failure when table has a large number of partitions. \(#issue("12525", "https://github.com/trinodb/trino/issues/12525")\)

== Iceberg connector

- Support updating Iceberg table partitioning using #raw("ALTER TABLE ... SET PROPERTIES"). \(#issue("12174", "https://github.com/trinodb/trino/issues/12174")\)
- Improves the performance of queries using equality and #raw("IN") predicates when reading ORC data that contains Bloom filters. \(#issue("11732", "https://github.com/trinodb/trino/issues/11732")\)
- Rename the #raw("delete_orphan_files") table procedure to #raw("remove_orphan_files"). \(#issue("12468", "https://github.com/trinodb/trino/issues/12468")\)
- Improve query performance of reads after #raw("DELETE") removes all rows from a file. \(#issue("12197", "https://github.com/trinodb/trino/issues/12197")\)

== MySQL connector

- Improve #raw("INSERT") performance. \(#issue("12411", "https://github.com/trinodb/trino/issues/12411")\)

== Oracle connector

- Improve #raw("INSERT") performance when data includes #raw("NULL") values. \(#issue("12400", "https://github.com/trinodb/trino/issues/12400")\)

== PostgreSQL connector

- Improve #raw("INSERT") performance. \(#issue("12417", "https://github.com/trinodb/trino/issues/12417")\)

== Prometheus connector

- Add support for Basic authentication. \(#issue("12302", "https://github.com/trinodb/trino/issues/12302")\)

== SPI

- Change #raw("ConnectorTableFunction") into an interface and add #raw("AbstractConnectorTableFunction") class as the base implementation of table functions. \(#issue("12531", "https://github.com/trinodb/trino/issues/12531")\)
