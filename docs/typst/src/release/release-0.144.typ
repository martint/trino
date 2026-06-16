#import "/lib/trino-docs.typ": *

#anchor("doc-release-release-0-144")
= Release 0.144

#warning[
Querying bucketed tables in the Hive connector may produce incorrect results. This is fixed in #link(label("doc-release-release-0-144-1"))[Release 0.144.1], and #link(label("doc-release-release-0-145"))[Release 0.145].
]

== General

- Fix already exists check when adding a column to be case-insensitive.
- Fix correctness issue when complex grouping operations have a partitioned source.
- Fix missing coercion when using #raw("INSERT") with #raw("NULL") literals.
- Fix regression that the queries fail when aggregation functions present in #raw("AT TIME ZONE").
- Fix potential memory starvation when a query is run with #raw("resource_overcommit=true").
- Queries run with #raw("resource_overcommit=true") may now be killed before they reach #raw("query.max-memory") if the cluster is low on memory.
- Discard output stage JSON from completion event when it is very long. This limit can be configured with #raw("event.max-output-stage-size").
- Add support for #link(label("doc-sql-explain-analyze"))[EXPLAIN ANALYZE].
- Change #raw("infoUri") field of #raw("/v1/statement") to point to query HTML page instead of JSON.
- Improve performance when processing results in CLI and JDBC driver.
- Improve performance of #raw("GROUP BY") queries.

== Hive

- Fix ORC reader to actually use #raw("hive.orc.stream-buffer-size") configuration property.
- Add support for creating and inserting into bucketed tables.
