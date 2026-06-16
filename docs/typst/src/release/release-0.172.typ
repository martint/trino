#import "/lib/trino-docs.typ": *

#anchor("doc-release-release-0-172")
= Release 0.172

== General

- Fix correctness issue in #raw("ORDER BY") queries due to improper implicit coercions.
- Fix planning failure when #raw("GROUP BY") queries contain lambda expressions.
- Fix planning failure when left side of #raw("IN") expression contains subqueries.
- Fix incorrect permissions check for #raw("SHOW TABLES").
- Fix planning failure when #raw("JOIN") clause contains lambda expressions that reference columns or variables from the enclosing scope.
- Reduce memory usage of #link(label("fn-map-agg"), raw("map_agg")) and #link(label("fn-map-union"), raw("map_union")).
- Reduce memory usage of #raw("GROUP BY") queries.
