#import "/lib/trino-docs.typ": *

#anchor("doc-release-release-415")
= Release 415 \(28 Apr 2023\)

== General

- Improve performance of aggregations with variable file sizes. \(#issue("11361", "https://github.com/trinodb/trino/issues/11361")\)
- Perform missing permission checks for table arguments to table functions. \(#issue("17279", "https://github.com/trinodb/trino/issues/17279")\)

== Web UI

- Add CPU planning time to the query details page. \(#issue("15318", "https://github.com/trinodb/trino/issues/15318")\)

== Delta Lake connector

- Add support for commenting on tables and columns with an #raw("id") and #raw("name") column mapping mode. \(#issue("17139", "https://github.com/trinodb/trino/issues/17139")\)
- Add support for #raw("BETWEEN") predicates in table check constraints. \(#issue("17120", "https://github.com/trinodb/trino/issues/17120")\)

== Hive connector

- Improve performance of queries with selective filters on primitive fields in #raw("row") columns. \(#issue("15163", "https://github.com/trinodb/trino/issues/15163")\)

== Iceberg connector

- Improve performance of queries with filters when Bloom filter indexes are present in Parquet files. \(#issue("17192", "https://github.com/trinodb/trino/issues/17192")\)
- Fix failure when trying to use #raw("DROP TABLE") on a corrupted table. \(#issue("12318", "https://github.com/trinodb/trino/issues/12318")\)

== Kafka connector

- Add support for Protobuf #raw("oneof") types when using the Confluent table description provider. \(#issue("16836", "https://github.com/trinodb/trino/issues/16836")\)

== SPI

- Expose #raw("planningCpuTime") in #raw("QueryStatistics"). \(#issue("15318", "https://github.com/trinodb/trino/issues/15318")\)
