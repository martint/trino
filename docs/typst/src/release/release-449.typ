#import "/lib/trino-docs.typ": *

#anchor("doc-release-release-449")
= Release 449 \(31 May 2024\)

== General

- Add #link(label("doc-admin-event-listeners-openlineage"))[OpenLineage event listener]. \(#issue("21265", "https://github.com/trinodb/trino/issues/21265")\)
- Fix rare query failure or incorrect results for array types when the data is dictionary encoded. \(#issue("21911", "https://github.com/trinodb/trino/issues/21911")\)
- Fix JMX metrics not exporting for resource groups. \(#issue("21343", "https://github.com/trinodb/trino/issues/21343")\)

== BigQuery connector

- Improve performance when listing schemas while the #raw("bigquery.case-insensitive-name-matching") configuration property is enabled. \(#issue("22033", "https://github.com/trinodb/trino/issues/22033")\)

== ClickHouse connector

- Add support for pushing down execution of the #raw("count(distinct)"), #raw("corr"), #raw("covar_samp"), and #raw("covar_pop") functions to the underlying database. \(#issue("7100", "https://github.com/trinodb/trino/issues/7100")\)
- Improve performance when pushing down equality predicates on textual types. \(#issue("7100", "https://github.com/trinodb/trino/issues/7100")\)

== Delta Lake connector

- Add support for #link(label("ref-delta-lake-partitions-table"))[the #raw("$partitions") system table]. \(#issue("18590", "https://github.com/trinodb/trino/issues/18590")\)
- Add support for reading from and writing to tables with #link("https://github.com/delta-io/delta/blob/master/PROTOCOL.md#vacuum-protocol-check")[VACUUM Protocol Check]. \(#issue("21398", "https://github.com/trinodb/trino/issues/21398")\)
- Add support for configuring the request retry policy on the native S3 filesystem with the #raw("s3.retry-mode") and #raw("s3.max-error-retries") configuration properties. \(#issue("21900", "https://github.com/trinodb/trino/issues/21900")\)
- Automatically use #raw("timestamp(6)") in struct types as a type during table creation when #raw("timestamp") is specified. \(#issue("21511", "https://github.com/trinodb/trino/issues/21511")\)
- Improve performance of writing data files. \(#issue("22089", "https://github.com/trinodb/trino/issues/22089")\)
- Fix query failure when the #raw("hive.metastore.glue.catalogid") configuration property is set. \(#issue("22048", "https://github.com/trinodb/trino/issues/22048")\)

== Hive connector

- Add support for specifying a catalog name in the Thrift metastore with the #raw("hive.metastore.thrift.catalog-name") configuration property. \(#issue("10287", "https://github.com/trinodb/trino/issues/10287")\)
- Add support for configuring the request retry policy on the native S3 filesystem with the #raw("s3.retry-mode") and #raw("s3.max-error-retries") configuration properties. \(#issue("21900", "https://github.com/trinodb/trino/issues/21900")\)
- Improve performance of writing to Parquet files. \(#issue("22089", "https://github.com/trinodb/trino/issues/22089")\)
- Allow usage of filesystem caching on the Trino coordinator when #raw("node-scheduler.include-coordinator") is enabled. \(#issue("21987", "https://github.com/trinodb/trino/issues/21987")\)
- Fix failure when listing Hive tables with unsupported syntax. \(#issue("21981", "https://github.com/trinodb/trino/issues/21981")\)
- Fix query failure when the #raw("hive.metastore.glue.catalogid") configuration property is set. \(#issue("22048", "https://github.com/trinodb/trino/issues/22048")\)
- Fix failure when running the #raw("flush_metadata_cache") table procedure with the Glue v2 metastore. \(#issue("22075", "https://github.com/trinodb/trino/issues/22075")\)

== Hudi connector

- Add support for configuring the request retry policy on the native S3 filesystem with the #raw("s3.retry-mode") and #raw("s3.max-error-retries") configuration properties. \(#issue("21900", "https://github.com/trinodb/trino/issues/21900")\)

== Iceberg connector

- Add support for views when using the Iceberg REST catalog. \(#issue("19818", "https://github.com/trinodb/trino/issues/19818")\)
- Add support for configuring the request retry policy on the native S3 filesystem with the #raw("s3.retry-mode") and #raw("s3.max-error-retries") configuration properties. \(#issue("21900", "https://github.com/trinodb/trino/issues/21900")\)
- Automatically use #raw("varchar") in struct types as a type during table creation when #raw("char") is specified. \(#issue("21511", "https://github.com/trinodb/trino/issues/21511")\)
- Automatically use microsecond precision for temporal types in struct types during table creation. \(#issue("21511", "https://github.com/trinodb/trino/issues/21511")\)
- Improve performance and memory usage when #link("https://iceberg.apache.org/spec/#equality-delete-files")[equality delete] files are used. \(#issue("18396", "https://github.com/trinodb/trino/issues/18396")\)
- Improve performance of writing to Parquet files. \(#issue("22089", "https://github.com/trinodb/trino/issues/22089")\)
- Fix failure when writing to tables with Iceberg #raw("VARBINARY") values. \(#issue("22072", "https://github.com/trinodb/trino/issues/22072")\)

== Pinot connector

- #breaking-marker("../release.html#breaking-changes") Remove support for non-gRPC clients and the #raw("pinot.grpc.enabled") and #raw("pinot.estimated-size-in-bytes-for-non-numeric-column") configuration properties. \(#issue("22213", "https://github.com/trinodb/trino/issues/22213")\)

== Snowflake connector

- Fix incorrect type mapping for numeric values. \(#issue("20977", "https://github.com/trinodb/trino/issues/20977")\)
