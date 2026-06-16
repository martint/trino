#import "/lib/trino-docs.typ": *

#anchor("doc-connector-oracle")
= Oracle connector

The Oracle connector allows querying and creating tables in an external Oracle database. Connectors let Trino join data provided by different databases, like Oracle and Hive, or different Oracle database instances.

== Requirements

To connect to Oracle, you need:

- Oracle 23 or higher.
- Network access from the Trino coordinator and workers to Oracle. Port 1521 is the default port.

== Configuration

To configure the Oracle connector as the #raw("example") catalog, create a file named #raw("example.properties") in #raw("etc/catalog"). Include the following connection properties in the file:

#code-block("text", "connector.name=oracle
# The correct syntax of the connection-url varies by Oracle version and
# configuration. The following example URL connects to an Oracle SID named
# \"orcl\".
connection-url=jdbc:oracle:thin:@example.net:1521:orcl
connection-user=root
connection-password=secret")

The #raw("connection-url") defines the connection information and parameters to pass to the JDBC driver. The Oracle connector uses the Oracle JDBC Thin driver, and the syntax of the URL may be different depending on your Oracle configuration. For example, the connection URL is different if you are connecting to an Oracle SID or an Oracle service name. See the #link("https://docs.oracle.com/en/database/oracle/oracle-database/19/jjdbc/data-sources-and-URLs.html")[Oracle Database JDBC driver documentation] for more information.

The #raw("connection-user") and #raw("connection-password") are typically required and determine the user credentials for the connection, often a service user. You can use #link(label("doc-security-secrets"))[secrets] to avoid actual values in the catalog properties files.

#note[
Oracle does not expose metadata comment via #raw("REMARKS") column by default in JDBC driver. You can enable it using #raw("oracle.remarks-reporting.enabled") config option. See #link("https://docs.oracle.com/en/database/oracle/oracle-database/19/jjdbc/performance-extensions.html")[Additional Oracle Performance Extensions] for more details.
]

By default, the Oracle connector uses connection pooling for performance improvement. The below configuration shows the typical default values. To update them, change the properties in the catalog configuration file:

#code-block("properties", "oracle.connection-pool.max-size=30
oracle.connection-pool.min-size=1
oracle.connection-pool.inactive-timeout=20m
oracle.connection-pool.wait-duration=3s")

To disable connection pooling, update properties to include the following:

#code-block("text", "oracle.connection-pool.enabled=false")

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

=== Multiple Oracle servers

If you want to connect to multiple Oracle servers, configure another instance of the Oracle connector as a separate catalog.

To add another Oracle catalog, create a new properties file. For example, if you name the property file #raw("sales.properties"), Trino creates a catalog named #raw("sales").

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

#anchor("ref-oracle-fte-support")

=== Fault-tolerant execution support

The connector supports #link(label("doc-admin-fault-tolerant-execution"))[Fault-tolerant execution] of query processing. Read and write operations are both supported with any retry policy.

== Querying Oracle

The Oracle connector provides a schema for every Oracle database.

Run #raw("SHOW SCHEMAS") to see the available Oracle databases:

#code-block(none, "SHOW SCHEMAS FROM example;")

If you used a different name for your catalog properties file, use that catalog name instead of #raw("example").

#note[
The Oracle user must have access to the table in order to access it from Trino. The user configuration, in the connection properties file, determines your privileges in these schemas.
]

=== Examples

If you have an Oracle database named #raw("web"), run #raw("SHOW TABLES") to see the tables it contains:

#code-block(none, "SHOW TABLES FROM example.web;")

To see a list of the columns in the #raw("clicks") table in the #raw("web") database, run either of the following:

#code-block(none, "DESCRIBE example.web.clicks;
SHOW COLUMNS FROM example.web.clicks;")

To access the clicks table in the web database, run the following:

#code-block(none, "SELECT * FROM example.web.clicks;")

#anchor("ref-oracle-type-mapping")

== Type mapping

Because Trino and Oracle each support types that the other does not, this connector #link(label("ref-type-mapping-overview"))[modifies some types] when reading or writing data. Data types may not map the same way in both directions between Trino and the data source. Refer to the following sections for type mapping in each direction.

=== Oracle to Trino type mapping

Trino supports selecting Oracle database types. This table shows the Oracle to Trino data type mapping:

#list-table((
  ([Oracle database type], [Trino type], [Notes],),
  ([#raw("NUMBER(p, s)")], [#raw("DECIMAL(pʹ, sʹ)") or #raw("NUMBER")], [Maps to Trino #raw("DECIMAL") when input data can be represented as Trino #raw("DECIMAL") losslessly. When #raw("1 ≤ p ≤ 38") and #raw("0 ≤ s ≤ p"), then #raw("pʹ = p") and #raw("sʹ = s"), otherwise, a wider type is used.  \
When input cannot be represented as Trino #raw("DECIMAL") losslessly, maps to #raw("NUMBER").],),
  ([#raw("NUMBER")], [#raw("NUMBER")], [],),
  ([#raw("FLOAT[(p)]")], [#raw("DOUBLE")], [When #raw("p") exceeds 53, numeric values may be subject to precision loss. The default precision of the #link("https://docs.oracle.com/javadb/10.6.2.1/ref/rrefsqlj27281.html")[FLOAT data type] in Oracle is 53.],),
  ([#raw("BINARY_FLOAT")], [#raw("REAL")], [],),
  ([#raw("BINARY_DOUBLE")], [#raw("DOUBLE")], [],),
  ([#raw("VARCHAR2(n CHAR)")], [#raw("VARCHAR(n)")], [],),
  ([#raw("VARCHAR2(n BYTE)")], [#raw("VARCHAR(n)")], [],),
  ([#raw("NVARCHAR2(n)")], [#raw("VARCHAR(n)")], [],),
  ([#raw("CHAR(n)")], [#raw("CHAR(n)")], [],),
  ([#raw("NCHAR(n)")], [#raw("CHAR(n)")], [],),
  ([#raw("CLOB")], [#raw("VARCHAR")], [],),
  ([#raw("NCLOB")], [#raw("VARCHAR")], [],),
  ([#raw("RAW(n)")], [#raw("VARBINARY")], [],),
  ([#raw("BLOB")], [#raw("VARBINARY")], [],),
  ([#raw("DATE")], [#raw("TIMESTAMP(0)")], [See #link(label("ref-oracle-datetime-mapping"))[Oracle connector]],),
  ([#raw("TIMESTAMP(p)")], [#raw("TIMESTAMP(p)")], [See #link(label("ref-oracle-datetime-mapping"))[Oracle connector]],),
  ([#raw("TIMESTAMP(p) WITH TIME ZONE")], [#raw("TIMESTAMP WITH TIME ZONE")], [See #link(label("ref-oracle-datetime-mapping"))[Oracle connector]],)
), header-rows: 1, title: "Oracle to Trino type mapping")

No other types are supported.

=== Trino to Oracle type mapping

Trino supports creating tables with the following types in an Oracle database. The table shows the mappings from Trino to Oracle data types:

#note[
For types not listed in the table below, Trino can't perform the #raw("CREATE TABLE <table> AS SELECT") operations. When data is inserted into existing tables, #raw("Oracle to Trino") type mapping is used.
]

#list-table((
  ([Trino type], [Oracle database type], [Notes],),
  ([#raw("TINYINT")], [#raw("NUMBER(3)")], [],),
  ([#raw("SMALLINT")], [#raw("NUMBER(5)")], [],),
  ([#raw("INTEGER")], [#raw("NUMBER(10)")], [],),
  ([#raw("BIGINT")], [#raw("NUMBER(19)")], [],),
  ([#raw("DECIMAL(p, s)")], [#raw("NUMBER(p, s)")], [],),
  ([#raw("NUMBER")], [#raw("NUMBER")], [],),
  ([#raw("REAL")], [#raw("BINARY_FLOAT")], [],),
  ([#raw("DOUBLE")], [#raw("BINARY_DOUBLE")], [],),
  ([#raw("VARCHAR")], [#raw("NCLOB")], [],),
  ([#raw("VARCHAR(n)")], [#raw("VARCHAR2(n CHAR)") or #raw("NCLOB")], [See #link(label("ref-oracle-character-mapping"))[Oracle connector]],),
  ([#raw("CHAR(n)")], [#raw("CHAR(n CHAR)") or #raw("NCLOB")], [See #link(label("ref-oracle-character-mapping"))[Oracle connector]],),
  ([#raw("VARBINARY")], [#raw("BLOB")], [],),
  ([#raw("DATE")], [#raw("DATE")], [See #link(label("ref-oracle-datetime-mapping"))[Oracle connector]],),
  ([#raw("TIMESTAMP")], [#raw("TIMESTAMP(3)")], [See #link(label("ref-oracle-datetime-mapping"))[Oracle connector]],),
  ([#raw("TIMESTAMP WITH TIME ZONE")], [#raw("TIMESTAMP(3) WITH TIME ZONE")], [See #link(label("ref-oracle-datetime-mapping"))[Oracle connector]],)
), header-rows: 1, title: "Trino to Oracle Type Mapping")

No other types are supported.

#anchor("ref-oracle-datetime-mapping")

=== Mapping datetime types

Writing a timestamp with fractional second precision \(#raw("p")\) greater than 9 rounds the fractional seconds to nine digits.

Oracle #raw("DATE") type stores hours, minutes, and seconds, so it is mapped to Trino #raw("TIMESTAMP(0)").

#warning[
Due to date and time differences in the libraries used by Trino and the Oracle JDBC driver, attempting to insert or select a datetime value earlier than #raw("1582-10-15") results in an incorrect date inserted.
]

#anchor("ref-oracle-character-mapping")

=== Mapping character types

Trino's #raw("VARCHAR(n)") maps to #raw("VARCHAR2(n CHAR)") if #raw("n") is no greater than 4000. A larger or unbounded #raw("VARCHAR") maps to #raw("NCLOB").

Trino's #raw("CHAR(n)") maps to #raw("CHAR(n CHAR)") if #raw("n") is no greater than 2000. A larger #raw("CHAR") maps to #raw("NCLOB").

Using #raw("CREATE TABLE AS") to create an #raw("NCLOB") column from a #raw("CHAR") value removes the trailing spaces from the initial values for the column. Inserting #raw("CHAR") values into existing #raw("NCLOB") columns keeps the trailing spaces. For example:

#code-block(none, "CREATE TABLE vals AS SELECT CAST('A' as CHAR(2001)) col;
INSERT INTO vals (col) VALUES (CAST('BB' as CHAR(2001)));
SELECT LENGTH(col) FROM vals;")

#code-block("text", " _col0
-------
  2001
     1
(2 rows)")

Attempting to write a #raw("CHAR") that doesn't fit in the column's actual size fails. This is also true for the equivalent #raw("VARCHAR") types.

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

=== Number to decimal configuration properties

#list-table((
  ([Configuration property name], [Session property name], [Description], [Default],),
  ([#raw("oracle.number.default-scale")], [#raw("number_default_scale")], [Default Trino #raw("DECIMAL") scale for Oracle #raw("NUMBER") \(without precision and scale\) date type. When not set then such column is treated as not supported.], [not set],),
  ([#raw("oracle.number.rounding-mode")], [#raw("number_rounding_mode")], [Rounding mode for the Oracle #raw("NUMBER") data type. This is useful when Oracle #raw("NUMBER") data type specifies higher scale than is supported in Trino. Possible values are:

- #raw("UNNECESSARY") - Rounding mode to assert that the requested operation has an exact result, hence no rounding is necessary.
- #raw("CEILING") - Rounding mode to round towards positive infinity.
- #raw("FLOOR") - Rounding mode to round towards negative infinity.
- #raw("HALF_DOWN") - Rounding mode to round towards #raw("nearest neighbor") unless both neighbors are equidistant, in which case rounding down is used.
- #raw("HALF_EVEN") - Rounding mode to round towards the #raw("nearest neighbor") unless both neighbors are equidistant, in which case rounding towards the even neighbor is performed.
- #raw("HALF_UP") - Rounding mode to round towards #raw("nearest neighbor") unless both neighbors are equidistant, in which case rounding up is used
- #raw("UP") - Rounding mode to round towards zero.
- #raw("DOWN") - Rounding mode to round towards zero.], [#raw("UNNECESSARY")],)
), header-rows: 1)

#anchor("ref-oracle-sql-support")

== SQL support

The connector provides read access and write access to data and metadata in Oracle. In addition to the #link(label("ref-sql-globally-available"))[globally available] and #link(label("ref-sql-read-operations"))[read operation] statements, the connector supports the following features:

- #link(label("doc-sql-insert"))[INSERT], see also #link(label("ref-oracle-insert"))[Oracle connector]
- #link(label("doc-sql-update"))[UPDATE], see also #link(label("ref-oracle-update"))[Oracle connector]
- #link(label("doc-sql-delete"))[DELETE], see also #link(label("ref-oracle-delete"))[Oracle connector]
- #link(label("doc-sql-truncate"))[TRUNCATE]
- #link(label("doc-sql-create-table"))[CREATE TABLE]
- #link(label("doc-sql-create-table-as"))[CREATE TABLE AS]
- #link(label("doc-sql-drop-table"))[DROP TABLE]
- #link(label("doc-sql-alter-table"))[ALTER TABLE], see also #link(label("ref-oracle-alter-table"))[Oracle connector]
- #link(label("doc-sql-comment"))[COMMENT]
- #link(label("ref-oracle-procedures"))[Oracle connector]
- #link(label("ref-oracle-table-functions"))[Oracle connector]

#anchor("ref-oracle-insert")

=== Non-transactional INSERT

The connector supports adding rows using #link(label("doc-sql-insert"))[INSERT statements]. By default, data insertion is performed by writing data to a temporary table. You can skip this step to improve performance and write directly to the target table. Set the #raw("insert.non-transactional-insert.enabled") catalog property or the corresponding #raw("non_transactional_insert") catalog session property to #raw("true").

Note that with this property enabled, data can be corrupted in rare cases where exceptions occur during the insert operation. With transactions disabled, no rollback can be performed.

#anchor("ref-oracle-update")

=== UPDATE limitation

Only #raw("UPDATE") statements with constant assignments and predicates are supported. For example, the following statement is supported because the values assigned are constants:

#code-block("sql", "UPDATE table SET col1 = 1 WHERE col3 = 1")

Arithmetic expressions, function calls, and other non-constant #raw("UPDATE") statements are not supported. For example, the following statement is not supported because arithmetic expressions cannot be used with the #raw("SET") command:

#code-block("sql", "UPDATE table SET col1 = col2 + 2 WHERE col3 = 1")

All column values of a table row cannot be updated simultaneously. For a three column table, the following statement is not supported:

#code-block("sql", "UPDATE table SET col1 = 1, col2 = 2, col3 = 3 WHERE col3 = 1")

#anchor("ref-oracle-delete")

=== DELETE limitation

If a #raw("WHERE") clause is specified, the #raw("DELETE") operation only works if the predicate in the clause can be fully pushed down to the data source.

#anchor("ref-oracle-alter-table")

=== ALTER TABLE RENAME TO limitation

The connector does not support renaming tables across multiple schemas. For example, the following statement is supported:

#code-block("sql", "ALTER TABLE example.schema_one.table_one RENAME TO example.schema_one.table_two")

The following statement attempts to rename a table across schemas, and therefore is not supported:

#code-block("sql", "ALTER TABLE example.schema_one.table_one RENAME TO example.schema_two.table_two")

#anchor("ref-oracle-procedures")

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

#anchor("ref-oracle-table-functions")

=== Table functions

The connector provides specific #link(label("doc-functions-table"))[table functions] to access Oracle.

#anchor("ref-oracle-query-function")

==== #raw("query(varchar) -> table")

The #raw("query") function allows you to query the underlying database directly. It requires syntax native to Oracle, because the full query is pushed down and processed in Oracle. This can be useful for accessing native features which are not available in Trino or for improving query performance in situations where running a query natively may be faster.

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

As a practical example, you can use the #link("https://docs.oracle.com/cd/B19306_01/server.102/b14223/sqlmodel.htm")[MODEL clause from Oracle SQL]:

#code-block(none, "SELECT
  SUBSTR(country, 1, 20) country,
  SUBSTR(product, 1, 15) product,
  year,
  sales
FROM
  TABLE(
    example.system.query(
      query => 'SELECT
        *
      FROM
        sales_view
      MODEL
        RETURN UPDATED ROWS
        MAIN
          simple_model
        PARTITION BY
          country
        MEASURES
          sales
        RULES
          (sales['Bounce', 2001] = 1000,
          sales['Bounce', 2002] = sales['Bounce', 2001] + sales['Bounce', 2000],
          sales['Y Box', 2002] = sales['Y Box', 2001])
      ORDER BY
        country'
    )
  );")

#note[
The query engine does not preserve the order of the results of this function. If the passed query contains an #raw("ORDER BY") clause, the function result may not be ordered as expected.
]

== Performance

The connector includes a number of performance improvements, detailed in the following sections.

=== Synonyms

Based on performance reasons, Trino disables support for Oracle #raw("SYNONYM"). To include #raw("SYNONYM"), add the following configuration property:

#code-block("text", "oracle.synonyms.enabled=true")

#anchor("ref-oracle-pushdown")

=== Pushdown

The connector supports pushdown for a number of operations:

- #link(label("ref-join-pushdown"))[join-pushdown]
- #link(label("ref-limit-pushdown"))[limit-pushdown]

In addition, the connector supports #link(label("ref-aggregation-pushdown"))[aggregation-pushdown] for the following functions:

- #link(label("fn-avg"), raw("avg()"))
- #link(label("fn-count"), raw("count()")), also #raw("count(distinct x)")
- #link(label("fn-max"), raw("max()"))
- #link(label("fn-min"), raw("min()"))
- #link(label("fn-sum"), raw("sum()"))

Pushdown is only supported for #raw("DOUBLE") type columns with the following functions:

- #link(label("fn-stddev"), raw("stddev()")) and #link(label("fn-stddev-samp"), raw("stddev_samp()"))
- #link(label("fn-stddev-pop"), raw("stddev_pop()"))
- #link(label("fn-var-pop"), raw("var_pop()"))
- #link(label("fn-variance"), raw("variance()")) and #link(label("fn-var-samp"), raw("var_samp()"))

Pushdown is only supported for #raw("REAL") or #raw("DOUBLE") type column with the following functions:

- #link(label("fn-covar-samp"), raw("covar_samp()"))
- #link(label("fn-covar-pop"), raw("covar_pop()"))

#note[
The connector performs pushdown where performance may be improved, but in order to preserve correctness an operation may not be pushed down. When pushdown of an operation may result in better performance but risks correctness, the connector prioritizes correctness.
]

==== Join pushdown

The #raw("join-pushdown.enabled") catalog configuration property or #raw("join_pushdown_enabled") #link(label("ref-session-properties-definition"))[catalog session property] control whether the connector pushes down join operations. The property defaults to #raw("false"), and enabling join pushdowns may negatively impact performance for some queries.

#anchor("ref-oracle-predicate-pushdown")

==== Predicate pushdown support

The connector does not support pushdown of any predicates on columns that use the #raw("CLOB"), #raw("NCLOB"), #raw("BLOB"), or #raw("RAW(n)") Oracle database types, or Trino data types that #link(label("ref-oracle-type-mapping"))[map] to these Oracle database types.

In the following example, the predicate is not pushed down for either query since #raw("name") is a column of type #raw("VARCHAR"), which maps to #raw("NCLOB") in Oracle:

#code-block("sql", "SHOW CREATE TABLE nation;

--             Create Table
----------------------------------------
-- CREATE TABLE oracle.trino_test.nation (
--    name VARCHAR
-- )
-- (1 row)

SELECT * FROM nation WHERE name > 'CANADA';
SELECT * FROM nation WHERE name = 'CANADA';")

In the following example, the predicate is pushed down for both queries since #raw("name") is a column of type #raw("VARCHAR(25)"), which maps to #raw("VARCHAR2(25)") in Oracle:

#code-block("sql", "SHOW CREATE TABLE nation;

--             Create Table
----------------------------------------
-- CREATE TABLE oracle.trino_test.nation (
--    name VARCHAR(25)
-- )
-- (1 row)

SELECT * FROM nation WHERE name > 'CANADA';
SELECT * FROM nation WHERE name = 'CANADA';")
