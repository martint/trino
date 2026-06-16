#import "/lib/trino-docs.typ": *

#anchor("doc-release-release-317")
= Release 317 \(1 Aug 2019\)

== General

- Fix #link(label("fn-url-extract-parameter"), raw("url_extract_parameter")) when the query string contains an encoded #raw("&") or #raw("=") character.
- Export MBeans from the #raw("db") resource group configuration manager. \(#issue("1151", "https://github.com/trinodb/trino/issues/1151")\)
- Add #link(label("fn-all-match"), raw("all_match")), #link(label("fn-any-match"), raw("any_match")), and #link(label("fn-none-match"), raw("none_match")) functions. \(#issue("1045", "https://github.com/trinodb/trino/issues/1045")\)
- Add support for fractional weights in #link(label("fn-approx-percentile"), raw("approx_percentile")). \(#issue("1168", "https://github.com/trinodb/trino/issues/1168")\)
- Add support for node dynamic filtering for semi-joins and filters when the experimental WorkProcessor pipelines feature is enabled. \(#issue("1075", "https://github.com/trinodb/trino/issues/1075"), #issue("1155", "https://github.com/trinodb/trino/issues/1155"), #issue("1119", "https://github.com/trinodb/trino/issues/1119")\)
- Allow overriding session time zone for clients via the #raw("sql.forced-session-time-zone") configuration property. \(#issue("1164", "https://github.com/trinodb/trino/issues/1164")\)

== Web UI

- Fix tooltip visibility on stage performance details page. \(#issue("1113", "https://github.com/trinodb/trino/issues/1113")\)
- Add planning time to query details page. \(#issue("1115", "https://github.com/trinodb/trino/issues/1115")\)

== Security

- Allow schema owner to create, drop, and rename schema when using file-based connector access control. \(#issue("1139", "https://github.com/trinodb/trino/issues/1139")\)
- Allow respecting the #raw("X-Forwarded-For") header when retrieving the IP address of the client submitting the query. This information is available in the #raw("remoteClientAddress") field of the #raw("QueryContext") class for query events. The behavior can be controlled via the #raw("dispatcher.forwarded-header") configuration property, as the header should only be used when the Presto coordinator is behind a proxy. \(#issue("1033", "https://github.com/trinodb/trino/issues/1033")\)

== JDBC driver

- Fix #raw("DatabaseMetaData.getURL()") to include the #raw("jdbc:") prefix. \(#issue("1211", "https://github.com/trinodb/trino/issues/1211")\)

== Elasticsearch connector

- Add support for nested fields. \(#issue("1001", "https://github.com/trinodb/trino/issues/1001")\)

== Hive connector

- Fix bucketing version safety check to correctly disallow writes to tables that use an unsupported bucketing version. \(#issue("1199", "https://github.com/trinodb/trino/issues/1199")\)
- Fix metastore error handling when metastore debug logging is enabled. \(#issue("1152", "https://github.com/trinodb/trino/issues/1152")\)
- Improve performance of file listings in #raw("system.sync_partition_metadata") procedure, especially for S3. \(#issue("1093", "https://github.com/trinodb/trino/issues/1093")\)

== Kudu connector

- Update Kudu client library version to #raw("1.10.0"). \(#issue("1086", "https://github.com/trinodb/trino/issues/1086")\)

== MongoDB connector

- Allow passwords to contain the #raw(":") or #raw("@") characters. \(#issue("1094", "https://github.com/trinodb/trino/issues/1094")\)

== PostgreSQL connector

- Add support for reading #raw("hstore") data type. \(#issue("1101", "https://github.com/trinodb/trino/issues/1101")\)

== SPI

- Allow delete to be implemented for non-legacy connectors. \(#issue("1015", "https://github.com/trinodb/trino/issues/1015")\)
- Remove deprecated method from #raw("ConnectorPageSourceProvider"). \(#issue("1095", "https://github.com/trinodb/trino/issues/1095")\)
