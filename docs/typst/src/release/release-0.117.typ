#import "/lib/trino-docs.typ": *

#anchor("doc-release-release-0-117")
= Release 0.117

== General

- Add back casts between JSON and VARCHAR to provide an easier migration path to #link(label("fn-json-parse"), raw("json_parse")) and #link(label("fn-json-format"), raw("json_format")). These will be removed in a future release.
- Fix bug in semi joins and group bys on a single #raw("BIGINT") column where 0 could match #raw("NULL").
