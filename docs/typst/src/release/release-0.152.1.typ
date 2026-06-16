#import "/lib/trino-docs.typ": *

#anchor("doc-release-release-0-152-1")
= Release 0.152.1

== General

- Fix race which could cause failed queries to have no error details.
- Fix race in HTTP layer which could cause queries to fail.
