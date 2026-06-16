#import "/lib/trino-docs.typ": *

#anchor("doc-release-release-0-83")
= Release 0.83

== Raptor

- Raptor now enables specifying the backup storage location. This feature is highly experimental.
- Fix the handling of shards not assigned to any node.

== General

- Fix resource leak in query queues.
- Fix NPE when writing null #raw("ARRAY/MAP") to Hive.
- Fix #link(label("fn-json-array-get"), raw("json_array_get")) to handle nested structures.
- Fix #raw("UNNEST") on null collections.
- Fix a regression where queries that fail during parsing or analysis do not expire.
- Make #raw("JSON") type comparable.
- Added an optimization for hash aggregations. This optimization is turned off by default. To turn it on, add #raw("optimizer.optimize-hash-generation=true") to the coordinator config properties.
