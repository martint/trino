#import "/lib/trino-docs.typ": *

#anchor("doc-release-release-441")
= Release 441 \(13 Mar 2024\)

== General

- Fix incorrect results of window aggregations when any input data includes #raw("NaN") or infinity. \(#issue("20946", "https://github.com/trinodb/trino/issues/20946")\)
- Fix #raw("NoSuchMethodError") in filtered aggregations. \(#issue("21002", "https://github.com/trinodb/trino/issues/21002")\)

== Cassandra connector

- Fix incorrect results when a query contains predicates on clustering columns. \(#issue("20963", "https://github.com/trinodb/trino/issues/20963")\)

== Hive connector

- #breaking-marker("../release.html#breaking-changes") Remove the default #raw("legacy") mode for the #raw("hive.security") configuration property, and change the default value to #raw("allow-all"). Additionally, remove the legacy properties #raw("hive.allow-drop-table"), #raw("hive.allow-rename-table"), #raw("hive.allow-add-column"), #raw("hive.allow-drop-column"), #raw("hive.allow-rename-column"), #raw("hive.allow-comment-table"), and #raw("hive.allow-comment-column"). \(#issue("21013", "https://github.com/trinodb/trino/issues/21013")\)
- Fix query failure when reading array types from Parquet files produced by some legacy writers. \(#issue("20943", "https://github.com/trinodb/trino/issues/20943")\)

== Hudi connector

- Disallow creating files on non-existent partitions. \(#issue("20133", "https://github.com/trinodb/trino/issues/20133")\)
