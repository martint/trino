#import "/lib/trino-docs.typ": *

#anchor("doc-connector-delta-lake")
= Delta Lake connector

The Delta Lake connector allows querying data stored in the #link("https://delta.io")[Delta Lake] format, including #link("https://docs.databricks.com/delta/index.html")[Databricks Delta Lake]. The connector can natively read the Delta Lake transaction log and thus detect when external systems change data.

== Requirements

To connect to Databricks Delta Lake, you need:

- Tables written by Databricks Runtime 7.3 LTS, 9.1 LTS, 10.4 LTS, 11.3 LTS, 12.2 LTS, 13.3 LTS, 14.3 LTS, 15.4 LTS, 16.4 LTS and 17.3 LTS are supported.
- Deployments using AWS, HDFS, Azure Storage, and Google Cloud Storage \(GCS\) are fully supported.
- Network access from the coordinator and workers to the Delta Lake storage.
- Access to the Hive metastore service \(HMS\) of Delta Lake or a separate HMS, or a Glue metastore.
- Network access to the HMS from the coordinator and workers. Port 9083 is the default port for the Thrift protocol used by the HMS.
- Data files stored in the #link(label("ref-parquet-format-configuration"))[Parquet file format] on a #link(label("ref-delta-lake-file-system-configuration"))[supported file system].

== General configuration

To configure the Delta Lake connector, create a catalog properties file #raw("etc/catalog/example.properties") that references the #raw("delta_lake") connector.

You must configure a #link(label("doc-object-storage-metastores"))[metastore for metadata].

You must select and configure one of the #link(label("ref-delta-lake-file-system-configuration"))[supported file systems].

#code-block("properties", "connector.name=delta_lake
hive.metastore.uri=thrift://example.net:9083
fs.x.enabled=true")

Replace the #raw("fs.x.enabled") configuration property with the desired file system.

If you are using #link(label("ref-hive-glue-metastore"))[AWS Glue] as your metastore, you must instead set #raw("hive.metastore") to #raw("glue"):

#code-block("properties", "connector.name=delta_lake
hive.metastore=glue")

Each metastore type has specific configuration properties along with #link(label("ref-general-metastore-properties"))[general metastore configuration properties].

The connector recognizes Delta Lake tables created in the metastore by the Databricks runtime. If non-Delta Lake tables are present in the metastore as well, they are not visible to the connector.

#anchor("ref-delta-lake-file-system-configuration")

== File system access configuration

The connector supports accessing the following file systems:

- #link(label("doc-object-storage-file-system-azure"))[Azure Storage file system support]
- #link(label("doc-object-storage-file-system-gcs"))[Google Cloud Storage file system support]
- #link(label("doc-object-storage-file-system-s3"))[S3 file system support]
- #link(label("doc-object-storage-file-system-hdfs"))[HDFS file system support]

Enable and configure the file system that your catalog uses. Use #raw("fs.hadoop.enabled") only for HDFS; see #link(label("ref-file-system-legacy"))[legacy file system support] for migration details.

=== Delta Lake general configuration properties

The following configuration properties are all using reasonable, tested default values. Typical usage does not require you to configure them.

#list-table((
  ([Property name], [Description], [Default],),
  ([#raw("delta.metadata.cache-ttl")], [Caching duration for Delta Lake tables metadata.], [#raw("30m")],),
  ([#raw("delta.metadata.cache-max-retained-size")], [Maximum retained size of Delta table metadata stored in cache. Must be specified in #link(label("ref-prop-type-data-size"))[Properties reference] values such as #raw("64MB"). Default is calculated to 5% of the maximum memory allocated to the JVM.], [],),
  ([#raw("delta.transaction-log.max-cached-file-size")], [Maximum size of delta transaction log file that will be cached in memory for the table metadata cache.], [#raw("16MB")],),
  ([#raw("delta.compression-codec")], [The compression codec to be used when writing new data files. Possible values are:

- #raw("NONE")
- #raw("SNAPPY")
- #raw("ZSTD")
- #raw("GZIP")

The equivalent catalog session property is #raw("compression_codec").], [#raw("ZSTD")],),
  ([#raw("delta.max-partitions-per-writer")], [Maximum number of partitions per writer.], [#raw("100")],),
  ([#raw("delta.idle-writer-min-file-size")], [Minimum data written by a single partition writer before it can be considered as idle and can be closed by the engine. The equivalent catalog session property is #raw("idle_writer_min_file_size").], [#raw("16MB")],),
  ([#raw("delta.hide-non-delta-lake-tables")], [Hide information about tables that are not managed by Delta Lake. Hiding only applies to tables with the metadata managed in a Glue catalog, and does not apply to usage with a Hive metastore service.], [#raw("false")],),
  ([#raw("delta.enable-non-concurrent-writes")], [Enable #link(label("ref-delta-lake-data-management"))[write support] for all supported file systems. Specifically, take note of the warning about concurrency and checkpoints.], [#raw("false")],),
  ([#raw("delta.default-checkpoint-writing-interval")], [Default integer count to write transaction log checkpoint entries. If the value is set to N, then checkpoints are written after every Nth statement performing table writes. The value can be overridden for a specific table with the #raw("checkpoint_interval") table property.], [#raw("10")],),
  ([#raw("delta.hive-catalog-name")], [Name of the catalog to which #raw("SELECT") queries are redirected when a Hive table is detected.], [],),
  ([#raw("delta.checkpoint-row-statistics-writing.enabled")], [Enable writing row statistics to checkpoint files.], [#raw("true")],),
  ([#raw("delta.dynamic-filtering.wait-timeout")], [Duration to wait for completion of #link(label("doc-admin-dynamic-filtering"))[dynamic filtering] during split generation. The equivalent catalog session property is #raw("dynamic_filtering_wait_timeout").], [],),
  ([#raw("delta.table-statistics-enabled")], [Enables #link(label("ref-delta-lake-table-statistics"))[Table statistics] for performance improvements. The equivalent catalog session property is #raw("statistics_enabled").], [#raw("true")],),
  ([#raw("delta.extended-statistics.enabled")], [Enable statistics collection with #link(label("doc-sql-analyze"))[ANALYZE] and use of extended statistics. The equivalent catalog session property is #raw("extended_statistics_enabled").], [#raw("true")],),
  ([#raw("delta.extended-statistics.collect-on-write")], [Enable collection of extended statistics for write operations. The equivalent catalog session property is #raw("extended_statistics_collect_on_write").], [#raw("true")],),
  ([#raw("delta.per-transaction-metastore-cache-maximum-size")], [Maximum number of metastore data objects per transaction in the Hive metastore cache.], [#raw("1000")],),
  ([#raw("delta.metastore.store-table-metadata")], [Store table comments and colum definitions in the metastore. The write permission is required to update the metastore.], [#raw("false")],),
  ([#raw("delta.metastore.store-table-metadata-threads")], [Number of threads used for storing table metadata in metastore.], [#raw("5")],),
  ([#raw("delta.delete-schema-locations-fallback")], [Whether schema locations are deleted when Trino can't determine whether they contain external files.], [#raw("false")],),
  ([#raw("delta.parquet.time-zone")], [Time zone used when reading timestamps from Parquet files.], [JVM default],),
  ([#raw("delta.target-max-file-size")], [Target maximum size of written files; the actual size could be larger. The equivalent catalog session property is #raw("target_max_file_size").], [#raw("1GB")],),
  ([#raw("delta.unique-table-location")], [Use randomized, unique table locations.], [#raw("true")],),
  ([#raw("delta.register-table-procedure.enabled")], [Enable to allow users to call the #link(label("ref-delta-lake-register-table"))[#raw("register_table") procedure].], [#raw("false")],),
  ([#raw("delta.vacuum.min-retention")], [Minimum retention threshold for the files taken into account for removal by the #link(label("ref-delta-lake-vacuum"))[VACUUM] procedure. The equivalent catalog session property is #raw("vacuum_min_retention").], [#raw("7 DAYS")],),
  ([#raw("delta.deletion-vectors-enabled")], [Set to #raw("true") for enabling deletion vectors by default when creating new tables.], [#raw("false")],),
  ([#raw("delta.metadata.parallelism")], [Number of threads used for retrieving metadata. Currently, only table loading is parallelized.], [#raw("8")],),
  ([#raw("delta.checkpoint-processing.parallelism")], [Number of threads used for retrieving checkpoint files of each table. Currently, only retrievals of V2 Checkpoint's sidecar files are parallelized.], [#raw("4")],),
  ([#raw("delta.load-metadata-from-checksum-file")], [Speed up query planning by reading table metadata and protocol entries from the Delta version checksum file \(#raw("<version>.crc")\) when available. Falls back to scanning the transaction log if the checksum file is missing, incomplete, or malformed. The equivalent catalog session property is #raw("load_metadata_from_checksum_file").], [#raw("true")],)
), header-rows: 1, title: "Delta Lake configuration properties")

=== Catalog session properties

The following table describes #link(label("ref-session-properties-definition"))[catalog session properties] supported by the Delta Lake connector:

#list-table((
  ([Property name], [Description], [Default],),
  ([#raw("parquet_max_read_block_size")], [The maximum block size used when reading Parquet files.], [#raw("16MB")],),
  ([#raw("parquet_writer_row_group_size")], [The maximum row group size created by the Parquet writer.], [#raw("128MB")],),
  ([#raw("parquet_writer_row_group_max_row_count")], [The maximum row count of row groups created by the Parquet writer.], [#raw("unlimited")],),
  ([#raw("parquet_writer_page_size")], [The maximum page size created by the Parquet writer.], [#raw("1MB")],),
  ([#raw("parquet_writer_page_value_count")], [The maximum value count of pages created by the Parquet writer.], [#raw("60000")],),
  ([#raw("parquet_writer_batch_size")], [Maximum number of rows processed by the Parquet writer in a batch.], [#raw("10000")],),
  ([#raw("projection_pushdown_enabled")], [Read only projected fields from row columns while performing #raw("SELECT") queries.], [#raw("true")],),
  ([#raw("load_metadata_from_checksum_file")], [Speed up query planning by reading table metadata and protocol entries from the Delta version checksum file \(#raw("<version>.crc")\) when available. Falls back to scanning the transaction log if the checksum file is missing, incomplete, or malformed.], [#raw("true")],)
), header-rows: 1, title: "Catalog session properties")

#anchor("ref-delta-lake-fte-support")

=== Fault-tolerant execution support

The connector supports #link(label("doc-admin-fault-tolerant-execution"))[Fault-tolerant execution] of query processing. Read and write operations are both supported with any retry policy.

#anchor("ref-delta-lake-type-mapping")

== Type mapping

Because Trino and Delta Lake each support types that the other does not, this connector #link(label("ref-type-mapping-overview"))[modifies some types] when reading or writing data. Data types might not map the same way in both directions between Trino and the data source. Refer to the following sections for type mapping in each direction.

See the #link("https://github.com/delta-io/delta/blob/master/PROTOCOL.md#primitive-types")[Delta Transaction Log specification] for more information about supported data types in the Delta Lake table format specification.

=== Delta Lake to Trino type mapping

The connector maps Delta Lake types to the corresponding Trino types following this table:

#list-table((
  ([Delta Lake type], [Trino type],),
  ([#raw("BOOLEAN")], [#raw("BOOLEAN")],),
  ([#raw("INTEGER")], [#raw("INTEGER")],),
  ([#raw("BYTE")], [#raw("TINYINT")],),
  ([#raw("SHORT")], [#raw("SMALLINT")],),
  ([#raw("LONG")], [#raw("BIGINT")],),
  ([#raw("FLOAT")], [#raw("REAL")],),
  ([#raw("DOUBLE")], [#raw("DOUBLE")],),
  ([#raw("DECIMAL(p,s)")], [#raw("DECIMAL(p,s)")],),
  ([#raw("STRING")], [#raw("VARCHAR")],),
  ([#raw("BINARY")], [#raw("VARBINARY")],),
  ([#raw("DATE")], [#raw("DATE")],),
  ([#raw("TIMESTAMPNTZ") \(#raw("TIMESTAMP_NTZ")\)], [#raw("TIMESTAMP(6)")],),
  ([#raw("TIMESTAMP")], [#raw("TIMESTAMP(3) WITH TIME ZONE")],),
  ([#raw("VARIANT")], [#raw("JSON")],),
  ([#raw("ARRAY")], [#raw("ARRAY")],),
  ([#raw("MAP")], [#raw("MAP")],),
  ([#raw("STRUCT(...)")], [#raw("ROW(...)")],)
), header-rows: 1, title: "Delta Lake to Trino type mapping")

No other types are supported.

=== Trino to Delta Lake type mapping

The connector maps Trino types to the corresponding Delta Lake types following this table:

#list-table((
  ([Trino type], [Delta Lake type],),
  ([#raw("BOOLEAN")], [#raw("BOOLEAN")],),
  ([#raw("INTEGER")], [#raw("INTEGER")],),
  ([#raw("TINYINT")], [#raw("BYTE")],),
  ([#raw("SMALLINT")], [#raw("SHORT")],),
  ([#raw("BIGINT")], [#raw("LONG")],),
  ([#raw("REAL")], [#raw("FLOAT")],),
  ([#raw("DOUBLE")], [#raw("DOUBLE")],),
  ([#raw("DECIMAL(p,s)")], [#raw("DECIMAL(p,s)")],),
  ([#raw("VARCHAR")], [#raw("STRING")],),
  ([#raw("VARBINARY")], [#raw("BINARY")],),
  ([#raw("DATE")], [#raw("DATE")],),
  ([#raw("TIMESTAMP")], [#raw("TIMESTAMPNTZ") \(#raw("TIMESTAMP_NTZ")\)],),
  ([#raw("TIMESTAMP(3) WITH TIME ZONE")], [#raw("TIMESTAMP")],),
  ([#raw("ARRAY")], [#raw("ARRAY")],),
  ([#raw("MAP")], [#raw("MAP")],),
  ([#raw("ROW(...)")], [#raw("STRUCT(...)")],)
), header-rows: 1, title: "Trino to Delta Lake type mapping")

No other types are supported.

== Delta Lake table features

The connector supports the following #link("https://github.com/delta-io/delta/blob/master/PROTOCOL.md#table-features")[Delta Lake table features]:

#list-table((
  ([Feature], [Description],),
  ([Append-only tables], [Writers only],),
  ([Column invariants], [Writers only],),
  ([CHECK constraints], [Writers only],),
  ([Change data feed], [Writers only],),
  ([Column mapping], [Readers and writers],),
  ([Deletion vectors], [Readers and writers],),
  ([Iceberg compatibility V1 & V2], [Readers only],),
  ([Invariants], [Writers only],),
  ([Timestamp without time zone], [Readers and writers],),
  ([Type widening], [Readers only],),
  ([Vacuum protocol check], [Readers and writers],),
  ([V2 checkpoint], [Readers only],)
), header-rows: 1, title: "Table features")

No other features are supported.

== Security

The Delta Lake connector allows you to choose one of several means of providing authorization at the catalog level. You can select a different type of authorization check in different Delta Lake catalog files.

#anchor("ref-delta-lake-authorization")

=== Authorization checks

Enable authorization checks for the connector by setting the #raw("delta.security") property in the catalog properties file. This property must be one of the security values in the following table:

#list-table((
  ([Property value], [Description],),
  ([#raw("ALLOW_ALL") \(default value\)], [No authorization checks are enforced.],),
  ([#raw("SYSTEM")], [The connector relies on system-level access control.],),
  ([#raw("READ_ONLY")], [Operations that read data or metadata, such as #link(label("doc-sql-select"))[SELECT] are permitted. No operations that write data or metadata, such as #link(label("doc-sql-create-table"))[CREATE TABLE], #link(label("doc-sql-insert"))[INSERT], or #link(label("doc-sql-delete"))[DELETE] are allowed.],),
  ([#raw("FILE")], [Authorization checks are enforced using a catalog-level access control configuration file whose path is specified in the #raw("security.config-file") catalog configuration property. See #link(label("ref-catalog-file-based-access-control"))[File-based access control] for information on the authorization configuration file.],)
), header-rows: 1, title: "Delta Lake security values")

#anchor("ref-delta-lake-sql-support")

== SQL support

The connector provides read and write access to data and metadata in Delta Lake. In addition to the #link(label("ref-sql-globally-available"))[globally available] and #link(label("ref-sql-read-operations"))[read operation] statements, the connector supports the following features:

- #link(label("ref-sql-write-operations"))[sql-write-operations]:
  
  - #link(label("ref-sql-data-management"))[sql-data-management], see details for  #link(label("ref-delta-lake-data-management"))[Delta Lake data management]
  - #link(label("ref-sql-schema-table-management"))[sql-schema-table-management], see details for  #link(label("ref-delta-lake-schema-table-management"))[Delta Lake schema and table management]
  - #link(label("ref-sql-view-management"))[sql-view-management]

#anchor("ref-delta-time-travel")

=== Time travel queries

The connector offers the ability to query historical data. This allows to query the table as it was when a previous snapshot of the table was taken, even if the data has since been modified or deleted.

The historical data of the table can be retrieved by specifying the version number corresponding to the version of the table to be retrieved:

#code-block("sql", "SELECT *
FROM example.testdb.customer_orders FOR VERSION AS OF 3")

A different approach of retrieving historical data is to specify a point in time in the past, such as a day or week ago. The latest snapshot of the table taken before or at the specified timestamp in the query is internally used for providing the previous state of the table:

#code-block("sql", "SELECT *
FROM example.testdb.customer_orders FOR TIMESTAMP AS OF TIMESTAMP '2022-03-23 09:59:29.803 America/Los_Angeles';")

The connector allows to create a new snapshot through Delta Lake's #link(label("ref-delta-lake-create-or-replace"))[replace table].

#code-block("sql", "CREATE OR REPLACE TABLE example.testdb.customer_orders AS
SELECT *
FROM example.testdb.customer_orders FOR TIMESTAMP AS OF TIMESTAMP '2022-03-23 09:59:29.803 America/Los_Angeles';")

You can use a date to specify a point a time in the past for using a snapshot of a table in a query. Assuming that the session time zone is #raw("America/Los_Angeles") the following queries are equivalent:

#code-block("sql", "SELECT *
FROM example.testdb.customer_orders FOR TIMESTAMP AS OF DATE '2022-03-23';")

#code-block("sql", "SELECT *
FROM example.testdb.customer_orders FOR TIMESTAMP AS OF TIMESTAMP '2022-03-23 00:00:00';")

#code-block("sql", "SELECT *
FROM example.testdb.customer_orders FOR TIMESTAMP AS OF TIMESTAMP '2022-03-23 00:00:00.000 America/Los_Angeles';")

Use the #raw("$history") metadata table to determine the snapshot ID of the table like in the following query:

#code-block("sql", "SELECT version, operation
FROM example.testdb.\"customer_orders$history\"
ORDER BY version DESC")

=== Procedures

Use the #link(label("doc-sql-call"))[CALL] statement to perform data manipulation or administrative tasks. Procedures are available in the system schema of each catalog. The following code snippet displays how to call the #raw("example_procedure") in the #raw("examplecatalog") catalog:

#code-block("sql", "CALL examplecatalog.system.example_procedure()")

#anchor("ref-delta-lake-register-table")

==== Register table

The connector can register existing Delta Lake tables into the metastore if #raw("delta.register-table-procedure.enabled") is set to #raw("true") for the catalog.

The #raw("system.register_table") procedure allows the caller to register an existing Delta Lake table in the metastore, using its existing transaction logs and data files:

#code-block("sql", "CALL example.system.register_table(schema_name => 'testdb', table_name => 'customer_orders', table_location => 's3://my-bucket/a/path')")

To prevent unauthorized users from accessing data, this procedure is disabled by default. The procedure is enabled only when #raw("delta.register-table-procedure.enabled") is set to #raw("true").

#anchor("ref-delta-lake-unregister-table")

==== Unregister table

The connector can remove existing Delta Lake tables from the metastore. Once unregistered, you can no longer query the table from Trino.

The procedure #raw("system.unregister_table") allows the caller to unregister an existing Delta Lake table from the metastores without deleting the data:

#code-block("sql", "CALL example.system.unregister_table(schema_name => 'testdb', table_name => 'customer_orders')")

#anchor("ref-delta-lake-flush-metadata-cache")

==== Flush metadata cache

- #raw("system.flush_metadata_cache()")
  
  Flushes all metadata caches.
- #raw("system.flush_metadata_cache(schema_name => ..., table_name => ...)")
  
  Flushes metadata cache entries of a specific table. Procedure requires passing named parameters.

#anchor("ref-delta-lake-vacuum")

==== #raw("VACUUM")

The #raw("VACUUM") procedure removes all old files that are not in the transaction log, as well as files that are not needed to read table snapshots newer than the current time minus the retention period defined by the #raw("retention period") parameter.

Users with #raw("INSERT") and #raw("DELETE") permissions on a table can run #raw("VACUUM") as follows:

#code-block("sql", "CALL example.system.vacuum('exampleschemaname', 'exampletablename', '7d');")

All parameters are required and must be presented in the following order:

- Schema name
- Table name
- Retention period

The #raw("delta.vacuum.min-retention") configuration property provides a safety measure to ensure that files are retained as expected. The minimum value for this property is #raw("0s"). There is a minimum retention session property as well, #raw("vacuum_min_retention").

#anchor("ref-delta-lake-data-management")

=== Data management

You can use the connector to #link(label("doc-sql-insert"))[INSERT], #link(label("doc-sql-delete"))[DELETE], #link(label("doc-sql-update"))[UPDATE], and #link(label("doc-sql-merge"))[MERGE] data in Delta Lake tables.

Write operations are supported for tables stored on the following systems:

- Azure ADLS Gen2, Google Cloud Storage
  
  Writes to the Azure ADLS Gen2 and Google Cloud Storage are enabled by default. Trino detects write collisions on these storage systems when writing from multiple Trino clusters, or from other query engines.
- S3 and S3-compatible storage
  
  Writes to Amazon S3 and S3-compatible storage are controlled by following configuration properties. When #raw("delta.s3.transaction-log-conditional-writes.enabled") is set to #raw("true") \(default\), the connector uses S3 conditional writes to detect log write collisions.  This is compatible with any other engines that also use conditional writes.
  
  When #raw("delta.s3.transaction-log-conditional-writes.enabled") is false, then writes to Amazon S3 and S3-compatible storage must be enabled with the #raw("delta.enable-non-concurrent-writes") property.  In this mode, the connector leverages S3 strong consistency guarantees combined with Trino specific naming strategy to orchestrate creation of new log files.  In this mode, writes to S3 can safely be made from multiple Trino clusters using same writing mode; however, write collisions are not detected when writing concurrently from other Delta Lake engines, or from Trino clusters using S3 conditional writes. You must make sure that no concurrent data modifications are run to avoid data corruption.

#anchor("ref-delta-lake-schema-table-management")

=== Schema and table management

The #link(label("ref-sql-schema-table-management"))[sql-schema-table-management] functionality includes support for:

- #link(label("doc-sql-create-table"))[CREATE TABLE]
- #link(label("doc-sql-create-table-as"))[CREATE TABLE AS]
- #link(label("doc-sql-drop-table"))[DROP TABLE]
- #link(label("doc-sql-alter-table"))[ALTER TABLE], see details for #link(label("ref-delta-lake-alter-table"))[Delta Lake ALTER TABLE]
- #link(label("doc-sql-create-schema"))[CREATE SCHEMA]
- #link(label("doc-sql-drop-schema"))[DROP SCHEMA]
- #link(label("doc-sql-alter-schema"))[ALTER SCHEMA]
- #link(label("doc-sql-comment"))[COMMENT]

The connector supports creating schemas. You can create a schema with or without a specified location.

You can create a schema with the #link(label("doc-sql-create-schema"))[CREATE SCHEMA] statement and the #raw("location") schema property. Tables in this schema are located in a subdirectory under the schema location. Data files for tables in this schema using the default location are cleaned up if the table is dropped:

#code-block("sql", "CREATE SCHEMA example.example_schema
WITH (location = 's3://my-bucket/a/path');")

Optionally, the location can be omitted. Tables in this schema must have a location included when you create them. The data files for these tables are not removed if the table is dropped:

#code-block("sql", "CREATE SCHEMA example.example_schema;")

When Delta Lake tables exist in storage but not in the metastore, Trino can be used to register the tables:

#code-block("sql", "CALL example.system.register_table(schema_name => 'testdb', table_name => 'example_table', table_location => 's3://my-bucket/a/path')")

The table schema is read from the transaction log instead. If the schema is changed by an external system, Trino automatically uses the new schema.

#warning[
Using #raw("CREATE TABLE") with an existing table content is disallowed, use the #raw("system.register_table") procedure instead.
]

If the specified location does not already contain a Delta table, the connector automatically writes the initial transaction log entries and registers the table in the metastore. As a result, any Databricks engine can write to the table:

#code-block("sql", "CREATE TABLE example.default.new_table (id BIGINT, address VARCHAR);")

The Delta Lake connector also supports creating tables using the #link(label("doc-sql-create-table-as"))[CREATE TABLE AS] syntax.

==== Schema evolution

The Delta Lake connector supports schema evolution, with safe column add, drop, and rename operations for non nested structures.

#anchor("ref-delta-lake-alter-table")

The connector supports the following #link(label("doc-sql-alter-table"))[ALTER TABLE] statements.

#anchor("ref-delta-lake-create-or-replace")

==== Replace tables

The connector supports replacing an existing table as an atomic operation. Atomic table replacement creates a new snapshot with the new table definition as part of the #link("#delta-lake-history-table")[table history].

To replace a table, use #link(label("doc-sql-create-table"))[#raw("CREATE OR REPLACE TABLE")] or #link(label("doc-sql-create-table-as"))[#raw("CREATE OR REPLACE TABLE AS")].

In this example, a table #raw("example_table") is replaced by a completely new definition and data from the source table:

#code-block("sql", "CREATE OR REPLACE TABLE example_table
WITH (partitioned_by = ARRAY['a'])
AS SELECT * FROM another_table;")

#anchor("ref-delta-lake-alter-table-execute")

==== ALTER TABLE EXECUTE

The connector supports the following commands for use with #link(label("ref-alter-table-execute"))[ALTER TABLE EXECUTE].

===== optimize

The #raw("optimize") command is used for rewriting the content of the specified table so that it is merged into fewer but larger files. If the table is partitioned, the data compaction acts separately on each partition selected for optimization. This operation improves read performance.

All files with a size below the optional #raw("file_size_threshold") parameter \(default value for the threshold is #raw("100MB")\) are merged:

#code-block("sql", "ALTER TABLE test_table EXECUTE optimize")

The following statement merges files in a table that are under 128 megabytes in size:

#code-block("sql", "ALTER TABLE test_table EXECUTE optimize(file_size_threshold => '128MB')")

You can use a #raw("WHERE") clause with the columns used to partition the table to filter which partitions are optimized:

#code-block("sql", "ALTER TABLE test_partitioned_table EXECUTE optimize
WHERE partition_key = 1")

You can use a more complex #raw("WHERE") clause to narrow down the scope of the #raw("optimize") procedure. The following example casts the timestamp values to dates, and uses a comparison to only optimize partitions with data from the year 2022 or newer:

#code-block(none, "ALTER TABLE test_table EXECUTE optimize
WHERE CAST(timestamp_tz AS DATE) > DATE '2021-12-31'")

Use a #raw("WHERE") clause with #link(label("ref-delta-lake-special-columns"))[metadata columns] to filter which files are optimized.

#code-block("sql", "ALTER TABLE test_table EXECUTE optimize
WHERE \"$file_modified_time\" > date_trunc('day', CURRENT_TIMESTAMP);")

#code-block("sql", "ALTER TABLE test_table EXECUTE optimize
WHERE \"$path\" <> 'skipping-file-path'")

#code-block("sql", "-- optimze files smaller than 1MB
ALTER TABLE test_table EXECUTE optimize
WHERE \"$file_size\" <= 1024 * 1024")

#anchor("ref-delta-lake-alter-table-rename-to")

==== ALTER TABLE RENAME TO

The connector only supports the #raw("ALTER TABLE RENAME TO") statement when met with one of the following conditions:

- The table type is external.
- The table is backed by a metastore that does not perform object storage operations, for example, AWS Glue.

==== Table properties

The following table properties are available for use:

#list-table((
  ([Property name], [Description],),
  ([#raw("location")], [File system location URI for the table.],),
  ([#raw("partitioned_by")], [Set partition columns.],),
  ([#raw("checkpoint_interval")], [Set the checkpoint interval in number of table writes.],),
  ([#raw("change_data_feed_enabled")], [Enables storing change data feed entries.],),
  ([#raw("column_mapping_mode")], [Column mapping mode. Possible values are:

- #raw("ID")
- #raw("NAME")
- #raw("NONE")

Defaults to #raw("NONE").],),
  ([#raw("deletion_vectors_enabled")], [Enables deletion vectors.],)
), header-rows: 1, title: "Delta Lake table properties")

The following example uses all available table properties:

#code-block("sql", "CREATE TABLE example.default.example_partitioned_table
WITH (
  location = 's3://my-bucket/a/path',
  partitioned_by = ARRAY['regionkey'],
  checkpoint_interval = 5,
  change_data_feed_enabled = false,
  column_mapping_mode = 'name',
  deletion_vectors_enabled = false
)
AS SELECT name, comment, regionkey FROM tpch.tiny.nation;")

#anchor("ref-delta-lake-shallow-clone")

==== Shallow cloned tables

The connector supports read and write operations on shallow cloned tables. Trino does not support creating shallow clone tables. More information about shallow cloning is available in the #link("https://docs.delta.io/latest/delta-utility.html#shallow-clone-a-delta-table")[Delta Lake documentation].

Shallow cloned tables let you test queries or experiment with changes to a table without duplicating data.

==== Metadata tables

The connector exposes several metadata tables for each Delta Lake table. These metadata tables contain information about the internal structure of the Delta Lake table. You can query each metadata table by appending the metadata table name to the table name:

#code-block("sql", "SELECT * FROM \"test_table$history\"")

#anchor("ref-delta-lake-history-table")

===== #raw("$history") table

The #raw("$history") table provides a log of the metadata changes performed on the Delta Lake table.

You can retrieve the changelog of the Delta Lake table #raw("test_table") by using the following query:

#code-block("sql", "SELECT * FROM \"test_table$history\"")

#code-block("text", " version |               timestamp               | user_id | user_name |  operation   |         operation_parameters          |                 cluster_id      | read_version |  isolation_level  | is_blind_append | operation_metrics              
---------+---------------------------------------+---------+-----------+--------------+---------------------------------------+---------------------------------+--------------+-------------------+-----------------+-------------------
       2 | 2023-01-19 07:40:54.684 Europe/Vienna | trino   | trino     | WRITE        | {queryId=20230119_064054_00008_4vq5t} | trino-406-trino-coordinator     |            2 | WriteSerializable | true            | {}
       1 | 2023-01-19 07:40:41.373 Europe/Vienna | trino   | trino     | ADD COLUMNS  | {queryId=20230119_064041_00007_4vq5t} | trino-406-trino-coordinator     |            0 | WriteSerializable | true            | {}
       0 | 2023-01-19 07:40:10.497 Europe/Vienna | trino   | trino     | CREATE TABLE | {queryId=20230119_064010_00005_4vq5t} | trino-406-trino-coordinator     |            0 | WriteSerializable | true            | {}")

The output of the query has the following history columns:

#list-table((
  ([Name], [Type], [Description],),
  ([#raw("version")], [#raw("BIGINT")], [The version of the table corresponding to the operation],),
  ([#raw("timestamp")], [#raw("TIMESTAMP(3) WITH TIME ZONE")], [The time when the table version became active For tables with in-Commit timestamps enabled, this field returns value of #link("https://github.com/delta-io/delta/blob/master/PROTOCOL.md#in-commit-timestamps")[inCommitTimestamp], Otherwise returns value of #raw("timestamp") field that in the #link("https://github.com/delta-io/delta/blob/master/PROTOCOL.md#commit-provenance-information")[commitInfo]],),
  ([#raw("user_id")], [#raw("VARCHAR")], [The identifier for the user which performed the operation],),
  ([#raw("user_name")], [#raw("VARCHAR")], [The username for the user which performed the operation],),
  ([#raw("operation")], [#raw("VARCHAR")], [The name of the operation performed on the table],),
  ([#raw("operation_parameters")], [#raw("map(VARCHAR, VARCHAR)")], [Parameters of the operation],),
  ([#raw("cluster_id")], [#raw("VARCHAR")], [The ID of the cluster which ran the operation],),
  ([#raw("read_version")], [#raw("BIGINT")], [The version of the table which was read in order to perform the operation],),
  ([#raw("isolation_level")], [#raw("VARCHAR")], [The level of isolation used to perform the operation],),
  ([#raw("is_blind_append")], [#raw("BOOLEAN")], [Whether or not the operation appended data],),
  ([#raw("operation_metrics")], [#raw("map(VARCHAR, VARCHAR)")], [Metrics of the operation],)
), header-rows: 1, title: "History columns")

#anchor("ref-delta-lake-partitions-table")

===== #raw("$partitions") table

The #raw("$partitions") table provides a detailed overview of the partitions of the Delta Lake table.

You can retrieve the information about the partitions of the Delta Lake table #raw("test_table") by using the following query:

#code-block("sql", "SELECT * FROM \"test_table$partitions\"")

#code-block("text", "           partition           | file_count | total_size |                     data                     |
-------------------------------+------------+------------+----------------------------------------------+
{_bigint=1, _date=2021-01-12}  |          2 |        884 | {_decimal={min=1.0, max=2.0, null_count=0}}  |
{_bigint=1, _date=2021-01-13}  |          1 |        442 | {_decimal={min=1.0, max=1.0, null_count=0}}  |")

The output of the query has the following columns:

#list-table((
  ([Name], [Type], [Description],),
  ([#raw("partition")], [#raw("ROW(...)")], [A row that contains the mapping of the partition column names to the partition column values.],),
  ([#raw("file_count")], [#raw("BIGINT")], [The number of files mapped in the partition.],),
  ([#raw("total_size")], [#raw("BIGINT")], [The size of all the files in the partition.],),
  ([#raw("data")], [#raw("ROW(... ROW (min ..., max ... , null_count BIGINT))")], [Partition range and null counts.],)
), header-rows: 1, title: "Partitions columns")

===== #raw("$properties") table

The #raw("$properties") table provides access to Delta Lake table configuration, table features and table properties. The table rows are key\/value pairs.

You can retrieve the properties of the Delta table #raw("test_table") by using the following query:

#code-block("sql", "SELECT * FROM \"test_table$properties\"")

#code-block("text", " key                        | value           |
----------------------------+-----------------+
delta.minReaderVersion      | 1               |
delta.minWriterVersion      | 4               |
delta.columnMapping.mode    | name            |
delta.feature.columnMapping | supported       |")

#anchor("ref-delta-lake-special-columns")

==== Metadata columns

In addition to the defined columns, the Delta Lake connector automatically exposes metadata in a number of hidden columns in each table. You can use these columns in your SQL statements like any other column, e.g., they can be selected directly or used in conditional statements.

- / #raw("$path"): Full file system path name of the file for this row.
- / #raw("$file_modified_time"): Date and time of the last modification of the file for this row.
- / #raw("$file_size"): Size of the file for this row.

=== Table functions

The connector provides the following table functions:

==== table\_changes

Allows reading Change Data Feed \(CDF\) entries to expose row-level changes between two versions of a Delta Lake table. When the #raw("change_data_feed_enabled") table property is set to #raw("true") on a specific Delta Lake table, the connector records change events for all data changes on the table. This is how these changes can be read:

#code-block("sql", "SELECT
  *
FROM
  TABLE(
    system.table_changes(
      schema_name => 'test_schema',
      table_name => 'tableName',
      since_version => 0
    )
  );")

#raw("schema_name") - type #raw("VARCHAR"), required, name of the schema for which the function is called

#raw("table_name") - type #raw("VARCHAR"), required, name of the table for which the function is called

#raw("since_version") - type #raw("BIGINT"), optional, version from which changes are shown, exclusive

In addition to returning the columns present in the table, the function returns the following values for each change event:

- / #raw("_change_type"): Gives the type of change that occurred. Possible values are #raw("insert"), #raw("delete"), #raw("update_preimage") and #raw("update_postimage").
- / #raw("_commit_version"): Shows the table version for which the change occurred.
- / #raw("_commit_timestamp"): Represents the timestamp for the commit in which the specified change happened.

This is how it would be normally used:

Create table:

#code-block("sql", "CREATE TABLE test_schema.pages (page_url VARCHAR, domain VARCHAR, views INTEGER)
    WITH (change_data_feed_enabled = true);")

Insert data:

#code-block("sql", "INSERT INTO test_schema.pages
    VALUES
        ('url1', 'domain1', 1),
        ('url2', 'domain2', 2),
        ('url3', 'domain1', 3);
INSERT INTO test_schema.pages
    VALUES
        ('url4', 'domain1', 400),
        ('url5', 'domain2', 500),
        ('url6', 'domain3', 2);")

Update data:

#code-block("sql", "UPDATE test_schema.pages
    SET domain = 'domain4'
    WHERE views = 2;")

Select changes:

#code-block("sql", "SELECT
  *
FROM
  TABLE(
    system.table_changes(
      schema_name => 'test_schema',
      table_name => 'pages',
      since_version => 1
    )
  )
ORDER BY _commit_version ASC;")

The preceding sequence of SQL statements returns the following result:

#code-block("text", "page_url    |     domain     |    views    |    _change_type     |    _commit_version    |    _commit_timestamp
url4        |     domain1    |    400      |    insert           |     2                 |    2023-03-10T21:22:23.000+0000
url5        |     domain2    |    500      |    insert           |     2                 |    2023-03-10T21:22:23.000+0000
url6        |     domain3    |    2        |    insert           |     2                 |    2023-03-10T21:22:23.000+0000
url2        |     domain2    |    2        |    update_preimage  |     3                 |    2023-03-10T22:23:24.000+0000
url2        |     domain4    |    2        |    update_postimage |     3                 |    2023-03-10T22:23:24.000+0000
url6        |     domain3    |    2        |    update_preimage  |     3                 |    2023-03-10T22:23:24.000+0000
url6        |     domain4    |    2        |    update_postimage |     3                 |    2023-03-10T22:23:24.000+0000")

The output shows what changes happen in which version. For example in version 3 two rows were modified, first one changed from #raw("('url2', 'domain2', 2)") into #raw("('url2', 'domain4', 2)") and the second from #raw("('url6', 'domain2', 2)") into #raw("('url6', 'domain4', 2)").

If #raw("since_version") is not provided the function produces change events starting from when the table was created.

#code-block("sql", "SELECT
  *
FROM
  TABLE(
    system.table_changes(
      schema_name => 'test_schema',
      table_name => 'pages'
    )
  )
ORDER BY _commit_version ASC;")

The preceding SQL statement returns the following result:

#code-block("text", "page_url    |     domain     |    views    |    _change_type     |    _commit_version    |    _commit_timestamp
url1        |     domain1    |    1        |    insert           |     1                 |    2023-03-10T20:21:22.000+0000
url2        |     domain2    |    2        |    insert           |     1                 |    2023-03-10T20:21:22.000+0000
url3        |     domain1    |    3        |    insert           |     1                 |    2023-03-10T20:21:22.000+0000
url4        |     domain1    |    400      |    insert           |     2                 |    2023-03-10T21:22:23.000+0000
url5        |     domain2    |    500      |    insert           |     2                 |    2023-03-10T21:22:23.000+0000
url6        |     domain3    |    2        |    insert           |     2                 |    2023-03-10T21:22:23.000+0000
url2        |     domain2    |    2        |    update_preimage  |     3                 |    2023-03-10T22:23:24.000+0000
url2        |     domain4    |    2        |    update_postimage |     3                 |    2023-03-10T22:23:24.000+0000
url6        |     domain3    |    2        |    update_preimage  |     3                 |    2023-03-10T22:23:24.000+0000
url6        |     domain4    |    2        |    update_postimage |     3                 |    2023-03-10T22:23:24.000+0000")

You can see changes that occurred at version 1 as three inserts. They are not visible in the previous statement when #raw("since_version") value was set to 1.

== Performance

The connector includes a number of performance improvements detailed in the following sections:

- Support for #link(label("doc-admin-properties-write-partitioning"))[write partitioning].

#anchor("ref-delta-lake-table-statistics")

=== Table statistics

Use #link(label("doc-sql-analyze"))[ANALYZE] statements in Trino to populate data size and number of distinct values \(NDV\) extended table statistics in Delta Lake. The minimum value, maximum value, value count, and null value count statistics are computed on the fly out of the transaction log of the Delta Lake table. The #link(label("doc-optimizer-cost-based-optimizations"))[cost-based optimizer] then uses these statistics to improve query performance.

Extended statistics enable a broader set of optimizations, including join reordering. The controlling catalog property #raw("delta.table-statistics-enabled") is enabled by default. The equivalent #link(label("ref-session-properties-definition"))[catalog session property] is #raw("statistics_enabled").

Each #raw("ANALYZE") statement updates the table statistics incrementally, so only the data changed since the last #raw("ANALYZE") is counted. The table statistics are not automatically updated by write operations such as #raw("INSERT"), #raw("UPDATE"), and #raw("DELETE"). You must manually run #raw("ANALYZE") again to update the table statistics.

To collect statistics for a table, execute the following statement:

#code-block("sql", "ANALYZE table_schema.table_name;")

To recalculate from scratch the statistics for the table use additional parameter #raw("mode"):

#quote(block: true)[
ANALYZE table\_schema.table\_name WITH\(mode = 'full\_refresh'\);
]

There are two modes available #raw("full_refresh") and #raw("incremental"). The procedure use #raw("incremental") by default.

To gain the most benefit from cost-based optimizations, run periodic #raw("ANALYZE") statements on every large table that is frequently queried.

==== Fine-tuning

The #raw("files_modified_after") property is useful if you want to run the #raw("ANALYZE") statement on a table that was previously analyzed. You can use it to limit the amount of data used to generate the table statistics:

#code-block("sql", "ANALYZE example_table WITH(files_modified_after = TIMESTAMP '2021-08-23
16:43:01.321 Z')")

As a result, only files newer than the specified time stamp are used in the analysis.

You can also specify a set or subset of columns to analyze using the #raw("columns") property:

#code-block("sql", "ANALYZE example_table WITH(columns = ARRAY['nationkey', 'regionkey'])")

To run #raw("ANALYZE") with #raw("columns") more than once, the next #raw("ANALYZE") must run on the same set or a subset of the original columns used.

To broaden the set of #raw("columns"), drop the statistics and reanalyze the table.

==== Disable and drop extended statistics

You can disable extended statistics with the catalog configuration property #raw("delta.extended-statistics.enabled") set to #raw("false"). Alternatively, you can disable it for a session, with the #link(label("doc-sql-set-session"))[catalog session property] #raw("extended_statistics_enabled") set to #raw("false").

If a table is changed with many delete and update operation, calling #raw("ANALYZE") does not result in accurate statistics. To correct the statistics, you have to drop the extended statistics and analyze the table again.

Use the #raw("system.drop_extended_stats") procedure in the catalog to drop the extended statistics for a specified table in a specified schema:

#code-block("sql", "CALL example.system.drop_extended_stats('example_schema', 'example_table')")

=== Memory usage

The Delta Lake connector is memory intensive and the amount of required memory grows with the size of Delta Lake transaction logs of any accessed tables. It is important to take that into account when provisioning the coordinator.

You must decrease memory usage by keeping the number of active data files in the table low by regularly running #raw("OPTIMIZE") and #raw("VACUUM") in Delta Lake.

==== Memory monitoring

When using the Delta Lake connector, you must monitor memory usage on the coordinator. Specifically, monitor JVM heap utilization using standard tools as part of routine operation of the cluster.

A good proxy for memory usage is the cache utilization of Delta Lake caches. It is exposed by the connector with the #raw("plugin.deltalake.transactionlog:name=<catalog-name>,type=transactionlogaccess") JMX bean.

You can access it with any standard monitoring software with JMX support, or use the #link(label("doc-connector-jmx"))[JMX connector] with the following query:

#code-block("sql", "SELECT * FROM jmx.current.\"*.plugin.deltalake.transactionlog:name=<catalog-name>,type=transactionlogaccess\"")

Following is an example result:

#code-block("text", "datafilemetadatacachestats.hitrate      | 0.97
datafilemetadatacachestats.missrate     | 0.03
datafilemetadatacachestats.requestcount | 3232
metadatacachestats.hitrate              | 0.98
metadatacachestats.missrate             | 0.02
metadatacachestats.requestcount         | 6783
node                                    | trino-master
object_name                             | io.trino.plugin.deltalake.transactionlog:type=TransactionLogAccess,name=delta")

In a healthy system, both #raw("datafilemetadatacachestats.hitrate") and #raw("metadatacachestats.hitrate") are close to #raw("1.0").

#anchor("ref-delta-lake-table-redirection")

=== Table redirection

Trino offers the possibility to transparently redirect operations on an existing table to the appropriate catalog based on the format of the table and catalog configuration.

In the context of connectors which depend on a metastore service \(for example, #link(label("doc-connector-hive"))[Hive connector], #link(label("doc-connector-iceberg"))[Iceberg connector] and #link(label("doc-connector-delta-lake"))[Delta Lake connector]\), the metastore \(Hive metastore service, #link("https://aws.amazon.com/glue/")[AWS Glue Data Catalog]\) can be used to accustom tables with different table formats. Therefore, a metastore database can hold a variety of tables with different table formats.

As a concrete example, let's use the following simple scenario which makes use of table redirection:

#code-block(none, "USE example.example_schema;

EXPLAIN SELECT * FROM example_table;")

#code-block("text", "                               Query Plan
-------------------------------------------------------------------------
Fragment 0 [SOURCE]
     ...
     Output[columnNames = [...]]
     │   ...
     └─ TableScan[table = another_catalog:example_schema:example_table]
            ...")

The output of the #raw("EXPLAIN") statement points out the actual catalog which is handling the #raw("SELECT") query over the table #raw("example_table").

The table redirection functionality works also when using fully qualified names for the tables:

#code-block(none, "EXPLAIN SELECT * FROM example.example_schema.example_table;")

#code-block("text", "                               Query Plan
-------------------------------------------------------------------------
Fragment 0 [SOURCE]
     ...
     Output[columnNames = [...]]
     │   ...
     └─ TableScan[table = another_catalog:example_schema:example_table]
            ...")

Trino offers table redirection support for the following operations:

- Table read operations
  
  - #link(label("doc-sql-select"))[SELECT]
  - #link(label("doc-sql-describe"))[DESCRIBE]
  - #link(label("doc-sql-show-stats"))[SHOW STATS]
  - #link(label("doc-sql-show-create-table"))[SHOW CREATE TABLE]
- Table write operations
  
  - #link(label("doc-sql-insert"))[INSERT]
  - #link(label("doc-sql-update"))[UPDATE]
  - #link(label("doc-sql-merge"))[MERGE]
  - #link(label("doc-sql-delete"))[DELETE]
- Table management operations
  
  - #link(label("doc-sql-alter-table"))[ALTER TABLE]
  - #link(label("doc-sql-drop-table"))[DROP TABLE]
  - #link(label("doc-sql-comment"))[COMMENT]

Trino does not offer view redirection support.

The connector supports redirection from Delta Lake tables to Hive tables with the #raw("delta.hive-catalog-name") catalog configuration property.

=== Performance tuning configuration properties

The following table describes performance tuning catalog properties specific to the Delta Lake connector.

#warning[
Performance tuning configuration properties are considered expert-level features. Altering these properties from their default values is likely to cause instability and performance degradation. It is strongly suggested that you use them only to address non-trivial performance issues, and that you keep a backup of the original values if you change them.
]

#list-table((
  ([Property name], [Description], [Default],),
  ([#raw("delta.domain-compaction-threshold")], [Minimum size of query predicates above which Trino compacts the predicates. Pushing a large list of predicates down to the data source can compromise performance. For optimization in that situation, Trino can compact the large predicates. If necessary, adjust the threshold to ensure a balance between performance and predicate pushdown.], [#raw("1000")],),
  ([#raw("delta.max-outstanding-splits")], [The target number of buffered splits for each table scan in a query, before the scheduler tries to pause.], [#raw("1000")],),
  ([#raw("delta.max-splits-per-second")], [Sets the maximum number of splits used per second to access underlying storage. Reduce this number if your limit is routinely exceeded, based on your filesystem limits. This is set to the absolute maximum value, which results in Trino maximizing the parallelization of data access by default. Attempting to set it higher results in Trino not being able to start.], [#raw("Integer.MAX_VALUE")],),
  ([#raw("delta.max-split-size")], [Sets the largest #link(label("ref-prop-type-data-size"))[Properties reference] for a single read section assigned to a worker after #raw("max-initial-splits") have been processed. You can also use the corresponding catalog session property #raw("<catalog-name>.max_split_size").], [#raw("128MB")],),
  ([#raw("delta.minimum-assigned-split-weight")], [A decimal value in the range \(0, 1\] used as a minimum for weights assigned to each split. A low value might improve performance on tables with small files. A higher value might improve performance for queries with highly skewed aggregations or joins.], [#raw("0.05")],),
  ([#raw("delta.projection-pushdown-enabled")], [Read only projected fields from row columns while performing #raw("SELECT") queries], [#raw("true")],),
  ([#raw("delta.query-partition-filter-required")], [Set to #raw("true") to force a query to use a partition filter. You can use the #raw("query_partition_filter_required") catalog session property for temporary, catalog specific use.], [#raw("false")],)
), header-rows: 1, title: "Delta Lake performance tuning configuration properties")

=== File system cache

The connector supports configuring and using #link(label("doc-object-storage-file-system-cache"))[file system caching].

The following table describes file system cache properties specific to the Delta Lake connector.

#list-table((
  ([Property name], [Description], [Default],),
  ([#raw("delta.fs.cache.disable-transaction-log-caching")], [Set to #raw("true") to disable caching of the #raw("_delta_log") directory of Delta Tables. This is useful in those cases when Delta Tables are destroyed and recreated, and the files inside the transaction log directory get overwritten and cannot be safely cached. Effective only when #raw("fs.cache.enabled=true").], [#raw("false")],)
), header-rows: 1, title: "Delta Lake file system cache configuration properties")
