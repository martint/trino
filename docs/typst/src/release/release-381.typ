#import "/lib/trino-docs.typ": *

#anchor("doc-release-release-381")
= Release 381 \(16 May 2022\)

== General

- Add support for fault-tolerant execution with exchange spooling on Azure Blob Storage. \(#issue("12211", "https://github.com/trinodb/trino/issues/12211")\)
- Add experimental support for #link(label("doc-functions-table"))[Table functions]. \(#issue("1839", "https://github.com/trinodb/trino/issues/1839")\)
- Increase the default number of stages allowed for a query from 100 to 150, specified with #raw("query.max-stage-count"). \(#issue("12292", "https://github.com/trinodb/trino/issues/12292")\)
- Allow configuring the number of partitions for distributed joins and aggregations when task-based fault-tolerant execution is enabled. This can be set with the #raw("fault-tolerant-execution-partition-count") configuration property or the #raw("fault_tolerant_execution_partition_count") session property. \(#issue("12263", "https://github.com/trinodb/trino/issues/12263")\)
- Introduce the #raw("least-waste") low memory task killer policy. This policy avoids killing tasks that are already executing for a long time, so the amount of wasted work is minimized. It can be enabled with the #raw("task.low-memory-killer.policy") configuration property. \(#issue("12393", "https://github.com/trinodb/trino/issues/12393")\)
- Fix potential planning failure of queries with multiple subqueries. \(#issue("12199", "https://github.com/trinodb/trino/issues/12199")\)

== Security

- Add support for automatic discovery of OpenID Connect metadata with OAuth 2.0 authentication. \(#issue("9788", "https://github.com/trinodb/trino/issues/9788")\)
- Re-introduce #raw("ldap.ssl-trust-certificate") as legacy configuration to avoid failures when updating Trino version. \(#issue("12187", "https://github.com/trinodb/trino/issues/12187")\)
- Fix potential query failure when a table has multiple column masks defined. \(#issue("12262", "https://github.com/trinodb/trino/issues/12262")\)
- Fix incorrect masking of columns when multiple rules in file-based system and connector access controls match. \(#issue("12203", "https://github.com/trinodb/trino/issues/12203")\)
- Fix authentication failure when using the LDAP password authenticator with ActiveDirectory. \(#issue("12321", "https://github.com/trinodb/trino/issues/12321")\)

== Web UI

- Ensure consistent sort order in the list of workers. \(#issue("12290", "https://github.com/trinodb/trino/issues/12290")\)

== Docker image

- Improve Advanced Encryption Standard \(AES\) processing performance on ARM64 processors. This is used for operations such as accessing object storage systems via TLS\/SSL. \(#issue("12251", "https://github.com/trinodb/trino/issues/12251")\)

== CLI

- Add automatic suggestions from command history. This can be disabled with the #raw("--disable-auto-suggestion") option. \(#issue("11671", "https://github.com/trinodb/trino/issues/11671")\)

== BigQuery connector

- Support reading materialized views. \(#issue("12352", "https://github.com/trinodb/trino/issues/12352")\)
- Allow skipping view materialization via #raw("bigquery.skip-view-materialization") configuration property. \(#issue("12210", "https://github.com/trinodb/trino/issues/12210")\)
- Support reading snapshot tables. \(#issue("12380", "https://github.com/trinodb/trino/issues/12380")\)

== ClickHouse connector

- Add support for #link(label("doc-sql-comment"))[#raw("COMMENT ON TABLE")]. \(#issue("11216", "https://github.com/trinodb/trino/issues/11216")\)
- Prevent data loss when non-transactional insert fails. \(#issue("12229", "https://github.com/trinodb/trino/issues/12229")\)

== Druid connector

- Prevent data loss when non-transactional insert fails. \(#issue("12229", "https://github.com/trinodb/trino/issues/12229")\)

== Elasticsearch connector

- Improve query performance by simplifying filters sent to Elasticsearch. \(#issue("10717", "https://github.com/trinodb/trino/issues/10717")\)
- Fix failure when reading nested timestamp values that are not ISO 8601 formatted. \(#issue("12250", "https://github.com/trinodb/trino/issues/12250")\)

== Hive connector

- Fix query failure when the table and partition bucket counts do not match. \(#issue("11885", "https://github.com/trinodb/trino/issues/11885")\)

== Iceberg connector

- Add support for #link(label("doc-sql-update"))[UPDATE]. \(#issue("12026", "https://github.com/trinodb/trino/issues/12026")\)
- Fix potential query failure or incorrect results when reading data from an Iceberg table that contains #link("https://iceberg.apache.org/spec/#equality-delete-files")[equality delete files]. \(#issue("12026", "https://github.com/trinodb/trino/issues/12026")\)

== MariaDB connector

- Prevent data loss when non-transactional insert fails. \(#issue("12229", "https://github.com/trinodb/trino/issues/12229")\)

== MySQL connector

- Prevent data loss when non-transactional insert fails. \(#issue("12229", "https://github.com/trinodb/trino/issues/12229")\)

== Oracle connector

- Prevent data loss when non-transactional insert fails. \(#issue("12229", "https://github.com/trinodb/trino/issues/12229")\)

== PostgreSQL connector

- Prevent data loss when non-transactional insert fails. \(#issue("12225", "https://github.com/trinodb/trino/issues/12225")\)

== Redis connector

- Allow specifying the refresh interval for fetching the table description with the #raw("redis.table-description-cache-ttl") configuration property. \(#issue("12240", "https://github.com/trinodb/trino/issues/12240")\)
- Support setting username for the connection with the #raw("redis.user") configuration property. \(#issue("12279", "https://github.com/trinodb/trino/issues/12279")\)

== Redshift connector

- Prevent data loss when non-transactional insert fails. \(#issue("12229", "https://github.com/trinodb/trino/issues/12229")\)

== SingleStore \(MemSQL\) connector

- Prevent data loss when non-transactional insert fails. \(#issue("12229", "https://github.com/trinodb/trino/issues/12229")\)

== SQL Server connector

- Prevent data loss when non-transactional insert fails. \(#issue("12229", "https://github.com/trinodb/trino/issues/12229")\)

== SPI

- Remove deprecated #raw("ConnectorMetadata") methods without the retry mode parameter. \(#issue("12342", "https://github.com/trinodb/trino/issues/12342")\)
