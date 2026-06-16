#import "/lib/trino-docs.typ": *

#anchor("doc-object-storage")
= Object storage

Object storage systems are commonly used to create data lakes or data lake houses. These systems provide methods to store objects in a structured manner and means to access them, for example using an API over HTTP. The objects are files in various format including ORC, Parquet and others. Object storage systems are available as service from public cloud providers and others vendors, or can be self-hosted using commercial as well as open source offerings.

== Object storage connectors

Trino accesses files directly on object storage and remote file system storage. The following connectors use this direct approach to read and write data files.

- #link(label("doc-connector-delta-lake"))[Delta Lake connector]
- #link(label("doc-connector-hive"))[Hive connector]
- #link(label("doc-connector-hudi"))[Hudi connector]
- #link(label("doc-connector-iceberg"))[Iceberg connector]

The connectors all support a variety of protocols and formats used on these object storage systems, and have separate requirements for metadata availability.

#anchor("ref-file-system-configuration")

== Configuration

By default, no file system support is activated for your catalog. You must select and configure one of the following properties to determine the support for different file systems in the catalog. Each catalog can only use one file system support.

#list-table((
  ([Property], [Description],),
  ([#raw("fs.azure.enabled")], [Activate the #link(label("doc-object-storage-file-system-azure"))[native implementation for Azure Storage support]. Defaults to #raw("false").],),
  ([#raw("fs.gcs.enabled")], [Activate the #link(label("doc-object-storage-file-system-gcs"))[native implementation for Google Cloud Storage support]. Defaults to #raw("false").],),
  ([#raw("fs.s3.enabled")], [Activate the #link(label("doc-object-storage-file-system-s3"))[native implementation for S3 storage support]. Defaults to #raw("false").],),
  ([#raw("fs.hadoop.enabled")], [Activate #link(label("doc-object-storage-file-system-hdfs"))[support for HDFS] using the HDFS libraries. Defaults to #raw("false").],)
), header-rows: 1, title: "File system support properties")

#anchor("ref-file-system-native")

== Native file system support

Trino includes optimized implementations to access the following systems, and compatible replacements:

- #link(label("doc-object-storage-file-system-azure"))[Azure Storage file system support]
- #link(label("doc-object-storage-file-system-gcs"))[Google Cloud Storage file system support]
- #link(label("doc-object-storage-file-system-s3"))[S3 file system support]
- #link(label("doc-object-storage-file-system-local"))[Local file system support]

The native support is available in all four connectors, and must be activated for use.

#anchor("ref-file-system-legacy")

== Legacy file system support

The HDFS libraries are used for accessing the Hadoop Distributed File System \(HDFS\):

- #link(label("doc-object-storage-file-system-hdfs"))[HDFS file system support]

Legacy object storage support through #raw("fs.hadoop.enabled") and deprecated #raw("hive.*") properties is no longer available. Use the native implementations for Azure Storage, Google Cloud Storage, and S3. If you are migrating older catalog configurations, refer to the following guides:

- #link(label("ref-fs-legacy-azure-migration"))[Azure Storage migration from hive.azure.\* properties]
- #link(label("ref-fs-legacy-gcs-migration"))[Google Cloud Storage migration from hive.gcs.\* properties]
- #link(label("ref-fs-legacy-s3-migration"))[S3 migration from hive.s3.\* properties]

#anchor("ref-object-storage-other")

== Other object storage support

Trino also provides the following additional support and features for object storage:

- #link(label("doc-object-storage-file-system-cache"))[File system cache]
- #link(label("doc-object-storage-metastores"))[Metastores]
- #link(label("doc-object-storage-file-formats"))[Object storage file formats]

- \/object-storage\/file-system-azure
- \/object-storage\/file-system-gcs
- \/object-storage\/file-system-s3
- \/object-storage\/file-system-local
- \/object-storage\/file-system-hdfs
- \/object-storage\/file-system-alluxio
- \/object-storage\/file-system-cache
- \/object-storage\/metastores
- \/object-storage\/file-formats
