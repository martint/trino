#import "/lib/trino-docs.typ": *

#anchor("doc-release-release-0-212")
= Release 0.212

== General

- Fix query failures when the #link(label("fn-st-geomfrombinary"), raw("ST_GeomFromBinary")) function is run on multiple rows.
- Fix memory accounting for the build side of broadcast joins.
- Fix occasional query failures when running #raw("EXPLAIN ANALYZE").
- Enhance #link(label("fn-st-convexhull"), raw("ST_ConvexHull")) and #link(label("fn-convex-hull-agg"), raw("convex_hull_agg")) functions to support geometry collections.
- Improve performance for some queries using #raw("DISTINCT").
- Improve performance for some queries that perform filtered global aggregations.
- Remove #raw("round(x, d)") and #raw("truncate(x, d)") functions where #raw("d") is a #raw("BIGINT") \(#issue("11462", "https://github.com/prestodb/presto/issues/11462")\).
- Add #link(label("fn-st-linestring"), raw("ST_LineString")) function to form a #raw("LineString") from an array of points.

== Hive connector

- Prevent ORC writer from writing stripes larger than the max configured size for some rare data patterns \(#issue("11526", "https://github.com/prestodb/presto/issues/11526")\).
- Restrict the maximum line length for text files. The default limit of 100MB can be changed using the #raw("hive.text.max-line-length") configuration property.
- Add sanity checks that fail queries if statistics read from the metastore are corrupt. Corrupt statistics can be ignored by setting the #raw("hive.ignore-corrupted-statistics") configuration property or the #raw("ignore_corrupted_statistics") session property.

== Thrift connector

- Fix retry for network errors that occur while sending a Thrift request.
- Remove failed connections from connection pool.

== Verifier

- Record the query ID of the test query regardless of query outcome.
