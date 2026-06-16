#import "/lib/trino-docs.typ": *

#anchor("doc-release-release-447")
= Release 447 \(8 May 2024\)

== General

- Add support for #link(label("doc-sql-show-create-function"))[SHOW CREATE FUNCTION]. \(#issue("21809", "https://github.com/trinodb/trino/issues/21809")\)
- Add support for the #link(label("fn-bitwise-xor-agg"), raw("bitwise_xor_agg")) aggregation function. \(#issue("21436", "https://github.com/trinodb/trino/issues/21436")\)
- #breaking-marker("../release.html#breaking-changes") Require JDK 22 to run Trino, including updated #link(label("ref-jvm-config"))[Deploying Trino].\(#issue("20980", "https://github.com/trinodb/trino/issues/20980")\)
- Improve performance of #raw("ORDER BY") queries with #raw("LIMIT") on large data sets. \(#issue("21761", "https://github.com/trinodb/trino/issues/21761")\)
- Improve performance of queries containing the #link(label("fn-rank"), raw("rank")) or #link(label("fn-row-number"), raw("row_number")) window functions. \(#issue("21639", "https://github.com/trinodb/trino/issues/21639")\)
- Improve performance of correlated queries with #raw("EXISTS"). \(#issue("21422", "https://github.com/trinodb/trino/issues/21422")\)
- Fix potential failure for expressions involving #raw("try_cast(parse_json(...))"). \(#issue("21877", "https://github.com/trinodb/trino/issues/21877")\)

== CLI

- Fix incorrect error location markers for SQL UDFs causing the CLI to print exceptions. \(#issue("21357", "https://github.com/trinodb/trino/issues/21357")\)

== Delta Lake connector

- Add support for concurrent #raw("DELETE") and #raw("TRUNCATE") queries. \(#issue("18521", "https://github.com/trinodb/trino/issues/18521")\)
- Fix under-accounting of memory usage when writing strings to Parquet files. \(#issue("21745", "https://github.com/trinodb/trino/issues/21745")\)

== Hive connector

- Add support for metastore caching on tables that have not been analyzed, which can be enabled with the #raw("hive.metastore-cache.cache-missing-stats") and #raw("hive.metastore-cache.cache-missing-partitions") configuration properties. \(#issue("21822", "https://github.com/trinodb/trino/issues/21822")\)
- Fix under-accounting of memory usage when writing strings to Parquet files. \(#issue("21745", "https://github.com/trinodb/trino/issues/21745")\)
- Fix failure when translating Hive views that contain #raw("EXISTS") clauses. \(#issue("21829", "https://github.com/trinodb/trino/issues/21829")\)

== Hudi connector

- Fix under-accounting of memory usage when writing strings to Parquet files. \(#issue("21745", "https://github.com/trinodb/trino/issues/21745")\)

== Iceberg connector

- Fix under-accounting of memory usage when writing strings to Parquet files. \(#issue("21745", "https://github.com/trinodb/trino/issues/21745")\)

== Phoenix connector

- #breaking-marker("../release.html#breaking-changes") Remove support for Phoenix versions 5.1.x and earlier. \(#issue("21569", "https://github.com/trinodb/trino/issues/21569")\)

== Pinot connector

- Add support for specifying an explicit broker URL with the #raw("pinot.broker-url") configuration property. \(#issue("17791", "https://github.com/trinodb/trino/issues/17791")\)

== Redshift connector

- #breaking-marker("../release.html#breaking-changes") Remove deprecated legacy type mapping and the associated #raw("redshift.use-legacy-type-mapping") configuration property. \(#issue("21855", "https://github.com/trinodb/trino/issues/21855")\)
