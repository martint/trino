#import "/lib/trino-docs.typ": *

#anchor("doc-release-release-339")
= Release 339 \(21 Jul 2020\)

== General

- Add #link(label("fn-approx-most-frequent"), raw("approx_most_frequent")). \(#issue("3425", "https://github.com/trinodb/trino/issues/3425")\)
- Physical bytes scan limit for queries can be configured via #raw("query.max-scan-physical-bytes") configuration property and #raw("query_max_scan_physical_bytes") session property. \(#issue("4075", "https://github.com/trinodb/trino/issues/4075")\)
- Remove support for addition and subtraction between #raw("TIME") and #raw("INTERVAL YEAR TO MONTH") types. \(#issue("4308", "https://github.com/trinodb/trino/issues/4308")\)
- Fix planning failure when join criteria contains subqueries. \(#issue("4380", "https://github.com/trinodb/trino/issues/4380")\)
- Fix failure when subquery appear in window function arguments. \(#issue("4127", "https://github.com/trinodb/trino/issues/4127")\)
- Fix failure when subquery in #raw("WITH") clause contains hidden columns. \(#issue("4423", "https://github.com/trinodb/trino/issues/4423")\)
- Fix failure when referring to type names with different case in a #raw("GROUP BY") clause. \(#issue("2960", "https://github.com/trinodb/trino/issues/2960")\)
- Fix failure for queries involving #raw("DISTINCT") when expressions in #raw("ORDER BY") clause differ by case from expressions in #raw("SELECT") clause. \(#issue("4233", "https://github.com/trinodb/trino/issues/4233")\)
- Fix incorrect type reporting for #raw("TIMESTAMP") and #raw("TIMESTAMP WITH TIME ZONE") for legacy clients. \(#issue("4408", "https://github.com/trinodb/trino/issues/4408")\)
- Fix failure when querying nested #raw("TIMESTAMP") or #raw("TIMESTAMP WITH TIME ZONE") for legacy clients. \(#issue("4475", "https://github.com/trinodb/trino/issues/4475"), #issue("4425", "https://github.com/trinodb/trino/issues/4425")\)
- Fix failure when parsing timestamps with time zone with an offset of the form #raw("+NNNN"). \(#issue("4490", "https://github.com/trinodb/trino/issues/4490")\)

== JDBC driver

- Fix reading #raw("TIMESTAMP") and #raw("TIMESTAMP WITH TIME ZONE") values with a negative year or a year higher than 9999. \(#issue("4364", "https://github.com/trinodb/trino/issues/4364")\)
- Fix incorrect column size metadata for #raw("TIMESTAMP") and #raw("TIMESTAMP WITH TIME ZONE") types. \(#issue("4411", "https://github.com/trinodb/trino/issues/4411")\)
- Return correct value from #raw("ResultSet.getDate()"), #raw("ResultSet.getTime()") and #raw("ResultSet.getTimestamp()") methods when session zone is set to a different zone than the default zone of the JVM the JDBC is run in. The previous behavior can temporarily be restored using #raw("useSessionTimeZone") JDBC connection parameter. \(#issue("4017", "https://github.com/trinodb/trino/issues/4017")\)

== Druid connector

- Fix handling of table and column names containing non-ASCII characters. \(#issue("4312", "https://github.com/trinodb/trino/issues/4312")\)

== Hive connector

- Make #raw("location") parameter optional for the #raw("system.register_partition") procedure. \(#issue("4443", "https://github.com/trinodb/trino/issues/4443")\)
- Avoid creating tiny splits at the end of block boundaries. \(#issue("4485", "https://github.com/trinodb/trino/issues/4485")\)
- Remove requirement to configure #raw("metastore.storage.schema.reader.impl") in Hive 3.x metastore to let Presto access CSV tables. \(#issue("4457", "https://github.com/trinodb/trino/issues/4457")\)
- Fail query if there are bucket files outside of the bucket range. Previously, these extra files were skipped. \(#issue("4378", "https://github.com/trinodb/trino/issues/4378")\)
- Fix a query failure when reading from Parquet file containing #raw("real") or #raw("double") #raw("NaN") values, if the file was written by a non-conforming writer. \(#issue("4267", "https://github.com/trinodb/trino/issues/4267")\)

== Kafka connector

- Add insert support for Avro. \(#issue("4418", "https://github.com/trinodb/trino/issues/4418")\)
- Add insert support for CSV. \(#issue("4287", "https://github.com/trinodb/trino/issues/4287")\)

== Kudu connector

- Add support for grouped execution. It can be enabled with the #raw("kudu.grouped-execution.enabled") configuration property or the #raw("grouped_execution") session property. \(#issue("3715", "https://github.com/trinodb/trino/issues/3715")\)

== MongoDB connector

- Allow querying Azure Cosmos DB. \(#issue("4415", "https://github.com/trinodb/trino/issues/4415")\)

== Oracle connector

- Allow providing credentials via the #raw("connection-user") and #raw("connection-password") configuration properties. These properties were previously ignored if connection pooling was enabled. \(#issue("4430", "https://github.com/trinodb/trino/issues/4430")\)

== Phoenix connector

- Fix handling of row key definition with white space. \(#issue("3251", "https://github.com/trinodb/trino/issues/3251")\)

== SPI

- Allow connectors to wait for dynamic filters before splits are generated via the new #raw("DynamicFilter") object passed to #raw("ConnectorSplitManager.getSplits()"). \(#issue("4224", "https://github.com/trinodb/trino/issues/4224")\)
