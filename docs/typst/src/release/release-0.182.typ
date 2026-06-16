#import "/lib/trino-docs.typ": *

#anchor("doc-release-release-0-182")
= Release 0.182

== General

- Fix correctness issue that causes #link(label("fn-corr"), raw("corr")) to return positive numbers for inverse correlations.
- Fix the #link(label("doc-sql-explain"))[EXPLAIN] query plan for tables that are partitioned on #raw("TIMESTAMP") or #raw("DATE") columns.
- Fix query failure when using certain window functions that take arrays or maps as arguments \(e.g., #link(label("fn-approx-percentile"), raw("approx_percentile"))\).
- Implement subtraction for all #raw("TIME") and #raw("TIMESTAMP") types.
- Improve planning performance for queries that join multiple tables with a large number columns.
- Improve the performance of joins with only non-equality conditions by using a nested loops join instead of a hash join.
- Improve the performance of casting from #raw("JSON") to #raw("ARRAY") or #raw("MAP") types.
- Add a new #link(label("ref-ipaddress-type"))[ipaddress-type] type to represent IP addresses.
- Add #link(label("fn-to-milliseconds"), raw("to_milliseconds")) function to convert intervals \(day to second\) to milliseconds.
- Add support for column aliases in #raw("CREATE TABLE AS") statements.
- Add a config option to reject queries during cluster initialization. Queries are rejected if the active worker count is less than the #raw("query-manager.initialization-required-workers") property while the coordinator has been running for less than #raw("query-manager.initialization-timeout").
- Add #link(label("doc-connector-tpcds"))[TPC-DS connector]. This connector provides a set of schemas to support the TPC Benchmark™ DS \(TPC-DS\).

== CLI

- Fix an issue that would sometimes prevent queries from being cancelled when exiting from the pager.

== Hive

- Fix reading decimal values in the optimized Parquet reader when they are backed by the #raw("int32") or #raw("int64") types.
- Add a new experimental ORC writer implementation optimized for Presto. We have some upcoming improvements, so we recommend waiting a few releases before using this in production. The new writer can be enabled with the #raw("hive.orc.optimized-writer.enabled") configuration property or with the #raw("orc_optimized_writer_enabled") session property.
