#import "/lib/trino-docs.typ": *

#anchor("doc-release-release-365")
= Release 365 \(3 Dec 2021\)

== General

- Add support for #link(label("doc-sql-truncate"))[#raw("TRUNCATE TABLE")]. \(#issue("8921", "https://github.com/trinodb/trino/issues/8921")\)
- Add support for aggregate functions in row pattern recognition context. \(#issue("8738", "https://github.com/trinodb/trino/issues/8738")\)
- Add support for time travel queries. \(#issue("8773", "https://github.com/trinodb/trino/issues/8773")\)
- Add support for spilling aggregations containing #raw("ORDER BY") or #raw("DISTINCT") clauses. \(#issue("9723", "https://github.com/trinodb/trino/issues/9723")\)
- Add #link(label("ref-ip-address-contains"))[#raw("contains")] function to check whether a CIDR contains an IP address. \(#issue("9654", "https://github.com/trinodb/trino/issues/9654")\)
- Report connector metrics in #raw("EXPLAIN ANALYZE VERBOSE"). \(#issue("9858", "https://github.com/trinodb/trino/issues/9858")\)
- Report operator input row count distribution in #raw("EXPLAIN ANALYZE VERBOSE"). \(#issue("10133", "https://github.com/trinodb/trino/issues/10133")\)
- Allow executing #raw("INSERT") or #raw("DELETE") statements on tables restricted with a row filter. \(#issue("8856", "https://github.com/trinodb/trino/issues/8856")\)
- Remove #raw("owner") column from the #raw("system.metadata.materialized_views") table. \(#issue("9961", "https://github.com/trinodb/trino/issues/9961")\)
- Remove the #raw("optimizer.iterative-rule-based-column-pruning") config property. The legacy column pruning optimizer is no longer available. \(#issue("9564", "https://github.com/trinodb/trino/issues/9564")\)
- Improve performance of inequality joins. \(#issue("9307", "https://github.com/trinodb/trino/issues/9307")\)
- Improve performance of joins involving a small table on one side. \(#issue("9851", "https://github.com/trinodb/trino/issues/9851")\)
- Improve CPU utilization by adjusting #raw("task.concurrency") automatically based on the number of physical cores. \(#issue("10088", "https://github.com/trinodb/trino/issues/10088")\)
- Make query final query statistics more accurate. \(#issue("9888", "https://github.com/trinodb/trino/issues/9888"), #issue("9913", "https://github.com/trinodb/trino/issues/9913")\)
- Improve query planning performance for queries containing large #raw("IN") predicates. \(#issue("9874", "https://github.com/trinodb/trino/issues/9874")\)
- Reduce peak memory usage for queries involving the #raw("rank"), #raw("dense_rank"), or #raw("row_number") window functions. \(#issue("10056", "https://github.com/trinodb/trino/issues/10056")\)
- Fix incorrect results when casting #raw("bigint") values to #raw("varchar(n)") type. \(#issue("552", "https://github.com/trinodb/trino/issues/552")\)
- Fix query failure when the #raw("PREPARE") statement is used with #raw("DROP") or #raw("INSERT") and the table or schema name contains special characters. \(#issue("9822", "https://github.com/trinodb/trino/issues/9822")\)
- Fix minor memory leak when queries are abandoned during the initial query submission phase. \(#issue("9962", "https://github.com/trinodb/trino/issues/9962")\)
- Collect connector metrics after #raw("ConnectorPageSource") is closed. \(#issue("9615", "https://github.com/trinodb/trino/issues/9615")\)

== Security

- Allow configuring HTTP proxy for OAuth2 authentication. \(#issue("9920", "https://github.com/trinodb/trino/issues/9920"), #issue("10069", "https://github.com/trinodb/trino/issues/10069")\)
- Add group-based and owner-based query access rules to file based system access control. \(#issue("9811", "https://github.com/trinodb/trino/issues/9811")\)
- Use internal names for discovery client when automatic TLS is enabled for internal communications. This allows #raw("discovery.uri") to be configured using a normal DNS name like #raw("https://coordinator.trino") and still use automatic TLS certificates. \(#issue("9821", "https://github.com/trinodb/trino/issues/9821")\)
- Use Kerberos operating system ticket cache if keytab file is not provided to JDBC and CLI for Kerberos authentication. \(#issue("8987", "https://github.com/trinodb/trino/issues/8987")\)
- Fix internal communication automatic TLS on Java 17. \(#issue("9821", "https://github.com/trinodb/trino/issues/9821")\)

== CLI

- Automatically use HTTPS when port is set to 443. \(#issue("8798", "https://github.com/trinodb/trino/issues/8798")\)

== BigQuery connector

- Support reading #raw("bignumeric") type whose precision is less than or equal to 38. \(#issue("9882", "https://github.com/trinodb/trino/issues/9882")\)
- Fix failure when a schema is dropped while listing tables. \(#issue("9954", "https://github.com/trinodb/trino/issues/9954")\)

== Cassandra connector

- Support reading user defined types in Cassandra. \(#issue("147", "https://github.com/trinodb/trino/issues/147")\)

== ClickHouse connector

- Add support for #link(label("doc-sql-truncate"))[truncating tables]. \(#issue("8921", "https://github.com/trinodb/trino/issues/8921")\)
- Fix incorrect query results when query contains predicates on #raw("real") type columns. \(#issue("9998", "https://github.com/trinodb/trino/issues/9998")\)

== Druid connector

- Add support for #link(label("doc-sql-truncate"))[truncating tables]. \(#issue("8921", "https://github.com/trinodb/trino/issues/8921")\)

== Elasticsearch connector

- Add support for additional Elastic Cloud node roles. \(#issue("9892", "https://github.com/trinodb/trino/issues/9892")\)
- Fix failure when empty values exist in numeric fields. \(#issue("9939", "https://github.com/trinodb/trino/issues/9939")\)

== Hive connector

- Allow reading empty files of type Parquet, RCFile, SequenceFile. \(#issue("9929", "https://github.com/trinodb/trino/issues/9929")\)
- Enable #raw("hive.s3.streaming") by default. \(#issue("9715", "https://github.com/trinodb/trino/issues/9715")\)
- Improve performance by not generating splits for empty files. \(#issue("9929", "https://github.com/trinodb/trino/issues/9929")\)
- Improve performance of decimal #raw("avg") aggregation. \(#issue("9738", "https://github.com/trinodb/trino/issues/9738")\)
- Improve performance when reading Parquet files with timestamps encoded using #raw("int64") representation. \(#issue("9414", "https://github.com/trinodb/trino/issues/9414")\)
- Improve dynamic partition pruning efficiency. \(#issue("9866", "https://github.com/trinodb/trino/issues/9866"), #issue("9869", "https://github.com/trinodb/trino/issues/9869")\)
- Improve query performance on partitioned tables or tables with small files by increasing #raw("hive.split-loader-concurrency") from #raw("4") to #raw("64"). \(#issue("9979", "https://github.com/trinodb/trino/issues/9979")\)
- Fix reporting of number of read bytes for tables using #raw("ORC") file format. \(#issue("10048", "https://github.com/trinodb/trino/issues/10048")\)
- Account for memory used for deleted row information when reading from ACID tables. \(#issue("9914", "https://github.com/trinodb/trino/issues/9914"), #issue("10070", "https://github.com/trinodb/trino/issues/10070")\)
- Fix #raw("REVOKE GRANT OPTION") to revoke only the grant option instead of revoking the entire privilege. \(#issue("10094", "https://github.com/trinodb/trino/issues/10094")\)
- Fix bug where incorrect rows were deleted when deleting from a transactional table that has original files \(before the first major compaction\). \(#issue("10095", "https://github.com/trinodb/trino/issues/10095")\)
- Fix delete and update failure when changing a table after a major compaction. \(#issue("10120", "https://github.com/trinodb/trino/issues/10120")\)
- Fix incorrect results when decoding decimal values in Parquet reader. \(#issue("9971", "https://github.com/trinodb/trino/issues/9971")\)
- Fix #raw("hive.dynamic-filtering.wait-timeout") not having any effect. \(#issue("10106", "https://github.com/trinodb/trino/issues/10106")\)
- Fix failure when reading Parquet data if column indexes are enabled. \(#issue("9890", "https://github.com/trinodb/trino/issues/9890"), #issue("10076", "https://github.com/trinodb/trino/issues/10076")\)

== Iceberg connector

- Add support for storing and reading UUID nested in #raw("row"), #raw("array") or #raw("map") type. \(#issue("9918", "https://github.com/trinodb/trino/issues/9918")\)
- Use Iceberg's #raw("schema.name-mapping.default") table property for scanning files with missing Iceberg IDs. This aligns Trino behavior on migrated files with the Iceberg spec. \(#issue("9959", "https://github.com/trinodb/trino/issues/9959")\)
- Use ZSTD compression by default. \(#issue("10058", "https://github.com/trinodb/trino/issues/10058")\)
- Add read-only security option which can be enabled by setting the configuration #raw("iceberg.security=read-only"). \(#issue("9974", "https://github.com/trinodb/trino/issues/9974")\)
- Change schema of #raw("$partitions") system table to avoid conflicts when table name contains a column named #raw("row_count"), #raw("file_count") or #raw("total_size"), or when a column is used for partitioning for part of table data, and it not used for partitioning in some other part of the table data. \(#issue("9519", "https://github.com/trinodb/trino/issues/9519"), #issue("8729", "https://github.com/trinodb/trino/issues/8729")\).
- Improve performance when reading timestamps from Parquet files. \(#issue("9414", "https://github.com/trinodb/trino/issues/9414")\)
- Improve query performance for certain queries with complex predicates. \(#issue("9309", "https://github.com/trinodb/trino/issues/9309")\)
- Reduce resource consumption and create bigger files when writing to an Iceberg table with partitioning. Bigger files are more efficient to query later. \(#issue("9826", "https://github.com/trinodb/trino/issues/9826")\)
- Improve performance for queries on nested data through dereference pushdown. \(#issue("8129", "https://github.com/trinodb/trino/issues/8129")\)
- Write correct #raw("file_size_in_bytes") in manifest when creating new ORC files. \(#issue("9810", "https://github.com/trinodb/trino/issues/9810")\)
- Fix query failures that could appear when reading Parquet files which contained ROW columns that were subject to schema evolution. \(#issue("9264", "https://github.com/trinodb/trino/issues/9264")\)
- Fix failure caused by stale metadata in the #raw("rollback_to_snapshot") procedure. \(#issue("9921", "https://github.com/trinodb/trino/issues/9921")\)

== Kudu connector

- Avoid scanner time-out issues when reading Kudu tables. \(#issue("7250", "https://github.com/trinodb/trino/issues/7250")\)

== MemSQL connector

- Add support for #link(label("doc-sql-truncate"))[truncating tables]. \(#issue("8921", "https://github.com/trinodb/trino/issues/8921")\)
- Fix incorrect query results when query contains predicates on #raw("real") type columns. \(#issue("9998", "https://github.com/trinodb/trino/issues/9998")\)

== MongoDB connector

- Support connecting to MongoDB clusters via #raw("mongodb.connection-url") config property. #raw("mongodb.seeds") and #raw("mongodb.credentials") properties are now deprecated. \(#issue("9819", "https://github.com/trinodb/trino/issues/9819")\)

== MySQL connector

- Add support for #link(label("doc-sql-truncate"))[truncating tables]. \(#issue("8921", "https://github.com/trinodb/trino/issues/8921")\)
- Fix incorrect query results when query contains predicates on #raw("real") type columns. \(#issue("9998", "https://github.com/trinodb/trino/issues/9998")\)

== Oracle connector

- Add support for #link(label("doc-sql-truncate"))[truncating tables]. \(#issue("8921", "https://github.com/trinodb/trino/issues/8921")\)

== Phoenix connector

- Support reading #raw("decimal") columns from Phoenix with unspecified precision or scale. \(#issue("9795", "https://github.com/trinodb/trino/issues/9795")\)
- Fix query failures when reading Phoenix tables. \(#issue("9151", "https://github.com/trinodb/trino/issues/9151")\)

== Pinot connector

- Update Pinot connector to be compatible with versions \>= 0.8.0 and drop support for older versions. \(#issue("9098", "https://github.com/trinodb/trino/issues/9098")\)

== PostgreSQL connector

- Add support for #link(label("doc-sql-truncate"))[truncating tables]. \(#issue("8921", "https://github.com/trinodb/trino/issues/8921")\)
- Add experimental support for range predicate pushdown on string columns. It can be enabled by setting the #raw("postgresql.experimental.enable-string-pushdown-with-collate") catalog configuration property or the corresponding #raw("enable_string_pushdown_with_collate") session property to #raw("true"). \(#issue("9746", "https://github.com/trinodb/trino/issues/9746")\)

== Redshift connector

- Add support for #link(label("doc-sql-truncate"))[truncating tables]. \(#issue("8921", "https://github.com/trinodb/trino/issues/8921")\)

== SQL Server connector

- Add support for #link(label("doc-sql-truncate"))[truncating tables]. \(#issue("8921", "https://github.com/trinodb/trino/issues/8921")\)

== SPI

- Allow split manager to filter splits based on a predicate not expressible as a #raw("TupleDomain"). \(#issue("7608", "https://github.com/trinodb/trino/issues/7608")\)
