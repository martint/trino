#import "/lib/trino-docs.typ": *

#anchor("doc-release-release-444")
= Release 444 \(3 Apr 2024\)

== General

- Improve planning time for queries with a large number of joins. \(#issue("21360", "https://github.com/trinodb/trino/issues/21360")\)
- Fix failure for queries containing large numbers of #raw("LIKE") terms in boolean expressions. \(#issue("21235", "https://github.com/trinodb/trino/issues/21235")\)
- Fix potential failure when queries contain filtered aggregations. \(#issue("21272", "https://github.com/trinodb/trino/issues/21272")\)

== Docker image

- Update Java runtime to Java 22. \(#issue("21161", "https://github.com/trinodb/trino/issues/21161")\)

== BigQuery connector

- Fix failure when reading BigQuery views with #link("https://arrow.apache.org/docs/")[Apache Arrow]. \(#issue("21337", "https://github.com/trinodb/trino/issues/21337")\)

== ClickHouse connector

- Improve performance of reading table comments. \(#issue("21238", "https://github.com/trinodb/trino/issues/21238")\)

== Delta Lake connector

- Add support for reading #raw("BYTE_STREAM_SPLIT") encoding in Parquet files. \(#issue("8357", "https://github.com/trinodb/trino/issues/8357")\)
- Add support for #link("https://docs.aws.amazon.com/AmazonS3/latest/userguide/acl-overview.html#canned-acl")[Canned ACLs] with the native S3 file system. \(#issue("21176", "https://github.com/trinodb/trino/issues/21176")\)
- Add support for concurrent, non-conflicting writes when a table is read and written to in the same query. \(#issue("20983", "https://github.com/trinodb/trino/issues/20983")\)
- Add support for reading tables with #link("https://github.com/delta-io/delta/blob/master/PROTOCOL.md#v2-spec")[v2 checkpoints]. \(#issue("19345", "https://github.com/trinodb/trino/issues/19345")\)
- Add support for reading #link(label("ref-delta-lake-shallow-clone"))[shallow cloned tables]. \(#issue("17011", "https://github.com/trinodb/trino/issues/17011")\)
- #breaking-marker("../release.html#breaking-changes") Remove support for split size configuration with the catalog properties #raw("delta.max-initial-splits") and #raw("delta.max-initial-split-size"), and the catalog session property #raw("max_initial_split_size"). \(#issue("21320", "https://github.com/trinodb/trino/issues/21320")\)
- Fix incorrect results when querying a table that's being modified concurrently. \(#issue("21324", "https://github.com/trinodb/trino/issues/21324")\)

== Druid connector

- Improve performance of reading table comments. \(#issue("21238", "https://github.com/trinodb/trino/issues/21238")\)

== Hive connector

- Add support for reading #raw("BYTE_STREAM_SPLIT") encoding in Parquet files. \(#issue("8357", "https://github.com/trinodb/trino/issues/8357")\)
- Add support for #link("https://docs.aws.amazon.com/AmazonS3/latest/userguide/acl-overview.html#canned-acl")[Canned ACLs] with the native S3 file system. \(#issue("21176", "https://github.com/trinodb/trino/issues/21176")\)

== Hudi connector

- Add support for reading #raw("BYTE_STREAM_SPLIT") encoding in Parquet files. \(#issue("8357", "https://github.com/trinodb/trino/issues/8357")\)
- Add support for #link("https://docs.aws.amazon.com/AmazonS3/latest/userguide/acl-overview.html#canned-acl")[Canned ACLs] with the native S3 file system. \(#issue("21176", "https://github.com/trinodb/trino/issues/21176")\)

== Iceberg connector

- Add support for the #raw("metadata_log_entries") system table. \(#issue("20410", "https://github.com/trinodb/trino/issues/20410")\)
- Add support for reading #raw("BYTE_STREAM_SPLIT") encoding in Parquet files. \(#issue("8357", "https://github.com/trinodb/trino/issues/8357")\)
- Add support for #link("https://docs.aws.amazon.com/AmazonS3/latest/userguide/acl-overview.html#canned-acl")[Canned ACLs] with the native S3 file system. \(#issue("21176", "https://github.com/trinodb/trino/issues/21176")\)

== Ignite connector

- Improve performance of reading table comments. \(#issue("21238", "https://github.com/trinodb/trino/issues/21238")\)

== MariaDB connector

- Improve performance of reading table comments. \(#issue("21238", "https://github.com/trinodb/trino/issues/21238")\)

== MySQL connector

- Improve performance of reading table comments. \(#issue("21238", "https://github.com/trinodb/trino/issues/21238")\)

== Oracle connector

- Improve performance of reading table comments. \(#issue("21238", "https://github.com/trinodb/trino/issues/21238")\)

== PostgreSQL connector

- Improve performance of reading table comments. \(#issue("21238", "https://github.com/trinodb/trino/issues/21238")\)

== Redshift connector

- Improve performance of reading table comments. \(#issue("21238", "https://github.com/trinodb/trino/issues/21238")\)

== SingleStore connector

- Improve performance of reading table comments. \(#issue("21238", "https://github.com/trinodb/trino/issues/21238")\)

== Snowflake connector

- Add support for table comments. \(#issue("21305", "https://github.com/trinodb/trino/issues/21305")\)
- Improve performance of queries with #raw("ORDER BY ... LIMIT") clause, or #raw("avg"), #raw("count(distinct)"), #raw("stddev"), or #raw("stddev_pop") aggregation functions when the computation can be pushed down to the underlying database. \(#issue("21219", "https://github.com/trinodb/trino/issues/21219"), #issue("21148", "https://github.com/trinodb/trino/issues/21148"), #issue("21130", "https://github.com/trinodb/trino/issues/21130"), #issue("21338", "https://github.com/trinodb/trino/issues/21338")\)
- Improve performance of reading table comments.  \(#issue("21161", "https://github.com/trinodb/trino/issues/21161")\)

== SQLServer connector

- Improve performance of reading table comments. \(#issue("21238", "https://github.com/trinodb/trino/issues/21238")\)

== SPI

- Change group id and capacity of #raw("GroupedAccumulatorState") to #raw("int") type. \(#issue("21333", "https://github.com/trinodb/trino/issues/21333")\)
