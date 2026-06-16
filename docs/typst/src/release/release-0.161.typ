#import "/lib/trino-docs.typ": *

#anchor("doc-release-release-0-161")
= Release 0.161

== General

- Fix correctness issue for queries involving multiple nested EXCEPT clauses. A query such as #raw("a EXCEPT (b EXCEPT c)") was incorrectly evaluated as #raw("a EXCEPT b EXCEPT c") and thus could return the wrong result.
- Fix failure when executing prepared statements that contain parameters in the join criteria.
- Fix failure when describing the output of prepared statements that contain aggregations.
- Fix planning failure when a lambda is used in the context of an aggregation or subquery.
- Fix column resolution rules for #raw("ORDER BY") to match the behavior expected by the SQL standard. This is a change in semantics that breaks backwards compatibility. To ease migration of existing queries, the legacy behavior can be restored by the #raw("deprecated.legacy-order-by") config option or the #raw("legacy_order_by") session property.
- Improve error message when coordinator responds with #raw("403 FORBIDDEN").
- Improve performance for queries containing expressions in the join criteria that reference columns on one side of the join.
- Improve performance of #link(label("fn-map-concat"), raw("map_concat")) when one argument is empty.
- Remove #raw("/v1/execute") resource.
- Add new column to #link(label("doc-sql-show-columns"))[SHOW COLUMNS] \(and #link(label("doc-sql-describe"))[DESCRIBE]\) to show extra information from connectors.
- Add #link(label("fn-map"), raw("map")) to construct an empty #link(label("ref-map-type"))[map-type].

== Hive connector

- Remove #raw("\"Partition Key: \"") prefix from column comments and replace it with the new extra information field described above.

== JMX connector

- Add support for escaped commas in #raw("jmx.dump-tables") config property.
