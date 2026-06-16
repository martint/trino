#import "/lib/trino-docs.typ": *

#anchor("doc-release-release-0-207")
= Release 0.207

== General

- Fix a planning issue for queries where correlated references were used in #raw("VALUES").
- Remove support for legacy #raw("JOIN ... USING") behavior.
- Change behavior for unnesting an array of #raw("row") type to produce multiple columns.
- Deprecate the #raw("reorder_joins") session property and the #raw("reorder-joins") configuration property. They are replaced by the #raw("join_reordering_strategy") session property and the #raw("optimizer.join-reordering-strategy") configuration property. #raw("NONE") maintains the order of the joins as written and is equivalent to #raw("reorder_joins=false"). #raw("ELIMINATE_CROSS_JOINS") will eliminate any unnecessary cross joins from the plan and is equivalent to #raw("reorder_joins=true"). #raw("AUTOMATIC") will use the new cost-based optimizer to select the best join order. To simplify migration, setting the #raw("reorder_joins") session property overrides the new session and configuration properties.
- Deprecate the #raw("distributed_joins") session property and the #raw("distributed-joins-enabled") configuration property. They are replaced by the #raw("join_distribution_type") session property and the #raw("join-distribution-type") configuration property. #raw("PARTITIONED") turns on hash partitioned joins and is equivalent to #raw("distributed_joins-enabled=true"). #raw("BROADCAST") changes the join strategy to broadcast and is equivalent to #raw("distributed_joins-enabled=false"). #raw("AUTOMATIC") will use the new cost-based optimizer to select the best join strategy. If no statistics are available, #raw("AUTOMATIC") is the same as #raw("REPARTITIONED"). To simplify migration, setting the #raw("distributed_joins") session property overrides the new session and configuration properties.
- Add support for column properties.
- Add #raw("optimizer.max-reordered-joins") configuration property to set the maximum number of joins that can be reordered at once using cost-based join reordering.
- Add support for #raw("char") type to #link(label("fn-approx-distinct"), raw("approx_distinct")).

== Security

- Fail on startup when configuration for file based system access control is invalid.
- Add support for securing communication between cluster nodes with Kerberos authentication.

== Web UI

- Add peak total \(user + system\) memory to query details UI.

== Hive connector

- Fix handling of #raw("VARCHAR(length)") type in the optimized Parquet reader. Previously, predicate pushdown failed with #raw("Mismatched Domain types: varchar(length) vs varchar").
- Fail on startup when configuration for file based access control is invalid.
- Add support for HDFS wire encryption.
- Allow ORC files to have struct columns with missing fields. This allows the table schema to be changed without rewriting the ORC files.
- Change collector for columns statistics to only consider a sample of partitions. The sample size can be changed by setting the #raw("hive.partition-statistics-sample-size") property.

== Memory connector

- Add support for dropping schemas.

== SPI

- Remove deprecated table\/view-level access control methods.
- Change predicate in constraint for accessing table layout to be optional.
- Change schema name in #raw("ConnectorMetadata") to be optional rather than nullable.
