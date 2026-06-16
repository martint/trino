#import "/lib/trino-docs.typ": *

#anchor("doc-release-release-0-107")
= Release 0.107

== General

- Added #raw("query_max_memory") session property. Note: this session property cannot increase the limit above the limit set by the #raw("query.max-memory") configuration option.
- Fixed task leak caused by queries that finish early, such as a #raw("LIMIT") query or cancelled query, when the cluster is under high load.
- Added #raw("task.info-refresh-max-wait") to configure task info freshness.
- Add support for #raw("DELETE") to language and connector SPI.
- Reenable error classification code for syntax errors.
- Fix out of bounds exception in #link(label("fn-lower"), raw("lower")) and #link(label("fn-upper"), raw("upper")) when the string contains the code point #raw("U+10FFFF").
