#import "/lib/trino-docs.typ": *

#anchor("doc-connector-hive")
= Hive connector

The Hive connector allows querying data stored in an #link("https://hive.apache.org/")[Apache Hive] data warehouse. Hive is a combination of three components:

- Data files in varying formats, that are typically stored in the Hadoop Distributed File System \(HDFS\) or in object storage systems such as Amazon S3.
- Metadata about how the data files are mapped to schemas and tables. This metadata is stored in a database, such as MySQL, and is accessed via the Hive metastore service.
- A query language called HiveQL. This query language is executed on a distributed computing framework such as MapReduce or Tez.

Trino only uses the first two components: the data and the metadata. It does not use HiveQL or any part of Hive's execution environment.

== Requirements

The Hive connector requires a #link(label("ref-hive-thrift-metastore"))[Hive metastore service] \(HMS\), or a compatible implementation of the Hive metastore, such as #link(label("ref-hive-glue-metastore"))[AWS Glue].

You must select and configure a #link(label("ref-hive-file-system-configuration"))[supported file system] in your catalog configuration file.

The coordinator and all workers must have network access to the Hive metastore and the storage system. Hive metastore access with the Thrift protocol defaults to using port 9083.

Data files must be in a supported file format. File formats can be configured using the #link(label("ref-hive-table-properties"))[#raw("format") table property] and other specific properties:

- #link(label("ref-orc-format-configuration"))[ORC]
- #link(label("ref-parquet-format-configuration"))[Parquet]
- Avro

In the case of serializable formats, only specific #link("https://www.wikipedia.org/wiki/SerDes")[SerDes] are allowed:

- RCText - RCFile using #raw("ColumnarSerDe")
- RCBinary - RCFile using #raw("LazyBinaryColumnarSerDe")
- SequenceFile with #raw("org.apache.hadoop.io.Text")
- SequenceFile with #raw("org.apache.hadoop.io.BytesWritable") containing protocol buffer records using #raw("com.twitter.elephantbird.hive.serde.ProtobufDeserializer")
- CSV - using #raw("org.apache.hadoop.hive.serde2.OpenCSVSerde")
- JSON - using #raw("org.apache.hive.hcatalog.data.JsonSerDe")
- OPENX\_JSON - OpenX JSON SerDe from #raw("org.openx.data.jsonserde.JsonSerDe"). Find more #link("https://github.com/trinodb/trino/tree/master/lib/trino-hive-formats/src/main/java/io/trino/hive/formats/line/openxjson/README.md")[details about the Trino implementation in the source repository].
- TextFile
- ESRI - using #raw("com.esri.hadoop.hive.serde.EsriJsonSerDe")
- ESRI\_GEO\_JSON - using #raw("com.esri.hadoop.hive.serde.GeoJsonSerDe")

#anchor("ref-hive-configuration")

== General configuration

To configure the Hive connector, create a catalog properties file #raw("etc/catalog/example.properties") that references the #raw("hive") connector.

You must configure a #link(label("doc-object-storage-metastores"))[metastore for metadata].

You must select and configure one of the #link(label("ref-hive-file-system-configuration"))[supported file systems].

#code-block("properties", "connector.name=hive
hive.metastore.uri=thrift://example.net:9083
fs.x.enabled=true")

Replace the #raw("fs.x.enabled") configuration property with the desired file system.

If you are using #link(label("ref-hive-glue-metastore"))[AWS Glue] as your metastore, you must instead set #raw("hive.metastore") to #raw("glue"):

#code-block("properties", "connector.name=hive
hive.metastore=glue")

Each metastore type has specific configuration properties along with #link(label("ref-general-metastore-properties"))[Metastores].

=== Multiple Hive clusters

You can have as many catalogs as you need, so if you have additional Hive clusters, simply add another properties file to #raw("etc/catalog") with a different name, making sure it ends in #raw(".properties"). For example, if you name the property file #raw("sales.properties"), Trino creates a catalog named #raw("sales") using the configured connector.

#anchor("ref-hive-configuration-properties")

=== Hive general configuration properties

The following table lists general configuration properties for the Hive connector. There are additional sets of configuration properties throughout the Hive connector documentation.

#list-table((
  ([Property Name], [Description], [Default],),
  ([#raw("hive.recursive-directories")], [Enable reading data from subdirectories of table or partition locations. If disabled, subdirectories are ignored. This is equivalent to the #raw("hive.mapred.supports.subdirectories") property in Hive.], [#raw("false")],),
  ([#raw("hive.ignore-absent-partitions")], [Ignore partitions when the file system location does not exist rather than failing the query. This skips data that may be expected to be part of the table.], [#raw("false")],),
  ([#raw("hive.storage-format")], [The default file format used when creating new tables.], [#raw("ORC")],),
  ([#raw("hive.orc.use-column-names")], [Access ORC columns by name. By default, columns in ORC files are accessed by their ordinal position in the Hive table definition. The equivalent catalog session property is #raw("orc_use_column_names"). See also, #link(label("ref-orc-format-configuration"))[Object storage file formats]], [#raw("false")],),
  ([#raw("hive.parquet.use-column-names")], [Access Parquet columns by name by default. Set this property to #raw("false") to access columns by their ordinal position in the Hive table definition. The equivalent catalog session property is #raw("parquet_use_column_names"). See also, #link(label("ref-parquet-format-configuration"))[Object storage file formats]], [#raw("true")],),
  ([#raw("hive.parquet.time-zone")], [Time zone used when reading and writing timestamps into Parquet files.], [JVM default],),
  ([#raw("hive.compression-codec")], [The compression codec to use when writing files. Possible values are #raw("NONE"), #raw("SNAPPY"), #raw("LZ4"), #raw("ZSTD"), or #raw("GZIP").], [#raw("GZIP")],),
  ([#raw("hive.force-local-scheduling")], [Force splits to be scheduled on the same node as the Hadoop DataNode process serving the split data. This is useful for installations where Trino is collocated with every DataNode.], [#raw("false")],),
  ([#raw("hive.respect-table-format")], [Should new partitions be written using the existing table format or the default Trino format?], [#raw("true")],),
  ([#raw("hive.immutable-partitions")], [Can new data be inserted into existing partitions? If #raw("true") then setting #raw("hive.insert-existing-partitions-behavior") to #raw("APPEND") is not allowed. This also affects the #raw("insert_existing_partitions_behavior") session property in the same way.], [#raw("false")],),
  ([#raw("hive.insert-existing-partitions-behavior")], [What happens when data is inserted into an existing partition? Possible values are

- #raw("APPEND") - appends data to existing partitions
- #raw("OVERWRITE") - overwrites existing partitions
- #raw("ERROR") - modifying existing partitions is not allowed

The equivalent catalog session property is #raw("insert_existing_partitions_behavior").], [#raw("APPEND")],),
  ([#raw("hive.target-max-file-size")], [Best effort maximum size of new files.], [#raw("1GB")],),
  ([#raw("hive.create-empty-bucket-files")], [Should empty files be created for buckets that have no data?], [#raw("false")],),
  ([#raw("hive.validate-bucketing")], [Enables validation that data is in the correct bucket when reading bucketed tables.], [#raw("true")],),
  ([#raw("hive.partition-statistics-sample-size")], [Specifies the number of partitions to analyze when computing table statistics.], [100],),
  ([#raw("hive.max-partitions-per-writers")], [Maximum number of partitions per writer.], [100],),
  ([#raw("hive.max-partitions-for-eager-load")], [The maximum number of partitions for a single table scan to load eagerly on the coordinator. Certain optimizations are not possible without eager loading.], [100,000],),
  ([#raw("hive.max-partitions-per-scan")], [Maximum number of partitions for a single table scan.], [1,000,000],),
  ([#raw("hive.non-managed-table-writes-enabled")], [Enable writes to non-managed \(external\) Hive tables.], [#raw("false")],),
  ([#raw("hive.non-managed-table-creates-enabled")], [Enable creating non-managed \(external\) Hive tables.], [#raw("true")],),
  ([#raw("hive.collect-column-statistics-on-write")], [Enables automatic column level statistics collection on write. See #link(label("ref-hive-table-statistics"))[Hive connector] for details.], [#raw("true")],),
  ([#raw("hive.file-status-cache-tables")], [Cache directory listing for specific tables. Examples:

- #raw("fruit.apple,fruit.orange") to cache listings only for tables #raw("apple") and #raw("orange") in schema #raw("fruit")
- #raw("fruit.*,vegetable.*") to cache listings for all tables in schemas #raw("fruit") and #raw("vegetable")
- #raw("*") to cache listings for all tables in all schemas], [],),
  ([#raw("hive.file-status-cache.excluded-tables")], [Whereas #raw("hive.file-status-cache-tables") is an inclusion list, this is an exclusion list for the cache.

- #raw("fruit.apple,fruit.orange") to #emph[NOT] cache listings only for tables #raw("apple") and #raw("orange") in schema #raw("fruit")
- #raw("fruit.*,vegetable.*") to #emph[NOT] cache listings for all tables in schemas #raw("fruit") and #raw("vegetable")], [],),
  ([#raw("hive.file-status-cache.max-retained-size")], [Maximum retained size of cached file status entries.], [#raw("1GB")],),
  ([#raw("hive.file-status-cache-expire-time")], [How long a cached directory listing is considered valid.], [#raw("1m")],),
  ([#raw("hive.per-transaction-file-status-cache.max-retained-size")], [Maximum retained size of all entries in per transaction file status cache. Retained size limit is shared across all running queries.], [#raw("100MB")],),
  ([#raw("hive.rcfile.time-zone")], [Adjusts binary encoded timestamp values to a specific time zone. For Hive 3.1+, this must be set to UTC.], [JVM default],),
  ([#raw("hive.timestamp-precision")], [Specifies the precision to use for Hive columns of type #raw("TIMESTAMP"). Possible values are #raw("MILLISECONDS"), #raw("MICROSECONDS") and #raw("NANOSECONDS"). Values with higher precision than configured are rounded. The equivalent #link(label("doc-sql-set-session"))[catalog session property] is #raw("timestamp_precision") for session specific use.], [#raw("MILLISECONDS")],),
  ([#raw("hive.temporary-staging-directory-enabled")], [Controls whether the temporary staging directory configured at #raw("hive.temporary-staging-directory-path") is used for write operations. Temporary staging directory is never used for writes to non-sorted tables on S3, encrypted HDFS or external location. Writes to sorted tables will utilize this path for staging temporary files during sorting operation. When disabled, the target storage will be used for staging while writing sorted tables which can be inefficient when writing to object stores like S3.], [#raw("true")],),
  ([#raw("hive.temporary-staging-directory-path")], [Controls the location of temporary staging directory that is used for write operations. The #raw("${USER}") placeholder can be used to use a different location for each user.], [#raw("/tmp/presto-${USER}")],),
  ([#raw("hive.hive-views.enabled")], [Enable translation for #link(label("ref-hive-views"))[Hive views].], [#raw("false")],),
  ([#raw("hive.hive-views.legacy-translation")], [Use the legacy algorithm to translate #link(label("ref-hive-views"))[Hive views]. You can use the #raw("hive_views_legacy_translation") catalog session property for temporary, catalog specific use.], [#raw("false")],),
  ([#raw("hive.parallel-partitioned-bucketed-writes")], [Improve parallelism of partitioned and bucketed table writes. When disabled, the number of writing threads is limited to number of buckets.], [#raw("true")],),
  ([#raw("hive.query-partition-filter-required")], [Set to #raw("true") to force a query to use a partition filter. You can use the #raw("query_partition_filter_required") catalog session property for temporary, catalog specific use.], [#raw("false")],),
  ([#raw("hive.query-partition-filter-required-schemas")], [Allow specifying the list of schemas for which Trino will enforce that queries use a filter on partition keys for source tables. The list can be specified using the #raw("hive.query-partition-filter-required-schemas"), or the #raw("query_partition_filter_required_schemas") session property. The list is taken into consideration only if the #raw("hive.query-partition-filter-required") configuration property or the #raw("query_partition_filter_required") session property is set to #raw("true").], [#raw("[]")],),
  ([#raw("hive.table-statistics-enabled")], [Enables #link(label("doc-optimizer-statistics"))[Table statistics]. The equivalent #link(label("doc-sql-set-session"))[catalog session property] is #raw("statistics_enabled") for session specific use. Set to #raw("false") to disable statistics. Disabling statistics means that #link(label("doc-optimizer-cost-based-optimizations"))[Cost-based optimizations] can not make smart decisions about the query plan.], [#raw("true")],),
  ([#raw("hive.auto-purge")], [Set the default value for the auto\_purge table property for managed tables. See the #link(label("ref-hive-table-properties"))[Hive connector] for more information on auto\_purge.], [#raw("false")],),
  ([#raw("hive.partition-projection-enabled")], [Enables Athena partition projection support], [#raw("true")],),
  ([#raw("hive.s3-glacier-filter")], [Filter S3 objects based on their storage class and restored status if applicable. Possible values are

- #raw("READ_ALL") - read files from all S3 storage classes
- #raw("READ_NON_GLACIER") - read files from non S3 Glacier storage classes
- #raw("READ_NON_GLACIER_AND_RESTORED") - read files from non S3 Glacier storage classes and restored objects from Glacier storage class], [#raw("READ_ALL")],),
  ([#raw("hive.max-partition-drops-per-query")], [Maximum number of partitions to drop in a single query.], [100,000],),
  ([#raw("hive.metastore.partition-batch-size.max")], [Maximum number of partitions processed in a single batch.], [100],),
  ([#raw("hive.single-statement-writes")], [Enables auto-commit for all writes. This can be used to disallow multi-statement write transactions.], [#raw("false")],),
  ([#raw("hive.metadata.parallelism")], [Number of threads used for retrieving metadata. Currently, only table loading is parallelized.], [#raw("8")],),
  ([#raw("hive.protobuf.descriptors.location")], [Path to a directory where binary Protocol Buffer descriptor files are stored to be used for reading tables stored in the #raw("com.twitter.elephantbird.hive.serde.ProtobufDeserializer") format.], [],),
  ([#raw("hive.protobuf.descriptors.cache.max-size")], [Maximum size of the Protocol Buffer descriptors cache], [#raw("64")],),
  ([#raw("hive.protobuf.descriptors.cache.refresh-interval")], [#link(label("ref-prop-type-duration"))[Duration] after which loaded Protocol Buffer descriptors should be reloaded from disk.], [#raw("1d")],)
), header-rows: 1, title: "Hive general configuration properties")

#anchor("ref-hive-file-system-configuration")

=== File system access configuration

The connector supports accessing the following file systems:

- #link(label("doc-object-storage-file-system-azure"))[Azure Storage file system support]
- #link(label("doc-object-storage-file-system-gcs"))[Google Cloud Storage file system support]
- #link(label("doc-object-storage-file-system-s3"))[S3 file system support]
- #link(label("doc-object-storage-file-system-hdfs"))[HDFS file system support]

Enable and configure the file system that your catalog uses. Use #raw("fs.hadoop.enabled") only for HDFS; see #link(label("ref-file-system-legacy"))[legacy file system support] for migration details.

#anchor("ref-hive-fte-support")

=== Fault-tolerant execution support

The connector supports #link(label("doc-admin-fault-tolerant-execution"))[Fault-tolerant execution] of query processing. Read and write operations are both supported with any retry policy on non-transactional tables.

Read operations are supported with any retry policy on transactional tables. Write operations and #raw("CREATE TABLE ... AS") operations are not supported with any retry policy on transactional tables.

== Type mapping

Because Trino and Hive each support types that the other does not, this connector #link(label("ref-type-mapping-overview"))[modifies some types] when reading or writing data. Data types may not map the same way in both directions between Trino and the data source. Refer to the following sections for type mapping in each direction.

=== Hive to Trino type mapping

The connector maps Hive types to the corresponding Trino types following this table:

#list-table((
  ([Hive type], [Trino type],),
  ([#raw("BOOLEAN")], [#raw("BOOLEAN")],),
  ([#raw("TINYINT")], [#raw("TINYINT")],),
  ([#raw("SMALLINT")], [#raw("SMALLINT")],),
  ([#raw("INT")], [#raw("INTEGER")],),
  ([#raw("BIGINT")], [#raw("BIGINT")],),
  ([#raw("FLOAT")], [#raw("REAL")],),
  ([#raw("DOUBLE")], [#raw("DOUBLE")],),
  ([#raw("DECIMAL(p,s)")], [#raw("DECIMAL(p,s)")],),
  ([#raw("STRING")], [#raw("VARCHAR")],),
  ([#raw("VARCHAR(n)")], [#raw("VARCHAR(n)")],),
  ([#raw("CHAR(n)")], [#raw("CHAR(n)")],),
  ([#raw("BINARY")], [#raw("VARBINARY")],),
  ([#raw("DATE")], [#raw("DATE")],),
  ([#raw("TIMESTAMP")], [#raw("TIMESTAMP(p)")],),
  ([#raw("TIMESTAMP WITH LOCAL TIME ZONE")], [#raw("TIMESTAMP(p) WITH TIME ZONE")],),
  ([#raw("ARRAY(e)")], [#raw("ARRAY(e)")],),
  ([#raw("MAP(k,v)")], [#raw("MAP(k,v)")],),
  ([#raw("STRUCT(...)")], [#raw("ROW(...)")],),
  ([#raw("UNIONTYPE<...>")], [#raw("ROW(...)")],)
), header-rows: 1, title: "Hive to Trino type mapping")

The precision #raw("p") for #raw("TIMESTAMP") and #raw("TIMESTAMP WITH LOCAL TIME ZONE") is determined by the #raw("hive.timestamp-precision") configuration property.

#raw("UNIONTYPE") is mapped to #raw("ROW") for reading only. Writing #raw("UNIONTYPE") columns is not supported.

No other types are supported.

=== Trino to Hive type mapping

The connector maps Trino types to the corresponding Hive types following this table:

#list-table((
  ([Trino type], [Hive type],),
  ([#raw("BOOLEAN")], [#raw("BOOLEAN")],),
  ([#raw("TINYINT")], [#raw("TINYINT")],),
  ([#raw("SMALLINT")], [#raw("SMALLINT")],),
  ([#raw("INTEGER")], [#raw("INT")],),
  ([#raw("BIGINT")], [#raw("BIGINT")],),
  ([#raw("REAL")], [#raw("FLOAT")],),
  ([#raw("DOUBLE")], [#raw("DOUBLE")],),
  ([#raw("DECIMAL(p,s)")], [#raw("DECIMAL(p,s)")],),
  ([#raw("VARCHAR")], [#raw("STRING")],),
  ([#raw("VARCHAR(n)")], [#raw("VARCHAR(n)") \(max 65535\)],),
  ([#raw("CHAR(n)")], [#raw("CHAR(n)") \(max 255\)],),
  ([#raw("VARBINARY")], [#raw("BINARY")],),
  ([#raw("DATE")], [#raw("DATE")],),
  ([#raw("TIMESTAMP(p)")], [#raw("TIMESTAMP")],),
  ([#raw("ARRAY(e)")], [#raw("ARRAY(e)")],),
  ([#raw("MAP(k,v)")], [#raw("MAP(k,v)")],),
  ([#raw("ROW(...)")], [#raw("STRUCT(...)")],)
), header-rows: 1, title: "Trino to Hive type mapping")

No other types are supported.

#anchor("ref-hive-security")

== Security

The connector supports different means of authentication for the used #link(label("ref-hive-file-system-configuration"))[file system] and #link(label("ref-hive-configuration"))[metastore].

In addition, the following security-related features are supported.

#anchor("ref-hive-authorization")

== Authorization

You can enable authorization checks by setting the #raw("hive.security") property in the catalog properties file. This property must be one of the following values:

#list-table((
  ([Property value], [Description],),
  ([#raw("allow-all") \(default value\)], [No authorization checks are enforced.],),
  ([#raw("read-only")], [Operations that read data or metadata, such as #raw("SELECT"), are permitted, but none of the operations that write data or metadata, such as #raw("CREATE"), #raw("INSERT") or #raw("DELETE"), are allowed.],),
  ([#raw("file")], [Authorization checks are enforced using a catalog-level access control configuration file whose path is specified in the #raw("security.config-file") catalog configuration property. See #link(label("ref-catalog-file-based-access-control"))[File-based access control] for details.],),
  ([#raw("sql-standard")], [Users are permitted to perform the operations as long as they have the required privileges as per the SQL standard. In this mode, Trino enforces the authorization checks for queries based on the privileges defined in Hive metastore. To alter these privileges, use the #link(label("doc-sql-grant"))[GRANT privilege] and #link(label("doc-sql-revoke"))[REVOKE privilege] commands.

See the #link(label("ref-hive-sql-standard-based-authorization"))[Hive connector] section for details.],)
), header-rows: 1, title: "`hive.security` property values")

#anchor("ref-hive-sql-standard-based-authorization")

=== SQL standard based authorization

When #raw("sql-standard") security is enabled, Trino enforces the same SQL standard-based authorization as Hive does.

Since Trino's #raw("ROLE") syntax support matches the SQL standard, and Hive does not exactly follow the SQL standard, there are the following limitations and differences:

- #raw("CREATE ROLE role WITH ADMIN") is not supported.
- The #raw("admin") role must be enabled to execute #raw("CREATE ROLE"), #raw("DROP ROLE") or #raw("CREATE SCHEMA").
- #raw("GRANT role TO user GRANTED BY someone") is not supported.
- #raw("REVOKE role FROM user GRANTED BY someone") is not supported.
- By default, all a user's roles, except #raw("admin"), are enabled in a new user session.
- One particular role can be selected by executing #raw("SET ROLE role").
- #raw("SET ROLE ALL") enables all of a user's roles except #raw("admin").
- The #raw("admin") role must be enabled explicitly by executing #raw("SET ROLE admin").
- #raw("GRANT privilege ON SCHEMA schema") is not supported. Schema ownership can be changed with #raw("ALTER SCHEMA schema SET AUTHORIZATION user")

#anchor("ref-hive-parquet-encryption")

== Parquet encryption

The Hive connector supports reading Parquet files encrypted with Parquet Modular Encryption \(PME\). Decryption keys can be provided via environment variables. Writing encrypted Parquet files is not supported.

#list-table((
  ([Property name], [Description], [Default],),
  ([#raw("pme.environment-key-retriever.enabled")], [Enable the key retriever that reads decryption keys from environment variables.], [#raw("false")],),
  ([#raw("pme.aad-prefix")], [AAD prefix used when decoding Parquet files. Must match the prefix used when the files were written, if applicable.], [],),
  ([#raw("pme.check-footer-integrity")], [Validate signature for plaintext footer files.], [#raw("true")],)
), header-rows: 1, title: "Parquet encryption properties")

When #raw("pme.environment-key-retriever.enabled") is set, provide keys with environment variables:

- #raw("pme.environment-key-retriever.footer-keys")
- #raw("pme.environment-key-retriever.column-keys")

Each variable accepts either a single base64-encoded key, or a comma-separated list of #raw("id:key") pairs \(base64-encoded keys\) where #raw("id") must match the key metadata embedded in the Parquet file.

#anchor("ref-hive-sql-support")

== SQL support

The connector provides read access and write access to data and metadata in the configured object storage system and metadata stores:

- #link(label("ref-sql-globally-available"))[Globally available statements]; see also #link(label("ref-hive-procedures"))[Globally available statements]
- #link(label("ref-sql-read-operations"))[Read operations]
- #link(label("ref-sql-write-operations"))[sql-write-operations]:
  
  - #link(label("ref-sql-data-management"))[sql-data-management]; see also #link(label("ref-hive-data-management"))[Hive-specific data management]
  - #link(label("ref-sql-schema-table-management"))[sql-schema-table-management]; see also #link(label("ref-hive-schema-and-table-management"))[Hive-specific schema and table management]
  - #link(label("ref-sql-view-management"))[sql-view-management]; see also #link(label("ref-hive-sql-view-management"))[Hive-specific view management]
- #link(label("ref-udf-management"))[SQL statement support]
- #link(label("ref-sql-security-operations"))[sql-security-operations]: see also #link(label("ref-hive-sql-standard-based-authorization"))[SQL standard-based authorization for object storage]
- #link(label("ref-sql-transactions"))[sql-transactions]

Refer to #link(label("doc-appendix-from-hive"))[the migration guide] for practical advice on migrating from Hive to Trino.

The following sections provide Hive-specific information regarding SQL support.

#anchor("ref-hive-examples")

=== Basic usage examples

The examples shown here work on Google Cloud Storage by replacing #raw("s3://") with #raw("gs://").

Create a new Hive table named #raw("page_views") in the #raw("web") schema that is stored using the ORC file format, partitioned by date and country, and bucketed by user into #raw("50") buckets. Note that Hive requires the partition columns to be the last columns in the table:

#code-block(none, "CREATE TABLE example.web.page_views (
  view_time TIMESTAMP,
  user_id BIGINT,
  page_url VARCHAR,
  ds DATE,
  country VARCHAR
)
WITH (
  format = 'ORC',
  partitioned_by = ARRAY['ds', 'country'],
  bucketed_by = ARRAY['user_id'],
  bucket_count = 50
)")

Create a new Hive schema named #raw("web") that stores tables in an S3 bucket named #raw("my-bucket"):

#code-block(none, "CREATE SCHEMA example.web
WITH (location = 's3://my-bucket/')")

Drop a schema:

#code-block(none, "DROP SCHEMA example.web")

Drop a partition from the #raw("page_views") table:

#code-block(none, "DELETE FROM example.web.page_views
WHERE ds = DATE '2016-08-09'
  AND country = 'US'")

Query the #raw("page_views") table:

#code-block(none, "SELECT * FROM example.web.page_views")

List the partitions of the #raw("page_views") table:

#code-block(none, "SELECT * FROM example.web.\"page_views$partitions\"")

Create an external Hive table named #raw("request_logs") that points at existing data in S3:

#code-block(none, "CREATE TABLE example.web.request_logs (
  request_time TIMESTAMP,
  url VARCHAR,
  ip VARCHAR,
  user_agent VARCHAR
)
WITH (
  format = 'TEXTFILE',
  external_location = 's3://my-bucket/data/logs/'
)")

Collect statistics for the #raw("request_logs") table:

#code-block(none, "ANALYZE example.web.request_logs;")

Drop the external table #raw("request_logs"). This only drops the metadata for the table. The referenced data directory is not deleted:

#code-block(none, "DROP TABLE example.web.request_logs")

- #link(label("doc-sql-create-table-as"))[CREATE TABLE AS] can be used to create transactional tables in ORC format like this:
  
  #code-block(none, "CREATE TABLE <name>
  WITH (
      format='ORC',
      transactional=true
  )
  AS <query>")

Add an empty partition to the #raw("page_views") table:

#code-block(none, "CALL system.create_empty_partition(
    schema_name => 'web',
    table_name => 'page_views',
    partition_columns => ARRAY['ds', 'country'],
    partition_values => ARRAY['2016-08-09', 'US']);")

Drop stats for a partition of the #raw("page_views") table:

#code-block(none, "CALL system.drop_stats(
    schema_name => 'web',
    table_name => 'page_views',
    partition_values => ARRAY[ARRAY['2016-08-09', 'US']]);")

Tables created in Hive with #link("https://github.com/twitter/elephant-bird/wiki/How-to-use-Elephant-Bird-with-Hive")[Twitter Elephantbird] are supported to read. The binary protobuf descriptor as mentioned in the #raw("serialization.class") should be stored in a directory that is configured via #raw("hive.protobuf.descriptors.location") on every worker.

#code-block(none, "...
row format serde \"com.twitter.elephantbird.hive.serde.ProtobufDeserializer\"
with serdeproperties (
    \"serialization.class\"=\"com.example.proto.gen.Storage$User\"
)")

#anchor("ref-hive-procedures")

=== Procedures

Use the #link(label("doc-sql-call"))[CALL] statement to perform data manipulation or administrative tasks. Procedures must include a qualified catalog name, if your Hive catalog is called #raw("web"):

#code-block(none, "CALL web.system.example_procedure()")

The following procedures are available:

- #raw("system.create_empty_partition(schema_name, table_name, partition_columns, partition_values)")
  
  Create an empty partition in the specified table.
- #raw("system.sync_partition_metadata(schema_name, table_name, mode, case_sensitive)")
  
  Check and update partitions list in metastore. There are three modes available:
  
  - #raw("ADD") : add any partitions that exist on the file system, but not in the metastore.
  - #raw("DROP"): drop any partitions that exist in the metastore, but not on the file system.
  - #raw("FULL"): perform both #raw("ADD") and #raw("DROP").
  
  The #raw("case_sensitive") argument is optional. The default value is #raw("true") for compatibility with Hive's #raw("MSCK REPAIR TABLE") behavior, which expects the partition column names in file system paths to use lowercase \(e.g. #raw("col_x=SomeValue")\). Partitions on the file system not conforming to this convention are ignored, unless the argument is set to #raw("false").
- #raw("system.drop_stats(schema_name, table_name, partition_values)")
  
  Drops statistics for a subset of partitions or the entire table. The partitions are specified as an array whose elements are arrays of partition values \(similar to the #raw("partition_values") argument in #raw("create_empty_partition")\). If #raw("partition_values") argument is omitted, stats are dropped for the entire table.

#anchor("ref-register-partition")

- #raw("system.register_partition(schema_name, table_name, partition_columns, partition_values, location)")
  
  Registers existing location as a new partition in the metastore for the specified table.
  
  When the #raw("location") argument is omitted, the partition location is constructed using #raw("partition_columns") and #raw("partition_values").
  
  Due to security reasons, the procedure is enabled only when #raw("hive.allow-register-partition-procedure") is set to #raw("true").

#anchor("ref-unregister-partition")

- #raw("system.unregister_partition(schema_name, table_name, partition_columns, partition_values)")
  
  Unregisters given, existing partition in the metastore for the specified table. The partition data is not deleted.

#anchor("ref-hive-flush-metadata-cache")

- #raw("system.flush_metadata_cache()")
  
  Flush all Hive metadata caches.
- #raw("system.flush_metadata_cache(schema_name => ..., table_name => ...)")
  
  Flush Hive metadata caches entries connected with selected table. Procedure requires named parameters to be passed
- #raw("system.flush_metadata_cache(schema_name => ..., table_name => ..., partition_columns => ARRAY[...], partition_values => ARRAY[...])")
  
  Flush Hive metadata cache entries connected with selected partition. Procedure requires named parameters to be passed.

#anchor("ref-hive-data-management")

=== Data management

The #link(label("ref-sql-data-management"))[sql-data-management] functionality includes support for #raw("INSERT"), #raw("UPDATE"), #raw("DELETE"), and #raw("MERGE") statements, with the exact support depending on the storage system, file format, and metastore.

When connecting to a Hive metastore version 3.x, the Hive connector supports reading from and writing to insert-only and ACID tables, with full support for partitioning and bucketing.

#link(label("doc-sql-delete"))[DELETE] applied to non-transactional tables is only supported if the table is partitioned and the #raw("WHERE") clause matches entire partitions. Transactional Hive tables with ORC format support "row-by-row" deletion, in which the #raw("WHERE") clause may match arbitrary sets of rows.

#link(label("doc-sql-update"))[UPDATE] is only supported for transactional Hive tables with format ORC. #raw("UPDATE") of partition or bucket columns is not supported.

#link(label("doc-sql-merge"))[MERGE] is only supported for ACID tables.

ACID tables created with #link("https://cwiki.apache.org/confluence/display/Hive/Streaming+Data+Ingest")[Hive Streaming Ingest] are not supported.

#anchor("ref-hive-schema-and-table-management")

=== Schema and table management

The Hive connector supports querying and manipulating Hive tables and schemas \(databases\). While some uncommon operations must be performed using Hive directly, most operations can be performed using Trino.

==== Schema evolution

Hive table partitions can differ from the current table schema. This occurs when the data types of columns of a table are changed from the data types of columns of preexisting partitions. The Hive connector supports this schema evolution by allowing the same conversions as Hive. The following table lists possible data type conversions.

#list-table((
  ([Data type], [Converted to],),
  ([#raw("BOOLEAN")], [#raw("VARCHAR")],),
  ([#raw("VARCHAR")], [#raw("BOOLEAN"), #raw("TINYINT"), #raw("SMALLINT"), #raw("INTEGER"), #raw("BIGINT"), #raw("REAL"), #raw("DOUBLE"), #raw("TIMESTAMP"), #raw("DATE"), #raw("CHAR") as well as narrowing conversions for #raw("VARCHAR")],),
  ([#raw("CHAR")], [#raw("VARCHAR"), narrowing conversions for #raw("CHAR")],),
  ([#raw("TINYINT")], [#raw("VARCHAR"), #raw("SMALLINT"), #raw("INTEGER"), #raw("BIGINT"), #raw("DOUBLE"), #raw("DECIMAL")],),
  ([#raw("SMALLINT")], [#raw("VARCHAR"), #raw("INTEGER"), #raw("BIGINT"), #raw("DOUBLE"), #raw("DECIMAL")],),
  ([#raw("INTEGER")], [#raw("VARCHAR"), #raw("BIGINT"), #raw("DOUBLE"), #raw("DECIMAL")],),
  ([#raw("BIGINT")], [#raw("VARCHAR"), #raw("DOUBLE"), #raw("DECIMAL")],),
  ([#raw("REAL")], [#raw("DOUBLE"), #raw("DECIMAL")],),
  ([#raw("DOUBLE")], [#raw("FLOAT"), #raw("DECIMAL")],),
  ([#raw("DECIMAL")], [#raw("DOUBLE"), #raw("REAL"), #raw("VARCHAR"), #raw("TINYINT"), #raw("SMALLINT"), #raw("INTEGER"), #raw("BIGINT"), as well as narrowing and widening conversions for #raw("DECIMAL")],),
  ([#raw("DATE")], [#raw("VARCHAR")],),
  ([#raw("TIMESTAMP")], [#raw("VARCHAR"), #raw("DATE")],),
  ([#raw("VARBINARY")], [#raw("VARCHAR")],)
), header-rows: 1, title: "Hive schema evolution type conversion")

Any conversion failure results in null, which is the same behavior as Hive. For example, converting the string #raw("'foo'") to a number, or converting the string #raw("'1234'") to a #raw("TINYINT") \(which has a maximum value of #raw("127")\).

#anchor("ref-hive-avro-schema")

==== Avro schema evolution

Trino supports querying and manipulating Hive tables with the Avro storage format, which has the schema set based on an Avro schema file\/literal. Trino is also capable of creating the tables in Trino by inferring the schema from a valid Avro schema file located locally, or remotely in HDFS\/Web server.

To specify that the Avro schema should be used for interpreting table data, use the #raw("avro_schema_url") table property.

The schema can be placed in the local file system or remotely in the following locations:

- HDFS \(e.g. #raw("avro_schema_url = 'hdfs://user/avro/schema/avro_data.avsc'")\)
- S3 \(e.g. #raw("avro_schema_url = 's3n:///schema_bucket/schema/avro_data.avsc'")\)
- A web server \(e.g. #raw("avro_schema_url = 'http://example.org/schema/avro_data.avsc'")\)

The URL, where the schema is located, must be accessible from the Hive metastore and Trino coordinator\/worker nodes.

Alternatively, you can use the table property #raw("avro_schema_literal") to define the Avro schema.

The table created in Trino using the #raw("avro_schema_url") or #raw("avro_schema_literal") property behaves the same way as a Hive table with #raw("avro.schema.url") or #raw("avro.schema.literal") set.

Example:

#code-block(none, "CREATE TABLE example.avro.avro_data (
   id BIGINT
 )
WITH (
   format = 'AVRO',
   avro_schema_url = '/usr/local/avro_data.avsc'
)")

The columns listed in the DDL \(#raw("id") in the above example\) is ignored if #raw("avro_schema_url") is specified. The table schema matches the schema in the Avro schema file. Before any read operation, the Avro schema is accessed so the query result reflects any changes in schema. Thus Trino takes advantage of Avro's backward compatibility abilities.

If the schema of the table changes in the Avro schema file, the new schema can still be used to read old data. Newly added\/renamed fields #emph[must] have a default value in the Avro schema file.

The schema evolution behavior is as follows:

- Column added in new schema: Data created with an older schema produces a #emph[default] value when table is using the new schema.
- Column removed in new schema: Data created with an older schema no longer outputs the data from the column that was removed.
- Column is renamed in the new schema: This is equivalent to removing the column and adding a new one, and data created with an older schema produces a #emph[default] value when table is using the new schema.
- Changing type of column in the new schema: If the type coercion is supported by Avro or the Hive connector, then the conversion happens. An error is thrown for incompatible types.

===== Limitations

The following operations are not supported when #raw("avro_schema_url") is set:

- #raw("CREATE TABLE AS") is not supported.
- Bucketing\(#raw("bucketed_by")\) columns are not supported in #raw("CREATE TABLE").
- #raw("ALTER TABLE") commands modifying columns are not supported.

#anchor("ref-hive-alter-table-execute")

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

The #raw("optimize") command is disabled by default, and can be enabled for a catalog with the #raw("<catalog-name>.non_transactional_optimize_enabled") session property:

#code-block("sql", "SET SESSION <catalog_name>.non_transactional_optimize_enabled=true")

#warning[
Because Hive tables are non-transactional, take note of the following possible outcomes:

- If queries are run against tables that are currently being optimized, duplicate rows may be read.
- In rare cases where exceptions occur during the #raw("optimize") operation, a manual cleanup of the table directory is needed. In this situation, refer to the Trino logs and query failure messages to see which files must be deleted.
]

#anchor("ref-hive-table-properties")

==== Table properties

Table properties supply or set metadata for the underlying tables. This is key for #link(label("doc-sql-create-table-as"))[CREATE TABLE AS] statements. Table properties are passed to the connector using a #link(label("doc-sql-create-table-as"))[WITH] clause:

#code-block(none, "CREATE TABLE tablename
WITH (format='CSV',
      csv_escape = '\"')")

#list-table((
  ([Property name], [Description], [Default],),
  ([#raw("auto_purge")], [Indicates to the configured metastore to perform a purge when a table or partition is deleted instead of a soft deletion using the trash.], [],),
  ([#raw("avro_schema_url")], [The URI pointing to #link(label("ref-hive-avro-schema"))[Hive connector] for the table.], [],),
  ([#raw("bucket_count")], [The number of buckets to group data into. Only valid if used with #raw("bucketed_by").], [0],),
  ([#raw("bucketed_by")], [The bucketing column for the storage table. Only valid if used with #raw("bucket_count").], [#raw("[]")],),
  ([#raw("bucketing_version")], [Specifies which Hive bucketing version to use. Valid values are #raw("1") or #raw("2").], [],),
  ([#raw("csv_escape")], [The CSV escape character. Requires CSV format.], [],),
  ([#raw("csv_quote")], [The CSV quote character. Requires CSV format.], [],),
  ([#raw("csv_separator")], [The CSV separator character. Requires CSV format. You can use other separators such as #raw("|") or use Unicode to configure invisible separators such tabs with #raw("U&'\\0009'").], [#raw(",")],),
  ([#raw("external_location")], [The URI for an external Hive table on S3, Azure Blob Storage, etc. See the #link(label("ref-hive-examples"))[Hive connector] for more information.], [],),
  ([#raw("format")], [The table file format. Valid values include #raw("ORC"), #raw("PARQUET"), #raw("AVRO"), #raw("RCBINARY"), #raw("RCTEXT"), #raw("SEQUENCEFILE"), #raw("JSON"), #raw("OPENX_JSON"), #raw("TEXTFILE"), #raw("CSV"), and #raw("REGEX"). The catalog property #raw("hive.storage-format") sets the default value and can change it to a different default.], [],),
  ([#raw("null_format")], [The serialization format for #raw("NULL") value. Requires TextFile, RCText, or SequenceFile format.], [],),
  ([#raw("orc_bloom_filter_columns")], [Comma separated list of columns to use for ORC bloom filter. It improves the performance of queries using equality predicates, such as #raw("="), #raw("IN") and small range predicates, when reading ORC files. Requires ORC format.], [#raw("[]")],),
  ([#raw("orc_bloom_filter_fpp")], [The ORC bloom filters false positive probability. Requires ORC format.], [0.05],),
  ([#raw("partitioned_by")], [The partitioning column for the storage table. The columns listed in the #raw("partitioned_by") clause must be the last columns as defined in the DDL.], [#raw("[]")],),
  ([#raw("parquet_bloom_filter_columns")], [Comma separated list of columns to use for Parquet bloom filter. It improves the performance of queries using equality predicates, such as #raw("="), #raw("IN") and small range predicates, when reading Parquet files. Requires Parquet format.], [#raw("[]")],),
  ([#raw("skip_footer_line_count")], [The number of footer lines to ignore when parsing the file for data. Requires TextFile or CSV format tables.], [],),
  ([#raw("skip_header_line_count")], [The number of header lines to ignore when parsing the file for data. Requires TextFile or CSV format tables.], [],),
  ([#raw("sorted_by")], [The column to sort by to determine bucketing for row. Only valid if #raw("bucketed_by") and #raw("bucket_count") are specified as well.], [#raw("[]")],),
  ([#raw("textfile_field_separator")], [Allows the use of custom field separators, such as '|', for TextFile formatted tables.], [],),
  ([#raw("textfile_field_separator_escape")], [Allows the use of a custom escape character for TextFile formatted tables.], [],),
  ([#raw("transactional")], [Set this property to #raw("true") to create an ORC ACID transactional table. Requires ORC format. This property may be shown as true for insert-only tables created using older versions of Hive.], [],),
  ([#raw("partition_projection_enabled")], [Enables partition projection for selected table. Mapped from AWS Athena table property #link("https://docs.aws.amazon.com/athena/latest/ug/partition-projection-setting-up.html")[projection.enabled].], [],),
  ([#raw("partition_projection_ignore")], [Ignore any partition projection properties stored in the metastore for the selected table. This is a Trino-only property which allows you to work around compatibility issues on a specific table, and if enabled, Trino ignores all other configuration options related to partition projection.], [],),
  ([#raw("partition_projection_location_template")], [Projected partition location template, such as #raw("s3a://test/name=${name}/"). Mapped from the AWS Athena table property #link("https://docs.aws.amazon.com/athena/latest/ug/partition-projection-setting-up.html#partition-projection-specifying-custom-s3-storage-locations")[storage.location.template]], [#raw("${table_location}/${partition_name}")],),
  ([#raw("extra_properties")], [Additional properties added to a Hive table. The properties are not used by Trino, and are available in the #raw("$properties") metadata table. The properties are not included in the output of #raw("SHOW CREATE TABLE") statements.], [],)
), header-rows: 1, title: "Hive connector table properties")

#anchor("ref-hive-special-tables")

==== Metadata tables

The raw Hive table properties are available as a hidden table, containing a separate column per table property, with a single row containing the property values.

===== #raw("$properties") table

The properties table name is composed with the table name and #raw("$properties") appended. It exposes the parameters of the table in the metastore.

You can inspect the property names and values with a simple query:

#code-block(none, "SELECT * FROM example.web.\"page_views$properties\";")

#code-block("text", "       stats_generated_via_stats_task        | auto.purge |       trino_query_id       | trino_version | transactional
---------------------------------------------+------------+-----------------------------+---------------+---------------
 workaround for potential lack of HIVE-12730 | false      | 20230705_152456_00001_nfugi | 434           | false")

===== #raw("$partitions") table

The #raw("$partitions") table provides a list of all partition values of a partitioned table.

The following example query returns all partition values from the #raw("page_views") table in the #raw("web") schema of the #raw("example") catalog:

#code-block(none, "SELECT * FROM example.web.\"page_views$partitions\";")

#code-block("text", "     day    | country
------------+---------
 2023-07-01 | POL
 2023-07-02 | POL
 2023-07-03 | POL
 2023-03-01 | USA
 2023-03-02 | USA")

#anchor("ref-hive-column-properties")

==== Column properties

#list-table((
  ([Property name], [Description], [Default],),
  ([#raw("partition_projection_type")], [Defines the type of partition projection to use on this column. May be used only on partition columns. Available types: #raw("ENUM"), #raw("INTEGER"), #raw("DATE"), #raw("INJECTED"). Mapped from the AWS Athena table property #link("https://docs.aws.amazon.com/athena/latest/ug/partition-projection-supported-types.html")[projection.\${columnName}.type].], [],),
  ([#raw("partition_projection_values")], [Used with #raw("partition_projection_type") set to #raw("ENUM"). Contains a static list of values used to generate partitions. Mapped from the AWS Athena table property #link("https://docs.aws.amazon.com/athena/latest/ug/partition-projection-supported-types.html")[projection.\${columnName}.values].], [],),
  ([#raw("partition_projection_range")], [Used with #raw("partition_projection_type") set to #raw("INTEGER") or #raw("DATE") to define a range. It is a two-element array, describing the minimum and maximum range values used to generate partitions. Generation starts from the minimum, then increments by the defined #raw("partition_projection_interval") to the maximum. For example, the format is #raw("['1', '4']") for a #raw("partition_projection_type") of #raw("INTEGER") and #raw("['2001-01-01', '2001-01-07']") or #raw("['NOW-3DAYS', 'NOW']") for a #raw("partition_projection_type") of #raw("DATE"). Mapped from the AWS Athena table property #link("https://docs.aws.amazon.com/athena/latest/ug/partition-projection-supported-types.html")[projection.\${columnName}.range].], [],),
  ([#raw("partition_projection_interval")], [Used with #raw("partition_projection_type") set to #raw("INTEGER") or #raw("DATE"). It represents the interval used to generate partitions within the given range #raw("partition_projection_range"). Mapped from the AWS Athena table property #link("https://docs.aws.amazon.com/athena/latest/ug/partition-projection-supported-types.html")[projection.\${columnName}.interval].], [],),
  ([#raw("partition_projection_digits")], [Used with #raw("partition_projection_type") set to #raw("INTEGER"). The number of digits to be used with integer column projection. Mapped from the AWS Athena table property #link("https://docs.aws.amazon.com/athena/latest/ug/partition-projection-supported-types.html")[projection.\${columnName}.digits].], [],),
  ([#raw("partition_projection_format")], [Used with #raw("partition_projection_type") set to #raw("DATE"). The date column projection format, defined as a string such as #raw("yyyy MM") or #raw("MM-dd-yy HH:mm:ss") for use with the #link("https://docs.oracle.com/javase/8/docs/api/java/time/format/DateTimeFormatter.html")[Java DateTimeFormatter class]. Mapped from the AWS Athena table property #link("https://docs.aws.amazon.com/athena/latest/ug/partition-projection-supported-types.html")[projection.\${columnName}.format].], [],),
  ([#raw("partition_projection_interval_unit")], [Used with #raw("partition_projection_type=DATA"). The date column projection range interval unit given in #raw("partition_projection_interval"). Mapped from the AWS Athena table property #link("https://docs.aws.amazon.com/athena/latest/ug/partition-projection-supported-types.html")[projection.\${columnName}.interval.unit].], [],)
), header-rows: 1, title: "Hive connector column properties")

#anchor("ref-hive-special-columns")

==== Metadata columns

In addition to the defined columns, the Hive connector automatically exposes metadata in a number of hidden columns in each table:

- #raw("$bucket"): Bucket number for this row
- #raw("$path"): Full file system path name of the file for this row
- #raw("$file_modified_time"): Date and time of the last modification of the file for this row
- #raw("$file_size"): Size of the file for this row
- #raw("$partition"): Partition name for this row

You can use these columns in your SQL statements like any other column. They can be selected directly, or used in conditional statements. For example, you can inspect the file size, location and partition for each record:

#code-block(none, "SELECT *, \"$path\", \"$file_size\", \"$partition\"
FROM example.web.page_views;")

Retrieve all records that belong to files stored in the partition #raw("ds=2016-08-09/country=US"):

#code-block(none, "SELECT *, \"$path\", \"$file_size\"
FROM example.web.page_views
WHERE \"$partition\" = 'ds=2016-08-09/country=US'")

#anchor("ref-hive-sql-view-management")

=== View management

Trino allows reading from Hive materialized views, and can be configured to support reading Hive views.

==== Materialized views

The Hive connector supports reading from Hive materialized views. In Trino, these views are presented as regular, read-only tables.

#anchor("ref-hive-views")

==== Hive views

Hive views are defined in HiveQL and stored in the Hive Metastore Service. They are analyzed to allow read access to the data.

The Hive connector includes support for reading Hive views with three different modes.

- Disabled
- Legacy
- Experimental

If using Hive views from Trino is required, you must compare results in Hive and Trino for each view definition to ensure identical results. Use the experimental mode whenever possible. Avoid using the legacy mode. Leave Hive views support disabled, if you are not accessing any Hive views from Trino.

You can configure the behavior in your catalog properties file.

By default, Hive views are executed with the #raw("RUN AS DEFINER") security mode. Set the  #raw("hive.hive-views.run-as-invoker") catalog configuration property to #raw("true") to use #raw("RUN AS INVOKER") semantics.

#strong[Disabled]

The default behavior is to ignore Hive views. This means that your business logic and data encoded in the views is not available in Trino.

#strong[Legacy]

A very simple implementation to execute Hive views, and therefore allow read access to the data in Trino, can be enabled with #raw("hive.hive-views.enabled=true") and #raw("hive.hive-views.legacy-translation=true").

For temporary usage of the legacy behavior for a specific catalog, you can set the #raw("hive_views_legacy_translation") #link(label("doc-sql-set-session"))[catalog session property] to #raw("true").

This legacy behavior interprets any HiveQL query that defines a view as if it is written in SQL. It does not do any translation, but instead relies on the fact that HiveQL is very similar to SQL.

This works for very simple Hive views, but can lead to problems for more complex queries. For example, if a HiveQL function has an identical signature but different behaviors to the SQL version, the returned results may differ. In more extreme cases the queries might fail, or not even be able to be parsed and executed.

#strong[Experimental]

The new behavior is better engineered and has the potential to become a lot more powerful than the legacy implementation. It can analyze, process, and rewrite Hive views and contained expressions and statements.

It supports the following Hive view functionality:

- #raw("UNION [DISTINCT]") and #raw("UNION ALL") against Hive views
- Nested #raw("GROUP BY") clauses
- #raw("current_user()")
- #raw("LATERAL VIEW OUTER EXPLODE")
- #raw("LATERAL VIEW [OUTER] EXPLODE") on array of struct
- #raw("LATERAL VIEW json_tuple")

You can enable the experimental behavior with #raw("hive.hive-views.enabled=true"). Remove the #raw("hive.hive-views.legacy-translation") property or set it to #raw("false") to make sure legacy is not enabled.

Keep in mind that numerous features are not yet implemented when experimenting with this feature. The following is an incomplete list of #strong[missing] functionality:

- HiveQL #raw("current_date"), #raw("current_timestamp"), and others
- Hive function calls including #raw("translate()"), window functions, and others
- Common table expressions and simple case expressions
- Honor timestamp precision setting
- Support all Hive data types and correct mapping to Trino types
- Ability to process custom UDFs

== Performance

The connector includes a number of performance improvements, detailed in the following sections.

#anchor("ref-hive-table-statistics")

=== Table statistics

The Hive connector supports collecting and managing #link(label("doc-optimizer-statistics"))[table statistics] to improve query processing performance.

When writing data, the Hive connector always collects basic statistics \(#raw("numFiles"), #raw("numRows"), #raw("rawDataSize"), #raw("totalSize")\) and by default will also collect column level statistics:

#list-table((
  ([Column type], [Collectible statistics],),
  ([#raw("TINYINT")], [Number of nulls, number of distinct values, min\/max values],),
  ([#raw("SMALLINT")], [Number of nulls, number of distinct values, min\/max values],),
  ([#raw("INTEGER")], [Number of nulls, number of distinct values, min\/max values],),
  ([#raw("BIGINT")], [Number of nulls, number of distinct values, min\/max values],),
  ([#raw("DOUBLE")], [Number of nulls, number of distinct values, min\/max values],),
  ([#raw("REAL")], [Number of nulls, number of distinct values, min\/max values],),
  ([#raw("DECIMAL")], [Number of nulls, number of distinct values, min\/max values],),
  ([#raw("DATE")], [Number of nulls, number of distinct values, min\/max values],),
  ([#raw("TIMESTAMP")], [Number of nulls, number of distinct values, min\/max values],),
  ([#raw("VARCHAR")], [Number of nulls, number of distinct values],),
  ([#raw("CHAR")], [Number of nulls, number of distinct values],),
  ([#raw("VARBINARY")], [Number of nulls],),
  ([#raw("BOOLEAN")], [Number of nulls, number of true\/false values],)
), header-rows: 1, title: "Available table statistics")

#anchor("ref-hive-analyze")

==== Updating table and partition statistics

If your queries are complex and include joining large data sets, running #link(label("doc-sql-analyze"))[ANALYZE] on tables\/partitions may improve query performance by collecting statistical information about the data.

When analyzing a partitioned table, the partitions to analyze can be specified via the optional #raw("partitions") property, which is an array containing the values of the partition keys in the order they are declared in the table schema:

#code-block(none, "ANALYZE table_name WITH (
    partitions = ARRAY[
        ARRAY['p1_value1', 'p1_value2'],
        ARRAY['p2_value1', 'p2_value2']])")

This query will collect statistics for two partitions with keys #raw("p1_value1, p1_value2") and #raw("p2_value1, p2_value2").

On wide tables, collecting statistics for all columns can be expensive and can have a detrimental effect on query planning. It is also typically unnecessary - statistics are only useful on specific columns, like join keys, predicates, grouping keys. One can specify a subset of columns to be analyzed via the optional #raw("columns") property:

#code-block(none, "ANALYZE table_name WITH (
    partitions = ARRAY[ARRAY['p2_value1', 'p2_value2']],
    columns = ARRAY['col_1', 'col_2'])")

This query collects statistics for columns #raw("col_1") and #raw("col_2") for the partition with keys #raw("p2_value1, p2_value2").

Note that if statistics were previously collected for all columns, they must be dropped before re-analyzing just a subset:

#code-block(none, "CALL system.drop_stats('schema_name', 'table_name')")

You can also drop statistics for selected partitions only:

#code-block(none, "CALL system.drop_stats(
    schema_name => 'schema',
    table_name => 'table',
    partition_values => ARRAY[ARRAY['p2_value1', 'p2_value2']])")

#anchor("ref-hive-dynamic-filtering")

=== Dynamic filtering

The Hive connector supports the #link(label("doc-admin-dynamic-filtering"))[dynamic filtering] optimization. Dynamic partition pruning is supported for partitioned tables stored in any file format for broadcast as well as partitioned joins. Dynamic bucket pruning is supported for bucketed tables stored in any file format for broadcast joins only.

For tables stored in ORC or Parquet file format, dynamic filters are also pushed into local table scan on worker nodes for broadcast joins. Dynamic filter predicates pushed into the ORC and Parquet readers are used to perform stripe or row-group pruning and save on disk I\/O. Sorting the data within ORC or Parquet files by the columns used in join criteria significantly improves the effectiveness of stripe or row-group pruning. This is because grouping similar data within the same stripe or row-group greatly improves the selectivity of the min\/max indexes maintained at stripe or row-group level.

==== Delaying execution for dynamic filters

It can often be beneficial to wait for the collection of dynamic filters before starting a table scan. This extra wait time can potentially result in significant overall savings in query and CPU time, if dynamic filtering is able to reduce the amount of scanned data.

For the Hive connector, a table scan can be delayed for a configured amount of time until the collection of dynamic filters by using the configuration property #raw("hive.dynamic-filtering.wait-timeout") in the catalog file or the catalog session property #raw("<hive-catalog>.dynamic_filtering_wait_timeout").

#anchor("ref-hive-table-redirection")

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

The connector supports redirection from Hive tables to Iceberg, Delta Lake, and Hudi tables with the following catalog configuration properties:

- #raw("hive.iceberg-catalog-name"): Name of the catalog, configured with the #link(label("doc-connector-iceberg"))[Iceberg connector], to use for reading Iceberg tables.
- #raw("hive.delta-lake-catalog-name"): Name of the catalog, configured with the #link(label("doc-connector-delta-lake"))[Delta Lake connector], to use for reading Delta Lake tables.
- #raw("hive.hudi-catalog-name"): Name of the catalog, configured with the #link(label("doc-connector-hudi"))[Hudi connector], to use for reading Hudi tables.

=== File system cache

The connector supports configuring and using #link(label("doc-object-storage-file-system-cache"))[file system caching].

#anchor("ref-hive-performance-tuning-configuration")

=== Performance tuning configuration properties

The following table describes performance tuning properties for the Hive connector.

#warning[
Performance tuning configuration properties are considered expert-level features. Altering these properties from their default values is likely to cause instability and performance degradation.
]

#list-table((
  ([Property name], [Description], [Default value],),
  ([#raw("hive.max-outstanding-splits")], [The target number of buffered splits for each table scan in a query, before the scheduler tries to pause.], [#raw("1000")],),
  ([#raw("hive.max-outstanding-splits-size")], [The maximum size allowed for buffered splits for each table scan in a query, before the query fails.], [#raw("256 MB")],),
  ([#raw("hive.max-splits-per-second")], [The maximum number of splits generated per second per table scan. This can be used to reduce the load on the storage system. By default, there is no limit, which results in Trino maximizing the parallelization of data access.], [],),
  ([#raw("hive.max-initial-splits")], [For each table scan, the coordinator first assigns file sections of up to #raw("max-initial-split-size"). After #raw("max-initial-splits") have been assigned, #raw("max-split-size") is used for the remaining splits.], [#raw("200")],),
  ([#raw("hive.max-initial-split-size")], [The size of a single file section assigned to a worker until #raw("max-initial-splits") have been assigned. Smaller splits results in more parallelism, which gives a boost to smaller queries.], [#raw("32 MB")],),
  ([#raw("hive.max-split-size")], [The largest size of a single file section assigned to a worker. Smaller splits result in more parallelism and thus can decrease latency, but also have more overhead and increase load on the system.], [#raw("64 MB")],)
), header-rows: 1)

== Hive 3-related limitations

- For security reasons, the #raw("sys") system catalog is not accessible.
- Hive's #raw("timestamp with local zone") data type is mapped to #raw("timestamp with time zone") with UTC timezone. It only supports reading values - writing to tables with columns of this type is not supported.
- Due to Hive issues #link("https://issues.apache.org/jira/browse/HIVE-21002")[HIVE-21002] and #link("https://issues.apache.org/jira/browse/HIVE-22167")[HIVE-22167], Trino does not correctly read #raw("TIMESTAMP") values from Parquet, RCBinary, or Avro file formats created by Hive 3.1 or later. When reading from these file formats, Trino returns different results than Hive.
- Trino does not support gathering table statistics for Hive transactional tables. You must use Hive to gather table statistics with #link("https://cwiki.apache.org/confluence/display/hive/statsdev#StatsDev-ExistingTables%E2%80%93ANALYZE")[ANALYZE statement] after table creation.
