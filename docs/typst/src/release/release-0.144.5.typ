#import "/lib/trino-docs.typ": *

#anchor("doc-release-release-0-144-5")
= Release 0.144.5

== General

- Fix window functions to correctly handle empty frames between unbounded and bounded in the same direction. For example, a frame such as #raw("ROWS BETWEEN UNBOUNDED PRECEDING AND 2 PRECEDING") would incorrectly use the first row as the window frame for the first two rows rather than using an empty frame.
- Fix correctness issue when grouping on columns that are also arguments to aggregation functions.
