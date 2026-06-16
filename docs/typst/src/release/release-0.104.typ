#import "/lib/trino-docs.typ": *

#anchor("doc-release-release-0-104")
= Release 0.104

== General

- Handle thread interruption in StatementClient.
- Fix CLI hang when server becomes unreachable during a query.
- Add #link(label("fn-covar-pop"), raw("covar_pop")), #link(label("fn-covar-samp"), raw("covar_samp")), #link(label("fn-corr"), raw("corr")), #link(label("fn-regr-slope"), raw("regr_slope")), and #link(label("fn-regr-intercept"), raw("regr_intercept")) functions.
- Fix potential deadlock in cluster memory manager.
- Add a visualization of query execution timeline.
- Allow mixed case in input to #link(label("fn-from-hex"), raw("from_hex")).
- Display "BLOCKED" state in web UI.
- Reduce CPU usage in coordinator.
- Fix excess object retention in workers due to long running queries.
- Reduce memory usage of #link(label("fn-array-distinct"), raw("array_distinct")).
- Add optimizer for projection push down which can improve the performance of certain query shapes.
- Improve query performance by storing pre-partitioned pages.
- Support #raw("TIMESTAMP") for #link(label("fn-first-value"), raw("first_value")), #link(label("fn-last-value"), raw("last_value")), #link(label("fn-nth-value"), raw("nth_value")), #link(label("fn-lead"), raw("lead")) and #link(label("fn-lag"), raw("lag")).

== Hive

- Upgrade to Parquet 1.6.0.
- Collect request time and retry statistics in #raw("PrestoS3FileSystem").
- Fix retry attempt counting for S3.
