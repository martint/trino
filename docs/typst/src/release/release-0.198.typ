#import "/lib/trino-docs.typ": *

#anchor("doc-release-release-0-198")
= Release 0.198

== General

- Perform semantic analysis before enqueuing queries.
- Add support for selective aggregates \(#raw("FILTER")\) with #raw("DISTINCT") argument qualifiers.
- Support #raw("ESCAPE") for #raw("LIKE") predicate in #raw("SHOW SCHEMAS") and #raw("SHOW TABLES") queries.
- Parse decimal literals \(e.g. #raw("42.0")\) as #raw("DECIMAL") by default. Previously, they were parsed as #raw("DOUBLE"). This behavior can be turned off via the #raw("parse-decimal-literals-as-double") config option or the #raw("parse_decimal_literals_as_double") session property.
- Fix #raw("current_date") failure when the session time zone has a "gap" at #raw("1970-01-01 00:00:00"). The time zone #raw("America/Bahia_Banderas") is one such example.
- Add variant of #link(label("fn-sequence"), raw("sequence")) function for #raw("DATE") with an implicit one-day step increment.
- Increase the maximum number of arguments for the #link(label("fn-zip"), raw("zip")) function from 4 to 5.
- Add #link(label("fn-st-isvalid"), raw("ST_IsValid")), #link(label("fn-geometry-invalid-reason"), raw("geometry_invalid_reason")), #link(label("fn-simplify-geometry"), raw("simplify_geometry")), and #link(label("fn-great-circle-distance"), raw("great_circle_distance")) functions.
- Support #link(label("fn-min"), raw("min")) and #link(label("fn-max"), raw("max")) aggregation functions when the input type is unknown at query analysis time. In particular, this allows using the functions with #raw("NULL") literals.
- Add configuration property #raw("task.max-local-exchange-buffer-size") for setting local exchange buffer size.
- Add trace token support to the scheduler and exchange HTTP clients. Each HTTP request sent by the scheduler and exchange HTTP clients will have a "trace token" \(a unique ID\) in their headers, which will be logged in the HTTP request logs. This information can be used to correlate the requests and responses during debugging.
- Improve query performance when dynamic writer scaling is enabled.
- Improve performance of #link(label("fn-st-intersects"), raw("ST_Intersects")).
- Improve query latency when tables are known to be empty during query planning.
- Optimize #link(label("fn-array-agg"), raw("array_agg")) to avoid excessive object overhead and native memory usage with G1 GC.
- Improve performance for high-cardinality aggregations with #raw("DISTINCT") argument qualifiers. This is an experimental optimization that can be activated by disabling the #raw("use_mark_distinct") session property or the #raw("optimizer.use-mark-distinct") config option.
- Improve parallelism of queries that have an empty grouping set.
- Improve performance of join queries involving the #link(label("fn-st-distance"), raw("ST_Distance")) function.

== Resource groups

- Query Queues have been removed. Resource Groups are always enabled. The config property #raw("experimental.resource-groups-enabled") has been removed.
- Change #raw("WEIGHTED_FAIR") scheduling policy to select oldest eligible sub group of groups where utilization and share are identical.

== CLI

- The #raw("--enable-authentication") option has been removed. Kerberos authentication is automatically enabled when #raw("--krb5-remote-service-name") is specified.
- Kerberos authentication now requires HTTPS.

== Hive

- Add support for using #link("https://aws.amazon.com/glue/")[AWS Glue] as the metastore. Enable it by setting the #raw("hive.metastore") config property to #raw("glue").
- Fix a bug in the ORC writer that will write incorrect data of type #raw("VARCHAR") or #raw("VARBINARY") into files.

== JMX

- Add wildcard character #raw("*") which allows querying several MBeans with a single query.

== SPI

- Add performance statistics to query plan in #raw("QueryCompletedEvent").
- Remove #raw("Page.getBlocks()"). This call was rarely used and performed an expensive copy. Instead, use #raw("Page.getBlock(channel)") or the new helper #raw("Page.appendColumn()").
- Improve validation of #raw("ArrayBlock"), #raw("MapBlock"), and #raw("RowBlock") during construction.
