#import "/lib/trino-docs.typ": *

#anchor("doc-release-release-0-112")
= Release 0.112

== General

- Fix incorrect handling of filters and limits in #link(label("fn-row-number"), raw("row_number")) optimizer. This caused certain query shapes to produce incorrect results.
- Fix non-string object arrays in JMX connector.

== Hive

- Tables created using #link(label("doc-sql-create-table"))[CREATE TABLE] \(not #link(label("doc-sql-create-table-as"))[CREATE TABLE AS]\) had invalid metadata and were not readable.
- Improve performance of #raw("IN") and #raw("OR") clauses when reading #raw("ORC") data. Previously, the ranges for a column were always compacted into a single range before being passed to the reader, preventing the reader from taking full advantage of row skipping. The compaction only happens now if the number of ranges exceeds the #raw("hive.domain-compaction-threshold") config property.
