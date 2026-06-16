#import "/lib/trino-docs.typ": *

#anchor("doc-release-release-0-152")
= Release 0.152

== General

- Add #link(label("fn-array-union"), raw("array_union")) function.
- Add #link(label("fn-reverse"), raw("reverse")) function for arrays.
- Fix issue that could cause queries with #raw("varchar") literals to fail.
- Fix categorization of errors from #link(label("fn-url-decode"), raw("url_decode")), allowing it to be used with #raw("TRY").
- Fix error reporting for invalid JSON paths provided to JSON functions.
- Fix view creation for queries containing #raw("GROUPING SETS").
- Fix query failure when referencing a field of a #raw("NULL") row.
- Improve query performance for multiple consecutive window functions.
- Prevent web UI from breaking when query fails without an error code.
- Display port on the task list in the web UI when multiple workers share the same host.
- Add support for #raw("EXCEPT").
- Rename #raw("FLOAT") type to #raw("REAL") for better compatibility with the SQL standard.
- Fix potential performance regression when transporting rows between nodes.

== JDBC driver

- Fix sizes returned from #raw("DatabaseMetaData.getColumns()") for #raw("COLUMN_SIZE"), #raw("DECIMAL_DIGITS"), #raw("NUM_PREC_RADIX") and #raw("CHAR_OCTET_LENGTH").

== Hive

- Fix resource leak in Parquet reader.
- Rename JMX stat #raw("AllViews") to #raw("GetAllViews") in #raw("ThriftHiveMetastore").
- Add file based security, which can be configured with the #raw("hive.security") and #raw("security.config-file") config properties. See #link(label("ref-hive-authorization"))[Hive connector] for more details.
- Add support for custom S3 credentials providers using the #raw("presto.s3.credentials-provider") Hadoop configuration property.

== MySQL

- Fix reading MySQL #raw("tinyint(1)") columns. Previously, these columns were incorrectly returned as a boolean rather than an integer.
- Add support for #raw("INSERT").
- Add support for reading data as #raw("tinyint") and #raw("smallint") types rather than #raw("integer").

== PostgreSQL

- Add support for #raw("INSERT").
- Add support for reading data as #raw("tinyint") and #raw("smallint") types rather than #raw("integer").

== SPI

- Remove #raw("owner") from #raw("ConnectorTableMetadata").
- Replace the  generic #raw("getServices()") method in #raw("Plugin") with specific methods such as #raw("getConnectorFactories()"), #raw("getTypes()"), etc. Dependencies like #raw("TypeManager") are now provided directly rather than being injected into #raw("Plugin").
- Add first-class support for functions in the SPI. This replaces the old #raw("FunctionFactory") interface. Plugins can return a list of classes from the #raw("getFunctions()") method:
  
  - Scalar functions are methods or classes annotated with #raw("@ScalarFunction").
  - Aggregation functions are methods or classes annotated with #raw("@AggregationFunction").
  - Window functions are an implementation of #raw("WindowFunction"). Most implementations should be a subclass of #raw("RankingWindowFunction") or #raw("ValueWindowFunction").

#note[
This is a backwards incompatible change with the previous SPI. If you have written a plugin, you will need to update your code before deploying this release.
]

== Verifier

- Fix handling of shadow write queries with a #raw("LIMIT").

== Local file

- Fix file descriptor leak.
