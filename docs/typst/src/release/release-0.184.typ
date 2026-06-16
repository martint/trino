#import "/lib/trino-docs.typ": *

#anchor("doc-release-release-0-184")
= Release 0.184

== General

- Fix query execution failure for #raw("split_to_map(...)[...]").
- Fix issue that caused queries containing #raw("CROSS JOIN") to continue using CPU resources even after they were killed.
- Fix planning failure for some query shapes containing #raw("count(*)") and a non-empty #raw("GROUP BY") clause.
- Fix communication failures caused by lock contention in the local scheduler.
- Improve performance of #link(label("fn-element-at"), raw("element_at")) for maps to be constant time rather than proportional to the size of the map.
- Improve performance of queries with gathering exchanges.
- Require #raw("coalesce()") to have at least two arguments, as mandated by the SQL standard.
- Add #link(label("fn-hamming-distance"), raw("hamming_distance")) function.

== JDBC driver

- Always invoke the progress callback with the final stats at query completion.

== Web UI

- Add worker status page with information about currently running threads and resource utilization \(CPU, heap, memory pools\). This page is accessible by clicking a hostname on a query task list.

== Hive

- Fix partition filtering for keys of #raw("CHAR"), #raw("DECIMAL"), or #raw("DATE") type.
- Reduce system memory usage when reading table columns containing string values from ORC or DWRF files. This can prevent high GC overhead or out-of-memory crashes.

== TPC-DS

- Fix display of table statistics when running #raw("SHOW STATS FOR ...").

== SPI

- Row columns or values represented with #raw("ArrayBlock") and #raw("InterleavedBlock") are no longer supported. They must be represented as #raw("RowBlock") or #raw("SingleRowBlock").
- Add #raw("source") field to #raw("ConnectorSession").
