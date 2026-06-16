#import "/lib/trino-docs.typ": *

#anchor("doc-release-release-0-109")
= Release 0.109

== General

- Add #link(label("fn-slice"), raw("slice")), #link(label("fn-md5"), raw("md5")), #link(label("fn-array-min"), raw("array_min")) and #link(label("fn-array-max"), raw("array_max")) functions.
- Fix bug that could cause queries submitted soon after startup to hang forever.
- Fix bug that could cause #raw("JOIN") queries to hang forever, if the right side of the #raw("JOIN") had too little data or skewed data.
- Improve index join planning heuristics to favor streaming execution.
- Improve validation of date\/time literals.
- Produce RPM package for Presto server.
- Always redistribute data when writing tables to avoid skew. This can be disabled by setting the session property #raw("redistribute_writes") or the config property #raw("redistribute-writes") to false.

== Remove "Big Query" support

The experimental support for big queries has been removed in favor of the new resource manager which can be enabled via the #raw("experimental.cluster-memory-manager-enabled") config option. The #raw("experimental_big_query") session property and the following config options are no longer supported: #raw("experimental.big-query-initial-hash-partitions"), #raw("experimental.max-concurrent-big-queries") and #raw("experimental.max-queued-big-queries").
