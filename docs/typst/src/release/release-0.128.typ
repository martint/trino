#import "/lib/trino-docs.typ": *

#anchor("doc-release-release-0-128")
= Release 0.128

== Graceful shutdown

Workers can now be instructed to shutdown. This is done by submiting a #raw("PUT") request to #raw("/v1/info/state") with the body #raw("\"SHUTTING_DOWN\""). Once instructed to shutdown, the worker will no longer receive new tasks, and will exit once all existing tasks have completed.

== General

- Fix cast from json to structural types when rows or maps have arrays, rows, or maps nested in them.
- Fix Example HTTP connector. It would previously fail with a JSON deserialization error.
- Optimize memory usage in TupleDomain.
- Fix an issue that can occur when an #raw("INNER JOIN") has equi-join clauses that align with the grouping columns used by a preceding operation such as #raw("GROUP BY"), #raw("DISTINCT"), etc. When this triggers, the join may fail to produce some of the output rows.

== MySQL

- Fix handling of MySQL database names with underscores.
