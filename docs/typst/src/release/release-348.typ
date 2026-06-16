#import "/lib/trino-docs.typ": *

#anchor("doc-release-release-348")
= Release 348 \(14 Dec 2020\)

== General

- Add support for #raw("DISTINCT") clause in aggregations within correlated subqueries. \(#issue("5904", "https://github.com/trinodb/trino/issues/5904")\)
- Support #raw("SHOW STATS") for arbitrary queries. \(#issue("3109", "https://github.com/trinodb/trino/issues/3109")\)
- Improve query performance by reducing worker to worker communication overhead. \(#issue("6126", "https://github.com/trinodb/trino/issues/6126")\)
- Improve performance of #raw("ORDER BY ... LIMIT") queries. \(#issue("6072", "https://github.com/trinodb/trino/issues/6072")\)
- Reduce memory pressure and improve performance of queries involving joins. \(#issue("6176", "https://github.com/trinodb/trino/issues/6176")\)
- Fix #raw("EXPLAIN ANALYZE") for certain queries that contain broadcast join. \(#issue("6115", "https://github.com/trinodb/trino/issues/6115")\)
- Fix planning failures for queries that contain outer joins and aggregations using #raw("FILTER (WHERE <condition>)") syntax. \(#issue("6141", "https://github.com/trinodb/trino/issues/6141")\)
- Fix incorrect results when correlated subquery in join contains aggregation functions such as #raw("array_agg") or #raw("checksum"). \(#issue("6145", "https://github.com/trinodb/trino/issues/6145")\)
- Fix incorrect query results when using #raw("timestamp with time zone") constants with precision higher than 3 describing same point in time but in different zones. \(#issue("6318", "https://github.com/trinodb/trino/issues/6318")\)
- Fix duplicate query completion events if query fails early. \(#issue("6103", "https://github.com/trinodb/trino/issues/6103")\)
- Fix query failure when views are accessed and current session does not specify default schema and catalog. \(#issue("6294", "https://github.com/trinodb/trino/issues/6294")\)

== Web UI

- Add support for OAuth2 authorization. \(#issue("5355", "https://github.com/trinodb/trino/issues/5355")\)
- Fix invalid operator stats in Stage Performance view. \(#issue("6114", "https://github.com/trinodb/trino/issues/6114")\)

== JDBC driver

- Allow reading #raw("timestamp with time zone") value as #raw("ZonedDateTime") using #raw("ResultSet.getObject(int column, Class<?> type)") method. \(#issue("307", "https://github.com/trinodb/trino/issues/307")\)
- Accept #raw("java.time.LocalDate") in #raw("PreparedStatement.setObject(int, Object)"). \(#issue("6301", "https://github.com/trinodb/trino/issues/6301")\)
- Extend #raw("PreparedStatement.setObject(int, Object, int)") to allow setting #raw("time") and #raw("timestamp") values with precision higher than nanoseconds. \(#issue("6300", "https://github.com/trinodb/trino/issues/6300")\) This can be done via providing a #raw("String") value representing a valid SQL literal.
- Change representation of a #raw("row") value. #raw("ResultSet.getObject") now returns an instance of #raw("io.prestosql.jdbc.Row") class, which better represents the returned value. Previously a #raw("row") value was represented as a #raw("Map") instance, with unnamed fields being named like #raw("field0"), #raw("field1"), etc. You can access the previous behavior by invoking #raw("getObject(column, Map.class)") on the #raw("ResultSet") object. \(#issue("4588", "https://github.com/trinodb/trino/issues/4588")\)
- Represent #raw("varbinary") value using hex string representation in #raw("ResultSet.getString"). Previously the return value was useless, similar to #raw("\"B@2de82bf8\""). \(#issue("6247", "https://github.com/trinodb/trino/issues/6247")\)
- Report precision of the #raw("time(p)"), #raw("time(p) with time zone"),  #raw("timestamp(p)") and #raw("timestamp(p) with time zone") in the #raw("DECIMAL_DIGITS") column in the result set returned from #raw("DatabaseMetaData#getColumns"). \(#issue("6307", "https://github.com/trinodb/trino/issues/6307")\)
- Fix the value of the #raw("DATA_TYPE") column for #raw("time(p)") and #raw("time(p) with time zone") in the result set returned from #raw("DatabaseMetaData#getColumns").  \(#issue("6307", "https://github.com/trinodb/trino/issues/6307")\)
- Fix failure when reading a #raw("timestamp") or #raw("timestamp with time zone") value with seconds fraction greater than or equal to 999999999500 picoseconds. \(#issue("6147", "https://github.com/trinodb/trino/issues/6147")\)
- Fix failure when reading a #raw("time") value with seconds fraction greater than or equal to 999999999500 picoseconds. \(#issue("6204", "https://github.com/trinodb/trino/issues/6204")\)
- Fix element representation in arrays returned from #raw("ResultSet.getArray"), making it consistent with #raw("ResultSet.getObject"). Previously the elements were represented using internal client representation \(e.g. #raw("String")\). \(#issue("6048", "https://github.com/trinodb/trino/issues/6048")\)
- Fix #raw("ResultSetMetaData.getColumnType") for #raw("timestamp with time zone"). Previously the type was miscategorized as #raw("java.sql.Types.TIMESTAMP"). \(#issue("6251", "https://github.com/trinodb/trino/issues/6251")\)
- Fix #raw("ResultSetMetaData.getColumnType") for #raw("time with time zone"). Previously the type was miscategorized as #raw("java.sql.Types.TIME"). \(#issue("6251", "https://github.com/trinodb/trino/issues/6251")\)
- Fix failure when an instance of #raw("SphericalGeography") geospatial type is returned in the #raw("ResultSet"). \(#issue("6240", "https://github.com/trinodb/trino/issues/6240")\)

== CLI

- Fix rendering of #raw("row") values with unnamed fields. Previously they were printed using fake field names like #raw("field0"), #raw("field1"), etc. \(#issue("4587", "https://github.com/trinodb/trino/issues/4587")\)
- Fix query progress reporting. \(#issue("6119", "https://github.com/trinodb/trino/issues/6119")\)
- Fix failure when an instance of #raw("SphericalGeography") geospatial type is returned to the client. \(#issue("6238", "https://github.com/trinodb/trino/issues/6238")\)

== Hive connector

- Allow configuring S3 endpoint in security mapping. \(#issue("3869", "https://github.com/trinodb/trino/issues/3869")\)
- Add support for S3 streaming uploads. Data is uploaded to S3 as it is written, rather than staged to a local temporary file. This feature is disabled by default, and can be enabled using the #raw("hive.s3.streaming.enabled") configuration property. \(#issue("3712", "https://github.com/trinodb/trino/issues/3712"), #issue("6201", "https://github.com/trinodb/trino/issues/6201")\)
- Reduce load on metastore when background cache refresh is enabled. \(#issue("6101", "https://github.com/trinodb/trino/issues/6101"), #issue("6156", "https://github.com/trinodb/trino/issues/6156")\)
- Verify that data is in the correct bucket file when reading bucketed tables. This is enabled by default, as incorrect bucketing can cause incorrect query results, but can be disabled using the #raw("hive.validate-bucketing") configuration property or the #raw("validate_bucketing") session property. \(#issue("6012", "https://github.com/trinodb/trino/issues/6012")\)
- Allow fallback to legacy Hive view translation logic via #raw("hive.legacy-hive-view-translation") config property or #raw("legacy_hive_view_translation") session property. \(#issue("6195 ", "https://github.com/trinodb/trino/issues/6195 ")\)
- Add deserializer class name to split information exposed to the event listener. \(#issue("6006", "https://github.com/trinodb/trino/issues/6006")\)
- Improve performance when querying tables that contain symlinks. \(#issue("6158", "https://github.com/trinodb/trino/issues/6158"), #issue("6213", "https://github.com/trinodb/trino/issues/6213")\)

== Iceberg connector

- Improve performance of queries containing filters on non-partition columns. Such filters are now used for optimizing split generation and table scan.  \(#issue("4932", "https://github.com/trinodb/trino/issues/4932")\)
- Add support for Google Cloud Storage and Azure Storage. \(#issue("6186", "https://github.com/trinodb/trino/issues/6186")\)

== Kafka connector

- Allow writing #raw("timestamp with time zone") values into columns using #raw("milliseconds-since-epoch") or #raw("seconds-since-epoch") JSON encoders. \(#issue("6074", "https://github.com/trinodb/trino/issues/6074")\)

== Other connectors

- Fix ineffective table metadata caching for PostgreSQL, MySQL, SQL Server, Redshift, MemSQL and Phoenix connectors. \(#issue("6081", "https://github.com/trinodb/trino/issues/6081"), #issue("6167", "https://github.com/trinodb/trino/issues/6167")\)

== SPI

- Change #raw("SystemAccessControl#filterColumns") and #raw("ConnectorAccessControl#filterColumns") methods to accept a set of column names, and return a set of visible column names. \(#issue("6084", "https://github.com/trinodb/trino/issues/6084")\)
- Expose catalog names corresponding to the splits through the split completion event of the event listener. \(#issue("6006", "https://github.com/trinodb/trino/issues/6006")\)
