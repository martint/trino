#import "/lib/trino-docs.typ": *

#anchor("doc-release-release-0-202")
= Release 0.202

== General

- Fix correctness issue for queries involving aggregations over the result of an outer join \(#issue("10592", "https://github.com/prestodb/presto/issues/10592")\).
- Fix #link(label("fn-map"), raw("map")) to raise an error on duplicate keys rather than silently producing a corrupted map.
- Fix #link(label("fn-map-from-entries"), raw("map_from_entries")) to raise an error when input array contains a #raw("null") entry.
- Fix out-of-memory error for bucketed execution by scheduling new splits on the same worker as the recently finished one.
- Fix query failure when performing a #raw("GROUP BY") on #raw("json") or #raw("ipaddress") types.
- Fix correctness issue in #link(label("fn-line-locate-point"), raw("line_locate_point")), #link(label("fn-st-isvalid"), raw("ST_IsValid")), and #link(label("fn-geometry-invalid-reason"), raw("geometry_invalid_reason")) functions to not return values outside of the expected range.
- Fix failure in #link(label("fn-geometry-to-bing-tiles"), raw("geometry_to_bing_tiles")) and #link(label("fn-st-numpoints"), raw("ST_NumPoints")) functions when processing geometry collections.
- Fix query failure in aggregation spilling \(#issue("10587", "https://github.com/prestodb/presto/issues/10587")\).
- Remove support for #raw("SHOW PARTITIONS") statement.
- Improve support for correlated subqueries containing equality predicates.
- Improve performance of correlated #raw("EXISTS") subqueries.
- Limit the number of grouping sets in a #raw("GROUP BY") clause. The default limit is #raw("2048") and can be set via the #raw("analyzer.max-grouping-sets") configuration property or the #raw("max_grouping_sets") session property.
- Allow coercion between row types regardless of field names. Previously, a row type is coercible to another only if the field name in the source type matches the target type, or when target type has anonymous field name.
- Increase default value for #raw("experimental.filter-and-project-min-output-page-size") to #raw("500kB").
- Improve performance of equals operator on #raw("array(bigint)") and #raw("array(double)") types.
- Respect #raw("X-Forwarded-Proto") header in client protocol responses.
- Add support for column-level access control. Connectors have not yet been updated to take advantage of this support.
- Add support for correlated subqueries with correlated #raw("OR") predicates.
- Add #link(label("fn-multimap-from-entries"), raw("multimap_from_entries")) function.
- Add #link(label("fn-bing-tiles-around"), raw("bing_tiles_around")), #link(label("fn-st-numgeometries"), raw("ST_NumGeometries")), #link(label("fn-st-geometryn"), raw("ST_GeometryN")), and #link(label("fn-st-convexhull"), raw("ST_ConvexHull")) geospatial functions.
- Add #link(label("fn-wilson-interval-lower"), raw("wilson_interval_lower")) and #link(label("fn-wilson-interval-upper"), raw("wilson_interval_upper")) functions.
- Add #raw("IS DISTINCT FROM") for #raw("json") and #raw("ipaddress") type.

== Hive

- Fix optimized ORC writer encoding of #raw("TIMESTAMP") before #raw("1970-01-01").  Previously, the written value was off by one second.
- Fix query failure when a Hive bucket has no splits. This commonly happens when a predicate filters some buckets out entirely.
- Remove the #raw("hive.bucket-writing") config property.
- Add support for creating and writing bucketed sorted tables. The list of sorting columns may be specified using the #raw("sorted_by") table property. Writing to sorted tables can be disabled using the #raw("hive.sorted-writing") config property or the #raw("sorted_writing_enabled") session property. The maximum number of temporary files for can be controlled using the #raw("hive.max-sort-files-per-bucket") property.
- Collect and store basic table statistics \(#raw("rowCount"), #raw("fileCount"), #raw("rawDataSize"), #raw("totalSize")\) when writing.
- Add #raw("hive.orc.tiny-stripe-threshold") config property and #raw("orc_tiny_stripe_threshold") session property to control the stripe\/file size threshold when ORC reader decides to read multiple consecutive stripes or entire fires at once. Previously, this feature piggybacks on other properties.

== CLI

- Add peak memory usage to #raw("--debug") output.

== SPI

- Make #raw("PageSorter") and #raw("PageIndexer") supported interfaces.
