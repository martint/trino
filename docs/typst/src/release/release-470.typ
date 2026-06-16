#import "/lib/trino-docs.typ": *

#anchor("doc-release-release-470")
= Release 470 \(5 Feb 2025\)

== General

- Add #link(label("doc-connector-duckdb"))[DuckDB connector]. \(#issue("18031", "https://github.com/trinodb/trino/issues/18031")\)
- Add #link(label("doc-connector-loki"))[Loki connector]. \(#issue("23053", "https://github.com/trinodb/trino/issues/23053")\)
- Add support for the #link(label("ref-select-with-session"))[SELECT] to set per-query session properties with #raw("SELECT") queries. \(#issue("24889", "https://github.com/trinodb/trino/issues/24889")\)
- Improve compatibility of fault-tolerant exchange storage with S3-compliant object stores. \(#issue("24822", "https://github.com/trinodb/trino/issues/24822")\)
- Allow skipping directory schema validation to improve compatibility of fault-tolerant exchange storage with HDFS-like file systems. This can be configured with the #raw("exchange.hdfs.skip-directory-scheme-validation") property. \(#issue("24627", "https://github.com/trinodb/trino/issues/24627")\)
- Export JMX metric for #raw("blockedQueries"). \(#issue("24907", "https://github.com/trinodb/trino/issues/24907")\)
- #breaking-marker("../release.html#breaking-changes") Remove support for the #raw("optimize_hash_generation") session property and the #raw("optimizer.optimize-hash-generation") configuration option. \(#issue("24792", "https://github.com/trinodb/trino/issues/24792")\)
- Fix failure when using upper-case variable names in SQL user-defined functions. \(#issue("24460", "https://github.com/trinodb/trino/issues/24460")\)
- Prevent failures of the #link(label("fn-array-histogram"), raw("array_histogram")) function when the input contains null values. \(#issue("24765", "https://github.com/trinodb/trino/issues/24765")\)

== JDBC driver

- #breaking-marker("../release.html#breaking-changes") Raise minimum runtime requirement to Java 11. \(#issue("23639", "https://github.com/trinodb/trino/issues/23639")\)

== CLI

- #breaking-marker("../release.html#breaking-changes") Raise minimum runtime requirement to Java 11. \(#issue("23639", "https://github.com/trinodb/trino/issues/23639")\)

== Delta Lake connector

- Prevent connection leakage when using the Azure Storage file system. \(#issue("24116", "https://github.com/trinodb/trino/issues/24116")\)
- Deprecate use of the legacy file system support for Azure Storage, Google Cloud Storage, IBM Cloud Object Storage, S3 and S3-compatible object storage systems. Use the migration guides for #link(label("ref-fs-legacy-azure-migration"))[Azure Storage], #link(label("ref-fs-legacy-gcs-migration"))[Google Cloud Storage], and #link(label("ref-fs-legacy-s3-migration"))[S3] to assist if you have not switched from legacy support. \(#issue("24878", "https://github.com/trinodb/trino/issues/24878")\)
- Fix potential table corruption when using the #raw("vacuum") procedure. \(#issue("24872", "https://github.com/trinodb/trino/issues/24872")\)

== Faker connector

- #link(label("ref-faker-statistics"))[Derive constraints] from source data when using #raw("CREATE TABLE ... AS SELECT"). \(#issue("24585", "https://github.com/trinodb/trino/issues/24585")\)

== Hive connector

- Deprecate use of the legacy file system support for Azure Storage, Google Cloud Storage, IBM Cloud Object Storage, S3 and S3-compatible object storage systems. Use the migration guides for #link(label("ref-fs-legacy-azure-migration"))[Azure Storage], #link(label("ref-fs-legacy-gcs-migration"))[Google Cloud Storage], and #link(label("ref-fs-legacy-s3-migration"))[S3] to assist if you have not switched from legacy support. \(#issue("24878", "https://github.com/trinodb/trino/issues/24878")\)
- Prevent connection leakage when using the Azure Storage file system. \(#issue("24116", "https://github.com/trinodb/trino/issues/24116")\)
- Fix NullPointerException when listing tables on Glue. \(#issue("24834", "https://github.com/trinodb/trino/issues/24834")\)

== Hudi connector

- Deprecate use of the legacy file system support for Azure Storage, Google Cloud Storage, IBM Cloud Object Storage, S3 and S3-compatible object storage systems. Use the migration guides for #link(label("ref-fs-legacy-azure-migration"))[Azure Storage], #link(label("ref-fs-legacy-gcs-migration"))[Google Cloud Storage], and #link(label("ref-fs-legacy-s3-migration"))[S3] to assist if you have not switched from legacy support. \(#issue("24878", "https://github.com/trinodb/trino/issues/24878")\)
- Prevent connection leakage when using the Azure Storage file system. \(#issue("24116", "https://github.com/trinodb/trino/issues/24116")\)

== Iceberg connector

- Add the #link(label("ref-iceberg-optimize-manifests"))[optimize\_manifests] table procedure. \(#issue("14821", "https://github.com/trinodb/trino/issues/14821")\)
- Allow configuration of the number of commit retries with the #raw("max_commit_retry") table property. \(#issue("22672", "https://github.com/trinodb/trino/issues/22672")\)
- Allow caching of table metadata when using the Hive metastore. \(#issue("13115", "https://github.com/trinodb/trino/issues/13115")\)
- Deprecate use of the legacy file system support for Azure Storage, Google Cloud Storage, IBM Cloud Object Storage, S3 and S3-compatible object storage systems. Use the migration guides for #link(label("ref-fs-legacy-azure-migration"))[Azure Storage], #link(label("ref-fs-legacy-gcs-migration"))[Google Cloud Storage], and #link(label("ref-fs-legacy-s3-migration"))[S3] to assist if you have not switched from legacy support. \(#issue("24878", "https://github.com/trinodb/trino/issues/24878")\)
- Prevent connection leakage when using the Azure Storage file system. \(#issue("24116", "https://github.com/trinodb/trino/issues/24116")\)
- Fix failure when adding a new column with a name containing a dot. \(#issue("24813", "https://github.com/trinodb/trino/issues/24813")\)
- Fix failure when reading from tables with #link("https://iceberg.apache.org/spec/#equality-delete-files")[equality deletes] with nested fields. \(#issue("18625", "https://github.com/trinodb/trino/issues/18625")\)
- Fix failure when reading #raw("$entries") and #raw("$all_entries") tables using #link("https://iceberg.apache.org/spec/#equality-delete-files")[equality deletes]. \(#issue("24775", "https://github.com/trinodb/trino/issues/24775")\)

== JMX connector

- Prevent missing metrics values when MBeans in coordinator and workers do not match. \(#issue("24908", "https://github.com/trinodb/trino/issues/24908")\)

== Kinesis connector

- #breaking-marker("../release.html#breaking-changes") Remove the Kinesis connector. \(#issue("23923", "https://github.com/trinodb/trino/issues/23923")\)

== MySQL connector

- Add support for #raw("MERGE") statement. \(#issue("24428", "https://github.com/trinodb/trino/issues/24428")\)
- Prevent writing of invalid, negative date values. \(#issue("24809", "https://github.com/trinodb/trino/issues/24809")\)

== PostgreSQL connector

- Raise minimum required version to PostgreSQL 12. \(#issue("24836", "https://github.com/trinodb/trino/issues/24836")\)
