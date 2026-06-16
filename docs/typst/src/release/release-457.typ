#import "/lib/trino-docs.typ": *

#anchor("doc-release-release-457")
= Release 457 \(6 Sep 2024\)

== General

- Expose additional JMX metrics about resource groups, including CPU and memory usage, limits, and scheduling policy. \(#issue("22957", "https://github.com/trinodb/trino/issues/22957")\)
- Improve performance of queries involving joins when fault tolerant execution is enabled. This #link(label("doc-optimizer-adaptive-plan-optimizations"))[adaptive plan optimization] can be disabled with the #raw("fault-tolerant-execution-adaptive-join-reordering-enabled") configuration property or the #raw("fault_tolerant_execution_adaptive_join_reordering_enabled") session property. \(#issue("23046", "https://github.com/trinodb/trino/issues/23046")\)
- Improve performance for #link(label("ref-file-compression"))[LZ4, Snappy and ZSTD compression and decompression] used for #link(label("ref-fte-exchange-manager"))[exchange spooling with fault-tolerant execution]. \(#issue("22532", "https://github.com/trinodb/trino/issues/22532")\)
- #breaking-marker("../release.html#breaking-changes") Shorten the name for the Kafka event listener to #raw("kafka"). \(#issue("23308", "https://github.com/trinodb/trino/issues/23308")\)
- Extend the Kafka event listener to send split completion events. \(#issue("23065", "https://github.com/trinodb/trino/issues/23065")\)

== JDBC driver

- Publish a #link(label("ref-jdbc-installation"))[JDBC driver JAR] without bundled, third-party dependencies. \(#issue("22098", "https://github.com/trinodb/trino/issues/22098")\)

== BigQuery connector

- Fix failures with queries using table functions when #raw("parent-project-id") is defined. \(#issue("23041", "https://github.com/trinodb/trino/issues/23041")\)

== Blackhole connector

- Add support for the #raw("REPLACE") modifier as part of a #raw("CREATE TABLE") statement. \(#issue("23004", "https://github.com/trinodb/trino/issues/23004")\)

== Delta Lake connector

- Add support for creating tables with #link("https://docs.delta.io/latest/delta-deletion-vectors.html")[deletion vector]. \(#issue("22104", "https://github.com/trinodb/trino/issues/22104")\)
- Improve performance for concurrent write operations on S3 by using lock-less Delta Lake write reconciliation. \(#issue("23145", "https://github.com/trinodb/trino/issues/23145")\)
- Improve performance for #link(label("ref-file-compression"))[LZ4, Snappy, and ZSTD compression and decompression]. \(#issue("22532", "https://github.com/trinodb/trino/issues/22532")\)
- Fix SSE configuration when using S3SecurityMapping with kmsKeyId configured. \(#issue("23299", "https://github.com/trinodb/trino/issues/23299")\)

== Hive connector

- Improve performance of queries that scan a large number of partitions. \(#issue("23194", "https://github.com/trinodb/trino/issues/23194")\)
- Improve performance for #link(label("ref-file-compression"))[LZ4, Snappy, and ZSTD compression and decompression]. \(#issue("22532", "https://github.com/trinodb/trino/issues/22532")\)
- Fix OpenX JSON decoding a JSON array line that resulted in data being written to the wrong output column. \(#issue("23120", "https://github.com/trinodb/trino/issues/23120")\)

== Hudi connector

- Improve performance for #link(label("ref-file-compression"))[LZ4, Snappy, and ZSTD compression and decompression]. \(#issue("22532", "https://github.com/trinodb/trino/issues/22532")\)

== Iceberg connector

- Improve performance for #link(label("ref-file-compression"))[LZ4, Snappy, and ZSTD compression and decompression]. \(#issue("22532", "https://github.com/trinodb/trino/issues/22532")\)

== Memory connector

- Add support for renaming schemas with #raw("ALTER SCHEMA ... RENAME"). \(#issue("22659", "https://github.com/trinodb/trino/issues/22659")\)

== Prometheus connector

- Fix reading large Prometheus responses. \(#issue("23025", "https://github.com/trinodb/trino/issues/23025")\)

== SPI

- Remove the deprecated #raw("ConnectorMetadata.createView") method. \(#issue("23208", "https://github.com/trinodb/trino/issues/23208")\)
- Remove the deprecated #raw("ConnectorMetadata.beginRefreshMaterializedView") method. \(#issue("23212", "https://github.com/trinodb/trino/issues/23212")\)
- Remove the deprecated #raw("ConnectorMetadata.finishInsert") method. \(#issue("23213", "https://github.com/trinodb/trino/issues/23213")\)
- Remove the deprecated #raw("ConnectorMetadata.createTable(ConnectorSession session, ConnectorTableMetadata tableMetadata, boolean ignoreExisting)") method. \(#issue("23209", "https://github.com/trinodb/trino/issues/23209")\)
- Remove the deprecated #raw("ConnectorMetadata.beginCreateTable") method. \(#issue("23211", "https://github.com/trinodb/trino/issues/23211")\)
- Remove the deprecated #raw("ConnectorSplit.getInfo") method. \(#issue("23271", "https://github.com/trinodb/trino/issues/23271")\)
- Remove the deprecated #raw("DecimalConversions.realToShortDecimal(long value, long precision, long scale)") method. \( #issue("23275", "https://github.com/trinodb/trino/issues/23275")\)
- Remove the deprecated constructor from the #raw("ConstraintApplicationResult") class. \(#issue("23272", "https://github.com/trinodb/trino/issues/23272")\)
