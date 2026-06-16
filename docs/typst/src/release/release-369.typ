#import "/lib/trino-docs.typ": *

#anchor("doc-release-release-369")
= Release 369 \(24 Jan 2022\)

== General

- Add support for #raw("Pacific/Kanton") time zone. \(#issue("10679", "https://github.com/trinodb/trino/issues/10679")\)
- Display #raw("Physical input read time") using most succinct time unit in #raw("EXPLAIN ANALYZE VERBOSE"). \(#issue("10576", "https://github.com/trinodb/trino/issues/10576")\)
- Fine tune request retry mechanism in HTTP event listener. \(#issue("10566", "https://github.com/trinodb/trino/issues/10566")\)
- Add support for using PostgreSQL and Oracle as backend database for resource groups. \(#issue("9812", "https://github.com/trinodb/trino/issues/9812")\)
- Remove unnecessary spilling configuration properties #raw("spill-order-by") and #raw("spill-window-operator"). \(#issue("10591", "https://github.com/trinodb/trino/issues/10591")\)
- Remove distinction between system and user memory to simplify cluster configuration. The configuration property #raw("query.max-total-memory-per-node") is removed. Use #raw("query.max-memory-per-node") instead. \(#issue("10574", "https://github.com/trinodb/trino/issues/10574")\)
- Use formatting specified in the SQL standard when casting #raw("double") and #raw("real") values to #raw("varchar") type. \(#issue("552", "https://github.com/trinodb/trino/issues/552")\)
- Add support for #raw("ALTER MATERIALIZED VIEW ... SET PROPERTIES"). \(#issue("9613", "https://github.com/trinodb/trino/issues/9613")\)
- Add experimental implementation of task level retries. This can be enabled by setting the #raw("retry-policy") configuration property or the #raw("retry_policy") session property to #raw("task"). \(#issue("9818", "https://github.com/trinodb/trino/issues/9818")\)
- Improve query wall time by splitting workload between nodes in a more balanced way. Previous workload balancing policy can be restored via #raw("node-scheduler.splits-balancing-policy=node"). \(#issue("10660", "https://github.com/trinodb/trino/issues/10660")\)
- Prevent hanging query execution on failures with #raw("phased") execution policy. \(#issue("10656", "https://github.com/trinodb/trino/issues/10656")\)
- Catch overflow in decimal multiplication. \(#issue("10732", "https://github.com/trinodb/trino/issues/10732")\)
- Fix #raw("UnsupportedOperationException") in #raw("max_by") and #raw("min_by") aggregation. \(#issue("10599", "https://github.com/trinodb/trino/issues/10599")\)
- Fix incorrect results or failure when casting date to #raw("varchar(n)") type. \(#issue("552", "https://github.com/trinodb/trino/issues/552")\)
- Fix issue where the length of log file names grow indefinitely upon log rotation. \(#issue("10738", "https://github.com/trinodb/trino/issues/10738")\)

== Security

- Allow extracting groups from OAuth2 claims from #raw("http-server.authentication.oauth2.groups-field"). \(#issue("10262", "https://github.com/trinodb/trino/issues/10262")\)

== JDBC driver

- Fix memory leak when using #raw("DatabaseMetaData"). \(#issue("10584", "https://github.com/trinodb/trino/issues/10584"), #issue("10632", "https://github.com/trinodb/trino/issues/10632")\)

== BigQuery connector

- Remove #raw("bigquery.case-insensitive-name-matching.cache-ttl") configuration option. It was previously ignored. \(#issue("10697", "https://github.com/trinodb/trino/issues/10697")\)
- Fix query failure when reading columns with #raw("numeric") or #raw("bignumeric") type. \(#issue("10564", "https://github.com/trinodb/trino/issues/10564")\)

== ClickHouse connector

- Upgrade minimum required version to 21.3. \(#issue("10703", "https://github.com/trinodb/trino/issues/10703")\)
- Add support for #link(label("doc-sql-alter-schema"))[renaming schemas]. \(#issue("10558", "https://github.com/trinodb/trino/issues/10558")\)
- Add support for setting #link(label("doc-sql-comment"))[column comments]. \(#issue("10641", "https://github.com/trinodb/trino/issues/10641")\)
- Map ClickHouse #raw("ipv4") and #raw("ipv6") types to Trino #raw("ipaddress") type. \(#issue("7098", "https://github.com/trinodb/trino/issues/7098")\)
- Allow mapping ClickHouse #raw("fixedstring") or #raw("string") as Trino #raw("varchar") via the #raw("map_string_as_varchar") session property. \(#issue("10601", "https://github.com/trinodb/trino/issues/10601")\)
- Disable #raw("avg") pushdown on #raw("decimal") types to avoid incorrect results. \(#issue("10650", "https://github.com/trinodb/trino/issues/10650")\)
- Fix spurious errors when metadata cache is enabled. \(#issue("10544", "https://github.com/trinodb/trino/issues/10544"), #issue("10512", "https://github.com/trinodb/trino/issues/10512")\)

== Druid connector

- Fix spurious errors when metadata cache is enabled. \(#issue("10544", "https://github.com/trinodb/trino/issues/10544"), #issue("10512", "https://github.com/trinodb/trino/issues/10512")\)

== Hive connector

- Add support for writing Bloom filters in ORC files. \(#issue("3939", "https://github.com/trinodb/trino/issues/3939")\)
- Allow flushing the metadata cache for specific schemas, tables, or partitions with the #link(label("ref-hive-flush-metadata-cache"))[flush\_metadata\_cache] system procedure. \(#issue("10385", "https://github.com/trinodb/trino/issues/10385")\)
- Add support for long lived AWS Security Token Service \(STS\) credentials for authentication with Glue catalog. \(#issue("10735", "https://github.com/trinodb/trino/issues/10735")\)
- Ensure transaction locks in the Hive Metastore are released in case of query failure when querying Hive ACID tables.  \(#issue("10401", "https://github.com/trinodb/trino/issues/10401")\)
- Disallow reading from Iceberg tables when redirects from Hive to Iceberg are not enabled. \(#issue("8693", "https://github.com/trinodb/trino/issues/8693"), #issue("10441", "https://github.com/trinodb/trino/issues/10441")\)
- Improve performance of queries using range predicates when reading ORC files with Bloom filters. \(#issue("4108", "https://github.com/trinodb/trino/issues/4108")\)
- Support writing Parquet files greater than 2GB. \(#issue("10722", "https://github.com/trinodb/trino/issues/10722")\)
- Fix spurious errors when metadata cache is enabled. \(#issue("10646", "https://github.com/trinodb/trino/issues/10646"), #issue("10512", "https://github.com/trinodb/trino/issues/10512")\)
- Prevent data loss during #raw("DROP SCHEMA") when the schema location contains files that are not part of existing tables. \(#issue("10485", "https://github.com/trinodb/trino/issues/10485")\)
- Fix inserting into transactional table when #raw("task_writer_count") \> 1. \(#issue("9149", "https://github.com/trinodb/trino/issues/9149")\)
- Fix possible data corruption when writing data to S3 with streaming enabled. \(#issue("10710 ", "https://github.com/trinodb/trino/issues/10710 ")\)

== Iceberg connector

- Add #raw("$properties") system table which can be queried to inspect Iceberg table properties. \(#issue("10480", "https://github.com/trinodb/trino/issues/10480")\)
- Add support for #raw("ALTER TABLE .. EXECUTE OPTIMIZE") statement. \(#issue("10497", "https://github.com/trinodb/trino/issues/10497")\)
- Respect Iceberg column metrics mode when writing. \(#issue("9938", "https://github.com/trinodb/trino/issues/9938")\)
- Add support for long lived AWS Security Token Service \(STS\) credentials for authentication with Glue catalog. \(#issue("10735", "https://github.com/trinodb/trino/issues/10735")\)
- Improve performance of queries using range predicates when reading ORC files with Bloom filters. \(#issue("4108", "https://github.com/trinodb/trino/issues/4108")\)
- Improve select query planning performance after write operations from Trino. \(#issue("9340", "https://github.com/trinodb/trino/issues/9340")\)
- Ensure table statistics are accumulated in a deterministic way from Iceberg column metrics. \(#issue("9716", "https://github.com/trinodb/trino/issues/9716")\)
- Prevent data loss during #raw("DROP SCHEMA") when the schema location contains files that are not part of existing tables. \(#issue("10485", "https://github.com/trinodb/trino/issues/10485")\)
- Support writing Parquet files greater than 2GB. \(#issue("10722", "https://github.com/trinodb/trino/issues/10722")\)
- Fix materialized view refresh when view a query references the same table multiple times. \(#issue("10570", "https://github.com/trinodb/trino/issues/10570")\)
- Fix possible data corruption when writing data to S3 with streaming enabled. \(#issue("10710 ", "https://github.com/trinodb/trino/issues/10710 ")\)

== MySQL connector

- Fix spurious errors when metadata cache is enabled. \(#issue("10544", "https://github.com/trinodb/trino/issues/10544"), #issue("10512", "https://github.com/trinodb/trino/issues/10512")\)

== Oracle connector

- Map Oracle #raw("date") to Trino #raw("timestamp(0)") type. \(#issue("10626", "https://github.com/trinodb/trino/issues/10626")\)
- Fix performance regression of predicate pushdown on indexed #raw("date") columns. \(#issue("10626", "https://github.com/trinodb/trino/issues/10626")\)
- Fix spurious errors when metadata cache is enabled. \(#issue("10544", "https://github.com/trinodb/trino/issues/10544"), #issue("10512", "https://github.com/trinodb/trino/issues/10512")\)

== Phoenix connector

- Fix spurious errors when metadata cache is enabled. \(#issue("10544", "https://github.com/trinodb/trino/issues/10544"), #issue("10512", "https://github.com/trinodb/trino/issues/10512")\)

== Pinot connector

- Add support for basic authentication. \(#issue("9531", "https://github.com/trinodb/trino/issues/9531")\)

== PostgreSQL connector

- Add support for #link(label("doc-sql-alter-schema"))[renaming schemas]. \(#issue("8939", "https://github.com/trinodb/trino/issues/8939")\)
- Fix spurious errors when metadata cache is enabled. \(#issue("10544", "https://github.com/trinodb/trino/issues/10544"), #issue("10512", "https://github.com/trinodb/trino/issues/10512")\)

== Redshift connector

- Add support for #link(label("doc-sql-alter-schema"))[renaming schemas]. \(#issue("8939", "https://github.com/trinodb/trino/issues/8939")\)
- Fix spurious errors when metadata cache is enabled. \(#issue("10544", "https://github.com/trinodb/trino/issues/10544"), #issue("10512", "https://github.com/trinodb/trino/issues/10512")\)

== SingleStore \(MemSQL\) connector

- Fix spurious errors when metadata cache is enabled. \(#issue("10544", "https://github.com/trinodb/trino/issues/10544"), #issue("10512", "https://github.com/trinodb/trino/issues/10512")\)

== SQL Server connector

- Fix spurious errors when metadata cache is enabled. \(#issue("10544", "https://github.com/trinodb/trino/issues/10544"), #issue("10512", "https://github.com/trinodb/trino/issues/10512")\)

== SPI

- Remove support for the #raw("ConnectorMetadata.getTableLayout()") API. \(#issue("781", "https://github.com/trinodb/trino/issues/781")\)
