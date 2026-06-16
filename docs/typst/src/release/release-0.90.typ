#import "/lib/trino-docs.typ": *

#anchor("doc-release-release-0-90")
= Release 0.90

#warning[
This release has a memory leak and should not be used.
]

== General

- Initial support for partition and placement awareness in the query planner. This can result in better plans for queries involving #raw("JOIN") and #raw("GROUP BY") over the same key columns.
- Improve planning of UNION queries.
- Add presto version to query creation and completion events.
- Add property #raw("task.writer-count") to configure the number of writers per task.
- Fix a bug when optimizing constant expressions involving binary types.
- Fix bug where a table writer commits partial results while cleaning up a failed query.
- Fix a bug when unnesting an array of doubles containing NaN or Infinity.
- Fix failure when accessing elements in an empty array.
- Fix #emph["Remote page is too large"] errors.
- Improve error message when attempting to cast a value to #raw("UNKNOWN").
- Update the #link(label("fn-approx-distinct"), raw("approx_distinct")) documentation with correct standard error bounds.
- Disable falling back to the interpreter when expressions fail to be compiled to bytecode. To enable this option, add #raw("compiler.interpreter-enabled=true") to the coordinator and worker config properties. Enabling this option will allow certain queries to run slowly rather than failing.
- Improve #link(label("doc-client-jdbc"))[JDBC driver] conformance. In particular, all unimplemented methods now throw #raw("SQLException") rather than #raw("UnsupportedOperationException").

== Functions and language features

- Add #link(label("fn-bool-and"), raw("bool_and")) and #link(label("fn-bool-or"), raw("bool_or")) aggregation functions.
- Add standard SQL function #link(label("fn-every"), raw("every")) as an alias for #link(label("fn-bool-and"), raw("bool_and")).
- Add #link(label("fn-year-of-week"), raw("year_of_week")) function.
- Add #link(label("fn-regexp-extract-all"), raw("regexp_extract_all")) function.
- Add #link(label("fn-map-agg"), raw("map_agg")) aggregation function.
- Add support for casting #raw("JSON") to #raw("ARRAY") or #raw("MAP") types.
- Add support for unparenthesized expressions in #raw("VALUES") clause.
- Added #link(label("doc-sql-set-session"))[SET SESSION], #link(label("doc-sql-reset-session"))[RESET SESSION] and #link(label("doc-sql-show-session"))[SHOW SESSION].
- Improve formatting of #raw("EXPLAIN (TYPE DISTRIBUTED)") output and include additional information such as output layout, task placement policy and partitioning functions.

== Hive

- Disable optimized metastore partition fetching for non-string partition keys. This fixes an issue were Presto might silently ignore data with non-canonical partition values. To enable this option, add #raw("hive.assume-canonical-partition-keys=true") to the coordinator and worker config properties.
- Don't retry operations against S3 that fail due to lack of permissions.

== SPI

- Add #raw("getColumnTypes") to #raw("RecordSink").
- Use #raw("Slice") for table writer fragments.
- Add #raw("ConnectorPageSink") which is a more efficient interface for column-oriented sources.

#note[
This is a backwards incompatible change with the previous connector SPI. If you have written a connector, you will need to update your code before deploying this release.
]
