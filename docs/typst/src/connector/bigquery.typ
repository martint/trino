#import "/lib/trino-docs.typ": *

#anchor("doc-connector-bigquery")
= BigQuery connector

The BigQuery connector allows querying the data stored in #link("https://cloud.google.com/bigquery/")[BigQuery]. This can be used to join data between different systems like BigQuery and Hive. The connector uses the #link("https://cloud.google.com/bigquery/docs/reference/storage/")[BigQuery Storage API] to read the data from the tables.

== BigQuery Storage API

The Storage API streams data in parallel directly from BigQuery via gRPC without using Google Cloud Storage as an intermediary. It has a number of advantages over using the previous export-based read flow that should generally lead to better read performance:

/ #strong[Direct Streaming]: It does not leave any temporary files in Google Cloud Storage. Rows are read directly from BigQuery servers using an Avro wire format.
/ #strong[Column Filtering]: The new API allows column filtering to only read the data you are interested in. #link("https://cloud.google.com/blog/products/bigquery/inside-capacitor-bigquerys-next-generation-columnar-storage-format")[Backed by a columnar datastore], it can efficiently stream data without reading all columns.
/ #strong[Dynamic Sharding]: The API rebalances records between readers until they all complete. This means that all Map phases will finish nearly concurrently. See this blog article on #link("https://cloud.google.com/blog/products/gcp/no-shard-left-behind-dynamic-work-rebalancing-in-google-cloud-dataflow")[how dynamic sharding is similarly used in Google Cloud Dataflow].

#anchor("ref-bigquery-requirements")

== Requirements

To connect to BigQuery, you need:

- To enable the #link("https://cloud.google.com/bigquery/docs/reference/storage/#enabling_the_api")[BigQuery Storage Read API].
- Network access from your Trino coordinator and workers to the Google Cloud API service endpoint. This endpoint uses HTTPS, or port 443.
- To configure BigQuery so that the Trino coordinator and workers have #link("https://cloud.google.com/bigquery/docs/reference/storage#permissions")[permissions in BigQuery].
- To set up authentication. Your authentication options differ depending on whether you are using Dataproc\/Google Compute Engine \(GCE\) or not.
  
  #strong[On Dataproc\/GCE] the authentication is done from the machine's role.
  
  #strong[Outside Dataproc\/GCE] you have 3 options:
  
  - Use a service account JSON key and #raw("GOOGLE_APPLICATION_CREDENTIALS") as described in the Google Cloud authentication #link("https://cloud.google.com/docs/authentication/getting-started")[getting started guide].
  - Set #raw("bigquery.credentials-key") in the catalog properties file. It should contain the contents of the JSON file, encoded using base64.
  - Set #raw("bigquery.credentials-file") in the catalog properties file. It should point to the location of the JSON file.

== Configuration

To configure the BigQuery connector, create a catalog properties file in #raw("etc/catalog") named #raw("example.properties"), to mount the BigQuery connector as the #raw("example") catalog. Create the file with the following contents, replacing the connection properties as appropriate for your setup:

#code-block("text", "connector.name=bigquery
bigquery.project-id=<your Google Cloud Platform project id>")

=== Multiple GCP projects

The BigQuery connector can only access a single GCP project. If you have data in multiple GCP projects, you must create several catalogs, each pointing to a different GCP project. For example, if you have two GCP projects, one for the sales and one for analytics, you can create two properties files in #raw("etc/catalog") named #raw("sales.properties") and #raw("analytics.properties"), both having #raw("connector.name=bigquery") but with different #raw("project-id"). This will create the two catalogs, #raw("sales") and #raw("analytics") respectively.

#anchor("ref-bigquery-project-id-resolution")

=== Billing and data projects

The BigQuery connector determines the #link("https://cloud.google.com/resource-manager/docs/creating-managing-projects")[project ID] to use based on the configuration settings. This behavior provides users with flexibility in selecting both the project to query and the project to bill for BigQuery operations. The following table explains how project IDs are resolved in different scenarios:

#list-table((
  ([Configured properties], [Billing project], [Data project],),
  ([Only #raw("bigquery.credentials-key")], [The project ID from the credentials key is used for billing.], [The project ID from the credentials key is used for querying data.],),
  ([#raw("bigquery.credentials-key") and #raw("bigquery.project-id")], [The project ID from the credentials key is used for billing.], [#raw("bigquery.project-id") is used for querying data.],),
  ([#raw("bigquery.credentials-key") and #raw("bigquery.parent-project-id")], [#raw("bigquery.parent-project-id") is used for billing.], [The project ID from the credentials key is used for querying data.],),
  ([#raw("bigquery.credentials-key") and #raw("bigquery.parent-project-id") and #raw("bigquery.project-id")], [#raw("bigquery.parent-project-id") is used for billing.], [#raw("bigquery.project-id") is used for querying data.],)
), header-rows: 1, title: "Billing and data project ID resolution")

#anchor("ref-bigquery-arrow-serialization-support")

=== Arrow serialization support

This is a feature which introduces support for using Apache Arrow as the serialization format when reading from BigQuery. Add the following required, additional JVM argument to the #link(label("ref-jvm-config"))[Deploying Trino]:

#code-block("none", "--add-opens=java.base/java.nio=ALL-UNNAMED
--sun-misc-unsafe-memory-access=allow")

#anchor("ref-bigquery-reading-from-views")

=== Reading from views

The connector has a preliminary support for reading from #link("https://cloud.google.com/bigquery/docs/views-intro")[BigQuery views]. Please note there are a few caveats:

- Reading from views is disabled by default. In order to enable it, set the #raw("bigquery.views-enabled") configuration property to #raw("true").
- BigQuery views are not materialized by default, which means that the connector needs to materialize them before it can read them. This process affects the read performance.
- The materialization process can also incur additional costs to your BigQuery bill.
- By default, the materialized views are created in the same project and dataset. Those can be configured by the optional #raw("bigquery.view-materialization-project") and #raw("bigquery.view-materialization-dataset") properties, respectively. The service account must have write permission to the project and the dataset in order to materialize the view.

=== Configuration properties

#list-table((
  ([Property name], [Description], [Default],),
  ([#raw("bigquery.project-id")], [The project ID of the Google Cloud account used to store the data, see also #link(label("ref-bigquery-project-id-resolution"))[BigQuery connector]], [Taken from the service account or from #raw("bigquery.parent-project-id"), if set],),
  ([#raw("bigquery.parent-project-id")], [The project ID Google Cloud Project to bill for the export, see also #link(label("ref-bigquery-project-id-resolution"))[BigQuery connector]], [Taken from the service account],),
  ([#raw("bigquery.views-enabled")], [Enables the connector to read from views and not only tables. Read #link(label("ref-bigquery-reading-from-views"))[this section] before enabling this feature.], [#raw("false")],),
  ([#raw("bigquery.view-expire-duration")], [Expire duration for the materialized view.], [#raw("24h")],),
  ([#raw("bigquery.view-materialization-project")], [The project where the materialized view is going to be created.], [The view's project],),
  ([#raw("bigquery.view-materialization-dataset")], [The dataset where the materialized view is going to be created.], [The view's project],),
  ([#raw("bigquery.skip-view-materialization")], [Use REST API to access views instead of Storage API. BigQuery #raw("BIGNUMERIC") and #raw("TIMESTAMP") types are unsupported.], [#raw("false")],),
  ([#raw("bigquery.view-materialization-with-filter")], [Use filter conditions when materializing views.], [#raw("false")],),
  ([#raw("bigquery.views-cache-ttl")], [Duration for which the materialization of a view will be cached and reused. Set to #raw("0ms") to disable the cache.], [#raw("15m")],),
  ([#raw("bigquery.metadata.cache-ttl")], [Duration for which metadata retrieved from BigQuery is cached and reused. Set to #raw("0ms") to disable the cache.], [#raw("0ms")],),
  ([#raw("bigquery.metadata.parallelism")], [The number of parallel metadata enumeration calls to BigQuery. Must be between #raw("1") and #raw("32").], [Minimum of the number of available CPUs and #raw("32")],),
  ([#raw("bigquery.metadata-page-size")], [The number of metadata entries retrieved per API request.], [#raw("1000")],),
  ([#raw("bigquery.max-read-rows-retries")], [The number of retries in case of retryable server issues.], [#raw("3")],),
  ([#raw("bigquery.credentials-key")], [The base64 encoded credentials key.], [None. See the #link(label("ref-bigquery-requirements"))[requirements] section],),
  ([#raw("bigquery.credentials-file")], [The path to the JSON credentials file.], [None. See the #link(label("ref-bigquery-requirements"))[requirements] section],),
  ([#raw("bigquery.case-insensitive-name-matching")], [Match dataset and table names case-insensitively.], [#raw("false")],),
  ([#raw("bigquery.case-insensitive-name-matching.cache-ttl")], [#link(label("ref-prop-type-duration"))[Duration] for which case insensitive schema and table names are cached. Set to #raw("0ms") to disable the cache.], [#raw("0ms")],),
  ([#raw("bigquery.query-results-cache.enabled")], [Enable #link("https://cloud.google.com/bigquery/docs/cached-results")[query results cache].], [#raw("false")],),
  ([#raw("bigquery.job.label-name")], [Adds a label with the given name to the BigQuery job.], [],),
  ([#raw("bigquery.job.label-format")], [Value format for the label specified by #raw("bigquery.job.label-name"). May consist of letters, digits, underscores, hyphens, commas, spaces, equal signs, and predefined values #raw("$QUERY_ID"), #raw("$SOURCE"), #raw("$USER"), and #raw("$TRACE_TOKEN").], [],),
  ([#raw("bigquery.arrow-serialization.enabled")], [Enable using Apache Arrow serialization when reading data from BigQuery. Read this #link(label("ref-bigquery-arrow-serialization-support"))[section] before using this feature.], [#raw("true")],),
  ([#raw("bigquery.arrow-serialization.max-allocation")], [The maximum amount of memory the Apache Arrow buffer allocator is allowed to use.], [#raw("100MB")],),
  ([#raw("bigquery.projection-pushdown-enabled")], [Enable dereference push down for #raw("ROW") type.], [#raw("true")],),
  ([#raw("bigquery.max-parallelism")], [The max number of partitions to split the data into. Reduce this number if the default parallelism \(number of workers x 3\) is too high.], [],),
  ([#raw("bigquery.channel-pool.initial-size")], [The initial size of the connection pool, also known as a channel pool, used for gRPC communication.], [#raw("1")],),
  ([#raw("bigquery.channel-pool.min-size")], [The minimum number of connections in the connection pool, also known as a channel pool, used for gRPC communication.], [#raw("1")],),
  ([#raw("bigquery.channel-pool.max-size")], [The maximum number of connections in the connection pool, also known as a channel pool, used for gRPC communication.], [#raw("1")],),
  ([#raw("bigquery.channel-pool.min-rpc-per-channel")], [Threshold to start scaling down the channel pool. When the average of outstanding RPCs in a single minute drop below this threshold, channels are removed from the pool.], [#raw("0")],),
  ([#raw("bigquery.channel-pool.max-rpc-per-channel")], [Threshold to start scaling up the channel pool. When the average of outstanding RPCs in a single minute surpass this threshold, channels are added to the pool.], [#raw("2147483647")],),
  ([#raw("bigquery.rpc-retries")], [The maximum number of retry attempts to perform for the RPC calls. If this value is set to #raw("0"), the value from #raw("bigquery.rpc-timeout") is used. Retry is deactivated when both #raw("bigquery.rpc-retries") and #raw("bigquery.rpc-timeout") are #raw("0"). If this value is positive, and the number of attempts exceeds #raw("bigquery.rpc-retries") limit, retries stop even if the total retry time is still lower than #raw("bigquery.rpc-timeout").], [#raw("0")],),
  ([#raw("bigquery.rpc-timeout")], [Timeout #link(label("ref-prop-type-duration"))[duration] on when the retries for the RPC call should be given up completely. The higher the timeout, the more retries can be attempted. If this value is #raw("0s"), then #raw("bigquery.rpc-retries") is used to determine retries. Retry is deactivated when #raw("bigquery.rpc-retries") and #raw("bigquery.rpc-timeout") are both #raw("0"). If this value is positive, and the retry duration has reached the timeout value, retries stop even if the number of attempts is lower than the #raw("bigquery.rpc-retries") value.], [#raw("0s")],),
  ([#raw("bigquery.rpc-retry-delay")], [The delay #link(label("ref-prop-type-duration"))[duration] before the first retry attempt for RPC calls.], [#raw("0s")],),
  ([#raw("bigquery.rpc-retry-delay-multiplier")], [Controls the change in delay before the next retry. The retry delay of the previous call is multiplied by the #raw("bigquery.rpc-retry-delay-multiplier") to calculate the retry delay for the next RPC call.], [#raw("1.0")],),
  ([#raw("bigquery.rpc-proxy.enabled")], [Use a proxy for communication with BigQuery.], [#raw("false")],),
  ([#raw("bigquery.rpc-proxy.uri")], [Proxy URI to use if connecting through a proxy.], [],),
  ([#raw("bigquery.rpc-proxy.username")], [Proxy username to use if connecting through a proxy.], [],),
  ([#raw("bigquery.rpc-proxy.password")], [Proxy password to use if connecting through a proxy.], [],),
  ([#raw("bigquery.rpc-proxy.keystore-path")], [Keystore containing client certificates to present to proxy if connecting through a proxy. Only required if proxy uses mutual TLS.], [],),
  ([#raw("bigquery.rpc-proxy.keystore-password")], [Password of the keystore specified by #raw("bigquery.rpc-proxy.keystore-path").], [],),
  ([#raw("bigquery.rpc-proxy.truststore-path")], [Truststore containing certificates of the proxy server if connecting through a proxy.], [],),
  ([#raw("bigquery.rpc-proxy.truststore-password")], [Password of the truststore specified by #raw("bigquery.rpc-proxy.truststore-path").], [],)
), header-rows: 1, title: "BigQuery configuration properties")

#anchor("ref-bigquery-fte-support")

=== Fault-tolerant execution support

The connector supports #link(label("doc-admin-fault-tolerant-execution"))[Fault-tolerant execution] of query processing. Read and write operations are both supported with any retry policy.

#anchor("ref-bigquery-type-mapping")

== Type mapping

Because Trino and BigQuery each support types that the other does not, this connector #link(label("ref-type-mapping-overview"))[modifies some types] when reading or writing data. Data types may not map the same way in both directions between Trino and the data source. Refer to the following sections for type mapping in each direction.

=== BigQuery type to Trino type mapping

The connector maps BigQuery types to the corresponding Trino types according to the following table:

#list-table((
  ([BigQuery type], [Trino type], [Notes],),
  ([#raw("BOOLEAN")], [#raw("BOOLEAN")], [],),
  ([#raw("INT64")], [#raw("BIGINT")], [#raw("INT"), #raw("SMALLINT"), #raw("INTEGER"), #raw("BIGINT"), #raw("TINYINT"), and #raw("BYTEINT") are aliases for #raw("INT64") in BigQuery.],),
  ([#raw("FLOAT64")], [#raw("DOUBLE")], [],),
  ([#raw("NUMERIC")], [#raw("DECIMAL(P,S)")], [The default precision and scale of #raw("NUMERIC") is #raw("(38, 9)").],),
  ([#raw("BIGNUMERIC")], [#raw("DECIMAL(P,S)")], [Precision \> 38 is not supported. The default precision and scale of #raw("BIGNUMERIC") is #raw("(77, 38)").],),
  ([#raw("DATE")], [#raw("DATE")], [],),
  ([#raw("DATETIME")], [#raw("TIMESTAMP(6)")], [],),
  ([#raw("STRING")], [#raw("VARCHAR")], [],),
  ([#raw("BYTES")], [#raw("VARBINARY")], [],),
  ([#raw("TIME")], [#raw("TIME(6)")], [],),
  ([#raw("TIMESTAMP")], [#raw("TIMESTAMP(6) WITH TIME ZONE")], [Time zone is UTC],),
  ([#raw("GEOGRAPHY")], [#raw("VARCHAR")], [In #link("https://wikipedia.org/wiki/Well-known_text_representation_of_geometry")[Well-known text \(WKT\)] format],),
  ([#raw("JSON")], [#raw("JSON")], [],),
  ([#raw("ARRAY")], [#raw("ARRAY")], [],),
  ([#raw("RECORD")], [#raw("ROW")], [],)
), header-rows: 1, title: "BigQuery type to Trino type mapping")

No other types are supported.

=== Trino type to BigQuery type mapping

The connector maps Trino types to the corresponding BigQuery types according to the following table:

#list-table((
  ([Trino type], [BigQuery type], [Notes],),
  ([#raw("BOOLEAN")], [#raw("BOOLEAN")], [],),
  ([#raw("VARBINARY")], [#raw("BYTES")], [],),
  ([#raw("DATE")], [#raw("DATE")], [],),
  ([#raw("DOUBLE")], [#raw("FLOAT")], [],),
  ([#raw("BIGINT")], [#raw("INT64")], [#raw("INT"), #raw("SMALLINT"), #raw("INTEGER"), #raw("BIGINT"), #raw("TINYINT"), and #raw("BYTEINT") are aliases for #raw("INT64") in BigQuery.],),
  ([#raw("DECIMAL(P,S)")], [#raw("NUMERIC")], [The default precision and scale of #raw("NUMERIC") is #raw("(38, 9)").],),
  ([#raw("VARCHAR")], [#raw("STRING")], [],),
  ([#raw("TIMESTAMP(6)")], [#raw("DATETIME")], [],)
), header-rows: 1, title: "Trino type to BigQuery type mapping")

No other types are supported.

== System tables

For each Trino table which maps to BigQuery view there exists a system table which exposes BigQuery view definition. Given a BigQuery view #raw("example_view") you can send query #raw("SELECT * example_view$view_definition") to see the SQL which defines view in BigQuery.

#anchor("ref-bigquery-special-columns")

== Special columns

In addition to the defined columns, the BigQuery connector exposes partition information in a number of hidden columns:

- #raw("$partition_date"): Equivalent to #raw("_PARTITIONDATE") pseudo-column in BigQuery
- #raw("$partition_time"): Equivalent to #raw("_PARTITIONTIME") pseudo-column in BigQuery

You can use these columns in your SQL statements like any other column. They can be selected directly, or used in conditional statements. For example, you can inspect the partition date and time for each record:

#code-block(none, "SELECT *, \"$partition_date\", \"$partition_time\"
FROM example.web.page_views;")

Retrieve all records stored in the partition #raw("_PARTITIONDATE = '2022-04-07'"):

#code-block(none, "SELECT *
FROM example.web.page_views
WHERE \"$partition_date\" = date '2022-04-07';")

#note[
Two special partitions #raw("__NULL__") and #raw("__UNPARTITIONED__") are not supported.
]

#anchor("ref-bigquery-sql-support")

== SQL support

The connector provides read and write access to data and metadata in the BigQuery database. In addition to the #link(label("ref-sql-globally-available"))[globally available] and #link(label("ref-sql-read-operations"))[read operation] statements, the connector supports the following features:

- #link(label("doc-sql-insert"))[INSERT]
- #link(label("doc-sql-delete"))[DELETE]
- #link(label("doc-sql-truncate"))[TRUNCATE]
- #link(label("doc-sql-create-table"))[CREATE TABLE]
- #link(label("doc-sql-create-table-as"))[CREATE TABLE AS]
- #link(label("doc-sql-drop-table"))[DROP TABLE]
- #link(label("doc-sql-create-schema"))[CREATE SCHEMA]
- #link(label("doc-sql-drop-schema"))[DROP SCHEMA]
- #link(label("doc-sql-comment"))[COMMENT]

=== DELETE limitation

If a #raw("WHERE") clause is specified, the #raw("DELETE") operation only works if the predicate in the clause can be fully pushed down to the data source.

=== Wildcard table

The connector provides support to query multiple tables using a concise #link("https://cloud.google.com/bigquery/docs/querying-wildcard-tables")[wildcard table] notation.

#code-block("sql", "SELECT *
FROM example.web.\"page_views_*\";")

=== Procedures

==== #raw("system.execute('query')")

The #raw("execute") procedure allows you to execute a query in the underlying data source directly. The query must use supported syntax of the connected data source. Use the procedure to access features which are not available in Trino or to execute queries that return no result set and therefore can not be used with the #raw("query") or #raw("raw_query") pass-through table function. Typical use cases are statements that create or alter objects, and require native feature such as constraints, default values, automatic identifier creation, or indexes. Queries can also invoke statements that insert, update, or delete data, and do not return any data as a result.

The query text is not parsed by Trino, only passed through, and therefore only subject to any security or access control of the underlying data source.

The following example sets the current database to the #raw("example_schema") of the #raw("example") catalog. Then it calls the procedure in that schema to drop the default value from #raw("your_column") on #raw("your_table") table using the standard SQL syntax in the parameter value assigned for #raw("query"):

#code-block("sql", "USE example.example_schema;
CALL system.execute(query => 'ALTER TABLE your_table ALTER COLUMN your_column DROP DEFAULT');")

Verify that the specific database supports this syntax, and adapt as necessary based on the documentation for the specific connected database and database version.

=== Table functions

The connector provides specific #link(label("doc-functions-table"))[table functions] to access BigQuery.

#anchor("ref-bigquery-query-function")

==== #raw("query(varchar) -> table")

The #raw("query") function allows you to query the underlying BigQuery directly. It requires syntax native to BigQuery, because the full query is pushed down and processed by BigQuery. This can be useful for accessing native features which are not available in Trino or for improving query performance in situations where running a query natively may be faster.

The native query passed to the underlying data source is required to return a table as a result set. Only the data source performs validation or security checks for these queries using its own configuration. Trino does not perform these tasks. Only use passthrough queries to read data.

For example, query the #raw("example") catalog and group and concatenate all employee IDs by manager ID:

#code-block(none, "SELECT
  *
FROM
  TABLE(
    example.system.query(
      query => 'SELECT
        manager_id, STRING_AGG(employee_id)
      FROM
        company.employees
      GROUP BY
        manager_id'
    )
  );")

#note[
The query engine does not preserve the order of the results of this function. If the passed query contains an #raw("ORDER BY") clause, the function result may not be ordered as expected.
]

== Performance

The connector includes a number of performance improvements, detailed in the following sections.

#anchor("ref-bigquery-pushdown")

=== Pushdown

The connector supports pushdown for a number of operations:

- #link(label("ref-limit-pushdown"))[Pushdown] for access to tables and other objects when using the REST API to reduce CPU consumption in BigQuery and performance overall. Pushdown is not supported by the Storage API, used for the more common Trino-managed tables, and therefore not used for access with it.

== FAQ

=== What is the Pricing for the Storage API?

See the #link("https://cloud.google.com/bigquery/pricing#storage-api")[BigQuery pricing documentation].
