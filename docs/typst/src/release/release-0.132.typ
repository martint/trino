#import "/lib/trino-docs.typ": *

#anchor("doc-release-release-0-132")
= Release 0.132

#warning[
#link(label("fn-concat"), raw("concat")) on #link(label("ref-array-type"))[array-type], or enabling #raw("columnar_processing_dictionary") may cause queries to fail in this release. This is fixed in #link(label("doc-release-release-0-133"))[Release 0.133].
]

== General

- Fix a correctness issue that can occur when any join depends on the output of another outer join that has an inner side \(or either side for the full outer case\) for which the connector declares that it has no data during planning.
- Improve error messages for unresolved operators.
- Add support for creating constant arrays with more than 255 elements.
- Fix analyzer for queries with #raw("GROUP BY ()") such that errors are raised during analysis rather than execution.
- Add #raw("resource_overcommit") session property. This disables all memory limits for the query. Instead it may be killed at any time, if the coordinator needs to reclaim memory.
- Add support for transactional connectors.
- Add support for non-correlated scalar sub-queries.
- Add support for SQL binary literals.
- Add variant of #link(label("fn-random"), raw("random")) that produces an integer number between 0 and a specified upper bound.
- Perform bounds checks when evaluating #link(label("fn-abs"), raw("abs")).
- Improve accuracy of memory accounting for #link(label("fn-map-agg"), raw("map_agg")) and #link(label("fn-array-agg"), raw("array_agg")). These functions will now appear to use more memory than before.
- Various performance optimizations for functions operating on #link(label("ref-array-type"))[array-type].
- Add server version to web UI.

== CLI

- Fix sporadic #emph["Failed to disable interrupt character"] error after exiting pager.

== Hive

- Report metastore and namenode latency in milliseconds rather than seconds in JMX stats.
- Fix #raw("NullPointerException") when inserting a null value for a partition column.
- Improve CPU efficiency when writing data.
