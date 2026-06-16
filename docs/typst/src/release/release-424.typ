#import "/lib/trino-docs.typ": *

#anchor("doc-release-release-424")
= Release 424 \(17 Aug 2023\)

== General

- Reduce coordinator overhead on large clusters. \(#issue("18542", "https://github.com/trinodb/trino/issues/18542")\)
- Require the JVM default charset to be UTF-8. This can be set with the JVM command line option #raw("-Dfile.encoding=UTF-8"). \(#issue("18657", "https://github.com/trinodb/trino/issues/18657")\)

== JDBC driver

- Add the number of bytes that have been written to the query results response. \(#issue("18651", "https://github.com/trinodb/trino/issues/18651")\)

== Delta Lake connector

- Remove the legacy Parquet reader, along with the #raw("parquet.optimized-reader.enabled") and #raw("parquet.optimized-nested-reader.enabled") configuration properties. \(#issue("18639", "https://github.com/trinodb/trino/issues/18639")\)

== Hive connector

- Improve performance for line-oriented Hive formats. \(#issue("18703", "https://github.com/trinodb/trino/issues/18703")\)
- Improve performance of reading JSON files. \(#issue("18709", "https://github.com/trinodb/trino/issues/18709")\)
- Remove the legacy Parquet reader, along with the #raw("parquet.optimized-reader.enabled") and #raw("parquet.optimized-nested-reader.enabled") configuration properties. \(#issue("18639", "https://github.com/trinodb/trino/issues/18639")\)
- Fix incorrect reporting of written bytes for uncompressed text files, which prevented the #raw("target_max_file_size") session property from working. \(#issue("18701", "https://github.com/trinodb/trino/issues/18701")\)

== Hudi connector

- Remove the legacy Parquet reader, along with the #raw("parquet.optimized-reader.enabled") and #raw("parquet.optimized-nested-reader.enabled") configuration properties. \(#issue("18639", "https://github.com/trinodb/trino/issues/18639")\)

== Iceberg connector

- Add support for #raw("CASCADE") option in #raw("DROP SCHEMA") statements. \(#issue("18689", "https://github.com/trinodb/trino/issues/18689")\)
- Remove the legacy Parquet reader, along with the #raw("parquet.optimized-reader.enabled") and #raw("parquet.optimized-nested-reader.enabled") configuration properties. \(#issue("18639", "https://github.com/trinodb/trino/issues/18639")\)
- Fix potential incorrect query results when a query involves a predicate on a #raw("timestamp with time zone") column. \(#issue("18588", "https://github.com/trinodb/trino/issues/18588")\)

== Memory connector

- Add support for #raw("CASCADE") option in #raw("DROP SCHEMA") statements. \(#issue("18668", "https://github.com/trinodb/trino/issues/18668")\)

== PostgreSQL connector

- Add support for #raw("CASCADE") option in #raw("DROP SCHEMA") statements. \(#issue("18663", "https://github.com/trinodb/trino/issues/18663")\)
- Remove support for Postgres versions older than #link("https://www.postgresql.org/support/versioning/")[version 11]. \(#issue("18696", "https://github.com/trinodb/trino/issues/18696")\)

== SPI

- Introduce the #raw("getNewTableWriterScalingOptions") and #raw("getInsertWriterScalingOptions") methods to #raw("ConnectorMetadata"), which enable connectors to limit writer scaling. \(#issue("18561", "https://github.com/trinodb/trino/issues/18561")\)
