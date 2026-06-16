#import "/lib/trino-docs.typ": *

#anchor("doc-release-release-0-153")
= Release 0.153

== General

- Fix incorrect results for grouping sets when #raw("task.concurrency") is greater than one.
- Fix silent numeric overflow when casting #raw("INTEGER") to large #raw("DECIMAL") types.
- Fix issue where #raw("GROUP BY ()") would produce no results if the input had no rows.
- Fix null handling in #link(label("fn-array-distinct"), raw("array_distinct")) when applied to the #raw("array(bigint)") type.
- Fix handling of #raw("-2^63") as the element index for #link(label("fn-json-array-get"), raw("json_array_get")).
- Fix correctness issue when the input to #raw("TRY_CAST") evaluates to null. For types such as booleans, numbers, dates, timestamps, etc., rather than returning null, a default value specific to the type such as #raw("false"), #raw("0") or #raw("1970-01-01") was returned.
- Fix potential thread deadlock in coordinator.
- Fix rare correctness issue with an aggregation on a single threaded right join when #raw("task.concurrency") is #raw("1").
- Fix query failure when casting a map with null values.
- Fix failure when view column names contain upper-case letters.
- Fix potential performance regression due to skew issue when grouping or joining on columns of the following types: #raw("TINYINT"), #raw("SMALLINT"), #raw("INTEGER"), #raw("BIGINT"), #raw("REAL"), #raw("DOUBLE"), #raw("COLOR"), #raw("DATE"), #raw("INTERVAL"), #raw("TIME"), #raw("TIMESTAMP").
- Fix potential memory leak for delete queries.
- Fix query stats to not include queued time in planning time.
- Fix query completion event to log final stats for the query.
- Fix spurious log messages when queries are torn down.
- Remove broken #raw("%w") specifier for #link(label("fn-date-format"), raw("date_format")) and #raw("date_parse").
- Improve performance of #link(label("ref-array-type"))[array-type] when underlying data is dictionary encoded.
- Improve performance of outer joins with non-equality criteria.
- Require task concurrency and task writer count to be a power of two.
- Use nulls-last ordering for #link(label("fn-array-sort"), raw("array_sort")).
- Validate that #raw("TRY") is used with exactly one argument.
- Allow running Presto with early-access Java versions.
- Add Accumulo connector.

== Functions and language features

- Allow subqueries in non-equality outer join criteria.
- Add support for #link(label("doc-sql-create-schema"))[CREATE SCHEMA], #link(label("doc-sql-drop-schema"))[DROP SCHEMA] and #link(label("doc-sql-alter-schema"))[ALTER SCHEMA].
- Add initial support for correlated subqueries.
- Add execution support for prepared statements.
- Add #raw("DOUBLE PRECISION") as an alias for the #raw("DOUBLE") type.
- Add #link(label("fn-typeof"), raw("typeof")) for discovering expression types.
- Add decimal support to #link(label("fn-avg"), raw("avg")), #link(label("fn-ceil"), raw("ceil")), #link(label("fn-floor"), raw("floor")), #link(label("fn-round"), raw("round")), #link(label("fn-truncate"), raw("truncate")), #link(label("fn-abs"), raw("abs")), #link(label("fn-mod"), raw("mod")) and #link(label("fn-sign"), raw("sign")).
- Add #link(label("fn-shuffle"), raw("shuffle")) function for arrays.

== Pluggable resource groups

Resource group management is now pluggable. A #raw("Plugin") can provide management factories via #raw("getResourceGroupConfigurationManagerFactories()") and the factory can be enabled via the #raw("etc/resource-groups.properties") configuration file by setting the #raw("resource-groups.configuration-manager") property. See the #raw("presto-resource-group-managers") plugin for an example and #link(label("doc-admin-resource-groups"))[Resource groups] for more details.

== Web UI

- Fix rendering failures due to null nested data structures.
- Do not include coordinator in active worker count on cluster overview page.
- Replace buffer skew indicators on query details page with scheduled time skew.
- Add stage total buffer, pending tasks and wall time to stage statistics on query details page.
- Add option to filter task lists by status on query details page.
- Add copy button for query text, query ID, and user to query details page.

== JDBC driver

- Add support for #raw("real") data type, which corresponds to the Java #raw("float") type.

== CLI

- Add support for configuring the HTTPS Truststore.

== Hive

- Fix permissions for new tables when using SQL-standard authorization.
- Improve performance of ORC reader when decoding dictionary encoded #link(label("ref-map-type"))[map-type].
- Allow certain combinations of queries to be executed in a transaction-ish manner, for example, when dropping a partition and then recreating it. Atomicity is not guaranteed due to fundamental limitations in the design of Hive.
- Support per-transaction cache for Hive metastore.
- Fail queries that attempt to rename partition columns.
- Add support for ORC bloom filters in predicate push down. This is can be enabled using the #raw("hive.orc.bloom-filters.enabled") configuration property or the #raw("orc_bloom_filters_enabled") session property.
- Add new optimized RCFile reader. This can be enabled using the #raw("hive.rcfile-optimized-reader.enabled") configuration property or the #raw("rcfile_optimized_reader_enabled") session property.
- Add support for the Presto #raw("real") type, which corresponds to the Hive #raw("float") type.
- Add support for #raw("char(x)") type.
- Add support for creating, dropping and renaming schemas \(databases\). The filesystem location can be specified when creating a schema, which allows, for example, easily creating tables on S3.
- Record Presto query ID for tables or partitions written by Presto using the #raw("trino_query_id") table or partition property.
- Include path name in error message when listing a directory fails.
- Rename #raw("allow-all") authorization method to #raw("legacy"). This method is deprecated and will be removed in a future release.
- Do not retry S3 requests that are aborted intentionally.
- Set the user agent suffix for S3 requests to #raw("presto").
- Allow configuring the user agent prefix for S3 requests using the #raw("hive.s3.user-agent-prefix") configuration property.
- Add support for S3-compatible storage using the #raw("hive.s3.endpoint") and #raw("hive.s3.signer-type") configuration properties.
- Add support for using AWS KMS with S3 as an encryption materials provider using the #raw("hive.s3.kms-key-id") configuration property.
- Allow configuring a custom S3 encryption materials provider using the #raw("hive.s3.encryption-materials-provider") configuration property.

== JMX

- Make name configuration for history tables case-insensitive.

== MySQL

- Optimize fetching column names when describing a single table.
- Add support for #raw("char(x)") and #raw("real") data types.

== PostgreSQL

- Optimize fetching column names when describing a single table.
- Add support for #raw("char(x)") and #raw("real") data types.
- Add support for querying materialized views.

== Blackhole

- Add #raw("page_processing_delay") table property.

== SPI

- Add #raw("schemaExists()") method to #raw("ConnectorMetadata").
- Add transaction to grant\/revoke in #raw("ConnectorAccessControl").
- Add #raw("isCoordinator()") and #raw("getVersion()") methods to #raw("Node").
- Remove #raw("setOptionalConfig()") method from #raw("Plugin").
- Remove #raw("ServerInfo") class.
- Make #raw("NodeManager") specific to a connector instance.
- Replace #raw("ConnectorFactoryContext") with #raw("ConnectorContext").
- Use #raw("@SqlNullable") for functions instead of #raw("@Nullable").
- Prevent plugins from seeing classes that are not part of the JDK \(bootstrap classes\) or the SPI.
- Update #raw("presto-maven-plugin"), which provides a Maven packaging and lifecycle for plugins, to validate that every SPI dependency is marked as #raw("provided") scope and that only SPI dependencies use #raw("provided") scope. This helps find potential dependency and class loader issues at build time rather than at runtime.

#note[
These are backwards incompatible changes with the previous SPI. If you have written a plugin, you will need to update your code before deploying this release.
]
