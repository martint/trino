#import "/lib/trino-docs.typ": *

#anchor("doc-release-release-0-181")
= Release 0.181

== General

- Fix query failure and memory usage tracking when query contains #link(label("fn-transform-keys"), raw("transform_keys")) or #link(label("fn-transform-values"), raw("transform_values")).
- Prevent #raw("CREATE TABLE IF NOT EXISTS") queries from ever failing with #emph["Table already exists"].
- Fix query failure when #raw("ORDER BY") expressions reference columns that are used in the #raw("GROUP BY") clause by their fully-qualified name.
- Fix excessive GC overhead caused by large arrays and maps containing #raw("VARCHAR") elements.
- Improve error handling when passing too many arguments to various functions or operators that take a variable number of arguments.
- Improve performance of #raw("count(*)") aggregations over subqueries with known constant cardinality.
- Add #raw("VERBOSE") option for #link(label("doc-sql-explain-analyze"))[EXPLAIN ANALYZE] that provides additional low-level details about query performance.
- Add per-task distribution information to the output of #raw("EXPLAIN ANALYZE").
- Add support for #raw("DROP COLUMN") in #link(label("doc-sql-alter-table"))[ALTER TABLE].
- Change local scheduler to prevent starvation of long running queries when the cluster is under constant load from short queries. The new behavior is disabled by default and can be enabled by setting the config property #raw("task.level-absolute-priority=true").
- Improve the fairness of the local scheduler such that long-running queries which spend more time on the CPU per scheduling quanta \(e.g., due to slow connectors\) do not get a disproportionate share of CPU. The new behavior is disabled by default and can be enabled by setting the config property #raw("task.legacy-scheduling-behavior=false").
- Add a config option to control the prioritization of queries based on elapsed scheduled time. The #raw("task.level-time-multiplier") property controls the target scheduled time of a level relative to the next level. Higher values for this property increase the fraction of CPU that will be allocated to shorter queries. This config property only has an effect when #raw("task.level-absolute-priority=true") and #raw("task.legacy-scheduling-behavior=false").

== Hive

- Fix potential native memory leak when writing tables using RCFile.
- Correctly categorize certain errors when writing tables using RCFile.
- Decrease the number of file system metadata calls when reading tables.
- Add support for dropping columns.

== JDBC driver

- Add support for query cancellation using #raw("Statement.cancel()").

== PostgreSQL

- Add support for operations on external tables.

== Accumulo

- Improve query performance by scanning index ranges in parallel.

== SPI

- Fix regression that broke serialization for #raw("SchemaTableName").
- Add access control check for #raw("DROP COLUMN").
