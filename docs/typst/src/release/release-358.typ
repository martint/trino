#import "/lib/trino-docs.typ": *

#anchor("doc-release-release-358")
= Release 358 \(1 Jun 2021\)

== General

- Support arbitrary queries in #link(label("doc-sql-show-stats"))[SHOW STATS]. \(#issue("8026", "https://github.com/trinodb/trino/issues/8026")\)
- Improve performance of complex queries involving joins and #raw("TABLESAMPLE"). \(#issue("8094", "https://github.com/trinodb/trino/issues/8094")\)
- Improve performance of #raw("ORDER BY ... LIMIT") queries on sorted data. \(#issue("6634", "https://github.com/trinodb/trino/issues/6634")\)
- Reduce graceful shutdown time for worker nodes. \(#issue("8149", "https://github.com/trinodb/trino/issues/8149")\)
- Fix query failure columns of non-orderable types \(e.g. #raw("HyperLogLog"), #raw("tdigest"), etc.\), are involved in a join. \(#issue("7723", "https://github.com/trinodb/trino/issues/7723")\)
- Fix failure for queries containing repeated ordinals in a #raw("GROUP BY") clause. Example: #raw("SELECT x FROM t GROUP BY 1, 1"). \(#issue("8023", "https://github.com/trinodb/trino/issues/8023")\)
- Fix failure for queries containing repeated expressions in the #raw("ORDER BY") clause of an aggregate function. Example: #raw("SELECT array_agg(x ORDER BY y, y) FROM (VALUES ('a', 2)) t(x, y)"). \(#issue("8080", "https://github.com/trinodb/trino/issues/8080")\)

== JDBC Driver

- Remove legacy JDBC URL prefix #raw("jdbc:presto:"). \(#issue("8042", "https://github.com/trinodb/trino/issues/8042")\)
- Remove legacy driver classes #raw("io.prestosql.jdbc.PrestoDriver") and #raw("com.facebook.presto.jdbc.PrestoDriver"). \(#issue("8042", "https://github.com/trinodb/trino/issues/8042")\)

== Hive connector

- Add support for reading from Hive views that use #raw("LATERAL VIEW EXPLODE") or #raw("LATERAL VIEW OUTER EXPLODE") over array of #raw("STRUCT"). \(#issue("8120", "https://github.com/trinodb/trino/issues/8120")\)
- Improve performance of #raw("ORDER BY ... LIMIT") queries on sorted data. \(#issue("6634", "https://github.com/trinodb/trino/issues/6634")\)

== Iceberg connector

- Fix failure when listing materialized views in #raw("information_schema.tables") or via the #raw("java.sql.DatabaseMetaData.getTables()") JDBC API. \(#issue("8151", "https://github.com/trinodb/trino/issues/8151")\)

== Memory connector

- Improve performance of certain complex queries involving joins. \(#issue("8095", "https://github.com/trinodb/trino/issues/8095")\)

== SPI

- Remove deprecated #raw("ConnectorPageSourceProvider.createPageSource()") method overrides. \(#issue("8077", "https://github.com/trinodb/trino/issues/8077")\)
- Add support for casting the columns of a redirected table scan when source column types don't match. \(#issue("6066", "https://github.com/trinodb/trino/issues/6066")\)
- Add #raw("ConnectorMetadata.redirectTable()") to allow connectors to redirect table reads and metadata listings. \(#issue("7606", "https://github.com/trinodb/trino/issues/7606")\)
- Add #raw("ConnectorMetadata.streamTableColumns()") for streaming column metadata in a redirection-aware manner. The alternate method for column listing #raw("ConnectorMetadata.listTableColumns()") is now deprecated. \(#issue("7606", "https://github.com/trinodb/trino/issues/7606")\)
