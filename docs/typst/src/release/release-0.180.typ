#import "/lib/trino-docs.typ": *

#anchor("doc-release-release-0-180")
= Release 0.180

== General

- Fix a rare bug where rows containing only #raw("null") values are not returned to the client. This only occurs when an entire result page contains only #raw("null") values. The only known case is a query over an ORC encoded Hive table that does not perform any transformation of the data.
- Fix incorrect results when performing comparisons between values of approximate data types \(#raw("REAL"), #raw("DOUBLE")\) and columns of certain exact numeric types \(#raw("INTEGER"), #raw("BIGINT"), #raw("DECIMAL")\).
- Fix memory accounting for #link(label("fn-min-by"), raw("min_by")) and #link(label("fn-max-by"), raw("max_by")) on complex types.
- Fix query failure due to #raw("NoClassDefFoundError") when scalar functions declared in plugins are implemented with instance methods.
- Improve performance of map subscript from O\(n\) to O\(1\) in all cases. Previously, only maps produced by certain functions and readers could take advantage of this improvement.
- Skip unknown costs in #raw("EXPLAIN") output.
- Support #link(label("doc-security-internal-communication"))[Secure internal communication] between Presto nodes.
- Add initial support for #raw("CROSS JOIN") against #raw("LATERAL") derived tables.
- Add support for #raw("VARBINARY") concatenation.
- Add #link(label("doc-connector-thrift"))[Thrift connector] that makes it possible to use Presto with external systems without the need to implement a custom connector.
- Add experimental #raw("/v1/resourceGroupState") REST endpoint on coordinator.

== Hive

- Fix skipping short decimal values in the optimized Parquet reader when they are backed by the #raw("int32") or #raw("int64") types.
- Ignore partition bucketing if table is not bucketed. This allows dropping the bucketing from table metadata but leaving it for old partitions.
- Improve error message for Hive partitions dropped during execution.
- The optimized RCFile writer is enabled by default, but can be disabled with the #raw("hive.rcfile-optimized-writer.enabled") config option. The writer supports validation which reads back the entire file after writing. Validation is disabled by default, but can be enabled with the #raw("hive.rcfile.writer.validate") config option.

== Cassandra

- Add support for #raw("INSERT").
- Add support for pushdown of non-equality predicates on clustering keys.

== JDBC driver

- Add support for authenticating using Kerberos.
- Allow configuring SSL\/TLS and Kerberos properties on a per-connection basis.
- Add support for executing queries using a SOCKS or HTTP proxy.

== CLI

- Add support for executing queries using an HTTP proxy.

== SPI

- Add running time limit and queued time limit to #raw("ResourceGroupInfo").
