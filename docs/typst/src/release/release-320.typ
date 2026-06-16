#import "/lib/trino-docs.typ": *

#anchor("doc-release-release-320")
= Release 320 \(10 Oct 2019\)

== General

- Fix incorrect parameter binding order for prepared statement execution when parameters appear inside a #raw("WITH") clause. \(#issue("1191", "https://github.com/trinodb/trino/issues/1191")\)
- Fix planning failure for certain queries involving a mix of outer and cross joins. \(#issue("1589", "https://github.com/trinodb/trino/issues/1589")\)
- Improve performance of queries containing complex predicates. \(#issue("1515", "https://github.com/trinodb/trino/issues/1515")\)
- Avoid unnecessary evaluation of redundant filters. \(#issue("1516", "https://github.com/trinodb/trino/issues/1516")\)
- Improve performance of certain window functions when using bounded window frames \(e.g., #raw("ROWS BETWEEN ... PRECEDING AND ... FOLLOWING")\). \(#issue("464", "https://github.com/trinodb/trino/issues/464")\)
- Add Kinesis connector. \(#issue("476", "https://github.com/trinodb/trino/issues/476")\)
- Add #link(label("fn-geometry-from-hadoop-shape"), raw("geometry_from_hadoop_shape")). \(#issue("1593", "https://github.com/trinodb/trino/issues/1593")\)
- Add #link(label("fn-at-timezone"), raw("at_timezone")). \(#issue("1612", "https://github.com/trinodb/trino/issues/1612")\)
- Add #link(label("fn-with-timezone"), raw("with_timezone")). \(#issue("1612", "https://github.com/trinodb/trino/issues/1612")\)

== JDBC driver

- Only report warnings on #raw("Statement"), not #raw("ResultSet"), as warnings are not associated with reads of the #raw("ResultSet"). \(#issue("1640", "https://github.com/trinodb/trino/issues/1640")\)

== CLI

- Add multi-line editing and syntax highlighting. \(#issue("1380", "https://github.com/trinodb/trino/issues/1380")\)

== Hive connector

- Add impersonation support for calls to the Hive metastore. This can be enabled using the #raw("hive.metastore.thrift.impersonation.enabled") configuration property. \(#issue("43", "https://github.com/trinodb/trino/issues/43")\)
- Add caching support for Glue metastore. \(#issue("1625", "https://github.com/trinodb/trino/issues/1625")\)
- Add separate configuration property #raw("hive.hdfs.socks-proxy") for accessing HDFS via a SOCKS proxy. Previously, it was controlled with the #raw("hive.metastore.thrift.client.socks-proxy") configuration property. \(#issue("1469", "https://github.com/trinodb/trino/issues/1469")\)

== MySQL connector

- Add #raw("mysql.jdbc.use-information-schema") configuration property to control whether the MySQL JDBC driver should use the MySQL #raw("information_schema") to answer metadata queries. This may be helpful when diagnosing problems. \(#issue("1598", "https://github.com/trinodb/trino/issues/1598")\)

== PostgreSQL connector

- Add support for reading PostgreSQL system tables, e.g., #raw("pg_catalog") relations. The functionality is disabled by default and can be enabled using the #raw("postgresql.include-system-tables") configuration property. \(#issue("1527", "https://github.com/trinodb/trino/issues/1527")\)

== Elasticsearch connector

- Add support for #raw("VARBINARY"), #raw("TIMESTAMP"), #raw("TINYINT"), #raw("SMALLINT"), and #raw("REAL") data types. \(#issue("1639", "https://github.com/trinodb/trino/issues/1639")\)
- Discover available tables and their schema dynamically. \(#issue("1639", "https://github.com/trinodb/trino/issues/1639")\)
- Add support for special #raw("_id"), #raw("_score") and #raw("_source") columns. \(#issue("1639", "https://github.com/trinodb/trino/issues/1639")\)
- Add support for #link(label("ref-elasticsearch-full-text-queries"))[full text queries]. \(#issue("1662", "https://github.com/trinodb/trino/issues/1662")\)

== SPI

- Introduce a builder for #raw("Identity") and deprecate its public constructors. \(#issue("1624", "https://github.com/trinodb/trino/issues/1624")\)
