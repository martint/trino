#import "/lib/trino-docs.typ": *

#anchor("doc-release-release-0-108")
= Release 0.108

== General

- Fix incorrect query results when a window function follows a #link(label("fn-row-number"), raw("row_number")) function and both are partitioned on the same column\(s\).
- Fix planning issue where queries that apply a #raw("false") predicate to the result of a non-grouped aggregation produce incorrect results.
- Fix exception when #raw("ORDER BY") clause contains duplicate columns.
- Fix issue where a query \(read or write\) that should fail can instead complete successfully with zero rows.
- Add #link(label("fn-normalize"), raw("normalize")), #link(label("fn-from-iso8601-timestamp"), raw("from_iso8601_timestamp")), #link(label("fn-from-iso8601-date"), raw("from_iso8601_date")) and #link(label("fn-to-iso8601"), raw("to_iso8601")) functions.
- Add support for #link(label("fn-position"), raw("position")) syntax.
- Add Teradata compatibility functions: #link(label("fn-index"), raw("index")), #link(label("fn-char2hexint"), raw("char2hexint")), #link(label("fn-to-char"), raw("to_char")), #link(label("fn-to-date"), raw("to_date")) and #link(label("fn-to-timestamp"), raw("to_timestamp")).
- Make #raw("ctrl-C") in CLI cancel the query \(rather than a partial cancel\).
- Allow calling #raw("Connection.setReadOnly(false)") in the JDBC driver. The read-only status for the connection is currently ignored.
- Add missing #raw("CAST") from #raw("VARCHAR") to #raw("TIMESTAMP WITH TIME ZONE").
- Allow optional time zone in #raw("CAST") from #raw("VARCHAR") to #raw("TIMESTAMP") and #raw("TIMESTAMP WITH TIME ZONE").
- Trim values when converting from #raw("VARCHAR") to date\/time types.
- Add support for fixed time zones #raw("+00:00") and #raw("-00:00").
- Properly account for query memory when using the #link(label("fn-row-number"), raw("row_number")) function.
- Skip execution of inner join when the join target is empty.
- Improve query detail UI page.
- Fix printing of table layouts in #link(label("doc-sql-explain"))[EXPLAIN].
- Add #link(label("doc-connector-blackhole"))[Black Hole connector].

== Cassandra

- Randomly select Cassandra node for split generation.
- Fix handling of #raw("UUID") partition keys.
