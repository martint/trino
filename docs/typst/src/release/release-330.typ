#import "/lib/trino-docs.typ": *

#anchor("doc-release-release-330")
= Release 330 \(18 Feb 2020\)

== General

- Fix incorrect behavior of #link(label("fn-format"), raw("format")) for #raw("char") values. Previously, the function did not preserve trailing whitespace of the value being formatted. \(#issue("2629", "https://github.com/trinodb/trino/issues/2629")\)
- Fix query failure in some cases when aggregation uses inputs from both sides of a join. \(#issue("2560", "https://github.com/trinodb/trino/issues/2560")\)
- Fix query failure when dynamic filtering is enabled and the query contains complex multi-level joins. \(#issue("2659", "https://github.com/trinodb/trino/issues/2659")\)
- Fix query failure for certain co-located joins when dynamic filtering is enabled. \(#issue("2685", "https://github.com/trinodb/trino/issues/2685")\)
- Fix failure of #raw("SHOW") statements or queries that access #raw("information_schema") schema tables with an empty value used in a predicate. \(#issue("2575", "https://github.com/trinodb/trino/issues/2575")\)
- Fix query failure when #link(label("doc-sql-execute"))[EXECUTE] is used with an expression containing a function call. \(#issue("2675", "https://github.com/trinodb/trino/issues/2675")\)
- Fix failure in #raw("SHOW CATALOGS") when the user does not have permissions to see any catalogs. \(#issue("2593", "https://github.com/trinodb/trino/issues/2593")\)
- Improve query performance for some join queries when #link(label("doc-optimizer-cost-based-optimizations"))[Cost-based optimizations] are enabled. \(#issue("2722", "https://github.com/trinodb/trino/issues/2722")\)
- Prevent uneven distribution of data that can occur when writing data with redistribution or writer scaling enabled. \(#issue("2788", "https://github.com/trinodb/trino/issues/2788")\)
- Add support for #raw("CREATE VIEW") with comment \(#issue("2557", "https://github.com/trinodb/trino/issues/2557")\)
- Add support for all major geometry types to #link(label("fn-st-points"), raw("ST_Points")). \(#issue("2535", "https://github.com/trinodb/trino/issues/2535")\)
- Add #raw("required_workers_count") and #raw("required_workers_max_wait_time") session properties to control the number of workers that must be present in the cluster before query processing starts. \(#issue("2484", "https://github.com/trinodb/trino/issues/2484")\)
- Add #raw("physical_input_bytes") column to #raw("system.runtime.tasks") table. \(#issue("2803", "https://github.com/trinodb/trino/issues/2803")\)
- Verify that the target schema exists for the #link(label("doc-sql-use"))[USE] statement. \(#issue("2764", "https://github.com/trinodb/trino/issues/2764")\)
- Verify that the session catalog exists when executing #link(label("doc-sql-set-role"))[SET ROLE]. \(#issue("2768", "https://github.com/trinodb/trino/issues/2768")\)

== Server

- Require running on #link(label("ref-requirements-java"))[Java 11 or above]. This requirement may be temporarily relaxed by adding #raw("-Dpresto-temporarily-allow-java8=true") to the Presto #link(label("ref-jvm-config"))[jvm-config]. This fallback will be removed in future versions of Presto after March 2020. \(#issue("2751", "https://github.com/trinodb/trino/issues/2751")\)
- Add experimental support for running on Linux aarch64 \(ARM64\). \(#issue("2809", "https://github.com/trinodb/trino/issues/2809")\)

== Security

- #link(label("ref-system-file-auth-principal-rules"))[system-file-auth-principal-rules] are deprecated and will be removed in a future release. These rules have been replaced with #link(label("doc-security-user-mapping"))[User mapping], which specifies how a complex authentication user name is mapped to a simple user name for Presto, and #link(label("ref-system-file-auth-impersonation-rules"))[system-file-auth-impersonation-rules] which control the ability of a user to impersonate another user. \(#issue("2215", "https://github.com/trinodb/trino/issues/2215")\)
- A shared secret is now required when using #link(label("doc-security-internal-communication"))[Secure internal communication]. \(#issue("2202", "https://github.com/trinodb/trino/issues/2202")\)
- Kerberos for #link(label("doc-security-internal-communication"))[Secure internal communication] has been replaced with the new shared secret mechanism. The #raw("internal-communication.kerberos.enabled") and #raw("internal-communication.kerberos.use-canonical-hostname") configuration properties must be removed. \(#issue("2202", "https://github.com/trinodb/trino/issues/2202")\)
- When authentication is disabled, the Presto user may now be set using standard HTTP basic authentication with an empty password. \(#issue("2653", "https://github.com/trinodb/trino/issues/2653")\)

== Web UI

- Display physical read time in detailed query view. \(#issue("2805", "https://github.com/trinodb/trino/issues/2805")\)

== JDBC driver

- Fix a performance issue on JDK 11+ when connecting using HTTP\/2. \(#issue("2633", "https://github.com/trinodb/trino/issues/2633")\)
- Implement #raw("PreparedStatement.setTimestamp()") variant that takes a #raw("Calendar"). \(#issue("2732", "https://github.com/trinodb/trino/issues/2732")\)
- Add #raw("roles") property for catalog authorization roles. \(#issue("2780", "https://github.com/trinodb/trino/issues/2780")\)
- Add #raw("sessionProperties") property for setting system and catalog session properties. \(#issue("2780", "https://github.com/trinodb/trino/issues/2780")\)
- Add #raw("clientTags") property to set client tags for selecting resource groups. \(#issue("2468", "https://github.com/trinodb/trino/issues/2468")\)
- Allow using the #raw(":") character within an extra credential value specified via the #raw("extraCredentials") property. \(#issue("2780", "https://github.com/trinodb/trino/issues/2780")\)

== CLI

- Fix a performance issue on JDK 11+ when connecting using HTTP\/2. \(#issue("2633", "https://github.com/trinodb/trino/issues/2633")\)

== Cassandra connector

- Fix query failure when identifiers should be quoted. \(#issue("2455", "https://github.com/trinodb/trino/issues/2455")\)

== Hive connector

- Fix reading symlinks from HDFS when using Kerberos. \(#issue("2720", "https://github.com/trinodb/trino/issues/2720")\)
- Reduce Hive metastore load when updating partition statistics. \(#issue("2734", "https://github.com/trinodb/trino/issues/2734")\)
- Allow redistributing writes for un-bucketed partitioned tables on the partition keys, which results in a single writer per partition. This reduces memory usage, results in a single file per partition, and allows writing a large number of partitions \(without hitting the open writer limit\). However, writing large partitions with a single writer can take substantially longer, so this feature should only be enabled when required. To enable this feature, set the #raw("use-preferred-write-partitioning") system configuration property or the #raw("use_preferred_write_partitioning") system session property to #raw("true"). \(#issue("2358", "https://github.com/trinodb/trino/issues/2358")\)
- Remove extra file status call after writing text-based, SequenceFile, or Avro file types. \(#issue("1748", "https://github.com/trinodb/trino/issues/1748")\)
- Allow using writer scaling with all file formats. Previously, it was not supported for text-based, SequenceFile, or Avro formats. \(#issue("2657", "https://github.com/trinodb/trino/issues/2657")\)
- Add support for symlink-based tables with Avro files. \(#issue("2720", "https://github.com/trinodb/trino/issues/2720")\)
- Add support for ignoring partitions with a non-existent data directory. This can be configured using the #raw("hive.ignore-absent-partitions=true") configuration property or the #raw("ignore_absent_partitions") session property. \(#issue("2555", "https://github.com/trinodb/trino/issues/2555")\)
- Allow creation of external tables with data via #raw("CREATE TABLE AS") when both #raw("hive.non-managed-table-creates-enabled") and #raw("hive.non-managed-table-writes-enabled") are set to #raw("true"). Previously this required executing #raw("CREATE TABLE") and #raw("INSERT") as separate statement \(#issue("2669", "https://github.com/trinodb/trino/issues/2669")\)
- Add support for Azure WASB, ADLS Gen1 \(ADL\) and ADLS Gen2 \(ABFS\) file systems. \(#issue("2494", "https://github.com/trinodb/trino/issues/2494")\)
- Add experimental support for executing basic Hive views. To enable this feature, the #raw("hive.views-execution.enabled") configuration property must be set to #raw("true"). \(#issue("2715", "https://github.com/trinodb/trino/issues/2715")\)
- Add #link(label("ref-register-partition"))[register\_partition] and #link(label("ref-unregister-partition"))[unregister\_partition] procedures for adding partitions to and removing partitions from a partitioned table. \(#issue("2692", "https://github.com/trinodb/trino/issues/2692")\)
- Allow running #link(label("doc-sql-analyze"))[ANALYZE] collecting only basic table statistics. \(#issue("2762", "https://github.com/trinodb/trino/issues/2762")\)

== Elasticsearch connector

- Improve performance of queries containing a #raw("LIMIT") clause. \(#issue("2781", "https://github.com/trinodb/trino/issues/2781")\)
- Add support for #raw("nested") data type. \(#issue("754", "https://github.com/trinodb/trino/issues/754")\)

== PostgreSQL connector

- Add read support for PostgreSQL #raw("money") data type. The type is mapped to #raw("varchar") in Presto. \(#issue("2601", "https://github.com/trinodb/trino/issues/2601")\)

== Other connectors

These changes apply to the MySQL, PostgreSQL, Redshift, Phoenix and SQL Server connectors.

- Respect #raw("DEFAULT") column clause when writing to a table. \(#issue("1185", "https://github.com/trinodb/trino/issues/1185")\)

== SPI

- Allow procedures to have optional arguments with default values. \(#issue("2706", "https://github.com/trinodb/trino/issues/2706")\)
- #raw("SystemAccessControl.checkCanSetUser()") is deprecated and has been replaced with #link(label("doc-security-user-mapping"))[User mapping] and #raw("SystemAccessControl.checkCanImpersonateUser()"). \(#issue("2215", "https://github.com/trinodb/trino/issues/2215")\)
