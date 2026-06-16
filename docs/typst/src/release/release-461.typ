#import "/lib/trino-docs.typ": *

#anchor("doc-release-release-461")
= Release 461 \(10 Oct 2024\)

== General

- Rename the configuration property #raw("max-tasks-waiting-for-execution-per-stage") to #raw("max-tasks-waiting-for-execution-per-query") and the session property #raw("max_tasks_waiting_for_node_per_stage") to #raw("max_tasks_waiting_for_node_per_query") to match implemented semantics. \(#issue("23585", "https://github.com/trinodb/trino/issues/23585")\)
- Fix failure when joining tables with large numbers of columns. \(#issue("23720", "https://github.com/trinodb/trino/issues/23720")\)
- Fix failure for #raw("MERGE") queries on tables with large numbers of columns. \(#issue("15848", "https://github.com/trinodb/trino/issues/15848")\)

== Security

- Add support for BCrypt versions 2A, 2B, and 2X usage in password database files used with file-based authentication. \(#issue("23648", "https://github.com/trinodb/trino/issues/23648")\)

== Web UI

- Add buttons on the query list to access query details. \(#issue("22831", "https://github.com/trinodb/trino/issues/22831")\)
- Add syntax highlighting to query display on query list. \(#issue("22831", "https://github.com/trinodb/trino/issues/22831")\)

== BigQuery connector

- Fix failure when #raw("bigquery.case-insensitive-name-matching") is enabled and #raw("bigquery.case-insensitive-name-matching.cache-ttl") is #raw("0m"). \(#issue("23698", "https://github.com/trinodb/trino/issues/23698")\)

== Delta Lake connector

- Enforce access control for new tables in the #raw("register_table") procedure. \(#issue("23728", "https://github.com/trinodb/trino/issues/23728")\)

== Hive connector

- Add support for reading Hive tables that use #raw("CombineTextInputFormat"). \(#issue("21842", "https://github.com/trinodb/trino/issues/21842")\)
- Improve performance of queries with selective joins. \(#issue("23687", "https://github.com/trinodb/trino/issues/23687")\)

== Iceberg connector

- Add support for the #raw("add_files") and #raw("add_files_from_table") procedures. \(#issue("11744", "https://github.com/trinodb/trino/issues/11744")\)
- Support #raw("timestamp") type columns with the #raw("migrate") procedure. \(#issue("17006", "https://github.com/trinodb/trino/issues/17006")\)
- Enforce access control for new tables in the #raw("register_table") procedure. \(#issue("23728", "https://github.com/trinodb/trino/issues/23728")\)

== Redshift connector

- Improve performance of queries with range filters on integers. \(#issue("23417", "https://github.com/trinodb/trino/issues/23417")\)
