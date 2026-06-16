#import "/lib/trino-docs.typ": *

#anchor("doc-release-release-308")
= Release 308 \(11 Apr 2019\)

== General

- Fix a regression that prevented the server from starting on Java 9+. \(#issue("610", "https://github.com/trinodb/trino/issues/610")\)
- Fix correctness issue for queries involving #raw("FULL OUTER JOIN") and #raw("coalesce"). \(#issue("622", "https://github.com/trinodb/trino/issues/622")\)

== Security

- Add authorization for listing table columns. \(#issue("507", "https://github.com/trinodb/trino/issues/507")\)

== CLI

- Add option for specifying Kerberos service principal pattern. \(#issue("597", "https://github.com/trinodb/trino/issues/597")\)

== JDBC driver

- Correctly report precision and column display size in #raw("ResultSetMetaData") for #raw("char") and #raw("varchar") columns. \(#issue("615", "https://github.com/trinodb/trino/issues/615")\)
- Add option for specifying Kerberos service principal pattern. \(#issue("597", "https://github.com/trinodb/trino/issues/597")\)

== Hive connector

- Fix regression that could cause queries to fail with #raw("Query can potentially read more than X partitions") error. \(#issue("619", "https://github.com/trinodb/trino/issues/619")\)
- Improve ORC read performance significantly. For TPC-DS, this saves about 9.5% of total CPU when running over gzip-compressed data. \(#issue("555", "https://github.com/trinodb/trino/issues/555")\)
- Require access to a table \(any privilege\) in order to list the columns. \(#issue("507", "https://github.com/trinodb/trino/issues/507")\)
- Add directory listing cache for specific tables. The list of tables is specified using the  #raw("hive.file-status-cache-tables") configuration property. \(#issue("343", "https://github.com/trinodb/trino/issues/343")\)

== MySQL connector

- Fix #raw("ALTER TABLE ... RENAME TO ...") statement. \(#issue("586", "https://github.com/trinodb/trino/issues/586")\)
- Push simple #raw("LIMIT") queries into the external database. \(#issue("589", "https://github.com/trinodb/trino/issues/589")\)

== PostgreSQL connector

- Push simple #raw("LIMIT") queries into the external database. \(#issue("589", "https://github.com/trinodb/trino/issues/589")\)

== Redshift connector

- Push simple #raw("LIMIT") queries into the external database. \(#issue("589", "https://github.com/trinodb/trino/issues/589")\)

== SQL Server connector

- Fix writing #raw("varchar") values with non-Latin characters in #raw("CREATE TABLE AS"). \(#issue("573", "https://github.com/trinodb/trino/issues/573")\)
- Support writing #raw("varchar") and #raw("char") values with length longer than 4000 characters in #raw("CREATE TABLE AS"). \(#issue("573", "https://github.com/trinodb/trino/issues/573")\)
- Support writing #raw("boolean") values in #raw("CREATE TABLE AS"). \(#issue("573", "https://github.com/trinodb/trino/issues/573")\)
- Push simple #raw("LIMIT") queries into the external database. \(#issue("589", "https://github.com/trinodb/trino/issues/589")\)

== Elasticsearch connector

- Add support for Search Guard in Elasticsearch connector. Please refer to #link(label("doc-connector-elasticsearch"))[Elasticsearch connector] for the relevant configuration properties. \(#issue("438", "https://github.com/trinodb/trino/issues/438")\)
