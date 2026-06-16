#import "/lib/trino-docs.typ": *

#anchor("doc-release-release-0-194")
= Release 0.194

== General

- Fix planning performance regression that can affect queries over Hive tables with many partitions.
- Fix deadlock in memory management logic introduced in the previous release.
- Add #link(label("fn-word-stem"), raw("word_stem")) function.
- Restrict #raw("n") \(number of result elements\) to 10,000 or less for #raw("min(col, n)"), #raw("max(col, n)"), #raw("min_by(col1, col2, n)"), and #raw("max_by(col1, col2, n)").
- Improve error message when a session property references an invalid catalog.
- Reduce memory usage of #link(label("fn-histogram"), raw("histogram")) aggregation function.
- Improve coordinator CPU efficiency when discovering splits.
- Include minimum and maximum values for columns in #raw("SHOW STATS").

== Web UI

- Fix previously empty peak memory display in the query details page.

== CLI

- Fix regression in CLI that makes it always print "query aborted by user" when the result is displayed with a pager, even if the query completes successfully.
- Return a non-zero exit status when an error occurs.
- Add #raw("--client-info") option for specifying client info.
- Add #raw("--ignore-errors") option to continue processing in batch mode when an error occurs.

== JDBC driver

- Allow configuring connection network timeout with #raw("setNetworkTimeout()").
- Allow setting client tags via the #raw("ClientTags") client info property.
- Expose update type via #raw("getUpdateType()") on #raw("PrestoStatement").

== Hive

- Consistently fail queries that attempt to read partitions that are offline. Previously, the query can have one of the following outcomes: fail as expected, skip those partitions and finish successfully, or hang indefinitely.
- Allow setting username used to access Hive metastore via the #raw("hive.metastore.username") config property.
- Add #raw("hive_storage_format") and #raw("respect_table_format") session properties, corresponding to the #raw("hive.storage-format") and #raw("hive.respect-table-format") config properties.
- Reduce ORC file reader memory consumption by allocating buffers lazily. Buffers are only allocated for columns that are actually accessed.

== Cassandra

- Fix failure when querying #raw("information_schema.columns") when there is no equality predicate on #raw("table_name").
