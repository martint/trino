#import "/lib/trino-docs.typ": *

#anchor("doc-release-release-0-136")
= Release 0.136

== General

- Add #raw("control.query-types") and #raw("test.query-types") to verifier, which can be used to select the type of queries to run.
- Fix issue where queries with #raw("ORDER BY LIMIT") with a limit greater than 2147483647 could fail or return incorrect results.
- Add query plan visualization with live stats to the web UI.
