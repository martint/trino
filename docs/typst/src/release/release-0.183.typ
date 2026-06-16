#import "/lib/trino-docs.typ": *

#anchor("doc-release-release-0-183")
= Release 0.183

== General

- Fix planning failure for queries that use #raw("GROUPING") and contain aggregation expressions that require implicit coercions.
- Fix planning failure for queries that contains a non-equi left join that is semantically equivalent to an inner join.
- Fix issue where a query may have a reported memory that is higher than actual usage when an aggregation is followed by other non-trivial work in the same stage. This can lead to failures due to query memory limit, or lower cluster throughput due to perceived insufficient memory.
- Fix query failure for #raw("CHAR") functions #link(label("fn-trim"), raw("trim")), #link(label("fn-rtrim"), raw("rtrim")), and #link(label("fn-substr"), raw("substr")) when the return value would have trailing spaces under #raw("VARCHAR") semantics.
- Fix formatting in #raw("EXPLAIN ANALYZE") output.
- Improve error message when a query contains an unsupported form of correlated subquery.
- Improve performance of #raw("CAST(json_parse(...) AS ...)").
- Add #link(label("fn-map-from-entries"), raw("map_from_entries")) and #link(label("fn-map-entries"), raw("map_entries")) functions.
- Change spilling for aggregations to only occur when the cluster runs out of memory.
- Remove the #raw("experimental.operator-memory-limit-before-spill") config property and the #raw("operator_memory_limit_before_spill") session property.
- Allow configuring the amount of memory that can be used for merging spilled aggregation data from disk using the #raw("experimental.aggregation-operator-unspill-memory-limit") config property or the #raw("aggregation_operator_unspill_memory_limit") session property.

== Web UI

- Add output rows, output size, written rows and written size to query detail page.

== Hive

- Work around #link("https://issues.apache.org/jira/browse/ORC-222")[ORC-222] which results in invalid summary statistics in ORC or DWRF files when the input data contains invalid string data. Previously, this would usually cause the query to fail, but in rare cases it could cause wrong results by incorrectly skipping data based on the invalid statistics.
- Fix issue where reported memory is lower than actual usage for table columns containing string values read from ORC or DWRF files. This can lead to high GC overhead or out-of-memory crash.
- Improve error message for small ORC files that are completely corrupt or not actually ORC.
- Add predicate pushdown for the hidden column #raw("\"$path\"").

== TPC-H

- Add column statistics for schemas #raw("tiny") and #raw("sf1").

== TPC-DS

- Add column statistics for schemas #raw("tiny") and #raw("sf1").

== SPI

- Map columns or values represented with #raw("ArrayBlock") and #raw("InterleavedBlock") are no longer supported. They must be represented as #raw("MapBlock") or #raw("SingleMapBlock").
- Extend column statistics with minimal and maximal value.
- Replace #raw("nullsCount") with #raw("nullsFraction") in column statistics.
