#import "/lib/trino-docs.typ": *

#anchor("doc-release-release-0-113")
= Release 0.113

#warning[
The ORC reader in the Hive connector is broken in this release.
]

== Cluster resource management

The cluster resource manager announced in #link(label("doc-release-release-0-103"))[Release 0.103] is now enabled by default. You can disable it with the #raw("experimental.cluster-memory-manager-enabled") flag. Memory limits can now be configured via #raw("query.max-memory") which controls the total distributed memory a query may use and #raw("query.max-memory-per-node") which limits the amount of memory a query may use on any one node. On each worker, the #raw("resources.reserved-system-memory") config property controls how much memory is reserved for internal Presto data structures and temporary allocations.

== Session properties

All session properties have a type, default value, and description. The value for #link(label("doc-sql-set-session"))[SET SESSION] can now be any constant expression, and the #link(label("doc-sql-show-session"))[SHOW SESSION] command prints the current effective value and default value for all session properties.

This type safety extends to the #link(label("doc-develop-spi-overview"))[SPI] where properties can be validated and converted to any Java type using #raw("SessionPropertyMetadata"). For an example, see #raw("HiveSessionProperties").

#note[
This is a backwards incompatible change with the previous connector SPI. If you have written a connector that uses session properties, you will need to update your code to declare the properties in the #raw("Connector") implementation and callers of #raw("ConnectorSession.getProperty()") will now need the expected Java type of the property.
]

== General

- Allow using any type with value window functions #link(label("fn-first-value"), raw("first_value")), #link(label("fn-last-value"), raw("last_value")), #link(label("fn-nth-value"), raw("nth_value")), #link(label("fn-lead"), raw("lead")) and #link(label("fn-lag"), raw("lag")).
- Add #link(label("fn-element-at"), raw("element_at")) function.
- Add #link(label("fn-url-encode"), raw("url_encode")) and #link(label("fn-url-decode"), raw("url_decode")) functions.
- #link(label("fn-concat"), raw("concat")) now allows arbitrary number of arguments.
- Fix JMX connector. In the previous release it always returned zero rows.
- Fix handling of literal #raw("NULL") in #raw("IS DISTINCT FROM").
- Fix an issue that caused some specific queries to fail in planning.

== Hive

- Fix the Hive metadata cache to properly handle negative responses. This makes the background refresh work properly by clearing the cached metadata entries when an object is dropped outside of Presto. In particular, this fixes the common case where a table is dropped using Hive but Presto thinks it still exists.
- Fix metastore socket leak when SOCKS connect fails.

== SPI

- Changed the internal representation of structural types.

#note[
This is a backwards incompatible change with the previous connector SPI. If you have written a connector that uses structural types, you will need to update your code to the new APIs.
]
