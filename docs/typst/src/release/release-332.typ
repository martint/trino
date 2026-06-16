#import "/lib/trino-docs.typ": *

#anchor("doc-release-release-332")
= Release 332 \(08 Apr 2020\)

== General

- Fix query failure during planning phase for certain queries involving multiple joins. \(#issue("3149", "https://github.com/trinodb/trino/issues/3149")\)
- Fix execution failure for queries involving large #raw("IN") predicates on decimal values with precision larger than 18. \(#issue("3191", "https://github.com/trinodb/trino/issues/3191")\)
- Fix prepared statements or view creation for queries containing certain nested aliases or #raw("TABLESAMPLE") clauses. \(#issue("3250", "https://github.com/trinodb/trino/issues/3250")\)
- Fix rare query failure. \(#issue("2981", "https://github.com/trinodb/trino/issues/2981")\)
- Ignore trailing whitespace when loading configuration files such as #raw("etc/event-listener.properties") or #raw("etc/group-provider.properties"). Trailing whitespace in #raw("etc/config.properties") and catalog properties files was already ignored. \(#issue("3231", "https://github.com/trinodb/trino/issues/3231")\)
- Reduce overhead for internal communication requests. \(#issue("3215", "https://github.com/trinodb/trino/issues/3215")\)
- Include filters over all table columns in output of #raw("EXPLAIN (TYPE IO)"). \(#issue("2743", "https://github.com/trinodb/trino/issues/2743")\)
- Support configuring multiple event listeners. The properties files for all the event listeners can be specified using the #raw("event-listener.config-files") configuration property. \(#issue("3128", "https://github.com/trinodb/trino/issues/3128")\)
- Add #raw("CREATE SCHEMA ... AUTHORIZATION") syntax to create a schema with specified owner. \(#issue("3066", "https://github.com/trinodb/trino/issues/3066")\).
- Add #raw("optimizer.push-partial-aggregation-through-join") configuration property to control pushing partial aggregations through inner joins. Previously, this was only available via the #raw("push_partial_aggregation_through_join") session property. \(#issue("3205", "https://github.com/trinodb/trino/issues/3205")\)
- Rename configuration property #raw("optimizer.push-aggregation-through-join") to #raw("optimizer.push-aggregation-through-outer-join"). \(#issue("3205", "https://github.com/trinodb/trino/issues/3205")\)
- Add operator statistics for the number of splits processed with a dynamic filter applied. \(#issue("3217", "https://github.com/trinodb/trino/issues/3217")\)

== Security

- Fix LDAP authentication when user belongs to multiple groups. \(#issue("3206", "https://github.com/trinodb/trino/issues/3206")\)
- Verify access to table columns when running #raw("SHOW STATS"). \(#issue("2665", "https://github.com/trinodb/trino/issues/2665")\)
- Only return views accessible to the user from #raw("information_schema.views"). \(#issue("3290", "https://github.com/trinodb/trino/issues/3290")\)

== JDBC driver

- Add #raw("clientInfo") property to set extra information about the client. \(#issue("3188", "https://github.com/trinodb/trino/issues/3188")\)
- Add #raw("traceToken") property to set a trace token for correlating requests across systems. \(#issue("3188", "https://github.com/trinodb/trino/issues/3188")\)

== BigQuery connector

- Extract parent project ID from service account before looking at the environment. \(#issue("3131", "https://github.com/trinodb/trino/issues/3131")\)

== Elasticsearch connector

- Add support for #raw("ip") type. \(#issue("3347", "https://github.com/trinodb/trino/issues/3347")\)
- Add support for #raw("keyword") fields with numeric values. \(#issue("3381", "https://github.com/trinodb/trino/issues/3381")\)
- Remove unnecessary #raw("elasticsearch.aws.use-instance-credentials") configuration property. \(#issue("3265", "https://github.com/trinodb/trino/issues/3265")\)

== Hive connector

- Fix failure reading certain Parquet files larger than 2GB. \(#issue("2730", "https://github.com/trinodb/trino/issues/2730")\)
- Improve performance when reading gzip-compressed Parquet data. \(#issue("3175", "https://github.com/trinodb/trino/issues/3175")\)
- Explicitly disallow reading from Delta Lake tables. Previously, reading from partitioned tables would return zero rows, and reading from unpartitioned tables would fail with a cryptic error. \(#issue("3366", "https://github.com/trinodb/trino/issues/3366")\)
- Add #raw("hive.fs.new-directory-permissions") configuration property for setting the permissions of new directories created by Presto. Default value is #raw("0777"), which corresponds to previous behavior. \(#issue("3126", "https://github.com/trinodb/trino/issues/3126")\)
- Add #raw("hive.partition-use-column-names") configuration property and matching #raw("partition_use_column_names") catalog session property that allows to match columns between table and partition schemas by names. By default they are mapped by index. \(#issue("2933", "https://github.com/trinodb/trino/issues/2933")\)
- Add support for #raw("CREATE SCHEMA ... AUTHORIZATION") to create a schema with specified owner. \(#issue("3066", "https://github.com/trinodb/trino/issues/3066")\).
- Allow specifying the Glue metastore endpoint URL using the #raw("hive.metastore.glue.endpoint-url") configuration property. \(#issue("3239", "https://github.com/trinodb/trino/issues/3239")\)
- Add experimental file system caching. This can be enabled with the #raw("hive.cache.enabled") configuration property. \(#issue("2679", "https://github.com/trinodb/trino/issues/2679")\)
- Support reading files compressed with newer versions of LZO. \(#issue("3209", "https://github.com/trinodb/trino/issues/3209")\)
- Add support for Alluxio Catalog Service. \(#issue("2116", "https://github.com/trinodb/trino/issues/2116")\)
- Remove unnecessary #raw("hive.metastore.glue.use-instance-credentials") configuration property. \(#issue("3265", "https://github.com/trinodb/trino/issues/3265")\)
- Remove unnecessary #raw("hive.s3.use-instance-credentials") configuration property. \(#issue("3265", "https://github.com/trinodb/trino/issues/3265")\)
- Add flexible S3 security mapping, allowing for separate credentials or IAM roles for specific users or buckets\/paths. \(#issue("3265", "https://github.com/trinodb/trino/issues/3265")\)
- Add support for specifying an External ID for an IAM role trust policy using the #raw("hive.metastore.glue.external-id") configuration property \(#issue("3144", "https://github.com/trinodb/trino/issues/3144")\)
- Allow using configured S3 credentials with IAM role. Previously, the configured IAM role was silently ignored. \(#issue("3351", "https://github.com/trinodb/trino/issues/3351")\)

== Kudu connector

- Fix incorrect column mapping in Kudu connector. \(#issue("3170", "https://github.com/trinodb/trino/issues/3170"), #issue("2963", "https://github.com/trinodb/trino/issues/2963")\)
- Fix incorrect query result for certain queries involving #raw("IS NULL") predicates with #raw("OR"). \(#issue("3274", "https://github.com/trinodb/trino/issues/3274")\)

== Memory connector

- Include views in the list of tables returned to the JDBC driver. \(#issue("3208", "https://github.com/trinodb/trino/issues/3208")\)

== MongoDB connector

- Add #raw("objectid_timestamp") for extracting the timestamp from #raw("ObjectId"). \(#issue("3089", "https://github.com/trinodb/trino/issues/3089")\)
- Delete document from #raw("_schema") collection when #raw("DROP TABLE") is executed for a table that exists only in #raw("_schema"). \(#issue("3234", "https://github.com/trinodb/trino/issues/3234")\)

== SQL Server connector

- Disallow renaming tables between schemas. Previously, such renames were allowed but the schema name was ignored when performing the rename. \(#issue("3284", "https://github.com/trinodb/trino/issues/3284")\)

== SPI

- Expose row filters and column masks in #raw("QueryCompletedEvent"). \(#issue("3183", "https://github.com/trinodb/trino/issues/3183")\)
- Expose referenced functions and procedures in #raw("QueryCompletedEvent"). \(#issue("3246", "https://github.com/trinodb/trino/issues/3246")\)
- Allow #raw("Connector") to provide #raw("EventListener") instances. \(#issue("3166", "https://github.com/trinodb/trino/issues/3166")\)
- Deprecate the #raw("ConnectorPageSourceProvider.createPageSource()") variant without the #raw("dynamicFilter") parameter. The method will be removed in a future release. \(#issue("3255", "https://github.com/trinodb/trino/issues/3255")\)
