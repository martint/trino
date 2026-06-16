#import "/lib/trino-docs.typ": *

#anchor("doc-release-release-0-175")
= Release 0.175

== General

- Fix #emph["position is not valid"] query execution failures.
- Fix memory accounting bug that can potentially cause #raw("OutOfMemoryError").
- Fix regression that could cause certain queries involving #raw("UNION") and #raw("GROUP BY") or #raw("JOIN") to fail during planning.
- Fix planning failure for #raw("GROUP BY") queries containing correlated subqueries in the #raw("SELECT") clause.
- Fix execution failure for certain #raw("DELETE") queries.
- Reduce occurrences of #emph["Method code too large"] errors.
- Reduce memory utilization for certain queries involving #raw("ORDER BY").
- Improve performance of map subscript from O\(n\) to O\(1\) when the map is produced by an eligible operation, including the map constructor and Hive readers \(except ORC and optimized Parquet\). More read and write operations will take advantage of this in future releases.
- Add #raw("enable_intermediate_aggregations") session property to enable the use of intermediate aggregations within un-grouped aggregations.
- Add support for #raw("INTERVAL") data type to #link(label("fn-avg"), raw("avg")) and #link(label("fn-sum"), raw("sum")) aggregation functions.
- Add support for #raw("INT") as an alias for the #raw("INTEGER") data type.
- Add resource group information to query events.

== Hive

- Make table creation metastore operations idempotent, which allows recovery when retrying timeouts or other errors.

== MongoDB

- Rename #raw("mongodb.connection-per-host") config option to #raw("mongodb.connections-per-host").
