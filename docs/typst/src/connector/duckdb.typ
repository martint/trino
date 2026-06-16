#import "/lib/trino-docs.typ": *

#anchor("doc-connector-duckdb")
= DuckDB connector

The DuckDB connector allows querying and creating tables in an external #link("https://duckdb.org/")[DuckDB] instance. This can be used to join data between different systems like DuckDB and Hive, or between two different DuckDB instances.

== Requirements

- All cluster nodes must include #raw("libstdc++") as required by the #link("https://duckdb.org/docs/clients/java.html")[DuckDB JDBC driver].
- The path to the persistent DuckDB database must be identical and available on all cluster nodes and point to the same storage location.

== Configuration

The connector can query a DuckDB database. Create a catalog properties file that specifies the DuckDb connector by setting the #raw("connector.name") to #raw("duckdb").

For example, to access a database as the #raw("example") catalog, create the file #raw("etc/catalog/example.properties"). Replace the connection properties as appropriate for your setup:

#code-block("none", "connector.name=duckdb
connection-url=jdbc:duckdb:<path>")

The #raw("connection-url") defines the connection information and parameters to pass to the DuckDB JDBC driver. The parameters for the URL are available in the #link("https://duckdb.org/docs/clients/java.html")[DuckDB JDBC driver documentation].

The #raw("<path>") must point to an existing, persistent DuckDB database file. For example, use #raw("jdbc:duckdb:/opt/duckdb/trino.duckdb") for a database created with the command #raw("duckdb /opt/duckdb/trino.duckdb"). The database automatically contains the #raw("main") schema  and the #raw("information_schema") schema. Use the #raw("main") schema for your new tables or create a new schema.

When using the connector on a Trino cluster the path must be consistent on all nodes and point to a shared storage to ensure that all nodes operate on the same database.

Using an in-memory DuckDB database #raw("jdbc:duckdb:") is not supported.

Refer to the DuckDB documentation for tips on #link("https://duckdb.org/docs/operations_manual/securing_duckdb/overview")[securing DuckDB]. Note that Trino connects to the database using the JDBC driver and does not use the DuckDB CLI.

=== Multiple DuckDB servers

The DuckDB connector can only access a single database within a DuckDB instance. Thus, if you have multiple DuckDB servers, or want to connect to multiple DuckDB servers, you must configure multiple instances of the DuckDB connector.

#anchor("ref-duckdb-type-mapping")

== Type mapping

Because Trino and DuckDB each support types that the other does not, this connector #link(label("ref-type-mapping-overview"))[modifies some types] when reading or writing data. Data types may not map the same way in both directions between Trino and the data source. Refer to the following sections for type mapping in each direction.

List of #link("https://duckdb.org/docs/sql/data_types/overview.html")[DuckDB data types].

=== DuckDB type to Trino type mapping

The connector maps DuckDB types to the corresponding Trino types following this table:

#list-table((
  ([DuckDB type], [Trino type], [Notes],),
  ([#raw("BOOLEAN")], [#raw("BOOLEAN")], [],),
  ([#raw("TINYINT")], [#raw("TINYINT")], [],),
  ([#raw("SMALLINT")], [#raw("SMALLINT")], [],),
  ([#raw("INTEGER")], [#raw("INTEGER")], [],),
  ([#raw("BIGINT")], [#raw("BIGINT")], [],),
  ([#raw("FLOAT")], [#raw("REAL")], [],),
  ([#raw("DOUBLE")], [#raw("DOUBLE")], [],),
  ([#raw("DECIMAL")], [#raw("DECIMAL")], [Default precision and scale are \(18,3\).],),
  ([#raw("VARCHAR")], [#raw("VARCHAR")], [],),
  ([#raw("DATE")], [#raw("DATE")], [],)
), header-rows: 1, title: "DuckDB type to Trino type mapping")

No other types are supported.

=== Trino type to DuckDB type mapping

The connector maps Trino types to the corresponding DuckDB types following this table:

#list-table((
  ([Trino type], [DuckDB type], [Notes],),
  ([#raw("BOOLEAN")], [#raw("BOOLEAN")], [],),
  ([#raw("TINYINT")], [#raw("TINYINT")], [],),
  ([#raw("SMALLINT")], [#raw("SMALLINT")], [],),
  ([#raw("INTEGER")], [#raw("INTEGER")], [],),
  ([#raw("BIGINT")], [#raw("BIGINT")], [],),
  ([#raw("REAL")], [#raw("REAL")], [],),
  ([#raw("DOUBLE")], [#raw("DOUBLE")], [],),
  ([#raw("DECIMAL")], [#raw("DECIMAL")], [],),
  ([#raw("CHAR")], [#raw("VARCHAR")], [],),
  ([#raw("VARCHAR")], [#raw("VARCHAR")], [],),
  ([#raw("DATE")], [#raw("DATE")], [],)
), header-rows: 1, title: "Trino type to DuckDB type mapping")

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

#anchor("ref-duckdb-sql-support")

== SQL support

The connector provides read access and write access to data and metadata in a DuckDB database.  In addition to the #link(label("ref-sql-globally-available"))[globally available] and #link(label("ref-sql-read-operations"))[read operation] statements, the connector supports the following features:

- #link(label("doc-sql-insert"))[INSERT]
- #link(label("doc-sql-delete"))[DELETE]
- #link(label("doc-sql-truncate"))[TRUNCATE]
- #link(label("doc-sql-create-table"))[CREATE TABLE]
- #link(label("doc-sql-create-table-as"))[CREATE TABLE AS]
- #link(label("doc-sql-drop-table"))[DROP TABLE]
- #link(label("doc-sql-alter-table"))[ALTER TABLE]
- #link(label("doc-sql-create-schema"))[CREATE SCHEMA]
- #link(label("doc-sql-drop-schema"))[DROP SCHEMA]

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

=== Table functions

The connector provides specific #link(label("doc-functions-table"))[table functions] to access DuckDB.

#anchor("ref-duckdb-query-function")

==== #raw("query(varchar) -> table")

The #raw("query") function allows you to query the underlying database directly. It requires syntax native to DuckDB, because the full query is pushed down and processed in DuckDB. This can be useful for accessing native features which are not available in Trino or for improving query performance in situations where running a query natively may be faster.

Find details about the SQL support of DuckDB that you can use in the query in the #link("https://duckdb.org/docs/sql/query_syntax/select")[DuckDB SQL Command Reference] and other statements and functions.

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
