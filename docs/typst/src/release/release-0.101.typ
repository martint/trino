#import "/lib/trino-docs.typ": *

#anchor("doc-release-release-0-101")
= Release 0.101

== General

- Add support for #link(label("doc-sql-create-table"))[CREATE TABLE] \(in addition to #link(label("doc-sql-create-table-as"))[CREATE TABLE AS]\).
- Add #raw("IF EXISTS") support to #link(label("doc-sql-drop-table"))[DROP TABLE] and #link(label("doc-sql-drop-view"))[DROP VIEW].
- Add #link(label("fn-array-agg"), raw("array_agg")) function.
- Add #link(label("fn-array-intersect"), raw("array_intersect")) function.
- Add #link(label("fn-array-position"), raw("array_position")) function.
- Add #link(label("fn-regexp-split"), raw("regexp_split")) function.
- Add support for #raw("millisecond") to #link(label("fn-date-diff"), raw("date_diff")) and #link(label("fn-date-add"), raw("date_add")).
- Fix excessive memory usage in #link(label("fn-map-agg"), raw("map_agg")).
- Fix excessive memory usage in queries that perform partitioned top-N operations with #link(label("fn-row-number"), raw("row_number")).
- Optimize #link(label("ref-array-type"))[array-type] comparison operators.
- Fix analysis of #raw("UNION") queries for tables with hidden columns.
- Fix #raw("JOIN") associativity to be left-associative instead of right-associative.
- Add #raw("source") column to #raw("runtime.queries") table in #link(label("doc-connector-system"))[System connector].
- Add #raw("coordinator") column to #raw("runtime.nodes") table in #link(label("doc-connector-system"))[System connector].
- Add #raw("errorCode"), #raw("errorName") and #raw("errorType") to #raw("error") object in REST API \(#raw("errorCode") previously existed but was always zero\).
- Fix #raw("DatabaseMetaData.getIdentifierQuoteString()") in JDBC driver.
- Handle thread interruption in JDBC driver #raw("ResultSet").
- Add #raw("history") command and support for running previous commands via #raw("!n") to the CLI.
- Change Driver to make as much progress as possible before blocking.  This improves responsiveness of some limit queries.
- Add predicate push down support to JMX connector.
- Add support for unary #raw("PLUS") operator.
- Improve scheduling speed by reducing lock contention.
- Extend optimizer to understand physical properties such as local grouping and sorting.
- Add support for streaming execution of window functions.
- Make #raw("UNION") run partitioned, if underlying plan is partitioned.
- Add #raw("hash_partition_count") session property to control hash partitions.

== Web UI

The main page of the web UI has been completely rewritten to use ReactJS. It also has a number of new features, such as the ability to pause auto-refresh via the "Z" key and also with a toggle in the UI.

== Hive

- Add support for connecting to S3 using EC2 instance credentials. This feature is enabled by default. To disable it, set #raw("hive.s3.use-instance-credentials=false") in your Hive catalog properties file.
- Treat ORC files as splittable.
- Change PrestoS3FileSystem to use lazy seeks, which improves ORC performance.
- Fix ORC #raw("DOUBLE") statistic for columns containing #raw("NaN").
- Lower the Hive metadata refresh interval from two minutes to one second.
- Invalidate Hive metadata cache for failed operations.
- Support #raw("s3a") file system scheme.
- Fix discovery of splits to correctly backoff when the queue is full.
- Add support for non-canonical Parquet structs.
- Add support for accessing Parquet columns by name. By default, columns in Parquet files are accessed by their ordinal position in the Hive table definition. To access columns based on the names recorded in the Parquet file, set #raw("hive.parquet.use-column-names=true") in your Hive catalog properties file.
- Add JMX stats to PrestoS3FileSystem.
- Add #raw("hive.recursive-directories") config option to recursively scan partition directories for data.

== SPI

- Add connector callback for rollback of #raw("INSERT") and #raw("CREATE TABLE AS").
- Introduce an abstraction for representing physical organizations of a table and describing properties such as partitioning, grouping, predicate and columns. #raw("ConnectorPartition") and related interfaces are deprecated and will be removed in a future version.
- Rename #raw("ConnectorColumnHandle") to #raw("ColumnHandle").

#note[
This is a backwards incompatible change with the previous connector SPI. If you have written a connector, you will need to update your code before deploying this release.
]
