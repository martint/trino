#import "/lib/trino-docs.typ": *

#anchor("doc-connector-postgresql")
= PostgreSQL connector

The PostgreSQL connector allows querying and creating tables in an external #link("https://www.postgresql.org/")[PostgreSQL] database. This can be used to join data between different systems like PostgreSQL and Hive, or between different PostgreSQL instances.

== Requirements

To connect to PostgreSQL, you need:

- PostgreSQL 12.x or higher.
- Network access from the Trino coordinator and workers to PostgreSQL. Port 5432 is the default port.

== Configuration

The connector can query a database on a PostgreSQL server. Create a catalog properties file that specifies the PostgreSQL connector by setting the #raw("connector.name") to #raw("postgresql").

For example, to access a database as the #raw("example") catalog, create the file #raw("etc/catalog/example.properties"). Replace the connection properties as appropriate for your setup:

#code-block("text", "connector.name=postgresql
connection-url=jdbc:postgresql://example.net:5432/database
connection-user=root
connection-password=secret")

The #raw("connection-url") defines the connection information and parameters to pass to the PostgreSQL JDBC driver. The parameters for the URL are available in the #link("https://jdbc.postgresql.org/documentation/use/#connecting-to-the-database")[PostgreSQL JDBC driver documentation]. Some parameters can have adverse effects on the connector behavior or not work with the connector.

The #raw("connection-user") and #raw("connection-password") are typically required and determine the user credentials for the connection, often a service user. You can use #link(label("doc-security-secrets"))[secrets] to avoid actual values in the catalog properties files.

=== Access to system tables

The PostgreSQL connector supports reading #link("https://www.postgresql.org/docs/current/catalogs.html")[PostgreSQL catalog tables], such as #raw("pg_namespace"). The functionality is turned off by default, and can be enabled using the #raw("postgresql.include-system-tables") configuration property.

You can see more details in the #raw("pg_catalog") schema in the #raw("example") catalog, for example about the #raw("pg_namespace") system table:

#code-block("sql", "SHOW TABLES FROM example.pg_catalog;
SELECT * FROM example.pg_catalog.pg_namespace;")

#anchor("ref-postgresql-tls")

=== Connection security

If you have TLS configured with a globally-trusted certificate installed on your data source, you can enable TLS between your cluster and the data source by appending a parameter to the JDBC connection string set in the #raw("connection-url") catalog configuration property.

For example, with version 42 of the PostgreSQL JDBC driver, enable TLS by appending the #raw("ssl=true") parameter to the #raw("connection-url") configuration property:

#code-block("properties", "connection-url=jdbc:postgresql://example.net:5432/database?ssl=true")

For more information on TLS configuration options, see the #link("https://jdbc.postgresql.org/documentation/use/#connecting-to-the-database")[PostgreSQL JDBC driver documentation].

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

=== Multiple PostgreSQL databases or servers

The PostgreSQL connector can only access a single database within a PostgreSQL server. Thus, if you have multiple PostgreSQL databases, or want to connect to multiple PostgreSQL servers, you must configure multiple instances of the PostgreSQL connector.

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

#anchor("ref-postgresql-fte-support")

=== Fault-tolerant execution support

The connector supports #link(label("doc-admin-fault-tolerant-execution"))[Fault-tolerant execution] of query processing. Read and write operations are both supported with any retry policy.

#anchor("ref-postgresql-type-mapping")

== Type mapping

Because Trino and PostgreSQL each support types that the other does not, this connector #link(label("ref-type-mapping-overview"))[modifies some types] when reading or writing data. Data types may not map the same way in both directions between Trino and the data source. Refer to the following sections for type mapping in each direction.

=== PostgreSQL type to Trino type mapping

The connector maps PostgreSQL types to the corresponding Trino types following this table:

#list-table((
  ([PostgreSQL type], [Trino type], [Notes],),
  ([#raw("BIT")], [#raw("BOOLEAN")], [],),
  ([#raw("BOOLEAN")], [#raw("BOOLEAN")], [],),
  ([#raw("SMALLINT")], [#raw("SMALLINT")], [],),
  ([#raw("INTEGER")], [#raw("INTEGER")], [],),
  ([#raw("BIGINT")], [#raw("BIGINT")], [],),
  ([#raw("REAL")], [#raw("REAL")], [],),
  ([#raw("DOUBLE")], [#raw("DOUBLE")], [],),
  ([#raw("NUMERIC(p, s)")  \
#raw("DECIMAL(p, s)")], [#raw("DECIMAL(pʹ, sʹ)") or #raw("NUMBER")], [Maps to Trino #raw("DECIMAL") when input data can be represented as Trino #raw("DECIMAL") losslessly. When #raw("1 ≤ p ≤ 38") and #raw("0 ≤ s ≤ p"), then #raw("pʹ = p") and #raw("sʹ = s"), otherwise, a wider type is used.  \
When input cannot be represented as Trino #raw("DECIMAL") losslessly, maps to #raw("NUMBER").],),
  ([#raw("NUMERIC")  \
#raw("DECIMAL")], [#raw("NUMBER")], [],),
  ([#raw("CHAR(n)")], [#raw("CHAR(n)")], [],),
  ([#raw("VARCHAR(n)")], [#raw("VARCHAR(n)")], [],),
  ([#raw("ENUM")], [#raw("VARCHAR")], [],),
  ([#raw("BYTEA")], [#raw("VARBINARY")], [],),
  ([#raw("DATE")], [#raw("DATE")], [],),
  ([#raw("TIME(n)")], [#raw("TIME(n)")], [],),
  ([#raw("TIMESTAMP(n)")], [#raw("TIMESTAMP(n)")], [],),
  ([#raw("TIMESTAMPTZ(n)")], [#raw("TIMESTAMP(n) WITH TIME ZONE")], [],),
  ([#raw("MONEY")], [#raw("VARCHAR")], [],),
  ([#raw("UUID")], [#raw("UUID")], [],),
  ([#raw("JSON")], [#raw("JSON")], [],),
  ([#raw("JSONB")], [#raw("JSON")], [],),
  ([#raw("VECTOR")], [#raw("ARRAY(REAL)")], [],),
  ([#raw("HSTORE")], [#raw("MAP(VARCHAR, VARCHAR)")], [],),
  ([#raw("ARRAY")], [Disabled, #raw("ARRAY"), or #raw("JSON")], [See #link(label("ref-postgresql-array-type-handling"))[PostgreSQL connector] for more information.],),
  ([#raw("GEOMETRY"), #raw("GEOMETRY(GEOMETRY TYPE, SRID)"), #raw("POINT")], [#raw("GEOMETRY")], [],)
), header-rows: 1, title: "PostgreSQL type to Trino type mapping")

No other types are supported.

=== Trino type to PostgreSQL type mapping

The connector maps Trino types to the corresponding PostgreSQL types following this table:

#list-table((
  ([Trino type], [PostgreSQL type], [Notes],),
  ([#raw("BOOLEAN")], [#raw("BOOLEAN")], [],),
  ([#raw("SMALLINT")], [#raw("SMALLINT")], [],),
  ([#raw("TINYINT")], [#raw("SMALLINT")], [],),
  ([#raw("INTEGER")], [#raw("INTEGER")], [],),
  ([#raw("BIGINT")], [#raw("BIGINT")], [],),
  ([#raw("DOUBLE")], [#raw("DOUBLE")], [],),
  ([#raw("DECIMAL(p, s)")], [#raw("NUMERIC(p, s)")], [],),
  ([#raw("NUMBER")], [#raw("NUMERIC")], [],),
  ([#raw("CHAR(n)")], [#raw("CHAR(n)")], [],),
  ([#raw("VARCHAR(n)")], [#raw("VARCHAR(n)")], [],),
  ([#raw("VARBINARY")], [#raw("BYTEA")], [],),
  ([#raw("DATE")], [#raw("DATE")], [],),
  ([#raw("TIME(n)")], [#raw("TIME(n)")], [],),
  ([#raw("TIMESTAMP(n)")], [#raw("TIMESTAMP(n)")], [],),
  ([#raw("TIMESTAMP(n) WITH TIME ZONE")], [#raw("TIMESTAMPTZ(n)")], [],),
  ([#raw("UUID")], [#raw("UUID")], [],),
  ([#raw("JSON")], [#raw("JSONB")], [],),
  ([#raw("ARRAY")], [#raw("ARRAY")], [See #link(label("ref-postgresql-array-type-handling"))[PostgreSQL connector] for more information.],),
  ([#raw("GEOMETRY")], [#raw("GEOMETRY")], [],)
), header-rows: 1, title: "Trino type to PostgreSQL type mapping")

No other types are supported.

#anchor("ref-postgresql-array-type-handling")

=== Array type handling

The PostgreSQL array implementation does not support fixed dimensions whereas Trino support only arrays with fixed dimensions. You can configure how the PostgreSQL connector handles arrays with the #raw("postgresql.array-mapping") configuration property in your catalog file or the #raw("array_mapping") session property. The following values are accepted for this property:

- #raw("DISABLED") \(default\): array columns are skipped.
- #raw("AS_ARRAY"): array columns are interpreted as Trino #raw("ARRAY") type, for array columns with fixed dimensions.
- #raw("AS_JSON"): array columns are interpreted as Trino #raw("JSON") type, with no constraint on dimensions.

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

== Querying PostgreSQL

The PostgreSQL connector provides a schema for every PostgreSQL schema. You can see the available PostgreSQL schemas by running #raw("SHOW SCHEMAS"):

#code-block(none, "SHOW SCHEMAS FROM example;")

If you have a PostgreSQL schema named #raw("web"), you can view the tables in this schema by running #raw("SHOW TABLES"):

#code-block(none, "SHOW TABLES FROM example.web;")

You can see a list of the columns in the #raw("clicks") table in the #raw("web") database using either of the following:

#code-block(none, "DESCRIBE example.web.clicks;
SHOW COLUMNS FROM example.web.clicks;")

Finally, you can access the #raw("clicks") table in the #raw("web") schema:

#code-block(none, "SELECT * FROM example.web.clicks;")

If you used a different name for your catalog properties file, use that catalog name instead of #raw("example") in the above examples.

#anchor("ref-postgresql-sql-support")

== SQL support

The connector provides read access and write access to data and metadata in PostgreSQL. In addition to the #link(label("ref-sql-globally-available"))[globally available] and #link(label("ref-sql-read-operations"))[read operation] statements, the connector supports the following features:

- #link(label("doc-sql-insert"))[INSERT], see also #link(label("ref-postgresql-insert"))[PostgreSQL connector]
- #link(label("doc-sql-update"))[UPDATE], see also #link(label("ref-postgresql-update"))[PostgreSQL connector]
- #link(label("doc-sql-delete"))[DELETE], see also #link(label("ref-postgresql-delete"))[PostgreSQL connector]
- #link(label("doc-sql-merge"))[MERGE], see also #link(label("ref-postgresql-merge"))[PostgreSQL connector]
- #link(label("doc-sql-truncate"))[TRUNCATE]
- #link(label("ref-sql-schema-table-management"))[SQL statement support], see also:
  
  - #link(label("ref-postgresql-alter-table"))[PostgreSQL connector]
  - #link(label("ref-postgresql-alter-schema"))[PostgreSQL connector]
- #link(label("ref-postgresql-procedures"))[PostgreSQL connector]
- #link(label("ref-postgresql-table-functions"))[PostgreSQL connector]

#anchor("ref-postgresql-insert")

=== Non-transactional INSERT

The connector supports adding rows using #link(label("doc-sql-insert"))[INSERT statements]. By default, data insertion is performed by writing data to a temporary table. You can skip this step to improve performance and write directly to the target table. Set the #raw("insert.non-transactional-insert.enabled") catalog property or the corresponding #raw("non_transactional_insert") catalog session property to #raw("true").

Note that with this property enabled, data can be corrupted in rare cases where exceptions occur during the insert operation. With transactions disabled, no rollback can be performed.

#anchor("ref-postgresql-update")

=== UPDATE limitation

Only #raw("UPDATE") statements with constant assignments and predicates are supported. For example, the following statement is supported because the values assigned are constants:

#code-block("sql", "UPDATE table SET col1 = 1 WHERE col3 = 1")

Arithmetic expressions, function calls, and other non-constant #raw("UPDATE") statements are not supported. For example, the following statement is not supported because arithmetic expressions cannot be used with the #raw("SET") command:

#code-block("sql", "UPDATE table SET col1 = col2 + 2 WHERE col3 = 1")

All column values of a table row cannot be updated simultaneously. For a three column table, the following statement is not supported:

#code-block("sql", "UPDATE table SET col1 = 1, col2 = 2, col3 = 3 WHERE col3 = 1")

#anchor("ref-postgresql-delete")

=== DELETE limitation

If a #raw("WHERE") clause is specified, the #raw("DELETE") operation only works if the predicate in the clause can be fully pushed down to the data source.

#anchor("ref-postgresql-merge")

=== Non-transactional MERGE

The connector supports adding, updating, and deleting rows using #link(label("doc-sql-merge"))[MERGE statements], if the #raw("merge.non-transactional-merge.enabled") catalog property or the corresponding #raw("non_transactional_merge_enabled") catalog session property is set to #raw("true"). Merge is only supported for directly modifying target tables.

In rare cases, exceptions may occur during the merge operation, potentially resulting in a partial update.

#anchor("ref-postgresql-alter-table")

=== ALTER TABLE RENAME TO limitation

The connector does not support renaming tables across multiple schemas. For example, the following statement is supported:

#code-block("sql", "ALTER TABLE example.schema_one.table_one RENAME TO example.schema_one.table_two")

The following statement attempts to rename a table across schemas, and therefore is not supported:

#code-block("sql", "ALTER TABLE example.schema_one.table_one RENAME TO example.schema_two.table_two")

#anchor("ref-postgresql-alter-schema")

=== ALTER SCHEMA limitation

The connector supports renaming a schema with the #raw("ALTER SCHEMA RENAME") statement. #raw("ALTER SCHEMA SET AUTHORIZATION") is not supported.

#anchor("ref-postgresql-procedures")

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

#anchor("ref-postgresql-table-functions")

=== Table functions

The connector provides specific #link(label("doc-functions-table"))[table functions] to access PostgreSQL.

#anchor("ref-postgresql-query-function")

==== #raw("query(varchar) -> table")

The #raw("query") function allows you to query the underlying database directly. It requires syntax native to PostgreSQL, because the full query is pushed down and processed in PostgreSQL. This can be useful for accessing native features which are not available in Trino or for improving query performance in situations where running a query natively may be faster.

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

As a practical example, you can leverage #link("https://www.postgresql.org/docs/current/sql-expressions.html#SYNTAX-WINDOW-FUNCTIONS")[frame exclusion from PostgresQL] when using window functions:

#code-block(none, "SELECT
  *
FROM
  TABLE(
    example.system.query(
      query => 'SELECT
        *,
        array_agg(week) OVER (
          ORDER BY
            week
          ROWS
            BETWEEN 2 PRECEDING
            AND 2 FOLLOWING
            EXCLUDE GROUP
        ) AS week,
        array_agg(week) OVER (
          ORDER BY
            day
          ROWS
            BETWEEN 2 PRECEDING
            AND 2 FOLLOWING
            EXCLUDE GROUP
        ) AS all
      FROM
        test.time_data'
    )
  );")

#note[
The query engine does not preserve the order of the results of this function. If the passed query contains an #raw("ORDER BY") clause, the function result may not be ordered as expected.
]

== Performance

The connector includes a number of performance improvements, detailed in the following sections.

#anchor("ref-postgresql-table-statistics")

=== Table statistics

The PostgreSQL connector can use #link(label("doc-optimizer-statistics"))[table and column statistics] for #link(label("doc-optimizer-cost-based-optimizations"))[cost based optimizations], to improve query processing performance based on the actual data in the data source.

The statistics are collected by PostgreSQL and retrieved by the connector.

To collect statistics for a table, execute the following statement in PostgreSQL.

#code-block("text", "ANALYZE table_schema.table_name;")

Refer to PostgreSQL documentation for additional #raw("ANALYZE") options.

#anchor("ref-postgresql-pushdown")

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
- #link(label("fn-covar-pop"), raw("covar_pop"))
- #link(label("fn-covar-samp"), raw("covar_samp"))
- #link(label("fn-corr"), raw("corr"))
- #link(label("fn-regr-intercept"), raw("regr_intercept"))
- #link(label("fn-regr-slope"), raw("regr_slope"))

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

=== Predicate pushdown support

Predicates are pushed down for most types, including #raw("UUID") and temporal types, such as #raw("DATE").

The connector does not support pushdown of range predicates, such as #raw(">"), #raw("<"), or #raw("BETWEEN"), on columns with #link(label("ref-string-data-types"))[character string types] like #raw("CHAR") or #raw("VARCHAR").  Equality predicates, such as #raw("IN") or #raw("="), and inequality predicates, such as #raw("!=") on columns with textual types are pushed down. This ensures correctness of results since the remote data source may sort strings differently than Trino.

In the following example, the predicate of the first query is not pushed down since #raw("name") is a column of type #raw("VARCHAR") and #raw(">") is a range predicate. The other queries are pushed down.

#code-block("sql", "-- Not pushed down
SELECT * FROM nation WHERE name > 'CANADA';
-- Pushed down
SELECT * FROM nation WHERE name != 'CANADA';
SELECT * FROM nation WHERE name = 'CANADA';")

There is experimental support to enable pushdown of range predicates on columns with character string types which can be enabled by setting the #raw("postgresql.experimental.enable-string-pushdown-with-collate") catalog configuration property or the corresponding #raw("enable_string_pushdown_with_collate") session property to #raw("true"). Enabling this configuration will make the predicate of all the queries in the above example get pushed down.
