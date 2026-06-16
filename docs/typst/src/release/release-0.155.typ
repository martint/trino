#import "/lib/trino-docs.typ": *

#anchor("doc-release-release-0-155")
= Release 0.155

== General

- Fix incorrect results when queries contain multiple grouping sets that resolve to the same set.
- Fix incorrect results when using #raw("map") with #raw("IN") predicates.
- Fix compile failure for outer joins that have a complex join criteria.
- Fix error messages for failures during commit.
- Fix memory accounting for simple aggregation, top N and distinct queries. These queries may now report higher memory usage than before.
- Reduce unnecessary memory usage of #link(label("fn-map-agg"), raw("map_agg")), #link(label("fn-multimap-agg"), raw("multimap_agg")) and #link(label("fn-map-union"), raw("map_union")).
- Make #raw("INCLUDING"), #raw("EXCLUDING") and #raw("PROPERTIES") non-reserved keywords.
- Remove support for the experimental feature to compute approximate queries based on sampled tables.
- Properly account for time spent creating page source.
- Various optimizations to reduce coordinator CPU usage.

== Hive

- Fix schema evolution support in new Parquet reader.
- Fix #raw("NoClassDefFoundError") when using Hadoop KMS.
- Add support for Avro file format.
- Always produce dictionary blocks for DWRF dictionary encoded streams.

== SPI

- Remove legacy connector API.
