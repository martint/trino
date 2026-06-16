#import "/lib/trino-docs.typ": *

#anchor("doc-release-release-368")
= Release 368 \(11 Jan 2022\)

== General

- Allow setting per task memory limits via #raw("query.max-total-memory-per-task") config property or via #raw("query_max_total_memory_per_task") session property. \(#issue("10308", "https://github.com/trinodb/trino/issues/10308")\)
- Improve wall time for query processing with the #raw("phased") scheduling policy. The previous behavior can be restored by setting the #raw("query.execution-policy") configuration property to #raw("legacy-phased"). \(#issue("10350", "https://github.com/trinodb/trino/issues/10350")\)
- Enable #raw("phased") scheduling policy by default. The previous behavior can be restored by setting the #raw("query.execution-policy") configuration property to #raw("all-at-once"). \(#issue("10455", "https://github.com/trinodb/trino/issues/10455")\)
- Improve performance of arithmetic operations involving decimals with precision larger than 18. \(#issue("10051", "https://github.com/trinodb/trino/issues/10051")\)
- Reduce risk of out-of-memory failure on congested clusters with high memory usage. \(#issue("10475", "https://github.com/trinodb/trino/issues/10475")\)
- Fix queries not being unblocked when placed in reserved memory pool. \(#issue("10475", "https://github.com/trinodb/trino/issues/10475")\)
- Prevent execution of #raw("REFRESH MATERIALIZED VIEW") from getting stuck. \(#issue("10360", "https://github.com/trinodb/trino/issues/10360")\)
- Fix double reporting of scheduled time for scan operators in #raw("EXPLAIN ANALYZE"). \(#issue("10472", "https://github.com/trinodb/trino/issues/10472")\)
- Fix issue where the length of log file names grow indefinitely upon log rotation. \(#issue("10394", "https://github.com/trinodb/trino/issues/10394")\)

== Hive connector

- Improve performance of decoding decimal values with precision larger than 18 in ORC, Parquet and RCFile data. \(#issue("10051", "https://github.com/trinodb/trino/issues/10051")\)
- Disallow querying the properties system table for Delta Lake tables, since Delta Lake tables are not supported. This fixes the previous behavior of silently returning incorrect values. \(#issue("10447", "https://github.com/trinodb/trino/issues/10447")\)
- Reduce risk of worker out-of-memory exception when scanning ORC files. \(#issue("9949", "https://github.com/trinodb/trino/issues/9949")\)

== Iceberg connector

- Fix Iceberg table creation with location when schema location inaccessible. \(#issue("9732", "https://github.com/trinodb/trino/issues/9732")\)
- Support file based access control. \(#issue("10493", "https://github.com/trinodb/trino/issues/10493")\)
- Display the Iceberg table location in #raw("SHOW CREATE TABLE") output. \(#issue("10459", "https://github.com/trinodb/trino/issues/10459")\)

== SingleStore \(MemSQL\) connector

- Add support for #raw("time") type. \(#issue("10332", "https://github.com/trinodb/trino/issues/10332")\)

== Oracle connector

- Fix incorrect result when a #raw("date") value is older than or equal to #raw("1582-10-14"). \(#issue("10380", "https://github.com/trinodb/trino/issues/10380")\)

== Phoenix connector

- Add support for reading #raw("binary") type. \(#issue("10539", "https://github.com/trinodb/trino/issues/10539")\)

== PostgreSQL connector

- Add support for accessing tables created with declarative partitioning in PostgreSQL. \(#issue("10400", "https://github.com/trinodb/trino/issues/10400")\)

== SPI

- Encode long decimal values using two's complement representation and change their carrier type to #raw("io.trino.type.Int128") instead of #raw("io.airlift.slice.Slice"). \(#issue("10051", "https://github.com/trinodb/trino/issues/10051")\)
- Fix #raw("ClassNotFoundException") when using aggregation with a custom state type. \(#issue("10408", "https://github.com/trinodb/trino/issues/10408")\)
