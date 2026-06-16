#import "/lib/trino-docs.typ": *

#anchor("doc-release-release-0-99")
= Release 0.99

== General

- Reduce lock contention in #raw("TaskExecutor").
- Fix reading maps with null keys from ORC.
- Fix precomputed hash optimization for nulls values.
- Make #link(label("fn-contains"), raw("contains()")) work for all comparable types.
