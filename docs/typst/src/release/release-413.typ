#import "/lib/trino-docs.typ": *

#anchor("doc-release-release-413")
= Release 413 \(12 Apr 2023\)

== General

- Improve performance of queries involving window operations or #link(label("doc-sql-pattern-recognition-in-window"))[row pattern recognition] on small partitions. \(#issue("16748", "https://github.com/trinodb/trino/issues/16748")\)
- Improve performance of queries with the #link(label("fn-row-number"), raw("row_number")) and #link(label("fn-rank"), raw("rank")) window functions. \(#issue("16753", "https://github.com/trinodb/trino/issues/16753")\)
- Fix potential failure when cancelling a query. \(#issue("16960", "https://github.com/trinodb/trino/issues/16960")\)

== Delta Lake connector

- Add support for nested #raw("timestamp with time zone") values in #link(label("ref-structural-data-types"))[structural data types]. \(#issue("16826", "https://github.com/trinodb/trino/issues/16826")\)
- Disallow using #raw("_change_type"), #raw("_commit_version"), and #raw("_commit_timestamp") as column names when creating a table or adding a column with #link("https://docs.delta.io/2.0.0/delta-change-data-feed.html")[change data feed]. \(#issue("16913", "https://github.com/trinodb/trino/issues/16913")\)
- Disallow enabling change data feed when the table contains #raw("_change_type"), #raw("_commit_version") and #raw("_commit_timestamp") columns. \(#issue("16913", "https://github.com/trinodb/trino/issues/16913")\)
- Fix incorrect results when reading #raw("INT32") values without a decimal logical annotation in Parquet files. \(#issue("16938", "https://github.com/trinodb/trino/issues/16938")\)

== Hive connector

- Fix incorrect results when reading #raw("INT32") values without a decimal logical annotation in Parquet files. \(#issue("16938", "https://github.com/trinodb/trino/issues/16938")\)
- Fix incorrect results when the file path contains hidden characters. \(#issue("16386", "https://github.com/trinodb/trino/issues/16386")\)

== Hudi connector

- Fix incorrect results when reading #raw("INT32") values without a decimal logical annotation in Parquet files. \(#issue("16938", "https://github.com/trinodb/trino/issues/16938")\)

== Iceberg connector

- Fix incorrect results when reading #raw("INT32") values without a decimal logical annotation in Parquet files. \(#issue("16938", "https://github.com/trinodb/trino/issues/16938")\)
- Fix failure when creating a schema with a username containing uppercase characters in the Iceberg Glue catalog. \(#issue("16116", "https://github.com/trinodb/trino/issues/16116")\)

== Oracle connector

- Add support for #link(label("doc-sql-comment"))[table comments] and creating tables with comments. \(#issue("16898", "https://github.com/trinodb/trino/issues/16898")\)

== Phoenix connector

- Add support for #link(label("doc-sql-merge"))[MERGE]. \(#issue("16661", "https://github.com/trinodb/trino/issues/16661")\)

== SPI

- Deprecate the #raw("getSchemaProperties()") and #raw("getSchemaOwner()") methods in #raw("ConnectorMetadata") in favor of versions that accept a #raw("String") for the schema name rather than #raw("CatalogSchemaName"). \(#issue("16862", "https://github.com/trinodb/trino/issues/16862")\)
