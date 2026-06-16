#import "/lib/trino-docs.typ": *

#anchor("doc-release-release-364")
= Release 364 \(1 Nov 2021\)

== General

- Add support for #link(label("doc-sql-alter-materialized-view"))[#raw("ALTER MATERIALIZED VIEW ... RENAME TO ...")]. \(#issue("9492", "https://github.com/trinodb/trino/issues/9492")\)
- Improve performance of #raw("GROUP BY") with single grouping column. \(#issue("9514", "https://github.com/trinodb/trino/issues/9514")\)
- Improve performance of decimal aggregations. \(#issue("9640", "https://github.com/trinodb/trino/issues/9640")\)
- Improve performance when evaluating the #raw("WHERE") and #raw("SELECT") clause. \(#issue("9610", "https://github.com/trinodb/trino/issues/9610")\)
- Improve performance when computing the product of #raw("decimal") values with precision larger than 19. \(#issue("9744", "https://github.com/trinodb/trino/issues/9744")\)
- Improve CPU coordinator utilization. \(#issue("8650", "https://github.com/trinodb/trino/issues/8650")\)
- Remove support for the #raw("unwrap_casts") session property and #raw("optimizer.unwrap-casts") configuration option. \(#issue("9550", "https://github.com/trinodb/trino/issues/9550")\)
- Fix incorrect results for queries with nested joins and #raw("IS NOT DISTINCT FROM") join clauses. \(#issue("9805", "https://github.com/trinodb/trino/issues/9805")\)
- Fix displaying character type dynamic filter values in #raw("EXPLAIN ANALYZE"). \(#issue("9673", "https://github.com/trinodb/trino/issues/9673")\)
- Fix query failure for update operation if it has a correlated subquery. \(#issue("8286", "https://github.com/trinodb/trino/issues/8286")\)
- Fix decimal division when result is between #raw("-1") and #raw("0"). \(#issue("9696", "https://github.com/trinodb/trino/issues/9696")\)
- Fix #link(label("doc-sql-show-stats"))[#raw("SHOW STATS")] failure for a query projecting a boolean column. \(#issue("9710", "https://github.com/trinodb/trino/issues/9710")\)

== Web UI

- Improve responsiveness of Web UI when query history contains queries with long query text. \(#issue("8892", "https://github.com/trinodb/trino/issues/8892")\)

== JDBC driver

- Allow using token from existing Kerberos context. This allows the client to perform Kerberos authentication without passing the Keytab or credential cache to the driver. \(#issue("4826", "https://github.com/trinodb/trino/issues/4826")\)

== Cassandra connector

- Map Cassandra #raw("uuid") type to Trino #raw("uuid"). \(#issue("5231", "https://github.com/trinodb/trino/issues/5231")\)

== Elasticsearch connector

- Fix failure when documents contain fields of unsupported types. \(#issue("9552", "https://github.com/trinodb/trino/issues/9552")\)

== Hive connector

- Allow to skip setting permissions on new directories by setting #raw("hive.fs.new-directory-permissions=skip") in connector properties file. \(#issue("9539", "https://github.com/trinodb/trino/issues/9539")\)
- Allow translating Hive views which cast #raw("timestamp") columns to #raw("decimal"). \(#issue("9530", "https://github.com/trinodb/trino/issues/9530")\)
- Add #raw("optimize") table procedure for merging small files in non-transactional Hive table. Procedure can be executed using #raw("ALTER TABLE <table> EXECUTE optimize(file_size_threshold => ...)") syntax. \(#issue("9665", "https://github.com/trinodb/trino/issues/9665")\)
- Restrict partition overwrite on insert to auto-commit context only. \(#issue("9559", "https://github.com/trinodb/trino/issues/9559")\)
- Reject execution of #raw("CREATE TABLE") when bucketing is requested on columns with unsupported column types. Previously #raw("CREATE") was allowed but it was not possible to insert data to such a table. \(#issue("9793", "https://github.com/trinodb/trino/issues/9793")\)
- Improve performance of querying Parquet data for files containing column indexes. \(#issue("9633", "https://github.com/trinodb/trino/issues/9633")\)
- Fix Hive 1 and Hive 3 incompatibility with Parquet files containing #raw("char") or #raw("varchar") data produced by the experimental Parquet writer. Hive 2 or newer should now read such files correctly, while Hive 1.x is still known not to read them. \(#issue("9515", "https://github.com/trinodb/trino/issues/9515"), \(#issue("6377", "https://github.com/trinodb/trino/issues/6377")\)\)
- Fix #raw("ArrayIndexOutOfBoundsException") when inserting into a partitioned table with #raw("hive.target-max-file-size") set.  \(#issue("9557", "https://github.com/trinodb/trino/issues/9557")\)
- Fix reading Avro schema written by Avro 1.8.2 with non-spec-compliant default values. \(#issue("9243", "https://github.com/trinodb/trino/issues/9243")\)
- Fix failure when querying nested Parquet data if column indexes are enabled. \(#issue("9587", "https://github.com/trinodb/trino/issues/9587")\)
- Fix incorrect results when querying Parquet data. \(#issue("9587", "https://github.com/trinodb/trino/issues/9587")\)
- Fix query failure when writing to a partitioned table with target max file size set. \(#issue("9557", "https://github.com/trinodb/trino/issues/9557")\)

== Iceberg connector

- Add support for renaming materialized views. \(#issue("9492", "https://github.com/trinodb/trino/issues/9492")\)
- Create Parquet files that can be read more efficiently. \(#issue("9569", "https://github.com/trinodb/trino/issues/9569")\)
- Improve query performance when dynamic filtering can be leveraged. \(#issue("4115", "https://github.com/trinodb/trino/issues/4115")\)
- Return value with UTC zone for table partitioned on #raw("timestamp with time zone"). \(#issue("9704", "https://github.com/trinodb/trino/issues/9704")\)
- Fix data loss in case of concurrent inserts to a table. \(#issue("9583", "https://github.com/trinodb/trino/issues/9583")\)
- Fix query failure when reading from #raw("$partitions") table for a table partitioned on #raw("timestamp with time zone") or #raw("uuid") \(#issue("9703", "https://github.com/trinodb/trino/issues/9703"), #issue("9757", "https://github.com/trinodb/trino/issues/9757")\)
- Fix query failure when reading Iceberg table statistics. \(#issue("9714", "https://github.com/trinodb/trino/issues/9714")\)

== MemSQL connector

- Support reading and writing MemSQL #raw("datetime(6)") and #raw("timestamp(6)") types as Trino #raw("timestamp(6)"). \(#issue("9725", "https://github.com/trinodb/trino/issues/9725")\)

== SQL Server connector

- Fix query failure when #raw("count(*)") aggregation is pushed down to SQL Server database and the table has more than 2147483647 rows. \(#issue("9549", "https://github.com/trinodb/trino/issues/9549")\)

== SPI

- Expose which columns are covered by dynamic filters. \(#issue("9644", "https://github.com/trinodb/trino/issues/9644")\)
- Add SPI for table procedures that can process table data in a distributed manner. Table procedures can be run via #raw("ALTER TABLE ... EXECUTE ...") syntax. \(#issue("9665", "https://github.com/trinodb/trino/issues/9665")\)
