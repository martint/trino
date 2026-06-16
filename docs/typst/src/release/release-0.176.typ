#import "/lib/trino-docs.typ": *

#anchor("doc-release-release-0-176")
= Release 0.176

== General

- Fix an issue where a query \(and some of its tasks\) continues to consume CPU\/memory on the coordinator and workers after the query fails.
- Fix a regression that cause the GC overhead and pauses to increase significantly when processing maps.
- Fix a memory tracking bug that causes the memory to be overestimated for #raw("GROUP BY") queries on #raw("bigint") columns.
- Improve the performance of the #link(label("fn-transform-values"), raw("transform_values")) function.
- Add support for casting from #raw("JSON") to #raw("REAL") type.
- Add #link(label("fn-parse-duration"), raw("parse_duration")) function.

== MySQL

- Disallow having a database in the #raw("connection-url") config property.

== Accumulo

- Decrease planning time by fetching index metrics in parallel.

== MongoDB

- Allow predicate pushdown for ObjectID.
