#import "/lib/trino-docs.typ": *

#anchor("doc-release-release-460")
= Release 460 \(3 Oct 2024\)

== General

- Fix failure for certain queries involving lambda expressions. \(#issue("23649", "https://github.com/trinodb/trino/issues/23649")\)

== Atop connector

- #breaking-marker("../release.html#breaking-changes") Remove the Atop connector. \(#issue("23550", "https://github.com/trinodb/trino/issues/23550")\)

== ClickHouse connector

- Improve performance of listing columns. \(#issue("23429", "https://github.com/trinodb/trino/issues/23429")\)
- Improve performance for queries comparing #raw("varchar") columns. \(#issue("23558", "https://github.com/trinodb/trino/issues/23558")\)
- Improve performance for queries using #raw("varchar") columns for #raw("IN") comparisons. \(#issue("23581", "https://github.com/trinodb/trino/issues/23581")\)
- Improve performance for queries with complex expressions involving #raw("LIKE"). \(#issue("23591", "https://github.com/trinodb/trino/issues/23591")\)

== Delta Lake connector

- Add support for using an #link(label("doc-object-storage-file-system-alluxio"))[Alluxio cluster as file system cache]. \(#issue("21603", "https://github.com/trinodb/trino/issues/21603")\)
- Add support for WASBS to #link(label("doc-object-storage-file-system-azure"))[Azure Storage file system support]. \(#issue("23548", "https://github.com/trinodb/trino/issues/23548")\)
- Disallow writing to tables that both change data feed and #link("https://docs.delta.io/latest/delta-deletion-vectors.html")[deletion vectors] are enabled. \(#issue("23653", "https://github.com/trinodb/trino/issues/23653")\)
- Fix query failures when writing bloom filters in Parquet files. \(#issue("22701", "https://github.com/trinodb/trino/issues/22701")\)

== Hive connector

- Add support for using an #link(label("doc-object-storage-file-system-alluxio"))[Alluxio cluster as file system cache]. \(#issue("21603", "https://github.com/trinodb/trino/issues/21603")\)
- Add support for WASBS to #link(label("doc-object-storage-file-system-azure"))[Azure Storage file system support]. \(#issue("23548", "https://github.com/trinodb/trino/issues/23548")\)
- Fix query failures when writing bloom filters in Parquet files. \(#issue("22701", "https://github.com/trinodb/trino/issues/22701")\)

== Hudi connector

- Add support for WASBS to #link(label("doc-object-storage-file-system-azure"))[Azure Storage file system support]. \(#issue("23548", "https://github.com/trinodb/trino/issues/23548")\)

== Iceberg connector

- Add support for using an #link(label("doc-object-storage-file-system-alluxio"))[Alluxio cluster as file system cache]. \(#issue("21603", "https://github.com/trinodb/trino/issues/21603")\)
- Add support for WASBS to #link(label("doc-object-storage-file-system-azure"))[Azure Storage file system support]. \(#issue("23548", "https://github.com/trinodb/trino/issues/23548")\)
- Ensure table columns are cached in Glue even when table comment is too long. \(#issue("23483", "https://github.com/trinodb/trino/issues/23483")\)
- Reduce planning time for queries on columns containing a large number of nested fields. \(#issue("23451", "https://github.com/trinodb/trino/issues/23451")\)
- Fix query failures when writing bloom filters in Parquet files. \(#issue("22701", "https://github.com/trinodb/trino/issues/22701")\)

== Oracle connector

- Improve performance for queries casting columns to #raw("char") or to #raw("varchar"). \(#issue("22728", "https://github.com/trinodb/trino/issues/22728")\)

== Raptor connector

- #breaking-marker("../release.html#breaking-changes") Remove the Raptor connector. \(#issue("23588", "https://github.com/trinodb/trino/issues/23588")\)

== SQL Server connector

- Improve performance of listing columns. \(#issue("23429", "https://github.com/trinodb/trino/issues/23429")\)
