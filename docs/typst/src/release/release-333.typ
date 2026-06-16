#import "/lib/trino-docs.typ": *

#anchor("doc-release-release-333")
= Release 333 \(04 May 2020\)

== General

- Fix planning failure when lambda expressions are repeated in a query. \(#issue("3218", "https://github.com/trinodb/trino/issues/3218")\)
- Fix failure when input to #raw("TRY") is a constant #raw("NULL"). \(#issue("3408", "https://github.com/trinodb/trino/issues/3408")\)
- Fix failure for #link(label("doc-sql-show-create-table"))[SHOW CREATE TABLE] for tables with row types that contain special characters. \(#issue("3380", "https://github.com/trinodb/trino/issues/3380")\)
- Fix failure when using #link(label("fn-max-by"), raw("max_by")) or #link(label("fn-min-by"), raw("min_by")) where the second argument is of type #raw("varchar"). \(#issue("3424", "https://github.com/trinodb/trino/issues/3424")\)
- Fix rare failure due to an invalid size estimation for T-Digests. \(#issue("3625", "https://github.com/trinodb/trino/issues/3625")\)
- Do not require coordinator to have spill paths setup when spill is enabled. \(#issue("3407", "https://github.com/trinodb/trino/issues/3407")\)
- Improve performance when dynamic filtering is enabled. \(#issue("3413", "https://github.com/trinodb/trino/issues/3413")\)
- Improve performance of queries involving constant scalar subqueries \(#issue("3432", "https://github.com/trinodb/trino/issues/3432")\)
- Allow overriding the count of available workers used for query cost estimation via the #raw("cost_estimation_worker_count") session property. \(#issue("2705", "https://github.com/trinodb/trino/issues/2705")\)
- Add data integrity verification for Presto internal communication. This can be configured with the #raw("exchange.data-integrity-verification") configuration property. \(#issue("3438", "https://github.com/trinodb/trino/issues/3438")\)
- Add support for #raw("LIKE") predicate to #link(label("doc-sql-show-columns"))[SHOW COLUMNS]. \(#issue("2997", "https://github.com/trinodb/trino/issues/2997")\)
- Add #link(label("doc-sql-show-create-schema"))[SHOW CREATE SCHEMA]. \(#issue("3099", "https://github.com/trinodb/trino/issues/3099")\)
- Add #link(label("fn-starts-with"), raw("starts_with")) function. \(#issue("3392", "https://github.com/trinodb/trino/issues/3392")\)

== Server

- Require running on #link(label("ref-requirements-java"))[Java 11 or above]. \(#issue("2799", "https://github.com/trinodb/trino/issues/2799")\)

== Server RPM

- Reduce size of RPM and disk usage after installation. \(#issue("3595", "https://github.com/trinodb/trino/issues/3595")\)

== Security

- Allow configuring trust certificate for LDAP password authenticator. \(#issue("3523", "https://github.com/trinodb/trino/issues/3523")\)

== JDBC driver

- Fix hangs on JDK 8u252 when using secure connections. \(#issue("3444", "https://github.com/trinodb/trino/issues/3444")\)

== BigQuery connector

- Improve performance for queries that contain filters on table columns. \(#issue("3376", "https://github.com/trinodb/trino/issues/3376")\)
- Add support for partitioned tables. \(#issue("3376", "https://github.com/trinodb/trino/issues/3376")\)

== Cassandra connector

- Allow #link(label("doc-sql-insert"))[INSERT] statement for table having hidden #raw("id") column. \(#issue("3499", "https://github.com/trinodb/trino/issues/3499")\)
- Add support for #link(label("doc-sql-create-table"))[CREATE TABLE] statement. \(#issue("3478", "https://github.com/trinodb/trino/issues/3478")\)

== Elasticsearch connector

- Fix failure when querying Elasticsearch 7.x clusters. \(#issue("3447", "https://github.com/trinodb/trino/issues/3447")\)

== Hive connector

- Fix incorrect query results when reading Parquet data with a #raw("varchar") column predicate which is a comparison with a value containing non-ASCII characters. \(#issue("3517", "https://github.com/trinodb/trino/issues/3517")\)
- Ensure cleanup of resources \(file descriptors, sockets, temporary files, etc.\) when an error occurs while writing an ORC file. \(#issue("3390", "https://github.com/trinodb/trino/issues/3390")\)
- Generate multiple splits for files in bucketed tables. \(#issue("3455", "https://github.com/trinodb/trino/issues/3455")\)
- Make file system caching honor Hadoop properties from #raw("hive.config.resources"). \(#issue("3557", "https://github.com/trinodb/trino/issues/3557")\)
- Disallow enabling file system caching together with S3 security mapping or GCS access tokens. \(#issue("3571", "https://github.com/trinodb/trino/issues/3571")\)
- Disable file system caching parallel warmup by default. It is currently broken and should not be enabled. \(#issue("3591", "https://github.com/trinodb/trino/issues/3591")\)
- Include metrics from S3 Select in the S3 JMX metrics. \(#issue("3429", "https://github.com/trinodb/trino/issues/3429")\)
- Report timings for request retries in S3 JMX metrics. Previously, only the first request was reported. \(#issue("3429", "https://github.com/trinodb/trino/issues/3429")\)
- Add S3 JMX metric for client retry pause time \(how long the thread was asleep between request retries in the client itself\). \(#issue("3429", "https://github.com/trinodb/trino/issues/3429")\)
- Add support for #link(label("doc-sql-show-create-schema"))[SHOW CREATE SCHEMA]. \(#issue("3099", "https://github.com/trinodb/trino/issues/3099")\)
- Add #raw("hive.projection-pushdown-enabled") configuration property and #raw("projection_pushdown_enabled") session property. \(#issue("3490", "https://github.com/trinodb/trino/issues/3490")\)
- Add support for connecting to the Thrift metastore using TLS. \(#issue("3440", "https://github.com/trinodb/trino/issues/3440")\)

== MongoDB connector

- Skip unknown types in nested BSON object. \(#issue("2935", "https://github.com/trinodb/trino/issues/2935")\)
- Fix query failure when the user does not have access privileges for #raw("system.views"). \(#issue("3355", "https://github.com/trinodb/trino/issues/3355")\)

== Other connectors

These changes apply to the MemSQL, MySQL, PostgreSQL, Redshift, and SQL Server connectors.

- Export JMX statistics for various connector operations. \(#issue("3479", "https://github.com/trinodb/trino/issues/3479")\).
