#import "/lib/trino-docs.typ": *

#anchor("doc-release-release-361")
= Release 361 \(27 Aug 2021\)

== General

- Add support for subqueries in #raw("MATCH_RECOGNIZE") and #raw("WINDOW") clause. \(#issue("8736", "https://github.com/trinodb/trino/issues/8736")\)
- Add #raw("system.metadata.materialized_views") table that contains detailed information about materialized views. \(#issue("8796", "https://github.com/trinodb/trino/issues/8796")\)
- Support table redirection for #raw("INSERT"), #raw("UPDATE") and #raw("DELETE") operations. \(#issue("8683", "https://github.com/trinodb/trino/issues/8683")\)
- Improve performance of #link(label("fn-sum"), raw("sum")) and #link(label("fn-avg"), raw("avg")) aggregations on #raw("decimal") values. \(#issue("8878", "https://github.com/trinodb/trino/issues/8878")\)
- Improve performance for queries using #raw("IN") predicate with moderate to large number of constants. \(#issue("8833", "https://github.com/trinodb/trino/issues/8833")\)
- Fix failures of specific queries accessing #raw("row") columns with with field names that would require quoting when used as an identifier.  \(#issue("8845", "https://github.com/trinodb/trino/issues/8845")\)
- Fix incorrect results for queries with a comparison between a #raw("varchar") column and a #raw("char") constant. \(#issue("8984", "https://github.com/trinodb/trino/issues/8984")\)
- Fix invalid result when two decimals are added together. This happened in certain queries where decimals had different precision. \(#issue("8973", "https://github.com/trinodb/trino/issues/8973")\)
- Prevent dropping or renaming objects with an incompatible SQL command. For example, #raw("DROP TABLE") no longer allows dropping a view. \(#issue("8869", "https://github.com/trinodb/trino/issues/8869")\)

== Security

- Add support for OAuth2\/OIDC opaque access tokens. The property #raw("http-server.authentication.oauth2.audience") has been removed in favor of using #raw("http-server.authentication.oauth2.client-id"), as expected by OIDC. The new property #raw("http-server.authentication.oauth2.additional-audiences") supports audiences which are not the #raw("client-id"). Additionally, the new property #raw("http-server.authentication.oauth2.issuer") is now required; tokens which are not issued by this URL will be rejected. \(#issue("8641", "https://github.com/trinodb/trino/issues/8641")\)

== JDBC driver

- Implement the #raw("PreparedStatement.getParameterMetaData()") method. \(#issue("2978", "https://github.com/trinodb/trino/issues/2978")\)
- Fix listing columns where table or schema name pattern contains an upper case value. Note that this fix is on the server, not in the JDBC driver. \(#issue("8978", "https://github.com/trinodb/trino/issues/8978")\)

== BigQuery connector

- Fix incorrect result when using BigQuery #raw("time") type. \(#issue("8999", "https://github.com/trinodb/trino/issues/8999")\)

== Cassandra connector

- Add support for predicate pushdown of #raw("smallint"), #raw("tinyint") and #raw("date") types on partition columns. \(#issue("3763", "https://github.com/trinodb/trino/issues/3763")\)
- Fix incorrect results for queries containing inequality predicates on a clustering key in the #raw("WHERE") clause. \(#issue("401", "https://github.com/trinodb/trino/issues/401")\)

== ClickHouse connector

- Allow limiting the size of the metadata cache via the #raw("metadata.cache-maximum-size") configuration property. \(#issue("8652", "https://github.com/trinodb/trino/issues/8652")\)
- Fix incorrect results for aggregation functions applied to columns of type #raw("varchar") and #raw("char"). \(#issue("7320", "https://github.com/trinodb/trino/issues/7320")\)

== Druid connector

- Allow limiting the size of the metadata cache via the #raw("metadata.cache-maximum-size") configuration property. \(#issue("8652", "https://github.com/trinodb/trino/issues/8652")\)

== Elasticsearch connector

- Add support for reading fields as #raw("json") values. \(#issue("7308", "https://github.com/trinodb/trino/issues/7308")\)

== Hive connector

- Expose #raw("<view>$properties") system table for Trino and Hive views. \(#issue("8805", "https://github.com/trinodb/trino/issues/8805")\)
- Add support for translating Hive views which contain common table expressions. \(#issue("5977", "https://github.com/trinodb/trino/issues/5977")\)
- Add support for translating Hive views which contain outer parentheses. \(#issue("8789", "https://github.com/trinodb/trino/issues/8789")\)
- Add support for translating Hive views which use the #raw("from_utc_timestamp") function. \(#issue("8502", "https://github.com/trinodb/trino/issues/8502")\)
- Add support for translating Hive views which use the #raw("date") function. \(#issue("8789", "https://github.com/trinodb/trino/issues/8789")\)
- Add support for translating Hive views which use the #raw("pmod") function. \(#issue("8935", "https://github.com/trinodb/trino/issues/8935")\)
- Prevent creating of tables that have column names containing commas, or leading or trailing spaces. \(#issue("8954", "https://github.com/trinodb/trino/issues/8954")\)
- Improve performance of updating Glue table statistics for partitioned tables. \(#issue("8839", "https://github.com/trinodb/trino/issues/8839")\)
- Change default Glue statistics read\/write parallelism from 1 to 5. \(#issue("8839", "https://github.com/trinodb/trino/issues/8839")\)
- Improve performance of querying Parquet data for files containing column indexes. \(#issue("7349", "https://github.com/trinodb/trino/issues/7349")\)
- Fix query failure when inserting data into a Hive ACID table which is not explicitly bucketed. \(#issue("8899", "https://github.com/trinodb/trino/issues/8899")\)

== Iceberg connector

- Fix reading or writing Iceberg tables that previously contained a partition field that was later dropped. \(#issue("8730", "https://github.com/trinodb/trino/issues/8730")\)
- Allow reading from Iceberg tables which specify the Iceberg #raw("write.object-storage.path") table property. \(#issue("8573", "https://github.com/trinodb/trino/issues/8573")\)
- Allow using randomized location when creating a table, so that future table renames or drops do not interfere with new tables created with the same name. This can be enabled using the #raw("iceberg.unique-table-location") configuration property. \(#issue("6063", "https://github.com/trinodb/trino/issues/6063")\)
- Return proper query results for queries accessing multiple snapshots of single Iceberg table. \(#issue("8868", "https://github.com/trinodb/trino/issues/8868")\)

== MemSQL connector

- Allow limiting the size of the metadata cache via the #raw("metadata.cache-maximum-size") configuration property. \(#issue("8652", "https://github.com/trinodb/trino/issues/8652")\)

== MongoDB connector

- Add #link(label("fn-timestamp-objectid"), raw("timestamp_objectid")) function. \(#issue("8824", "https://github.com/trinodb/trino/issues/8824")\)
- Enable #raw("mongodb.socket-keep-alive") config property by default. \(#issue("8832", "https://github.com/trinodb/trino/issues/8832")\)

== MySQL connector

- Allow limiting the size of the metadata cache via the #raw("metadata.cache-maximum-size") configuration property. \(#issue("8652", "https://github.com/trinodb/trino/issues/8652")\)
- Fix incorrect results for aggregation functions applied to columns of type #raw("varchar") and #raw("char"). \(#issue("7320", "https://github.com/trinodb/trino/issues/7320")\)

== Oracle connector

- Allow limiting the size of the metadata cache via the #raw("metadata.cache-maximum-size") configuration property. \(#issue("8652", "https://github.com/trinodb/trino/issues/8652")\)

== Phoenix connector

- Allow limiting the size of the metadata cache via the #raw("metadata.cache-maximum-size") configuration property. \(#issue("8652", "https://github.com/trinodb/trino/issues/8652")\)

== Pinot connector

- Implement aggregation pushdown for #raw("count"), #raw("avg"), #raw("min"), #raw("max"), #raw("sum"), #raw("count(DISTINCT)") and #raw("approx_distinct"). It is enabled by default and can be disabled using the configuration property #raw("pinot.aggregation-pushdown.enabled") or the catalog session property #raw("aggregation_pushdown_enabled"). \(#issue("4140", "https://github.com/trinodb/trino/issues/4140")\)
- Allow #raw("https") URLs in #raw("pinot.controller-urls"). \(#issue("8617", "https://github.com/trinodb/trino/issues/8617")\)
- Fix failures when querying #raw("information_schema.columns") with a filter on the table name. \(#issue("8307", "https://github.com/trinodb/trino/issues/8307")\)

== PostgreSQL connector

- Allow limiting the size of the metadata cache via the #raw("metadata.cache-maximum-size") configuration property. \(#issue("8652", "https://github.com/trinodb/trino/issues/8652")\)
- Fix incorrect results for aggregation functions applied to columns of type #raw("varchar") and #raw("char"). \(#issue("7320", "https://github.com/trinodb/trino/issues/7320")\)

== Redshift connector

- Allow limiting the size of the metadata cache via the #raw("metadata.cache-maximum-size") configuration property. \(#issue("8652", "https://github.com/trinodb/trino/issues/8652")\)

== SQL Server connector

- Allow limiting the size of the metadata cache via the #raw("metadata.cache-maximum-size") configuration property. \(#issue("8652", "https://github.com/trinodb/trino/issues/8652")\)
- Fix incorrect results for aggregation functions applied to columns of type #raw("varchar") and #raw("char"). \(#issue("7320", "https://github.com/trinodb/trino/issues/7320")\)
