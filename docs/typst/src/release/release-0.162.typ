#import "/lib/trino-docs.typ": *

#anchor("doc-release-release-0-162")
= Release 0.162

#warning[
The #link(label("fn-xxhash64"), raw("xxhash64")) function introduced in this release will return a varbinary instead of a bigint in the next release.
]

== General

- Fix correctness issue when the type of the value in the #raw("IN") predicate does not match the type of the elements in the subquery.
- Fix correctness issue when the value on the left-hand side of an #raw("IN") expression or a quantified comparison is #raw("NULL").
- Fix correctness issue when the subquery of a quantified comparison produces no rows.
- Fix correctness issue due to improper inlining of TRY arguments.
- Fix correctness issue when the right side of a JOIN produces a very large number of rows.
- Fix correctness issue for expressions with multiple nested #raw("AND") and #raw("OR") conditions.
- Improve performance of window functions with similar #raw("PARTITION BY") clauses.
- Improve performance of certain multi-way JOINs by automatically choosing the best evaluation order. This feature is turned off by default and can be enabled via the #raw("reorder-joins") config option or #raw("reorder_joins") session property.
- Add #link(label("fn-xxhash64"), raw("xxhash64")) and #link(label("fn-to-big-endian-64"), raw("to_big_endian_64")) functions.
- Add aggregated operator statistics to final query statistics.
- Allow specifying column comments for #link(label("doc-sql-create-table"))[CREATE TABLE].

== Hive

- Fix performance regression when querying Hive tables with large numbers of partitions.

== SPI

- Connectors can now return optional output metadata for write operations.
- Add ability for event listeners to get connector-specific output metadata.
- Add client-supplied payload field #raw("X-Presto-Client-Info") to #raw("EventListener").
