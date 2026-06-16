#import "/lib/trino-docs.typ": *

#anchor("doc-release-release-334")
= Release 334 \(29 May 2020\)

== General

- Fix incorrect query results for certain queries involving comparisons of #raw("real") and #raw("double") types when values include negative zero. \(#issue("3745", "https://github.com/trinodb/trino/issues/3745")\)
- Fix failure when querying an empty table with late materialization enabled. \(#issue("3577", "https://github.com/trinodb/trino/issues/3577")\)
- Fix failure when the inputs to #raw("UNNEST") are repeated. \(#issue("3587", "https://github.com/trinodb/trino/issues/3587")\)
- Fix failure when an aggregation is used in the arguments to #link(label("fn-format"), raw("format")). \(#issue("3829", "https://github.com/trinodb/trino/issues/3829")\)
- Fix #link(label("fn-localtime"), raw("localtime")) and #link(label("fn-current-time"), raw("current_time")) for session zones with DST or with historical offset changes in legacy \(default\) timestamp semantics. \(#issue("3846", "https://github.com/trinodb/trino/issues/3846"), #issue("3850", "https://github.com/trinodb/trino/issues/3850")\)
- Fix dynamic filter failures in complex spatial join queries. \(#issue("3694", "https://github.com/trinodb/trino/issues/3694")\)
- Improve performance of queries involving #link(label("fn-row-number"), raw("row_number")). \(#issue("3614", "https://github.com/trinodb/trino/issues/3614")\)
- Improve performance of queries containing #raw("LIKE") predicate. \(#issue("3618", "https://github.com/trinodb/trino/issues/3618")\)
- Improve query performance when dynamic filtering is enabled. \(#issue("3632", "https://github.com/trinodb/trino/issues/3632")\)
- Improve performance for queries that read fields from nested structures. \(#issue("2672", "https://github.com/trinodb/trino/issues/2672")\)
- Add variant of #link(label("fn-random"), raw("random")) function that produces a number in the provided range. \(#issue("1848", "https://github.com/trinodb/trino/issues/1848")\)
- Show distributed plan by default in #link(label("doc-sql-explain"))[EXPLAIN]. \(#issue("3724", "https://github.com/trinodb/trino/issues/3724")\)
- Add #link(label("doc-connector-oracle"))[Oracle connector]. \(#issue("1959", "https://github.com/trinodb/trino/issues/1959")\)
- Add #link(label("doc-connector-pinot"))[Pinot connector]. \(#issue("2028", "https://github.com/trinodb/trino/issues/2028")\)
- Add #link(label("doc-connector-prometheus"))[Prometheus connector]. \(#issue("2321", "https://github.com/trinodb/trino/issues/2321")\)
- Add support for standards compliant \(#link("https://www.rfc-editor.org/rfc/rfc7239")[RFC 7239]\) HTTP forwarded headers. Processing of HTTP forwarded headers is now controlled by the #raw("http-server.process-forwarded") configuration property, and the old #raw("http-server.authentication.allow-forwarded-https") and #raw("dispatcher.forwarded-header") configuration properties are no longer supported. \(#issue("3714", "https://github.com/trinodb/trino/issues/3714")\)
- Add pluggable #link(label("doc-develop-certificate-authenticator"))[Certificate authenticator]. \(#issue("3804", "https://github.com/trinodb/trino/issues/3804")\)

== JDBC driver

- Implement #raw("toString()") for #raw("java.sql.Array") results. \(#issue("3803", "https://github.com/trinodb/trino/issues/3803")\)

== CLI

- Improve rendering of elapsed time for short queries. \(#issue("3311", "https://github.com/trinodb/trino/issues/3311")\)

== Web UI

- Add #raw("fixed"), #raw("certificate"), #raw("JWT"), and #raw("Kerberos") to UI authentication. \(#issue("3433", "https://github.com/trinodb/trino/issues/3433")\)
- Show join distribution type in Live Plan. \(#issue("1323", "https://github.com/trinodb/trino/issues/1323")\)

== JDBC driver

- Improve performance of #raw("DatabaseMetaData.getColumns()") when the parameters contain unescaped #raw("%") or #raw("_"). \(#issue("1620", "https://github.com/trinodb/trino/issues/1620")\)

== Elasticsearch connector

- Fix failure when executing #raw("SHOW CREATE TABLE"). \(#issue("3718", "https://github.com/trinodb/trino/issues/3718")\)
- Improve performance for #raw("count(*)") queries. \(#issue("3512", "https://github.com/trinodb/trino/issues/3512")\)
- Add support for raw Elasticsearch queries. \(#issue("3735", "https://github.com/trinodb/trino/issues/3735")\)

== Hive connector

- Fix matching bucket filenames without leading zeros. \(#issue("3702", "https://github.com/trinodb/trino/issues/3702")\)
- Fix creation of external tables using #raw("CREATE TABLE AS"). Previously, the tables were created as managed and with the default location. \(#issue("3755", "https://github.com/trinodb/trino/issues/3755")\)
- Fix incorrect table statistics for newly created external tables. \(#issue("3819", "https://github.com/trinodb/trino/issues/3819")\)
- Prevent Presto from starting when cache fails to initialize. \(#issue("3749", "https://github.com/trinodb/trino/issues/3749")\)
- Fix race condition that could cause caching to be permanently disabled. \(#issue("3729", "https://github.com/trinodb/trino/issues/3729"), #issue("3810", "https://github.com/trinodb/trino/issues/3810")\)
- Fix malformed reads when asynchronous read mode for caching is enabled. \(#issue("3772", "https://github.com/trinodb/trino/issues/3772")\)
- Fix eviction of cached data while still under size eviction threshold. \(#issue("3772", "https://github.com/trinodb/trino/issues/3772")\)
- Improve performance when creating unpartitioned external tables over large data sets. \(#issue("3624", "https://github.com/trinodb/trino/issues/3624")\)
- Leverage Parquet file statistics when reading decimal columns. \(#issue("3581", "https://github.com/trinodb/trino/issues/3581")\)
- Change type of #raw("$file_modified_time") hidden column from #raw("bigint") to #raw("timestamp with timezone type"). \(#issue("3611", "https://github.com/trinodb/trino/issues/3611")\)
- Add caching support for HDFS and Azure file systems. \(#issue("3772", "https://github.com/trinodb/trino/issues/3772")\)
- Fix S3 connection pool depletion when asynchronous read mode for caching is enabled. \(#issue("3772", "https://github.com/trinodb/trino/issues/3772")\)
- Disable caching on coordinator by default. \(#issue("3820", "https://github.com/trinodb/trino/issues/3820")\)
- Use asynchronous read mode for caching by default. \(#issue("3799", "https://github.com/trinodb/trino/issues/3799")\)
- Cache delegation token for Hive thrift metastore. This can be configured with the #raw("hive.metastore.thrift.delegation-token.cache-ttl") and #raw("hive.metastore.thrift.delegation-token.cache-maximum-size") configuration properties. \(#issue("3771", "https://github.com/trinodb/trino/issues/3771")\)

== MemSQL connector

- Include #link(label("doc-connector-singlestore"))[SingleStore connector] in the server tarball and RPM. \(#issue("3743", "https://github.com/trinodb/trino/issues/3743")\)

== MongoDB connector

- Support case insensitive database and collection names. This can be enabled with the #raw("mongodb.case-insensitive-name-matching") configuration property. \(#issue("3453", "https://github.com/trinodb/trino/issues/3453")\)

== SPI

- Allow a #raw("SystemAccessControl") to provide an #raw("EventListener"). \(#issue("3629", "https://github.com/trinodb/trino/issues/3629")\).
