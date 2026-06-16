#import "/lib/trino-docs.typ": *

#anchor("doc-release-release-0-193")
= Release 0.193

== General

- Fix an infinite loop during planning for queries containing non-trivial predicates.
- Fix #raw("row_number()") optimization that causes query failure or incorrect results for queries that constrain the result of #raw("row_number()") to be less than one.
- Fix failure during query planning when lambda expressions are used in #raw("UNNEST") or #raw("VALUES") clauses.
- Fix #raw("Tried to free more revocable memory than is reserved") error for queries that have spilling enabled and run in the reserved memory pool.
- Improve the performance of the #link(label("fn-st-contains"), raw("ST_Contains")) function.
- Add #link(label("fn-map-zip-with"), raw("map_zip_with")) lambda function.
- Add #link(label("fn-normal-cdf"), raw("normal_cdf")) function.
- Add #raw("SET_DIGEST") type and related functions.
- Add query stat that tracks peak total memory.
- Improve performance of queries that filter all data from a table up-front \(e.g., due to partition pruning\).
- Turn on new local scheduling algorithm by default \(see release-0.181\).
- Remove the #raw("information_schema.__internal_partitions__") table.

== Security

- Apply the authentication methods in the order they are listed in the #raw("http-server.authentication.type") configuration.

== CLI

- Fix rendering of maps of Bing tiles.
- Abort the query when the result pager exits.

== JDBC driver

- Use SSL by default for port 443.

== Hive

- Allow dropping any column in a table. Previously, dropping columns other than the last one would fail with #raw("ConcurrentModificationException").
- Correctly write files for text format tables that use non-default delimiters. Previously, they were written with the default delimiter.
- Fix reading data from S3 if the data is in a region other than #raw("us-east-1"). Previously, such queries would fail with #raw("\"The authorization header is malformed; the region 'us-east-1' is wrong; expecting '<region_name>'\""), where #raw("<region_name>") is the S3 region hosting the bucket that is queried.
- Enable #raw("SHOW PARTITIONS FROM <table> WHERE <condition>") to work for tables that have more than #raw("hive.max-partitions-per-scan") partitions as long as the specified #raw("<condition>") reduces the number of partitions to below this limit.

== Blackhole

- Do not allow creating tables in a nonexistent schema.
- Add support for #raw("CREATE SCHEMA").

== Memory connector

- Allow renaming tables across schemas. Previously, the target schema was ignored.
- Do not allow creating tables in a nonexistent schema.

== MongoDB

- Add #raw("INSERT") support. It was previously removed in 0.155.
