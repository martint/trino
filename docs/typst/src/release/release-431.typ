#import "/lib/trino-docs.typ": *

#anchor("doc-release-release-431")
= Release 431 \(27 Oct 2023\)

== General

- Add support for #link(label("doc-udf-sql"))[SQL user-defined functions]. \(#issue("19308", "https://github.com/trinodb/trino/issues/19308")\)
- Add support for #link(label("doc-sql-create-function"))[CREATE FUNCTION] and #link(label("doc-sql-drop-function"))[DROP FUNCTION] statements. \(#issue("19308", "https://github.com/trinodb/trino/issues/19308")\)
- Add support for the #raw("REPLACE") modifier to the #raw("CREATE TABLE") statement. \(#issue("13180", "https://github.com/trinodb/trino/issues/13180")\)
- Disallow a #raw("null") offset for the #link(label("fn-lead"), raw("lead")) and #link(label("fn-lag"), raw("lag")) functions. \(#issue("19003", "https://github.com/trinodb/trino/issues/19003")\)
- Improve performance of queries with short running splits. \(#issue("19487", "https://github.com/trinodb/trino/issues/19487")\)

== Security

- Support defining rules for procedures in file-based access control. \(#issue("19416", "https://github.com/trinodb/trino/issues/19416")\)
- Mask additional sensitive values in log files. \(#issue("19519", "https://github.com/trinodb/trino/issues/19519")\)

== JDBC driver

- Improve latency for prepared statements for Trino versions that support #raw("EXECUTE IMMEDIATE") when the #raw("explicitPrepare") parameter to is set to #raw("false"). \(#issue("19541", "https://github.com/trinodb/trino/issues/19541")\)

== Delta Lake connector

- Replace the #raw("hive.metastore-timeout") Hive metastore configuration property with the #raw("hive.metastore.thrift.client.connect-timeout") and #raw("hive.metastore.thrift.client.read-timeout") properties. \(#issue("19390", "https://github.com/trinodb/trino/issues/19390")\)

== Hive connector

- Add support for #link(label("ref-udf-management"))[SQL statement support]. \(#issue("19308", "https://github.com/trinodb/trino/issues/19308")\)
- Replace the #raw("hive.metastore-timeout") Hive metastore configuration property with the #raw("hive.metastore.thrift.client.connect-timeout") and #raw("hive.metastore.thrift.client.read-timeout") properties. \(#issue("19390", "https://github.com/trinodb/trino/issues/19390")\)
- Improve support for concurrent updates of table statistics in Glue. \(#issue("19463", "https://github.com/trinodb/trino/issues/19463")\)
- Fix Hive view translation failures involving comparisons between char and varchar fields. \(#issue("18337", "https://github.com/trinodb/trino/issues/18337")\)

== Hudi connector

- Replace the #raw("hive.metastore-timeout") Hive metastore configuration property with the #raw("hive.metastore.thrift.client.connect-timeout") and #raw("hive.metastore.thrift.client.read-timeout") properties. \(#issue("19390", "https://github.com/trinodb/trino/issues/19390")\)

== Iceberg connector

- Add support for the #raw("REPLACE") modifier to the #raw("CREATE TABLE") statement. \(#issue("13180", "https://github.com/trinodb/trino/issues/13180")\)
- Replace the #raw("hive.metastore-timeout") Hive metastore configuration property with the #raw("hive.metastore.thrift.client.connect-timeout") and #raw("hive.metastore.thrift.client.read-timeout") properties. \(#issue("19390", "https://github.com/trinodb/trino/issues/19390")\)

== Memory connector

- Add support for #link(label("ref-udf-management"))[SQL statement support]. \(#issue("19308", "https://github.com/trinodb/trino/issues/19308")\)

== SPI

- Add #raw("ValueBlock") abstraction along with #raw("VALUE_BLOCK_POSITION") and #raw("VALUE_BLOCK_POSITION_NOT_NULL") calling conventions. \(#issue("19385", "https://github.com/trinodb/trino/issues/19385")\)
- Require a separate block position for each argument of aggregation functions. \(#issue("19385", "https://github.com/trinodb/trino/issues/19385")\)
- Require implementations of #raw("Block") to implement #raw("ValueBlock"). \(#issue("19480", "https://github.com/trinodb/trino/issues/19480")\)
