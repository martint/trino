#import "/lib/trino-docs.typ": *

#anchor("doc-release-release-0-190")
= Release 0.190

== General

- Fix correctness issue for #link(label("fn-array-min"), raw("array_min")) and #link(label("fn-array-max"), raw("array_max")) when arrays contain #raw("NaN").
- Fix planning failure for queries involving #raw("GROUPING") that require implicit coercions in expressions containing aggregate functions.
- Fix potential workload imbalance when using topology-aware scheduling.
- Fix performance regression for queries containing #raw("DISTINCT") aggregates over the same column.
- Fix a memory leak that occurs on workers.
- Improve error handling when a #raw("HAVING") clause contains window functions.
- Avoid unnecessary data redistribution when writing when the target table has the same partition property as the data being written.
- Ignore case when sorting the output of #raw("SHOW FUNCTIONS").
- Improve rendering of the #raw("BingTile") type.
- The #link(label("fn-approx-distinct"), raw("approx_distinct")) function now supports a standard error in the range of #raw("[0.0040625, 0.26000]").
- Add support for #raw("ORDER BY") in aggregation functions.
- Add dictionary processing for joins which can improve join performance up to 50%. This optimization can be disabled using the #raw("dictionary-processing-joins-enabled") config property or the #raw("dictionary_processing_join") session property.
- Add support for casting to #raw("INTERVAL") types.
- Add #link(label("fn-st-buffer"), raw("ST_Buffer")) geospatial function.
- Allow treating decimal literals as values of the #raw("DECIMAL") type rather than #raw("DOUBLE"). This behavior can be enabled by setting the #raw("parse-decimal-literals-as-double") config property or the #raw("parse_decimal_literals_as_double") session property to #raw("false").
- Add JMX counter to track the number of submitted queries.

== Resource groups

- Add priority column to the DB resource group selectors.
- Add exact match source selector to the DB resource group selectors.

== CLI

- Add support for setting client tags.

== JDBC driver

- Add #raw("getPeakMemoryBytes()") to #raw("QueryStats").

== Accumulo

- Improve table scan parallelism.

== Hive

- Fix query failures for the file-based metastore implementation when partition column values contain a colon.
- Improve performance for writing to bucketed tables when the data being written is already partitioned appropriately \(e.g., the output is from a bucketed join\).
- Add config property #raw("hive.max-outstanding-splits-size") for the maximum amount of memory used to buffer splits for a single table scan. Additionally, the default value is substantially higher than the previous hard-coded limit, which can prevent certain queries from failing.

== Thrift connector

- Make Thrift retry configurable.
- Add JMX counters for Thrift requests.

== SPI

- Remove the #raw("RecordSink") interface, which was difficult to use correctly and had no advantages over the #raw("PageSink") interface.

#note[
This is a backwards incompatible change with the previous connector SPI. If you have written a connector that uses the #raw("RecordSink") interface, you will need to update your code before deploying this release.
]
