#import "/lib/trino-docs.typ": *

#anchor("doc-release-release-0-149")
= Release 0.149

== General

- Fix runtime failure for queries that use grouping sets over unions.
- Do not ignore null values in #link(label("fn-array-agg"), raw("array_agg")).
- Fix failure when casting row values that contain null fields.
- Fix failure when using complex types as map keys.
- Fix potential memory tracking leak when queries are cancelled.
- Fix rejection of queries that do not match any queue\/resource group rules. Previously, a 500 error was returned to the client.
- Fix #link(label("fn-trim"), raw("trim")) and #link(label("fn-rtrim"), raw("rtrim")) functions to produce more intuitive results when the argument contains invalid #raw("UTF-8") sequences.
- Add a new web interface with cluster overview, realtime stats, and improved sorting and filtering of queries.
- Add support for #raw("FLOAT") type.
- Rename #raw("query.max-age") to #raw("query.min-expire-age").
- #raw("optimizer.columnar-processing") and #raw("optimizer.columnar-processing-dictionary") properties were merged to #raw("optimizer.processing-optimization") with possible values #raw("disabled"), #raw("columnar") and #raw("columnar_dictionary")
- #raw("columnar_processing") and #raw("columnar_processing_dictionary") session properties were merged to #raw("processing_optimization") with possible values #raw("disabled"), #raw("columnar") and #raw("columnar_dictionary")
- Change #raw("%y") \(2-digit year\) in #raw("date_parse") to evaluate to a year between 1970 and 2069 inclusive.
- Add #raw("queued") flag to #raw("StatementStats") in REST API.
- Improve error messages for math operations.
- Improve memory tracking in exchanges to avoid running out of Java heap space.
- Improve performance of subscript operator for the #raw("MAP") type.
- Improve performance of #raw("JOIN") and #raw("GROUP BY") queries.

== Hive

- Clean up empty staging directories after inserts.
- Add #raw("hive.dfs.ipc-ping-interval") config for HDFS.
- Change default value of #raw("hive.dfs-timeout") to 60 seconds.
- Fix ORC\/DWRF reader to avoid repeatedly fetching the same data when stripes are skipped.
- Fix force local scheduling for S3 or other non-HDFS file systems.
