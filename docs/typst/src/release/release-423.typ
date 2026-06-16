#import "/lib/trino-docs.typ": *

#anchor("doc-release-release-423")
= Release 423 \(10 Aug 2023\)

== General

- Add support for renaming nested fields in a column via #raw("RENAME COLUMN"). \(#issue("16757", "https://github.com/trinodb/trino/issues/16757")\)
- Add support for setting the type of a nested field in a column via #raw("SET DATA TYPE"). \(#issue("16959", "https://github.com/trinodb/trino/issues/16959")\)
- Add support for comments on materialized view columns. \(#issue("18016", "https://github.com/trinodb/trino/issues/18016")\)
- Add support for displaying all Unicode characters in string literals. \(#issue("5061", "https://github.com/trinodb/trino/issues/5061")\)
- Improve performance of #raw("INSERT") and #raw("CREATE TABLE AS ... SELECT") queries. \(#issue("18212", "https://github.com/trinodb/trino/issues/18212")\)
- Improve performance when planning queries involving multiple window functions. \(#issue("18491", "https://github.com/trinodb/trino/issues/18491")\)
- Improve performance of queries involving #raw("BETWEEN") clauses. \(#issue("18501", "https://github.com/trinodb/trino/issues/18501")\)
- Improve performance of queries containing redundant #raw("ORDER BY") clauses in views or #raw("WITH") clauses. This may affect the semantics of queries that incorrectly rely on implementation-specific behavior. The old behavior can be restored via the #raw("skip_redundant_sort") session property or the #raw("optimizer.skip-redundant-sort") configuration property. \(#issue("18159", "https://github.com/trinodb/trino/issues/18159")\)
- Reduce default values for the #raw("task.partitioned-writer-count") and #raw("task.scale-writers.max-writer-count") configuration properties to reduce the memory requirements of queries that write data. \(#issue("18488", "https://github.com/trinodb/trino/issues/18488")\)
- Remove the deprecated #raw("optimizer.use-mark-distinct") configuration property, which has been replaced with #raw("optimizer.mark-distinct-strategy"). \(#issue("18540", "https://github.com/trinodb/trino/issues/18540")\)
- Fix query planning failure due to dynamic filters in #link(label("doc-admin-fault-tolerant-execution"))[fault tolerant execution mode]. \(#issue("18383", "https://github.com/trinodb/trino/issues/18383")\)
- Fix #raw("EXPLAIN") failure when a query contains #raw("WHERE ... IN (NULL)"). \(#issue("18328", "https://github.com/trinodb/trino/issues/18328")\)

== JDBC driver

- Add support for #link("https://web.mit.edu/kerberos/krb5-latest/doc/appdev/gssapi.html#constrained-delegation-s4u")[constrained delegation] with Kerberos. \(#issue("17853", "https://github.com/trinodb/trino/issues/17853")\)

== CLI

- Add support for accepting a single Trino JDBC URL with parameters as an alternative to passing command line arguments. \(#issue("12587", "https://github.com/trinodb/trino/issues/12587")\)

== ClickHouse connector

- Add support for #raw("CASCADE") option in #raw("DROP SCHEMA") statements. \(#issue("18305", "https://github.com/trinodb/trino/issues/18305")\)

== Blackhole connector

- Add support for the #raw("COMMENT ON VIEW") statement. \(#issue("18516", "https://github.com/trinodb/trino/issues/18516")\)

== Delta Lake connector

- Add #raw("$properties") system table which can be queried to inspect Delta Lake table properties. \(#issue("17294", "https://github.com/trinodb/trino/issues/17294")\)
- Add support for reading the #raw("timestamp_ntz") type. \(#issue("17502", "https://github.com/trinodb/trino/issues/17502")\)
- Add support for writing the #raw("timestamp with time zone") type on partitioned columns. \(#issue("16822", "https://github.com/trinodb/trino/issues/16822")\)
- Add option to enforce that a filter on a partition key is present for query processing. This can be enabled by setting the #raw("delta.query-partition-filter-required") configuration property or the #raw("query_partition_filter_required") session property to #raw("true"). \(#issue("18345", "https://github.com/trinodb/trino/issues/18345")\)
- Improve performance of the #raw("$history") system table. \(#issue("18427", "https://github.com/trinodb/trino/issues/18427")\)
- Improve memory accounting of the Parquet writer. \(#issue("18564", "https://github.com/trinodb/trino/issues/18564")\)
- Allow metadata changes on Delta Lake tables with #link("https://github.com/delta-io/delta/blob/master/PROTOCOL.md#identity-columns")[identity columns]. \(#issue("18200", "https://github.com/trinodb/trino/issues/18200")\)
- Fix incorrectly creating files smaller than the configured #raw("file_size_threshold") as part of #raw("OPTIMIZE"). \(#issue("18388", "https://github.com/trinodb/trino/issues/18388")\)
- Fix query failure when a table has a file with a location ending with whitespace. \(#issue("18206", "https://github.com/trinodb/trino/issues/18206")\)

== Hive connector

- Add support for changing a column's type from #raw("varchar") to #raw("timestamp"). \(#issue("18014", "https://github.com/trinodb/trino/issues/18014")\)
- Improve memory accounting of the Parquet writer. \(#issue("18564", "https://github.com/trinodb/trino/issues/18564")\)
- Remove the legacy Parquet writer, along with the #raw("parquet.optimized-writer.enabled") configuration property and the #raw("parquet_optimized_writer_enabled ") session property. Replace the #raw("parquet.optimized-writer.validation-percentage") configuration property with #raw("parquet.writer.validation-percentage"). \(#issue("18420", "https://github.com/trinodb/trino/issues/18420")\)
- Disallow coercing Hive #raw("timestamp") types to #raw("varchar") for dates before 1900. \(#issue("18004", "https://github.com/trinodb/trino/issues/18004")\)
- Fix loss of data precision when coercing Hive #raw("timestamp") values. \(#issue("18003", "https://github.com/trinodb/trino/issues/18003")\)
- Fix incorrectly creating files smaller than the configured #raw("file_size_threshold") as part of #raw("OPTIMIZE"). \(#issue("18388", "https://github.com/trinodb/trino/issues/18388")\)
- Fix query failure when a table has a file with a location ending with whitespace. \(#issue("18206", "https://github.com/trinodb/trino/issues/18206")\)
- Fix incorrect results when using S3 Select and a query predicate includes a quote character \(#raw("\"")\) or a decimal column. \(#issue("17775", "https://github.com/trinodb/trino/issues/17775")\)
- Add the #raw("hive.s3select-pushdown.experimental-textfile-pushdown-enabled") configuration property to enable S3 Select pushdown for #raw("TEXTFILE") tables. \(#issue("17775", "https://github.com/trinodb/trino/issues/17775")\)

== Hudi connector

- Fix query failure when a table has a file with a location ending with whitespace. \(#issue("18206", "https://github.com/trinodb/trino/issues/18206")\)

== Iceberg connector

- Add support for renaming nested fields in a column via #raw("RENAME COLUMN"). \(#issue("16757", "https://github.com/trinodb/trino/issues/16757")\)
- Add support for setting the type of a nested field in a column via #raw("SET DATA TYPE"). \(#issue("16959", "https://github.com/trinodb/trino/issues/16959")\)
- Add support for comments on materialized view columns. \(#issue("18016", "https://github.com/trinodb/trino/issues/18016")\)
- Add support for #raw("tinyint") and #raw("smallint") types in the #raw("migrate") procedure. \(#issue("17946", "https://github.com/trinodb/trino/issues/17946")\)
- Add support for reading Parquet files with time stored in millisecond precision. \(#issue("18535", "https://github.com/trinodb/trino/issues/18535")\)
- Improve performance of #raw("information_schema.columns") queries for tables managed by Trino with AWS Glue as metastore. \(#issue("18315", "https://github.com/trinodb/trino/issues/18315")\)
- Improve performance of #raw("system.metadata.table_comments") when querying Iceberg tables backed by AWS Glue as metastore.  \(#issue("18517", "https://github.com/trinodb/trino/issues/18517")\)
- Improve performance of #raw("information_schema.columns") when using the Glue catalog. \(#issue("18586", "https://github.com/trinodb/trino/issues/18586")\)
- Improve memory accounting of the Parquet writer. \(#issue("18564", "https://github.com/trinodb/trino/issues/18564")\)
- Fix incorrectly creating files smaller than the configured #raw("file_size_threshold") as part of #raw("OPTIMIZE"). \(#issue("18388", "https://github.com/trinodb/trino/issues/18388")\)
- Fix query failure when a table has a file with a location ending with whitespace. \(#issue("18206", "https://github.com/trinodb/trino/issues/18206")\)
- Fix failure when creating a materialized view on a table which has been rolled back. \(#issue("18205", "https://github.com/trinodb/trino/issues/18205")\)
- Fix query failure when reading ORC files with nullable #raw("time") columns. \(#issue("15606", "https://github.com/trinodb/trino/issues/15606")\)
- Fix failure to calculate query statistics when referring to #raw("$path") as part of a #raw("WHERE") clause. \(#issue("18330", "https://github.com/trinodb/trino/issues/18330")\)
- Fix write conflict detection for #raw("UPDATE"), #raw("DELETE"), and #raw("MERGE") operations. In rare situations this issue may have resulted in duplicate rows when multiple operations were run at the same time, or at the same time as an #raw("optimize") procedure. \(#issue("18533", "https://github.com/trinodb/trino/issues/18533")\)

== Kafka connector

- Rename the #raw("ADD_DUMMY") value for the #raw("kafka.empty-field-strategy") configuration property and the #raw("empty_field_strategy") session property to #raw("MARK") \(#issue("18485", "https://github.com/trinodb/trino/issues/18485")\).

== Kudu connector

- Add support for optimized local scheduling of splits. \(#issue("18121", "https://github.com/trinodb/trino/issues/18121")\)

== MariaDB connector

- Add support for #raw("CASCADE") option in #raw("DROP SCHEMA") statements. \(#issue("18305", "https://github.com/trinodb/trino/issues/18305")\)

== MongoDB connector

- Add support for predicate pushdown on #raw("char") and #raw("decimal") type. \(#issue("18382", "https://github.com/trinodb/trino/issues/18382")\)

== MySQL connector

- Add support for predicate pushdown for #raw("="), #raw("<>"), #raw("IN"), #raw("NOT IN"), and #raw("LIKE") operators on case-sensitive #raw("varchar") and #raw("nvarchar") columns. \(#issue("18140", "https://github.com/trinodb/trino/issues/18140"), #issue("18441", "https://github.com/trinodb/trino/issues/18441")\)
- Add support for #raw("CASCADE") option in #raw("DROP SCHEMA") statements. \(#issue("18305", "https://github.com/trinodb/trino/issues/18305")\)

== Oracle connector

- Add support for Oracle #raw("timestamp") types with non-millisecond precision. \(#issue("17934", "https://github.com/trinodb/trino/issues/17934")\)
- Add support for #raw("CASCADE") option in #raw("DROP SCHEMA") statements. \(#issue("18305", "https://github.com/trinodb/trino/issues/18305")\)

== SingleStore connector

- Add support for #raw("CASCADE") option in #raw("DROP SCHEMA") statements. \(#issue("18305", "https://github.com/trinodb/trino/issues/18305")\)

== SPI

- Deprecate the #raw("ConnectorMetadata.getTableHandle(ConnectorSession, SchemaTableName)") method signature. Connectors should implement #raw("ConnectorMetadata.getTableHandle(ConnectorSession, SchemaTableName, Optional, Optional)") instead. \(#issue("18596", "https://github.com/trinodb/trino/issues/18596")\)
- Remove the deprecated #raw("supportsReportingWrittenBytes") method from ConnectorMetadata. \(#issue("18617", "https://github.com/trinodb/trino/issues/18617")\)
