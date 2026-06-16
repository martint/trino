#import "/lib/trino-docs.typ": *

#anchor("doc-release-release-0-151")
= Release 0.151

== General

- Fix issue where aggregations may produce the wrong result when #raw("task.concurrency") is set to #raw("1").
- Fix query failure when #raw("array"), #raw("map"), or #raw("row") type is used in non-equi #raw("JOIN").
- Fix performance regression for queries using #raw("OUTER JOIN").
- Fix query failure when using the #link(label("fn-arbitrary"), raw("arbitrary")) aggregation function on #raw("integer") type.
- Add various math functions that operate directly on #raw("float") type.
- Add flag #raw("deprecated.legacy-array-agg") to restore legacy #link(label("fn-array-agg"), raw("array_agg")) behavior \(ignore #raw("NULL") input\). This flag will be removed in a future release.
- Add support for uncorrelated #raw("EXISTS") clause.
- Add #link(label("fn-cosine-similarity"), raw("cosine_similarity")) function.
- Allow Tableau web connector to use catalogs other than #raw("hive").

== Verifier

- Add #raw("shadow-writes.enabled") option which can be used to transform #raw("CREATE TABLE AS SELECT") queries to write to a temporary table \(rather than the originally specified table\).

== SPI

- Remove #raw("getDataSourceName") from #raw("ConnectorSplitSource").
- Remove #raw("dataSourceName") constructor parameter from #raw("FixedSplitSource").

#note[
This is a backwards incompatible change with the previous connector SPI. If you have written a connector, you will need to update your code before deploying this release.
]
