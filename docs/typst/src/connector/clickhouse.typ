#import "/lib/trino-docs.typ": *

#anchor("doc-connector-clickhouse")
= ClickHouse connector

The ClickHouse connector allows querying tables in an external #link("https://clickhouse.com/")[ClickHouse] server. This can be used to query data in the databases on that server, or combine it with other data from different catalogs accessing ClickHouse or any other supported data source.

== Requirements

To connect to a ClickHouse server, you need:

- ClickHouse \(version 25.3 or higher\) or Altinity \(version 23.3 or higher\).
- Network access from the Trino coordinator and workers to the ClickHouse server. Port 8123 is the default port.

== Configuration

The connector can query a ClickHouse server. Create a catalog properties file that specifies the ClickHouse connector by setting the #raw("connector.name") to #raw("clickhouse").

For example, create the file #raw("etc/catalog/example.properties"). Replace the connection properties as appropriate for your setup:

#code-block("none", "connector.name=clickhouse
connection-url=jdbc:clickhouse://host1:8123/
connection-user=exampleuser
connection-password=examplepassword")

The #raw("connection-url") defines the connection information and parameters to pass to the ClickHouse JDBC driver. The supported parameters for the URL are available in the #link("https://clickhouse.com/docs/en/integrations/java#configuration")[ClickHouse JDBC driver configuration].

The #raw("connection-user") and #raw("connection-password") are typically required and determine the user credentials for the connection, often a service user. You can use #link(label("doc-security-secrets"))[secrets] to avoid actual values in the catalog properties files.

#anchor("ref-clickhouse-tls")

=== Connection security

If you have TLS configured with a globally-trusted certificate installed on your data source, you can enable TLS between your cluster and the data source by appending a parameter to the JDBC connection string set in the #raw("connection-url") catalog configuration property.

For example, with version 2.6.4 of the ClickHouse JDBC driver, enable TLS by appending the #raw("ssl=true") parameter to the #raw("connection-url") configuration property:

#code-block("properties", "connection-url=jdbc:clickhouse://host1:8443/?ssl=true")

For more information on TLS configuration options, see the #link("https://clickhouse.com/docs/en/interfaces/jdbc/")[Clickhouse JDBC driver documentation]

=== Data source authentication

The connector can provide credentials for the data source connection in multiple ways:

- inline, in the connector configuration file
- in a separate properties file
- in a key store file
- as extra credentials set when connecting to Trino

You can use #link(label("doc-security-secrets"))[secrets] to avoid storing sensitive values in the catalog properties files.

The following table describes configuration properties for connection credentials:

#list-table((
  ([Property name], [Description],),
  ([#raw("credential-provider.type")], [Type of the credential provider. Must be one of #raw("INLINE"), #raw("FILE"), or #raw("KEYSTORE"); defaults to #raw("INLINE").],),
  ([#raw("connection-user")], [Connection user name.],),
  ([#raw("connection-password")], [Connection password.],),
  ([#raw("user-credential-name")], [Name of the extra credentials property, whose value to use as the user name. See #raw("extraCredentials") in #link(label("ref-jdbc-parameter-reference"))[Parameter reference].],),
  ([#raw("password-credential-name")], [Name of the extra credentials property, whose value to use as the password.],),
  ([#raw("connection-credential-file")], [Location of the properties file where credentials are present. It must contain the #raw("connection-user") and #raw("connection-password") properties.],),
  ([#raw("keystore-file-path")], [The location of the Java Keystore file, from which to read credentials.],),
  ([#raw("keystore-type")], [File format of the keystore file, for example #raw("JKS") or #raw("PEM").],),
  ([#raw("keystore-password")], [Password for the key store.],),
  ([#raw("keystore-user-credential-name")], [Name of the key store entity to use as the user name.],),
  ([#raw("keystore-user-credential-password")], [Password for the user name key store entity.],),
  ([#raw("keystore-password-credential-name")], [Name of the key store entity to use as the password.],),
  ([#raw("keystore-password-credential-password")], [Password for the password key store entity.],)
), header-rows: 1)

=== Multiple ClickHouse servers

If you have multiple ClickHouse servers you need to configure one catalog for each server. To add another catalog:

- Add another properties file to #raw("etc/catalog")
- Save it with a different name that ends in #raw(".properties")

For example, if you name the property file #raw("sales.properties"), Trino uses the configured connector to create a catalog named #raw("sales").

=== General configuration properties

The following table describes general catalog configuration properties for the connector:

#list-table((
  ([Property name], [Description],),
  ([#raw("case-insensitive-name-matching")], [Support case insensitive schema and table names. Defaults to #raw("false").],),
  ([#raw("case-insensitive-name-matching.cache-ttl")], [#link(label("ref-prop-type-duration"))[Duration] for which case insensitive schema and table names are cached. Defaults to #raw("1m").],),
  ([#raw("case-insensitive-name-matching.config-file")], [Path to a name mapping configuration file in JSON format that allows Trino to disambiguate between schemas and tables with similar names in different cases. Defaults to #raw("null").],),
  ([#raw("case-insensitive-name-matching.config-file.refresh-period")], [Frequency with which Trino checks the name matching configuration file for changes. The #link(label("ref-prop-type-duration"))[duration value] defaults to #raw("0s") \(refresh disabled\).],),
  ([#raw("metadata.cache-ttl")], [#link(label("ref-prop-type-duration"))[Duration] for which metadata, including table and column statistics, is cached. Defaults to #raw("0s") \(caching disabled\).],),
  ([#raw("metadata.cache-missing")], [Cache the fact that metadata, including table and column statistics, is not available. Defaults to #raw("false").],),
  ([#raw("metadata.schemas.cache-ttl")], [#link(label("ref-prop-type-duration"))[Duration] for which schema metadata is cached. Defaults to the value of #raw("metadata.cache-ttl").],),
  ([#raw("metadata.tables.cache-ttl")], [#link(label("ref-prop-type-duration"))[Duration] for which table metadata is cached. Defaults to the value of #raw("metadata.cache-ttl").],),
  ([#raw("metadata.statistics.cache-ttl")], [#link(label("ref-prop-type-duration"))[Duration] for which tables statistics are cached. Defaults to the value of #raw("metadata.cache-ttl").],),
  ([#raw("metadata.cache-maximum-size")], [Maximum number of objects stored in the metadata cache. Defaults to #raw("10000").],),
  ([#raw("write.batch-size")], [Maximum number of statements in a batched execution. Do not change this setting from the default. Non-default values may negatively impact performance. Defaults to #raw("1000").],),
  ([#raw("dynamic-filtering.enabled")], [Push down dynamic filters into JDBC queries. Defaults to #raw("true").],),
  ([#raw("dynamic-filtering.wait-timeout")], [Maximum #link(label("ref-prop-type-duration"))[duration] for which Trino waits for dynamic filters to be collected from the build side of joins before starting a JDBC query. Using a large timeout can potentially result in more detailed dynamic filters. However, it can also increase latency for some queries. Defaults to #raw("20s").],)
), header-rows: 1)

=== Appending query metadata

The optional parameter #raw("query.comment-format") allows you to configure a SQL comment that is sent to the datasource with each query. The format of this comment can contain any characters and the following metadata:

- #raw("$QUERY_ID"): The identifier of the query.
- #raw("$USER"): The name of the user who submits the query to Trino.
- #raw("$SOURCE"): The identifier of the client tool used to submit the query, for example #raw("trino-cli").
- #raw("$TRACE_TOKEN"): The trace token configured with the client tool.

The comment can provide more context about the query. This additional information is available in the logs of the datasource. To include environment variables from the Trino cluster with the comment , use the #raw("${ENV:VARIABLE-NAME}") syntax.

The following example sets a simple comment that identifies each query sent by Trino:

#code-block("text", "query.comment-format=Query sent by Trino.")

With this configuration, a query such as #raw("SELECT * FROM example_table;") is sent to the datasource with the comment appended:

#code-block("text", "SELECT * FROM example_table; /*Query sent by Trino.*/")

The following example improves on the preceding example by using metadata:

#code-block("text", "query.comment-format=Query $QUERY_ID sent by user $USER from Trino.")

If #raw("Jane") sent the query with the query identifier #raw("20230622_180528_00000_bkizg"), the following comment string is sent to the datasource:

#code-block("text", "SELECT * FROM example_table; /*Query 20230622_180528_00000_bkizg sent by user Jane from Trino.*/")

#note[
Certain JDBC driver settings and logging configurations might cause the comment to be removed.
]

=== Domain compaction threshold

Pushing down a large list of predicates to the data source can compromise performance. Trino compacts large predicates into a simpler range predicate by default to ensure a balance between performance and predicate pushdown. If necessary, the threshold for this compaction can be increased to improve performance when the data source is capable of taking advantage of large predicates. Increasing this threshold may improve pushdown of large #link(label("doc-admin-dynamic-filtering"))[dynamic filters]. The #raw("domain-compaction-threshold") catalog configuration property or the #raw("domain_compaction_threshold") #link(label("ref-session-properties-definition"))[catalog session property] can be used to adjust the default value of #raw("1000") for this threshold.

=== Case insensitive matching

When #raw("case-insensitive-name-matching") is set to #raw("true"), Trino is able to query non-lowercase schemas and tables by maintaining a mapping of the lowercase name to the actual name in the remote system. However, if two schemas and\/or tables have names that differ only in case \(such as "customers" and "Customers"\) then Trino fails to query them due to ambiguity.

In these cases, use the #raw("case-insensitive-name-matching.config-file") catalog configuration property to specify a configuration file that maps these remote schemas and tables to their respective Trino schemas and tables. Additionally, the JSON file must include both the #raw("schemas") and #raw("tables") properties, even if only as empty arrays.

#code-block("json", "{
  \"schemas\": [
    {
      \"remoteSchema\": \"CaseSensitiveName\",
      \"mapping\": \"case_insensitive_1\"
    },
    {
      \"remoteSchema\": \"cASEsENSITIVEnAME\",
      \"mapping\": \"case_insensitive_2\"
    }],
  \"tables\": [
    {
      \"remoteSchema\": \"CaseSensitiveName\",
      \"remoteTable\": \"tablex\",
      \"mapping\": \"table_1\"
    },
    {
      \"remoteSchema\": \"CaseSensitiveName\",
      \"remoteTable\": \"TABLEX\",
      \"mapping\": \"table_2\"
    }]
}")

Queries against one of the tables or schemes defined in the #raw("mapping") attributes are run against the corresponding remote entity. For example, a query against tables in the #raw("case_insensitive_1") schema is forwarded to the CaseSensitiveName schema and a query against #raw("case_insensitive_2") is forwarded to the #raw("cASEsENSITIVEnAME") schema.

At the table mapping level, a query on #raw("case_insensitive_1.table_1") as configured above is forwarded to #raw("CaseSensitiveName.tablex"), and a query on #raw("case_insensitive_1.table_2") is forwarded to #raw("CaseSensitiveName.TABLEX").

By default, when a change is made to the mapping configuration file, Trino must be restarted to load the changes. Optionally, you can set the #raw("case-insensitive-name-matching.config-file.refresh-period") to have Trino refresh the properties without requiring a restart:

#code-block("properties", "case-insensitive-name-matching.config-file.refresh-period=30s")

== Querying ClickHouse

The ClickHouse connector provides a schema for every ClickHouse #emph[database]. Run #raw("SHOW SCHEMAS") to see the available ClickHouse databases:

#code-block(none, "SHOW SCHEMAS FROM example;")

If you have a ClickHouse database named #raw("web"), run #raw("SHOW TABLES") to view the tables in this database:

#code-block(none, "SHOW TABLES FROM example.web;")

Run #raw("DESCRIBE") or #raw("SHOW COLUMNS") to list the columns in the #raw("clicks") table in the #raw("web") databases:

#code-block(none, "DESCRIBE example.web.clicks;
SHOW COLUMNS FROM example.web.clicks;")

Run #raw("SELECT") to access the #raw("clicks") table in the #raw("web") database:

#code-block(none, "SELECT * FROM example.web.clicks;")

#note[
If you used a different name for your catalog properties file, use that catalog name instead of #raw("example") in the above examples.
]

== Table properties

Table property usage example:

#code-block(none, "CREATE TABLE default.trino_ck (
  id int NOT NULL,
  birthday DATE NOT NULL,
  name VARCHAR,
  age BIGINT,
  logdate DATE NOT NULL
)
WITH (
  engine = 'MergeTree',
  order_by = ARRAY['id', 'birthday'],
  partition_by = ARRAY['toYYYYMM(logdate)'],
  primary_key = ARRAY['id'],
  sample_by = 'id'
);")

The following are supported ClickHouse table properties from #link("https://clickhouse.tech/docs/en/engines/table-engines/mergetree-family/mergetree/")[https:\/\/clickhouse.tech\/docs\/en\/engines\/table-engines\/mergetree-family\/mergetree\/]

#list-table((
  ([Property name], [Default value], [Description],),
  ([#raw("engine")], [#raw("Log")], [Name and parameters of the engine.],),
  ([#raw("order_by")], [\(none\)], [Array of columns or expressions to concatenate to create the sorting key. #raw("tuple()") is used by default if #raw("order_by is") not specified.],),
  ([#raw("partition_by")], [\(none\)], [Array of columns or expressions to use as nested partition keys. Optional.],),
  ([#raw("primary_key")], [\(none\)], [Array of columns or expressions to concatenate to create the primary key. Optional.],),
  ([#raw("sample_by")], [\(none\)], [An expression to use for #link("https://clickhouse.tech/docs/en/sql-reference/statements/select/sample/")[sampling]. Optional.],)
), header-rows: 1)

Currently the connector only supports #raw("Log") and #raw("MergeTree") table engines in create table statement. #raw("ReplicatedMergeTree") engine is not yet supported.

#anchor("ref-clickhouse-type-mapping")

== Type mapping

Because Trino and ClickHouse each support types that the other does not, this connector #link(label("ref-type-mapping-overview"))[modifies some types] when reading or writing data. Data types may not map the same way in both directions between Trino and the data source. Refer to the following sections for type mapping in each direction.

=== ClickHouse type to Trino type mapping

The connector maps ClickHouse types to the corresponding Trino types according to the following table:

#list-table((
  ([ClickHouse type], [Trino type], [Notes],),
  ([#raw("Bool")], [#raw("BOOLEAN")], [],),
  ([#raw("Int8")], [#raw("TINYINT")], [#raw("TINYINT") and #raw("INT1") are aliases of #raw("Int8")],),
  ([#raw("Int16")], [#raw("SMALLINT")], [#raw("SMALLINT") and #raw("INT2") are aliases of #raw("Int16")],),
  ([#raw("Int32")], [#raw("INTEGER")], [#raw("INT"), #raw("INT4"), and #raw("INTEGER") are aliases of #raw("Int32")],),
  ([#raw("Int64")], [#raw("BIGINT")], [#raw("BIGINT") is an alias of #raw("Int64")],),
  ([#raw("UInt8")], [#raw("SMALLINT")], [],),
  ([#raw("UInt16")], [#raw("INTEGER")], [],),
  ([#raw("UInt32")], [#raw("BIGINT")], [],),
  ([#raw("UInt64")], [#raw("DECIMAL(20,0)")], [],),
  ([#raw("Float32")], [#raw("REAL")], [#raw("FLOAT") is an alias of #raw("Float32")],),
  ([#raw("Float64")], [#raw("DOUBLE")], [#raw("DOUBLE") is an alias of #raw("Float64")],),
  ([#raw("Decimal")], [#raw("DECIMAL") or #raw("NUMBER")], [Maps to Trino #raw("DECIMAL") when #raw("p ≤ 38"). Otherwise, maps to #raw("NUMBER").],),
  ([#raw("FixedString")], [#raw("VARBINARY")], [Enabling #raw("clickhouse.map-string-as-varchar") config property changes the mapping to #raw("VARCHAR")],),
  ([#raw("String")], [#raw("VARBINARY")], [Enabling #raw("clickhouse.map-string-as-varchar") config property changes the mapping to #raw("VARCHAR")],),
  ([#raw("Date")], [#raw("DATE")], [],),
  ([#raw("DateTime[(timezone)]")], [#raw("TIMESTAMP(0) [WITH TIME ZONE]")], [],),
  ([#raw("IPv4")], [#raw("IPADDRESS")], [],),
  ([#raw("IPv6")], [#raw("IPADDRESS")], [],),
  ([#raw("Enum8")], [#raw("VARCHAR")], [],),
  ([#raw("Enum16")], [#raw("VARCHAR")], [],),
  ([#raw("UUID")], [#raw("UUID")], [],)
), header-rows: 1, title: "ClickHouse type to Trino type mapping")

No other types are supported.

=== Trino type to ClickHouse type mapping

The connector maps Trino types to the corresponding ClickHouse types according to the following table:

#list-table((
  ([Trino type], [ClickHouse type], [Notes],),
  ([#raw("BOOLEAN")], [#raw("Bool")], [],),
  ([#raw("TINYINT")], [#raw("Int8")], [#raw("TINYINT") and #raw("INT1") are aliases of #raw("Int8")],),
  ([#raw("SMALLINT")], [#raw("Int16")], [#raw("SMALLINT") and #raw("INT2") are aliases of #raw("Int16")],),
  ([#raw("INTEGER")], [#raw("Int32")], [#raw("INT"), #raw("INT4"), and #raw("INTEGER") are aliases of #raw("Int32")],),
  ([#raw("BIGINT")], [#raw("Int64")], [#raw("BIGINT") is an alias of #raw("Int64")],),
  ([#raw("REAL")], [#raw("Float32")], [#raw("FLOAT") is an alias of #raw("Float32")],),
  ([#raw("DOUBLE")], [#raw("Float64")], [#raw("DOUBLE") is an alias of #raw("Float64")],),
  ([#raw("DECIMAL(p,s)")], [#raw("Decimal(p,s)")], [],),
  ([#raw("VARCHAR")], [#raw("String")], [],),
  ([#raw("CHAR")], [#raw("String")], [],),
  ([#raw("VARBINARY")], [#raw("String")], [Enabling #raw("clickhouse.map-string-as-varchar") config property changes the mapping to #raw("VARCHAR")],),
  ([#raw("DATE")], [#raw("Date")], [],),
  ([#raw("TIMESTAMP(0)")], [#raw("DateTime")], [],),
  ([#raw("UUID")], [#raw("UUID")], [],)
), header-rows: 1, title: "Trino type to ClickHouse type mapping")

No other types are supported.

=== Type mapping configuration properties

The following properties can be used to configure how data types from the connected data source are mapped to Trino data types and how the metadata is cached in Trino.

#list-table((
  ([Property name], [Description], [Default value],),
  ([#raw("unsupported-type-handling")], [Configure how unsupported column data types are handled:

- #raw("IGNORE"), column is not accessible.
- #raw("CONVERT_TO_VARCHAR"), column is converted to unbounded #raw("VARCHAR").

The respective catalog session property is #raw("unsupported_type_handling").], [#raw("IGNORE")],),
  ([#raw("jdbc-types-mapped-to-varchar")], [Allow forced mapping of comma separated lists of data types to convert to unbounded #raw("VARCHAR")], [],)
), header-rows: 1)

#anchor("ref-clickhouse-sql-support")

== SQL support

The connector provides read and write access to data and metadata in a ClickHouse catalog. In addition to the #link(label("ref-sql-globally-available"))[globally available] and #link(label("ref-sql-read-operations"))[read operation] statements, the connector supports the following features:

- #link(label("doc-sql-insert"))[INSERT], see also #link(label("ref-clickhouse-insert"))[ClickHouse connector]
- #link(label("doc-sql-truncate"))[TRUNCATE]
- #link(label("ref-sql-schema-table-management"))[SQL statement support], see also:
  
  - #link(label("ref-clickhouse-alter-table"))[ClickHouse connector]
- #link(label("ref-clickhouse-procedures"))[ClickHouse connector]
- #link(label("ref-clickhouse-table-functions"))[ClickHouse connector]

#anchor("ref-clickhouse-insert")

=== Non-transactional INSERT

The connector supports adding rows using #link(label("doc-sql-insert"))[INSERT statements]. By default, data insertion is performed by writing data to a temporary table. You can skip this step to improve performance and write directly to the target table. Set the #raw("insert.non-transactional-insert.enabled") catalog property or the corresponding #raw("non_transactional_insert") catalog session property to #raw("true").

Note that with this property enabled, data can be corrupted in rare cases where exceptions occur during the insert operation. With transactions disabled, no rollback can be performed.

#anchor("ref-clickhouse-alter-table")

=== ALTER SCHEMA limitation

The connector supports renaming a schema with the #raw("ALTER SCHEMA RENAME") statement. #raw("ALTER SCHEMA SET AUTHORIZATION") is not supported.

#anchor("ref-clickhouse-procedures")

=== Procedures

==== #raw("system.flush_metadata_cache()")

Flush JDBC metadata caches. For example, the following system call flushes the metadata caches for all schemas in the #raw("example") catalog

#code-block("sql", "USE example.example_schema;
CALL system.flush_metadata_cache();")

==== #raw("system.execute('query')")

The #raw("execute") procedure allows you to execute a query in the underlying data source directly. The query must use supported syntax of the connected data source. Use the procedure to access features which are not available in Trino or to execute queries that return no result set and therefore can not be used with the #raw("query") or #raw("raw_query") pass-through table function. Typical use cases are statements that create or alter objects, and require native feature such as constraints, default values, automatic identifier creation, or indexes. Queries can also invoke statements that insert, update, or delete data, and do not return any data as a result.

The query text is not parsed by Trino, only passed through, and therefore only subject to any security or access control of the underlying data source.

The following example sets the current database to the #raw("example_schema") of the #raw("example") catalog. Then it calls the procedure in that schema to drop the default value from #raw("your_column") on #raw("your_table") table using the standard SQL syntax in the parameter value assigned for #raw("query"):

#code-block("sql", "USE example.example_schema;
CALL system.execute(query => 'ALTER TABLE your_table ALTER COLUMN your_column DROP DEFAULT');")

Verify that the specific database supports this syntax, and adapt as necessary based on the documentation for the specific connected database and database version.

#anchor("ref-clickhouse-table-functions")

=== Table functions

The connector provides specific #link(label("doc-functions-table"))[table functions] to access ClickHouse.

#anchor("ref-clickhouse-query-function")

==== #raw("query(varchar) -> table")

The #raw("query") function allows you to query the underlying database directly. It requires syntax native to ClickHouse, because the full query is pushed down and processed in ClickHouse. This can be useful for accessing native features which are not available in Trino or for improving query performance in situations where running a query natively may be faster.

The native query passed to the underlying data source is required to return a table as a result set. Only the data source performs validation or security checks for these queries using its own configuration. Trino does not perform these tasks. Only use passthrough queries to read data.

As a simple example, query the #raw("example") catalog and select an entire table:

#code-block(none, "SELECT
  *
FROM
  TABLE(
    example.system.query(
      query => 'SELECT
        *
      FROM
        tpch.nation'
    )
  );")

#note[
The query engine does not preserve the order of the results of this function. If the passed query contains an #raw("ORDER BY") clause, the function result may not be ordered as expected.
]

== Performance

The connector includes a number of performance improvements, detailed in the following sections.

#anchor("ref-clickhouse-pushdown")

=== Pushdown

The connector supports pushdown for a number of operations:

- #link(label("ref-limit-pushdown"))[limit-pushdown]

#link(label("ref-aggregation-pushdown"))[Aggregate pushdown] for the following functions:

- #link(label("fn-avg"), raw("avg"))
- #link(label("fn-count"), raw("count"))
- #link(label("fn-max"), raw("max"))
- #link(label("fn-min"), raw("min"))
- #link(label("fn-sum"), raw("sum"))

#note[
The connector performs pushdown where performance may be improved, but in order to preserve correctness an operation may not be pushed down. When pushdown of an operation may result in better performance but risks correctness, the connector prioritizes correctness.
]

==== Predicate pushdown support

The connector does not support pushdown of inequality predicates, such as #raw("!="), and range predicates such as #raw(">"), or #raw("BETWEEN"), on columns with #link(label("ref-string-data-types"))[character string types] like #raw("CHAR") or #raw("VARCHAR"). Equality predicates, such as #raw("IN") or #raw("="), on columns with character string types are pushed down. This ensures correctness of results since the remote data source may sort strings differently than Trino.

In the following example, the predicate of the first and second query is not pushed down since #raw("name") is a column of type #raw("VARCHAR") and #raw(">") and #raw("!=") are range and inequality predicates respectively. The last query is pushed down.

#code-block("sql", "-- Not pushed down
SELECT * FROM nation WHERE name > 'CANADA';
SELECT * FROM nation WHERE name != 'CANADA';
-- Pushed down
SELECT * FROM nation WHERE name = 'CANADA';")
