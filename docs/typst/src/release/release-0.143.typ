#import "/lib/trino-docs.typ": *

#anchor("doc-release-release-0-143")
= Release 0.143

== General

- Fix race condition in output buffer that can cause a page to be lost.
- Fix case-sensitivity issue when de-referencing row fields.
- Fix bug in phased scheduler that could cause queries to block forever.
- Fix #link(label("doc-sql-delete"))[DELETE] for predicates that optimize to false.
- Add support for scalar subqueries in #link(label("doc-sql-delete"))[DELETE] queries.
- Add config option #raw("query.max-cpu-time") to limit CPU time used by a query.
- Add loading indicator and error message to query detail page in UI.
- Add query teardown to query timeline visualizer.
- Add string padding functions #link(label("fn-lpad"), raw("lpad")) and #link(label("fn-rpad"), raw("rpad")).
- Add #link(label("fn-width-bucket"), raw("width_bucket")) function.
- Add #link(label("fn-truncate"), raw("truncate")) function.
- Improve query startup time in large clusters.
- Improve error messages for #raw("CAST") and #link(label("fn-slice"), raw("slice")).

== Hive

- Fix native memory leak when reading or writing gzip compressed data.
- Fix performance regression due to complex expressions not being applied when pruning partitions.
- Fix data corruption in #link(label("doc-sql-create-table-as"))[CREATE TABLE AS] when #raw("hive.respect-table-format") config is set to false and user-specified storage format does not match default.
