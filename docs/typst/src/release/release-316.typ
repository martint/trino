#import "/lib/trino-docs.typ": *

#anchor("doc-release-release-316")
= Release 316 \(8 Jul 2019\)

== General

- Fix #raw("date_format") function failure when format string contains non-ASCII characters. \(#issue("1056", "https://github.com/trinodb/trino/issues/1056")\)
- Improve performance of queries using #raw("UNNEST").  \(#issue("901", "https://github.com/trinodb/trino/issues/901")\)
- Improve error message when statement parsing fails. \(#issue("1042", "https://github.com/trinodb/trino/issues/1042")\)

== CLI

- Fix refresh of completion cache when catalog or schema is changed. \(#issue("1016", "https://github.com/trinodb/trino/issues/1016")\)
- Allow reading password from console when stdout is a pipe. \(#issue("982", "https://github.com/trinodb/trino/issues/982")\)

== Hive connector

- Acquire S3 credentials from the default AWS locations if not configured explicitly. \(#issue("741", "https://github.com/trinodb/trino/issues/741")\)
- Only allow using roles and grants with SQL standard based authorization. \(#issue("972", "https://github.com/trinodb/trino/issues/972")\)
- Add support for #raw("CSV") file format. \(#issue("920", "https://github.com/trinodb/trino/issues/920")\)
- Support reading from and writing to Hadoop encryption zones \(Hadoop KMS\). \(#issue("997", "https://github.com/trinodb/trino/issues/997")\)
- Collect column statistics on write by default. This can be disabled using the #raw("hive.collect-column-statistics-on-write") configuration property or the #raw("collect_column_statistics_on_write") session property. \(#issue("981", "https://github.com/trinodb/trino/issues/981")\)
- Eliminate unused idle threads when using the metastore cache. \(#issue("1061", "https://github.com/trinodb/trino/issues/1061")\)

== PostgreSQL connector

- Add support for columns of type #raw("UUID"). \(#issue("1011", "https://github.com/trinodb/trino/issues/1011")\)
- Export JMX statistics for various JDBC and connector operations. \(#issue("906", "https://github.com/trinodb/trino/issues/906")\).

== MySQL connector

- Export JMX statistics for various JDBC and connector operations. \(#issue("906", "https://github.com/trinodb/trino/issues/906")\).

== Redshift connector

- Export JMX statistics for various JDBC and connector operations. \(#issue("906", "https://github.com/trinodb/trino/issues/906")\).

== SQL Server connector

- Export JMX statistics for various JDBC and connector operations. \(#issue("906", "https://github.com/trinodb/trino/issues/906")\).

== TPC-H connector

- Fix #raw("SHOW TABLES") failure when used with a hidden schema. \(#issue("1005", "https://github.com/trinodb/trino/issues/1005")\)

== TPC-DS connector

- Fix #raw("SHOW TABLES") failure when used with a hidden schema. \(#issue("1005", "https://github.com/trinodb/trino/issues/1005")\)

== SPI

- Add support for pushing simple column and row field reference expressions into connectors via the #raw("ConnectorMetadata.applyProjection()") method. \(#issue("676", "https://github.com/trinodb/trino/issues/676")\)
