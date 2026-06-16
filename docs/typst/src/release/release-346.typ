#import "/lib/trino-docs.typ": *

#anchor("doc-release-release-346")
= Release 346 \(10 Nov 2020\)

== General

- Add support for #raw("RANGE BETWEEN <value> PRECEDING AND <value> FOLLOWING") window frames. \(#issue("609", "https://github.com/trinodb/trino/issues/609")\)
- Add support for window frames based on #raw("GROUPS"). \(#issue("5713", "https://github.com/trinodb/trino/issues/5713")\)
- Add support for #link(label("fn-extract"), raw("extract")) with #raw("TIMEZONE_HOUR") and #raw("TIMEZONE_MINUTE") for #raw("time with time zone") values. \(#issue("5668", "https://github.com/trinodb/trino/issues/5668")\)
- Add SQL syntax for #raw("GRANT") and #raw("REVOKE") on schema. This is not yet used by any connector. \(#issue("4396", "https://github.com/trinodb/trino/issues/4396")\)
- Add #raw("ALTER TABLE ... SET AUTHORIZATION") syntax to allow changing the table owner. \(#issue("5717", "https://github.com/trinodb/trino/issues/5717")\)
- Make #raw("EXPLAIN") more readable for queries containing #raw("timestamp") or #raw("timestamp with time zone")  constants. \(#issue("5683", "https://github.com/trinodb/trino/issues/5683")\)
- Improve performance for queries with inequality conditions. \(#issue("2674", "https://github.com/trinodb/trino/issues/2674")\)
- Improve performance of queries with uncorrelated #raw("IN") clauses. \(#issue("5582", "https://github.com/trinodb/trino/issues/5582")\)
- Use consistent NaN behavior for #link(label("fn-least"), raw("least")), #link(label("fn-greatest"), raw("greatest")), #link(label("fn-array-min"), raw("array_min")), #link(label("fn-array-max"), raw("array_max")), #link(label("fn-min"), raw("min")), #link(label("fn-max"), raw("max")), #link(label("fn-min-by"), raw("min_by")), and #link(label("fn-max-by"), raw("max_by")). NaN is only returned when it is the only value \(except for null which are ignored for aggregation functions\). \(#issue("5851", "https://github.com/trinodb/trino/issues/5851")\)
- Restore previous null handling for #link(label("fn-least"), raw("least")) and #link(label("fn-greatest"), raw("greatest")). \(#issue("5787", "https://github.com/trinodb/trino/issues/5787")\)
- Restore previous null handling for #link(label("fn-array-min"), raw("array_min")) and #link(label("fn-array-max"), raw("array_max")). \(#issue("5787", "https://github.com/trinodb/trino/issues/5787")\)
- Remove configuration properties #raw("arrayagg.implementation"), #raw("multimapagg.implementation"), and #raw("histogram.implementation"). \(#issue("4581", "https://github.com/trinodb/trino/issues/4581")\)
- Fix incorrect handling of negative offsets for the #raw("time with time zone") type. \(#issue("5696", "https://github.com/trinodb/trino/issues/5696")\)
- Fix incorrect result when casting #raw("time(p)") to #raw("timestamp(p)") for precisions higher than 6. \(#issue("5736", "https://github.com/trinodb/trino/issues/5736")\)
- Fix incorrect query results when comparing a #raw("timestamp") column with a #raw("timestamp with time zone") constant. \(#issue("5685", "https://github.com/trinodb/trino/issues/5685")\)
- Fix improper table alias visibility for queries that select all fields. \(#issue("5660", "https://github.com/trinodb/trino/issues/5660")\)
- Fix failure when query parameter appears in a lambda expression. \(#issue("5640", "https://github.com/trinodb/trino/issues/5640")\)
- Fix failure for queries containing #raw("DISTINCT *") and fully-qualified column names in the #raw("ORDER BY") clause. \(#issue("5647", "https://github.com/trinodb/trino/issues/5647")\)
- Fix planning failure for certain queries involving #raw("INNER JOIN"), #raw("GROUP BY") and correlated subqueries. \(#issue("5846", "https://github.com/trinodb/trino/issues/5846")\)
- Fix recording of query completion event when query is aborted early. \(#issue("5815", "https://github.com/trinodb/trino/issues/5815")\)
- Fix exported JMX name for #raw("QueryManager"). \(#issue("5702", "https://github.com/trinodb/trino/issues/5702")\)
- Fix failure when #link(label("fn-approx-distinct"), raw("approx_distinct")) is used with high precision #raw("timestamp(p)")\/#raw("timestamp(p) with time zone")\/#raw("time(p) with time zone") data types. \(#issue("5392", "https://github.com/trinodb/trino/issues/5392")\)

== Web UI

- Fix "Capture Snapshot" button on the Worker page. \(#issue("5759", "https://github.com/trinodb/trino/issues/5759")\)

== JDBC driver

- Support number accessor methods like #raw("ResultSet.getLong()") or #raw("ResultSet.getDouble()") on #raw("decimal") values, as well as #raw("char") or #raw("varchar") values that can be unambiguously interpreted as numbers. \(#issue("5509", "https://github.com/trinodb/trino/issues/5509")\)
- Add #raw("SSLVerification") JDBC connection parameter that allows configuring SSL verification. \(#issue("5610", "https://github.com/trinodb/trino/issues/5610")\)
- Remove legacy #raw("useSessionTimeZone") JDBC connection parameter. \(#issue("4521", "https://github.com/trinodb/trino/issues/4521")\)
- Implement #raw("ResultSet.getRow()"). \(#issue("5769", "https://github.com/trinodb/trino/issues/5769")\)

== Server RPM

- Remove leftover empty directories after RPM uninstall. \(#issue("5782", "https://github.com/trinodb/trino/issues/5782")\)

== BigQuery connector

- Fix issue when query could return invalid results if some column references were pruned out during query optimization. \(#issue("5618", "https://github.com/trinodb/trino/issues/5618")\)

== Cassandra connector

- Improve performance of #raw("INSERT") queries with batch statement. The batch size can be configured via the #raw("cassandra.batch-size") configuration property. \(#issue("5047", "https://github.com/trinodb/trino/issues/5047")\)

== Elasticsearch connector

- Fix failure when index mappings do not contain a #raw("properties") section. \(#issue("5807", "https://github.com/trinodb/trino/issues/5807")\)

== Hive connector

- Add support for #raw("ALTER TABLE ... SET AUTHORIZATION") SQL syntax to change the table owner. \(#issue("5717", "https://github.com/trinodb/trino/issues/5717")\)
- Add support for writing timestamps with microsecond or nanosecond precision, in addition to milliseconds. \(#issue("5283", "https://github.com/trinodb/trino/issues/5283")\)
- Export JMX statistics for Glue metastore client request metrics. \(#issue("5693", "https://github.com/trinodb/trino/issues/5693")\)
- Collect column statistics during #raw("ANALYZE") and when data is inserted to table for columns of #raw("timestamp(p)") when precision is greater than 3. \(#issue("5392", "https://github.com/trinodb/trino/issues/5392")\)
- Improve query performance by adding support for dynamic bucket pruning. \(#issue("5634", "https://github.com/trinodb/trino/issues/5634")\)
- Remove deprecated #raw("parquet.fail-on-corrupted-statistics") \(previously known as #raw("hive.parquet.fail-on-corrupted-statistics")\). A new configuration property, #raw("parquet.ignore-statistics"), can be used to deal with Parquet files with incorrect metadata.  \(#issue("3077", "https://github.com/trinodb/trino/issues/3077")\)
- Do not write min\/max statistics for #raw("timestamp") columns. \(#issue("5858", "https://github.com/trinodb/trino/issues/5858")\)
- If multiple metastore URIs are defined via #raw("hive.metastore.uri"), prefer connecting to one which was seen operational most recently. This prevents query failures when one or more metastores are misbehaving. \(#issue("5795", "https://github.com/trinodb/trino/issues/5795")\)
- Fix Hive view access when catalog name is other than #raw("hive"). \(#issue("5785", "https://github.com/trinodb/trino/issues/5785")\)
- Fix failure when the declared length of a #raw("varchar(n)") column in the partition schema differs from the table schema. \(#issue("5484", "https://github.com/trinodb/trino/issues/5484")\)
- Fix Glue metastore pushdown for complex expressions. \(#issue("5698", "https://github.com/trinodb/trino/issues/5698")\)

== Iceberg connector

- Add support for materialized views. \(#issue("4832", "https://github.com/trinodb/trino/issues/4832")\)
- Remove deprecated #raw("parquet.fail-on-corrupted-statistics") \(previously known as #raw("hive.parquet.fail-on-corrupted-statistics")\). A new configuration property, #raw("parquet.ignore-statistics"), can be used to deal with Parquet files with incorrect metadata.  \(#issue("3077", "https://github.com/trinodb/trino/issues/3077")\)

== Kafka connector

- Fix incorrect column comment. \(#issue("5751", "https://github.com/trinodb/trino/issues/5751")\)

== Kudu connector

- Improve performance of queries having only #raw("LIMIT") clause. \(#issue("3691", "https://github.com/trinodb/trino/issues/3691")\)

== MySQL connector

- Improve performance for queries containing a predicate on a #raw("varbinary") column. \(#issue("5672", "https://github.com/trinodb/trino/issues/5672")\)

== Oracle connector

- Add support for setting column comments. \(#issue("5399", "https://github.com/trinodb/trino/issues/5399")\)
- Allow enabling remarks reporting via #raw("oracle.remarks-reporting.enabled") configuration property. \(#issue("5720", "https://github.com/trinodb/trino/issues/5720")\)

== PostgreSQL connector

- Improve performance of queries comparing a #raw("timestamp") column with a #raw("timestamp with time zone") constants for #raw("timestamp with time zone") precision higher than 3. \(#issue("5543", "https://github.com/trinodb/trino/issues/5543")\)

== Other connectors

- Improve performance of queries with #raw("DISTINCT") or #raw("LIMIT"), or with #raw("GROUP BY") and no aggregate functions and #raw("LIMIT"), when the computation can be pushed down to the underlying database for the PostgreSQL, MySQL, Oracle, Redshift and SQL Server connectors. \(#issue("5522", "https://github.com/trinodb/trino/issues/5522")\)

== SPI

- Fix propagation of connector session properties to #raw("ConnectorNodePartitioningProvider"). \(#issue("5690", "https://github.com/trinodb/trino/issues/5690")\)
- Add user groups to query events. \(#issue("5643", "https://github.com/trinodb/trino/issues/5643")\)
- Add planning time to query completed event. \(#issue("5643", "https://github.com/trinodb/trino/issues/5643")\)
