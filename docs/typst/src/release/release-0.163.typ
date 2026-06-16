#import "/lib/trino-docs.typ": *

#anchor("doc-release-release-0-163")
= Release 0.163

== General

- Fix data corruption when transporting dictionary-encoded data.
- Fix potential deadlock when resource groups are configured with memory limits.
- Improve performance for #raw("OUTER JOIN") queries.
- Improve exchange performance by reading from buffers in parallel.
- Improve performance when only a subset of the columns resulting from a #raw("JOIN") are referenced.
- Make #raw("ALL"), #raw("SOME") and #raw("ANY") non-reserved keywords.
- Add #link(label("fn-from-big-endian-64"), raw("from_big_endian_64")) function.
- Change #link(label("fn-xxhash64"), raw("xxhash64")) return type from #raw("BIGINT") to #raw("VARBINARY").
- Change subscript operator for map types to fail if the key is not present in the map. The former behavior \(returning #raw("NULL")\) can be restored by setting the #raw("deprecated.legacy-map-subscript") config option.
- Improve #raw("EXPLAIN ANALYZE") to render stats more accurately and to include input statistics.
- Improve tolerance to communication errors for long running queries. This can be adjusted with the #raw("query.remote-task.max-error-duration") config option.

== Accumulo

- Fix issue that could cause incorrect results for large rows.

== MongoDB

- Fix NullPointerException when a field contains a null.

== Cassandra

- Add support for #raw("VARBINARY"), #raw("TIMESTAMP") and #raw("REAL") data types.

== Hive

- Fix issue that would prevent predicates from being pushed into Parquet reader.
- Fix Hive metastore user permissions caching when tables are dropped or renamed.
- Add experimental file based metastore which stores information in HDFS or S3 instead of a database.
