#import "/lib/trino-docs.typ": *

#anchor("doc-connector-mariadb")
= MariaDB connector

The MariaDB connector allows querying and creating tables in an external MariaDB database.

== Requirements

To connect to MariaDB, you need:

- MariaDB version 10.10 or higher.
- Network access from the Trino coordinator and workers to MariaDB. Port 3306 is the default port.

== Configuration

To configure the MariaDB connector, create a catalog properties file in #raw("etc/catalog") named, for example, #raw("example.properties"), to mount the MariaDB connector as the #raw("example") catalog. Create the file with the following contents, replacing the connection properties as appropriate for your setup:

#code-block("text", "connector.name=mariadb
connection-url=jdbc:mariadb://example.net:3306
connection-user=root
connection-password=secret")

The #raw("connection-user") and #raw("connection-password") are typically required and determine the user credentials for the connection, often a service user. You can use #link(label("doc-security-secrets"))[secrets] to avoid actual values in the catalog properties files.

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

#anchor("ref-mariadb-fte-support")

=== Fault-tolerant execution support

The connector supports #link(label("doc-admin-fault-tolerant-execution"))[Fault-tolerant execution] of query processing. Read and write operations are both supported with any retry policy.

== Querying MariaDB

The MariaDB connector provides a schema for every MariaDB #emph[database]. You can see the available MariaDB databases by running #raw("SHOW SCHEMAS"):

#code-block(none, "SHOW SCHEMAS FROM example;")

If you have a MariaDB database named #raw("web"), you can view the tables in this database by running #raw("SHOW TABLES"):

#code-block(none, "SHOW TABLES FROM example.web;")

You can see a list of the columns in the #raw("clicks") table in the #raw("web") database using either of the following:

#code-block(none, "DESCRIBE example.web.clicks;
SHOW COLUMNS FROM example.web.clicks;")

Finally, you can access the #raw("clicks") table in the #raw("web") database:

#code-block(none, "SELECT * FROM example.web.clicks;")

If you used a different name for your catalog properties file, use that catalog name instead of #raw("example") in the above examples.

% mariadb-type-mapping:

== Type mapping

Because Trino and MariaDB each support types that the other does not, this connector #link(label("ref-type-mapping-overview"))[modifies some types] when reading or writing data. Data types may not map the same way in both directions between Trino and the data source. Refer to the following sections for type mapping in each direction.

=== MariaDB type to Trino type mapping

The connector maps MariaDB types to the corresponding Trino types according to the following table:

#list-table((
  ([MariaDB type], [Trino type], [Notes],),
  ([#raw("BOOLEAN")], [#raw("TINYINT")], [#raw("BOOL") and #raw("BOOLEAN") are aliases of #raw("TINYINT(1)")],),
  ([#raw("TINYINT")], [#raw("TINYINT")], [],),
  ([#raw("TINYINT UNSIGNED")], [#raw("SMALLINT")], [],),
  ([#raw("SMALLINT")], [#raw("SMALLINT")], [],),
  ([#raw("SMALLINT UNSIGNED")], [#raw("INTEGER")], [],),
  ([#raw("INT")], [#raw("INTEGER")], [],),
  ([#raw("INT UNSIGNED")], [#raw("BIGINT")], [],),
  ([#raw("BIGINT")], [#raw("BIGINT")], [],),
  ([#raw("BIGINT UNSIGNED")], [#raw("DECIMAL(20, 0)")], [],),
  ([#raw("FLOAT")], [#raw("REAL")], [],),
  ([#raw("DOUBLE")], [#raw("DOUBLE")], [],),
  ([#raw("DECIMAL(p, s)")], [#raw("DECIMAL(p, s)") or #raw("NUMBER")], [Maps to Trino #raw("DECIMAL") when #raw("p ≤ 38"). Otherwise, maps to #raw("NUMBER").],),
  ([#raw("CHAR(n)")], [#raw("CHAR(n)")], [],),
  ([#raw("TINYTEXT")], [#raw("VARCHAR(255)")], [],),
  ([#raw("TEXT")], [#raw("VARCHAR(65535)")], [],),
  ([#raw("MEDIUMTEXT")], [#raw("VARCHAR(16777215)")], [],),
  ([#raw("LONGTEXT")], [#raw("VARCHAR")], [],),
  ([#raw("VARCHAR(n)")], [#raw("VARCHAR(n)")], [],),
  ([#raw("TINYBLOB")], [#raw("VARBINARY")], [],),
  ([#raw("BLOB")], [#raw("VARBINARY")], [],),
  ([#raw("MEDIUMBLOB")], [#raw("VARBINARY")], [],),
  ([#raw("LONGBLOB")], [#raw("VARBINARY")], [],),
  ([#raw("VARBINARY(n)")], [#raw("VARBINARY")], [],),
  ([#raw("DATE")], [#raw("DATE")], [],),
  ([#raw("TIME(n)")], [#raw("TIME(n)")], [],),
  ([#raw("TIMESTAMP(n)")], [#raw("TIMESTAMP(n)")], [MariaDB stores the current timestamp by default. Enable #link("https://mariadb.com/docs/reference/mdb/system-variables/explicit_defaults_for_timestamp/")[explicit\_defaults\_for\_timestamp] to avoid implicit default values and use #raw("NULL") as the default value.],),
  ([#raw("DATETIME(n)")], [#raw("TIMESTAMP(n)")], [],)
), header-rows: 1, title: "MariaDB type to Trino type mapping")

No other types are supported.

=== Trino type mapping to MariaDB type mapping

The connector maps Trino types to the corresponding MariaDB types according to the following table:

#list-table((
  ([Trino type], [MariaDB type], [Notes],),
  ([#raw("BOOLEAN")], [#raw("BOOLEAN")], [],),
  ([#raw("TINYINT")], [#raw("TINYINT")], [],),
  ([#raw("SMALLINT")], [#raw("SMALLINT")], [],),
  ([#raw("INTEGER")], [#raw("INT")], [],),
  ([#raw("BIGINT")], [#raw("BIGINT")], [],),
  ([#raw("REAL")], [#raw("FLOAT")], [],),
  ([#raw("DOUBLE")], [#raw("DOUBLE")], [],),
  ([#raw("DECIMAL(p,s)")], [#raw("DECIMAL(p,s)")], [],),
  ([#raw("CHAR(n)")], [#raw("CHAR(n)")], [],),
  ([#raw("VARCHAR(255)")], [#raw("TINYTEXT")], [Maps on #raw("VARCHAR") of length 255 or less.],),
  ([#raw("VARCHAR(65535)")], [#raw("TEXT")], [Maps on #raw("VARCHAR") of length between 256 and 65535, inclusive.],),
  ([#raw("VARCHAR(16777215)")], [#raw("MEDIUMTEXT")], [Maps on #raw("VARCHAR") of length between 65536 and 16777215, inclusive.],),
  ([#raw("VARCHAR")], [#raw("LONGTEXT")], [#raw("VARCHAR") of length greater than 16777215 and unbounded #raw("VARCHAR") map to #raw("LONGTEXT").],),
  ([#raw("VARBINARY")], [#raw("MEDIUMBLOB")], [],),
  ([#raw("DATE")], [#raw("DATE")], [],),
  ([#raw("TIME(n)")], [#raw("TIME(n)")], [],),
  ([#raw("TIMESTAMP(n)")], [#raw("TIMESTAMP(n)")], [MariaDB stores the current timestamp by default. Enable #raw("explicit_defaults_for_timestamp   <https://mariadb.com/docs/reference/mdb/system-variables/explicit_defaults_for_timestamp/>")\_ to avoid implicit default values and use #raw("NULL") as the default value.],)
), header-rows: 1, title: "Trino type mapping to MariaDB type mapping")

No other types are supported.

Complete list of #link("https://mariadb.com/kb/en/data-types/")[MariaDB data types].

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

#anchor("ref-mariadb-sql-support")

== SQL support

The connector provides read access and write access to data and metadata in a MariaDB database. In addition to the #link(label("ref-sql-globally-available"))[globally available] and #link(label("ref-sql-read-operations"))[read operation] statements, the connector supports the following features:

- #link(label("doc-sql-insert"))[INSERT], see also #link(label("ref-mariadb-insert"))[MariaDB connector]
- #link(label("doc-sql-update"))[UPDATE], see also #link(label("ref-mariadb-update"))[MariaDB connector]
- #link(label("doc-sql-delete"))[DELETE], see also #link(label("ref-mariadb-delete"))[MariaDB connector]
- #link(label("doc-sql-truncate"))[TRUNCATE]
- #link(label("doc-sql-create-table"))[CREATE TABLE]
- #link(label("doc-sql-create-table-as"))[CREATE TABLE AS]
- #link(label("doc-sql-drop-table"))[DROP TABLE]
- #link(label("doc-sql-alter-table"))[ALTER TABLE]
- #link(label("doc-sql-create-schema"))[CREATE SCHEMA]
- #link(label("doc-sql-drop-schema"))[DROP SCHEMA]
- #link(label("ref-mariadb-procedures"))[MariaDB connector]
- #link(label("ref-mariadb-table-functions"))[MariaDB connector]

#anchor("ref-mariadb-insert")

=== Non-transactional INSERT

The connector supports adding rows using #link(label("doc-sql-insert"))[INSERT statements]. By default, data insertion is performed by writing data to a temporary table. You can skip this step to improve performance and write directly to the target table. Set the #raw("insert.non-transactional-insert.enabled") catalog property or the corresponding #raw("non_transactional_insert") catalog session property to #raw("true").

Note that with this property enabled, data can be corrupted in rare cases where exceptions occur during the insert operation. With transactions disabled, no rollback can be performed.

#anchor("ref-mariadb-update")

=== UPDATE limitation

Only #raw("UPDATE") statements with constant assignments and predicates are supported. For example, the following statement is supported because the values assigned are constants:

#code-block("sql", "UPDATE table SET col1 = 1 WHERE col3 = 1")

Arithmetic expressions, function calls, and other non-constant #raw("UPDATE") statements are not supported. For example, the following statement is not supported because arithmetic expressions cannot be used with the #raw("SET") command:

#code-block("sql", "UPDATE table SET col1 = col2 + 2 WHERE col3 = 1")

All column values of a table row cannot be updated simultaneously. For a three column table, the following statement is not supported:

#code-block("sql", "UPDATE table SET col1 = 1, col2 = 2, col3 = 3 WHERE col3 = 1")

#anchor("ref-mariadb-delete")

=== DELETE limitation

If a #raw("WHERE") clause is specified, the #raw("DELETE") operation only works if the predicate in the clause can be fully pushed down to the data source.

#anchor("ref-mariadb-procedures")

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

#anchor("ref-mariadb-table-functions")

=== Table functions

The connector provides specific #link(label("doc-functions-table"))[table functions] to access MariaDB.

#anchor("ref-mariadb-query-function")

==== #raw("query(varchar) -> table")

The #raw("query") function allows you to query the underlying database directly. It requires syntax native to MariaDB, because the full query is pushed down and processed in MariaDB. This can be useful for accessing native features which are not available in Trino or for improving query performance in situations where running a query natively may be faster.

The native query passed to the underlying data source is required to return a table as a result set. Only the data source performs validation or security checks for these queries using its own configuration. Trino does not perform these tasks. Only use passthrough queries to read data.

As an example, query the #raw("example") catalog and select the age of employees by using #raw("TIMESTAMPDIFF") and #raw("CURDATE"):

#code-block(none, "SELECT
  age
FROM
  TABLE(
    example.system.query(
      query => 'SELECT
        TIMESTAMPDIFF(
          YEAR,
          date_of_birth,
          CURDATE()
        ) AS age
      FROM
        tiny.employees'
    )
  );")

#note[
The query engine does not preserve the order of the results of this function. If the passed query contains an #raw("ORDER BY") clause, the function result may not be ordered as expected.
]

== Performance

The connector includes a number of performance improvements, detailed in the following sections.

#anchor("ref-mariadb-table-statistics")

=== Table statistics

The MariaDB connector can use #link(label("doc-optimizer-statistics"))[table and column statistics] for #link(label("doc-optimizer-cost-based-optimizations"))[cost based optimizations] to improve query processing performance based on the actual data in the data source.

The statistics are collected by MariaDB and retrieved by the connector.

To collect statistics for a table, execute the following statement in MariaDB.

#code-block("text", "ANALYZE TABLE table_name;")

Refer to #link("https://mariadb.com/kb/en/analyze-table/")[MariaDB documentation] for additional information.

#anchor("ref-mariadb-pushdown")

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

==== Predicate pushdown support

The connector does not support pushdown of any predicates on columns with #link(label("ref-string-data-types"))[textual types] like #raw("CHAR") or #raw("VARCHAR"). This ensures correctness of results since the data source may compare strings case-insensitively.

In the following example, the predicate is not pushed down for either query since #raw("name") is a column of type #raw("VARCHAR"):

#code-block("sql", "SELECT * FROM nation WHERE name > 'CANADA';
SELECT * FROM nation WHERE name = 'CANADA';")
