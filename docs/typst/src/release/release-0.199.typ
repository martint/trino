#import "/lib/trino-docs.typ": *

#anchor("doc-release-release-0-199")
= Release 0.199

== General

- Allow users to create views for their own use when they do not have permission to grant others access to the underlying tables or views. To enable this, creation permission is now only checked at query time, not at creation time, and the query time check is skipped if the user is the owner of the view.
- Add support for spatial left join.
- Add #link(label("fn-hmac-md5"), raw("hmac_md5")), #link(label("fn-hmac-sha1"), raw("hmac_sha1")), #link(label("fn-hmac-sha256"), raw("hmac_sha256")), and #link(label("fn-hmac-sha512"), raw("hmac_sha512")) functions.
- Add #link(label("fn-array-sort"), raw("array_sort")) function that takes a lambda as a comparator.
- Add #link(label("fn-line-locate-point"), raw("line_locate_point")) geospatial function.
- Add support for #raw("ORDER BY") clause in aggregations for queries that use grouping sets.
- Add support for yielding when unspilling an aggregation.
- Expand grouped execution support to #raw("GROUP BY") and #raw("UNION ALL"), making it possible to execute aggregations with less peak memory usage.
- Change the signature of #raw("round(x, d)") and #raw("truncate(x, d)") functions so that #raw("d") is of type #raw("INTEGER"). Previously, #raw("d") could be of type #raw("BIGINT"). This behavior can be restored with the #raw("deprecated.legacy-round-n-bigint") config option or the #raw("legacy_round_n_bigint") session property.
- Accessing anonymous row fields via #raw(".field0"), #raw(".field1"), etc., is no longer allowed. This behavior can be restored with the #raw("deprecated.legacy-row-field-ordinal-access") config option or the #raw("legacy_row_field_ordinal_access") session property.
- Optimize the #link(label("fn-st-intersection"), raw("ST_Intersection")) function for rectangles aligned with coordinate axes \(e.g., polygons produced by the #link(label("fn-st-envelope"), raw("ST_Envelope")) and #link(label("fn-bing-tile-polygon"), raw("bing_tile_polygon")) functions\).
- Finish joins early when possible if one side has no rows. This happens for either side of an inner join, for the left side of a left join, and for the right side of a right join.
- Improve predicate evaluation performance during predicate pushdown in planning.
- Improve the performance of queries that use #raw("LIKE") predicates on the columns of #raw("information_schema") tables.
- Improve the performance of map-to-map cast.
- Improve the performance of #link(label("fn-st-touches"), raw("ST_Touches")), #link(label("fn-st-within"), raw("ST_Within")), #link(label("fn-st-overlaps"), raw("ST_Overlaps")), #link(label("fn-st-disjoint"), raw("ST_Disjoint")), and #link(label("fn-st-crosses"), raw("ST_Crosses")) functions.
- Improve the serialization performance of geometry values.
- Improve the performance of functions that return maps.
- Improve the performance of joins and aggregations that include map columns.

== Server RPM

- Add support for installing on machines with OpenJDK.

== Security

- Add support for authentication with JWT access token.

== JDBC driver

- Make driver compatible with Java 9+. It previously failed with #raw("IncompatibleClassChangeError").

== Hive

- Fix ORC writer failure when writing #raw("NULL") values into columns of type #raw("ROW"), #raw("MAP"),  or #raw("ARRAY").
- Fix ORC writers incorrectly writing non-null values as #raw("NULL") for all types.
- Support reading Hive partitions that have a different bucket count than the table, as long as the ratio is a power of two \(#raw("1:2^n") or #raw("2^n:1")\).
- Add support for the #raw("skip.header.line.count") table property.
- Prevent reading from tables with the #raw("skip.footer.line.count") table property.
- Partitioned tables now have a hidden system table that contains the partition values. A table named #raw("example") will have a partitions table named #raw("example$partitions"). This provides the same functionality and data as #raw("SHOW PARTITIONS").
- Partition name listings, both via the #raw("$partitions") table and using #raw("SHOW PARTITIONS"), are no longer subject to the limit defined by the #raw("hive.max-partitions-per-scan") config option.
- Allow marking partitions as offline via the #raw("presto_offline") partition property.

== Thrift connector

- Most of the config property names are different due to replacing the underlying Thrift client implementation. Please see #link(label("doc-connector-thrift"))[Thrift connector] for details on the new properties.

== SPI

- Allow connectors to provide system tables dynamically.
- Add #raw("resourceGroupId") and #raw("queryType") fields to #raw("SessionConfigurationContext").
- Simplify the constructor of #raw("RowBlock").
- #raw("Block.writePositionTo()") now closes the current entry.
- Replace the #raw("writeObject()") method in #raw("BlockBuilder") with #raw("appendStructure()").
