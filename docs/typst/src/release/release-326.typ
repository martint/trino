#import "/lib/trino-docs.typ": *

#anchor("doc-release-release-326")
= Release 326 \(27 Nov 2019\)

== General

- Fix incorrect query results when query contains #raw("LEFT JOIN") over #raw("UNNEST"). \(#issue("2097", "https://github.com/trinodb/trino/issues/2097")\)
- Fix performance regression in queries involving #raw("JOIN"). \(#issue("2047", "https://github.com/trinodb/trino/issues/2047")\)
- Fix accounting of semantic analysis time when queued queries are cancelled. \(#issue("2055", "https://github.com/trinodb/trino/issues/2055")\)
- Add #link(label("doc-connector-singlestore"))[SingleStore connector]. \(#issue("1906", "https://github.com/trinodb/trino/issues/1906")\)
- Improve performance of #raw("INSERT") and #raw("CREATE TABLE ... AS") queries containing redundant #raw("ORDER BY") clauses. \(#issue("2044", "https://github.com/trinodb/trino/issues/2044")\)
- Improve performance when processing columns of #raw("map") type. \(#issue("2015", "https://github.com/trinodb/trino/issues/2015")\)

== Server RPM

- Allow running Presto with #link(label("ref-requirements-java"))[Java 11 or above]. \(#issue("2057", "https://github.com/trinodb/trino/issues/2057")\)

== Security

- Deprecate Kerberos in favor of JWT for #link(label("doc-security-internal-communication"))[Secure internal communication]. \(#issue("2032", "https://github.com/trinodb/trino/issues/2032")\)

== Hive

- Fix table creation error for tables with S3 location when using #raw("file") metastore. \(#issue("1664", "https://github.com/trinodb/trino/issues/1664")\)
- Fix a compatibility issue with the CDH 5.x metastore which results in stats not being recorded for #link(label("doc-sql-analyze"))[ANALYZE]. \(#issue("973", "https://github.com/trinodb/trino/issues/973")\)
- Improve performance for Glue metastore by fetching partitions in parallel. \(#issue("1465", "https://github.com/trinodb/trino/issues/1465")\)
- Improve performance of #raw("sql-standard") security. \(#issue("1922", "https://github.com/trinodb/trino/issues/1922"), #issue("1929", "https://github.com/trinodb/trino/issues/1929")\)

== Phoenix connector

- Collect statistics on the count and duration of each call to Phoenix. \(#issue("2024", "https://github.com/trinodb/trino/issues/2024")\)

== Other connectors

These changes apply to the MySQL, PostgreSQL, Redshift, and SQL Server connectors.

- Collect statistics on the count and duration of operations to create and destroy #raw("JDBC") connections. \(#issue("2024", "https://github.com/trinodb/trino/issues/2024")\)
- Add support for showing column comments. \(#issue("1840", "https://github.com/trinodb/trino/issues/1840")\)
