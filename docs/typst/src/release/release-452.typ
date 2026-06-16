#import "/lib/trino-docs.typ": *

#anchor("doc-release-release-452")
= Release 452 \(11 Jul 2024\)

== General

- Add #link(label("doc-connector-exasol"))[Exasol connector]. \(#issue("16083", "https://github.com/trinodb/trino/issues/16083")\)
- Add support for processing the #raw("X-Forwarded-Prefix") header when the #raw("http-server.process-forwarded") property is enabled. \(#issue("22227", "https://github.com/trinodb/trino/issues/22227")\)
- Add support for the #link(label("fn-euclidean-distance"), raw("euclidean_distance")), #link(label("fn-dot-product"), raw("dot_product")), and #link(label("fn-cosine-distance"), raw("cosine_distance")) functions. \(#issue("22397", "https://github.com/trinodb/trino/issues/22397")\)
- Improve performance of queries with selective joins by performing fine-grained filtering of rows using dynamic filters. This behavior is enabled by default and can be disabled using the #raw("enable-dynamic-row-filtering") configuration property or the #raw("enable_dynamic_row_filtering") session property. \(#issue("22411", "https://github.com/trinodb/trino/issues/22411")\)
- Fix sporadic query failure when the #raw("retry_policy") property is set to #raw("TASK"). \(#issue("22617", "https://github.com/trinodb/trino/issues/22617")\)

== Web UI

- Fix query plans occasionally not rendering the stage details page. \(#issue("22542", "https://github.com/trinodb/trino/issues/22542")\)

== BigQuery connector

- Add support for using the #link("https://cloud.google.com/bigquery/docs/reference/storage")[BigQuery Storage Read API] when using the #link(label("ref-bigquery-query-function"))[#raw("query") table function]. \(#issue("22432", "https://github.com/trinodb/trino/issues/22432")\)

== Black Hole connector

- Add support for adding, dropping and renaming columns. \(#issue("22620", "https://github.com/trinodb/trino/issues/22620")\)

== ClickHouse connector

- Add #link(label("ref-clickhouse-query-function"))[#raw("query") table function] for full query pass-through to ClickHouse. \(#issue("16182", "https://github.com/trinodb/trino/issues/16182")\)

== Delta Lake connector

- Add support for type coercion when adding new columns. \(#issue("19708", "https://github.com/trinodb/trino/issues/19708")\)
- Improve performance of reading from Parquet files with large schemas. \(#issue("22434", "https://github.com/trinodb/trino/issues/22434")\)
- Fix incorrect results when reading #raw("INT32") values in Parquet files as #raw("varchar") or #raw("decimal") types in Trino. \(#issue("21556", "https://github.com/trinodb/trino/issues/21556")\)
- Fix a performance regression when using the native filesystem for Azure. \(#issue("22561", "https://github.com/trinodb/trino/issues/22561")\)

== Hive connector

- Add support for changing column types for structural data types for non-partitioned tables using ORC files. \(#issue("22326", "https://github.com/trinodb/trino/issues/22326")\)
- Add support for type coercion when adding new columns. \(#issue("19708", "https://github.com/trinodb/trino/issues/19708")\)
- Add support for changing a column's type from #raw("varbinary") to #raw("varchar"). \(#issue("22322", "https://github.com/trinodb/trino/issues/22322")\)
- Improve performance of reading from Parquet files with large schemas. \(#issue("22434", "https://github.com/trinodb/trino/issues/22434")\)
- Fix incorrect results when reading #raw("INT32") values in Parquet files as #raw("varchar") or #raw("decimal") types in Trino. \(#issue("21556", "https://github.com/trinodb/trino/issues/21556")\)
- Fix #raw("sync_partition_metadata") ignoring case-sensitive variations of partition names in storage. \(#issue("22484", "https://github.com/trinodb/trino/issues/22484")\)
- Fix a performance regression when using the native filesystem for Azure. \(#issue("22561", "https://github.com/trinodb/trino/issues/22561")\)

== Hudi connector

- Improve performance of reading from Parquet files with large schemas. \(#issue("22434", "https://github.com/trinodb/trino/issues/22434")\)
- Fix incorrect results when reading #raw("INT32") values in Parquet files as #raw("varchar") or #raw("decimal") types in Trino. \(#issue("21556", "https://github.com/trinodb/trino/issues/21556")\)
- Fix a performance regression when using the native filesystem for Azure. \(#issue("22561", "https://github.com/trinodb/trino/issues/22561")\)

== Iceberg connector

- Add support for type coercion when adding new columns. \(#issue("19708", "https://github.com/trinodb/trino/issues/19708")\)
- Improve performance of reading from Parquet files with a large number of columns. \(#issue("22434", "https://github.com/trinodb/trino/issues/22434")\)
- Fix files being deleted when dropping tables with the Nessie catalog. \(#issue("22392", "https://github.com/trinodb/trino/issues/22392")\)
- Fix incorrect results when reading #raw("INT32") values in Parquet files as #raw("varchar") or #raw("decimal") types in Trino. \(#issue("21556", "https://github.com/trinodb/trino/issues/21556")\)
- Fix failure when hidden partition names conflict with other columns. \(#issue("22351", "https://github.com/trinodb/trino/issues/22351")\)
- Fix failure when reading tables with #raw("null") on partition columns while the #raw("optimize_metadata_queries") session property is enabled. \(#issue("21844", "https://github.com/trinodb/trino/issues/21844")\)
- Fix failure when listing views with an unsupported dialect in the REST catalog. \(#issue("22598", "https://github.com/trinodb/trino/issues/22598")\)
- Fix a performance regression when using the native filesystem for Azure. \(#issue("22561", "https://github.com/trinodb/trino/issues/22561")\)

== Kudu connector

- Fix failure when adding new columns with a #raw("decimal") type. \(#issue("22558", "https://github.com/trinodb/trino/issues/22558")\)

== Memory connector

- Add support for adding new columns. \(#issue("22610", "https://github.com/trinodb/trino/issues/22610")\)
- Add support for renaming columns. \(#issue("22607", "https://github.com/trinodb/trino/issues/22607")\)
- Add support for the #raw("NOT NULL") constraint. \(#issue("22601", "https://github.com/trinodb/trino/issues/22601")\)

== PostgreSQL connector

- Improve performance of the #link(label("fn-reverse"), raw("reverse")) function by pushing down execution to the underlying database. \(#issue("22203", "https://github.com/trinodb/trino/issues/22203")\)
