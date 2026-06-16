#import "/lib/trino-docs.typ": *

#anchor("doc-release-release-0-126")
= Release 0.126

== General

- Add error location information \(line and column number\) for semantic errors.
- Fix a CLI crash during tab-completion when no schema is currently selected.
- Fix reset of session properties in CLI when running #link(label("doc-sql-use"))[USE].
- Fix occasional query planning failure due to a bug in the projection push down optimizer.
- Fix a parsing issue when expressions contain the form #raw("POSITION(x in (y))").
- Add a new version of #link(label("fn-approx-percentile"), raw("approx_percentile")) that takes an #raw("accuracy") parameter.
- Allow specifying columns names in #link(label("doc-sql-insert"))[INSERT] queries.
- Add #raw("field_length") table property to blackhole connector to control the size of generated #raw("VARCHAR") and #raw("VARBINARY") fields.
- Bundle Teradata functions plugin in server package.
- Improve handling of physical properties which can increase performance for queries involving window functions.
- Add ability to control whether index join lookups and caching are shared within a task. This allows us to optimize for index cache hits or for more CPU parallelism. This option is toggled by the #raw("task.share-index-loading") config property or the #raw("task_share_index_loading") session property.
- Add Tableau web connector.
- Improve performance of queries that use an #raw("IN") expression with a large list of constant values.
- Enable connector predicate push down for all comparable and equatable types.
- Fix query planning failure when using certain operations such as #raw("GROUP BY"), #raw("DISTINCT"), etc. on the output columns of #raw("UNNEST").
- In #raw("ExchangeClient") set #raw("maxResponseSize") to be slightly smaller than the configured value. This reduces the possibility of encountering #raw("PageTooLargeException").
- Fix memory leak in coordinator.
- Add validation for names of table properties.

== Hive

- Fix reading structural types containing nulls in Parquet.
- Fix writing DATE type when timezone offset is negative. Previous versions would write the wrong date \(off by one day\).
- Fix an issue where #raw("VARCHAR") columns added to an existing table could not be queried.
- Fix over-creation of initial splits.
- Fix #raw("hive.immutable-partitions") config property to also apply to unpartitioned tables.
- Allow non-#raw("VARCHAR") columns in #raw("DELETE") query.
- Support #raw("DATE") columns as partition columns in parquet tables.
- Improve error message for cases where partition columns are also table columns.
