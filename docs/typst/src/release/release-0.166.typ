#import "/lib/trino-docs.typ": *

#anchor("doc-release-release-0-166")
= Release 0.166

== General

- Fix failure due to implicit coercion issue in #raw("IN") expressions for certain combinations of data types \(e.g., #raw("double") and #raw("decimal")\).
- Add #raw("query.max-length") config flag to set the maximum length of a query. The default maximum length is 1MB.
- Improve performance of #link(label("fn-approx-percentile"), raw("approx_percentile")).

== Hive

- Include original exception from metastore for #raw("AlreadyExistsException") when adding partitions.
- Add support for the Hive JSON file format \(#raw("org.apache.hive.hcatalog.data.JsonSerDe")\).

== Cassandra

- Add configuration properties for speculative execution.

== SPI

- Add peak memory reservation to #raw("SplitStatistics") in split completion events.
