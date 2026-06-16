#import "/lib/trino-docs.typ": *

#anchor("doc-release-release-0-135")
= Release 0.135

== General

- Add summary of change in CPU usage to verifier output.
- Add cast between JSON and VARCHAR, BOOLEAN, DOUBLE, BIGINT. For the old behavior of cast between JSON and VARCHAR \(pre-#link(label("doc-release-release-0-122"))[Release 0.122]\), use #link(label("fn-json-parse"), raw("json_parse")) and #link(label("fn-json-format"), raw("json_format")).
- Fix bug in 0.134 that prevented query page in web UI from displaying in Safari.
