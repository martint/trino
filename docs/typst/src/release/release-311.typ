#import "/lib/trino-docs.typ": *

#anchor("doc-release-release-311")
= Release 311 \(14 May 2019\)

== General

- Fix incorrect results for aggregation query that contains a #raw("HAVING") clause but no #raw("GROUP BY") clause. \(#issue("733", "https://github.com/trinodb/trino/issues/733")\)
- Fix rare error when moving already completed query to a new memory pool. \(#issue("725", "https://github.com/trinodb/trino/issues/725")\)
- Fix leak in operator peak memory computations \(#issue("764", "https://github.com/trinodb/trino/issues/764")\)
- Improve consistency of reported query statistics. \(#issue("773", "https://github.com/trinodb/trino/issues/773")\)
- Add support for #raw("OFFSET") syntax. \(#issue("732", "https://github.com/trinodb/trino/issues/732")\)
- Print cost metrics using appropriate units in the output of #raw("EXPLAIN"). \(#issue("68", "https://github.com/trinodb/trino/issues/68")\)
- Add #link(label("fn-combinations"), raw("combinations")) function. \(#issue("714", "https://github.com/trinodb/trino/issues/714")\)

== Hive connector

- Add support for static AWS credentials for the Glue metastore. \(#issue("748", "https://github.com/trinodb/trino/issues/748")\)

== Cassandra connector

- Support collections nested in other collections. \(#issue("657", "https://github.com/trinodb/trino/issues/657")\)
- Automatically discover the Cassandra protocol version when the previously required #raw("cassandra.protocol-version") configuration property is not set. \(#issue("596", "https://github.com/trinodb/trino/issues/596")\)

== Black Hole connector

- Fix rendering of tables and columns in plans. \(#issue("728", "https://github.com/trinodb/trino/issues/728")\)
- Add table and column statistics. \(#issue("728", "https://github.com/trinodb/trino/issues/728")\)

== System connector

- Add #raw("system.metadata.table_comments") table that contains table comments. \(#issue("531", "https://github.com/trinodb/trino/issues/531")\)
