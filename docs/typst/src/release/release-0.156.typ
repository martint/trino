#import "/lib/trino-docs.typ": *

#anchor("doc-release-release-0-156")
= Release 0.156

#warning[
Query may incorrectly produce #raw("NULL") when no row qualifies for the aggregation if the #raw("optimize_mixed_distinct_aggregations") session property or the #raw("optimizer.optimize-mixed-distinct-aggregations") config option is enabled.
]

== General

- Fix potential correctness issue in queries that contain correlated scalar aggregation subqueries.
- Fix query failure when using #raw("AT TIME ZONE") in #raw("VALUES") list.
- Add support for quantified comparison predicates: #raw("ALL"), #raw("ANY"), and #raw("SOME").
- Add support for #link(label("ref-array-type"))[array-type] and #link(label("ref-row-type"))[row-type] that contain #raw("NULL") in #link(label("fn-checksum"), raw("checksum")) aggregation.
- Add support for filtered aggregations. Example: #raw("SELECT sum(a) FILTER (WHERE b > 0) FROM ...")
- Add a variant of #link(label("fn-from-unixtime"), raw("from_unixtime")) function that takes a timezone argument.
- Improve performance of #raw("GROUP BY") queries that compute a mix of distinct and non-distinct aggregations. This optimization can be turned on by setting the #raw("optimizer.optimize-mixed-distinct-aggregations") configuration option or via the #raw("optimize_mixed_distinct_aggregations") session property.
- Change default task concurrency to 16.

== Hive

- Add support for legacy RCFile header version in new RCFile reader.

== Redis

- Support #raw("iso8601") data format for the #raw("hash") row decoder.

== SPI

- Make #raw("ConnectorPageSink#finish()") asynchronous.

#note[
These are backwards incompatible changes with the previous SPI. If you have written a plugin, you will need to update your code before deploying this release.
]
