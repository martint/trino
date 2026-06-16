#import "/lib/trino-docs.typ": *

#anchor("doc-release-release-401")
= Release 401 \(26 Oct 2022\)

== General

- Add support for using path-style access for all requests to S3 when using fault-tolerant execution with exchange spooling. This can be enabled with the #raw("exchange.s3.path-style-access") configuration property. \(#issue("14655", "https://github.com/trinodb/trino/issues/14655")\)
- Add support for table functions in file-based access control. \(#issue("13713", "https://github.com/trinodb/trino/issues/13713")\)
- Add output buffer utilization distribution to #raw("EXPLAIN ANALYZE VERBOSE"). \(#issue("14596", "https://github.com/trinodb/trino/issues/14596")\)
- Add operator blocked time distribution to #raw("EXPLAIN ANALYZE VERBOSE"). \(#issue("14640", "https://github.com/trinodb/trino/issues/14640")\)
- Improve performance and reliability of #raw("INSERT") and #raw("MERGE"). \(#issue("14553", "https://github.com/trinodb/trino/issues/14553")\)
- Fix query failure caused by a #raw("com.google.common.base.VerifyException: cannot unset noMoreSplits") error. \(#issue("14668", "https://github.com/trinodb/trino/issues/14668")\)
- Fix underestimation of CPU usage and scheduled time statistics for joins in #raw("EXPLAIN ANALYZE"). \(#issue("14572", "https://github.com/trinodb/trino/issues/14572")\)

== Cassandra connector

- Upgrade minimum required Cassandra version to 3.0. \(#issue("14562", "https://github.com/trinodb/trino/issues/14562")\)

== Delta Lake connector

- Add support for writing to tables with #link("https://docs.delta.io/latest/versioning.html#features-by-protocol-version")[Delta Lake writer protocol version 4]. This does not yet include support for #link("https://docs.delta.io/2.0.0/delta-change-data-feed.html")[change data feeds] or generated columns. \(#issue("14573 ", "https://github.com/trinodb/trino/issues/14573 ")\)
- Add support for writes on Google Cloud Storage. \(#issue("12264", "https://github.com/trinodb/trino/issues/12264")\)
- Avoid overwriting the reader and writer versions when executing a #raw("COMMENT") or #raw("ALTER TABLE ... ADD COLUMN") statement. \(#issue("14611", "https://github.com/trinodb/trino/issues/14611")\)
- Fix failure when listing tables from the Glue metastore and one of the tables has no properties. \(#issue("14577", "https://github.com/trinodb/trino/issues/14577")\)

== Hive connector

- Add support for IBM Cloud Object Storage. \(#issue("14625", "https://github.com/trinodb/trino/issues/14625")\)
- Allow creating tables with an Avro schema literal using the new table property #raw("avro_schema_literal"). \(#issue("14426", "https://github.com/trinodb/trino/issues/14426")\)
- Fix potential query failure or incorrect results when reading from a table with the #raw("avro.schema.literal") Hive table property set. \(#issue("14426", "https://github.com/trinodb/trino/issues/14426")\)
- Fix failure when listing tables from the Glue metastore and one of the tables has no properties. \(#issue("14577", "https://github.com/trinodb/trino/issues/14577")\)

== Iceberg connector

- Improve performance of the #raw("remove_orphan_files") table procedure. \(#issue("13691", "https://github.com/trinodb/trino/issues/13691")\)
- Fix query failure when analyzing a table that contains a column with a non-lowercase name. \(#issue("14583", "https://github.com/trinodb/trino/issues/14583")\)
- Fix failure when listing tables from the Glue metastore and one of the tables has no properties. \(#issue("14577", "https://github.com/trinodb/trino/issues/14577")\)

== Kafka connector

- Add support for configuring the prefix for internal column names with the #raw("kafka.internal-column-prefix") catalog configuration property. The default value is #raw("_") to maintain current behavior. \(#issue("14224", "https://github.com/trinodb/trino/issues/14224")\)

== MongoDB connector

- Add #raw("query") table function for query pass-through to the connector. \(#issue("14535", "https://github.com/trinodb/trino/issues/14535")\)

== MySQL connector

- Add support for writes when #link(label("doc-admin-fault-tolerant-execution"))[fault-tolerant execution] is enabled. \(#issue("14445", "https://github.com/trinodb/trino/issues/14445")\)

== Pinot connector

- Fix failure when executing #raw("SHOW CREATE TABLE"). \(#issue("14071", "https://github.com/trinodb/trino/issues/14071")\)

== PostgreSQL connector

- Add support for writes when #link(label("doc-admin-fault-tolerant-execution"))[fault-tolerant execution] is enabled. \(#issue("14445", "https://github.com/trinodb/trino/issues/14445")\)

== SQL Server connector

- Add support for writes when #link(label("doc-admin-fault-tolerant-execution"))[fault-tolerant execution] is enabled. \(#issue("14730", "https://github.com/trinodb/trino/issues/14730")\)

== SPI

- Add stage output buffer distribution to #raw("EventListener"). \(#issue("14638", "https://github.com/trinodb/trino/issues/14638")\)
