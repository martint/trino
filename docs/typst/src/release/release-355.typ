#import "/lib/trino-docs.typ": *

#anchor("doc-release-release-355")
= Release 355 \(8 Apr 2021\)

== General

- Report tables that are directly referenced by a query in #raw("QueryCompletedEvent"). \(#issue("7330", "https://github.com/trinodb/trino/issues/7330")\)
- Report columns that are the target of #raw("INSERT") or #raw("UPDATE") queries in #raw("QueryCompletedEvent"). This includes information about which input columns they are derived from. \(#issue("7425", "https://github.com/trinodb/trino/issues/7425"), #issue("7465", "https://github.com/trinodb/trino/issues/7465")\)
- Rename #raw("optimizer.plan-with-table-node-partitioning") config property to #raw("optimizer.use-table-scan-node-partitioning"). \(#issue("7257", "https://github.com/trinodb/trino/issues/7257")\)
- Improve query parallelism when table bucket count is small compared to number of nodes. This optimization is now triggered automatically when the ratio between table buckets and possible table scan tasks exceeds or is equal to #raw("optimizer.table-scan-node-partitioning-min-bucket-to-task-ratio"). \(#issue("7257", "https://github.com/trinodb/trino/issues/7257")\)
- Include information about #link(label("doc-admin-spill"))[Spill to disk] in #link(label("doc-sql-explain-analyze"))[EXPLAIN ANALYZE]. \(#issue("7427", "https://github.com/trinodb/trino/issues/7427")\)
- Disallow inserting data into tables that have row filters. \(#issue("7346", "https://github.com/trinodb/trino/issues/7346")\)
- Improve performance of queries that can benefit from both #link(label("doc-optimizer-cost-based-optimizations"))[Cost-based optimizations] and join pushdown by giving precedence to cost-based optimizations. \(#issue("7331", "https://github.com/trinodb/trino/issues/7331")\)
- Fix inconsistent behavior for #link(label("fn-to-unixtime"), raw("to_unixtime")) with values of type #raw("timestamp(p)"). \(#issue("7450", "https://github.com/trinodb/trino/issues/7450")\)
- Change return type of #link(label("fn-from-unixtime"), raw("from_unixtime")) and #link(label("fn-from-unixtime-nanos"), raw("from_unixtime_nanos")) to #raw("timestamp(p) with time zone"). \(#issue("7460", "https://github.com/trinodb/trino/issues/7460")\)

== Security

- Add support for configuring multiple password authentication plugins. \(#issue("7151", "https://github.com/trinodb/trino/issues/7151")\)

== JDBC driver

- Add #raw("assumeLiteralNamesInMetadataCallsForNonConformingClients") parameter for use as a workaround when applications do not properly escape schema or table names in calls to #raw("DatabaseMetaData") methods. \(#issue("7438", "https://github.com/trinodb/trino/issues/7438")\)

== ClickHouse connector

- Support creating tables with MergeTree storage engine. \(#issue("7135", "https://github.com/trinodb/trino/issues/7135")\)

== Hive connector

- Support Hive views containing #raw("LATERAL VIEW json_tuple(...) AS ...") syntax. \(#issue("7242", "https://github.com/trinodb/trino/issues/7242")\)
- Fix incorrect results when reading from a Hive view that uses array subscript operators. \(#issue("7271", "https://github.com/trinodb/trino/issues/7271")\)
- Fix incorrect results when querying the #raw("$file_modified_time") hidden column. \(#issue("7511", "https://github.com/trinodb/trino/issues/7511")\)

== Phoenix connector

- Improve performance when fetching table metadata during query analysis. \(#issue("6975", "https://github.com/trinodb/trino/issues/6975")\)
- Improve performance of queries with #raw("ORDER BY ... LIMIT") clause when the computation can be pushed down to the underlying database. \(#issue("7490", "https://github.com/trinodb/trino/issues/7490")\)

== SQL Server connector

- Improve performance when fetching table metadata during query analysis. \(#issue("6975", "https://github.com/trinodb/trino/issues/6975")\)

== SPI

- Engine now uses #raw("ConnectorMaterializedViewDefinition#storageTable") to determine materialized view storage table. \(#issue("7319", "https://github.com/trinodb/trino/issues/7319")\)
