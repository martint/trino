#import "/lib/trino-docs.typ": *

#anchor("doc-release-release-344")
= Release 344 \(9 Oct 2020\)

== General

- Add #link(label("fn-murmur3"), raw("murmur3")) function. \(#issue("5054", "https://github.com/trinodb/trino/issues/5054")\)
- Add #link(label("fn-from-unixtime-nanos"), raw("from_unixtime_nanos")) function. \(#issue("5046", "https://github.com/trinodb/trino/issues/5046")\)
- Add #link(label("doc-functions-tdigest"))[T-Digest] type and functions. \(#issue("5158", "https://github.com/trinodb/trino/issues/5158")\)
- Improve performance and latency of queries leveraging dynamic filters. \(#issue("5081", "https://github.com/trinodb/trino/issues/5081"), #issue("5340", "https://github.com/trinodb/trino/issues/5340")\)
- Add #raw("dynamic-filtering.service-thread-count") config property to specify number of threads used for processing dynamic filters on coordinator. \(#issue("5341", "https://github.com/trinodb/trino/issues/5341")\)
- Extend #link(label("doc-security-secrets"))[Secrets] environment variable substitution to allow multiple replacements in a single configuration property. \(#issue("4345", "https://github.com/trinodb/trino/issues/4345")\)
- Remove the #raw("fast-inequality-joins") configuration property. This feature is always enabled. \(#issue("5375", "https://github.com/trinodb/trino/issues/5375")\)
- Use #raw("timestamp(3) with time zone") rather than #raw("timestamp(3)") for the #raw("queries"), #raw("transactions"), and #raw("tasks") tables in #raw("system.runtime"). \(#issue("5464", "https://github.com/trinodb/trino/issues/5464")\)
- Improve performance and accuracy of #link(label("fn-approx-percentile"), raw("approx_percentile")). \(#issue("5158", "https://github.com/trinodb/trino/issues/5158")\)
- Improve performance of certain cross join queries. \(#issue("5276", "https://github.com/trinodb/trino/issues/5276")\)
- Prevent potential query deadlock when query runs out of memory. \(#issue("5289", "https://github.com/trinodb/trino/issues/5289")\)
- Fix failure due to rounding error when casting between two #raw("timestamp") types with precision higher than 6. \(#issue("5310", "https://github.com/trinodb/trino/issues/5310")\)
- Fix failure due to rounding error when casting between two #raw("timestamp with time zone") types with precision higher than 3. \(#issue("5371", "https://github.com/trinodb/trino/issues/5371")\)
- Fix column pruning for #raw("EXPLAIN ANALYZE"). \(#issue("4760", "https://github.com/trinodb/trino/issues/4760")\)
- Fix incorrect timestamp values returned by the #raw("queries"), #raw("transactions"), and #raw("tasks") tables in #raw("system.runtime"). \(#issue("5462", "https://github.com/trinodb/trino/issues/5462")\)

== Security

#warning[
The file-based system and catalog access controls have changed in ways that reduce or increase permissions. Please, read these release notes carefully.
]

- Change file-based catalog access control from deny to allow when table, schema, or session property rules are not defined. \(#issue("5039", "https://github.com/trinodb/trino/issues/5039")\)
- Add missing table rule checks for table and view DDL in file-based system access control. \(#issue("5039", "https://github.com/trinodb/trino/issues/5039")\)
- Add missing schema rule checks for create schema in file-based system access control. \(#issue("5039", "https://github.com/trinodb/trino/issues/5039")\)
- Add session property rules to file-based system access control. \(#issue("5039", "https://github.com/trinodb/trino/issues/5039")\)
- Add catalog regex to table and schema rules in file-based system access control. \(#issue("5039", "https://github.com/trinodb/trino/issues/5039")\)
- Change create, rename, alter, and drop table in file-based system controls to only check for table ownership.  \(#issue("5039", "https://github.com/trinodb/trino/issues/5039")\)
- Change file-based system access control to support files without catalog rules defined. In this case, all access to catalogs is allowed. \(#issue("5039", "https://github.com/trinodb/trino/issues/5039")\)
- Change file-based system and catalog access controls to only show catalogs, schemas, and tables a user has permissions on. \(#issue("5039", "https://github.com/trinodb/trino/issues/5039")\)
- Change file-based catalog access control to deny permissions inspection and manipulation. \(#issue("5039", "https://github.com/trinodb/trino/issues/5039")\)
- Add #link(label("doc-security-group-mapping"))[file-based group provider]. \(#issue("5028", "https://github.com/trinodb/trino/issues/5028")\)

== Hive connector

- Add support for #raw("hive.security=allow-all"), which allows to skip all authorization checks. \(#issue("5416", "https://github.com/trinodb/trino/issues/5416")\)
- Support Kerberos authentication for Hudi tables. \(#issue("5472", "https://github.com/trinodb/trino/issues/5472")\)
- Allow hiding Delta Lake tables from table listings such as #raw("SHOW TABLES") or #raw("information_schema.tables"), as these tables cannot be queried by the Hive connector. This be enabled using the #raw("hive.hide-delta-lake-tables") configuration property. \(#issue("5430", "https://github.com/trinodb/trino/issues/5430")\)
- Improve query concurrency by listing data files more efficiently. \(#issue("5260", "https://github.com/trinodb/trino/issues/5260")\)
- Fix Parquet encoding for timestamps before 1970-01-01. \(#issue("5364", "https://github.com/trinodb/trino/issues/5364")\)

== Kafka connector

- Expose message timestamp via #raw("_timestamp") internal column. \(#issue("4805", "https://github.com/trinodb/trino/issues/4805")\)
- Add predicate pushdown for #raw("_timestamp"), #raw("_partition_offset") and #raw("_partition_id") columns. \(#issue("4805", "https://github.com/trinodb/trino/issues/4805")\)

== Phoenix connector

- Fix query failure when a column name in #raw("CREATE TABLE") requires quoting. \(#issue("3601", "https://github.com/trinodb/trino/issues/3601")\)

== PostgreSQL connector

- Add support for setting a column comment. \(#issue("5307", "https://github.com/trinodb/trino/issues/5307")\)
- Add support for variable-precision #raw("time") type. \(#issue("5342", "https://github.com/trinodb/trino/issues/5342")\)
- Allow #raw("CREATE TABLE") and #raw("CREATE TABLE AS") with #raw("timestamp") and #raw("timestamp with time zone") with precision higher than 6. The resulting column will be declared with precision of 6, maximal supported by PostgreSQL. \(#issue("5342", "https://github.com/trinodb/trino/issues/5342")\)

== SQL Server connector

- Improve performance of queries with aggregations and #raw("WHERE") clause. \(#issue("5327", "https://github.com/trinodb/trino/issues/5327")\)
