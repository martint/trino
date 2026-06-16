#import "/lib/trino-docs.typ": *

#anchor("doc-release-release-0-133")
= Release 0.133

== General

- Add support for calling connector-defined procedures using #link(label("doc-sql-call"))[CALL].
- Add #link(label("doc-connector-system"))[System connector] procedure for killing running queries.
- Properly expire idle transactions that consist of just the start transaction statement and nothing else.
- Fix possible deadlock in worker communication when task restart is detected.
- Performance improvements for aggregations on dictionary encoded data. This optimization is turned off by default. It can be configured via the #raw("optimizer.dictionary-aggregation") config property or the #raw("dictionary_aggregation") session property.
- Fix race which could cause queries to fail when using #link(label("fn-concat"), raw("concat")) on #link(label("ref-array-type"))[array-type], or when enabling #raw("columnar_processing_dictionary").
- Add sticky headers and the ability to sort the tasks table on the query page in the web interface.
