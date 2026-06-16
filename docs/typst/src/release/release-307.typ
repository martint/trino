#import "/lib/trino-docs.typ": *

#anchor("doc-release-release-307")
= Release 307 \(3 Apr 2019\)

== General

- Fix cleanup of spill files for queries using window functions or #raw("ORDER BY"). \(#issue("543", "https://github.com/trinodb/trino/issues/543")\)
- Optimize queries containing #raw("ORDER BY") together with #raw("LIMIT") over an #raw("OUTER JOIN") by pushing #raw("ORDER BY") and #raw("LIMIT") to the outer side of the join. \(#issue("419", "https://github.com/trinodb/trino/issues/419")\)
- Improve performance of table scans for data sources that produce tiny pages. \(#issue("467", "https://github.com/trinodb/trino/issues/467")\)
- Improve performance of #raw("IN") subquery expressions that contain a #raw("DISTINCT") clause. \(#issue("551", "https://github.com/trinodb/trino/issues/551")\)
- Expand support of types handled in #raw("EXPLAIN (TYPE IO)"). \(#issue("509", "https://github.com/trinodb/trino/issues/509")\)
- Add support for outer joins involving lateral derived tables \(i.e., #raw("LATERAL")\). \(#issue("390", "https://github.com/trinodb/trino/issues/390")\)
- Add support for setting table comments via the #link(label("doc-sql-comment"))[COMMENT] syntax. \(#issue("200", "https://github.com/trinodb/trino/issues/200")\)

== Web UI

- Allow UI to work when opened as #raw("/ui") \(no trailing slash\). \(#issue("500", "https://github.com/trinodb/trino/issues/500")\)

== Security

- Make query result and cancellation URIs secure. Previously, an authenticated user could potentially steal the result data of any running query. \(#issue("561", "https://github.com/trinodb/trino/issues/561")\)

== Server RPM

- Prevent JVM from allocating large amounts of native memory. The new configuration is applied automatically when Presto is installed from RPM. When Presto is installed another way, or when you provide your own #raw("jvm.config"), we recommend adding #raw("-Djdk.nio.maxCachedBufferSize=2000000") to your #raw("jvm.config"). See #link(label("doc-installation-deployment"))[Deploying Trino] for details. \(#issue("542", "https://github.com/trinodb/trino/issues/542")\)

== CLI

- Always abort query in batch mode when CLI is killed. \(#issue("508", "https://github.com/trinodb/trino/issues/508"), #issue("580", "https://github.com/trinodb/trino/issues/580")\)

== JDBC driver

- Abort query synchronously when the #raw("ResultSet") is closed or when the #raw("Statement") is cancelled. Previously, the abort was sent in the background, allowing the JVM to exit before the abort was received by the server. \(#issue("580", "https://github.com/trinodb/trino/issues/580")\)

== Hive connector

- Add safety checks for Hive bucketing version. Hive 3.0 introduced a new bucketing version that uses an incompatible hash function. The Hive connector will treat such tables as not bucketed when reading and disallows writing. \(#issue("512", "https://github.com/trinodb/trino/issues/512")\)
- Add support for setting table comments via the #link(label("doc-sql-comment"))[COMMENT] syntax. \(#issue("200", "https://github.com/trinodb/trino/issues/200")\)

== Other connectors

These changes apply to the MySQL, PostgreSQL, Redshift, and SQL Server connectors.

- Fix reading and writing of #raw("timestamp") values. Previously, an incorrect value could be read, depending on the Presto JVM time zone. \(#issue("495", "https://github.com/trinodb/trino/issues/495")\)
- Add support for using a client-provided username and password. The credential names can be configured using the #raw("user-credential-name") and #raw("password-credential-name") configuration properties. \(#issue("482", "https://github.com/trinodb/trino/issues/482")\)

== SPI

- #raw("LongDecimalType") and #raw("IpAddressType") now use #raw("Int128ArrayBlock") instead of #raw("FixedWithBlock"). Any code that creates blocks directly, rather than using the #raw("BlockBuilder") returned from the #raw("Type"), will need to be updated. \(#issue("492", "https://github.com/trinodb/trino/issues/492")\)
- Remove #raw("FixedWidthBlock"). Use one of the #raw("*ArrayBlock") classes instead. \(#issue("492", "https://github.com/trinodb/trino/issues/492")\)
- Add support for simple constraint pushdown into connectors via the #raw("ConnectorMetadata.applyFilter()") method. \(#issue("541", "https://github.com/trinodb/trino/issues/541")\)
