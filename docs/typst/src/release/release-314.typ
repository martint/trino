#import "/lib/trino-docs.typ": *

#anchor("doc-release-release-314")
= Release 314 \(7 Jun 2019\)

== General

- Fix incorrect results for #raw("BETWEEN") involving #raw("NULL") values. \(#issue("877", "https://github.com/trinodb/trino/issues/877")\)
- Fix query history leak in coordinator. \(#issue("939", "https://github.com/trinodb/trino/issues/939"), #issue("944", "https://github.com/trinodb/trino/issues/944")\)
- Fix idle client timeout handling. \(#issue("947", "https://github.com/trinodb/trino/issues/947")\)
- Improve performance of #link(label("fn-json-parse"), raw("json_parse")) function. \(#issue("904", "https://github.com/trinodb/trino/issues/904")\)
- Visualize plan structure in #raw("EXPLAIN") output. \(#issue("888", "https://github.com/trinodb/trino/issues/888")\)
- Add support for positional access to #raw("ROW") fields via the subscript operator. \(#issue("860", "https://github.com/trinodb/trino/issues/860")\)

== CLI

- Add JSON output format. \(#issue("878", "https://github.com/trinodb/trino/issues/878")\)

== Web UI

- Fix queued queries counter in UI. \(#issue("894", "https://github.com/trinodb/trino/issues/894")\)

== Server RPM

- Change default location of the #raw("http-request.log") to #raw("/var/log/presto"). Previously, the log would be located in #raw("/var/lib/presto/data/var/log") by default. \(#issue("919", "https://github.com/trinodb/trino/issues/919")\)

== Hive connector

- Fix listing tables and views from Hive 2.3+ Metastore on certain databases, including Derby and Oracle. This fixes #raw("SHOW TABLES"), #raw("SHOW VIEWS") and reading from #raw("information_schema.tables") table. \(#issue("833", "https://github.com/trinodb/trino/issues/833")\)
- Fix handling of Avro tables with #raw("avro.schema.url") defined in Hive #raw("SERDEPROPERTIES"). \(#issue("898", "https://github.com/trinodb/trino/issues/898")\)
- Fix regression that caused ORC bloom filters to be ignored. \(#issue("921", "https://github.com/trinodb/trino/issues/921")\)
- Add support for reading LZ4 and ZSTD compressed Parquet data. \(#issue("910", "https://github.com/trinodb/trino/issues/910")\)
- Add support for writing ZSTD compressed ORC data. \(#issue("910", "https://github.com/trinodb/trino/issues/910")\)
- Add support for configuring ZSTD and LZ4 as default compression methods via the #raw("hive.compression-codec") configuration option. \(#issue("910", "https://github.com/trinodb/trino/issues/910")\)
- Do not allow inserting into text format tables that have a header or footer. \(#issue("891", "https://github.com/trinodb/trino/issues/891")\)
- Add #raw("textfile_skip_header_line_count") and #raw("textfile_skip_footer_line_count") table properties for text format tables that specify the number of header and footer lines. \(#issue("845", "https://github.com/trinodb/trino/issues/845")\)
- Add #raw("hive.max-splits-per-second") configuration property to allow throttling the split discovery rate, which can reduce load on the file system. \(#issue("534", "https://github.com/trinodb/trino/issues/534")\)
- Support overwriting unpartitioned tables for insert queries. \(#issue("924", "https://github.com/trinodb/trino/issues/924")\)

== PostgreSQL connector

- Support PostgreSQL arrays declared using internal type name, for example #raw("_int4") \(rather than #raw("int[]")\). \(#issue("659", "https://github.com/trinodb/trino/issues/659")\)

== Elasticsearch connector

- Add support for mixed-case field names. \(#issue("887", "https://github.com/trinodb/trino/issues/887")\)

== Base-JDBC connector library

- Allow connectors to customize how they store #raw("NULL") values. \(#issue("918", "https://github.com/trinodb/trino/issues/918")\)

== SPI

- Expose the SQL text of the executed prepared statement to #raw("EventListener"). \(#issue("908", "https://github.com/trinodb/trino/issues/908")\)
- Deprecate table layouts for #raw("ConnectorMetadata.makeCompatiblePartitioning()"). \(#issue("689", "https://github.com/trinodb/trino/issues/689")\)
- Add support for delete pushdown into connectors via the #raw("ConnectorMetadata.applyDelete()") and #raw("ConnectorMetadata.executeDelete()") methods. \(#issue("689", "https://github.com/trinodb/trino/issues/689")\)
- Allow connectors without distributed tables. \(#issue("893", "https://github.com/trinodb/trino/issues/893")\)
