#import "/lib/trino-docs.typ": *

#anchor("doc-release-release-430")
= Release 430 \(20 Oct 2023\)

== General

- Improve performance of queries with #raw("GROUP BY"). \(#issue("19302", "https://github.com/trinodb/trino/issues/19302")\)
- Fix incorrect results for queries involving #raw("ORDER BY") and window functions with ordered frames. \(#issue("19399", "https://github.com/trinodb/trino/issues/19399")\)
- Fix incorrect results for query involving an aggregation in a correlated subquery. \(#issue("19002", "https://github.com/trinodb/trino/issues/19002")\)

== Security

- Enforce authorization capability of client when receiving commands #raw("RESET") and #raw("SET") for #raw("SESSION AUTHORIZATION"). \(#issue("19217", "https://github.com/trinodb/trino/issues/19217")\)

== JDBC driver

- Add support for a #raw("timezone") parameter to set the session timezone. \(#issue("19102", "https://github.com/trinodb/trino/issues/19102")\)

== Iceberg connector

- Add an option to require filters on partition columns. This can be enabled by setting the #raw("iceberg.query-partition-filter-required") configuration property or the #raw("query_partition_filter_required") session property. \(#issue("17263", "https://github.com/trinodb/trino/issues/17263")\)
- Improve performance when reading partition columns. \(#issue("19303", "https://github.com/trinodb/trino/issues/19303")\)

== Ignite connector

- Fix failure when a query contains #raw("LIKE") with #raw("ESCAPE"). \(#issue("19464", "https://github.com/trinodb/trino/issues/19464")\)

== MariaDB connector

- Add support for table statistics. \(#issue("19408", "https://github.com/trinodb/trino/issues/19408")\)

== MongoDB connector

- Fix incorrect results when a query contains several #raw("<>") or #raw("NOT IN") predicates. \(#issue("19404", "https://github.com/trinodb/trino/issues/19404")\)

== SPI

- Change the Java stack type for a #raw("map") value to #raw("SqlMap") and a #raw("row") value to #raw("SqlRow"), which do not implement #raw("Block"). \(#issue("18948", "https://github.com/trinodb/trino/issues/18948")\)
