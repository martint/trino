#import "/lib/trino-docs.typ": *

#anchor("doc-release-release-0-88")
= Release 0.88

== General

- Added #link(label("fn-arbitrary"), raw("arbitrary")) aggregation function.
- Allow using all #link(label("doc-functions-aggregate"))[Aggregate functions] as #link(label("doc-functions-window"))[Window functions].
- Support specifying window frames and correctly implement frames for all #link(label("doc-functions-window"))[Window functions].
- Allow #link(label("fn-approx-distinct"), raw("approx_distinct")) aggregation function to accept a standard error parameter.
- Implement #link(label("fn-least"), raw("least")) and #link(label("fn-greatest"), raw("greatest")) with variable number of arguments.
- #link(label("ref-array-type"))[array-type] is now comparable and can be used as #raw("GROUP BY") keys or in #raw("ORDER BY") expressions.
- Implement #raw("=") and #raw("<>") operators for #link(label("ref-row-type"))[row-type].
- Fix excessive garbage creation in the ORC reader.
- Fix an issue that could cause queries using #link(label("fn-row-number"), raw("row_number()")) and #raw("LIMIT") to never terminate.
- Fix an issue that could cause queries with #link(label("fn-row-number"), raw("row_number()")) and specific filters to produce incorrect results.
- Fixed an issue that caused the Cassandra plugin to fail to load with a SecurityException.
