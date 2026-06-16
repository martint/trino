#import "/lib/trino-docs.typ": *

#anchor("doc-release-release-379")
= Release 379 \(28 Apr 2022\)

== General

- Add #link(label("doc-connector-mariadb"))[MariaDB connector]. \(#issue("10046", "https://github.com/trinodb/trino/issues/10046")\)
- Improve performance of queries that contain #raw("JOIN") and #raw("UNION") clauses. \(#issue("11935", "https://github.com/trinodb/trino/issues/11935")\)
- Improve performance of queries that contain #raw("GROUP BY") clauses. \(#issue("12095", "https://github.com/trinodb/trino/issues/12095")\)
- Fail #raw("DROP TABLE IF EXISTS") when deleted entity is not a table. Previously the statement did not delete anything. \(#issue("11555", "https://github.com/trinodb/trino/issues/11555")\)
- Fail #raw("DROP VIEW IF EXISTS") when deleted entity is not a view. Previously the statement did not delete anything. \(#issue("11555", "https://github.com/trinodb/trino/issues/11555")\)
- Fail #raw("DROP MATERIALIZED VIEW IF EXISTS") when deleted entity is not a materialized view. Previously the statement did not delete anything. \(#issue("11555", "https://github.com/trinodb/trino/issues/11555")\)

== Web UI

- Group information about tasks by stage. \(#issue("12099", "https://github.com/trinodb/trino/issues/12099")\)
- Show aggregated statistics for failed tasks of queries that are executed with #raw("retry-policy") set to #raw("TASK"). \(#issue("12099", "https://github.com/trinodb/trino/issues/12099")\)
- Fix reporting of #raw("physical input read time"). \(#issue("12135", "https://github.com/trinodb/trino/issues/12135")\)

== Delta Lake connector

- Add support for Google Cloud Storage. \(#issue("12144", "https://github.com/trinodb/trino/issues/12144")\)
- Fix failure when reading from #raw("information_schema.columns") when non-Delta tables are present in the metastore. \(#issue("12122", "https://github.com/trinodb/trino/issues/12122")\)

== Iceberg connector

- Add support for #link(label("doc-sql-delete"))[DELETE] with arbitrary predicates. \(#issue("11886", "https://github.com/trinodb/trino/issues/11886")\)
- Improve compatibility when Glue storage properties are used. \(#issue("12164", "https://github.com/trinodb/trino/issues/12164")\)
- Prevent data loss when queries modify a table concurrently when Glue catalog is used. \(#issue("11713", "https://github.com/trinodb/trino/issues/11713")\)
- Enable commit retries when conflicts occur writing a transaction to a Hive Metastore. \(#issue("12419", "https://github.com/trinodb/trino/issues/12419")\)
- Always return the number of deleted rows for #link(label("doc-sql-delete"))[DELETE] statements. \(#issue("12055", "https://github.com/trinodb/trino/issues/12055")\)

== Pinot connector

- Add support for Pinot 0.10. \(#issue("11475", "https://github.com/trinodb/trino/issues/11475")\)

== Redis connector

- Improve performance when reading data from Redis. \(#issue("12108", "https://github.com/trinodb/trino/issues/12108")\)

== SQL Server connector

- Properly apply snapshot isolation to all connections when it is enabled. \(#issue("11662", "https://github.com/trinodb/trino/issues/11662")\)
