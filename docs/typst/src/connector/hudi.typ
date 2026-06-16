#import "/lib/trino-docs.typ": *

#anchor("doc-connector-hudi")
= Hudi connector

The Hudi connector enables querying #link("https://hudi.apache.org/docs/overview/")[Hudi] tables.

== Requirements

To use the Hudi connector, you need:

- Hudi version 0.12.3 or higher.
- Network access from the Trino coordinator and workers to the Hudi storage.
- Access to a Hive metastore service \(HMS\).
- Network access from the Trino coordinator to the HMS.
- Data files stored in the #link(label("ref-parquet-format-configuration"))[Parquet file format] on a #link(label("ref-hudi-file-system-configuration"))[supported file system].

== General configuration

To configure the Hudi connector, create a catalog properties file #raw("etc/catalog/example.properties") that references the #raw("hudi") connector.

You must configure a #link(label("doc-object-storage-metastores"))[metastore for table metadata].

You must select and configure one of the #link(label("ref-hudi-file-system-configuration"))[supported file systems].

#code-block("properties", "connector.name=hudi
hive.metastore.uri=thrift://example.net:9083
fs.x.enabled=true")

Replace the #raw("fs.x.enabled") configuration property with the desired file system.

There are #link(label("ref-general-metastore-properties"))[HMS configuration properties] available for use with the Hudi connector. The connector recognizes Hudi tables synced to the metastore by the #link("https://hudi.apache.org/docs/syncing_metastore")[Hudi sync tool].

Additionally, following configuration properties can be set depending on the use-case:

#list-table((
  ([Property name], [Description], [Default],),
  ([#raw("hudi.columns-to-hide")], [List of column names that are hidden from the query output. It can be used to hide Hudi meta fields. By default, no fields are hidden.], [],),
  ([#raw("hudi.parquet.use-column-names")], [Access Parquet columns using names from the file. If disabled, then columns are accessed using the index. Only applicable to Parquet file format.], [#raw("true")],),
  ([#raw("hudi.split-generator-parallelism")], [Number of threads to generate splits from partitions.], [#raw("4")],),
  ([#raw("hudi.split-loader-parallelism")], [Number of threads to run background split loader. A single background split loader is needed per query.], [#raw("4")],),
  ([#raw("hudi.size-based-split-weights-enabled")], [Unlike uniform splitting, size-based splitting ensures that each batch of splits has enough data to process. By default, it is enabled to improve performance.], [#raw("true")],),
  ([#raw("hudi.standard-split-weight-size")], [The split size corresponding to the standard weight \(1.0\) when size-based split weights are enabled.], [#raw("128MB")],),
  ([#raw("hudi.minimum-assigned-split-weight")], [Minimum weight that a split can be assigned when size-based split weights are enabled.], [#raw("0.05")],),
  ([#raw("hudi.max-splits-per-second")], [Rate at which splits are queued for processing. The queue is throttled if this rate limit is breached.], [#raw("Integer.MAX_VALUE")],),
  ([#raw("hudi.max-outstanding-splits")], [Maximum outstanding splits in a batch enqueued for processing.], [#raw("1000")],),
  ([#raw("hudi.per-transaction-metastore-cache-maximum-size")], [Maximum number of metastore data objects per transaction in the Hive metastore cache.], [#raw("2000")],),
  ([#raw("hudi.query-partition-filter-required")], [Set to #raw("true") to force a query to use a partition column in the filter condition. The equivalent catalog session property is #raw("query_partition_filter_required"). Enabling this property causes query failures if the partition column used in the filter condition doesn't effectively reduce the number of data files read. Example: Complex filter expressions such as #raw("id = 1 OR part_key = '100'") or #raw("CAST(part_key AS INTEGER) % 2 = 0") are not recognized as partition filters, and queries using such expressions fail if the property is set to #raw("true").], [#raw("false")],),
  ([#raw("hudi.ignore-absent-partitions")], [Ignore partitions when the file system location does not exist rather than failing the query. This skips data that may be expected to be part of the table.], [#raw("false")],)
), header-rows: 1, title: "Hudi configuration properties")

#anchor("ref-hudi-file-system-configuration")

== File system access configuration

The connector supports accessing the following file systems:

- #link(label("doc-object-storage-file-system-azure"))[Azure Storage file system support]
- #link(label("doc-object-storage-file-system-gcs"))[Google Cloud Storage file system support]
- #link(label("doc-object-storage-file-system-s3"))[S3 file system support]
- #link(label("doc-object-storage-file-system-hdfs"))[HDFS file system support]

Enable and configure the file system that your catalog uses. Use #raw("fs.hadoop.enabled") only for HDFS; see #link(label("ref-file-system-legacy"))[legacy file system support] for migration details.

== SQL support

The connector provides read access to data in the Hudi table that has been synced to Hive metastore. The #link(label("ref-sql-globally-available"))[globally available] and #link(label("ref-sql-read-operations"))[read operation] statements are supported.

=== Basic usage examples

In the following example queries, #raw("stock_ticks_cow") is the Hudi copy-on-write table referred to in the Hudi #link("https://hudi.apache.org/docs/docker_demo/")[quickstart guide].

#code-block("sql", "USE example.example_schema;

SELECT symbol, max(ts)
FROM stock_ticks_cow
GROUP BY symbol
HAVING symbol = 'GOOG';")

#code-block("text", "  symbol   |        _col1         |
-----------+----------------------+
 GOOG      | 2018-08-31 10:59:00  |
(1 rows)")

#code-block("sql", "SELECT dt, symbol
FROM stock_ticks_cow
WHERE symbol = 'GOOG';")

#code-block("text", "    dt      | symbol |
------------+--------+
 2018-08-31 |  GOOG  |
(1 rows)")

#code-block("sql", "SELECT dt, count(*)
FROM stock_ticks_cow
GROUP BY dt;")

#code-block("text", "    dt      | _col1 |
------------+--------+
 2018-08-31 |  99  |
(1 rows)")

=== Schema and table management

Hudi supports #link("https://hudi.apache.org/docs/table_types")[two types of tables] depending on how the data is indexed and laid out on the file system. The following table displays a support matrix of tables types and query types for the connector:

#list-table((
  ([Table type], [Supported query type],),
  ([Copy on write], [Snapshot queries],),
  ([Merge on read], [Read-optimized queries],)
), header-rows: 1, title: "Hudi configuration properties")

==== Table properties

The following table properties are available for use:

#list-table((
  ([Property name], [Description],),
  ([#raw("location")], [File system location URI for the table.],),
  ([#raw("partitioned_by")], [Partition columns for the table.],)
), header-rows: 1, title: "Hudi table properties")

#anchor("ref-hudi-metadata-tables")

==== Metadata tables

The connector exposes a metadata table for each Hudi table. The metadata table contains information about the internal structure of the Hudi table. You can query each metadata table by appending the metadata table name to the table name:

#code-block(none, "SELECT * FROM \"test_table$timeline\"")

===== #raw("$timeline") table

The #raw("$timeline") table provides a detailed view of meta-data instants in the Hudi table. Instants are specific points in time.

You can retrieve the information about the timeline of the Hudi table #raw("test_table") by using the following query:

#code-block(none, "SELECT * FROM \"test_table$timeline\"")

#code-block("text", " timestamp          | action  | state
--------------------+---------+-----------
8667764846443717831 | commit  | COMPLETED
7860805980949777961 | commit  | COMPLETED")

The output of the query has the following columns:

#list-table((
  ([Name], [Type], [Description],),
  ([#raw("timestamp")], [#raw("VARCHAR")], [Instant time is typically a timestamp when the actions performed.],),
  ([#raw("action")], [#raw("VARCHAR")], [#link("https://hudi.apache.org/docs/concepts/#timeline")[Type of action] performed on the table.],),
  ([#raw("state")], [#raw("VARCHAR")], [Current state of the instant.],)
), header-rows: 1, title: "Timeline columns")
