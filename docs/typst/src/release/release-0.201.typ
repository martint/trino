#import "/lib/trino-docs.typ": *

#anchor("doc-release-release-0-201")
= Release 0.201

== General

- Change grouped aggregations to use #raw("IS NOT DISTINCT FROM") semantics rather than equality semantics. This fixes incorrect results and degraded performance when grouping on #raw("NaN") floating point values, and adds support for grouping on structural types that contain nulls.
- Fix planning error when column names are reused in #raw("ORDER BY") query.
- System memory pool is now unused by default and it will eventually be removed completely. All memory allocations will now be served from the general\/user memory pool. The old behavior can be restored with the #raw("deprecated.legacy-system-pool-enabled") config option.
- Improve performance and memory usage for queries using #link(label("fn-row-number"), raw("row_number")) followed by a filter on the row numbers generated.
- Improve performance and memory usage for queries using #raw("ORDER BY") followed by a #raw("LIMIT").
- Improve performance of queries that process structural types and contain joins, aggregations, or table writes.
- Add session property #raw("prefer-partial-aggregation") to allow users to disable partial aggregations for queries that do not benefit.
- Add support for #raw("current_user") \(see #link(label("doc-functions-session"))[Session information]\).

== Security

- Change rules in the #link(label("doc-security-built-in-system-access-control"))[System access control] for enforcing matches between authentication credentials and a chosen username to allow more fine-grained control and ability to define superuser-like credentials.

== Hive

- Replace ORC writer stripe minimum row configuration #raw("hive.orc.writer.stripe-min-rows") with stripe minimum data size #raw("hive.orc.writer.stripe-min-size").
- Change ORC writer validation configuration #raw("hive.orc.writer.validate") to switch to a sampling percentage #raw("hive.orc.writer.validation-percentage").
- Fix optimized ORC writer writing incorrect data of type #raw("map") or #raw("array").
- Fix #raw("SHOW PARTITIONS") and the #raw("$partitions") table for tables that have null partition values.
- Fix impersonation for the simple HDFS authentication to use login user rather than current user.

== SPI

- Support resource group selection based on resource estimates.
