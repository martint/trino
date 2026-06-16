#import "/lib/trino-docs.typ": *

#anchor("doc-release-release-321")
= Release 321 \(15 Oct 2019\)

#warning[
The server RPM is broken in this release.
]

== General

- Fix incorrect result of #link(label("fn-round"), raw("round")) when applied to a #raw("tinyint"), #raw("smallint"), #raw("integer"), or #raw("bigint") type with negative decimal places. \(#issue("42", "https://github.com/trinodb/trino/issues/42")\)
- Improve performance of queries with #raw("LIMIT") over #raw("information_schema") tables. \(#issue("1543", "https://github.com/trinodb/trino/issues/1543")\)
- Improve performance for broadcast joins by using dynamic filtering. This can be enabled via the #raw("experimental.enable-dynamic-filtering") configuration option or the #raw("enable_dynamic_filtering") session property. \(#issue("1686", "https://github.com/trinodb/trino/issues/1686")\)

== Security

- Improve the security of query results with one-time tokens. \(#issue("1654", "https://github.com/trinodb/trino/issues/1654")\)

== Hive connector

- Fix reading #raw("TEXT") file collection delimiter set by Hive versions earlier than 3.0. \(#issue("1714", "https://github.com/trinodb/trino/issues/1714")\)
- Fix a regression that prevented Presto from using the AWS Glue metastore. \(#issue("1698", "https://github.com/trinodb/trino/issues/1698")\)
- Allow skipping header or footer lines for #raw("CSV") format tables via the #raw("skip_header_line_count") and #raw("skip_footer_line_count") table properties. \(#issue("1090", "https://github.com/trinodb/trino/issues/1090")\)
- Rename table property #raw("textfile_skip_header_line_count") to #raw("skip_header_line_count") and #raw("textfile_skip_footer_line_count") to #raw("skip_footer_line_count"). \(#issue("1090", "https://github.com/trinodb/trino/issues/1090")\)
- Add support for LZOP compressed \(#raw(".lzo")\) files. Previously, queries accessing LZOP compressed files would fail, unless all files were small. \(#issue("1701", "https://github.com/trinodb/trino/issues/1701")\)
- Add support for bucket-aware read of tables using bucketing version 2. \(#issue("538", "https://github.com/trinodb/trino/issues/538")\)
- Add support for writing to tables using bucketing version 2. \(#issue("538", "https://github.com/trinodb/trino/issues/538")\)
- Allow caching directory listings for all tables or schemas. \(#issue("1668", "https://github.com/trinodb/trino/issues/1668")\)
- Add support for dynamic filtering for broadcast joins. \(#issue("1686", "https://github.com/trinodb/trino/issues/1686")\)

== PostgreSQL connector

- Support reading PostgreSQL arrays as the #raw("JSON") data type. This can be enabled by setting the #raw("postgresql.experimental.array-mapping") configuration property or the #raw("array_mapping") catalog session property to #raw("AS_JSON"). \(#issue("682", "https://github.com/trinodb/trino/issues/682")\)

== Elasticsearch connector

- Add support for Amazon Elasticsearch Service. \(#issue("1693", "https://github.com/trinodb/trino/issues/1693")\)

== Cassandra connector

- Add TLS support. \(#issue("1680", "https://github.com/trinodb/trino/issues/1680")\)

== JMX connector

- Add support for wildcards in configuration of history tables. \(#issue("1572", "https://github.com/trinodb/trino/issues/1572")\)

== SPI

- Fix #raw("QueryStatistics.getWallTime()") to report elapsed time rather than total scheduled time. \(#issue("1719", "https://github.com/trinodb/trino/issues/1719")\)
