#import "/lib/trino-docs.typ": *

#anchor("doc-release-release-340")
= Release 340 \(8 Aug 2020\)

== General

- Add support for query parameters in #raw("LIMIT"), #raw("OFFSET") and #raw("FETCH FIRST") clauses. \(#issue("4529", "https://github.com/trinodb/trino/issues/4529"), #issue("4601", "https://github.com/trinodb/trino/issues/4601")\)
- Add experimental support for recursive queries. \(#issue("4250", "https://github.com/trinodb/trino/issues/4250")\)
- Add #link(label("fn-bitwise-left-shift"), raw("bitwise_left_shift")), #link(label("fn-bitwise-right-shift"), raw("bitwise_right_shift")) and #link(label("fn-bitwise-right-shift-arithmetic"), raw("bitwise_right_shift_arithmetic")). \(#issue("740", "https://github.com/trinodb/trino/issues/740")\)
- Add #link(label("fn-luhn-check"), raw("luhn_check")). \(#issue("4011", "https://github.com/trinodb/trino/issues/4011")\)
- Add #raw("IF EXISTS ")and #raw("IF NOT EXISTS") syntax to #raw("ALTER TABLE"). \(#issue("4651", "https://github.com/trinodb/trino/issues/4651")\)
- Include remote host in error info for page transport errors. \(#issue("4511", "https://github.com/trinodb/trino/issues/4511")\)
- Improve minimum latency for dynamic partition pruning. \(#issue("4388", "https://github.com/trinodb/trino/issues/4388")\)
- Reduce cluster load by cancelling query stages from which data is no longer required. \(#issue("4290", "https://github.com/trinodb/trino/issues/4290")\)
- Reduce query memory usage by improving retained size estimation for #raw("VARCHAR") and #raw("CHAR") types. \(#issue("4123", "https://github.com/trinodb/trino/issues/4123")\)
- Improve query performance for queries containing #link(label("fn-starts-with"), raw("starts_with")). \(#issue("4669", "https://github.com/trinodb/trino/issues/4669")\)
- Improve performance of queries that use #raw("DECIMAL") data type. \(#issue("4730", "https://github.com/trinodb/trino/issues/4730")\)
- Fix failure when #raw("GROUP BY") clause contains duplicate expressions. \(#issue("4609", "https://github.com/trinodb/trino/issues/4609")\)
- Fix potential hang during query planning \(#issue("4635", "https://github.com/trinodb/trino/issues/4635")\).

== Security

- Fix unprivileged access to table's schema via #raw("CREATE TABLE LIKE"). \(#issue("4472", "https://github.com/trinodb/trino/issues/4472")\)

== JDBC driver

- Fix handling of dates before 1582-10-15. \(#issue("4563", "https://github.com/trinodb/trino/issues/4563")\)
- Fix handling of timestamps before 1900-01-01. \(#issue("4563", "https://github.com/trinodb/trino/issues/4563")\)

== Elasticsearch connector

- Fix failure when index mapping is missing. \(#issue("4535", "https://github.com/trinodb/trino/issues/4535")\)

== Hive connector

- Allow creating a table with #raw("external_location") when schema's location is not valid. \(#issue("4069", "https://github.com/trinodb/trino/issues/4069")\)
- Add read support for tables that were created as non-transactional and converted to be transactional later. \(#issue("2293", "https://github.com/trinodb/trino/issues/2293")\)
- Allow creation of transactional tables. Note that writing to transactional tables is not yet supported. \(#issue("4516", "https://github.com/trinodb/trino/issues/4516")\)
- Add #raw("hive.metastore.glue.max-error-retries") configuration property for the number of retries performed when accessing the Glue metastore. \(#issue("4611", "https://github.com/trinodb/trino/issues/4611")\)
- Support using Java KeyStore files for Thrift metastore TLS configuration. \(#issue("4432", "https://github.com/trinodb/trino/issues/4432")\)
- Expose hit rate statistics for Hive metastore cache via JMX. \(#issue("4458", "https://github.com/trinodb/trino/issues/4458")\)
- Improve performance when querying a table with large files and with #raw("skip.header.line.count") property set to 1. \(#issue("4513", "https://github.com/trinodb/trino/issues/4513")\)
- Improve performance of reading JSON tables. \(#issue("4705", "https://github.com/trinodb/trino/issues/4705")\)
- Fix query failure when S3 data location contains a #raw("_$folder$") marker object. \(#issue("4552", "https://github.com/trinodb/trino/issues/4552")\)
- Fix failure when referencing nested fields of a #raw("ROW") type when table and partition metadata differs. \(#issue("3967", "https://github.com/trinodb/trino/issues/3967")\)

== Kafka connector

- Add insert support for Raw data format. \(#issue("4417", "https://github.com/trinodb/trino/issues/4417")\)
- Add insert support for JSON. \(#issue("4477", "https://github.com/trinodb/trino/issues/4477")\)
- Remove unused #raw("kafka.connect-timeout") configuration properties. \(#issue("4664", "https://github.com/trinodb/trino/issues/4664")\)

== MongoDB connector

- Add #raw("mongodb.max-connection-idle-time") properties to limit the maximum idle time of a pooled connection. \(#issue("4483", "https://github.com/trinodb/trino/issues/4483")\)

== Phoenix connector

- Add table level property to specify data block encoding when creating tables. \(#issue("4617", "https://github.com/trinodb/trino/issues/4617")\)
- Fix query failure when listing schemas. \(#issue("4560", "https://github.com/trinodb/trino/issues/4560")\)

== PostgreSQL connector

- Push down #link(label("fn-count"), raw("count")) aggregations over constant expressions. For example, #raw("SELECT count(1)"). \(#issue("4362", "https://github.com/trinodb/trino/issues/4362")\)

== SPI

- Expose information about query type in query Event Listener. \(#issue("4592", "https://github.com/trinodb/trino/issues/4592")\)
- Add support for TopN pushdown via the #raw("ConnectorMetadata.applyLimit()") method. \(#issue("4249", "https://github.com/trinodb/trino/issues/4249")\)
- Deprecate the older variants of #raw("ConnectorSplitManager.getSplits()"). \(#issue("4508", "https://github.com/trinodb/trino/issues/4508")\)
