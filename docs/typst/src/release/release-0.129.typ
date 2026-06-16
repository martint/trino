#import "/lib/trino-docs.typ": *

#anchor("doc-release-release-0-129")
= Release 0.129

#warning[
There is a performance regression in this release for #raw("GROUP BY") and #raw("JOIN") queries when the length of the keys is between 16 and 31 bytes. This is fixed in #link(label("doc-release-release-0-130"))[Release 0.130].
]

== General

- Fix a planner issue that could cause queries involving #raw("OUTER JOIN") to return incorrect results.
- Some queries, particularly those using #link(label("fn-max-by"), raw("max_by")) or #link(label("fn-min-by"), raw("min_by")), now accurately reflect their true memory usage and thus appear to use more memory than before.
- Fix #link(label("doc-sql-show-session"))[SHOW SESSION] to not show hidden session properties.
- Fix hang in large queries with #raw("ORDER BY") and #raw("LIMIT").
- Fix an issue when casting empty arrays or arrays containing only #raw("NULL") to other types.
- Table property names are now properly treated as case-insensitive.
- Minor UI improvements for query detail page.
- Do not display useless stack traces for expected exceptions in verifier.
- Improve performance of queries involving #raw("UNION ALL") that write data.
- Introduce the #raw("P4HyperLogLog") type, which uses an implementation of the HyperLogLog data structure that trades off accuracy and memory requirements when handling small sets for an improvement in performance.

== JDBC driver

- Throw exception when using #link(label("doc-sql-set-session"))[SET SESSION] or #link(label("doc-sql-reset-session"))[RESET SESSION] rather than silently ignoring the command.
- The driver now properly supports non-query statements. The #raw("Statement") interface supports all variants of the #raw("execute") methods. It also supports the #raw("getUpdateCount") and #raw("getLargeUpdateCount") methods.

== CLI

- Always clear screen when canceling query with #raw("ctrl-C").
- Make client request timeout configurable.

== Network topology aware scheduling

The scheduler can now be configured to take network topology into account when scheduling splits. This is set using the #raw("node-scheduler.network-topology") config. See #link(label("doc-admin-tuning"))[Tuning Trino] for more information.

== Hive

- The S3 region is no longer automatically configured when running in EC2. To enable this feature, use #raw("hive.s3.pin-client-to-current-region=true") in your Hive catalog properties file. Enabling this feature is required to access S3 data in the China isolated region, but prevents accessing data outside the current region.
- Server-side encryption is now supported for S3. To enable this feature, use #raw("hive.s3.sse.enabled=true") in your Hive catalog properties file.
- Add support for the #raw("retention_days") table property.
- Add support for S3 #raw("EncryptionMaterialsProvider").
