#import "/lib/trino-docs.typ": *

#anchor("doc-release-release-327")
= Release 327 \(20 Dec 2019\)

== General

- Fix join query failure when late materialization is enabled. \(#issue("2144", "https://github.com/trinodb/trino/issues/2144")\)
- Fix failure of #link(label("fn-word-stem"), raw("word_stem")) for certain inputs. \(#issue("2145", "https://github.com/trinodb/trino/issues/2145")\)
- Fix query failure when using #raw("transform_values()") inside #raw("try()") and the transformation fails for one of the rows. \(#issue("2315", "https://github.com/trinodb/trino/issues/2315")\)
- Fix potential incorrect results for aggregations involving #raw("FILTER (WHERE ...)") when the condition is a reference to a table column. \(#issue("2267", "https://github.com/trinodb/trino/issues/2267")\)
- Allow renaming views with #link(label("doc-sql-alter-view"))[ALTER VIEW]. \(#issue("1060", "https://github.com/trinodb/trino/issues/1060")\)
- Add #raw("error_type") and #raw("error_code") columns to #raw("system.runtime.queries"). \(#issue("2249", "https://github.com/trinodb/trino/issues/2249")\)
- Rename #raw("experimental.work-processor-pipelines") configuration property to #raw("experimental.late-materialization.enabled") and rename #raw("work_processor_pipelines") session property to #raw("late_materialization"). \(#issue("2275", "https://github.com/trinodb/trino/issues/2275")\)

== Security

- Allow using multiple system access controls. \(#issue("2178", "https://github.com/trinodb/trino/issues/2178")\)
- Add #link(label("doc-security-password-file"))[Password file authentication]. \(#issue("797", "https://github.com/trinodb/trino/issues/797")\)

== Hive connector

- Fix incorrect query results when reading #raw("timestamp") values from ORC files written by Hive 3.1 or later. \(#issue("2099", "https://github.com/trinodb/trino/issues/2099")\)
- Fix a CDH 5.x metastore compatibility issue resulting in failure when analyzing or inserting into a table with #raw("date") columns. \(#issue("556", "https://github.com/trinodb/trino/issues/556")\)
- Reduce number of metastore calls when fetching partitions. \(#issue("1921", "https://github.com/trinodb/trino/issues/1921")\)
- Support reading from insert-only transactional tables. \(#issue("576", "https://github.com/trinodb/trino/issues/576")\)
- Deprecate #raw("parquet.fail-on-corrupted-statistics") \(previously known as #raw("hive.parquet.fail-on-corrupted-statistics")\). Setting this configuration property to #raw("false") may hide correctness issues, leading to incorrect query results. Session property #raw("parquet_fail_with_corrupted_statistics") is deprecated as well. Both configuration and session properties will be removed in a future version. \(#issue("2129", "https://github.com/trinodb/trino/issues/2129")\)
- Improve concurrency when updating table or partition statistics. \(#issue("2154", "https://github.com/trinodb/trino/issues/2154")\)
- Add support for renaming views. \(#issue("2189", "https://github.com/trinodb/trino/issues/2189")\)
- Allow configuring the #raw("hive.orc.use-column-names") config property on a per-session basis using the #raw("orc_use_column_names") session property. \(#issue("2248", "https://github.com/trinodb/trino/issues/2248")\)

== Kudu connector

- Support predicate pushdown for the #raw("decimal") type. \(#issue("2131", "https://github.com/trinodb/trino/issues/2131")\)
- Fix column position swap for delete operations that may result in deletion of the wrong records. \(#issue("2252", "https://github.com/trinodb/trino/issues/2252")\)
- Improve predicate pushdown for queries that match a column against multiple values \(typically using the #raw("IN") operator\). \(#issue("2253", "https://github.com/trinodb/trino/issues/2253")\)

== MongoDB connector

- Add support for reading from views. \(#issue("2156", "https://github.com/trinodb/trino/issues/2156")\)

== PostgreSQL connector

- Allow converting unsupported types to #raw("VARCHAR") by setting the session property #raw("unsupported_type_handling") or configuration property #raw("unsupported-type-handling") to #raw("CONVERT_TO_VARCHAR"). \(#issue("1182", "https://github.com/trinodb/trino/issues/1182")\)

== MySQL connector

- Fix #raw("INSERT") query failure when #raw("GTID") mode is enabled. \(#issue("2251", "https://github.com/trinodb/trino/issues/2251")\)

== Elasticsearch connector

- Improve performance for queries involving equality and range filters over table columns. \(#issue("2310", "https://github.com/trinodb/trino/issues/2310")\)

== Google Sheets connector

- Fix incorrect results when listing tables in #raw("information_schema"). \(#issue("2118", "https://github.com/trinodb/trino/issues/2118")\)

== SPI

- Add #raw("executionTime") to #raw("QueryStatistics") for event listeners. \(#issue("2247", "https://github.com/trinodb/trino/issues/2247")\)
