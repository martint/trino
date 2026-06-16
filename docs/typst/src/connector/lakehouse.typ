#import "/lib/trino-docs.typ": *

#anchor("doc-connector-lakehouse")
= Lakehouse connector

The Lakehouse connector provides a unified way to interact with data stored in various table formats across different storage systems and metastore services. This single connector allows you to query and write data seamlessly, regardless of whether it's in Iceberg, Delta Lake, or Hudi table formats, or traditional Hive tables.

This connector offers flexible connectivity to popular metastore services including AWS Glue and Hive Metastore. For data storage, it supports a wide range of options including cloud storage services such as AWS S3, S3-compatible storage, Google Cloud Storage \(GCS\), and Azure Blob Storage, as well as HDFS installations.

The connector combines the features of the #link(label("doc-connector-hive"))[Hive], #link(label("doc-connector-iceberg"))[Iceberg], #link(label("doc-connector-delta-lake"))[Delta Lake], and #link(label("doc-connector-hudi"))[Hudi] connectors into a single connector. The configuration properties, session properties, table properties, and beahvior come from the underlying connectors. Please refer to the documentation for the underlying connectors for the table formats that you are using.

== General configuration

To configure the Lakehouse connector, create a catalog properties file #raw("etc/catalog/example.properties") with the following content, replacing the properties as appropriate:

#code-block("text", "connector.name=lakehouse")

You must configure a #link(label("doc-object-storage-metastores"))[AWS Glue or a Hive metastore]. The #raw("hive.metastore") property will also configure the Iceberg catalog. Do not specify #raw("iceberg.catalog.type").

You must select and configure one of the #link(label("ref-lakehouse-file-system-configuration"))[supported file systems].

== Configuration properties

The following configuration properties are available:

#list-table((
  ([Property name], [Description], [Default],),
  ([#raw("lakehouse.table-type")], [The default table type for newly created tables when the #raw("format") table property is not specified. Possible values:

- #raw("HIVE")
- #raw("ICEBERG")
- #raw("DELTA")], [#raw("ICEBERG")],)
), header-rows: 1)

#anchor("ref-lakehouse-file-system-configuration")

== File system access configuration

The connector supports accessing the following file systems:

- #link(label("doc-object-storage-file-system-azure"))[Azure Storage file system support]
- #link(label("doc-object-storage-file-system-gcs"))[Google Cloud Storage file system support]
- #link(label("doc-object-storage-file-system-s3"))[S3 file system support]
- #link(label("doc-object-storage-file-system-hdfs"))[HDFS file system support]

Enable and configure the file system that your catalog uses. Use #raw("fs.hadoop.enabled") only for HDFS; see #link(label("ref-file-system-legacy"))[legacy file system support] for migration details.

== Examples

Create an Iceberg table:

#code-block("sql", "CREATE TABLE iceberg_table (
  c1 INTEGER,
  c2 DATE,
  c3 DOUBLE
)
WITH (
  type = 'ICEBERG'
  format = 'PARQUET',
  partitioning = ARRAY['c1', 'c2'],
  sorted_by = ARRAY['c3']
);")

Create a Hive table:

#code-block("sql", "CREATE TABLE hive_page_views (
  view_time TIMESTAMP,
  user_id BIGINT,
  page_url VARCHAR,
  ds DATE,
  country VARCHAR
)
WITH (
  type = 'HIVE',
  format = 'ORC',
  partitioned_by = ARRAY['ds', 'country'],
  bucketed_by = ARRAY['user_id'],
  bucket_count = 50
)")
