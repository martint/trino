#import "/lib/trino-docs.typ": *

#anchor("doc-release-release-0-159")
= Release 0.159

== General

- Improve predicate performance for #raw("JOIN") queries.

== Hive

- Optimize filtering of partition names to reduce object creation.
- Add limit on the number of partitions that can potentially be read per table scan. This limit is configured using #raw("hive.max-partitions-per-scan") and defaults to 100,000.
