#import "/lib/trino-docs.typ": *

#anchor("doc-connector-singlestore")
= SingleStore connector

The SingleStore \(formerly known as MemSQL\) connector allows querying and creating tables in an external SingleStore database.

== Requirements

To connect to SingleStore, you need:

- SingleStore version 8.7 or higher.
- Network access from the Trino coordinator and workers to SingleStore. Port 3306 is the default port.

#anchor("ref-singlestore-configuration")

== Configuration

To configure the SingleStore connector, create a catalog properties file in #raw("etc/catalog") named, for example, #raw("example.properties"), to mount the SingleStore connector as the #raw("example") catalog. Create the file with the following contents, replacing the connection properties as appropriate for your setup:

#code-block("text", "connector.name=singlestore
connection-url=jdbc:singlestore://example.net:3306
connection-user=root
connection-password=secret")

The #raw("connection-url") defines the connection information and parameters to pass to the SingleStore JDBC driver. The supported parameters for the URL are available in the #link("https://docs.singlestore.com/db/latest/developer-resources/connect-with-application-development-tools/connect-with-java-jdbc/the-singlestore-jdbc-driver/#connection-string-parameters")[SingleStore JDBC driver documentation].

The #raw("connection-user") and #raw("connection-password") are typically required and determine the user credentials for the connection, often a service user. You can use #link(label("doc-security-secrets"))[secrets] to avoid actual values in the catalog properties files.

#anchor("ref-singlestore-tls")

=== Connection security

If you have TLS configured with a globally-trusted certificate installed on your data source, you can enable TLS between your cluster and the data source by appending a parameter to the JDBC connection string set in the #raw("connection-url") catalog configuration property.

Enable TLS between your cluster and SingleStore by appending the #raw("useSsl=true") parameter to the #raw("connection-url") configuration property:

#code-block("properties", "connection-url=jdbc:singlestore://example.net:3306/?useSsl=true")

For more information on TLS configuration options, see the #link("https://docs.singlestore.com/db/latest/developer-resources/connect-with-application-development-tools/connect-with-java-jdbc/the-singlestore-jdbc-driver/#tls-")[JDBC driver documentation].

=== Multiple SingleStore servers

You can have as many catalogs as you need, so if you have additional SingleStore servers, simply add another properties file to #raw("etc/catalog") with a different name \(making sure it ends in #raw(".properties")\). For example, if you name the property file #raw("sales.properties"), Trino will create a catalog named #raw("sales") using the configured connector.

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

== Querying SingleStore

The SingleStore connector provides a schema for every SingleStore #emph[database]. You can see the available SingleStore databases by running #raw("SHOW SCHEMAS"):

#code-block(none, "SHOW SCHEMAS FROM example;")

If you have a SingleStore database named #raw("web"), you can view the tables in this database by running #raw("SHOW TABLES"):

#code-block(none, "SHOW TABLES FROM example.web;")

You can see a list of the columns in the #raw("clicks") table in the #raw("web") database using either of the following:

#code-block(none, "DESCRIBE example.web.clicks;
SHOW COLUMNS FROM example.web.clicks;")

Finally, you can access the #raw("clicks") table in the #raw("web") database:

#code-block(none, "SELECT * FROM example.web.clicks;")

If you used a different name for your catalog properties file, use that catalog name instead of #raw("example") in the above examples.

#anchor("ref-singlestore-type-mapping")

== Type mapping

Because Trino and Singlestore each support types that the other does not, this connector #link(label("ref-type-mapping-overview"))[modifies some types] when reading or writing data. Data types may not map the same way in both directions between Trino and the data source. Refer to the following sections for type mapping in each direction.

=== Singlestore to Trino type mapping

The connector maps Singlestore types to the corresponding Trino types following this table:

#list-table((
  ([Singlestore type], [Trino type], [Notes],),
  ([#raw("BIT")], [#raw("BOOLEAN")], [],),
  ([#raw("BOOLEAN")], [#raw("BOOLEAN")], [],),
  ([#raw("TINYINT")], [#raw("TINYINT")], [],),
  ([#raw("TINYINT UNSIGNED")], [#raw("SMALLINT")], [],),
  ([#raw("SMALLINT")], [#raw("SMALLINT")], [],),
  ([#raw("SMALLINT UNSIGNED")], [#raw("INTEGER")], [],),
  ([#raw("INTEGER")], [#raw("INTEGER")], [],),
  ([#raw("INTEGER UNSIGNED")], [#raw("BIGINT")], [],),
  ([#raw("BIGINT")], [#raw("BIGINT")], [],),
  ([#raw("BIGINT UNSIGNED")], [#raw("DECIMAL(20, 0)")], [],),
  ([#raw("DOUBLE")], [#raw("DOUBLE")], [],),
  ([#raw("REAL")], [#raw("DOUBLE")], [],),
  ([#raw("DECIMAL(p, s)")], [#raw("DECIMAL(p, s)") or #raw("NUMBER")], [Maps to Trino #raw("DECIMAL") when #raw("p ≤ 38"). Otherwise, maps to #raw("NUMBER").],),
  ([#raw("CHAR(n)")], [#raw("CHAR(n)")], [],),
  ([#raw("TINYTEXT")], [#raw("VARCHAR(255)")], [],),
  ([#raw("TEXT")], [#raw("VARCHAR(65535)")], [],),
  ([#raw("MEDIUMTEXT")], [#raw("VARCHAR(16777215)")], [],),
  ([#raw("LONGTEXT")], [#raw("VARCHAR")], [],),
  ([#raw("VARCHAR(n)")], [#raw("VARCHAR(n)")], [],),
  ([#raw("LONGBLOB")], [#raw("VARBINARY")], [],),
  ([#raw("DATE")], [#raw("DATE")], [],),
  ([#raw("TIME")], [#raw("TIME(0)")], [],),
  ([#raw("TIME(6)")], [#raw("TIME(6)")], [],),
  ([#raw("DATETIME")], [#raw("TIMESTAMP(0)")], [],),
  ([#raw("DATETIME(6)")], [#raw("TIMESTAMP(6)")], [],),
  ([#raw("JSON")], [#raw("JSON")], [],)
), header-rows: 1, title: "Singlestore to Trino type mapping")

No other types are supported.

=== Trino to Singlestore type mapping

The connector maps Trino types to the corresponding Singlestore types following this table:

#list-table((
  ([Trino type], [Singlestore type], [Notes],),
  ([#raw("BOOLEAN")], [#raw("BOOLEAN")], [],),
  ([#raw("TINYINT")], [#raw("TINYINT")], [],),
  ([#raw("SMALLINT")], [#raw("SMALLINT")], [],),
  ([#raw("INTEGER")], [#raw("INTEGER")], [],),
  ([#raw("BIGINT")], [#raw("BIGINT")], [],),
  ([#raw("DOUBLE")], [#raw("DOUBLE")], [],),
  ([#raw("REAL")], [#raw("FLOAT")], [],),
  ([#raw("DECIMAL(p, s)")], [#raw("DECIMAL(p, s)")], [],),
  ([#raw("CHAR(n)")], [#raw("CHAR(n)")], [],),
  ([#raw("VARCHAR(65535)")], [#raw("TEXT")], [],),
  ([#raw("VARCHAR(16777215)")], [#raw("MEDIUMTEXT")], [],),
  ([#raw("VARCHAR")], [#raw("LONGTEXT")], [],),
  ([#raw("VARCHAR(n)")], [#raw("VARCHAR(n)")], [],),
  ([#raw("VARBINARY")], [#raw("LONGBLOB")], [],),
  ([#raw("DATE")], [#raw("DATE")], [],),
  ([#raw("TIME(0)")], [#raw("TIME")], [],),
  ([#raw("TIME(6)")], [#raw("TIME(6)")], [],),
  ([#raw("TIMESTAMP(0)")], [#raw("DATETIME")], [],),
  ([#raw("TIMESTAMP(6)")], [#raw("DATETIME(6)")], [],),
  ([#raw("JSON")], [#raw("JSON")], [],)
), header-rows: 1, title: "Trino to Singlestore type mapping")

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

#anchor("ref-singlestore-sql-support")

== SQL support

The connector provides read access and write access to data and metadata in a SingleStore database.  In addition to the #link(label("ref-sql-globally-available"))[globally available] and #link(label("ref-sql-read-operations"))[read operation] statements, the connector supports the following features:

- #link(label("doc-sql-insert"))[INSERT], see also #link(label("ref-singlestore-insert"))[SingleStore connector]
- #link(label("doc-sql-update"))[UPDATE], see also #link(label("ref-singlestore-update"))[SingleStore connector]
- #link(label("doc-sql-delete"))[DELETE], see also #link(label("ref-singlestore-delete"))[SingleStore connector]
- #link(label("doc-sql-truncate"))[TRUNCATE]
- #link(label("doc-sql-create-table"))[CREATE TABLE]
- #link(label("doc-sql-create-table-as"))[CREATE TABLE AS]
- #link(label("doc-sql-alter-table"))[ALTER TABLE], see also #link(label("ref-singlestore-alter-table"))[SingleStore connector]
- #link(label("doc-sql-drop-table"))[DROP TABLE]
- #link(label("doc-sql-create-schema"))[CREATE SCHEMA]
- #link(label("doc-sql-drop-schema"))[DROP SCHEMA]
- #link(label("ref-singlestore-procedures"))[SingleStore connector]

#anchor("ref-singlestore-insert")

=== Non-transactional INSERT

The connector supports adding rows using #link(label("doc-sql-insert"))[INSERT statements]. By default, data insertion is performed by writing data to a temporary table. You can skip this step to improve performance and write directly to the target table. Set the #raw("insert.non-transactional-insert.enabled") catalog property or the corresponding #raw("non_transactional_insert") catalog session property to #raw("true").

Note that with this property enabled, data can be corrupted in rare cases where exceptions occur during the insert operation. With transactions disabled, no rollback can be performed.

#anchor("ref-singlestore-update")

=== UPDATE limitation

Only #raw("UPDATE") statements with constant assignments and predicates are supported. For example, the following statement is supported because the values assigned are constants:

#code-block("sql", "UPDATE table SET col1 = 1 WHERE col3 = 1")

Arithmetic expressions, function calls, and other non-constant #raw("UPDATE") statements are not supported. For example, the following statement is not supported because arithmetic expressions cannot be used with the #raw("SET") command:

#code-block("sql", "UPDATE table SET col1 = col2 + 2 WHERE col3 = 1")

All column values of a table row cannot be updated simultaneously. For a three column table, the following statement is not supported:

#code-block("sql", "UPDATE table SET col1 = 1, col2 = 2, col3 = 3 WHERE col3 = 1")

#anchor("ref-singlestore-delete")

=== DELETE limitation

If a #raw("WHERE") clause is specified, the #raw("DELETE") operation only works if the predicate in the clause can be fully pushed down to the data source.

#anchor("ref-singlestore-alter-table")

=== ALTER TABLE RENAME TO limitation

The connector does not support renaming tables across multiple schemas. For example, the following statement is supported:

#code-block("sql", "ALTER TABLE example.schema_one.table_one RENAME TO example.schema_one.table_two")

The following statement attempts to rename a table across schemas, and therefore is not supported:

#code-block("sql", "ALTER TABLE example.schema_one.table_one RENAME TO example.schema_two.table_two")

#anchor("ref-singlestore-procedures")

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

== Performance

The connector includes a number of performance improvements, detailed in the following sections.

#anchor("ref-singlestore-pushdown")

=== Pushdown

The connector supports pushdown for a number of operations:

- #link(label("ref-join-pushdown"))[join-pushdown]
- #link(label("ref-limit-pushdown"))[limit-pushdown]
- #link(label("ref-topn-pushdown"))[topn-pushdown]

#note[
The connector performs pushdown where performance may be improved, but in order to preserve correctness an operation may not be pushed down. When pushdown of an operation may result in better performance but risks correctness, the connector prioritizes correctness.
]

==== Join pushdown

The #raw("join-pushdown.enabled") catalog configuration property or #raw("join_pushdown_enabled") #link(label("ref-session-properties-definition"))[catalog session property] control whether the connector pushes down join operations. The property defaults to #raw("false"), and enabling join pushdowns may negatively impact performance for some queries.

==== Predicate pushdown support

The connector does not support pushdown of any predicates on columns with #link(label("ref-string-data-types"))[textual types] like #raw("CHAR") or #raw("VARCHAR"). This ensures correctness of results since the data source may compare strings case-insensitively.

In the following example, the predicate is not pushed down for either query since #raw("name") is a column of type #raw("VARCHAR"):

#code-block("sql", "SELECT * FROM nation WHERE name > 'CANADA';
SELECT * FROM nation WHERE name = 'CANADA';")
