#import "/lib/trino-docs.typ": *

#anchor("doc-connector-snowflake")
= Snowflake connector

The Snowflake connector allows querying and creating tables in an external #link("https://www.snowflake.com/")[Snowflake] account. This can be used to join data between different systems like Snowflake and Hive, or between two different Snowflake accounts.

== Configuration

To configure the Snowflake connector, create a catalog properties file in #raw("etc/catalog") named, for example, #raw("example.properties"), to mount the Snowflake connector as the #raw("snowflake") catalog. Create the file with the following contents, replacing the connection properties as appropriate for your setup:

#code-block("none", "connector.name=snowflake
connection-url=jdbc:snowflake://<account>.snowflakecomputing.com
connection-user=root
connection-password=secret
snowflake.account=account
snowflake.database=database
snowflake.role=role
snowflake.warehouse=warehouse")

The Snowflake connector uses Apache Arrow as the serialization format when reading from Snowflake. Add the following required, additional JVM argument to the #link(label("ref-jvm-config"))[Deploying Trino]:

#code-block("none", "--add-opens=java.base/java.nio=ALL-UNNAMED
--sun-misc-unsafe-memory-access=allow")

=== Multiple Snowflake databases or accounts

The Snowflake connector can only access a single database within a Snowflake account. Thus, if you have multiple Snowflake databases, or want to connect to multiple Snowflake accounts, you must configure multiple instances of the Snowflake connector.

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

Pushing down a large list of predicates to the data source can compromise performance. Trino compacts large predicates into a simpler range predicate by default to ensure a balance between performance and predicate pushdown. If necessary, the threshold for this compaction can be increased to improve performance when the data source is capable of taking advantage of large predicates. Increasing this threshold may improve pushdown of large #link(label("doc-admin-dynamic-filtering"))[dynamic filters]. The #raw("domain-compaction-threshold") catalog configuration property or the #raw("domain_compaction_threshold") #link(label("ref-session-properties-definition"))[catalog session property] can be used to adjust the default value of #raw("256") for this threshold.

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

% snowflake-type-mapping:

== Type mapping

Because Trino and Snowflake each support types that the other does not, this connector #link(label("ref-type-mapping-overview"))[modifies some types] when reading or writing data. Data types may not map the same way in both directions between Trino and the data source. Refer to the following sections for type mapping in each direction.

List of #link("https://docs.snowflake.com/en/sql-reference/intro-summary-data-types.html")[Snowflake data types].

=== Snowflake type to Trino type mapping

The connector maps Snowflake types to the corresponding Trino types following this table:

#list-table((
  ([Snowflake type], [Trino type], [Notes],),
  ([#raw("BOOLEAN")], [#raw("BOOLEAN")], [],),
  ([#raw("INT"), #raw("INTEGER"), #raw("BIGINT"), #raw("SMALLINT"), #raw("TINYINT"), #raw("BYTEINT")], [#raw("DECIMAL(38,0)")], [Synonymous with #raw("NUMBER(38,0)"). See Snowflake #link("https://docs.snowflake.com/en/sql-reference/data-types-numeric#data-types-for-fixed-point-numbers")[data types for fixed point numbers] for more information.],),
  ([#raw("FLOAT"), #raw("FLOAT4"), #raw("FLOAT8")], [#raw("DOUBLE")], [The names #raw("FLOAT"), #raw("FLOAT4"), and #raw("FLOAT8") are for compatibility with other systems; Snowflake treats all three as 64-bit floating-point numbers. See Snowflake #link("https://docs.snowflake.com/en/sql-reference/data-types-numeric#data-types-for-floating-point-numbers")[data types for floating point numbers] for more information.],),
  ([#raw("DOUBLE"), #raw("DOUBLE PRECISION"), #raw("REAL")], [#raw("DOUBLE")], [Synonymous with #raw("FLOAT"). See Snowflake #link("https://docs.snowflake.com/en/sql-reference/data-types-numeric#data-types-for-floating-point-numbers")[data types for floating point numbers] for more information.],),
  ([#raw("NUMBER")], [#raw("DECIMAL")], [Default precision and scale are \(38,0\).],),
  ([#raw("DECIMAL"), #raw("NUMERIC")], [#raw("DECIMAL")], [Synonymous with #raw("NUMBER"). See Snowflake #link("https://docs.snowflake.com/en/sql-reference/data-types-numeric#data-types-for-fixed-point-numbers")[data types for fixed point numbers] for more information.],),
  ([#raw("VARCHAR")], [#raw("VARCHAR")], [],),
  ([#raw("CHAR"), #raw("CHARACTER")], [#raw("VARCHAR")], [Synonymous with #raw("VARCHAR") except default length is #raw("VARCHAR(1)"). See Snowflake #link("https://docs.snowflake.com/en/sql-reference/data-types-text")[String & Binary Data Types] for more information.],),
  ([#raw("STRING"), #raw("TEXT")], [#raw("VARCHAR")], [Synonymous with #raw("VARCHAR"). See Snowflake #link("https://docs.snowflake.com/en/sql-reference/data-types-text")[String & Binary Data Types] for more information.],),
  ([#raw("BINARY")], [#raw("VARBINARY")], [],),
  ([#raw("VARBINARY")], [#raw("VARBINARY")], [Synonymous with #raw("BINARY"). See Snowflake #link("https://docs.snowflake.com/en/sql-reference/data-types-text")[String & Binary Data Types] for more information.],),
  ([#raw("DATE")], [#raw("DATE")], [],),
  ([#raw("TIME")], [#raw("TIME")], [],),
  ([#raw("TIMESTAMP_NTZ")], [#raw("TIMESTAMP")], [TIMESTAMP with no time zone; time zone, if provided, is not stored. See Snowflake #link("https://docs.snowflake.com/en/sql-reference/data-types-datetime")[Date & Time Data Types] for more information.],),
  ([#raw("DATETIME")], [#raw("TIMESTAMP")], [Alias for #raw("TIMESTAMP_NTZ"). See Snowflake #link("https://docs.snowflake.com/en/sql-reference/data-types-datetime")[Date & Time Data Types] for more information.],),
  ([#raw("TIMESTAMP")], [#raw("TIMESTAMP")], [Alias for one of the #raw("TIMESTAMP") variations \(#raw("TIMESTAMP_NTZ") by default\). This connector always sets #raw("TIMESTAMP_NTZ") as the variant.],),
  ([#raw("TIMESTAMP_TZ")], [#raw("TIMESTAMP WITH TIME ZONE")], [TIMESTAMP with time zone.],)
), header-rows: 1, title: "Snowflake type to Trino type mapping")

No other types are supported.

=== Trino type to Snowflake type mapping

The connector maps Trino types to the corresponding Snowflake types following this table:

#list-table((
  ([Trino type], [Snowflake type], [Notes],),
  ([#raw("BOOLEAN")], [#raw("BOOLEAN")], [],),
  ([#raw("TINYINT")], [#raw("NUMBER(3, 0)")], [],),
  ([#raw("SMALLINT")], [#raw("NUMBER(5, 0)")], [],),
  ([#raw("INTEGER")], [#raw("NUMBER(10, 0)")], [],),
  ([#raw("BIGINT")], [#raw("NUMBER(19, 0)")], [],),
  ([#raw("REAL")], [#raw("DOUBLE")], [],),
  ([#raw("DOUBLE")], [#raw("DOUBLE")], [],),
  ([#raw("DECIMAL")], [#raw("NUMBER")], [],),
  ([#raw("VARCHAR")], [#raw("VARCHAR")], [],),
  ([#raw("CHAR")], [#raw("VARCHAR")], [],),
  ([#raw("VARBINARY")], [#raw("BINARY")], [],),
  ([#raw("VARBINARY")], [#raw("VARBINARY")], [],),
  ([#raw("DATE")], [#raw("DATE")], [],),
  ([#raw("TIME")], [#raw("TIME")], [],),
  ([#raw("TIMESTAMP")], [#raw("TIMESTAMP_NTZ")], [],),
  ([#raw("TIMESTAMP WITH TIME ZONE")], [#raw("TIMESTAMP_TZ")], [],)
), header-rows: 1, title: "Trino type to Snowflake type mapping")

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

#anchor("ref-snowflake-sql-support")

== SQL support

The connector provides read access and write access to data and metadata in a Snowflake database. In addition to the #link(label("ref-sql-globally-available"))[globally available] and #link(label("ref-sql-read-operations"))[read operation] statements, the connector supports the following features:

- #link(label("doc-sql-insert"))[INSERT], see also #link(label("ref-snowflake-insert"))[Snowflake connector]
- #link(label("doc-sql-delete"))[DELETE]
- #link(label("doc-sql-truncate"))[TRUNCATE]
- #link(label("doc-sql-create-table"))[CREATE TABLE]
- #link(label("doc-sql-create-table-as"))[CREATE TABLE AS]
- #link(label("doc-sql-drop-table"))[DROP TABLE]
- #link(label("doc-sql-alter-table"))[ALTER TABLE]
- #link(label("doc-sql-create-schema"))[CREATE SCHEMA]
- #link(label("doc-sql-drop-schema"))[DROP SCHEMA]
- #link(label("ref-snowflake-procedures"))[Snowflake connector]
- #link(label("ref-snowflake-table-functions"))[Snowflake connector]

#anchor("ref-snowflake-insert")

=== Non-transactional INSERT

The connector supports adding rows using #link(label("doc-sql-insert"))[INSERT statements]. By default, data insertion is performed by writing data to a temporary table. You can skip this step to improve performance and write directly to the target table. Set the #raw("insert.non-transactional-insert.enabled") catalog property or the corresponding #raw("non_transactional_insert") catalog session property to #raw("true").

Note that with this property enabled, data can be corrupted in rare cases where exceptions occur during the insert operation. With transactions disabled, no rollback can be performed.

#anchor("ref-snowflake-procedures")

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

#anchor("ref-snowflake-table-functions")

=== Table functions

The connector provides specific #link(label("doc-functions-table"))[table functions] to access Snowflake.

#anchor("ref-snowflake-query-function")

==== #raw("query(varchar) -> table")

The #raw("query") function allows you to query the underlying database directly. It requires syntax native to Snowflake, because the full query is pushed down and processed in Snowflake. This can be useful for accessing native features which are not available in Trino or for improving query performance in situations where running a query natively may be faster.

Find details about the SQL support of Snowflake that you can use in the query in the #link("https://docs.snowflake.com/en/sql-reference-commands")[Snowflake SQL Command Reference], including #link("https://docs.snowflake.com/en/sql-reference/constructs/pivot")[PIVOT], #link("https://docs.snowflake.com/en/sql-reference/constructs/join-lateral")[lateral joins] and other statements and functions.

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

As a practical example, you can use the Snowflake SQL support for #link("https://docs.snowflake.com/en/sql-reference/constructs/pivot")[PIVOT] to pivot on all distinct column values automatically with a dynamic pivot.

#code-block(none, "SELECT
  *
FROM
  TABLE(
    example.system.query(
      query => '
        SELECT *
        FROM quarterly_sales
          PIVOT(SUM(amount) FOR quarter IN (ANY ORDER BY quarter))
        ORDER BY empid;
      '
    )
  );")

#note[
The query engine does not preserve the order of the results of this function. If the passed query contains an #raw("ORDER BY") clause, the function result may not be ordered as expected.
]

== Performance

The connector includes a number of performance improvements, detailed in the following sections.

#anchor("ref-snowflake-pushdown")

=== Pushdown

The connector supports pushdown for a number of operations:

- #link(label("ref-limit-pushdown"))[Pushdown]
- #link(label("ref-topn-pushdown"))[Pushdown]

#link(label("ref-aggregation-pushdown"))[Aggregate pushdown] for the following functions:

- #link(label("fn-avg"), raw("avg"))
- #link(label("fn-count"), raw("count"))
- #link(label("fn-max"), raw("max"))
- #link(label("fn-min"), raw("min"))
- #link(label("fn-sum"), raw("sum"))
- #link(label("fn-stddev"), raw("stddev"))
- #link(label("fn-stddev-pop"), raw("stddev_pop"))
- #link(label("fn-stddev-samp"), raw("stddev_samp"))
- #link(label("fn-variance"), raw("variance"))
- #link(label("fn-var-pop"), raw("var_pop"))
- #link(label("fn-var-samp"), raw("var_samp"))
- #link(label("fn-covar-pop"), raw("covar_pop"))
- #link(label("fn-covar-samp"), raw("covar_samp"))
- #link(label("fn-corr"), raw("corr"))
- #link(label("fn-regr-intercept"), raw("regr_intercept"))
- #link(label("fn-regr-slope"), raw("regr_slope"))

#note[
The connector performs pushdown where performance may be improved, but in order to preserve correctness an operation may not be pushed down. When pushdown of an operation may result in better performance but risks correctness, the connector prioritizes correctness.
]
