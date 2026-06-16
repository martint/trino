#import "/lib/trino-docs.typ": *

#anchor("doc-release-release-350")
= Release 350 \(28 Dec 2020\)

== General

- Add HTTP client JMX metrics. \(#issue("6453", "https://github.com/trinodb/trino/issues/6453")\)
- Improve query performance by reducing worker to worker communication overhead. \(#issue("6283", "https://github.com/trinodb/trino/issues/6283"), #issue("6349", "https://github.com/trinodb/trino/issues/6349")\)
- Improve performance of queries that contain #raw("IS NOT DISTINCT FROM") join predicates. \(#issue("6404", "https://github.com/trinodb/trino/issues/6404")\)
- Fix failure when restricted columns have column masks. \(#issue("6017", "https://github.com/trinodb/trino/issues/6017")\)
- Fix failure when #raw("try") expressions reference columns that contain #raw("@") or #raw(":") in their names. \(#issue("6380", "https://github.com/trinodb/trino/issues/6380")\)
- Fix memory management config handling to use #raw("query.max-total-memory-per-node") rather than only using #raw("query.max-memory-per-node") for both values. \(#issue("6349", "https://github.com/trinodb/trino/issues/6349")\)

== Web UI

- Fix truncation of query text in cluster overview page. \(#issue("6216", "https://github.com/trinodb/trino/issues/6216")\)

== JDBC driver

- Accept #raw("java.time.OffsetTime") in #raw("PreparedStatement.setObject(int, Object)"). \(#issue("6352", "https://github.com/trinodb/trino/issues/6352")\)
- Extend #raw("PreparedStatement.setObject(int, Object, int)") to allow setting #raw("time with time zone") and #raw("timestamp with time zone") values with precision higher than nanoseconds. This can be done via providing a #raw("String") value representing a valid SQL literal. \(#issue("6352", "https://github.com/trinodb/trino/issues/6352")\)

== BigQuery connector

- Fix incorrect results for #raw("count(*)") queries with views. \(#issue("5635", "https://github.com/trinodb/trino/issues/5635")\)

== Cassandra connector

- Support #raw("DELETE") statement with primary key or partition key. \(#issue("4059", "https://github.com/trinodb/trino/issues/4059")\)

== Elasticsearch connector

- Improve query analysis performance when Elasticsearch contains many index mappings. \(#issue("6368", "https://github.com/trinodb/trino/issues/6368")\)

== Kafka connector

- Support Kafka Schema Registry for Avro topics. \(#issue("6137", "https://github.com/trinodb/trino/issues/6137")\)

== SQL Server connector

- Add #raw("data_compression") table property to control the target compression in SQL Server. The allowed values are #raw("NONE"), #raw("ROW") or #raw("PAGE"). \(#issue("4693", "https://github.com/trinodb/trino/issues/4693")\)

== Other connectors

This change applies to the MySQL, Oracle, PostgreSQL, Redshift, and SQL Server connectors.

- Send shorter and potentially more performant queries to remote database when a Presto query has a #raw("NOT IN") predicate eligible for pushdown into the connector. \(#issue("6075", "https://github.com/trinodb/trino/issues/6075")\)

== SPI

- Rename #raw("LongTimeWithTimeZone.getPicoSeconds()") to #raw("LongTimeWithTimeZone.getPicoseconds()"). \(#issue("6354", "https://github.com/trinodb/trino/issues/6354")\)
