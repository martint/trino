#import "/lib/trino-docs.typ": *

#anchor("doc-release-release-453")
= Release 453 \(25 Jul 2024\)

== General

- Improve accuracy of the #link(label("fn-cosine-distance"), raw("cosine_distance")) function. \(#issue("22761", "https://github.com/trinodb/trino/issues/22761")\)
- Improve performance of non-equality joins. \(#issue("22521", "https://github.com/trinodb/trino/issues/22521")\)
- Improve performance for column masking with #link(label("doc-security-opa-access-control"))[Open Policy Agent access control]. \(#issue("21359", "https://github.com/trinodb/trino/issues/21359")\)
- Fix incorrect evaluation of repeated non-deterministic functions. \(#issue("22683", "https://github.com/trinodb/trino/issues/22683")\)
- Fix potential failure for queries involving #raw("GROUP BY"), #raw("UNNEST"), and filters over expressions that may produce an error for certain inputs. \(#issue("22731", "https://github.com/trinodb/trino/issues/22731")\)
- Fix planning failure for queries with a filter on an aggregation. \(#issue("22716", "https://github.com/trinodb/trino/issues/22716")\)
- Fix planning failure for queries involving multiple aggregations and #raw("CASE") expressions. \(#issue("22806", "https://github.com/trinodb/trino/issues/22806")\)
- Fix optimizer timeout for certain queries involving aggregations and #raw("CASE") expressions. \(#issue("22813", "https://github.com/trinodb/trino/issues/22813")\)

== Security

- Add support for #raw("IF EXISTS") to #raw("DROP ROLE"). \(#issue("21985", "https://github.com/trinodb/trino/issues/21985")\)

== JDBC driver

- Add support for using certificates from the operating system keystore. \(#issue("22341", "https://github.com/trinodb/trino/issues/22341")\)
- Add support for setting the default #link(label("doc-sql-set-path"))[SQL PATH]. \(#issue("22703", "https://github.com/trinodb/trino/issues/22703")\)
- Allow Trino host URI specification without port for the default ports 80 for HTTP and 443 for HTTPS. \(#issue("22724", "https://github.com/trinodb/trino/issues/22724")\)

== CLI

- Add support for using certificates from the operating system keystore. \(#issue("22341", "https://github.com/trinodb/trino/issues/22341")\)
- Add support for setting the default #link(label("doc-sql-set-path"))[SQL PATH]. \(#issue("22703", "https://github.com/trinodb/trino/issues/22703")\)
- Allow Trino host URI specification without port for the default ports 80 for HTTP and 443 for HTTPS. \(#issue("22724", "https://github.com/trinodb/trino/issues/22724")\)

== BigQuery connector

- Improve performance when querying information schema. \(#issue("22770", "https://github.com/trinodb/trino/issues/22770")\)

== Cassandra connector

- Add support for the #raw("execute") procedure. \(#issue("22556", "https://github.com/trinodb/trino/issues/22556")\)

== ClickHouse connector

- Add support for the #raw("execute") procedure. \(#issue("22556", "https://github.com/trinodb/trino/issues/22556")\)

== Delta Lake connector

- Add support for reading partition columns whose type changed via #link("https://docs.delta.io/latest/delta-type-widening.html")[type widening]. \(#issue("22433", "https://github.com/trinodb/trino/issues/22433")\)
- Add support for authenticating with Glue with a Kubernetes service account. This can be enabled via the #raw("hive.metastore.glue.use-web-identity-token-credentials-provider") configuration property. \(#issue("15267", "https://github.com/trinodb/trino/issues/15267")\)
- Fix failure when executing the #link(label("ref-delta-lake-vacuum"))[VACUUM] procedure on tables without old transaction logs. \(#issue("22816", "https://github.com/trinodb/trino/issues/22816")\)

== Druid connector

- Add support for the #raw("execute") procedure. \(#issue("22556", "https://github.com/trinodb/trino/issues/22556")\)

== Exasol connector

- Add support for the #raw("execute") procedure. \(#issue("22556", "https://github.com/trinodb/trino/issues/22556")\)

== Hive connector

- Add support for authenticating with Glue with a Kubernetes service account. This can be enabled via the #raw("hive.metastore.glue.use-web-identity-token-credentials-provider") configuration property. \(#issue("15267", "https://github.com/trinodb/trino/issues/15267")\)
- Fix failure to read Hive tables migrated to Iceberg with Apache Spark. \(#issue("11338", "https://github.com/trinodb/trino/issues/11338")\)
- Fix failure for #raw("CREATE FUNCTION") with SQL UDF storage in Glue when #raw("hive.metastore.glue.catalogid") is set. \(#issue("22717", "https://github.com/trinodb/trino/issues/22717")\)

== Hudi connector

- Add support for authenticating with Glue with a Kubernetes service account. This can be enabled via the #raw("hive.metastore.glue.use-web-identity-token-credentials-provider") configuration property. \(#issue("15267", "https://github.com/trinodb/trino/issues/15267")\)

== Iceberg connector

- #breaking-marker("../release.html#breaking-changes") Change the schema version for the JDBC catalog database to #raw("V1"). The previous value can be restored by setting the #raw("iceberg.jdbc-catalog.schema-version") configuration property to #raw("V0"). \(#issue("22576", "https://github.com/trinodb/trino/issues/22576")\)
- Add support for views with the JDBC catalog. Requires an upgrade of the schema for the JDBC catalog database to #raw("V1"). \(#issue("22576", "https://github.com/trinodb/trino/issues/22576")\)
- Add support for specifying on which schemas to enforce the presence of a partition filter in queries. This can be configured #raw("query-partition-filter-required-schemas") property. \(#issue("22540", "https://github.com/trinodb/trino/issues/22540")\)
- Add support for authenticating with Glue with a Kubernetes service account. This can be enabled via the #raw("hive.metastore.glue.use-web-identity-token-credentials-provider") configuration property. \(#issue("15267", "https://github.com/trinodb/trino/issues/15267")\)
- Fix failure when executing #raw("DROP SCHEMA ... CASCADE") using the REST catalog with Iceberg views. \(#issue("22758", "https://github.com/trinodb/trino/issues/22758")\)

== Ignite connector

- Add support for the #raw("execute") procedure. \(#issue("22556", "https://github.com/trinodb/trino/issues/22556")\)

== MariaDB connector

- Add support for the #raw("execute") procedure. \(#issue("22556", "https://github.com/trinodb/trino/issues/22556")\)

== MySQL connector

- Add support for the #raw("execute") procedure. \(#issue("22556", "https://github.com/trinodb/trino/issues/22556")\)

== Oracle connector

- Add support for the #raw("execute") procedure. \(#issue("22556", "https://github.com/trinodb/trino/issues/22556")\)

== Phoenix connector

- Add support for the #raw("execute") procedure. \(#issue("22556", "https://github.com/trinodb/trino/issues/22556")\)

== PostgreSQL connector

- Add support for reading the #raw("vector") type on #link("https://github.com/pgvector/pgvector/")[pgvector]. \(#issue("22630", "https://github.com/trinodb/trino/issues/22630")\)
- Add support for the #raw("execute") procedure. \(#issue("22556", "https://github.com/trinodb/trino/issues/22556")\)

== Redshift connector

- Add support for the #raw("execute") procedure. \(#issue("22556", "https://github.com/trinodb/trino/issues/22556")\)

== SingleStore connector

- Add support for the #raw("execute") procedure. \(#issue("22556", "https://github.com/trinodb/trino/issues/22556")\)

== Snowflake connector

- Add support for the #raw("execute") procedure. \(#issue("22556", "https://github.com/trinodb/trino/issues/22556")\)

== SQL Server connector

- Add support for the #raw("execute") procedure. \(#issue("22556", "https://github.com/trinodb/trino/issues/22556")\)

== SPI

- Add #raw("SystemAccessControl.getColumnMasks") as replacement for the deprecated #raw("SystemAccessControl.getColumnMask"). \(#issue("21997", "https://github.com/trinodb/trino/issues/21997")\)
