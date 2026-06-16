#import "/lib/trino-docs.typ": *

#anchor("doc-release-release-468")
= Release 468 \(17 Dec 2024\)

== General

- Add support for #link(label("doc-udf-python"))[Python user-defined functions]. \(#issue("24378", "https://github.com/trinodb/trino/issues/24378")\)
- Add cluster overview to the #link(label("doc-admin-preview-web-interface"))[Preview Web UI]. \(#issue("23600", "https://github.com/trinodb/trino/issues/23600")\)
- Add new node states #raw("DRAINING") and #raw("DRAINED") to make it possible to reactivate a draining worker node. \(#issue("24444 ", "https://github.com/trinodb/trino/issues/24444 ")\)

== BigQuery connector

- Improve performance when reading external #link("https://cloud.google.com/bigquery/docs/biglake-intro")[BigLake] tables. \(#issue("21016", "https://github.com/trinodb/trino/issues/21016")\)

== Delta Lake connector

- #breaking-marker("../release.html#breaking-changes") Reduce coordinator memory usage for the Delta table metadata cache and enable configuration #raw("delta.metadata.cache-max-retained-size") to control memory usage. Remove the configuration property #raw("delta.metadata.cache-size") and increase the default for #raw("delta.metadata.cache-ttl") to #raw("30m"). \(#issue("24432", "https://github.com/trinodb/trino/issues/24432")\)

== Hive connector

- Enable mismatched bucket execution optimization by default. This can be disabled with #raw("hive.optimize-mismatched-bucket-count") configuration property and the #raw("optimize_mismatched_bucket_count") session property. \(#issue("23432", "https://github.com/trinodb/trino/issues/23432")\)
- Improve performance by deactivating bucket execution when not useful in query processing. \(#issue("23432", "https://github.com/trinodb/trino/issues/23432")\)

== Iceberg connector

- Improve performance when running a join or aggregation on a bucketed table with bucketed execution. This can be deactivated with the #raw("iceberg.bucket-execution") configuration property and the #raw("bucket_execution_enabled") session property. \(#issue("23432", "https://github.com/trinodb/trino/issues/23432")\)
- Deprecate the #raw("iceberg.materialized-views.storage-schema") configuration property. \(#issue("24398", "https://github.com/trinodb/trino/issues/24398")\)
- #breaking-marker("../release.html#breaking-changes") Rename the #raw("partitions") column in the #raw("$manifests") metadata table to #raw("partition_summaries"). \(#issue("24103", "https://github.com/trinodb/trino/issues/24103")\)
- Avoid excessive resource usage on coordinator when reading Iceberg system tables. \(#issue("24396", "https://github.com/trinodb/trino/issues/24396")\)

== PostgreSQL connector

- Add support for non-transactional #link(label("doc-sql-merge"))[MERGE statements]. \(#issue("23034", "https://github.com/trinodb/trino/issues/23034")\)

== SPI

- Add partitioning push down, which a connector can use to activate optional partitioning or choose between multiple partitioning strategies. \(#issue("23432", "https://github.com/trinodb/trino/issues/23432")\)
