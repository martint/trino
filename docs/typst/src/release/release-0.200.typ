#import "/lib/trino-docs.typ": *

#anchor("doc-release-release-0-200")
= Release 0.200

== General

- Disable early termination of inner or right joins when the right side has zero rows. This optimization can cause indefinite query hangs for queries that join against a small number of rows. This regression was introduced in 0.199.
- Fix query execution failure for #link(label("fn-bing-tile-coordinates"), raw("bing_tile_coordinates")).
- Remove the #raw("log()") function. The arguments to the function were in the wrong order according to the SQL standard, resulting in incorrect results when queries were translated to or from other SQL implementations. The equivalent to #raw("log(x, b)") is #raw("ln(x) / ln(b)"). The function can be restored with the #raw("deprecated.legacy-log-function") config option.
- Allow including a comment when adding a column to a table with #raw("ALTER TABLE").
- Add #link(label("fn-from-ieee754-32"), raw("from_ieee754_32")) and #link(label("fn-from-ieee754-64"), raw("from_ieee754_64")) functions.
- Add #link(label("fn-st-geometrytype"), raw("ST_GeometryType")) geospatial function.

== Hive

- Fix reading min\/max statistics for columns of #raw("REAL") type in partitioned tables.
- Fix failure when reading Parquet files with optimized Parquet reader related with the predicate push down for structural types. Predicates on structural types are now ignored for Parquet files.
- Fix failure when reading ORC files that contain UTF-8 Bloom filter streams. Such Bloom filters are now ignored.

== MySQL

- Avoid reading extra rows from MySQL at query completion. This typically affects queries with a #raw("LIMIT") clause.
