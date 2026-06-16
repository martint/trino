#import "/lib/trino-docs.typ": *

#anchor("doc-release-release-414")
= Release 414 \(19 Apr 2023\)

== General

- Add #link(label("ref-json-descendant-member-accessor"))[recursive member access] to the #link(label("ref-json-path-language"))[JSON path language]. \(#issue("16854", "https://github.com/trinodb/trino/issues/16854")\)
- Add the #link(label("ref-built-in-table-functions"))[#raw("sequence()")] table function. \(#issue("16716", "https://github.com/trinodb/trino/issues/16716")\)
- Add support for progress estimates when #link(label("doc-admin-fault-tolerant-execution"))[fault-tolerant execution] is enabled. \(#issue("13072", "https://github.com/trinodb/trino/issues/13072")\)
- Add support for #raw("CUBE") and #raw("ROLLUP") with composite sets. \(#issue("16981", "https://github.com/trinodb/trino/issues/16981")\)
- Add experimental support for tracing using #link("https://opentelemetry.io/")[OpenTelemetry]. This can be enabled by setting the #raw("tracing.enabled") configuration property to #raw("true") and optionally configuring the #link("https://opentelemetry.io/docs/reference/specification/protocol/otlp/")[OLTP\/gRPC endpoint] by setting the #raw("tracing.exporter.endpoint") configuration property. \(#issue("16950", "https://github.com/trinodb/trino/issues/16950")\)
- Improve performance for certain queries that produce no values. \(#issue("15555", "https://github.com/trinodb/trino/issues/15555"), #issue("16515", "https://github.com/trinodb/trino/issues/16515")\)
- Fix query failure for recursive queries involving lambda expressions. \(#issue("16989", "https://github.com/trinodb/trino/issues/16989")\)
- Fix incorrect results when using the #link(label("fn-sequence"), raw("sequence")) function with values greater than 231 \(about 2.1 billion\). \(#issue("16742", "https://github.com/trinodb/trino/issues/16742")\)

== Security

- Disallow #link(label("doc-admin-graceful-shutdown"))[graceful shutdown] with the #raw("default") #link(label("doc-security-built-in-system-access-control"))[system access control]. Shutdowns can be re-enabled by using the #raw("allow-all") system access control, or by configuring #link(label("ref-system-file-auth-system-information"))[system information rules] with the #raw("file") system access control. \(#issue("17105", "https://github.com/trinodb/trino/issues/17105")\)

== Delta Lake connector

- Add support for #raw("INSERT"), #raw("UPDATE"), and #raw("DELETE") operations on tables with a #raw("name") column mapping. \(#issue("12638", "https://github.com/trinodb/trino/issues/12638")\)
- Add support for #link("https://docs.databricks.com/release-notes/runtime/12.2.html")[Databricks 12.2 LTS]. \(#issue("16905", "https://github.com/trinodb/trino/issues/16905")\)
- Disallow reading tables with #link("https://github.com/delta-io/delta/blob/master/PROTOCOL.md#deletion-vectors")[deletion vectors]. Previously, this returned incorrect results. \(#issue("16884", "https://github.com/trinodb/trino/issues/16884")\)

== Iceberg connector

- Add support for Hive external tables in the #raw("migrate") table procedure. \(#issue("16704", "https://github.com/trinodb/trino/issues/16704")\)

== Kafka connector

- Fix query failure when a Kafka topic contains tombstones \(messages with a #raw("NULL") value\). \(#issue("16962", "https://github.com/trinodb/trino/issues/16962")\)

== Kudu connector

- Fix query failure when merging two tables that were created by #raw("CREATE TABLE ... AS SELECT ..."). \(#issue("16848", "https://github.com/trinodb/trino/issues/16848")\)

== Pinot connector

- Fix incorrect results due to incorrect pushdown of aggregations. \(#issue("12655", "https://github.com/trinodb/trino/issues/12655")\)

== PostgreSQL connector

- Fix failure when fetching table statistics for PostgreSQL 14.0 and later. \(#issue("17061", "https://github.com/trinodb/trino/issues/17061")\)

== Redshift connector

- Add support for #link(label("doc-admin-fault-tolerant-execution"))[fault-tolerant execution]. \(#issue("16860", "https://github.com/trinodb/trino/issues/16860")\)
