#import "/lib/trino-docs.typ": *

#anchor("doc-release-release-0-206")
= Release 0.206

== General

- Fix execution failure for certain queries containing a join followed by an aggregation when #raw("dictionary_aggregation") is enabled.
- Fix planning failure when a query contains a #raw("GROUP BY"), but the cardinality of the grouping columns is one. For example: #raw("SELECT c1, sum(c2) FROM t WHERE c1 = 'foo' GROUP BY c1")
- Fix high memory pressure on the coordinator during the execution of queries using bucketed execution.
- Add #link(label("fn-st-union"), raw("ST_Union")), #link(label("fn-st-geometries"), raw("ST_Geometries")), #link(label("fn-st-pointn"), raw("ST_PointN")), #link(label("fn-st-interiorrings"), raw("ST_InteriorRings")), and #link(label("fn-st-interiorringn"), raw("ST_InteriorRingN")) geospatial functions.
- Add #link(label("fn-split-to-multimap"), raw("split_to_multimap")) function.
- Expand the #link(label("fn-approx-distinct"), raw("approx_distinct")) function to support the following types: #raw("INTEGER"), #raw("SMALLINT"), #raw("TINYINT"), #raw("DECIMAL"), #raw("REAL"), #raw("DATE"), #raw("TIMESTAMP"), #raw("TIMESTAMP WITH TIME ZONE"), #raw("TIME"), #raw("TIME WITH TIME ZONE"), #raw("IPADDRESS").
- Add a resource group ID column to the #raw("system.runtime.queries") table.
- Add support for executing #raw("ORDER BY") without #raw("LIMIT") in a distributed manner. This can be disabled with the #raw("distributed-sort") configuration property or the #raw("distributed_sort") session property.
- Add implicit coercion from #raw("VARCHAR(n)") to #raw("CHAR(n)"), and remove implicit coercion the other way around. As a result, comparing a #raw("CHAR") with a #raw("VARCHAR") will now follow trailing space insensitive #raw("CHAR") comparison semantics.
- Improve query cost estimation by only including non-null rows when computing average row size.
- Improve query cost estimation to better account for overhead when estimating data size.
- Add new semantics that conform to the SQL standard for temporal types. It affects the #raw("TIMESTAMP") \(aka #raw("TIMESTAMP WITHOUT TIME ZONE")\) type, #raw("TIME") \(aka #raw("TIME WITHOUT TIME ZONE")\) type, and #raw("TIME WITH TIME ZONE") type. The legacy behavior remains default. At this time, it is not recommended to enable the new semantics. For any connector that supports temporal types, code changes are required before the connector can work correctly with the new semantics. No connectors have been updated yet. In addition, the new semantics are not yet stable as more breaking changes are planned, particularly around the #raw("TIME WITH TIME ZONE") type.

== JDBC driver

- Add #raw("applicationNamePrefix") parameter, which is combined with the #raw("ApplicationName") property to construct the client source name.

== Hive connector

- Reduce ORC reader memory usage by reducing unnecessarily large internal buffers.
- Support reading from tables with #raw("skip.footer.line.count") and #raw("skip.header.line.count") when using HDFS authentication with Kerberos.
- Add support for case-insensitive column lookup for Parquet readers.
