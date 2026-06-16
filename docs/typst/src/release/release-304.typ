#import "/lib/trino-docs.typ": *

#anchor("doc-release-release-304")
= Release 304 \(27 Feb 2019\)

== General

- Fix wrong results for queries involving #raw("FULL OUTER JOIN") and #raw("coalesce") expressions over the join keys. \(#issue("288", "https://github.com/trinodb/trino/issues/288")\)
- Fix failure when a column is referenced using its fully qualified form. \(#issue("250", "https://github.com/trinodb/trino/issues/250")\)
- Correctly report physical and internal network position count for operators. \(#issue("271", "https://github.com/trinodb/trino/issues/271")\)
- Improve plan stability for repeated executions of the same query. \(#issue("226", "https://github.com/trinodb/trino/issues/226")\)
- Remove deprecated #raw("datasources") configuration property. \(#issue("306", "https://github.com/trinodb/trino/issues/306")\)
- Improve error message when a query contains zero-length delimited identifiers. \(#issue("249", "https://github.com/trinodb/trino/issues/249")\)
- Avoid opening an unnecessary HTTP listener on an arbitrary port. \(#issue("239", "https://github.com/trinodb/trino/issues/239")\)
- Add experimental support for spilling for queries involving #raw("ORDER BY") or window functions. \(#issue("228", "https://github.com/trinodb/trino/issues/228")\)

== Server RPM

- Preserve modified configuration files when the RPM is uninstalled. \(#issue("267", "https://github.com/trinodb/trino/issues/267")\)

== Web UI

- Fix broken timeline view. \(#issue("283", "https://github.com/trinodb/trino/issues/283")\)
- Show data size and position count reported by connectors and by worker-to-worker data transfers in detailed query view. \(#issue("271", "https://github.com/trinodb/trino/issues/271")\)

== Hive connector

- Fix authorization failure when using SQL Standard Based Authorization mode with user identifiers that contain capital letters. \(#issue("289", "https://github.com/trinodb/trino/issues/289")\)
- Fix wrong results when filtering on the hidden #raw("$bucket") column for tables containing partitions with different bucket counts. Instead, queries will now fail in this case. \(#issue("286", "https://github.com/trinodb/trino/issues/286")\)
- Record the configured Hive time zone when writing ORC files. \(#issue("212", "https://github.com/trinodb/trino/issues/212")\)
- Use the time zone recorded in ORC files when reading timestamps. The configured Hive time zone, which was previously always used, is now used only as a default when the writer did not record the time zone. \(#issue("212", "https://github.com/trinodb/trino/issues/212")\)
- Support Parquet files written with Parquet 1.9+ that use #raw("DELTA_BINARY_PACKED") encoding with the Parquet #raw("INT64") type. \(#issue("334", "https://github.com/trinodb/trino/issues/334")\)
- Allow setting the retry policy for the Thrift metastore client using the #raw("hive.metastore.thrift.client.*") configuration properties. \(#issue("240", "https://github.com/trinodb/trino/issues/240")\)
- Reduce file system read operations when reading Parquet file footers. \(#issue("296", "https://github.com/trinodb/trino/issues/296")\)
- Allow ignoring Glacier objects in S3 rather than failing the query. This is disabled by default, as it may skip data that is expected to exist, but it can be enabled using the #raw("hive.s3.skip-glacier-objects") configuration property. \(#issue("305", "https://github.com/trinodb/trino/issues/305")\)
- Add procedure #raw("system.sync_partition_metadata()") to synchronize the partitions in the metastore with the partitions that are physically on the file system. \(#issue("223", "https://github.com/trinodb/trino/issues/223")\)
- Improve performance of ORC reader for columns that only contain nulls. \(#issue("229", "https://github.com/trinodb/trino/issues/229")\)

== PostgreSQL connector

- Map PostgreSQL #raw("json") and #raw("jsonb") types to Presto #raw("json") type. \(#issue("81", "https://github.com/trinodb/trino/issues/81")\)

== Cassandra connector

- Support queries over tables containing partitioning columns of any type. \(#issue("252", "https://github.com/trinodb/trino/issues/252")\)
- Support #raw("smallint"), #raw("tinyint") and  #raw("date") Cassandra types. \(#issue("141", "https://github.com/trinodb/trino/issues/141")\)
