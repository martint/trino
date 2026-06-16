#import "/lib/trino-docs.typ": *

#anchor("doc-release-release-347")
= Release 347 \(25 Nov 2020\)

== General

- Add #raw("ALTER VIEW ... SET AUTHORIZATION") syntax for changing owner of the view. \(#issue("5789", "https://github.com/trinodb/trino/issues/5789")\)
- Add support for #raw("INTERSECT ALL") and #raw("EXCEPT ALL"). \(#issue("2152", "https://github.com/trinodb/trino/issues/2152")\)
- Add #link(label("fn-contains-sequence"), raw("contains_sequence")) function. \(#issue("5593", "https://github.com/trinodb/trino/issues/5593")\)
- Support defining cluster topology \(used for query scheduling\) using network subnets. \(#issue("4862", "https://github.com/trinodb/trino/issues/4862")\)
- Improve query performance by reducing worker to worker communication overhead. \(#issue("5905", "https://github.com/trinodb/trino/issues/5905"), #issue("5949", "https://github.com/trinodb/trino/issues/5949")\)
- Allow disabling client HTTP response compression, which can improve throughput over fast network links. Compression can be disabled globally via the #raw("query-results.compression-enabled") config property, for CLI via the #raw("--disable-compression") flag, and for the JDBC driver via the #raw("disableCompression") driver property. \(#issue("5818", "https://github.com/trinodb/trino/issues/5818")\)
- Rename #raw("rewrite-filtering-semi-join-to-inner-join") session property to #raw("rewrite_filtering_semi_join_to_inner_join"). \(#issue("5954", "https://github.com/trinodb/trino/issues/5954")\)
- Throw a user error when session property value cannot be decoded. \(#issue("5731", "https://github.com/trinodb/trino/issues/5731")\)
- Fix query failure when expressions that produce values of type #raw("row") are used in a #raw("VALUES") clause. \(#issue("3398", "https://github.com/trinodb/trino/issues/3398")\)

== Server

- A minimum Java version of 11.0.7 is now required for Presto to start. This is to mitigate JDK-8206955. \(#issue("5957", "https://github.com/trinodb/trino/issues/5957")\)

== Security

- Add support for multiple LDAP bind patterns. \(#issue("5874", "https://github.com/trinodb/trino/issues/5874")\)
- Include groups for view owner when checking permissions for views. \(#issue("5945", "https://github.com/trinodb/trino/issues/5945")\)

== JDBC driver

- Implement #raw("addBatch()"), #raw("clearBatch()") and #raw("executeBatch()") methods in #raw("PreparedStatement"). \(#issue("5507", "https://github.com/trinodb/trino/issues/5507")\)

== CLI

- Add support for providing queries to presto-cli via shell redirection. \(#issue("5881", "https://github.com/trinodb/trino/issues/5881")\)

== Docker image

- Update Presto docker image to use CentOS 8 as the base image. \(#issue("5920", "https://github.com/trinodb/trino/issues/5920")\)

== Hive connector

- Add support for #raw("ALTER VIEW  ... SET AUTHORIZATION") SQL syntax to change the view owner. This supports Presto and Hive views. \(#issue("5789", "https://github.com/trinodb/trino/issues/5789")\)
- Allow configuring HDFS replication factor via the #raw("hive.dfs.replication") config property. \(#issue("1829", "https://github.com/trinodb/trino/issues/1829")\)
- Add access checks for tables in Hive Procedures. \(#issue("1489", "https://github.com/trinodb/trino/issues/1489")\)
- Decrease latency of #raw("INSERT") and #raw("CREATE TABLE AS ...") queries by updating table and column statistics in parallel. \(#issue("3638", "https://github.com/trinodb/trino/issues/3638")\)
- Fix leaking S3 connections when querying Avro tables. \(#issue("5562", "https://github.com/trinodb/trino/issues/5562")\)

== Kudu connector

- Add dynamic filtering support. It can be enabled by setting a non-zero duration value for #raw("kudu.dynamic-filtering.wait-timeout") config property or #raw("dynamic_filtering_wait_timeout") session property. \(#issue("5594", "https://github.com/trinodb/trino/issues/5594")\)

== MongoDB connector

- Improve performance of queries containing a #raw("LIMIT") clause. \(#issue("5870", "https://github.com/trinodb/trino/issues/5870")\)

== Other connectors

- Improve query performance by compacting large pushed down predicates for the PostgreSQL, MySQL, Oracle, Redshift and SQL Server connectors. Compaction threshold can be changed using the #raw("domain-compaction-threshold") config property or #raw("domain_compaction_threshold") session property. \(#issue("6057", "https://github.com/trinodb/trino/issues/6057")\)
- Improve performance for the PostgreSQL, MySQL, SQL Server connectors for certain complex queries involving aggregation and predicates by pushing the aggregation and predicates computation into the remote database. \(#issue("4112", "https://github.com/trinodb/trino/issues/4112")\)

== SPI

- Add support for connectors to redirect table scan operations to another connector. \(#issue("5792", "https://github.com/trinodb/trino/issues/5792")\)
- Add physical input bytes and rows for table scan operation to query completion event. \(#issue("5872", "https://github.com/trinodb/trino/issues/5872")\)
