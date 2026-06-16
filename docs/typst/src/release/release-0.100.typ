#import "/lib/trino-docs.typ": *

#anchor("doc-release-release-0-100")
= Release 0.100

== System connector

The #link(label("doc-connector-system"))[System connector] now works like other connectors: global system tables are only available in the #raw("system") catalog, rather than in a special schema that is available in every catalog. Additionally, connectors may now provide system tables that are available within that connector's catalog by implementing the #raw("getSystemTables()") method on the #raw("Connector") interface.

== General

- Fix #raw("%f") specifier in #link(label("fn-date-format"), raw("date_format")) and #raw("date_parse").
- Add #raw("WITH ORDINALITY") support to #raw("UNNEST").
- Add #link(label("fn-array-distinct"), raw("array_distinct")) function.
- Add #link(label("fn-split"), raw("split")) function.
- Add #link(label("fn-degrees"), raw("degrees")) and #link(label("fn-radians"), raw("radians")) functions.
- Add #link(label("fn-to-base"), raw("to_base")) and #link(label("fn-from-base"), raw("from_base")) functions.
- Rename config property #raw("task.shard.max-threads") to #raw("task.max-worker-threads"). This property sets the number of threads used to concurrently process splits. The old property name is deprecated and will be removed in a future release.
- Fix referencing #raw("NULL") values in #link(label("ref-row-type"))[row-type].
- Make #link(label("ref-map-type"))[map-type] comparable.
- Fix leak of tasks blocked during query teardown.
- Improve query queue config validation.
