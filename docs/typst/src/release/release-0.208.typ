#import "/lib/trino-docs.typ": *

#anchor("doc-release-release-0-208")
= Release 0.208

#warning[
This release has the potential for data loss in the Hive connector when writing bucketed sorted tables.
]

== General

- Fix an issue with memory accounting that would lead to garbage collection pauses and out of memory exceptions.
- Fix an issue that produces incorrect results when #raw("push_aggregation_through_join") is enabled \(#issue("10724", "https://github.com/prestodb/presto/issues/10724")\).
- Preserve field names when unnesting columns of type #raw("ROW").
- Make the cluster out of memory killer more resilient to memory accounting leaks. Previously, memory accounting leaks on the workers could effectively disable the out of memory killer.
- Improve planning time for queries over tables with high column count.
- Add a limit on the number of stages in a query.  The default is #raw("100") and can be changed with the #raw("query.max-stage-count") configuration property and the #raw("query_max_stage_count") session property.
- Add #link(label("fn-spooky-hash-v2-32"), raw("spooky_hash_v2_32")) and #link(label("fn-spooky-hash-v2-64"), raw("spooky_hash_v2_64")) functions.
- Add a cluster memory leak detector that logs queries that have possibly accounted for memory usage incorrectly on workers. This is a tool to for debugging internal errors.
- Add support for correlated subqueries requiring coercions.
- Add experimental support for running on Linux ppc64le.

== CLI

- Fix creation of the history file when it does not exist.
- Add #raw("PRESTO_HISTORY_FILE") environment variable to override location of history file.

== Hive connector

- Remove size limit for writing bucketed sorted tables.
- Support writer scaling for Parquet.
- Improve stripe size estimation for the optimized ORC writer. This reduces the number of cases where tiny ORC stripes will be written.
- Provide the actual size of CHAR, VARCHAR, and VARBINARY columns to the cost based optimizer.
- Collect column level statistics when writing tables. This is disabled by default, and can be enabled by setting the #raw("hive.collect-column-statistics-on-write") property.

== Thrift connector

- Include error message from remote server in query failure message.
