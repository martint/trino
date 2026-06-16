#import "/lib/trino-docs.typ": *

#anchor("doc-release-release-446")
= Release 446 \(1 May 2024\)

== General

- Improve performance of #raw("INSERT") statements into partitioned tables when the #raw("retry_policy") configuration property is set to #raw("TASK"). \(#issue("21661 ", "https://github.com/trinodb/trino/issues/21661 ")\)
- Improve performance of queries with complex grouping operations.  \(#issue("21726", "https://github.com/trinodb/trino/issues/21726")\)
- Reduce delay before killing queries when the cluster runs out of memory. \(#issue("21719", "https://github.com/trinodb/trino/issues/21719")\)
- Prevent assigning null values to non-null columns as part of a #raw("MERGE") statement. \(#issue("21619", "https://github.com/trinodb/trino/issues/21619")\)
- Fix #raw("CREATE CATALOG") statements including quotes in catalog names. \(#issue("21399", "https://github.com/trinodb/trino/issues/21399")\)
- Fix potential query failure when a column name ends with a #raw(":"). \(#issue("21676", "https://github.com/trinodb/trino/issues/21676")\)
- Fix potential query failure when a #link(label("doc-udf-sql"))[SQL user-defined functions] contains a label reference in a #raw("LEAVE"), #raw("ITERATE"), #raw("REPEAT"), or #raw("WHILE") statement. \(#issue("21682", "https://github.com/trinodb/trino/issues/21682")\)
- Fix query failure when #link(label("doc-udf-sql"))[SQL user-defined functions] use the #raw("NULLIF") or #raw("BETWEEN") functions. \(#issue("19820", "https://github.com/trinodb/trino/issues/19820")\)
- Fix potential query failure due to worker nodes running out of memory in concurrent scenarios. \(#issue("21706", "https://github.com/trinodb/trino/issues/21706")\)

== BigQuery connector

- Improve performance when listing table comments. \(#issue("21581", "https://github.com/trinodb/trino/issues/21581")\)
- #breaking-marker("../release.html#breaking-changes") Enable #raw("bigquery.arrow-serialization.enabled") by default. This requires #raw("--add-opens=java.base/java.nio=ALL-UNNAMED") in #raw("jvm-config"). \(#issue("21580", "https://github.com/trinodb/trino/issues/21580")\)

== Delta Lake connector

- Fix failure when reading from Azure file storage and the schema, table, or column name contains non-alphanumeric characters. \(#issue("21586", "https://github.com/trinodb/trino/issues/21586")\)
- Fix incorrect results when reading a partitioned table with a #link("https://docs.delta.io/latest/delta-deletion-vectors.html")[deletion vector]. \(#issue("21737", "https://github.com/trinodb/trino/issues/21737")\)

== Hive connector

- Add support for reading S3 objects restored from Glacier storage. \(#issue("21164", "https://github.com/trinodb/trino/issues/21164")\)
- Fix failure when reading from Azure file storage and the schema, table, or column name contains non-alphanumeric characters. \(#issue("21586", "https://github.com/trinodb/trino/issues/21586")\)
- Fix failure when listing Hive views with unsupported syntax. \(#issue("21748", "https://github.com/trinodb/trino/issues/21748")\)

== Iceberg connector

- Add support for the #link(label("ref-iceberg-snowflake-catalog"))[Snowflake catalog]. \(#issue("19362", "https://github.com/trinodb/trino/issues/19362")\)
- Automatically use #raw("varchar") as a type during table creation when #raw("char") is specified. \(#issue("19336", "https://github.com/trinodb/trino/issues/19336"), #issue("21515", "https://github.com/trinodb/trino/issues/21515")\)
- Deprecate the #raw("schema") and #raw("table") arguments for the #raw("table_changes") function in favor of #raw("schema_name") and #raw("table_name"), respectively. \(#issue("21698", "https://github.com/trinodb/trino/issues/21698")\)
- Fix failure when executing the #raw("migrate") procedure with partitioned Hive tables on Glue. \(#issue("21391", "https://github.com/trinodb/trino/issues/21391")\)
- Fix failure when reading from Azure file storage and the schema, table, or column name contains non-alphanumeric characters. \(#issue("21586", "https://github.com/trinodb/trino/issues/21586")\)

== Pinot connector

- Fix query failure when a predicate contains a #raw("'"). \(#issue("21681", "https://github.com/trinodb/trino/issues/21681")\)

== Snowflake connector

- Add support for the #raw("unsupported-type-handling") and #raw("jdbc-types-mapped-to-varchar") type mapping configuration properties. \(#issue("21528", "https://github.com/trinodb/trino/issues/21528")\)

== SPI

- Remove support for #raw("@RemoveInput") as an annotation for aggregation functions. A #raw("WindowAggregation") can be declared in #raw("@AggregationFunction") instead, which supports input removal. \(#issue("21349", "https://github.com/trinodb/trino/issues/21349")\)
- Extend #raw("QueryCompletionEvent") with various aggregated, per-stage, per-task distribution statistics. New information is available in #raw("QueryCompletedEvent.statistics.taskStatistics"). \(#issue("21694", "https://github.com/trinodb/trino/issues/21694")\)
