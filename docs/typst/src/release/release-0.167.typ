#import "/lib/trino-docs.typ": *

#anchor("doc-release-release-0-167")
= Release 0.167

== General

- Fix planning failure when a window function depends on the output of another window function.
- Fix planning failure for certain aggregation with both #raw("DISTINCT") and #raw("GROUP BY").
- Fix incorrect aggregation of operator summary statistics.
- Fix a join issue that could cause joins that produce and filter many rows to monopolize worker threads, even after the query has finished.
- Expand plan predicate pushdown capabilities involving implicitly coerced types.
- Short-circuit inner and right join when right side is empty.
- Optimize constant patterns for #raw("LIKE") predicates that use an escape character.
- Validate escape sequences in #raw("LIKE") predicates per the SQL standard.
- Reduce memory usage of #link(label("fn-min-by"), raw("min_by")) and #link(label("fn-max-by"), raw("max_by")).
- Add #link(label("fn-transform-keys"), raw("transform_keys")), #link(label("fn-transform-values"), raw("transform_values")) and #link(label("fn-zip-with"), raw("zip_with")) lambda functions.
- Add #link(label("fn-levenshtein-distance"), raw("levenshtein_distance")) function.
- Add JMX stat for the elapsed time of the longest currently active split.
- Add JMX stats for compiler caches.
- Raise required Java version to 8u92.

== Security

- The #raw("http.server.authentication.enabled") config option that previously enabled Kerberos has been replaced with #raw("http-server.authentication.type=KERBEROS").
- Add support for #link(label("doc-security-ldap"))[LDAP authentication] using username and password.
- Add a read-only #link(label("doc-develop-system-access-control"))[System access control] named #raw("read-only").
- Allow access controls to filter the results of listing catalogs, schemas and tables.
- Add access control checks for #link(label("doc-sql-show-schemas"))[SHOW SCHEMAS] and #link(label("doc-sql-show-tables"))[SHOW TABLES].

== Web UI

- Add operator-level performance analysis.
- Improve visibility of blocked and reserved query states.
- Lots of minor improvements.

== JDBC driver

- Allow escaping in #raw("DatabaseMetaData") patterns.

== Hive

- Fix write operations for #raw("ViewFileSystem") by using a relative location.
- Remove support for the #raw("hive-cdh4") and #raw("hive-hadoop1") connectors which support CDH 4 and Hadoop 1.x, respectively.
- Remove the #raw("hive-cdh5") connector as an alias for #raw("hive-hadoop2").
- Remove support for the legacy S3 block-based file system.
- Add support for KMS-managed keys for S3 server-side encryption.

== Cassandra

- Add support for Cassandra 3.x by removing the deprecated Thrift interface used to connect to Cassandra. The following config options are now defunct and must be removed: #raw("cassandra.thrift-port"), #raw("cassandra.thrift-connection-factory-class"), #raw("cassandra.transport-factory-options") and #raw("cassandra.partitioner").

== SPI

- Add methods to #raw("SystemAccessControl") and #raw("ConnectorAccessControl") to filter the list of catalogs, schemas and tables.
- Add access control checks for #link(label("doc-sql-show-schemas"))[SHOW SCHEMAS] and #link(label("doc-sql-show-tables"))[SHOW TABLES].
- Add #raw("beginQuery") and #raw("cleanupQuery") notifications to #raw("ConnectorMetadata").
