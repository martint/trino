#import "/lib/trino-docs.typ": *

#anchor("doc-release-release-0-73")
= Release 0.73

== Cassandra plugin

The Cassandra connector now supports CREATE TABLE and DROP TABLE. Additionally, the connector now takes into account Cassandra indexes when generating CQL. This release also includes several bug fixes and performance improvements.

== General

- New window functions: #link(label("fn-lead"), raw("lead")), and #link(label("fn-lag"), raw("lag"))
- New scalar function: #link(label("fn-json-size"), raw("json_size"))
