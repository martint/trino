#import "/lib/trino-docs.typ": *

#anchor("doc-release-release-440")
= Release 440 \(8 Mar 2024\)

== General

- Add #link(label("doc-connector-snowflake"))[Snowflake connector]. \(#issue("17909", "https://github.com/trinodb/trino/issues/17909")\)
- Add support for sub-queries inside #raw("UNNEST") clauses. \(#issue("17953", "https://github.com/trinodb/trino/issues/17953")\)
- Improve performance of #link(label("fn-arrays-overlap"), raw("arrays_overlap")). \(#issue("20900", "https://github.com/trinodb/trino/issues/20900")\)
- Export JMX statistics for resource groups by default. This can be disabled with the #raw("jmxExport") resource group property. \(#issue("20810", "https://github.com/trinodb/trino/issues/20810")\)
- #breaking-marker("../release.html#breaking-changes") Remove the defunct #raw("*.http-client.max-connections") properties. \(#issue("20966", "https://github.com/trinodb/trino/issues/20966")\)
- Fix query failure when a check constraint is null. \(#issue("20906", "https://github.com/trinodb/trino/issues/20906")\)
- Fix query failure for aggregations over #raw("CASE") expressions when the input evaluation could throw an error. \(#issue("20652", "https://github.com/trinodb/trino/issues/20652")\)
- Fix incorrect behavior of the else clause in a SQL UDFs with a single if\/end condition. \(#issue("20926", "https://github.com/trinodb/trino/issues/20926")\)
- Fix the #raw("ALTER TABLE EXECUTE optimize") queries failing due to exceeding the open writer limit. \(#issue("20871", "https://github.com/trinodb/trino/issues/20871")\)
- Fix certain #raw("INSERT") and #raw("CREATE TABLE AS .. SELECT") queries failing due to exceeding the of open writer limit on partitioned tables. \(#issue("20871", "https://github.com/trinodb/trino/issues/20871")\)
- Fix "multiple entries with same key" query failure for queries with joins on partitioned tables. \(#issue("20917", "https://github.com/trinodb/trino/issues/20917")\)
- Fix incorrect results when using #raw("GRANT"), #raw("DENY"), and #raw("REVOKE") clauses on views and materialized views. \(#issue("20812", "https://github.com/trinodb/trino/issues/20812")\)

== Security

- Add support for row filtering and column masking in Open Policy Agent access control. \(#issue("20921", "https://github.com/trinodb/trino/issues/20921")\)

== Web UI

- Fix error when using authentication tokens larger than 4 kB. \(#issue("20787", "https://github.com/trinodb/trino/issues/20787")\)

== Delta Lake connector

- Add support for concurrent #raw("INSERT") queries. \(#issue("18506", "https://github.com/trinodb/trino/issues/18506")\)
- Improve latency for queries with file system caching enabled. \(#issue("20851", "https://github.com/trinodb/trino/issues/20851")\)
- Improve latency for queries on tables with checkpoints. \(#issue("20901", "https://github.com/trinodb/trino/issues/20901")\)
- Fix query failure due to "corrupted statistics" when reading Parquet files with a predicate on a long decimal column. \(#issue("20981", "https://github.com/trinodb/trino/issues/20981")\)

== Hive connector

- Add support for bearer token authentication for a Thrift metastore connection. \(#issue("20371", "https://github.com/trinodb/trino/issues/20371")\)
- Add support for commenting on partitioned columns in the Thrift metastore. \(#issue("20264", "https://github.com/trinodb/trino/issues/20264")\)
- Add support for changing a column's type from #raw("varchar") to #raw("float"). \(#issue("20719", "https://github.com/trinodb/trino/issues/20719")\)
- Add support for changing a column's type from #raw("varchar") to #raw("char"). \(#issue("20723", "https://github.com/trinodb/trino/issues/20723")\)
- Add support for changing a column's type from #raw("varchar") to #raw("boolean"). \(#issue("20741", "https://github.com/trinodb/trino/issues/20741")\)
- Add support for configuring a #raw("region") and #raw("endpoint") for S3 security mapping. \(#issue("18838", "https://github.com/trinodb/trino/issues/18838")\)
- Improve performance when reading JSON files. \(#issue("19396", "https://github.com/trinodb/trino/issues/19396")\)
- Fix incorrect truncation when decoding #raw("varchar(n)") and #raw("char(n)") in #raw("TEXTFILE") and #raw("SEQUENCEFILE") formats. \(#issue("20731", "https://github.com/trinodb/trino/issues/20731")\)
- Fix query failure when #raw("hive.file-status-cache-tables") is enabled for a table and new manifest files have been added but not cached yet. \(#issue("20344", "https://github.com/trinodb/trino/issues/20344")\)
- Fix error when trying to #raw("INSERT") into a transactional table that does not have partitions. \(#issue("19407", "https://github.com/trinodb/trino/issues/19407")\)
- Fix query failure due to "corrupted statistics" when reading Parquet files with a predicate on a long decimal column. \(#issue("20981", "https://github.com/trinodb/trino/issues/20981")\)

== Hudi connector

- Fix query failure due to "corrupted statistics" when reading Parquet files with a predicate on a long decimal column. \(#issue("20981", "https://github.com/trinodb/trino/issues/20981")\)

== Iceberg connector

#warning[
This release has a major regression which is fixed in Trino 442.
]

- Improve latency of queries when file system caching is enabled. \(#issue("20803", "https://github.com/trinodb/trino/issues/20803")\)
- Disallow setting the materialized view owner when using system security with the Glue catalog. \(#issue("20647", "https://github.com/trinodb/trino/issues/20647")\)
- Rename the #raw("orc.bloom.filter.columns") and #raw("orc.bloom.filter.fpp") table properties to #raw("write.orc.bloom.filter.columns") and #raw("write.orc.bloom.filter.fpp"), respectively. \(#issue("20432", "https://github.com/trinodb/trino/issues/20432")\)
- Fix query failure due to "corrupted statistics" when reading Parquet files with a predicate on a long decimal column. \(#issue("20981", "https://github.com/trinodb/trino/issues/20981")\)

== SPI

- Add reset to position method to #raw("BlockBuilder"). \(#issue("19577", "https://github.com/trinodb/trino/issues/19577")\)
- Remove the #raw("getChildren") method from #raw("Block"). \(#issue("19577", "https://github.com/trinodb/trino/issues/19577")\)
- Remove the #raw("get{Type}") methods from #raw("Block").  Callers must unwrap a #raw("Block") and downcast the #raw("ValueBlock") to #raw("Type.getValueBlockType()") implementation. \(#issue("19577", "https://github.com/trinodb/trino/issues/19577")\)
