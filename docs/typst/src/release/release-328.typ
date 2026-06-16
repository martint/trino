#import "/lib/trino-docs.typ": *

#anchor("doc-release-release-328")
= Release 328 \(10 Jan 2020\)

== General

- Fix correctness issue for certain correlated join queries when the correlated subquery on the right produces no rows. \(#issue("1969", "https://github.com/trinodb/trino/issues/1969")\)
- Fix incorrect handling of multi-byte characters for #link(label("doc-functions-regexp"))[Regular expression functions] when the pattern is empty. \(#issue("2313", "https://github.com/trinodb/trino/issues/2313")\)
- Fix failure when join criteria contains columns of different types. \(#issue("2320", "https://github.com/trinodb/trino/issues/2320")\)
- Fix failure for complex outer join queries when dynamic filtering is enabled. \(#issue("2363", "https://github.com/trinodb/trino/issues/2363")\)
- Improve support for correlated queries. \(#issue("1969", "https://github.com/trinodb/trino/issues/1969")\)
- Allow inserting values of a larger type into as smaller type when the values fit. For example, #raw("BIGINT") into #raw("SMALLINT"), or #raw("VARCHAR(10)") into #raw("VARCHAR(3)"). Values that don't fit will cause an error at runtime. \(#issue("2061", "https://github.com/trinodb/trino/issues/2061")\)
- Add #link(label("fn-regexp-count"), raw("regexp_count")) and #link(label("fn-regexp-position"), raw("regexp_position")) functions. \(#issue("2136", "https://github.com/trinodb/trino/issues/2136")\)
- Add support for interpolating #link(label("doc-security-secrets"))[Secrets] in server and catalog configuration files. \(#issue("2370", "https://github.com/trinodb/trino/issues/2370")\)

== Security

- Fix a security issue allowing users to gain unauthorized access to Presto cluster when using password authenticator with LDAP. \(#issue("2356", "https://github.com/trinodb/trino/issues/2356")\)
- Add support for LDAP referrals in LDAP password authenticator. \(#issue("2354", "https://github.com/trinodb/trino/issues/2354")\)

== JDBC driver

- Fix behavior of #raw("java.sql.Connection#commit()") and #raw("java.sql.Connection#rollback()") methods when no statements performed in a transaction. Previously, these methods would fail. \(#issue("2339", "https://github.com/trinodb/trino/issues/2339")\)
- Fix failure when restoring autocommit mode with #raw("java.sql.Connection#setAutocommit()") \(#issue("2338", "https://github.com/trinodb/trino/issues/2338")\)

== Hive connector

- Reduce query latency and Hive metastore load when using the #raw("AUTOMATIC") join reordering strategy. \(#issue("2184", "https://github.com/trinodb/trino/issues/2184")\)
- Allow configuring #raw("hive.max-outstanding-splits-size") to values larger than 2GB. \(#issue("2395", "https://github.com/trinodb/trino/issues/2395")\)
- Avoid redundant file system stat call when writing Parquet files. \(#issue("1746", "https://github.com/trinodb/trino/issues/1746")\)
- Avoid retrying permanent errors for S3-related services such as STS. \(#issue("2331", "https://github.com/trinodb/trino/issues/2331")\)

== Kafka connector

- Remove internal columns: #raw("_segment_start"), #raw("_segment_end") and #raw("_segment_count"). \(#issue("2303", "https://github.com/trinodb/trino/issues/2303")\)
- Add new configuration property #raw("kafka.messages-per-split") to control how many Kafka messages will be processed by a single Presto split. \(#issue("2303", "https://github.com/trinodb/trino/issues/2303")\)

== Elasticsearch connector

- Fix query failure when an object in an Elasticsearch document does not have any fields. \(#issue("2217", "https://github.com/trinodb/trino/issues/2217")\)
- Add support for querying index aliases. \(#issue("2324", "https://github.com/trinodb/trino/issues/2324")\)

== Phoenix connector

- Add support for mapping unsupported data types to #raw("VARCHAR"). This can be enabled by setting the #raw("unsupported-type-handling") configuration property or the #raw("unsupported_type_handling") session property to #raw("CONVERT_TO_VARCHAR"). \(#issue("2427", "https://github.com/trinodb/trino/issues/2427")\)

== Other connectors

These changes apply to the MySQL, PostgreSQL, Redshift and SQL Server connectors:

- Add support for creating schemas. \(#issue("1874", "https://github.com/trinodb/trino/issues/1874")\)
- Add support for caching metadata. The configuration property #raw("metadata.cache-ttl") controls how long to cache data \(it defaults to #raw("0ms") which disables caching\), and #raw("metadata.cache-missing") controls whether or not missing tables are cached. \(#issue("2290", "https://github.com/trinodb/trino/issues/2290")\)

This change applies to the MySQL and PostgreSQL connectors:

- Add support for mapping #raw("DECIMAL") types with precision larger than 38 to Presto #raw("DECIMAL"). \(#issue("2088", "https://github.com/trinodb/trino/issues/2088")\)
