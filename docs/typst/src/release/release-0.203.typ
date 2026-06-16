#import "/lib/trino-docs.typ": *

#anchor("doc-release-release-0-203")
= Release 0.203

== General

- Fix spurious duplicate key errors from #link(label("fn-map"), raw("map")).
- Fix planning failure when a correlated subquery containing a #raw("LIMIT") clause is used within #raw("EXISTS") \(#issue("10696", "https://github.com/prestodb/presto/issues/10696")\).
- Fix out of memory error caused by missing pushback checks in data exchanges.
- Fix execution failure for queries containing a cross join when using bucketed execution.
- Fix execution failure for queries containing an aggregation function with #raw("DISTINCT") and a highly selective aggregation filter. For example: #raw("sum(DISTINCT x) FILTER (WHERE y = 0)")
- Fix quoting in error message for #raw("SHOW PARTITIONS").
- Eliminate redundant calls to check column access permissions.
- Improve query creation reliability by delaying query start until the client acknowledges the query ID by fetching the first response link. This eliminates timeouts during the initial request for queries that take a long time to analyze.
- Remove support for legacy #raw("ORDER BY") semantics.
- Distinguish between inner and left spatial joins in explain plans.

== Security

- Fix sending authentication challenge when at least two of the #raw("KERBEROS"), #raw("PASSWORD"), or #raw("JWT") authentication types are configured.
- Allow using PEM encoded \(PKCS \#8\) keystore and truststore with the HTTP server and the HTTP client used for internal communication. This was already supported for the CLI and JDBC driver.

== Server RPM

- Declare a dependency on #raw("uuidgen"). The #raw("uuidgen") program is required during installation of the Presto server RPM package and lack of it resulted in an invalid config file being generated during installation.

== Hive connector

- Fix complex type handling in the optimized Parquet reader. Previously, null values, optional fields, and Parquet backward compatibility rules were not handled correctly.
- Fix an issue that could cause the optimized ORC writer to fail with a #raw("LazyBlock") error.
- Improve error message for max open writers.

== Thrift connector

- Fix retry of requests when the remote Thrift server indicates that the error is retryable.

== Local file connector

- Fix parsing of timestamps when the JVM time zone is UTC \(#issue("9601", "https://github.com/prestodb/presto/issues/9601")\).
