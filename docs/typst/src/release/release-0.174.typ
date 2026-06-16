#import "/lib/trino-docs.typ": *

#anchor("doc-release-release-0-174")
= Release 0.174

== General

- Fix correctness issue for correlated subqueries containing a #raw("LIMIT") clause.
- Fix query failure when #link(label("fn-reduce"), raw("reduce")) function is used with lambda expressions containing #link(label("fn-array-sort"), raw("array_sort")), #link(label("fn-shuffle"), raw("shuffle")), #link(label("fn-reverse"), raw("reverse")), #link(label("fn-array-intersect"), raw("array_intersect")), #link(label("fn-arrays-overlap"), raw("arrays_overlap")), #link(label("fn-concat"), raw("concat")) \(for arrays\) or #link(label("fn-map-concat"), raw("map_concat")).
- Fix a bug that causes underestimation of the amount of memory used by #link(label("fn-max-by"), raw("max_by")), #link(label("fn-min-by"), raw("min_by")), #link(label("fn-max"), raw("max")), #link(label("fn-min"), raw("min")), and #link(label("fn-arbitrary"), raw("arbitrary")) aggregations over varchar\/varbinary columns.
- Fix a memory leak in the coordinator that causes long-running queries in highly loaded clusters to consume unnecessary memory.
- Improve performance of aggregate window functions.
- Improve parallelism of queries involving #raw("GROUPING SETS"), #raw("CUBE") or #raw("ROLLUP").
- Improve parallelism of #raw("UNION") queries.
- Filter and projection operations are now always processed columnar if possible, and Presto will automatically take advantage of dictionary encodings where effective. The #raw("processing_optimization") session property and #raw("optimizer.processing-optimization") configuration option have been removed.
- Add support for escaped unicode sequences in string literals.
- Add #link(label("doc-sql-show-grants"))[SHOW GRANTS] and #raw("information_schema.table_privileges") table.

== Hive

- Change default value of #raw("hive.metastore-cache-ttl") and #raw("hive.metastore-refresh-interval") to 0 to disable cross-transaction metadata caching.

== Web UI

- Fix ES6 compatibility issue with older browsers.
- Display buffered bytes for every stage in the live plan UI.

== SPI

- Add support for retrieving table grants.
- Rename SPI access control check from #raw("checkCanShowTables") to #raw("checkCanShowTablesMetadata"), which is used for both #link(label("doc-sql-show-tables"))[SHOW TABLES] and #link(label("doc-sql-show-grants"))[SHOW GRANTS].
