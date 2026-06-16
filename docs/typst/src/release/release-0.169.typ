#import "/lib/trino-docs.typ": *

#anchor("doc-release-release-0-169")
= Release 0.169

== General

- Fix regression that could cause queries involving #raw("JOIN") and certain language features such as #raw("current_date"), #raw("current_time") or #raw("extract") to fail during planning.
- Limit the maximum allowed input size to #link(label("fn-levenshtein-distance"), raw("levenshtein_distance")).
- Improve performance of #link(label("fn-map-agg"), raw("map_agg")) and #link(label("fn-multimap-agg"), raw("multimap_agg")).
- Improve memory accounting when grouping on a single #raw("BIGINT") column.

== JDBC driver

- Return correct class name for #raw("ARRAY") type from #raw("ResultSetMetaData.getColumnClassName()").

== CLI

- Fix support for non-standard offset time zones \(e.g., #raw("GMT+01:00")\).

== Cassandra

- Add custom error codes.
