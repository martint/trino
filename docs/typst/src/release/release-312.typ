#import "/lib/trino-docs.typ": *

#anchor("doc-release-release-312")
= Release 312 \(29 May 2019\)

== General

- Fix incorrect results for queries using #raw("IS [NOT] DISTINCT FROM"). \(#issue("795", "https://github.com/trinodb/trino/issues/795")\)
- Fix #raw("array_distinct"), #raw("array_intersect") semantics with respect to indeterminate values \(i.e., #raw("NULL") or structural types containing #raw("NULL")\). \(#issue("559", "https://github.com/trinodb/trino/issues/559")\)
- Fix failure when the largest negative #raw("BIGINT") value \(#raw("-9223372036854775808")\) is used as a constant in a query. \(#issue("805", "https://github.com/trinodb/trino/issues/805")\)
- Improve reliability for network errors when using Kerberos with #link(label("doc-security-internal-communication"))[Secure internal communication]. \(#issue("838", "https://github.com/trinodb/trino/issues/838")\)
- Improve performance of #raw("JOIN") queries involving inline tables \(#raw("VALUES")\). \(#issue("743", "https://github.com/trinodb/trino/issues/743")\)
- Improve performance of queries containing duplicate expressions. \(#issue("730", "https://github.com/trinodb/trino/issues/730")\)
- Improve performance of queries involving comparisons between values of different types. \(#issue("731", "https://github.com/trinodb/trino/issues/731")\)
- Improve performance of queries containing redundant #raw("ORDER BY") clauses in subqueries. This may affect the semantics of queries that incorrectly rely on implementation-specific behavior. The old behavior can be restored via the #raw("skip_redundant_sort") session property or the #raw("optimizer.skip-redundant-sort") configuration property. \(#issue("818", "https://github.com/trinodb/trino/issues/818")\)
- Improve performance of #raw("IN") predicates that contain subqueries. \(#issue("767", "https://github.com/trinodb/trino/issues/767")\)
- Improve support for correlated subqueries containing redundant #raw("LIMIT") clauses. \(#issue("441", "https://github.com/trinodb/trino/issues/441")\)
- Add a new #link(label("ref-uuid-type"))[uuid-type] type to represent UUIDs. \(#issue("755", "https://github.com/trinodb/trino/issues/755")\)
- Add #link(label("fn-uuid"), raw("uuid")) function to generate random UUIDs. \(#issue("786", "https://github.com/trinodb/trino/issues/786")\)
- Add Phoenix connector. \(#issue("672", "https://github.com/trinodb/trino/issues/672")\)
- Make semantic error name available in client protocol. \(#issue("790", "https://github.com/trinodb/trino/issues/790")\)
- Report operator statistics when #raw("experimental.work-processor-pipelines") is enabled. \(#issue("788", "https://github.com/trinodb/trino/issues/788")\)

== Server

- Raise required Java version to 8u161. This version allows unlimited strength crypto. \(#issue("779", "https://github.com/trinodb/trino/issues/779")\)
- Show JVM configuration hint when JMX agent fails to start on Java 9+. \(#issue("838", "https://github.com/trinodb/trino/issues/838")\)
- Skip starting JMX agent on Java 9+ if it is already configured via JVM properties. \(#issue("838", "https://github.com/trinodb/trino/issues/838")\)
- Support configuring TrustStore for #link(label("doc-security-internal-communication"))[Secure internal communication] using the #raw("internal-communication.https.truststore.path") and #raw("internal-communication.https.truststore.key") configuration properties. The path can point at a Java KeyStore or a PEM file. \(#issue("785", "https://github.com/trinodb/trino/issues/785")\)
- Remove deprecated check for minimum number of workers before starting a coordinator.  Use the #raw("query-manager.required-workers") and #raw("query-manager.required-workers-max-wait") configuration properties instead. \(#issue("95", "https://github.com/trinodb/trino/issues/95")\)

== Hive connector

- Fix #raw("SHOW GRANTS") failure when metastore contains few tables. \(#issue("791", "https://github.com/trinodb/trino/issues/791")\)
- Fix failure reading from #raw("information_schema.table_privileges") table when metastore contains few tables. \(#issue("791", "https://github.com/trinodb/trino/issues/791")\)
- Use Hive naming convention for file names when writing to bucketed tables. \(#issue("822", "https://github.com/trinodb/trino/issues/822")\)
- Support new Hive bucketing conventions by allowing any number of files per bucket. This allows reading from partitions that were inserted into multiple times by Hive, or were written to by Hive on Tez \(which does not create files for empty buckets\).
- Allow disabling the creation of files for empty buckets when writing data. This behavior is enabled by  default for compatibility with previous versions of Presto, but can be disabled using the #raw("hive.create-empty-bucket-files") configuration property or the #raw("create_empty_bucket_files") session property. \(#issue("822", "https://github.com/trinodb/trino/issues/822")\)

== MySQL connector

- Map MySQL #raw("json") type to Presto #raw("json") type. \(#issue("824", "https://github.com/trinodb/trino/issues/824")\)

== PostgreSQL connector

- Add support for PostgreSQL's #raw("TIMESTAMP WITH TIME ZONE") data type. \(#issue("640", "https://github.com/trinodb/trino/issues/640")\)

== SPI

- Add support for pushing #raw("TABLESAMPLE") into connectors via the #raw("ConnectorMetadata.applySample()") method. \(#issue("753", "https://github.com/trinodb/trino/issues/753")\)
