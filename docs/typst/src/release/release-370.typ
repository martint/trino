#import "/lib/trino-docs.typ": *

#anchor("doc-release-release-370")
= Release 370 \(3 Feb 2022\)

== General

- Add support for #raw("DEFAULT") keyword in #raw("ALTER TABLE...SET PROPERTIES..."). \(#issue("10331", "https://github.com/trinodb/trino/issues/10331")\)
- Improve performance of map and row types. \(#issue("10469", "https://github.com/trinodb/trino/issues/10469")\)
- Improve performance when evaluating expressions in #raw("WHERE") and #raw("SELECT") clauses. \(#issue("10322", "https://github.com/trinodb/trino/issues/10322")\)
- Prevent queries deadlock when using #raw("phased") execution policy with dynamic filters in multi-join queries. \(#issue("10868", "https://github.com/trinodb/trino/issues/10868")\)
- Fix query scheduling regression introduced in Trino 360 that caused coordinator slowness in assigning splits to workers. \(#issue("10839", "https://github.com/trinodb/trino/issues/10839")\)
- Fix #raw("information_schema") query failure when an #raw("IS NOT NULL") predicate is used. \(#issue("10861", "https://github.com/trinodb/trino/issues/10861")\)
- Fix failure when nested subquery contains a #raw("TABLESAMPLE") clause. \(#issue("10764", "https://github.com/trinodb/trino/issues/10764")\)

== Security

- Reduced the latency of successful OAuth 2.0 authentication. \(#issue("10929", "https://github.com/trinodb/trino/issues/10929")\)
- Fix server start failure when using JWT and OAuth 2.0 authentication together \(#raw("http-server.authentication.type=jwt,oauth2")\). \(#issue("10811", "https://github.com/trinodb/trino/issues/10811")\)

== CLI

- Add support for ARM64 processors. \(#issue("10177", "https://github.com/trinodb/trino/issues/10177")\)
- Allow to choose the way how external authentication is handled with the #raw("--external-authentication-redirect-handler") parameter. \(#issue("10248", "https://github.com/trinodb/trino/issues/10248")\)

== RPM package

- Fix failure when operating system open file count is set too low. \(#issue("8819", "https://github.com/trinodb/trino/issues/8819")\)

== Docker image

- Change base image to #raw("registry.access.redhat.com/ubi8/ubi"), since CentOS 8 has reached end-of-life. \(#issue("10866", "https://github.com/trinodb/trino/issues/10866")\)

== Cassandra connector

- Fix query failure when pushing predicates on #raw("uuid") partitioned columns. \(#issue("10799", "https://github.com/trinodb/trino/issues/10799")\)

== ClickHouse connector

- Support creating tables with Trino #raw("timestamp(0)") type columns.
- Drop support for ClickHouse servers older than version 20.7 to avoid using a deprecated driver. You can continue to use the deprecated driver with the #raw("clickhouse.legacy-driver") flag when connecting to old servers. \(#issue("10541", "https://github.com/trinodb/trino/issues/10541")\)
- Remove the legacy #raw("allow-drop-table") configuration property. This defaulted to #raw("false"), which disallowed dropping tables, but other modifications were still allowed. Use #link(label("doc-security-built-in-system-access-control"))[System access control] instead, if desired. \(#issue("588", "https://github.com/trinodb/trino/issues/588")\)

== Druid connector

- Remove the legacy #raw("allow-drop-table") configuration property. This defaulted to #raw("false"), which disallowed dropping tables, but other modifications were still allowed. Use #link(label("doc-security-built-in-system-access-control"))[System access control] instead, if desired. \(#issue("588", "https://github.com/trinodb/trino/issues/588")\)

== Hive connector

- Improve query performance when reading ORC data. \(#issue("10575", "https://github.com/trinodb/trino/issues/10575")\)
- Add configuration property #raw("hive.single-statement-writes") to require auto-commit for writes. This can be used to disallow multi-statement write transactions. \(#issue("10820", "https://github.com/trinodb/trino/issues/10820")\)
- Fix sporadic query failure #raw("Partition no longer exists") when working with wide tables using a AWS Glue catalog as metastore. \(#issue("10696", "https://github.com/trinodb/trino/issues/10696")\)
- Fix #raw("SHOW TABLES") failure when #raw("hive.hide-delta-lake-tables") is enabled, and Glue metastore references the table with no properties. \(#issue("10864", "https://github.com/trinodb/trino/issues/10864")\)

== Iceberg connector

- Fix query failure when reading from a table that underwent partitioning evolution. \(#issue("10770", "https://github.com/trinodb/trino/issues/10770")\)
- Fix data corruption when writing Parquet files. \(#issue("9749", "https://github.com/trinodb/trino/issues/9749")\)

== MySQL connector

- Remove the legacy #raw("allow-drop-table") configuration property. This defaulted to #raw("false"), which disallowed dropping tables, but other modifications were still allowed. Use #link(label("doc-security-built-in-system-access-control"))[System access control] instead, if desired. \(#issue("588", "https://github.com/trinodb/trino/issues/588")\)

== Oracle connector

- Remove the legacy #raw("allow-drop-table") configuration property. This defaulted to #raw("false"), which disallowed dropping tables, but other modifications were still allowed. Use #link(label("doc-security-built-in-system-access-control"))[System access control] instead, if desired. \(#issue("588", "https://github.com/trinodb/trino/issues/588")\)

== Phoenix connector

- Fix incorrect result when a #raw("date") value is older than or equal to #raw("1899-12-31"). \(#issue("10749", "https://github.com/trinodb/trino/issues/10749")\)

== PostgreSQL connector

- Remove the legacy #raw("allow-drop-table") configuration property. This defaulted to #raw("false"), which disallowed dropping tables, but other modifications were still allowed. Use #link(label("doc-security-built-in-system-access-control"))[System access control] instead, if desired. \(#issue("588", "https://github.com/trinodb/trino/issues/588")\)

== Redshift connector

- Remove the legacy #raw("allow-drop-table") configuration property. This defaulted to #raw("false"), which disallowed dropping tables, but other modifications were still allowed. Use #link(label("doc-security-built-in-system-access-control"))[System access control] instead, if desired. \(#issue("588", "https://github.com/trinodb/trino/issues/588")\)

== SingleStore \(MemSQL\) connector

- Remove the legacy #raw("allow-drop-table") configuration property. This defaulted to #raw("false"), which disallowed dropping tables, but other modifications were still allowed. Use #link(label("doc-security-built-in-system-access-control"))[System access control] instead, if desired. \(#issue("588", "https://github.com/trinodb/trino/issues/588")\)

== SQL Server connector

- Remove the legacy #raw("allow-drop-table") configuration property. This defaulted to #raw("false"), which disallowed dropping tables, but other modifications were still allowed. Use #link(label("doc-security-built-in-system-access-control"))[System access control] instead, if desired. \(#issue("588", "https://github.com/trinodb/trino/issues/588")\)

== SPI

- Allow null property names in #raw("ConnetorMetadata#setTableProperties"). \(#issue("10331", "https://github.com/trinodb/trino/issues/10331")\)
- Rename #raw("ConnectorNewTableLayout")  to #raw("ConnectorTableLayout"). \(#issue("10587", "https://github.com/trinodb/trino/issues/10587")\)
- Connectors no longer need to explicitly declare handle classes.  The #raw("ConnectorFactory.getHandleResolver") and #raw("Connector.getHandleResolver") methods are removed. \(#issue("10858", "https://github.com/trinodb/trino/issues/10858"), #issue("10872", "https://github.com/trinodb/trino/issues/10872")\)
- Remove unnecessary #raw("Block.writePositionTo") and #raw("BlockBuilder.appendStructure") methods. Use of these methods can be replaced with the existing #raw("Type.appendTo") or #raw("writeObject") methods. \(#issue("10602", "https://github.com/trinodb/trino/issues/10602")\)
