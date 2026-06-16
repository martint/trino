#import "/lib/trino-docs.typ": *

#anchor("doc-release-release-0-211")
= Release 0.211

== General

- Fix missing final query plan in #raw("QueryCompletedEvent"). Statistics and cost estimates are removed from the plan text because they may not be available during event generation.
- Update the default value of the #raw("http-server.https.excluded-cipher") config property to exclude cipher suites with a weak hash algorithm or without forward secrecy. Specifically, this means all ciphers that use the RSA key exchange are excluded by default. Consequently, TLS 1.0 or TLS 1.1 are no longer supported with the default configuration. The #raw("http-server.https.excluded-cipher") config property can be set to empty string to restore the old behavior.
- Add #link(label("fn-st-geomfrombinary"), raw("ST_GeomFromBinary")) and #link(label("fn-st-asbinary"), raw("ST_AsBinary")) functions that convert geometries to and from Well-Known Binary format.
- Remove the #raw("verbose_stats") session property, and rename the #raw("task.verbose-stats") configuration property to #raw("task.per-operator-cpu-timer-enabled").
- Improve query planning performance for queries containing multiple joins and a large number of columns \(#issue("11196", "https://github.com/prestodb/presto/issues/11196")\).
- Add built-in #link(label("doc-admin-session-property-managers"))[file based property manager] to automate the setting of session properties based on query characteristics.
- Allow running on a JVM from any vendor that meets the functional requirements.

== Hive connector

- Fix regression in 0.210 that causes query failure when writing ORC or DWRF files that occurs for specific patterns of input data. When the writer attempts to give up using dictionary encoding for a column that is highly compressed, the process of transitioning to use direct encoding instead can fail.
- Fix coordinator OOM when a query scans many partitions of a Hive table \(#issue("11322", "https://github.com/prestodb/presto/issues/11322")\).
- Improve readability of columns, partitioning, and transactions in explain plains.

== Thrift connector

- Fix lack of retry for network errors while sending requests.

== Resource group

- Add documentation for new resource group scheduling policies.
- Remove running and queue time limits from resource group configuration. Legacy behavior can be replicated by using the #link(label("doc-admin-session-property-managers"))[file based property manager] to set session properties.

== SPI

- Clarify semantics of #raw("predicate") in #raw("ConnectorTableLayout").
- Reduce flexibility of #raw("unenforcedConstraint") that a connector can return in #raw("getTableLayouts"). For each column in the predicate, the connector must enforce the entire domain or none.
- Make the null vector in #raw("ArrayBlock"), #raw("MapBlock"), and #raw("RowBlock") optional. When it is not present, all entries in the #raw("Block") are non-null.
