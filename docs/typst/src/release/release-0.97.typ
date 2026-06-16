#import "/lib/trino-docs.typ": *

#anchor("doc-release-release-0-97")
= Release 0.97

== General

- The queueing policy in Presto may now be injected.
- Speed up detection of ASCII strings in implementation of #raw("LIKE") operator.
- Fix NullPointerException when metadata-based query optimization is enabled.
- Fix possible infinite loop when decompressing ORC data.
- Fix an issue where #raw("NOT") clause was being ignored in #raw("NOT BETWEEN") predicates.
- Fix a planning issue in queries that use #raw("SELECT *"), window functions and implicit coercions.
- Fix scheduler deadlock for queries with a #raw("UNION") between #raw("VALUES") and #raw("SELECT").

== Hive

- Fix decoding of #raw("STRUCT") type from Parquet files.
- Speed up decoding of ORC files with very small stripes.
