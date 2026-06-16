#import "/lib/trino-docs.typ": *

#anchor("doc-release-release-0-209")
= Release 0.209

== General

- Fix incorrect predicate pushdown when grouping sets contain the empty grouping set \(#issue("11296", "https://github.com/prestodb/presto/issues/11296")\).
- Fix #raw("X-Forwarded-Proto") header handling for requests to the #raw("/") path \(#issue("11168", "https://github.com/prestodb/presto/issues/11168")\).
- Fix a regression that results in execution failure when at least one of the arguments to #link(label("fn-min-by"), raw("min_by")) or #link(label("fn-max-by"), raw("max_by")) is a constant #raw("NULL").
- Fix failure when some buckets are completely filtered out during bucket-by-bucket execution.
- Fix execution failure of queries due to a planning deficiency involving complex nested joins where a join that is not eligible for bucket-by-bucket execution feeds into the build side of a join that is eligible.
- Improve numerical stability for #link(label("fn-corr"), raw("corr")), #link(label("fn-covar-samp"), raw("covar_samp")), #link(label("fn-regr-intercept"), raw("regr_intercept")), and #link(label("fn-regr-slope"), raw("regr_slope")).
- Do not include column aliases when checking column access permissions.
- Eliminate unnecessary data redistribution for scalar correlated subqueries.
- Remove table scan original constraint information from #raw("EXPLAIN") output.
- Introduce distinct error codes for global and per-node memory limit errors.
- Include statistics and cost estimates for #raw("EXPLAIN (TYPE DISTRIBUTED)") and #raw("EXPLAIN ANALYZE").
- Support equality checks for #raw("ARRAY"), #raw("MAP"), and #raw("ROW") values containing nulls.
- Improve statistics estimation and fix potential negative nulls fraction estimates for expressions that include #raw("NOT") or #raw("OR").
- Completely remove the #raw("SHOW PARTITIONS") statement.
- Add #link(label("fn-bing-tiles-around"), raw("bing_tiles_around")) variant that takes a radius.
- Add the #link(label("fn-convex-hull-agg"), raw("convex_hull_agg")) and #link(label("fn-geometry-union-agg"), raw("geometry_union_agg")) geospatial aggregation functions.
- Add #raw("(TYPE IO, FORMAT JSON)") option for #link(label("doc-sql-explain"))[EXPLAIN] that shows input tables with constraints and the output table in JSON format.
- Add Kudu connector.
- Raise required Java version to 8u151. This avoids correctness issues for map to map cast when running under some earlier JVM versions, including 8u92.

== Web UI

- Fix the kill query button on the live plan and stage performance pages.

== CLI

- Prevent spurious #emph["No route to host"] errors on macOS when using IPv6.

== JDBC driver

- Prevent spurious #emph["No route to host"] errors on macOS when using IPv6.

== Hive connector

- Fix data loss when writing bucketed sorted tables. Partitions would be missing arbitrary rows if any of the temporary files for a bucket had the same size. The #raw("numRows") partition property contained the correct number of rows and can be used to detect if this occurred.
- Fix cleanup of temporary files when writing bucketed sorted tables.
- Allow creating schemas when using #raw("file") based security.
- Reduce the number of cases where tiny ORC stripes will be written when some columns are highly dictionary compressed.
- Improve memory accounting when reading ORC files. Previously, buffer memory and object overhead was not tracked for stream readers.
- ORC struct columns are now mapped by name rather than ordinal. This correctly handles missing or extra struct fields in the ORC file.
- Add procedure #raw("system.create_empty_partition()") for creating empty partitions.

== Kafka connector

- Support Avro formatted Kafka messages.
- Support backward compatible Avro schema evolution.

== SPI

- Allow using #raw("Object") as a parameter type or return type for SQL functions when the corresponding SQL type is an unbounded generic.
