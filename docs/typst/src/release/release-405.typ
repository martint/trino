#import "/lib/trino-docs.typ": *

#anchor("doc-release-release-405")
= Release 405 \(28 Dec 2022\)

== General

- Add Trino version to the output of #raw("EXPLAIN"). \(#issue("15317", "https://github.com/trinodb/trino/issues/15317")\)
- Add task input\/output size distribution to the output of #raw("EXPLAIN ANALYZE VERBOSE"). \(#issue("15286", "https://github.com/trinodb/trino/issues/15286")\)
- Add stage skewness warnings to the output of #raw("EXPLAIN ANALYZE"). \(#issue("15286", "https://github.com/trinodb/trino/issues/15286")\)
- Add support for #raw("ALTER COLUMN ... SET DATA TYPE") statement. \(#issue("11608", "https://github.com/trinodb/trino/issues/11608")\)
- Allow configuring a refresh interval for the database resource group manager with the #raw("resource-groups.refresh-interval") configuration property. \(#issue("14514", "https://github.com/trinodb/trino/issues/14514")\)
- Improve performance of queries that compare #raw("date") columns with #raw("timestamp(n) with time zone") literals. \(#issue("5798", "https://github.com/trinodb/trino/issues/5798")\)
- Improve performance and resource utilization when inserting into tables. \(#issue("14718", "https://github.com/trinodb/trino/issues/14718"), #issue("14874", "https://github.com/trinodb/trino/issues/14874")\)
- Improve performance for #raw("INSERT") queries when fault-tolerant execution is enabled. \(#issue("14735", "https://github.com/trinodb/trino/issues/14735")\)
- Improve planning performance for queries with many #raw("GROUP BY") clauses. \(#issue("15292", "https://github.com/trinodb/trino/issues/15292")\)
- Improve query performance for large clusters and skewed queries. \(#issue("15369", "https://github.com/trinodb/trino/issues/15369")\)
- Rename the #raw("node-scheduler.max-pending-splits-per-task") configuration property to #raw("node-scheduler.min-pending-splits-per-task"). \(#issue("15168", "https://github.com/trinodb/trino/issues/15168")\)
- Ensure that the configured number of task retries is not larger than 126. \(#issue("14459", "https://github.com/trinodb/trino/issues/14459")\)
- Fix incorrect rounding of #raw("time(n)") and #raw("time(n) with time zone") values near the top of the range of allowed values. \(#issue("15138", "https://github.com/trinodb/trino/issues/15138")\)
- Fix incorrect results for queries involving window functions without a #raw("PARTITION BY") clause followed by the evaluation of window functions with a #raw("PARTITION BY") and #raw("ORDER BY") clause. \(#issue("15203", "https://github.com/trinodb/trino/issues/15203")\)
- Fix incorrect results when adding or subtracting an #raw("interval") from a #raw("timestamp with time zone"). \(#issue("15103", "https://github.com/trinodb/trino/issues/15103")\)
- Fix potential incorrect results when joining tables on indexed and non-indexed columns at the same time. \(#issue("15334", "https://github.com/trinodb/trino/issues/15334")\)
- Fix potential failure of queries involving #raw("MATCH_RECOGNIZE"). \(#issue("15343", "https://github.com/trinodb/trino/issues/15343")\)
- Fix incorrect reporting of #raw("Projection CPU time") in the output of #raw("EXPLAIN ANALYZE VERBOSE"). \(#issue("15364", "https://github.com/trinodb/trino/issues/15364")\)
- Fix #raw("SET TIME ZONE LOCAL") to correctly reset to the initial time zone of the client session. \(#issue("15314", "https://github.com/trinodb/trino/issues/15314")\)

== Security

- Add support for string replacement as part of #link(label("ref-system-file-auth-impersonation-rules"))[impersonation rules]. \(#issue("14962", "https://github.com/trinodb/trino/issues/14962")\)
- Add support for fetching access control rules via HTTPS. \(#issue("14008", "https://github.com/trinodb/trino/issues/14008")\)
- Fix some #raw("system.metadata") tables improperly showing the names of catalogs which the user cannot access. \(#issue("14000", "https://github.com/trinodb/trino/issues/14000")\)
- Fix #raw("USE") statement improperly disclosing the names of catalogs and schemas which the user cannot access. \(#issue("14208", "https://github.com/trinodb/trino/issues/14208")\)
- Fix improper HTTP redirect after OAuth 2.0 token refresh. \(#issue("15336", "https://github.com/trinodb/trino/issues/15336")\)

== Web UI

- Display operator CPU time in the "Stage Performance" tab. \(#issue("15339", "https://github.com/trinodb/trino/issues/15339")\)

== JDBC driver

- Return correct values in #raw("NULLABLE") columns of the #raw("DatabaseMetaData.getColumns") result. \(#issue("15214", "https://github.com/trinodb/trino/issues/15214")\)

== BigQuery connector

- Improve read performance with experimental support for #link("https://arrow.apache.org/docs/")[Apache Arrow] serialization when reading from BigQuery. This can be enabled with the #raw("bigquery.experimental.arrow-serialization.enabled") catalog configuration property. \(#issue("14972", "https://github.com/trinodb/trino/issues/14972")\)
- Fix queries incorrectly executing with the project ID specified in the credentials instead of the project ID specified in the #raw("bigquery.project-id") catalog property. \(#issue("14083", "https://github.com/trinodb/trino/issues/14083")\)

== Delta Lake connector

- Add support for views. \(#issue("11609", "https://github.com/trinodb/trino/issues/11609")\)
- Add support for configuring batch size for reads on Parquet files using the #raw("parquet.max-read-block-row-count") configuration property or the #raw("parquet_max_read_block_row_count") session property. \(#issue("15474", "https://github.com/trinodb/trino/issues/15474")\)
- Improve performance and reduce storage requirements when running the #raw("vacuum") procedure on S3-compatible storage. \(#issue("15072", "https://github.com/trinodb/trino/issues/15072")\)
- Improve memory accounting for #raw("INSERT"), #raw("MERGE"), and #raw("CREATE TABLE ... AS SELECT") queries. \(#issue("14407", "https://github.com/trinodb/trino/issues/14407")\)
- Improve performance of reading Parquet files for #raw("boolean"), #raw("tinyint"), #raw("short"), #raw("int"), #raw("long"), #raw("float"), #raw("double"), #raw("short decimal"), #raw("UUID"), #raw("time"), #raw("decimal"), #raw("varchar"), and #raw("char") data types. This optimization can be disabled with the #raw("parquet.optimized-reader.enabled") catalog configuration property. \(#issue("14423", "https://github.com/trinodb/trino/issues/14423"), #issue("14667", "https://github.com/trinodb/trino/issues/14667")\)
- Improve query performance when the #raw("nulls fraction") statistic is not available for some columns. \(#issue("15132", "https://github.com/trinodb/trino/issues/15132")\)
- Improve performance when reading Parquet files. \(#issue("15257", "https://github.com/trinodb/trino/issues/15257"), #issue("15474", "https://github.com/trinodb/trino/issues/15474")\)
- Improve performance of reading Parquet files for queries with filters. \(#issue("15268", "https://github.com/trinodb/trino/issues/15268")\)
- Improve #raw("DROP TABLE") performance for tables stored on AWS S3. \(#issue("13974", "https://github.com/trinodb/trino/issues/13974")\)
- Improve performance of reading Parquet files for #raw("timestamp") and #raw("timestamp with timezone") data types. \(#issue("15204", "https://github.com/trinodb/trino/issues/15204")\)
- Improve performance of queries that read a small number of columns and queries that process tables with large Parquet row groups or ORC stripes. \(#issue("15168", "https://github.com/trinodb/trino/issues/15168")\)
- Improve stability and reduce peak memory requirements when reading from Parquet files. \(#issue("15374", "https://github.com/trinodb/trino/issues/15374")\)
- Allow registering existing table files in the metastore with the new #link(label("ref-delta-lake-register-table"))[#raw("register_table") procedure]. \(#issue("13568", "https://github.com/trinodb/trino/issues/13568")\)
- Deprecate creating a new table with existing table content. This can be re-enabled using the #raw("delta.legacy-create-table-with-existing-location.enabled") configuration property or the #raw("legacy_create_table_with_existing_location_enabled") session property. \(#issue("13568", "https://github.com/trinodb/trino/issues/13568")\)
- Fix query failure when reading Parquet files with large row groups. \(#issue("5729", "https://github.com/trinodb/trino/issues/5729")\)
- Fix #raw("DROP TABLE") leaving files behind when using managed tables stored on S3 and created by the Databricks runtime. \(#issue("13017", "https://github.com/trinodb/trino/issues/13017")\)
- Fix query failure when the path contains special characters. \(#issue("15183", "https://github.com/trinodb/trino/issues/15183")\)
- Fix potential #raw("INSERT") failure for tables stored on S3. \(#issue("15476", "https://github.com/trinodb/trino/issues/15476")\)

== Google Sheets connector

- Add support for setting a read timeout with the #raw("gsheets.read-timeout") configuration property. \(#issue("15322", "https://github.com/trinodb/trino/issues/15322")\)
- Add support for #raw("base64")-encoded credentials using the #raw("gsheets.credentials-key") configuration property. \(#issue("15477", "https://github.com/trinodb/trino/issues/15477")\)
- Rename the #raw("credentials-path") configuration property to #raw("gsheets.credentials-path"), #raw("metadata-sheet-id") to #raw("gsheets.metadata-sheet-id"), #raw("sheets-data-max-cache-size") to #raw("gsheets.max-data-cache-size"), and #raw("sheets-data-expire-after-write") to #raw("gsheets.data-cache-ttl"). \(#issue("15042", "https://github.com/trinodb/trino/issues/15042")\)

== Hive connector

- Add support for referencing nested fields in columns with the #raw("UNIONTYPE") Hive type. \(#issue("15278", "https://github.com/trinodb/trino/issues/15278")\)
- Add support for configuring batch size for reads on Parquet files using the #raw("parquet.max-read-block-row-count") configuration property or the #raw("parquet_max_read_block_row_count") session property. \(#issue("15474", "https://github.com/trinodb/trino/issues/15474")\)
- Improve memory accounting for #raw("INSERT"), #raw("MERGE"), and #raw("CREATE TABLE AS SELECT") queries. \(#issue("14407", "https://github.com/trinodb/trino/issues/14407")\)
- Improve performance of reading Parquet files for #raw("boolean"), #raw("tinyint"), #raw("short"), #raw("int"), #raw("long"), #raw("float"), #raw("double"), #raw("short decimal"), #raw("UUID"), #raw("time"), #raw("decimal"), #raw("varchar"), and #raw("char") data types. This optimization can be disabled with the #raw("parquet.optimized-reader.enabled") catalog configuration property. \(#issue("14423", "https://github.com/trinodb/trino/issues/14423"), #issue("14667", "https://github.com/trinodb/trino/issues/14667")\)
- Improve performance for queries which write data into multiple partitions. \(#issue("15241", "https://github.com/trinodb/trino/issues/15241"), #issue("15066", "https://github.com/trinodb/trino/issues/15066")\)
- Improve performance when reading Parquet files. \(#issue("15257", "https://github.com/trinodb/trino/issues/15257"), #issue("15474", "https://github.com/trinodb/trino/issues/15474")\)
- Improve performance of reading Parquet files for queries with filters. \(#issue("15268", "https://github.com/trinodb/trino/issues/15268")\)
- Improve #raw("DROP TABLE") performance for tables stored on AWS S3. \(#issue("13974", "https://github.com/trinodb/trino/issues/13974")\)
- Improve performance of reading Parquet files for #raw("timestamp") and #raw("timestamp with timezone") data types. \(#issue("15204", "https://github.com/trinodb/trino/issues/15204")\)
- Improve performance of queries that read a small number of columns and queries that process tables with large Parquet row groups or ORC stripes. \(#issue("15168", "https://github.com/trinodb/trino/issues/15168")\)
- Improve stability and reduce peak memory requirements when reading from Parquet files. \(#issue("15374", "https://github.com/trinodb/trino/issues/15374")\)
- Disallow creating transactional tables when not using the Hive metastore. \(#issue("14673", "https://github.com/trinodb/trino/issues/14673")\)
- Fix query failure when reading Parquet files with large row groups. \(#issue("5729", "https://github.com/trinodb/trino/issues/5729")\)
- Fix incorrect #raw("schema already exists") error caused by a client timeout when creating a new schema. \(#issue("15174", "https://github.com/trinodb/trino/issues/15174")\)
- Fix failure when an access denied exception happens while listing tables or views in a Glue metastore. \(#issue("14746", "https://github.com/trinodb/trino/issues/14746")\)
- Fix #raw("INSERT") failure on ORC ACID tables when Apache Hive 3.1.2 is used as a metastore. \(#issue("7310", "https://github.com/trinodb/trino/issues/7310")\)
- Fix failure when reading Hive views with #raw("char") types. \(#issue("15470", "https://github.com/trinodb/trino/issues/15470")\)
- Fix potential #raw("INSERT") failure for tables stored on S3. \(#issue("15476", "https://github.com/trinodb/trino/issues/15476")\)

== Hudi connector

- Improve performance of reading Parquet files for #raw("boolean"), #raw("tinyint"), #raw("short"), #raw("int"), #raw("long"), #raw("float"), #raw("double"), #raw("short decimal"), #raw("UUID"), #raw("time"), #raw("decimal"), #raw("varchar"), and #raw("char") data types. This optimization can be disabled with the #raw("parquet.optimized-reader.enabled") catalog configuration property. \(#issue("14423", "https://github.com/trinodb/trino/issues/14423"), #issue("14667", "https://github.com/trinodb/trino/issues/14667")\)
- Improve performance of reading Parquet files for queries with filters. \(#issue("15268", "https://github.com/trinodb/trino/issues/15268")\)
- Improve performance of reading Parquet files for #raw("timestamp") and #raw("timestamp with timezone") data types. \(#issue("15204", "https://github.com/trinodb/trino/issues/15204")\)
- Improve performance of queries that read a small number of columns and queries that process tables with large Parquet row groups or ORC stripes. \(#issue("15168", "https://github.com/trinodb/trino/issues/15168")\)
- Improve stability and reduce peak memory requirements when reading from Parquet files. \(#issue("15374", "https://github.com/trinodb/trino/issues/15374")\)
- Fix query failure when reading Parquet files with large row groups. \(#issue("5729", "https://github.com/trinodb/trino/issues/5729")\)

== Iceberg connector

- Add support for configuring batch size for reads on Parquet files using the #raw("parquet.max-read-block-row-count") configuration property or the #raw("parquet_max_read_block_row_count") session property. \(#issue("15474", "https://github.com/trinodb/trino/issues/15474")\)
- Add support for the Iceberg REST catalog. \(#issue("13294", "https://github.com/trinodb/trino/issues/13294")\)
- Improve memory accounting for #raw("INSERT"), #raw("MERGE"), and #raw("CREATE TABLE AS SELECT") queries. \(#issue("14407", "https://github.com/trinodb/trino/issues/14407")\)
- Improve performance of reading Parquet files for #raw("boolean"), #raw("tinyint"), #raw("short"), #raw("int"), #raw("long"), #raw("float"), #raw("double"), #raw("short decimal"), #raw("UUID"), #raw("time"), #raw("decimal"), #raw("varchar"), and #raw("char") data types. This optimization can be disabled with the #raw("parquet.optimized-reader.enabled") catalog configuration property. \(#issue("14423", "https://github.com/trinodb/trino/issues/14423"), #issue("14667", "https://github.com/trinodb/trino/issues/14667")\)
- Improve performance when reading Parquet files. \(#issue("15257", "https://github.com/trinodb/trino/issues/15257"), #issue("15474", "https://github.com/trinodb/trino/issues/15474")\)
- Improve performance of reading Parquet files for queries with filters. \(#issue("15268", "https://github.com/trinodb/trino/issues/15268")\)
- Improve #raw("DROP TABLE") performance for tables stored on AWS S3. \(#issue("13974", "https://github.com/trinodb/trino/issues/13974")\)
- Improve performance of reading Parquet files for #raw("timestamp") and #raw("timestamp with timezone") data types. \(#issue("15204", "https://github.com/trinodb/trino/issues/15204")\)
- Improve performance of queries that read a small number of columns and queries that process tables with large Parquet row groups or ORC stripes. \(#issue("15168", "https://github.com/trinodb/trino/issues/15168")\)
- Improve stability and reduce peak memory requirements when reading from Parquet files. \(#issue("15374", "https://github.com/trinodb/trino/issues/15374")\)
- Fix incorrect results when predicates over #raw("row") columns on Parquet files are pushed into the connector. \(#issue("15408", "https://github.com/trinodb/trino/issues/15408")\)
- Fix query failure when reading Parquet files with large row groups. \(#issue("5729", "https://github.com/trinodb/trino/issues/5729")\)
- Fix #raw("REFRESH MATERIALIZED VIEW") failure when the materialized view is based on non-Iceberg tables. \(#issue("13131", "https://github.com/trinodb/trino/issues/13131")\)
- Fix failure when an access denied exception happens while listing tables or views in a Glue metastore. \(#issue("14971", "https://github.com/trinodb/trino/issues/14971")\)
- Fix potential #raw("INSERT") failure for tables stored on S3. \(#issue("15476", "https://github.com/trinodb/trino/issues/15476")\)

== Kafka connector

- Add support for #link(label("ref-kafka-protobuf-encoding"))[Protobuf encoding]. \(#issue("14734", "https://github.com/trinodb/trino/issues/14734")\)

== MongoDB connector

- Add support for #link(label("doc-admin-fault-tolerant-execution"))[fault-tolerant execution]. \(#issue("15062", "https://github.com/trinodb/trino/issues/15062")\)
- Add support for setting a file path and password for the truststore and keystore. \(#issue("15240", "https://github.com/trinodb/trino/issues/15240")\)
- Add support for case-insensitive name-matching in the #raw("query") table function. \(#issue("15329", "https://github.com/trinodb/trino/issues/15329")\)
- Rename the #raw("mongodb.ssl.enabled") configuration property to #raw("mongodb.tls.enabled"). \(#issue("15240", "https://github.com/trinodb/trino/issues/15240")\)
- Upgrade minimum required MongoDB version to #link("https://www.mongodb.com/docs/manual/release-notes/4.2/")[4.2]. \(#issue("15062", "https://github.com/trinodb/trino/issues/15062")\)
- Delete a MongoDB field from collections when dropping a column. Previously, the connector deleted only metadata. \(#issue("15226", "https://github.com/trinodb/trino/issues/15226")\)
- Remove deprecated #raw("mongodb.seeds") and #raw("mongodb.credentials") configuration properties. \(#issue("15263", "https://github.com/trinodb/trino/issues/15263")\)
- Fix failure when an unauthorized exception happens while listing schemas or tables. \(#issue("1398", "https://github.com/trinodb/trino/issues/1398")\)
- Fix #raw("NullPointerException") when a column name contains uppercase characters in the #raw("query") table function. \(#issue("15294", "https://github.com/trinodb/trino/issues/15294")\)
- Fix potential incorrect results when the #raw("objectid") function is used more than once within a single query. \(#issue("15426", "https://github.com/trinodb/trino/issues/15426")\)

== MySQL connector

- Fix failure when the #raw("query") table function contains a #raw("WITH") clause. \(#issue("15332", "https://github.com/trinodb/trino/issues/15332")\)

== PostgreSQL connector

- Fix query failure when a #raw("FULL JOIN") is pushed down. \(#issue("14841", "https://github.com/trinodb/trino/issues/14841")\)

== Redshift connector

- Add support for aggregation, join, and #raw("ORDER BY ... LIMIT") pushdown. \(#issue("15365", "https://github.com/trinodb/trino/issues/15365")\)
- Add support for #raw("DELETE"). \(#issue("15365", "https://github.com/trinodb/trino/issues/15365")\)
- Add schema, table, and column name length checks. \(#issue("15365", "https://github.com/trinodb/trino/issues/15365")\)
- Add full type mapping for Redshift types. The previous behavior can be restored via the #raw("redshift.use-legacy-type-mapping") configuration property. \(#issue("15365", "https://github.com/trinodb/trino/issues/15365")\)

== SPI

- Remove deprecated #raw("ConnectorNodePartitioningProvider.getBucketNodeMap()") method. \(#issue("14067", "https://github.com/trinodb/trino/issues/14067")\)
- Use the #raw("MERGE") APIs in the engine to execute #raw("DELETE") and #raw("UPDATE"). Require connectors to implement #raw("beginMerge()") and related APIs. Deprecate #raw("beginDelete()"), #raw("beginUpdate()") and #raw("UpdatablePageSource"), which are unused and do not need to be implemented. \(#issue("13926", "https://github.com/trinodb/trino/issues/13926")\)
