#import "/lib/trino-docs.typ": *

#anchor("doc-release-release-0-81")
= Release 0.81

== Hive

- Fix ORC predicate pushdown.
- Fix column selection in RCFile.

== General

- Fix handling of null and out-of-range offsets for #link(label("fn-lead"), raw("lead")), #link(label("fn-lag"), raw("lag")) and #link(label("fn-nth-value"), raw("nth_value")) functions.
