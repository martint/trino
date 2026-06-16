#import "/lib/trino-docs.typ": *

#anchor("doc-release-release-458")
= Release 458 \(17 Sep 2024\)

== General

- Improve performance for queries with a redundant #raw("DISTINCT") clause. \(#issue("23087", "https://github.com/trinodb/trino/issues/23087")\)

== JDBC

- Add support for tracing with OpenTelemetry. \(#issue("23458", "https://github.com/trinodb/trino/issues/23458")\)
- Remove publishing a JDBC driver JAR without bundled, third-party dependencies. \(#issue("23452", "https://github.com/trinodb/trino/issues/23452")\)

== Druid connector

- Reduce data transfer from remote systems for queries with large #raw("IN") lists. \(#issue("23381", "https://github.com/trinodb/trino/issues/23381")\)

== Delta Lake connector

- #breaking-marker("../release.html#breaking-changes") Deactivate #link(label("ref-file-system-legacy"))[legacy file system support] for all catalogs. You must activate the desired #link(label("ref-file-system-configuration"))[file system support] with #raw("fs.native-azure.enabled"),#raw("fs.native-gcs.enabled"), #raw("fs.native-s3.enabled"), or #raw("fs.hadoop.enabled") in each catalog. Use the migration guides for #link(label("ref-fs-legacy-azure-migration"))[Azure Storage], #link(label("ref-fs-legacy-gcs-migration"))[Google Cloud Storage], and #link(label("ref-fs-legacy-s3-migration"))[S3] to assist if you have not switched from legacy support. \(#issue("23343", "https://github.com/trinodb/trino/issues/23343")\)
- Add JMX monitoring to the #link(label("doc-object-storage-file-system-s3"))[S3 file system support]. \(#issue("23177", "https://github.com/trinodb/trino/issues/23177")\)
- Reduce the number of file system operations when reading from Delta Lake tables. \(#issue("23329", "https://github.com/trinodb/trino/issues/23329")\)
- Fix rare, long planning times when Hive metastore caching is enabled. \(#issue("23401", "https://github.com/trinodb/trino/issues/23401")\)

== Exasol connector

- Reduce data transfer from remote systems for queries with large #raw("IN") lists. \(#issue("23381", "https://github.com/trinodb/trino/issues/23381")\)

== Hive connector

- #breaking-marker("../release.html#breaking-changes") Deactivate #link(label("ref-file-system-legacy"))[legacy file system support] for all catalogs. You must activate the desired #link(label("ref-file-system-configuration"))[file system support] with #raw("fs.native-azure.enabled"),#raw("fs.native-gcs.enabled"), #raw("fs.native-s3.enabled"), or #raw("fs.hadoop.enabled") in each catalog. Use the migration guides for #link(label("ref-fs-legacy-azure-migration"))[Azure Storage], #link(label("ref-fs-legacy-gcs-migration"))[Google Cloud Storage], and #link(label("ref-fs-legacy-s3-migration"))[S3] to assist if you have not switched from legacy support. \(#issue("23343", "https://github.com/trinodb/trino/issues/23343")\)
- Add JMX monitoring to the native S3 file system support. \(#issue("23177", "https://github.com/trinodb/trino/issues/23177")\)
- Reduce the number of file system operations when reading tables with file system caching enabled. \(#issue("23327", "https://github.com/trinodb/trino/issues/23327")\)
- Improve the #raw("flush_metadata_cache") procedure to include flushing the file status cache. \(#issue("22412", "https://github.com/trinodb/trino/issues/22412")\)
- Fix listing failure when Glue contains Hive unsupported tables. \(#issue("23253", "https://github.com/trinodb/trino/issues/23253")\)
- Fix rare, long planning times when Hive metastore caching is enabled. \(#issue("23401", "https://github.com/trinodb/trino/issues/23401")\)

== Hudi connector

- #breaking-marker("../release.html#breaking-changes") Deactivate #link(label("ref-file-system-legacy"))[legacy file system support] for all catalogs. You must activate the desired #link(label("ref-file-system-configuration"))[file system support] with #raw("fs.native-azure.enabled"),#raw("fs.native-gcs.enabled"), #raw("fs.native-s3.enabled"), or #raw("fs.hadoop.enabled") in each catalog. Use the migration guides for #link(label("ref-fs-legacy-azure-migration"))[Azure Storage], #link(label("ref-fs-legacy-gcs-migration"))[Google Cloud Storage], and #link(label("ref-fs-legacy-s3-migration"))[S3] to assist if you have not switched from legacy support. \(#issue("23343", "https://github.com/trinodb/trino/issues/23343")\)
- Add JMX monitoring to the native S3 file system support. \(#issue("23177", "https://github.com/trinodb/trino/issues/23177")\)
- Fix rare, long planning times when Hive metastore caching is enabled. \(#issue("23401", "https://github.com/trinodb/trino/issues/23401")\)

== Iceberg connector

- #breaking-marker("../release.html#breaking-changes") Deactivate #link(label("ref-file-system-legacy"))[legacy file system support] for all catalogs. You must activate the desired #link(label("ref-file-system-configuration"))[file system support] with #raw("fs.native-azure.enabled"),#raw("fs.native-gcs.enabled"), #raw("fs.native-s3.enabled"), or #raw("fs.hadoop.enabled") in each catalog. Use the migration guides for #link(label("ref-fs-legacy-azure-migration"))[Azure Storage], #link(label("ref-fs-legacy-gcs-migration"))[Google Cloud Storage], and #link(label("ref-fs-legacy-s3-migration"))[S3] to assist if you have not switched from legacy support. \(#issue("23343", "https://github.com/trinodb/trino/issues/23343")\)
- Add JMX monitoring to the native S3 file system support. \(#issue("23177", "https://github.com/trinodb/trino/issues/23177")\)
- Fix rare, long planning times when Hive metastore caching is enabled. \(#issue("23401", "https://github.com/trinodb/trino/issues/23401")\)

== MariaDB connector

- Reduce data transfer from remote systems for queries with large #raw("IN") lists. \(#issue("23381", "https://github.com/trinodb/trino/issues/23381")\)

== MySQL connector

- Reduce data transfer from remote systems for queries with large #raw("IN") lists. \(#issue("23381", "https://github.com/trinodb/trino/issues/23381")\)

== Oracle connector

- Reduce data transfer from remote systems for queries with large #raw("IN") lists. \(#issue("23381", "https://github.com/trinodb/trino/issues/23381")\)

== PostgreSQL connector

- Reduce data transfer from remote systems for queries with large #raw("IN") lists. \(#issue("23381", "https://github.com/trinodb/trino/issues/23381")\)

== Redshift connector

- Reduce data transfer from remote systems for queries with large #raw("IN") lists. \(#issue("23381", "https://github.com/trinodb/trino/issues/23381")\)

== SingleStore connector

- Reduce data transfer from remote systems for queries with large #raw("IN") lists. \(#issue("23381", "https://github.com/trinodb/trino/issues/23381")\)

== Snowflake connector

- Reduce data transfer from remote systems for queries with large #raw("IN") lists. \(#issue("23381", "https://github.com/trinodb/trino/issues/23381")\)

== SQL Server connector

- Reduce data transfer from remote systems for queries with large #raw("IN") lists. \(#issue("23381", "https://github.com/trinodb/trino/issues/23381")\)

== SPI

- Add #raw("@Constraint") annotation for functions. \(#issue("23449", "https://github.com/trinodb/trino/issues/23449")\)
- Remove the deprecated constructor from the #raw("ConnectorTableLayout") class. \(#issue("23395", "https://github.com/trinodb/trino/issues/23395")\)
