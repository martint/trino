#import "/lib/trino-docs.typ": *

#anchor("doc-release-release-403")
= Release 403 \(15 Nov 2022\)

== General

- Include the amount of data read from external sources in the output of #raw("EXPLAIN ANALYZE"). \(#issue("14907", "https://github.com/trinodb/trino/issues/14907")\)
- Improve performance of worker-to-worker data transfer encryption when fault-tolerant execution is enabled. \(#issue("14941", "https://github.com/trinodb/trino/issues/14941")\)
- Improve performance of aggregations when input data does not contain nulls. \(#issue("14567", "https://github.com/trinodb/trino/issues/14567")\)
- Fix potential failure when clients do not support variable precision temporal types. \(#issue("14950", "https://github.com/trinodb/trino/issues/14950")\)
- Fix query deadlock in multi-join queries where broadcast join size is underestimated. \(#issue("14948", "https://github.com/trinodb/trino/issues/14948")\)
- Fix incorrect results when #raw("min(x, n)") or #raw("max(x, n)") is used as a window function. \(#issue("14886", "https://github.com/trinodb/trino/issues/14886")\)
- Fix failure for certain queries involving joins over partitioned tables. \(#issue("14317", "https://github.com/trinodb/trino/issues/14317")\)
- Fix incorrect order of parameters in #raw("DESCRIBE INPUT") when they appear in a #raw("WITH") clause. \(#issue("14738", "https://github.com/trinodb/trino/issues/14738")\)
- Fix failure for queries involving #raw("BETWEEN") predicates over #raw("varchar") columns that contain temporal data. \(#issue("14954", "https://github.com/trinodb/trino/issues/14954")\)

== Security

- Allow access token passthrough when using OAuth 2.0 authentication with refresh tokens enabled. \(#issue("14949", "https://github.com/trinodb/trino/issues/14949")\)

== BigQuery connector

- Improve performance of #raw("SHOW SCHEMAS") by adding a metadata cache. This can be configured with the #raw("bigquery.metadata.cache-ttl") catalog property, which is disabled by default. \(#issue("14729", "https://github.com/trinodb/trino/issues/14729")\)
- Fix failure when a #link("https://cloud.google.com/bigquery/docs/row-level-security-intro")[row access policy] returns an empty result. \(#issue("14760", "https://github.com/trinodb/trino/issues/14760")\)

== ClickHouse connector

- Add mapping for the ClickHouse #raw("DateTime(timezone)") type to the Trino #raw("timestamp(0) with time zone") type for read-only operations. \(#issue("13541", "https://github.com/trinodb/trino/issues/13541")\)

== Delta Lake connector

- Fix statistics for #raw("DATE") columns. \(#issue("15005", "https://github.com/trinodb/trino/issues/15005")\)

== Hive connector

- Avoid showing the unsupported #raw("AUTHORIZATION ROLE") property in the result of #raw("SHOW CREATE SCHEMA") when the access control doesn't support roles. \(#issue("8817", "https://github.com/trinodb/trino/issues/8817")\)

== Iceberg connector

- Improve performance and storage requirements when running the #raw("expire_snapshots") table procedure on S3-compatible storage. \(#issue("14434", "https://github.com/trinodb/trino/issues/14434")\)
- Allow registering existing table files in the metastore with the new #link(label("ref-iceberg-register-table"))[#raw("register_table") procedure]. \(#issue("13552", "https://github.com/trinodb/trino/issues/13552")\)

== MongoDB connector

- Add support for #link(label("doc-sql-delete"))[DELETE]. \(#issue("14864", "https://github.com/trinodb/trino/issues/14864")\)
- Fix incorrect results when predicates over #raw("varchar") and #raw("char") columns are pushed into the connector and MongoDB collections have a collation specified. \(#issue("14900", "https://github.com/trinodb/trino/issues/14900")\)

== SQL Server connector

- Fix incorrect results when non-transactional #raw("INSERT") is disabled and bulk #raw("INSERT") is enabled. \(#issue("14856", "https://github.com/trinodb/trino/issues/14856")\)

== SPI

- Enhance #raw("ConnectorTableLayout") to allow the connector to specify that multiple writers per partition are allowed. \(#issue("14956", "https://github.com/trinodb/trino/issues/14956")\)
- Remove deprecated methods from #raw("ConnectorPageSinkProvider"). \(#issue("14959", "https://github.com/trinodb/trino/issues/14959")\)
