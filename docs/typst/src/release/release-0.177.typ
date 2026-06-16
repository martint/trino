#import "/lib/trino-docs.typ": *

#anchor("doc-release-release-0-177")
= Release 0.177

#warning[
Query may incorrectly produce #raw("NULL") when no row qualifies for the aggregation if the #raw("optimize_mixed_distinct_aggregations") session property or the #raw("optimizer.optimize-mixed-distinct-aggregations") config option is enabled. This optimization was introduced in Presto version 0.156.
]

== General

- Fix correctness issue when performing range comparisons over columns of type #raw("CHAR").
- Fix correctness issue due to mishandling of nulls and non-deterministic expressions in inequality joins unless #raw("fast_inequality_join") is disabled.
- Fix excessive GC overhead caused by lambda expressions. There are still known GC issues with captured lambda expressions. This will be fixed in a future release.
- Check for duplicate columns in #raw("CREATE TABLE") before asking the connector to create the table. This improves the error message for most connectors and will prevent errors for connectors that do not perform validation internally.
- Add support for null values on the left-hand side of a semijoin \(i.e., #raw("IN") predicate with subqueries\).
- Add #raw("SHOW STATS") to display table and query statistics.
- Improve implicit coercion support for functions involving lambda. Specifically, this makes it easier to use the #link(label("fn-reduce"), raw("reduce")) function.
- Improve plans for queries involving #raw("ORDER BY") and #raw("LIMIT") by avoiding unnecessary data exchanges.
- Improve performance of queries containing window functions with identical #raw("PARTITION BY") and #raw("ORDER BY") clauses.
- Improve performance of certain queries involving #raw("OUTER JOIN") and aggregations, or containing certain forms of correlated subqueries. This optimization is experimental and can be turned on via the #raw("push_aggregation_through_join") session property or the #raw("optimizer.push-aggregation-through-join") config option.
- Improve performance of certain queries involving joins and aggregations.  This optimization is experimental and can be turned on via the #raw("push_partial_aggregation_through_join") session property.
- Improve error message when a lambda expression has a different number of arguments than expected.
- Improve error message when certain invalid #raw("GROUP BY") expressions containing lambda expressions.

== Hive

- Fix handling of trailing spaces for the #raw("CHAR") type when reading RCFile.
- Allow inserts into tables that have more partitions than the partitions-per-scan limit.
- Add support for exposing Hive table statistics to the engine. This option is experimental and can be turned on via the #raw("statistics_enabled") session property.
- Ensure file name is always present for error messages about corrupt ORC files.

== Cassandra

- Remove caching of metadata in the Cassandra connector. Metadata caching makes Presto violate the consistency defined by the Cassandra cluster. It's also unnecessary because the Cassandra driver internally caches metadata. The #raw("cassandra.max-schema-refresh-threads"), #raw("cassandra.schema-cache-ttl") and #raw("cassandra.schema-refresh-interval") config options have been removed.
- Fix intermittent issue in the connection retry mechanism.

== Web UI

- Change cluster HUD realtime statistics to be aggregated across all running queries.
- Change parallelism statistic on cluster HUD to be averaged per-worker.
- Fix bug that always showed indeterminate progress bar in query list view.
- Change running drivers statistic to exclude blocked drivers.
- Change unit of CPU and scheduled time rate sparklines to seconds on query details page.
- Change query details page refresh interval to three seconds.
- Add uptime and connected status indicators to every page.

== CLI

- Add support for preprocessing commands.  When the #raw("PRESTO_PREPROCESSOR") environment variable is set, all commands are piped through the specified program before being sent to the Presto server.
