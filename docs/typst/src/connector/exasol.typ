#import "/lib/trino-docs.typ": *

#anchor("doc-connector-exasol")
= Exasol connector

The Exasol connector allows querying an #link("https://www.exasol.com/")[Exasol] database.

== Requirements

To connect to Exasol, you need:

- Exasol database version 8.34.0 or higher.
- Network access from the Trino coordinator and workers to Exasol. Port 8563 is the default port.

== Configuration

To configure the Exasol connector as the #raw("example") catalog, create a file named #raw("example.properties") in #raw("etc/catalog"). Include the following connection properties in the file:

#code-block("text", "connector.name=exasol
connection-url=jdbc:exa:exasol.example.com:8563
connection-user=user
connection-password=secret")

The #raw("connection-url") defines the connection information and parameters to pass to the JDBC driver. See the #link("https://docs.exasol.com/db/latest/connect_exasol/drivers/jdbc.htm#ExasolURL")[Exasol JDBC driver documentation] for more information.

The #raw("connection-user") and #raw("connection-password") are typically required and determine the user credentials for the connection, often a service user. You can use #link(label("doc-security-secrets"))[secrets] to avoid using actual values in catalog properties files.

#note[
If your Exasol database uses a self-signed TLS certificate you must specify the certificate's fingerprint in the JDBC URL using parameter #raw("fingerprint"), e.g.: #raw("jdbc:exa:exasol.example.com:8563;fingerprint=ABC123").
]

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

#anchor("ref-exasol-type-mapping")

== Type mapping

Because Trino and Exasol each support types that the other does not, this connector #link(label("ref-type-mapping-overview"))[modifies some types] when reading data. Data types may not map the same way in both directions between Trino and the data source. Refer to the following sections for type mapping in each direction.

=== Exasol to Trino type mapping

Trino supports selecting Exasol database types. This table shows the Exasol to Trino data type mapping:

#list-table((
  ([Exasol database type], [Trino type], [Notes],),
  ([#raw("BOOLEAN")], [#raw("BOOLEAN")], [],),
  ([#raw("DOUBLE PRECISION")], [#raw("REAL")], [],),
  ([#raw("DECIMAL(p, s)")], [#raw("DECIMAL(p, s)")], [See #link(label("ref-exasol-number-mapping"))[exasol-number-mapping]],),
  ([#raw("CHAR(n)")], [#raw("CHAR(n)")], [],),
  ([#raw("VARCHAR(n)")], [#raw("VARCHAR(n)")], [],),
  ([#raw("DATE")], [#raw("DATE")], [],),
  ([#raw("HASHTYPE")], [#raw("VARBINARY")], [],)
), header-rows: 1, title: "Exasol to Trino type mapping")

No other types are supported.

#anchor("ref-exasol-number-mapping")

=== Mapping numeric types

An Exasol #raw("DECIMAL(p, s)") maps to Trino's #raw("DECIMAL(p, s)") and vice versa except in these conditions:

- No precision is specified for the column \(example: #raw("DECIMAL") or #raw("DECIMAL(*)")\).
- Scale \(#raw("s")\) is greater than precision.
- Precision \(#raw("p")\) is greater than 36.
- Scale is negative.

#anchor("ref-exasol-character-mapping")

=== Mapping character types

Trino's #raw("VARCHAR(n)") maps to #raw("VARCHAR(n)") and vice versa if #raw("n") is no greater than 2000000. Exasol does not support longer values. If no length is specified, the connector uses 2000000.

Trino's #raw("CHAR(n)") maps to #raw("CHAR(n)") and vice versa if #raw("n") is no greater than 2000. Exasol does not support longer values.

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

#anchor("ref-exasol-sql-support")

== SQL support

The connector provides read access to data and metadata in Exasol. In addition to the #link(label("ref-sql-globally-available"))[globally available] and #link(label("ref-sql-read-operations"))[read operation] statements, the connector supports the following features:

- #link(label("ref-exasol-procedures"))[Exasol connector]
- #link(label("ref-exasol-table-functions"))[Exasol connector]

#anchor("ref-exasol-procedures")

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

#anchor("ref-exasol-table-functions")

=== Table functions

The connector provides specific #link(label("doc-functions-table"))[table functions] to access Exasol.

#anchor("ref-exasol-query-function")

==== #raw("query(varchar) -> table")

The #raw("query") function allows you to query the underlying database directly. It requires syntax native to Exasol, because the full query is pushed down and processed in Exasol. This can be useful for accessing native features which are not available in Trino or for improving query performance in situations where running a query natively may be faster.

The native query passed to the underlying data source is required to return a table as a result set. Only the data source performs validation or security checks for these queries using its own configuration. Trino does not perform these tasks. Only use passthrough queries to read data.

As a simple example, query the #raw("example") catalog and select an entire table::

#code-block("sql", "SELECT
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

As a practical example, you can use the #link("https://docs.exasol.com/db/latest/sql_references/functions/analyticfunctions.htm#AnalyticFunctions")[WINDOW clause from Exasol]:

#code-block("sql", "SELECT
  *
FROM
  TABLE(
    example.system.query(
      query => 'SELECT
        id, department, hire_date, starting_salary,
        AVG(starting_salary) OVER w2 AVG,
        MIN(starting_salary) OVER w2 MIN_STARTING_SALARY,
        MAX(starting_salary) OVER (w1 ORDER BY hire_date)
      FROM employee_table
      WINDOW w1 as (PARTITION BY department), w2 as (w1 ORDER BY hire_date)
      ORDER BY department, hire_date'
    )
  );")

#note[
The query engine does not preserve the order of the results of this function. If the passed query contains an #raw("ORDER BY") clause, the function result may not be ordered as expected.
]

== Performance

The connector includes a number of performance improvements, detailed in the following sections.

#anchor("ref-exasol-pushdown")

=== Pushdown

The connector supports pushdown for a number of operations:

- #link(label("ref-limit-pushdown"))[limit-pushdown]
- #link(label("ref-topn-pushdown"))[topn-pushdown]
