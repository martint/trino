#import "/lib/trino-docs.typ": *

#anchor("doc-release-release-0-127")
= Release 0.127

== General

- Disable index join repartitioning when it disrupts streaming execution.
- Fix memory accounting leak in some #raw("JOIN") queries.
