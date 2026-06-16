#import "/lib/trino-docs.typ": *

#anchor("doc-release-release-0-157-1")
= Release 0.157.1

== General

- Fix regression that could cause high CPU and heap usage on coordinator, when processing certain types of long running queries.
