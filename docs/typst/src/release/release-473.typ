#import "/lib/trino-docs.typ": *

#anchor("doc-release-release-473")
= Release 473 \(19 Mar 2025\)

#warning[
This release is broken and should not be used. GROUP BY and DISTINCT queries containing more than 33M unique groups can produce incorrect results. See: \(#issue("25381", "https://github.com/trinodb/trino/issues/25381")\)
]

== General

- Add support for array literals. \(#issue("25301", "https://github.com/trinodb/trino/issues/25301")\)
- Reduce the amount of memory required for #raw("DISTINCT") and #raw("GROUP BY") operations. \(#issue("25127", "https://github.com/trinodb/trino/issues/25127")\)
- Improve performance of #raw("GROUP BY") and #raw("DISTINCT") aggregations when spilling to disk is enabled \
  or grouping by #raw("row"), #raw("array"), or #raw("map") columns \(#issue("25294", "https://github.com/trinodb/trino/issues/25294")\)
- Fix failure when setting comments on columns with upper case letters. \(#issue("25297", "https://github.com/trinodb/trino/issues/25297")\)
- Fix potential query failure when #raw("retry_policy") set to #raw("TASK") \(#issue("25217", "https://github.com/trinodb/trino/issues/25217")\)

== Security

- Add LDAP-based group provider. \(#issue("23900", "https://github.com/trinodb/trino/issues/23900")\)
- Fix column masks not being applied on view columns with upper case. \(#issue("24054", "https://github.com/trinodb/trino/issues/24054")\)

== BigQuery connector

- Fix failure when initializing the connector on a machine with more than 32 CPU cores. \(#issue("25228", "https://github.com/trinodb/trino/issues/25228")\)

== Delta Lake connector

- Remove the deprecated #raw("glue-v1") metastore type. \(#issue("25201", "https://github.com/trinodb/trino/issues/25201")\)
- Remove deprecated Databricks Unity catalog integration. \(#issue("25250", "https://github.com/trinodb/trino/issues/25250")\)
- Fix Glue endpoint URL override. \(#issue("25324", "https://github.com/trinodb/trino/issues/25324")\)

== Hive connector

- Remove the deprecated #raw("glue-v1") metastore type. \(#issue("25201", "https://github.com/trinodb/trino/issues/25201")\)
- Remove deprecated Databricks Unity catalog integration. \(#issue("25250", "https://github.com/trinodb/trino/issues/25250")\)
- Fix Glue endpoint URL override. \(#issue("25324", "https://github.com/trinodb/trino/issues/25324")\)

== Hudi connector

- Fix queries getting stuck when reading empty partitions. \(#issue("19506 ", "https://github.com/trinodb/trino/issues/19506 ")\)
- Remove the deprecated #raw("glue-v1") metastore type. \(#issue("25201", "https://github.com/trinodb/trino/issues/25201")\)
- Fix Glue endpoint URL override. \(#issue("25324", "https://github.com/trinodb/trino/issues/25324")\)

== Iceberg connector

- Set the #raw("write.<filetype>.compression-codec") table property when creating new tables. \(#issue("24851", "https://github.com/trinodb/trino/issues/24851")\)
- Expose additional properties in #raw("$properties") tables. \(#issue("24812", "https://github.com/trinodb/trino/issues/24812")\)
- Fix Glue endpoint URL override. \(#issue("25324", "https://github.com/trinodb/trino/issues/25324")\)

== Kudu connector

- #breaking-marker("../release.html#breaking-changes") Remove the Kudu connector. \(#issue("24417", "https://github.com/trinodb/trino/issues/24417")\)

== Phoenix connector

- #breaking-marker("../release.html#breaking-changes") Remove the Phoenix connector. \(#issue("24135", "https://github.com/trinodb/trino/issues/24135")\)

== SPI

- Add #raw("SourcePage") interface and #raw("ConnectorPageSource.getNextSourcePage()"). \(#issue("24011", "https://github.com/trinodb/trino/issues/24011")\)
- Deprecate #raw("ConnectorPageSource.getNextPage()") for removal. \(#issue("24011", "https://github.com/trinodb/trino/issues/24011")\)
