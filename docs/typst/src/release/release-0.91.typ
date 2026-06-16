#import "/lib/trino-docs.typ": *

#anchor("doc-release-release-0-91")
= Release 0.91

#warning[
This release has a memory leak and should not be used.
]

== General

- Clear #raw("LazyBlockLoader") reference after load to free memory earlier.
