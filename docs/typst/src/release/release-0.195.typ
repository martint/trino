#import "/lib/trino-docs.typ": *

#anchor("doc-release-release-0-195")
= Release 0.195

== General

- Fix #link(label("fn-histogram"), raw("histogram")) for map type when type coercion is required.
- Fix #raw("nullif") for map type when type coercion is required.
- Fix incorrect termination of queries when the coordinator to worker communication is under high load.
- Fix race condition that causes queries with a right or full outer join to fail.
- Change reference counting for varchar, varbinary, and complex types to be approximate. This approximation reduces GC activity when computing large aggregations with these types.
- Change communication system to be more resilient to issues such as long GC pauses or networking errors. The min\/max sliding scale of for timeouts has been removed and instead only max time is used. The #raw("exchange.min-error-duration") and #raw("query.remote-task.min-error-duration") are now ignored and will be removed in a future release.
- Increase coordinator timeout for cleanup of worker tasks for failed queries.  This improves the health of the system when workers are offline for long periods due to GC or network errors.
- Remove the #raw("compiler.interpreter-enabled") config property.

== Security

- Presto now supports generic password authentication using a pluggable #link(label("doc-develop-password-authenticator"))[Password authenticator]. Enable password authentication by setting #raw("http-server.authentication.type") to include #raw("PASSWORD") as an authentication type.
- #link(label("doc-security-ldap"))[LDAP authentication] is now implemented as a password authentication plugin. You will need to update your configuration if you are using it.

== CLI and JDBC

- Provide a better error message when TLS client certificates are expired or not yet valid.

== MySQL

- Fix an error that can occur while listing tables if one of the listed tables is dropped.

== Hive

- Add support for LZ4 compressed ORC files.
- Add support for reading Zstandard compressed ORC files.
- Validate ORC compression block size when reading ORC files.
- Set timeout of Thrift metastore client. This was accidentally removed in 0.191.

== MySQL, Redis, Kafka, and MongoDB

- Fix failure when querying #raw("information_schema.columns") when there is no equality predicate on #raw("table_name").
