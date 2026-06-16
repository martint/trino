#import "/lib/trino-docs.typ": *

#anchor("doc-release-release-420")
= Release 420 \(22 Jun 2023\)

== General

- Add support for the #link(label("fn-any-value"), raw("any_value")) aggregation function. \(#issue("17777", "https://github.com/trinodb/trino/issues/17777")\)
- Add support for underscores in numeric literals. \(#issue("17776", "https://github.com/trinodb/trino/issues/17776")\)
- Add support for hexadecimal, binary, and octal numeric literals. \(#issue("17776", "https://github.com/trinodb/trino/issues/17776")\)
- Deprecate the #raw("dynamic-filtering.small-broadcast.*") and #raw("dynamic-filtering.large-broadcast.*") configuration properties in favor of #raw("dynamic-filtering.small.*") and #raw("dynamic-filtering.large.*"). \(#issue("17831", "https://github.com/trinodb/trino/issues/17831")\)

== Security

- Add support for configuring authorization rules for #raw("ALTER ... SET AUTHORIZATION...") statements in file-based access control. \(#issue("16691", "https://github.com/trinodb/trino/issues/16691")\)
- Remove the deprecated #raw("legacy.allow-set-view-authorization") configuration property. \(#issue("16691", "https://github.com/trinodb/trino/issues/16691")\)

== BigQuery connector

- Fix direct download of access tokens, and correctly use the proxy when it is enabled with the #raw("bigquery.rpc-proxy.enabled") configuration property. \(#issue("17783", "https://github.com/trinodb/trino/issues/17783")\)

== Delta Lake connector

- Add support for #link(label("doc-sql-comment"))[comments] on view columns. \(#issue("17773", "https://github.com/trinodb/trino/issues/17773")\)
- Add support for recalculating all statistics with an #raw("ANALYZE") statement. \(#issue("15968", "https://github.com/trinodb/trino/issues/15968")\)
- Disallow using the root directory of a bucket \(#raw("scheme://authority")\) as a table location without a trailing slash in the location name. \(#issue("17921", "https://github.com/trinodb/trino/issues/17921")\)
- Fix Parquet writer incompatibility with Apache Spark and Databricks Runtime. \(#issue("17978", "https://github.com/trinodb/trino/issues/17978")\)

== Druid connector

- Add support for tables with uppercase characters in their names. \(#issue("7197", "https://github.com/trinodb/trino/issues/7197")\)

== Hive connector

- Add a native Avro file format reader. This can be disabled with the #raw("avro.native-reader.enabled") configuration property or the #raw("avro_native_reader_enabled") session property. \(#issue("17221", "https://github.com/trinodb/trino/issues/17221")\)
- Require admin role privileges to perform #raw("ALTER ... SET AUTHORIZATION...") statements when the #raw("hive-security") configuration property is set to #raw("sql-standard"). \(#issue("16691", "https://github.com/trinodb/trino/issues/16691")\)
- Improve query performance on partitioned Hive tables when table statistics are not available. \(#issue("17677", "https://github.com/trinodb/trino/issues/17677")\)
- Disallow using the root directory of a bucket \(#raw("scheme://authority")\) as a table location without a trailing slash in the location name. \(#issue("17921", "https://github.com/trinodb/trino/issues/17921")\)
- Fix Parquet writer incompatibility with Apache Spark and Databricks Runtime. \(#issue("17978", "https://github.com/trinodb/trino/issues/17978")\)
- Fix reading from a Hive table when its location is the root directory of an S3 bucket. \(#issue("17848", "https://github.com/trinodb/trino/issues/17848")\)

== Hudi connector

- Disallow using the root directory of a bucket \(#raw("scheme://authority")\) as a table location without a trailing slash in the location name. \(#issue("17921", "https://github.com/trinodb/trino/issues/17921")\)
- Fix Parquet writer incompatibility with Apache Spark and Databricks Runtime. \(#issue("17978", "https://github.com/trinodb/trino/issues/17978")\)
- Fix failure when fetching table metadata for views. \(#issue("17901", "https://github.com/trinodb/trino/issues/17901")\)

== Iceberg connector

- Disallow using the root directory of a bucket \(#raw("scheme://authority")\) as a table location without a trailing slash in the location name. \(#issue("17921", "https://github.com/trinodb/trino/issues/17921")\)
- Fix Parquet writer incompatibility with Apache Spark and Databricks Runtime. \(#issue("17978", "https://github.com/trinodb/trino/issues/17978")\)
- Fix scheduling failure when dynamic filtering is enabled. \(#issue("17871", "https://github.com/trinodb/trino/issues/17871")\)

== Kafka connector

- Fix server startup failure when a Kafka catalog is present. \(#issue("17299", "https://github.com/trinodb/trino/issues/17299")\)

== MongoDB connector

- Add support for #raw("ALTER TABLE ... RENAME COLUMN"). \(#issue("17874", "https://github.com/trinodb/trino/issues/17874")\)
- Fix incorrect results when the order of the #link("https://www.mongodb.com/docs/manual/reference/database-references/#dbrefs")[dbref type] fields is different from #raw("databaseName"), #raw("collectionName"), and #raw("id"). \(#issue("17883", "https://github.com/trinodb/trino/issues/17883")\)

== SPI

- Move table function infrastructure to the #raw("io.trino.spi.function.table") package. \(#issue("17774", "https://github.com/trinodb/trino/issues/17774")\)
