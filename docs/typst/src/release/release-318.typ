#import "/lib/trino-docs.typ": *

#anchor("doc-release-release-318")
= Release 318 \(26 Aug 2019\)

== General

- Fix query failure when using #raw("DISTINCT FROM") with the #raw("UUID") or #raw("IPADDRESS") types. \(#issue("1180", "https://github.com/trinodb/trino/issues/1180")\)
- Improve query performance when #raw("optimize_hash_generation") is enabled. \(#issue("1071", "https://github.com/trinodb/trino/issues/1071")\)
- Improve performance of information schema tables. \(#issue("999", "https://github.com/trinodb/trino/issues/999"), #issue("1306", "https://github.com/trinodb/trino/issues/1306")\)
- Rename #raw("http.server.authentication.*") configuration options to #raw("http-server.authentication.*"). \(#issue("1270", "https://github.com/trinodb/trino/issues/1270")\)
- Change query CPU tracking for resource groups to update periodically while the query is running. Previously, CPU usage would only update at query completion. This improves resource management fairness when using CPU-limited resource groups. \(#issue("1128", "https://github.com/trinodb/trino/issues/1128")\)
- Remove #raw("distributed_planning_time_ms") column from #raw("system.runtime.queries"). \(#issue("1084", "https://github.com/trinodb/trino/issues/1084")\)
- Add support for #raw("Asia/Qostanay") time zone. \(#issue("1221", "https://github.com/trinodb/trino/issues/1221")\)
- Add session properties that allow overriding the query per-node memory limits: #raw("query_max_memory_per_node") and #raw("query_max_total_memory_per_node"). These properties can be used to decrease limits for a query, but not to increase them. \(#issue("1212", "https://github.com/trinodb/trino/issues/1212")\)
- Add #link(label("doc-connector-googlesheets"))[Google Sheets connector]. \(#issue("1030", "https://github.com/trinodb/trino/issues/1030")\)
- Add #raw("planning_time_ms") column to the #raw("system.runtime.queries") table that shows the time spent on query planning. This is the same value that used to be in the #raw("analysis_time_ms") column, which was a misnomer. \(#issue("1084", "https://github.com/trinodb/trino/issues/1084")\)
- Add #link(label("fn-last-day-of-month"), raw("last_day_of_month")) function. \(#issue("1295", "https://github.com/trinodb/trino/issues/1295")\)
- Add support for cancelling queries via the #raw("system.runtime.kill_query") procedure when they are in the queue or in the semantic analysis stage. \(#issue("1079", "https://github.com/trinodb/trino/issues/1079")\)
- Add queries that are in the queue or in the semantic analysis stage to the #raw("system.runtime.queries") table. \(#issue("1079", "https://github.com/trinodb/trino/issues/1079")\)

== Web UI

- Display information about queries that are in the queue or in the semantic analysis stage. \(#issue("1079", "https://github.com/trinodb/trino/issues/1079")\)
- Add support for cancelling queries that are in the queue or in the semantic analysis stage. \(#issue("1079", "https://github.com/trinodb/trino/issues/1079")\)

== Hive connector

- Fix query failure due to missing credentials while writing empty bucket files. \(#issue("1298", "https://github.com/trinodb/trino/issues/1298")\)
- Fix bucketing of #raw("NaN") values of #raw("real") type. Previously #raw("NaN") values could be assigned a wrong bucket. \(#issue("1336", "https://github.com/trinodb/trino/issues/1336")\)
- Fix reading #raw("RCFile") collection delimiter set by Hive version earlier than 3.0. \(#issue("1321", "https://github.com/trinodb/trino/issues/1321")\)
- Return proper error when selecting #raw("\"$bucket\"") column from a table using Hive bucketing v2. \(#issue("1336", "https://github.com/trinodb/trino/issues/1336")\)
- Improve performance of S3 object listing. \(#issue("1232", "https://github.com/trinodb/trino/issues/1232")\)
- Improve performance when reading data from GCS. \(#issue("1200", "https://github.com/trinodb/trino/issues/1200")\)
- Add support for reading data from S3 Requester Pays buckets. This can be enabled using the #raw("hive.s3.requester-pays.enabled") configuration property. \(#issue("1241", "https://github.com/trinodb/trino/issues/1241")\)
- Allow inserting into bucketed, unpartitioned tables. \(#issue("1127", "https://github.com/trinodb/trino/issues/1127")\)
- Allow inserting into existing partitions of bucketed, partitioned tables. \(#issue("1347", "https://github.com/trinodb/trino/issues/1347")\)

== PostgreSQL connector

- Add support for providing JDBC credential in a separate file. This can be enabled by setting the #raw("credential-provider.type=FILE") and #raw("connection-credential-file") config options in the catalog properties file. \(#issue("1124", "https://github.com/trinodb/trino/issues/1124")\)
- Allow logging all calls to #raw("JdbcClient"). This can be enabled by turning on #raw("DEBUG") logging for #raw("io.prestosql.plugin.jdbc.JdbcClient"). \(#issue("1274", "https://github.com/trinodb/trino/issues/1274")\)
- Add possibility to force mapping of certain types to #raw("varchar"). This can be enabled by setting #raw("jdbc-types-mapped-to-varchar") to comma-separated list of type names. \(#issue("186", "https://github.com/trinodb/trino/issues/186")\)
- Add support for PostgreSQL #raw("timestamp[]") type. \(#issue("1023", "https://github.com/trinodb/trino/issues/1023"), #issue("1262", "https://github.com/trinodb/trino/issues/1262"), #issue("1328", "https://github.com/trinodb/trino/issues/1328")\)

== MySQL connector

- Add support for providing JDBC credential in a separate file. This can be enabled by setting the #raw("credential-provider.type=FILE") and #raw("connection-credential-file") config options in the catalog properties file. \(#issue("1124", "https://github.com/trinodb/trino/issues/1124")\)
- Allow logging all calls to #raw("JdbcClient"). This can be enabled by turning on #raw("DEBUG") logging for #raw("io.prestosql.plugin.jdbc.JdbcClient"). \(#issue("1274", "https://github.com/trinodb/trino/issues/1274")\)
- Add possibility to force mapping of certain types to #raw("varchar"). This can be enabled by setting #raw("jdbc-types-mapped-to-varchar") to comma-separated list of type names. \(#issue("186", "https://github.com/trinodb/trino/issues/186")\)

== Redshift connector

- Add support for providing JDBC credential in a separate file. This can be enabled by setting the #raw("credential-provider.type=FILE") and #raw("connection-credential-file") config options in the catalog properties file. \(#issue("1124", "https://github.com/trinodb/trino/issues/1124")\)
- Allow logging all calls to #raw("JdbcClient"). This can be enabled by turning on #raw("DEBUG") logging for #raw("io.prestosql.plugin.jdbc.JdbcClient"). \(#issue("1274", "https://github.com/trinodb/trino/issues/1274")\)
- Add possibility to force mapping of certain types to #raw("varchar"). This can be enabled by setting #raw("jdbc-types-mapped-to-varchar") to comma-separated list of type names. \(#issue("186", "https://github.com/trinodb/trino/issues/186")\)

== SQL Server connector

- Add support for providing JDBC credential in a separate file. This can be enabled by setting the #raw("credential-provider.type=FILE") and #raw("connection-credential-file") config options in the catalog properties file. \(#issue("1124", "https://github.com/trinodb/trino/issues/1124")\)
- Allow logging all calls to #raw("JdbcClient"). This can be enabled by turning on #raw("DEBUG") logging for #raw("io.prestosql.plugin.jdbc.JdbcClient"). \(#issue("1274", "https://github.com/trinodb/trino/issues/1274")\)
- Add possibility to force mapping of certain types to #raw("varchar"). This can be enabled by setting #raw("jdbc-types-mapped-to-varchar") to comma-separated list of type names. \(#issue("186", "https://github.com/trinodb/trino/issues/186")\)

== SPI

- Add #raw("Block.isLoaded()") method. \(#issue("1216", "https://github.com/trinodb/trino/issues/1216")\)
- Update security APIs to accept the new #raw("ConnectorSecurityContext") and #raw("SystemSecurityContext") classes. \(#issue("171", "https://github.com/trinodb/trino/issues/171")\)
- Allow connectors to override minimal schedule split batch size. \(#issue("1251", "https://github.com/trinodb/trino/issues/1251")\)
