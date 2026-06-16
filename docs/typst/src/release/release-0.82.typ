#import "/lib/trino-docs.typ": *

#anchor("doc-release-release-0-82")
= Release 0.82

- Presto now supports the #link(label("ref-row-type"))[row-type] type, and all Hive structs are converted to ROWs, instead of JSON encoded VARCHARs.
- Add #link(label("fn-current-timezone"), raw("current_timezone")) function.
- Improve planning performance for queries with thousands of columns.
- Fix a regression that was causing excessive memory allocation and GC pressure in the coordinator.
