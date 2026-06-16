#import "/lib/trino-docs.typ": *

#anchor("doc-release-release-378")
= Release 378 \(21 Apr 2022\)

== General

- Add #link(label("fn-to-base32"), raw("to_base32")) and #link(label("fn-from-base32"), raw("from_base32")) functions. \(#issue("11439", "https://github.com/trinodb/trino/issues/11439")\)
- Improve planning performance of queries with large #raw("IN") lists. \(#issue("11902", "https://github.com/trinodb/trino/issues/11902"), #issue("11918", "https://github.com/trinodb/trino/issues/11918"), #issue("11956", "https://github.com/trinodb/trino/issues/11956")\)
- Improve performance of queries involving correlated #raw("IN") or #raw("EXISTS") predicates. \(#issue("12047", "https://github.com/trinodb/trino/issues/12047")\)
- Fix reporting of total spilled bytes in JMX metrics. \(#issue("11983", "https://github.com/trinodb/trino/issues/11983")\)

== Security

- Require value for #link(label("doc-security-internal-communication"))[the shared secret configuration for internal communication] when any authentication is enabled. \(#issue("11944", "https://github.com/trinodb/trino/issues/11944")\)

== CLI

- Allow disabling progress reporting during query executing in the CLI client by specifying #raw("--no-progress") \(#issue("11894", "https://github.com/trinodb/trino/issues/11894")\)
- Reduce latency for very short queries. \(#issue("11768", "https://github.com/trinodb/trino/issues/11768")\)

== Delta Lake connector

- Improve query planning performance. \(#issue("11858", "https://github.com/trinodb/trino/issues/11858")\)
- Fix failure when reading from #raw("information_schema.columns") when metastore contains views. \(#issue("11946", "https://github.com/trinodb/trino/issues/11946")\)
- Add support for dropping tables with invalid metadata. \(#issue("11924", "https://github.com/trinodb/trino/issues/11924")\)
- Fix query failure when partition column has a #raw("null") value and query has a complex predicate on that partition column. \(#issue("12056", "https://github.com/trinodb/trino/issues/12056")\)

== Hive connector

- Improve query planning performance. \(#issue("11858", "https://github.com/trinodb/trino/issues/11858")\)

== Iceberg connector

- Add support for hidden #raw("$path") columns. \(#issue("8769", "https://github.com/trinodb/trino/issues/8769")\)
- Add support for creating tables with either Iceberg format version 1, or 2. \(#issue("11880", "https://github.com/trinodb/trino/issues/11880")\)
- Add the #raw("expire_snapshots") table procedure. \(#issue("10810", "https://github.com/trinodb/trino/issues/10810")\)
- Add the #raw("delete_orphan_files") table procedure. \(#issue("10810", "https://github.com/trinodb/trino/issues/10810")\)
- Allow reading Iceberg tables written by Glue that have locations containing double slashes. \(#issue("11964", "https://github.com/trinodb/trino/issues/11964")\)
- Improve query planning performance. \(#issue("11858", "https://github.com/trinodb/trino/issues/11858")\)
- Fix query failure with a dynamic filter prunes a split on a worker node. \(#issue("11976", "https://github.com/trinodb/trino/issues/11976")\)
- Include missing #raw("format_version") property in #raw("SHOW CREATE TABLE") output. \(#issue("11980", "https://github.com/trinodb/trino/issues/11980")\)

== MySQL connector

- Improve query planning performance. \(#issue("11858", "https://github.com/trinodb/trino/issues/11858")\)

== Pinot connector

- Support querying tables having non-lowercase names in Pinot. \(#issue("6789", "https://github.com/trinodb/trino/issues/6789")\)
- Fix handling of hybrid tables in Pinot and stop returning duplicate data. \(#issue("10125", "https://github.com/trinodb/trino/issues/10125")\)

== PostgreSQL connector

- Improve query planning performance. \(#issue("11858", "https://github.com/trinodb/trino/issues/11858")\)

== SQL Server connector

- Improve query planning performance. \(#issue("11858", "https://github.com/trinodb/trino/issues/11858")\)

== SPI

- Deprecate passing constraints to #raw("ConnectorMetadata.getTableStatistics()"). Constraints can be associated with the table handle in #raw("ConnectorMetadata.applyFilter()"). \(#issue("11877", "https://github.com/trinodb/trino/issues/11877")\)
