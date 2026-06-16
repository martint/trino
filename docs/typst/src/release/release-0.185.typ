#import "/lib/trino-docs.typ": *

#anchor("doc-release-release-0-185")
= Release 0.185

== General

- Fix incorrect column names in #raw("QueryCompletedEvent").
- Fix excessive CPU usage in coordinator for queries that have large string literals containing non-ASCII characters.
- Fix potential infinite loop during query optimization when constant expressions fail during evaluation.
- Fix incorrect ordering when the same field appears multiple times with different ordering specifications in a window function #raw("ORDER BY") clause. For example: #raw("OVER (ORDER BY x ASC, x DESC)").
- Do not allow dropping or renaming hidden columns.
- When preparing to drop a column, ignore hidden columns when checking if the table only has one column.
- Improve performance of joins where the condition is a range over a function. For example: #raw("a JOIN b ON b.x < f(a.x) AND b.x > g(a.x)")
- Improve performance of certain window functions \(e.g., #raw("LAG")\) with similar specifications.
- Extend #link(label("fn-substr"), raw("substr")) function to work on #raw("VARBINARY") in addition to #raw("CHAR") and #raw("VARCHAR").
- Add cast from #raw("JSON") to #raw("ROW").
- Allow usage of #raw("TRY") within lambda expressions.

== Hive

- Improve ORC reader efficiency by only reading small ORC streams when accessed in the query.
- Improve RCFile IO efficiency by increasing the buffer size from 1 to 8 MB.
- Fix native memory leak for optimized RCFile writer.
- Fix potential native memory leak for optimized ORC writer.

== Memory connector

- Add support for views.
