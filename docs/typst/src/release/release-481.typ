#import "/lib/trino-docs.typ": *

#anchor("doc-release-release-481")
= Release 481 \(11 May 2026\)

== General

- Add support for casting #raw("boolean") to #raw("number"). \(#issue("28879", "https://github.com/trinodb/trino/issues/28879")\)
- Add support for the #raw("number") type in Python UDFs. \(#issue("28921", "https://github.com/trinodb/trino/issues/28921")\)
- Add support for casting between #raw("number") and #raw("json"). \(#issue("28394", "https://github.com/trinodb/trino/issues/28394")\)
- Improve performance of #link(label("ref-json-value"))[json\_value] and #link(label("ref-json-table"))[json\_table] by evaluating #raw("ON EMPTY") and #raw("ON ERROR") clauses lazily. \(#issue("28969", "https://github.com/trinodb/trino/issues/28969")\)
- Add support for #raw("DESCRIBE OUTPUT") with inline queries, allowing direct description of query results without requiring a #raw("PREPARE") statement. For example, #raw("DESCRIBE OUTPUT (SELECT * FROM nation)"). \(#issue("28002", "https://github.com/trinodb/trino/issues/28002")\)
- Add support for the #raw("NEAREST") clause for approximate matches in joins. \(#issue("21759", "https://github.com/trinodb/trino/issues/21759")\)
- Add support for binding parameters in #raw("WITH SESSION"), #raw("SET SESSION"), and #raw("CALL") statements. \(#issue("29053", "https://github.com/trinodb/trino/issues/29053")\)
- Add support for persisting external authentication tokens to disk \(in #raw("~/.trino/")\), allowing reuse across separate JDBC client processes. Set #raw("externalAuthenticationTokenCache=SYSTEM") to enable. \(#issue("28783", "https://github.com/trinodb/trino/issues/28783")\)
- Include connector split source metrics in #raw("io.trino.spi.eventlistener.QueryInputMetadata#connectorMetrics"). \(#issue("28870", "https://github.com/trinodb/trino/issues/28870")\)
- Replace the Esri geometry library with JTS to improve interoperability with the broader spatial ecosystem. \(#issue("27881", "https://github.com/trinodb/trino/issues/27881")\)
- #breaking-marker("../release.html#breaking-changes") Reject WKT input that does not conform to OGC standards. Some inputs that were silently accepted before will now fail. \(#issue("27881", "https://github.com/trinodb/trino/issues/27881")\)
- #breaking-marker("../release.html#breaking-changes") Change #link(label("fn-st-union"), raw("ST_Union")) to return an empty geometry collection instead of #raw("NULL") for empty inputs. \(#issue("27881", "https://github.com/trinodb/trino/issues/27881")\)
- #breaking-marker("../release.html#breaking-changes") Stop inserting vertices at intersection points for point-on-line unions in #link(label("fn-st-union"), raw("ST_Union")). \(#issue("27881", "https://github.com/trinodb/trino/issues/27881")\)
- Improve compatibility of file system exchange with Azure containers that have hierarchical namespaces enabled. \(#issue("29042", "https://github.com/trinodb/trino/issues/29042")\)
- Improve performance of queries with simple #raw("AND") and #raw("OR") predicates that have highly selective terms. \(#issue("24336", "https://github.com/trinodb/trino/issues/24336")\)
- Reduce excessive memory usage caused by suboptimal join ordering for queries on columns with unknown statistics. \(#issue("29157", "https://github.com/trinodb/trino/issues/29157")\)
- Fix query failures and transaction errors caused by race conditions when dynamic catalogs are dropped concurrently with #raw("system.jdbc") or #raw("system.metadata") queries. \(#issue("28017", "https://github.com/trinodb/trino/issues/28017")\)
- Fix incorrect results when using #link(label("fn-json-parse"), raw("json_parse")) or #raw("JSON") type literals on documents containing numbers with more than 16 significant digits in the decimal portion. \(#issue("28867", "https://github.com/trinodb/trino/issues/28867")\)
- Fix failure when executing table procedures on tables with uppercase column names. \(#issue("28970", "https://github.com/trinodb/trino/issues/28970")\)
- Fix failure when executing #raw("ALTER TABLE EXECUTE OPTIMIZE") with #raw("OR") predicates on partitioned #raw("timestamp with time zone") columns. \(#issue("27136", "https://github.com/trinodb/trino/issues/27136")\)
- Fix incorrect freshness check for materialized views whose definition contains non-deterministic functions. \(#issue("28682", "https://github.com/trinodb/trino/issues/28682")\)
- Fix failure when executing #raw("DESCRIBE OUTPUT") with #raw("[VERSION | TIMESTAMP] AS OF") clauses. \(#issue("29077", "https://github.com/trinodb/trino/issues/29077")\)

== JDBC driver

- Add support for the #raw("variant") type. \(#issue("29046", "https://github.com/trinodb/trino/issues/29046")\)
- Add support for transparent OAuth2 token refresh when using the JDBC #raw("accessToken") connection property against a server configured with #raw("http-server.authentication.oauth2.refresh-tokens=true"). Previously, such connections failed with #raw("401 Unauthorized") once the embedded access token expired. \(#issue("29264", "https://github.com/trinodb/trino/issues/29264")\)
- Fix failure when calling #raw("setBigDecimal()") with a #raw("BigDecimal") value whose #raw("toString()") representation uses scientific notation, such as #raw("0E-10"). \(#issue("23523", "https://github.com/trinodb/trino/issues/23523")\)

== CLI

- Add support for the #raw("variant") type. \(#issue("29046", "https://github.com/trinodb/trino/issues/29046")\)

== ClickHouse connector

- Add support for reading all ClickHouse #raw("DECIMAL") columns. \(#issue("28873", "https://github.com/trinodb/trino/issues/28873")\)

== Delta Lake connector

- #breaking-marker("../release.html#breaking-changes") Remove legacy object storage support for Azure Storage, Google Cloud Storage, IBM Cloud Object Storage, S3, and S3-compatible systems. Use native file system support for object storage. #raw("fs.hadoop.enabled") applies only to HDFS. See #link(label("ref-file-system-legacy"))[legacy file system support] for migration details. \(#issue("24878", "https://github.com/trinodb/trino/issues/24878")\)
- Add support for configuring the Azure connection-pool idle time and HTTP request timeout via the #raw("azure.connection-pool-max-idle-time") and #raw("azure.http-request-timeout") configuration properties. \(#issue("29284", "https://github.com/trinodb/trino/issues/29284")\)
- Reduce memory usage when writing files to S3. \(#issue("28488", "https://github.com/trinodb/trino/issues/28488")\)
- Reduce query planning time by reading metadata and protocol information from Delta checksum files. This optimization can be disabled by setting the #raw("delta.load-metadata-from-checksum-file") configuration property or #raw("load_metadata_from_checksum_file") session property to #raw("false"). \(#issue("28381", "https://github.com/trinodb/trino/issues/28381")\)
- Fix #raw("DELETE") deleting incorrect rows on Delta Lake tables backed by Parquet files with column indexes, particularly when the table was written by Apache Spark. \(#issue("28885", "https://github.com/trinodb/trino/issues/28885")\)

== Hive connector

- #breaking-marker("../release.html#breaking-changes") Remove legacy object storage support for Azure Storage, Google Cloud Storage, IBM Cloud Object Storage, S3, and S3-compatible systems. Use native file system support for object storage. #raw("fs.hadoop.enabled") applies only to HDFS. See #link(label("ref-file-system-legacy"))[legacy file system support] for migration details. \(#issue("24878", "https://github.com/trinodb/trino/issues/24878")\)
- Add support for #link("https://doc.arcgis.com/en/arcgis-online/reference/geojson.htm")[Esri GeoJSON]. \(#issue("28859", "https://github.com/trinodb/trino/issues/28859")\)
- Add support for configuring the Azure connection-pool idle time and HTTP request timeout via the #raw("azure.connection-pool-max-idle-time") and #raw("azure.http-request-timeout") configuration properties. \(#issue("29284", "https://github.com/trinodb/trino/issues/29284")\)
- Improve performance of queries with date partition predicates on Hive tables in the Glue catalog. \(#issue("28817", "https://github.com/trinodb/trino/issues/28817")\)
- Reduce memory usage when writing files to S3. \(#issue("28488", "https://github.com/trinodb/trino/issues/28488")\)
- Fix failure when creating tables in the Hive metastore version 3.1. \(#issue("28798", "https://github.com/trinodb/trino/issues/28798")\)
- Fix failure when parsing bucket numbers on tables backed by files without a bucket name. \(#issue("28632", "https://github.com/trinodb/trino/issues/28632")\)

== Hudi connector

- Add support for configuring the Azure connection-pool idle time and HTTP request timeout via the #raw("azure.connection-pool-max-idle-time") and #raw("azure.http-request-timeout") configuration properties. \(#issue("29284", "https://github.com/trinodb/trino/issues/29284")\)

== Iceberg connector

- #breaking-marker("../release.html#breaking-changes") Remove legacy object storage support for Azure Storage, Google Cloud Storage, IBM Cloud Object Storage, S3, and S3-compatible systems. Use native file system support for object storage. #raw("fs.hadoop.enabled") applies only to HDFS. See #link(label("ref-file-system-legacy"))[legacy file system support] for migration details. \(#issue("24878", "https://github.com/trinodb/trino/issues/24878")\)
- Add experimental support for the #raw("variant") type for Iceberg v3 tables. Older CLI versions will render the value as JSON unless updated. \(#issue("24538", "https://github.com/trinodb/trino/issues/24538")\)
- Add support for reading and writing #raw("timestamp(9)") and #raw("timestamp(9) with time zone") in Iceberg v3 tables. \(#issue("27835", "https://github.com/trinodb/trino/issues/27835")\)
- Add support for Azure vended credentials in Iceberg REST catalog. \(#issue("23238", "https://github.com/trinodb/trino/issues/23238")\)
- Add support for specifying HTTP headers in REST catalog. \(#issue("24236", "https://github.com/trinodb/trino/issues/24236")\)
- Add support for execution metrics while running the #raw("add_files") and #raw("add_files_from_table") procedures. \(#issue("28996", "https://github.com/trinodb/trino/issues/28996")\)
- Add support for execution metrics while running the #raw("optimize") procedure. \(#issue("28992", "https://github.com/trinodb/trino/issues/28992")\)
- Add more columns to #raw("$files") system table. \(#issue("29044", "https://github.com/trinodb/trino/issues/29044")\)
- Add #raw("added_snapshot_id") column to #raw("$files") system table. \(#issue("28911", "https://github.com/trinodb/trino/issues/28911")\)
- Add support for configuring the Azure connection-pool idle time and HTTP request timeout via the #raw("azure.connection-pool-max-idle-time") and #raw("azure.http-request-timeout") configuration properties. \(#issue("29284", "https://github.com/trinodb/trino/issues/29284")\)
- Add support for refreshable vended credentials for the Iceberg REST catalog \(S3, GCS, Azure\). \(#issue("28998", "https://github.com/trinodb/trino/issues/28998")\)
- Reduce memory usage when writing files to S3. \(#issue("28488", "https://github.com/trinodb/trino/issues/28488")\)
- Fix failure when reading the #raw("$entries") or #raw("$all_entries") metadata tables. \(#issue("29211", "https://github.com/trinodb/trino/issues/29211")\)

== Lakehouse connector

- #breaking-marker("../release.html#breaking-changes") Remove legacy object storage support for Azure Storage, Google Cloud Storage, IBM Cloud Object Storage, S3, and S3-compatible systems. Use native file system support for object storage. #raw("fs.hadoop.enabled") applies only to HDFS. See #link(label("ref-file-system-legacy"))[legacy file system support] for migration details. \(#issue("24878", "https://github.com/trinodb/trino/issues/24878")\)
- Add support for configuring the Azure connection-pool idle time and HTTP request timeout via the #raw("azure.connection-pool-max-idle-time") and #raw("azure.http-request-timeout") configuration properties. \(#issue("29284", "https://github.com/trinodb/trino/issues/29284")\)
- Reduce memory usage when writing files to S3. \(#issue("28488", "https://github.com/trinodb/trino/issues/28488")\)

== MongoDB connector

- Fix incorrect results when reading JSON columns containing numbers with more than 16 significant digits in the decimal portion. \(#issue("28867", "https://github.com/trinodb/trino/issues/28867")\)

== MySQL connector

- Fix incorrect results when reading JSON columns containing numbers with more than 16 significant digits in the decimal portion. \(#issue("28867", "https://github.com/trinodb/trino/issues/28867")\)

== Pinot connector

- Fix incorrect results when reading JSON columns containing numbers with more than 16 significant digits in the decimal portion. \(#issue("28867", "https://github.com/trinodb/trino/issues/28867")\)

== PostgreSQL connector

- Improve performance of queries involving #raw("COALESCE") by pushing expression computation to the underlying database. \(#issue("11535", "https://github.com/trinodb/trino/issues/11535")\)
- Fix incorrect results when reading JSON columns containing numbers with more than 16 significant digits in the decimal portion. \(#issue("28867", "https://github.com/trinodb/trino/issues/28867")\)

== SingleStore connector

- Fix incorrect results when reading JSON columns containing numbers with more than 16 significant digits in the decimal portion. \(#issue("28867", "https://github.com/trinodb/trino/issues/28867")\)

== SQL Server connector

- Add support for the #raw("json") type. \(#issue("28082", "https://github.com/trinodb/trino/issues/28082")\)
- Fix permission denied failure when reading tables. \(#issue("29244", "https://github.com/trinodb/trino/issues/29244")\)

== SPI

- Add #raw("variant") type defined by the Iceberg specification. \(#issue("24538", "https://github.com/trinodb/trino/issues/24538")\)
- Add a #raw("tableBranch") parameter to the #raw("ConnectorAccessControl.checkCanXxx") table-level methods. \(#issue("29179", "https://github.com/trinodb/trino/issues/29179")\)
- Add support for pushing down #raw("COALESCE") expressions in connectors. \(#issue("28984", "https://github.com/trinodb/trino/issues/28984")\)
- #breaking-marker("../release.html#breaking-changes") Remove the deprecated #raw("getObject") and #raw("appendTo") methods from the #raw("Type") interface. \(#issue("29003", "https://github.com/trinodb/trino/issues/29003")\)
