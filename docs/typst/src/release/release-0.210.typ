#import "/lib/trino-docs.typ": *

#anchor("doc-release-release-0-210")
= Release 0.210

== General

- Fix planning failure when aliasing columns of tables containing hidden columns \(#issue("11385", "https://github.com/prestodb/presto/issues/11385")\).
- Fix correctness issue when #raw("GROUP BY DISTINCT") terms contain references to the same column using different syntactic forms \(#issue("11120", "https://github.com/prestodb/presto/issues/11120")\).
- Fix failures when querying #raw("information_schema") tables using capitalized names.
- Improve performance when converting between #raw("ROW") types.
- Remove user CPU time tracking as introduces non-trivial overhead.
- Select join distribution type automatically for queries involving outer joins.

== Hive connector

- Fix a security bug introduced in 0.209 when using #raw("hive.security=file"), which would allow any user to create, drop, or rename schemas.
- Prevent ORC writer from writing stripes larger than the max configured size when converting a highly dictionary compressed column to direct encoding.
- Support creating Avro tables with a custom schema using the #raw("avro_schema_url") table property.
- Support backward compatible Avro schema evolution.
- Support cross-realm Kerberos authentication for HDFS and Hive Metastore.

== JDBC driver

- Deallocate prepared statement when #raw("PreparedStatement") is closed. Previously, #raw("Connection") became unusable after many prepared statements were created.
- Remove #raw("getUserTimeMillis()") from #raw("QueryStats") and #raw("StageStats").

== SPI

- #raw("SystemAccessControl.checkCanSetUser()") now takes an #raw("Optional<Principal>") rather than a nullable #raw("Principal").
- Rename #raw("connectorId") to #raw("catalogName") in #raw("ConnectorFactory"), #raw("QueryInputMetadata"), and #raw("QueryOutputMetadata").
- Pass #raw("ConnectorTransactionHandle") to #raw("ConnectorAccessControl.checkCanSetCatalogSessionProperty()").
- Remove #raw("getUserTime()") from #raw("SplitStatistics") \(referenced in #raw("SplitCompletedEvent")\).

#note[
These are backwards incompatible changes with the previous SPI. If you have written a plugin, you will need to update your code before deploying this release.
]
