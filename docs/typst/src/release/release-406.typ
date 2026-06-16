#import "/lib/trino-docs.typ": *

#anchor("doc-release-release-406")
= Release 406 \(25 Jan 2023\)

== General

- Add support for #link(label("ref-fte-exchange-hdfs"))[exchange spooling on HDFS] when fault-tolerant execution is enabled. \(#issue("15160", "https://github.com/trinodb/trino/issues/15160")\)
- Add support for #raw("CHECK") constraints in an #raw("INSERT") statement. \(#issue("14964", "https://github.com/trinodb/trino/issues/14964")\)
- Improve planner estimates for queries containing outer joins over a subquery involving #raw("ORDER BY") and #raw("LIMIT"). \(#issue("15428", "https://github.com/trinodb/trino/issues/15428")\)
- Improve accuracy of memory usage reporting for table scans. \(#issue("15711", "https://github.com/trinodb/trino/issues/15711")\)
- Improve performance of queries parsing date values in ISO 8601 format. \(#issue("15548", "https://github.com/trinodb/trino/issues/15548")\)
- Improve performance of queries with selective joins. \(#issue("15569", "https://github.com/trinodb/trino/issues/15569")\)
- Remove #raw("legacy-phased") execution scheduler as an option for the #raw("query.execution-policy") configuration property. \(#issue("15657", "https://github.com/trinodb/trino/issues/15657")\)
- Fix failure when #raw("WHERE") or #raw("JOIN") clauses contain a #raw("LIKE") expression with a non-constant pattern or escape. \(#issue("15629", "https://github.com/trinodb/trino/issues/15629")\)
- Fix inaccurate planner estimates for queries with filters on columns without statistics. \(#issue("15642", "https://github.com/trinodb/trino/issues/15642")\)
- Fix queries with outer joins failing when fault-tolerant execution is enabled. \(#issue("15608", "https://github.com/trinodb/trino/issues/15608")\)
- Fix potential query failure when using #raw("MATCH_RECOGNIZE"). \(#issue("15461", "https://github.com/trinodb/trino/issues/15461")\)
- Fix query failure when using group-based access control with column masks or row filters. \(#issue("15583", "https://github.com/trinodb/trino/issues/15583")\)
- Fix potential hang during shutdown. \(#issue("15675", "https://github.com/trinodb/trino/issues/15675")\)
- Fix incorrect results when referencing a field resulting from the application of a column mask expression that produces a #raw("row") type. \(#issue("15659", "https://github.com/trinodb/trino/issues/15659")\)
- Fix incorrect application of column masks when a mask expression references a different column in the underlying table. \(#issue("15680", "https://github.com/trinodb/trino/issues/15680")\)

== BigQuery connector

- Add support for #link(label("doc-admin-fault-tolerant-execution"))[fault-tolerant execution]. \(#issue("15620", "https://github.com/trinodb/trino/issues/15620")\)
- Fix possible incorrect results for certain queries like #raw("count(*)") when a table has recently been written to. \(#issue("14981", "https://github.com/trinodb/trino/issues/14981")\)

== Cassandra connector

- Fix incorrect results when the Cassandra #raw("list"), #raw("map"), or #raw("set") types contain user-defined types. \(#issue("15771", "https://github.com/trinodb/trino/issues/15771")\)

== Delta Lake connector

- Reduce latency for #raw("INSERT") queries on unpartitioned tables. \(#issue("15708", "https://github.com/trinodb/trino/issues/15708")\)
- Improve performance of reading Parquet files. \(#issue("15498", "https://github.com/trinodb/trino/issues/15498")\)
- Improve memory accounting of the Parquet reader. \(#issue("15554", "https://github.com/trinodb/trino/issues/15554")\)
- Improve performance of queries with filters or projections on low-cardinality string columns stored in Parquet files. \(#issue("15269", "https://github.com/trinodb/trino/issues/15269")\)
- Fix reading more data than necessary from Parquet files for queries with filters. \(#issue("15552", "https://github.com/trinodb/trino/issues/15552")\)
- Fix potential query failure when writing to Parquet from a table with an #raw("INTEGER") range on a #raw("BIGINT") column. \(#issue("15496", "https://github.com/trinodb/trino/issues/15496")\)
- Fix query failure due to missing null counts in Parquet column indexes. \(#issue("15706", "https://github.com/trinodb/trino/issues/15706")\)

== Hive connector

- Add support for table redirections to catalogs using the Hudi connector. \(#issue("14750", "https://github.com/trinodb/trino/issues/14750")\)
- Reduce latency for #raw("INSERT") queries on unpartitioned tables. \(#issue("15708", "https://github.com/trinodb/trino/issues/15708")\)
- Improve performance of caching. \(#issue("13243 ", "https://github.com/trinodb/trino/issues/13243 ")\)
- Improve performance of reading Parquet files. \(#issue("15498", "https://github.com/trinodb/trino/issues/15498")\)
- Improve memory accounting of the Parquet reader. \(#issue("15554", "https://github.com/trinodb/trino/issues/15554")\)
- Improve performance of queries with filters or projections on low-cardinality string columns stored in Parquet files. \(#issue("15269", "https://github.com/trinodb/trino/issues/15269")\)
- Improve performance of queries with filters when Bloom filter indexes are present in Parquet files. Use of Bloom filters from Parquet files can be disabled with the #raw("parquet.use-bloom-filter") configuration property or the #raw("parquet_use_bloom_filter") session property. \(#issue("14428", "https://github.com/trinodb/trino/issues/14428")\)
- Allow coercion between Hive #raw("UNIONTYPE") and Hive #raw("STRUCT")-typed columns. \(#issue("15017", "https://github.com/trinodb/trino/issues/15017")\)
- Fix reading more data than necessary from Parquet files for queries with filters. \(#issue("15552", "https://github.com/trinodb/trino/issues/15552")\)
- Fix query failure due to missing null counts in Parquet column indexes. \(#issue("15706", "https://github.com/trinodb/trino/issues/15706")\)
- Fix incorrect #raw("schema already exists") error caused by a client timeout when creating a new schema. \(#issue("15174", "https://github.com/trinodb/trino/issues/15174")\)

== Hudi connector

- Improve performance of reading Parquet files. \(#issue("15498", "https://github.com/trinodb/trino/issues/15498")\)
- Improve memory accounting of the Parquet reader. \(#issue("15554", "https://github.com/trinodb/trino/issues/15554")\)
- Improve performance of queries with filters or projections on low-cardinality string columns stored in Parquet files. \(#issue("15269", "https://github.com/trinodb/trino/issues/15269")\)
- Fix reading more data than necessary from Parquet files for queries with filters. \(#issue("15552", "https://github.com/trinodb/trino/issues/15552")\)
- Fix query failure due to missing null counts in Parquet column indexes. \(#issue("15706", "https://github.com/trinodb/trino/issues/15706")\)

== Iceberg connector

- Add support for changing column types. \(#issue("15515", "https://github.com/trinodb/trino/issues/15515")\)
- Add #link(label("ref-iceberg-jdbc-catalog"))[support for the JDBC catalog]. \(#issue("9968", "https://github.com/trinodb/trino/issues/9968")\)
- Reduce latency for #raw("INSERT") queries on unpartitioned tables. \(#issue("15708", "https://github.com/trinodb/trino/issues/15708")\)
- Improve performance of reading Parquet files. \(#issue("15498", "https://github.com/trinodb/trino/issues/15498")\)
- Improve memory accounting of the Parquet reader. \(#issue("15554", "https://github.com/trinodb/trino/issues/15554")\)
- Improve performance of queries with filters or projections on low-cardinality string columns stored in Parquet files. \(#issue("15269", "https://github.com/trinodb/trino/issues/15269")\)
- Fix reading more data than necessary from Parquet files for queries with filters. \(#issue("15552", "https://github.com/trinodb/trino/issues/15552")\)
- Fix query failure due to missing null counts in Parquet column indexes. \(#issue("15706", "https://github.com/trinodb/trino/issues/15706")\)
- Fix query failure when a subquery contains #link(label("ref-iceberg-time-travel"))[time travel]. \(#issue("15607", "https://github.com/trinodb/trino/issues/15607")\)
- Fix failure when reading columns that had their type changed from #raw("float") to #raw("double") by other query engines. \(#issue("15650", "https://github.com/trinodb/trino/issues/15650")\)
- Fix incorrect results when reading or writing #raw("NaN") with #raw("real") or #raw("double") types on partitioned columns. \(#issue("15723", "https://github.com/trinodb/trino/issues/15723")\)

== MongoDB connector

- Fix schemas not being dropped when trying to drop schemas with the #raw("mongodb.case-insensitive-name-matching") configuration property enabled. \(#issue("15716", "https://github.com/trinodb/trino/issues/15716")\)

== PostgreSQL connector

- Add support for changing column types. \(#issue("15515", "https://github.com/trinodb/trino/issues/15515")\)

== SPI

- Remove the #raw("getDeleteRowIdColumnHandle()"), #raw("beginDelete()"), #raw("finishDelete()"), #raw("getUpdateRowIdColumnHandle()"), #raw("beginUpdate()"), and #raw("finishUpdate()") methods from #raw("ConnectorMetadata"). \(#issue("15161", "https://github.com/trinodb/trino/issues/15161")\)
- Remove the #raw("UpdatablePageSource") interface. \(#issue("15161", "https://github.com/trinodb/trino/issues/15161")\)
- Remove support for multiple masks on a single column. \(#issue("15680", "https://github.com/trinodb/trino/issues/15680")\)
