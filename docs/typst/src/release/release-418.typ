#import "/lib/trino-docs.typ": *

#anchor("doc-release-release-418")
= Release 418 \(17 May 2023\)

== General

- Add support for #link(label("doc-sql-execute-immediate"))[EXECUTE IMMEDIATE]. \(#issue("17341", "https://github.com/trinodb/trino/issues/17341")\)
- Fix failure when invoking #raw("current_timestamp"). \(#issue("17455", "https://github.com/trinodb/trino/issues/17455")\)

== BigQuery connector

- Add support for adding labels to BigQuery jobs started by Trino as part of query processing. The name and value of the label can be configured via the #raw("bigquery.job.label-name") and #raw("bigquery.job.label-format") catalog configuration properties, respectively. \(#issue("16187", "https://github.com/trinodb/trino/issues/16187")\)

== Delta Lake connector

- Add support for #raw("INSERT"), #raw("UPDATE"), #raw("DELETE"), and #raw("MERGE") statements for tables with an #raw("id") column mapping. \(#issue("16600", "https://github.com/trinodb/trino/issues/16600")\)
- Add the #raw("table_changes") table function. \(#issue("16205", "https://github.com/trinodb/trino/issues/16205")\)
- Improve performance of joins on partition columns. \(#issue("14493", "https://github.com/trinodb/trino/issues/14493")\)

== Hive connector

- Improve performance of querying #raw("information_schema.tables") when using the Hive metastore. \(#issue("17127", "https://github.com/trinodb/trino/issues/17127")\)
- Improve performance of joins on partition columns. \(#issue("14493", "https://github.com/trinodb/trino/issues/14493")\)
- Improve performance of writing Parquet files by enabling the optimized Parquet writer by default. \(#issue("17393", "https://github.com/trinodb/trino/issues/17393")\)
- Remove the #raw("temporary_staging_directory_enabled") and #raw("temporary_staging_directory_path") session properties. \(#issue("17390", "https://github.com/trinodb/trino/issues/17390")\)
- Fix failure when querying text files in S3 if the native reader is enabled. \(#issue("16546", "https://github.com/trinodb/trino/issues/16546")\)

== Hudi connector

- Improve performance of joins on partition columns. \(#issue("14493", "https://github.com/trinodb/trino/issues/14493")\)

== Iceberg connector

- Improve planning time for #raw("SELECT") queries. \(#issue("17347", "https://github.com/trinodb/trino/issues/17347")\)
- Improve performance of joins on partition columns. \(#issue("14493", "https://github.com/trinodb/trino/issues/14493")\)
- Fix incorrect results when querying the #raw("$history") table if the REST catalog is used. \(#issue("17470", "https://github.com/trinodb/trino/issues/17470")\)

== Kafka connector

- Fix query failure when a Kafka key or message cannot be de-serialized, and instead correctly set the #raw("_key_corrupt") and #raw("_message_corrupt") columns. \(#issue("17479", "https://github.com/trinodb/trino/issues/17479")\)

== Kinesis connector

- Fix query failure when a Kinesis message cannot be de-serialized, and instead correctly set the #raw("_message_valid") column. \(#issue("17479", "https://github.com/trinodb/trino/issues/17479")\)

== Oracle connector

- Add support for writes when #link(label("doc-admin-fault-tolerant-execution"))[fault-tolerant execution] is enabled. \(#issue("17200", "https://github.com/trinodb/trino/issues/17200")\)

== Redis connector

- Fix query failure when a Redis key or value cannot be de-serialized, and instead correctly set the #raw("_key_corrupt") and #raw("_value_corrupt") columns. \(#issue("17479", "https://github.com/trinodb/trino/issues/17479")\)
