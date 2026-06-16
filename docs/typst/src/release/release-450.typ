#import "/lib/trino-docs.typ": *

#anchor("doc-release-release-450")
= Release 450 \(19 Jun 2024\)

== General

- Add support for specifying an Azure blob endpoint for accessing spooling in fault-tolerant execution with the #raw("exchange.azure.endpoint") configuration property. \(#issue("22218", "https://github.com/trinodb/trino/issues/22218")\)
- Expose driver execution statistics via JMX. \(#issue("22427", "https://github.com/trinodb/trino/issues/22427")\)
- Improve performance of the #link(label("fn-first-value"), raw("first_value")) and #link(label("fn-last-value"), raw("last_value")) functions. \(#issue("22092", "https://github.com/trinodb/trino/issues/22092")\)
- Improve performance for large clusters under heavy workloads. \(#issue("22039", "https://github.com/trinodb/trino/issues/22039")\)
- Improve performance of queries with simple predicates. This optimization can be disabled using the #raw("experimental.columnar-filter-evaluation.enabled") configuration property or the #raw("columnar_filter_evaluation_enabled") session property. \(#issue("21375", "https://github.com/trinodb/trino/issues/21375")\)
- #breaking-marker("../release.html#breaking-changes") Improve performance of aggregations containing a #raw("DISTINCT") clause, and replace the #raw("optimizer.mark-distinct-strategy") and #raw("optimizer.optimize-mixed-distinct-aggregations") configuration properties with the new #raw("optimizer.distinct-aggregations-strategy") property. \(#issue("21907", "https://github.com/trinodb/trino/issues/21907")\)
- Improve performance of reading JSON files. \(#issue("22348", "https://github.com/trinodb/trino/issues/22348")\)
- Improve performance for the #link(label("fn-date-trunc"), raw("date_trunc")), #link(label("fn-date-add"), raw("date_add")), and #link(label("fn-date-diff"), raw("date_diff")) functions. \(#issue("22192", "https://github.com/trinodb/trino/issues/22192")\)
- Fix failure when loading the #link(label("doc-admin-event-listeners-openlineage"))[OpenLineage event listener]. \(#issue("22228", "https://github.com/trinodb/trino/issues/22228")\)
- Fix potential incorrect results when metadata or table data in certain connectors is updated or deleted. \(#issue("22285", "https://github.com/trinodb/trino/issues/22285")\)

== Security

- Add support for using web identity exclusively for authentication when running on Amazon EKS with the legacy S3 file system enabled. This can be configured via the #raw("trino.s3.use-web-identity-token-credentials-provider") property. \(#issue("22162", "https://github.com/trinodb/trino/issues/22162")\)
- Add support for exclusively using web identity for authentication when using Amazon EKS with #link("https://docs.aws.amazon.com/eks/latest/userguide/iam-roles-for-service-accounts.html")[IAM roles] by setting the #raw("s3.use-web-identity-token-credentials-provider") configuration property. \(#issue("22163", "https://github.com/trinodb/trino/issues/22163")\)

== JDBC driver

- Add support for the #raw("assumeNullCatalogMeansCurrent") connection property. When enabled, a #raw("null") value for the #raw("catalog") parameter in #raw("DatabaseMetaData") methods is assumed to mean the current catalog. If no current catalog is set, the behaviour is unmodified. \(#issue("20866", "https://github.com/trinodb/trino/issues/20866")\)

== BigQuery connector

- Add support for metadata caching when the #raw("bigquery.case-insensitive-name-matching") configuration property is enabled. \(#issue("10740", "https://github.com/trinodb/trino/issues/10740")\)
- #breaking-marker("../release.html#breaking-changes") Automatically configure BigQuery scan parallelism, and remove the #raw("bigquery.parallelism") configuration property. \(#issue("22279", "https://github.com/trinodb/trino/issues/22279")\)

== Cassandra connector

- Fix incorrect results when specifying a value for the #raw("cassandra.partition-size-for-batch-select") configuration property. \(#issue("21940", "https://github.com/trinodb/trino/issues/21940")\)

== ClickHouse connector

- Improve performance of #raw("ORDER BY ... LIMIT") on non-textual types by pushing execution down to the underlying database. \(#issue("22174", "https://github.com/trinodb/trino/issues/22174")\)

== Delta Lake connector

- Add support for concurrent #raw("UPDATE"), #raw("MERGE"), and #raw("DELETE") queries. \(#issue("21727", "https://github.com/trinodb/trino/issues/21727")\)
- Add support for using table statistics with #raw("TIMESTAMP") types. \(#issue("21878", "https://github.com/trinodb/trino/issues/21878")\)
- Add support for reading tables with #link("https://docs.delta.io/latest/delta-type-widening.html")[type widening]. \(#issue("21756", "https://github.com/trinodb/trino/issues/21756")\)
- Set the default value for the #raw("s3.max-connections") configuration property to 500. \(#issue("22209", "https://github.com/trinodb/trino/issues/22209")\)
- Fix failure when reading a #raw("TIMESTAMP") value after the year 9999. \(#issue("22184", "https://github.com/trinodb/trino/issues/22184")\)
- Fix failure when reading tables with the unsupported #raw("variant") type. \(#issue("22310", "https://github.com/trinodb/trino/issues/22310")\)
- Add support for reading #link("https://docs.delta.io/latest/delta-uniform.html")[UniForm] tables. \(#issue("22106", "https://github.com/trinodb/trino/issues/22106")\)

== Hive connector

- Add support for changing a column's type from #raw("integer") to #raw("varchar") and #raw("decimal") to #raw("varchar"), respectively, in unpartitioned tables. \(#issue("22246", "https://github.com/trinodb/trino/issues/22246"), #issue("22293", "https://github.com/trinodb/trino/issues/22293")\)
- Add support for changing a column's type from #raw("double") to #raw("varchar") in unpartitioned tables using Parquet files. \(#issue("22277", "https://github.com/trinodb/trino/issues/22277")\)
- Add support for changing a column's type from #raw("float") to #raw("varchar"). \(#issue("22291", "https://github.com/trinodb/trino/issues/22291")\)
- Set the default value for the #raw("s3.max-connections") configuration property to 500. \(#issue("22209", "https://github.com/trinodb/trino/issues/22209")\)

== Hudi connector

- Set the default value for the #raw("s3.max-connections") configuration property to 500. \(#issue("22209", "https://github.com/trinodb/trino/issues/22209")\)

== Iceberg connector

- Add support for the #raw("TRUNCATE") statement. \(#issue("22340", "https://github.com/trinodb/trino/issues/22340")\)
- #breaking-marker("../release.html#breaking-changes") Add support for V2 of the Nessie REST API. Previous behavior can be restored by setting the #raw("iceberg.nessie-catalog.client-api-version") configuration property to #raw("V1"). \(#issue("22215", "https://github.com/trinodb/trino/issues/22215")\)
- Improve performance when reading by populating #raw("split_offsets") in file metadata. \(#issue("9018", "https://github.com/trinodb/trino/issues/9018")\)
- Set the default value for the #raw("s3.max-connections") configuration property to 500. \(#issue("22209", "https://github.com/trinodb/trino/issues/22209")\)
- Fix failure when reading Parquet files that don't have #raw("field-id") on structured types. \(#issue("22347", "https://github.com/trinodb/trino/issues/22347")\)

== MariaDB connector

- Add support for #link(label("doc-admin-fault-tolerant-execution"))[fault-tolerant execution]. \(#issue("22328", "https://github.com/trinodb/trino/issues/22328")\)
- Improve performance of listing table columns. \(#issue("22241", "https://github.com/trinodb/trino/issues/22241")\)

== Memory connector

- Add support for the #raw("TRUNCATE") statement. \(#issue("22337", "https://github.com/trinodb/trino/issues/22337")\)

== MySQL connector

- Improve performance of listing table columns. \(#issue("22241", "https://github.com/trinodb/trino/issues/22241")\)

== Pinot connector

- Add support for the #link("https://docs.pinot.apache.org/developers/advanced/null-value-support#advanced-null-handling-support")[#raw("enableNullHandling") query option]. \(#issue("22214", "https://github.com/trinodb/trino/issues/22214")\)
- Fix failure when using #link(label("ref-pinot-dynamic-tables"))[dynamic tables]. \(#issue("22301", "https://github.com/trinodb/trino/issues/22301")\)

== Redshift connector

- Improve performance of listing table columns. \(#issue("22241", "https://github.com/trinodb/trino/issues/22241")\)

== SingleStore connector

- Improve performance of listing table columns. \(#issue("22241", "https://github.com/trinodb/trino/issues/22241")\)
