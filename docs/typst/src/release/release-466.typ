#import "/lib/trino-docs.typ": *

#anchor("doc-release-release-466")
= Release 466 \(27 Nov 2024\)

== General

- Add support for changing the type of row fields when they are in a columns of type #raw("map"). \(#issue("24248", "https://github.com/trinodb/trino/issues/24248")\)
- Remove the requirement for a Python runtime on Trino cluster nodes. \(#issue("24271", "https://github.com/trinodb/trino/issues/24271")\)
- Improve performance of queries involving #raw("GROUP BY") and joins. \(#issue("23812", "https://github.com/trinodb/trino/issues/23812")\)
- Improve client protocol throughput by introducing the #link(label("ref-protocol-spooling"))[spooling protocol]. \(#issue("24214", "https://github.com/trinodb/trino/issues/24214")\)

== Security

- Add support for #link(label("doc-security-ranger-access-control"))[data access control with Apache Ranger], including support for column masking, row filtering, and audit logging. \(#issue("22675", "https://github.com/trinodb/trino/issues/22675")\)

== JDBC driver

- Improve throughput by automatically using the #link(label("ref-jdbc-spooling-protocol"))[spooling protocol] when it is configured on the Trino cluster, and add the parameter #raw("encoding") to optionally set the preferred encoding from the JDBC driver. \(#issue("24214", "https://github.com/trinodb/trino/issues/24214")\)
- Improve decompression performance when running the client with Java 22 or newer. \(#issue("24263", "https://github.com/trinodb/trino/issues/24263")\)
- Improve performance #raw("java.sql.DatabaseMetaData.getTables()"). \(#issue("24159", "https://github.com/trinodb/trino/issues/24159"), #issue("24110", "https://github.com/trinodb/trino/issues/24110")\)

== Server RPM

- Remove Python requirement. \(#issue("24271", "https://github.com/trinodb/trino/issues/24271")\)

== Docker image

- Remove Python runtime and libraries. \(#issue("24271", "https://github.com/trinodb/trino/issues/24271")\)

== CLI

- Improve throughput by automatically use the #link(label("ref-cli-spooling-protocol"))[spooling protocol] when it is configured on the Trino cluster, and add the option #raw("--encoding") to optionally set the preferred encoding from the CLI. \(#issue("24214", "https://github.com/trinodb/trino/issues/24214")\)
- Improve decompression performance when running the CLI with Java 22 or newer. \(#issue("24263", "https://github.com/trinodb/trino/issues/24263")\)

== BigQuery connector

- Add support for #raw("LIMIT") pushdown. \(#issue("23937", "https://github.com/trinodb/trino/issues/23937")\)

== Iceberg connector

- Add support for the #link("https://iceberg.apache.org/docs/latest/aws/#object-store-file-layout")[object store file layout]. \(#issue("8861", "https://github.com/trinodb/trino/issues/8861")\)
- Add support for changing field types inside a map. \(#issue("24248", "https://github.com/trinodb/trino/issues/24248")\)
- Improve performance of queries with selective joins. \(#issue("24277", "https://github.com/trinodb/trino/issues/24277")\)
- Fix failure when reading columns containing nested row types that differ from the schema of the underlying Parquet data. \(#issue("22922", "https://github.com/trinodb/trino/issues/22922")\)

== Phoenix connector

- Improve performance for #raw("MERGE") statements. \(#issue("24075", "https://github.com/trinodb/trino/issues/24075")\)

== SQL Server connector

- Rename the #raw("sqlserver.experimental.stored-procedure-table-function-enabled") configuration property to #raw("sqlserver.stored-procedure-table-function-enabled"). \(#issue("24239", "https://github.com/trinodb/trino/issues/24239")\)

== SPI

- Add #raw("ConnectorSplit") argument to the #raw("SystemTable.cursor()") method. \(#issue("24159", "https://github.com/trinodb/trino/issues/24159")\)
- Add support for partial row updates to the #raw("ConnectorMetadata.beginMerge()") method. \(#issue("24075", "https://github.com/trinodb/trino/issues/24075")\)
