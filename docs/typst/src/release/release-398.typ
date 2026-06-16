#import "/lib/trino-docs.typ": *

#anchor("doc-release-release-398")
= Release 398 \(28 Sep 2022\)

== General

- Add Hudi connector. \(#issue("10228", "https://github.com/trinodb/trino/issues/10228")\)
- Add metrics for the execution time of filters and projections to #raw("EXPLAIN ANALYZE VERBOSE"). \(#issue("14135", "https://github.com/trinodb/trino/issues/14135")\)
- Show local cost estimates when using #raw("EXPLAIN"). \(#issue("14268", "https://github.com/trinodb/trino/issues/14268")\)
- Fix timeouts happening too early because of improper handling of the #raw("node-scheduler.allowed-no-matching-node-period") configuration property. \(#issue("14256", "https://github.com/trinodb/trino/issues/14256")\)
- Fix query failure for #raw("MERGE") queries when #raw("task_writer_count") is greater than one. \(#issue("14306", "https://github.com/trinodb/trino/issues/14306")\)

== Accumulo connector

- Add support for column comments when creating a new table. \(#issue("14114", "https://github.com/trinodb/trino/issues/14114")\)
- Move column mapping and index information into the output of #raw("DESCRIBE") instead of a comment. \(#issue("14095", "https://github.com/trinodb/trino/issues/14095")\)

== BigQuery connector

- Fix improper escaping of backslash and newline characters. \(#issue("14254", "https://github.com/trinodb/trino/issues/14254")\)
- Fix query failure when the predicate involves a #raw("varchar") value with a backslash. \(#issue("14254", "https://github.com/trinodb/trino/issues/14254")\)

== ClickHouse connector

- Upgrade minimum required Clickhouse version to 21.8. \(#issue("14112", "https://github.com/trinodb/trino/issues/14112")\)

== Delta Lake connector

- Improve performance when reading Parquet files for queries with predicates. \(#issue("14247", "https://github.com/trinodb/trino/issues/14247")\)

== Elasticsearch connector

- Deprecate support for query pass-through using the special #raw("<index>$query:<es-query>") dynamic tables in favor of the #raw("raw_query") table function. Legacy behavior can be re-enabled with the #raw("elasticsearch.legacy-pass-through-query.enabled") configuration property. \(#issue("14015", "https://github.com/trinodb/trino/issues/14015")\)

== Hive connector

- Add support for partitioned views when legacy mode for view translation is enabled. \(#issue("14028", "https://github.com/trinodb/trino/issues/14028")\)
- Extend the #raw("flush_metadata_cache") procedure to be able to flush table-related caches instead of only partition-related caches. \(#issue("14219", "https://github.com/trinodb/trino/issues/14219")\)
- Improve performance when reading Parquet files for queries with predicates. \(#issue("14247", "https://github.com/trinodb/trino/issues/14247")\)

== Iceberg connector

- Improve performance when reading Parquet files for queries with predicates. \(#issue("14247", "https://github.com/trinodb/trino/issues/14247")\)
- Fix potential table corruption when changing a table before it is known if committing to the Glue metastore has failed or succeeded. \(#issue("14174", "https://github.com/trinodb/trino/issues/14174")\)

== Pinot connector

- Add support for the #raw("timestamp") type. \(#issue("10199", "https://github.com/trinodb/trino/issues/10199")\)

== SPI

- Extend #raw("ConnectorMetadata.getStatisticsCollectionMetadata") to allow the connector to request the computation of any aggregation function during stats collection. \(#issue("14233", "https://github.com/trinodb/trino/issues/14233")\)
