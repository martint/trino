#import "/lib/trino-docs.typ": *

#anchor("doc-release-release-0-189")
= Release 0.189

== General

- Fix query failure while logging the query plan.
- Fix a bug that causes clients to hang when executing #raw("LIMIT") queries when #raw("optimizer.force-single-node-output") is disabled.
- Fix a bug in the #link(label("fn-bing-tile-at"), raw("bing_tile_at")) and #link(label("fn-bing-tile-polygon"), raw("bing_tile_polygon")) functions where incorrect results were produced for points close to tile edges.
- Fix variable resolution when lambda argument has the same name as a table column.
- Improve error message when running #raw("SHOW TABLES") on a catalog that does not exist.
- Improve performance for queries with highly selective filters.
- Execute #link(label("doc-sql-use"))[USE] on the server rather than in the CLI, allowing it to be supported by any client. This requires clients to add support for the protocol changes \(otherwise the statement will be silently ignored\).
- Allow casting #raw("JSON") to #raw("ROW") even if the #raw("JSON") does not contain every field in the #raw("ROW").
- Add support for dereferencing row fields in lambda expressions.

== Security

- Support configuring multiple authentication types, which allows supporting clients that have different authentication requirements or gracefully migrating between authentication types without needing to update all clients at once. Specify multiple values for #raw("http-server.authentication.type"), separated with commas.
- Add support for TLS client certificates as an authentication mechanism by specifying #raw("CERTIFICATE") for #raw("http-server.authentication.type"). The distinguished name from the validated certificate will be provided as a #raw("javax.security.auth.x500.X500Principal"). The certificate authority \(CA\) used to sign client certificates will be need to be added to the HTTP server KeyStore \(should technically be a TrustStore but separating them out is not yet supported\).
- Skip sending final leg of SPNEGO authentication when using Kerberos.

== JDBC driver

- Per the JDBC specification, close the #raw("ResultSet") when #raw("Statement") is closed.
- Add support for TLS client certificate authentication by configuring the #raw("SSLKeyStorePath") and #raw("SSLKeyStorePassword") parameters.
- Add support for transactions using SQL statements or the standard JDBC mechanism.
- Allow executing the #raw("USE") statement. Note that this is primarily useful when running arbitrary SQL on behalf of users. For programmatic use, continuing to use #raw("setCatalog()") and #raw("setSchema()") on #raw("Connection") is recommended.
- Allow executing #raw("SET SESSION") and #raw("RESET SESSION").

== Resource group

- Add #raw("WEIGHTED_FAIR") resource group scheduling policy.

== Hive

- Do not require setting #raw("hive.metastore.uri") when using the file metastore.
- Reduce memory usage when reading string columns from ORC or DWRF files.

== MySQL, PostgreSQL, Redshift, and SQL Server shanges

- Change mapping for columns with #raw("DECIMAL(p,s)") data type from Presto #raw("DOUBLE") type to the corresponding Presto #raw("DECIMAL") type.

== Kafka

- Fix documentation for raw decoder.

== Thrift connector

- Add support for index joins.

== SPI

- Deprecate #raw("SliceArrayBlock").
- Add #raw("SessionPropertyConfigurationManager") plugin to enable overriding default session properties dynamically.
