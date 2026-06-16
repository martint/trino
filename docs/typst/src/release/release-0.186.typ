#import "/lib/trino-docs.typ": *

#anchor("doc-release-release-0-186")
= Release 0.186

#warning[
This release has a stability issue that may cause query failures in large deployments due to HTTP requests timing out.
]

== General

- Fix excessive GC overhead caused by map to map cast.
- Fix implicit coercions for #raw("ROW") types, allowing operations between compatible types such as #raw("ROW(INTEGER)") and #raw("ROW(BIGINT)").
- Fix issue that may cause queries containing expensive functions, such as regular expressions, to continue using CPU resources even after they are killed.
- Fix performance issue caused by redundant casts.
- Fix #link(label("fn-json-parse"), raw("json_parse")) to not ignore trailing characters. Previously, input such as #raw("[1,2]abc") would successfully parse as #raw("[1,2]").
- Fix leak in running query counter for failed queries. The counter would increment but never decrement for queries that failed before starting.
- Reduce coordinator HTTP thread usage for queries that are queued or waiting for data.
- Reduce memory usage when building data of #raw("VARCHAR") or #raw("VARBINARY") types.
- Estimate memory usage for #raw("GROUP BY") more precisely to avoid out of memory errors.
- Add queued time and elapsed time to the client protocol.
- Add #raw("query_max_execution_time") session property and #raw("query.max-execution-time") config property. Queries will be aborted after they execute for more than the specified duration.
- Add #link(label("fn-inverse-normal-cdf"), raw("inverse_normal_cdf")) function.
- Add #link(label("doc-functions-geospatial"))[Geospatial functions] including functions for processing Bing tiles.
- Add #link(label("doc-admin-spill"))[Spill to disk] for joins.
- Add #link(label("doc-connector-redshift"))[Redshift connector].

== Resource groups

- Query Queues are deprecated in favor of #link(label("doc-admin-resource-groups"))[Resource groups] and will be removed in a future release.
- Rename the #raw("maxRunning") property to #raw("hardConcurrencyLimit"). The old property name is deprecated and will be removed in a future release.
- Fail on unknown property names when loading the JSON config file.

== JDBC driver

- Allow specifying an empty password.
- Add #raw("getQueuedTimeMillis()") and #raw("getElapsedTimeMillis()") to #raw("QueryStats").

== Hive

- Fix #raw("FileSystem closed") errors when using Kerberos authentication.
- Add support for path style access to the S3 file system. This can be enabled by setting the #raw("hive.s3.path-style-access=true") config property.

== SPI

- Add an #raw("ignoreExisting") flag to #raw("ConnectorMetadata::createTable()").
- Remove the #raw("getTotalBytes()") method from #raw("RecordCursor") and #raw("ConnectorPageSource").

#note[
These are backwards incompatible changes with the previous SPI. If you have written a connector, you will need to update your code before deploying this release.
]
