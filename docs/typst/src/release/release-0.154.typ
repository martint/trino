#import "/lib/trino-docs.typ": *

#anchor("doc-release-release-0-154")
= Release 0.154

== General

- Fix planning issue that could cause #raw("JOIN") queries involving functions that return null on non-null input to produce incorrect results.
- Fix regression that would cause certain queries involving uncorrelated subqueries in #raw("IN") predicates to fail during planning.
- Fix potential #emph["Input symbols do not match output symbols"] error when writing to bucketed tables.
- Fix potential #emph["Requested array size exceeds VM limit"] error that triggers the JVM's #raw("OutOfMemoryError") handling.
- Improve performance of window functions with identical partitioning and ordering but different frame specifications.
- Add #raw("code-cache-collection-threshold") config which controls when Presto will attempt to force collection of the JVM code cache and reduce the default threshold to #raw("40%").
- Add support for using #raw("LIKE") with #link(label("doc-sql-create-table"))[CREATE TABLE].
- Add support for #raw("DESCRIBE INPUT") to describe the requirements for the input parameters to a prepared statement.

== Hive

- Fix handling of metastore cache TTL. With the introduction of the per-transaction cache, the cache timeout was reset after each access, which means cache entries might never expire.
