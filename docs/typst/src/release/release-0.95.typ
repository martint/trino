#import "/lib/trino-docs.typ": *

#anchor("doc-release-release-0-95")
= Release 0.95

== General

- Fix task and stage leak, caused when a stage finishes before its substages.
