#import "/lib/trino-docs.typ": *

#anchor("doc-connector-ignite")
= Ignite connector

The Ignite connector allows querying an #link("https://ignite.apache.org/")[Apache Ignite] database from Trino.

== Requirements

To connect to an Ignite server, you need:

- Ignite version 2.9.0 or latter
- Network access from the Trino coordinator and workers to the Ignite server. Port 10800 is the default port.
- Specify #raw("--add-opens=java.base/java.nio=ALL-UNNAMED") in the #raw("jvm.config") when starting the Trino server.

== Configuration

The Ignite connector expose #raw("public") schema by default.

The connector can query an Ignite instance. Create a catalog properties file that specifies the Ignite connector by setting the #raw("connector.name") to #raw("ignite").

For example, to access an instance as #raw("example"), create the file #raw("etc/catalog/example.properties"). Replace the connection properties as appropriate for your setup:

#code-block("text", "connector.name=ignite
connection-url=jdbc:ignite:thin://host1:10800/
connection-user=exampleuser
connection-password=examplepassword")

The #raw("connection-url") defines the connection information and parameters to pass to the Ignite JDBC driver. The parameters for the URL are available in the #link("https://ignite.apache.org/docs/latest/SQL/JDBC/jdbc-driver")[Ignite JDBC driver documentation]. Some parameters can have adverse effects on the connector behavior or not work with the connector.

The #raw("connection-user") and #raw("connection-password") are typically required and determine the user credentials for the connection, often a service user. You can use #link(label("doc-security-secrets"))[secrets] to avoid actual values in the catalog properties files.

=== Multiple Ignite servers

If you have multiple Ignite servers you need to configure one catalog for each server. To add another catalog:

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

== Table properties

Table property usage example:

#code-block(none, "CREATE TABLE public.person (
  id BIGINT NOT NULL,
  birthday DATE NOT NULL,
  name VARCHAR(26),
  age BIGINT,
  logdate DATE
)
WITH (
  primary_key = ARRAY['id', 'birthday']
);")

The following are supported Ignite table properties from #link("https://ignite.apache.org/docs/latest/sql-reference/ddl")[https:\/\/ignite.apache.org\/docs\/latest\/sql-reference\/ddl]

#list-table((
  ([Property name], [Required], [Description],),
  ([#raw("primary_key")], [No], [The primary key of the table, can choose multi columns as the table primary key. Table at least contains one column not in primary key.],)
), header-rows: 1)

=== #raw("primary_key")

This is a list of columns to be used as the table's primary key. If not specified, a #raw("VARCHAR") primary key column named #raw("DUMMY_ID") is generated, the value is derived from the value generated by the #raw("UUID") function in Ignite.

#anchor("ref-ignite-type-mapping")

== Type mapping

The following are supported Ignite SQL data types from #link("https://ignite.apache.org/docs/latest/sql-reference/data-types")[https:\/\/ignite.apache.org\/docs\/latest\/sql-reference\/data-types]

#list-table((
  ([Ignite SQL data type name], [Map to Trino type], [Possible values],),
  ([#raw("BOOLEAN")], [#raw("BOOLEAN")], [#raw("TRUE") and #raw("FALSE")],),
  ([#raw("BIGINT")], [#raw("BIGINT")], [#raw("-9223372036854775808"), #raw("9223372036854775807"), etc.],),
  ([#raw("DECIMAL")], [#raw("DECIMAL")], [Data type with fixed precision and scale],),
  ([#raw("DOUBLE")], [#raw("DOUBLE")], [#raw("3.14"), #raw("-10.24"), etc.],),
  ([#raw("INT")], [#raw("INT")], [#raw("-2147483648"), #raw("2147483647"), etc.],),
  ([#raw("REAL")], [#raw("REAL")], [#raw("3.14"), #raw("-10.24"), etc.],),
  ([#raw("SMALLINT")], [#raw("SMALLINT")], [#raw("-32768"), #raw("32767"), etc.],),
  ([#raw("TINYINT")], [#raw("TINYINT")], [#raw("-128"), #raw("127"), etc.],),
  ([#raw("CHAR")], [#raw("CHAR")], [#raw("hello"), #raw("Trino"), etc.],),
  ([#raw("VARCHAR")], [#raw("VARCHAR")], [#raw("hello"), #raw("Trino"), etc.],),
  ([#raw("DATE")], [#raw("DATE")], [#raw("1972-01-01"), #raw("2021-07-15"), etc.],),
  ([#raw("BINARY")], [#raw("VARBINARY")], [Represents a byte array.],)
), header-rows: 1)

#anchor("ref-ignite-sql-support")

== SQL support

The connector provides read access and write access to data and metadata in Ignite.  In addition to the #link(label("ref-sql-globally-available"))[globally available] and #link(label("ref-sql-read-operations"))[read operation] statements, the connector supports the following features:

- #link(label("doc-sql-insert"))[INSERT], see also #link(label("ref-ignite-insert"))[Ignite connector]
- #link(label("doc-sql-update"))[UPDATE], see also #link(label("ref-ignite-update"))[Ignite connector]
- #link(label("doc-sql-delete"))[DELETE]
- #link(label("doc-sql-merge"))[MERGE], see also #link(label("ref-ignite-merge"))[Ignite connector]
- #link(label("doc-sql-create-table"))[CREATE TABLE]
- #link(label("doc-sql-create-table-as"))[CREATE TABLE AS]
- #link(label("doc-sql-drop-table"))[DROP TABLE]
- #link(label("doc-sql-alter-table"))[ALTER TABLE], see also #link(label("ref-ignite-alter-table"))[Ignite connector]
- #link(label("ref-ignite-procedures"))[Ignite connector]

#anchor("ref-ignite-insert")

=== Non-transactional INSERT

The connector supports adding rows using #link(label("doc-sql-insert"))[INSERT statements]. By default, data insertion is performed by writing data to a temporary table. You can skip this step to improve performance and write directly to the target table. Set the #raw("insert.non-transactional-insert.enabled") catalog property or the corresponding #raw("non_transactional_insert") catalog session property to #raw("true").

Note that with this property enabled, data can be corrupted in rare cases where exceptions occur during the insert operation. With transactions disabled, no rollback can be performed.

#anchor("ref-ignite-update")

=== UPDATE limitation

Only #raw("UPDATE") statements with constant assignments and predicates are supported. For example, the following statement is supported because the values assigned are constants:

#code-block("sql", "UPDATE table SET col1 = 1 WHERE col3 = 1")

Arithmetic expressions, function calls, and other non-constant #raw("UPDATE") statements are not supported. For example, the following statement is not supported because arithmetic expressions cannot be used with the #raw("SET") command:

#code-block("sql", "UPDATE table SET col1 = col2 + 2 WHERE col3 = 1")

All column values of a table row cannot be updated simultaneously. For a three column table, the following statement is not supported:

#code-block("sql", "UPDATE table SET col1 = 1, col2 = 2, col3 = 3 WHERE col3 = 1")

#anchor("ref-ignite-merge")

=== Non-transactional MERGE

The connector supports adding, updating, and deleting rows using #link(label("doc-sql-merge"))[MERGE statements], if the #raw("merge.non-transactional-merge.enabled") catalog property or the corresponding #raw("non_transactional_merge_enabled") catalog session property is set to #raw("true"). Merge is only supported for directly modifying target tables.

In rare cases, exceptions may occur during the merge operation, potentially resulting in a partial update.

#anchor("ref-ignite-alter-table")

=== ALTER TABLE RENAME TO limitation

The connector does not support renaming tables across multiple schemas. For example, the following statement is supported:

#code-block("sql", "ALTER TABLE example.schema_one.table_one RENAME TO example.schema_one.table_two")

The following statement attempts to rename a table across schemas, and therefore is not supported:

#code-block("sql", "ALTER TABLE example.schema_one.table_one RENAME TO example.schema_two.table_two")

#anchor("ref-ignite-procedures")

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

#anchor("ref-ignite-pushdown")

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

==== Predicate pushdown support

The connector does not support pushdown of any predicates on columns with #link(label("ref-string-data-types"))[textual types] like #raw("CHAR") or #raw("VARCHAR"). This ensures correctness of results since the data source may compare strings case-insensitively.

In the following example, the predicate is not pushed down for either query since #raw("name") is a column of type #raw("VARCHAR"):

#code-block("sql", "SELECT * FROM nation WHERE name > 'CANADA';
SELECT * FROM nation WHERE name = 'CANADA';")
