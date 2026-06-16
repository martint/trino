#import "/lib/trino-docs.typ": *

#anchor("doc-release-release-0-98")
= Release 0.98

== Array, map, and row types

The memory representation of these types is now #raw("VariableWidthBlockEncoding") instead of #raw("JSON").

#note[
This is a backwards incompatible change with the previous representation, so if you have written a connector or function, you will need to update your code before deploying this release.
]

== Hive

- Fix handling of ORC files with corrupt checkpoints.

== SPI

- Rename #raw("Index") to #raw("ConnectorIndex").

#note[
This is a backwards incompatible change, so if you have written a connector that uses #raw("Index"), you will need to update your code before deploying this release.
]

== General

- Fix bug in #raw("UNNEST") when output is unreferenced or partially referenced.
- Make #link(label("fn-max"), raw("max")) and #link(label("fn-min"), raw("min")) functions work on all orderable types.
- Optimize memory allocation in #link(label("fn-max-by"), raw("max_by")) and other places that #raw("Block") is used.
