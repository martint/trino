#import "/lib/trino-docs.typ": *

#anchor("doc-connector-sqlserver")
= SQL Server connector

The SQL Server connector allows querying and creating tables in an external #link("https://www.microsoft.com/sql-server/")[Microsoft SQL Server] database. This can be used to join data between different systems like SQL Server and Hive, or between two different SQL Server instances.

== Requirements

To connect to SQL Server, you need:

- SQL Server 2019 or higher, or Azure SQL Database.
- Network access from the Trino coordinator and workers to SQL Server. Port 1433 is the default port.

== Configuration

The connector can query a single database on a given SQL Server instance. Create a catalog properties file that specifies the SQL server connector by setting the #raw("connector.name") to #raw("sqlserver").

For example, to access a database as #raw("example"), create the file #raw("etc/catalog/example.properties"). Replace the connection properties as appropriate for your setup:

#code-block("properties", "connector.name=sqlserver
connection-url=jdbc:sqlserver://<host>:<port>;databaseName=<databaseName>;encrypt=false
connection-user=root
connection-password=secret")

The #raw("connection-url") defines the connection information and parameters to pass to the SQL Server JDBC driver. The supported parameters for the URL are available in the #link("https://docs.microsoft.com/sql/connect/jdbc/building-the-connection-url")[SQL Server JDBC driver documentation].

The #raw("connection-user") and #raw("connection-password") are typically required and determine the user credentials for the connection, often a service user. You can use #link(label("doc-security-secrets"))[secrets] to avoid actual values in the catalog properties files.

#anchor("ref-sqlserver-tls")

=== Connection security

The JDBC driver, and therefore the connector, automatically use Transport Layer Security \(TLS\) encryption and certificate validation. This requires a suitable TLS certificate configured on your SQL Server database host.

If you do not have the necessary configuration established, you can disable encryption in the connection string with the #raw("encrypt") property:

#code-block("properties", "connection-url=jdbc:sqlserver://<host>:<port>;databaseName=<databaseName>;encrypt=false")

Further parameters like #raw("trustServerCertificate"), #raw("hostNameInCertificate"), #raw("trustStore"), and #raw("trustStorePassword") are details in the #link("https://docs.microsoft.com/sql/connect/jdbc/using-ssl-encryption")[TLS section of SQL Server JDBC driver documentation].

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

=== Multiple SQL Server databases or servers

The SQL Server connector can only access a single SQL Server database within a single catalog. Thus, if you have multiple SQL Server databases, or want to connect to multiple SQL Server instances, you must configure multiple instances of the SQL Server connector.

To add another catalog, simply add another properties file to #raw("etc/catalog") with a different name, making sure it ends in #raw(".properties"). For example, if you name the property file #raw("sales.properties"), Trino creates a catalog named #raw("sales") using the configured connector.

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

=== Specific configuration properties

The SQL Server connector supports additional catalog properties to configure the behavior of the connector and the issues queries to the database.

#list-table((
  ([Property name], [Description],),
  ([#raw("sqlserver.snapshot-isolation.disabled")], [Control the automatic use of snapshot isolation for transactions issued by Trino in SQL Server. Defaults to #raw("false"), which means that snapshot isolation is enabled.],)
), header-rows: 1)

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

#anchor("ref-sqlserver-fte-support")

=== Fault-tolerant execution support

The connector supports #link(label("doc-admin-fault-tolerant-execution"))[Fault-tolerant execution] of query processing. Read and write operations are both supported with any retry policy.

== Querying SQL Server

The SQL Server connector provides access to all schemas visible to the specified user in the configured database. For the following examples, assume the SQL Server catalog is #raw("example").

You can see the available schemas by running #raw("SHOW SCHEMAS"):

#code-block(none, "SHOW SCHEMAS FROM example;")

If you have a schema named #raw("web"), you can view the tables in this schema by running #raw("SHOW TABLES"):

#code-block(none, "SHOW TABLES FROM example.web;")

You can see a list of the columns in the #raw("clicks") table in the #raw("web") database using either of the following:

#code-block(none, "DESCRIBE example.web.clicks;
SHOW COLUMNS FROM example.web.clicks;")

Finally, you can query the #raw("clicks") table in the #raw("web") schema:

#code-block(none, "SELECT * FROM example.web.clicks;")

If you used a different name for your catalog properties file, use that catalog name instead of #raw("example") in the above examples.

#anchor("ref-sqlserver-type-mapping")

== Type mapping

Because Trino and SQL Server each support types that the other does not, this connector #link(label("ref-type-mapping-overview"))[modifies some types] when reading or writing data. Data types may not map the same way in both directions between Trino and the data source. Refer to the following sections for type mapping in each direction.

=== SQL Server type to Trino type mapping

The connector maps SQL Server types to the corresponding Trino types following this table:

#list-table((
  ([SQL Server database type], [Trino type], [Notes],),
  ([#raw("BIT")], [#raw("BOOLEAN")], [],),
  ([#raw("TINYINT")], [#raw("SMALLINT")], [SQL Server #raw("TINYINT") is actually #raw("unsigned TINYINT")],),
  ([#raw("SMALLINT")], [#raw("SMALLINT")], [],),
  ([#raw("INTEGER")], [#raw("INTEGER")], [],),
  ([#raw("BIGINT")], [#raw("BIGINT")], [],),
  ([#raw("DOUBLE PRECISION")], [#raw("DOUBLE")], [],),
  ([#raw("FLOAT[(n)]")], [#raw("REAL") or #raw("DOUBLE")], [See #link(label("ref-sqlserver-numeric-mapping"))[SQL Server connector]],),
  ([#raw("REAL")], [#raw("REAL")], [],),
  ([#raw("DECIMAL[(p[, s])]"), #raw("NUMERIC[(p[, s])]")], [#raw("DECIMAL(p, s)")], [],),
  ([#raw("CHAR[(n)]")], [#raw("CHAR(n)")], [#raw("1 <= n <= 8000")],),
  ([#raw("NCHAR[(n)]")], [#raw("CHAR(n)")], [#raw("1 <= n <= 4000")],),
  ([#raw("VARCHAR[(n | max)]"), #raw("NVARCHAR[(n | max)]")], [#raw("VARCHAR(n)")], [#raw("1 <= n <= 8000"), #raw("max = 2147483647")],),
  ([#raw("TEXT")], [#raw("VARCHAR(2147483647)")], [],),
  ([#raw("NTEXT")], [#raw("VARCHAR(1073741823)")], [],),
  ([#raw("VARBINARY[(n | max)]")], [#raw("VARBINARY")], [#raw("1 <= n <= 8000"), #raw("max = 2147483647")],),
  ([#raw("DATE")], [#raw("DATE")], [],),
  ([#raw("TIME[(n)]")], [#raw("TIME(n)")], [#raw("0 <= n <= 7")],),
  ([#raw("DATETIME2[(n)]")], [#raw("TIMESTAMP(n)")], [#raw("0 <= n <= 7")],),
  ([#raw("SMALLDATETIME")], [#raw("TIMESTAMP(0)")], [],),
  ([#raw("DATETIMEOFFSET[(n)]")], [#raw("TIMESTAMP(n) WITH TIME ZONE")], [#raw("0 <= n <= 7")],),
  ([#raw("JSON")], [#raw("JSON")], [],)
), header-rows: 1, title: "SQL Server type to Trino type mapping")

=== Trino type to SQL Server type mapping

The connector maps Trino types to the corresponding SQL Server types following this table:

#list-table((
  ([Trino type], [SQL Server type], [Notes],),
  ([#raw("BOOLEAN")], [#raw("BIT")], [],),
  ([#raw("TINYINT")], [#raw("TINYINT")], [Trino only supports writing values belonging to #raw("[0, 127]")],),
  ([#raw("SMALLINT")], [#raw("SMALLINT")], [],),
  ([#raw("INTEGER")], [#raw("INTEGER")], [],),
  ([#raw("BIGINT")], [#raw("BIGINT")], [],),
  ([#raw("REAL")], [#raw("REAL")], [],),
  ([#raw("DOUBLE")], [#raw("DOUBLE PRECISION")], [],),
  ([#raw("DECIMAL(p, s)")], [#raw("DECIMAL(p, s)")], [],),
  ([#raw("CHAR(n)")], [#raw("NCHAR(n)") or #raw("NVARCHAR(max)")], [See #link(label("ref-sqlserver-character-mapping"))[SQL Server connector]],),
  ([#raw("VARCHAR(n)")], [#raw("NVARCHAR(n)") or #raw("NVARCHAR(max)")], [See #link(label("ref-sqlserver-character-mapping"))[SQL Server connector]],),
  ([#raw("VARBINARY")], [#raw("VARBINARY(max)")], [],),
  ([#raw("DATE")], [#raw("DATE")], [],),
  ([#raw("TIME(n)")], [#raw("TIME(n)")], [#raw("0 <= n <= 7")],),
  ([#raw("TIMESTAMP(n)")], [#raw("DATETIME2(n)")], [#raw("0 <= n <= 7")],),
  ([#raw("JSON")], [#raw("JSON")], [],)
), header-rows: 1, title: "Trino type to SQL Server type mapping")

Complete list of #link("https://msdn.microsoft.com/library/ms187752.aspx")[SQL Server data types].

#anchor("ref-sqlserver-numeric-mapping")

=== Numeric type mapping

For SQL Server #raw("FLOAT[(n)]"):

- If #raw("n") is not specified maps to Trino #raw("Double")
- If #raw("1 <= n <= 24") maps to Trino #raw("REAL")
- If #raw("24 < n <= 53") maps to Trino #raw("DOUBLE")

#anchor("ref-sqlserver-character-mapping")

=== Character type mapping

For Trino #raw("CHAR(n)"):

- If #raw("1 <= n <= 4000") maps SQL Server #raw("NCHAR(n)")
- If #raw("n > 4000") maps SQL Server #raw("NVARCHAR(max)")

For Trino #raw("VARCHAR(n)"):

- If #raw("1 <= n <= 4000") maps SQL Server #raw("NVARCHAR(n)")
- If #raw("n > 4000") maps SQL Server #raw("NVARCHAR(max)")

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

#anchor("ref-sqlserver-sql-support")

== SQL support

The connector provides read access and write access to data and metadata in SQL Server. In addition to the #link(label("ref-sql-globally-available"))[globally available] and #link(label("ref-sql-read-operations"))[read operation] statements, the connector supports the following features:

- #link(label("doc-sql-insert"))[INSERT], see also #link(label("ref-sqlserver-insert"))[SQL Server connector]
- #link(label("doc-sql-update"))[UPDATE], see also #link(label("ref-sqlserver-update"))[SQL Server connector]
- #link(label("doc-sql-delete"))[DELETE], see also #link(label("ref-sqlserver-delete"))[SQL Server connector]
- #link(label("doc-sql-truncate"))[TRUNCATE]
- #link(label("ref-sql-schema-table-management"))[SQL statement support], see also:
  
  - #link(label("ref-sqlserver-alter-table"))[SQL Server connector]
- #link(label("ref-sqlserver-procedures"))[SQL Server connector]
- #link(label("ref-sqlserver-table-functions"))[SQL Server connector]

#anchor("ref-sqlserver-insert")

=== Non-transactional INSERT

The connector supports adding rows using #link(label("doc-sql-insert"))[INSERT statements]. By default, data insertion is performed by writing data to a temporary table. You can skip this step to improve performance and write directly to the target table. Set the #raw("insert.non-transactional-insert.enabled") catalog property or the corresponding #raw("non_transactional_insert") catalog session property to #raw("true").

Note that with this property enabled, data can be corrupted in rare cases where exceptions occur during the insert operation. With transactions disabled, no rollback can be performed.

#anchor("ref-sqlserver-update")

=== UPDATE limitation

Only #raw("UPDATE") statements with constant assignments and predicates are supported. For example, the following statement is supported because the values assigned are constants:

#code-block("sql", "UPDATE table SET col1 = 1 WHERE col3 = 1")

Arithmetic expressions, function calls, and other non-constant #raw("UPDATE") statements are not supported. For example, the following statement is not supported because arithmetic expressions cannot be used with the #raw("SET") command:

#code-block("sql", "UPDATE table SET col1 = col2 + 2 WHERE col3 = 1")

All column values of a table row cannot be updated simultaneously. For a three column table, the following statement is not supported:

#code-block("sql", "UPDATE table SET col1 = 1, col2 = 2, col3 = 3 WHERE col3 = 1")

#anchor("ref-sqlserver-delete")

=== DELETE limitation

If a #raw("WHERE") clause is specified, the #raw("DELETE") operation only works if the predicate in the clause can be fully pushed down to the data source.

#anchor("ref-sqlserver-alter-table")

=== ALTER TABLE RENAME TO limitation

The connector does not support renaming tables across multiple schemas. For example, the following statement is supported:

#code-block("sql", "ALTER TABLE example.schema_one.table_one RENAME TO example.schema_one.table_two")

The following statement attempts to rename a table across schemas, and therefore is not supported:

#code-block("sql", "ALTER TABLE example.schema_one.table_one RENAME TO example.schema_two.table_two")

#anchor("ref-sqlserver-procedures")

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

#anchor("ref-sqlserver-table-functions")

=== Table functions

The connector provides specific #link(label("doc-functions-table"))[table functions] to access SQL Server.

#anchor("ref-sqlserver-query-function")

==== #raw("query(varchar) -> table")

The #raw("query") function allows you to query the underlying database directly. It requires syntax native to SQL Server, because the full query is pushed down and processed in SQL Server. This can be useful for accessing native features which are not implemented in Trino or for improving query performance in situations where running a query natively may be faster.

The native query passed to the underlying data source is required to return a table as a result set. Only the data source performs validation or security checks for these queries using its own configuration. Trino does not perform these tasks. Only use passthrough queries to read data.

For example, query the #raw("example") catalog and select the top 10 percent of nations by population:

#code-block(none, "SELECT
  *
FROM
  TABLE(
    example.system.query(
      query => 'SELECT
        TOP(10) PERCENT *
      FROM
        tpch.nation
      ORDER BY
        population DESC'
    )
  );")

#anchor("ref-sqlserver-procedure-function")

=== #raw("procedure(varchar) -> table")

The #raw("procedure") function allows you to run stored procedures on the underlying database directly. It requires syntax native to SQL Server, because the full query is pushed down and processed in SQL Server. In order to use this table function set #raw("sqlserver.stored-procedure-table-function-enabled") to #raw("true").

#note[
The #raw("procedure") function does not support running StoredProcedures that return multiple statements, use a non-select statement, use output parameters, or use conditional statements.
]

#warning[
This feature is experimental only. The function has security implication and syntax might change and be backward incompatible.
]

The follow example runs the stored procedure #raw("employee_sp") in the #raw("example") catalog and the #raw("example_schema") schema in the underlying SQL Server database:

#code-block(none, "SELECT
  *
FROM
  TABLE(
    example.system.procedure(
      query => 'EXECUTE example_schema.employee_sp'
    )
  );")

If the stored procedure #raw("employee_sp") requires any input append the parameter value to the procedure statement:

#code-block(none, "SELECT
  *
FROM
  TABLE(
    example.system.procedure(
      query => 'EXECUTE example_schema.employee_sp 0'
    )
  );")

#note[
The query engine does not preserve the order of the results of this function. If the passed query contains an #raw("ORDER BY") clause, the function result may not be ordered as expected.
]

== Performance

The connector includes a number of performance improvements, detailed in the following sections.

#anchor("ref-sqlserver-table-statistics")

=== Table statistics

The SQL Server connector can use #link(label("doc-optimizer-statistics"))[table and column statistics] for #link(label("doc-optimizer-cost-based-optimizations"))[cost based optimizations], to improve query processing performance based on the actual data in the data source.

The statistics are collected by SQL Server and retrieved by the connector.

The connector can use information stored in single-column statistics. SQL Server Database can automatically create column statistics for certain columns. If column statistics are not created automatically for a certain column, you can create them by executing the following statement in SQL Server Database.

#code-block("sql", "CREATE STATISTICS example_statistics_name ON table_schema.table_name (column_name);")

SQL Server Database routinely updates the statistics. In some cases, you may want to force statistics update \(e.g. after defining new column statistics or after changing data in the table\). You can do that by executing the following statement in SQL Server Database.

#code-block("sql", "UPDATE STATISTICS table_schema.table_name;")

Refer to SQL Server documentation for information about options, limitations and additional considerations.

#anchor("ref-sqlserver-pushdown")

=== Pushdown

The connector supports pushdown for a number of operations:

- #link(label("ref-join-pushdown"))[join-pushdown]
- #link(label("ref-limit-pushdown"))[limit-pushdown]
- #link(label("ref-topn-pushdown"))[topn-pushdown]

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

#note[
The connector performs pushdown where performance may be improved, but in order to preserve correctness an operation may not be pushed down. When pushdown of an operation may result in better performance but risks correctness, the connector prioritizes correctness.
]

==== Cost-based join pushdown

The connector supports cost-based #link(label("ref-join-pushdown"))[join-pushdown] to make intelligent decisions about whether to push down a join operation to the data source.

When cost-based join pushdown is enabled, the connector only pushes down join operations if the available #link(label("doc-optimizer-statistics"))[Table statistics] suggest that doing so improves performance. Note that if no table statistics are available, join operation pushdown does not occur to avoid a potential decrease in query performance.

The following table describes catalog configuration properties for join pushdown:

#list-table((
  ([Property name], [Description], [Default value],),
  ([#raw("join-pushdown.enabled")], [Enable #link(label("ref-join-pushdown"))[join pushdown]. Equivalent #link(label("ref-session-properties-definition"))[catalog session property] is #raw("join_pushdown_enabled").], [#raw("true")],),
  ([#raw("join-pushdown.strategy")], [Strategy used to evaluate whether join operations are pushed down. Set to #raw("AUTOMATIC") to enable cost-based join pushdown, or #raw("EAGER") to push down joins whenever possible. Note that #raw("EAGER") can push down joins even when table statistics are unavailable, which may result in degraded query performance. Because of this, #raw("EAGER") is only recommended for testing and troubleshooting purposes.], [#raw("AUTOMATIC")],)
), header-rows: 1)

==== Predicate pushdown support

The connector supports pushdown of predicates on #raw("VARCHAR") and #raw("NVARCHAR") columns if the underlying columns in SQL Server use a case-sensitive #link("https://learn.microsoft.com/en-us/sql/relational-databases/collations/collation-and-unicode-support?view=sql-server-ver16")[collation].

The following operators are pushed down:

- #raw("=")
- #raw("<>")
- #raw("IN")
- #raw("NOT IN")

To ensure correct results, operators are not pushed down for columns using a case-insensitive collation.

#anchor("ref-sqlserver-bulk-insert")

=== Bulk insert

You can optionally use the #link("https://docs.microsoft.com/sql/connect/jdbc/use-bulk-copy-api-batch-insert-operation")[bulk copy API] to drastically speed up write operations.

Enable bulk copying and a lock on the destination table to meet #link("https://docs.microsoft.com/sql/relational-databases/import-export/prerequisites-for-minimal-logging-in-bulk-import")[minimal logging requirements].

The following table shows the relevant catalog configuration properties and their default values:

#list-table((
  ([Property name], [Description], [Default],),
  ([#raw("sqlserver.bulk-copy-for-write.enabled")], [Use the SQL Server bulk copy API for writes. The corresponding catalog session property is #raw("bulk_copy_for_write").], [#raw("false")],),
  ([#raw("sqlserver.bulk-copy-for-write.lock-destination-table")], [Obtain a bulk update lock on the destination table for write operations. The corresponding catalog session property is #raw("bulk_copy_for_write_lock_destination_table"). Setting is only used when #raw("bulk-copy-for-write.enabled=true").], [#raw("false")],)
), header-rows: 1, title: "Bulk load properties")

Limitations:

- Column names with leading and trailing spaces are not supported.

== Data compression

You can specify the #link("https://docs.microsoft.com/sql/relational-databases/data-compression/data-compression")[data compression policy for SQL Server tables] with the #raw("data_compression") table property. Valid policies are #raw("NONE"), #raw("ROW") or #raw("PAGE").

Example:

#code-block(none, "CREATE TABLE example_schema.scientists (
  recordkey VARCHAR,
  name VARCHAR,
  age BIGINT,
  birthday DATE
)
WITH (
  data_compression = 'ROW'
);")
