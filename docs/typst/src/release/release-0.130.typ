#import "/lib/trino-docs.typ": *

#anchor("doc-release-release-0-130")
= Release 0.130

== General

- Fix a performance regression in #raw("GROUP BY") and #raw("JOIN") queries when the length of the keys is between 16 and 31 bytes.
- Add #link(label("fn-map-concat"), raw("map_concat")) function.
- Performance improvements for filters, projections and dictionary encoded data. This optimization is turned off by default. It can be configured via the #raw("optimizer.columnar-processing-dictionary") config property or the #raw("columnar_processing_dictionary") session property.
- Improve performance of aggregation queries with large numbers of groups.
- Improve performance for queries that use #link(label("ref-array-type"))[array-type] type.
- Fix querying remote views in MySQL and PostgreSQL connectors.
