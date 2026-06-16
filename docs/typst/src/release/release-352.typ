#import "/lib/trino-docs.typ": *

#anchor("doc-release-release-352")
= Release 352 \(9 Feb 2021\)

== General

- Add support for #link(label("ref-window-clause"))[#raw("WINDOW") clause]. \(#issue("651", "https://github.com/trinodb/trino/issues/651")\)
- Add support for #link(label("doc-sql-update"))[UPDATE]. \(#issue("5861", "https://github.com/trinodb/trino/issues/5861")\)
- Add #link(label("fn-version"), raw("version")) function. \(#issue("4627", "https://github.com/trinodb/trino/issues/4627")\)
- Allow prepared statement parameters for #raw("SHOW STATS"). \(#issue("6582", "https://github.com/trinodb/trino/issues/6582")\)
- Update tzdata version to 2020d. As a result, queries can no longer reference the #raw("US/Pacific-New") zone, as it has been removed. \(#issue("6660", "https://github.com/trinodb/trino/issues/6660")\)
- Add #raw("plan-with-table-node-partitioning") feature config that corresponds to existing #raw("plan_with_table_node_partitioning") session property. \(#issue("6811", "https://github.com/trinodb/trino/issues/6811")\)
- Improve performance of queries using #link(label("fn-rank"), raw("rank()")) window function. \(#issue("6333", "https://github.com/trinodb/trino/issues/6333")\)
- Improve performance of #link(label("fn-sum"), raw("sum")) and #link(label("fn-avg"), raw("avg")) for #raw("decimal") types. \(#issue("6951", "https://github.com/trinodb/trino/issues/6951")\)
- Improve join performance. \(#issue("5981", "https://github.com/trinodb/trino/issues/5981")\)
- Improve query planning time for queries using range predicates or large #raw("IN") lists. \(#issue("6544", "https://github.com/trinodb/trino/issues/6544")\)
- Fix window and streaming aggregation semantics regarding peer rows. Now peer rows are grouped using #raw("IS NOT DISTINCT FROM") instead of the #raw("=") operator. \(#issue("6472", "https://github.com/trinodb/trino/issues/6472")\)
- Fix query failure when using an element of #raw("array(timestamp(p))") in a complex expression for #raw("p") greater than 6. \(#issue("6350", "https://github.com/trinodb/trino/issues/6350")\)
- Fix failure when using geospatial functions in a join clause and #raw("spatial_partitioning_table_name") is set. \(#issue("6587", "https://github.com/trinodb/trino/issues/6587")\)
- Fix #raw("CREATE TABLE AS") failure when source table has hidden columns. \(#issue("6835", "https://github.com/trinodb/trino/issues/6835")\)

== Security

- Allow configuring HTTP client used for OAuth2 authentication. \(#issue("6600", "https://github.com/trinodb/trino/issues/6600")\)
- Add token polling client API for OAuth2 authentication. \(#issue("6625", "https://github.com/trinodb/trino/issues/6625")\)
- Support JWK with certificate chain for OAuth2 authorization. \(#issue("6428", "https://github.com/trinodb/trino/issues/6428")\)
- Add scopes to OAuth2 configuration. \(#issue("6580", "https://github.com/trinodb/trino/issues/6580")\)
- Optionally verify JWT audience \(#raw("aud")\) field for OAuth2 authentication. \(#issue("6501", "https://github.com/trinodb/trino/issues/6501")\)
- Guard against replay attacks in OAuth2 by using #raw("nonce") cookie when #raw("openid") scope is requested. \(#issue("6580", "https://github.com/trinodb/trino/issues/6580")\)

== JDBC driver

- Add OAuth2 authentication. \(#issue("6576", "https://github.com/trinodb/trino/issues/6576")\)
- Support user impersonation when using password-based authentication using the new #raw("sessionUser") parameter. \(#issue("6549", "https://github.com/trinodb/trino/issues/6549")\)

== Docker image

- Remove support for configuration directory #raw("/usr/lib/trino/etc"). The configuration should be provided in #raw("/etc/trino"). \(#issue("6497", "https://github.com/trinodb/trino/issues/6497")\)

== CLI

- Support user impersonation when using password-based authentication using the #raw("--session-user") command line option. \(#issue("6567", "https://github.com/trinodb/trino/issues/6567")\)

== BigQuery connector

- Add a #raw("view_definition") system table which exposes BigQuery view definitions. \(#issue("3687", "https://github.com/trinodb/trino/issues/3687")\)
- Fix query failure when calculating #raw("count(*)") aggregation on a view more than once, without any filter. \(#issue("6706", "https://github.com/trinodb/trino/issues/6706")\).

== Hive connector

- Add #raw("UPDATE") support for ACID tables. \(#issue("5861", "https://github.com/trinodb/trino/issues/5861")\)
- Match columns by index rather than by name by default for ORC ACID tables. \(#issue("6479", "https://github.com/trinodb/trino/issues/6479")\)
- Match columns by name rather than by index by default for Parquet files. This can be changed using #raw("hive.parquet.use-column-names") configuration property and #raw("parquet_use_column_names") session property. \(#issue("6479", "https://github.com/trinodb/trino/issues/6479")\)
- Remove the #raw("hive.partition-use-column-names") configuration property and the #raw("partition_use_column_names ") session property. This is now determined automatically. \(#issue("6479", "https://github.com/trinodb/trino/issues/6479")\)
- Support timestamps with microsecond or nanosecond precision \(as configured with #raw("hive.timestamp-precision") property\) nested within #raw("array"), #raw("map") or #raw("struct") data types. \(#issue("5195", "https://github.com/trinodb/trino/issues/5195")\)
- Support reading from table in Sequencefile format that uses LZO compression. \(#issue("6452", "https://github.com/trinodb/trino/issues/6452")\)
- Expose AWS HTTP Client stats via JMX. \(#issue("6503", "https://github.com/trinodb/trino/issues/6503")\)
- Allow specifying S3 KMS Key ID used for client side encryption via security mapping config and extra credentials. \(#issue("6802", "https://github.com/trinodb/trino/issues/6802")\)
- Fix writing incorrect #raw("timestamp") values within #raw("row"), #raw("array") or #raw("map") when using Parquet file format. \(#issue("6760", "https://github.com/trinodb/trino/issues/6760")\)
- Fix possible S3 connection leak on query failure. \(#issue("6849", "https://github.com/trinodb/trino/issues/6849")\)

== Iceberg connector

- Add #raw("iceberg.max-partitions-per-writer") config property to allow configuring the limit on partitions per writer. \(#issue("6650", "https://github.com/trinodb/trino/issues/6650")\)
- Optimize cardinality-insensitive aggregations \(#link(label("fn-max"), raw("max")), #link(label("fn-min"), raw("min")), #raw("distinct"), #link(label("fn-approx-distinct"), raw("approx_distinct"))\) over identity partition columns with #raw("optimizer.optimize-metadata-queries") config property or #raw("optimize_metadata_queries") session property. \(#issue("5199", "https://github.com/trinodb/trino/issues/5199")\)
- Provide #raw("use_file_size_from_metadata") catalog session property and #raw("iceberg.use-file-size-from-metadata") config property to fix query failures on tables with wrong file sizes stored in the metadata. \(#issue("6369", "https://github.com/trinodb/trino/issues/6369")\)
- Fix the mapping of nested fields between table metadata and ORC file metadata. This enables evolution of #raw("row") typed columns for Iceberg tables stored in ORC. \(#issue("6520", "https://github.com/trinodb/trino/issues/6520")\)

== Kinesis connector

- Support GZIP message compression. \(#issue("6442", "https://github.com/trinodb/trino/issues/6442")\)

== MySQL connector

- Improve performance for certain complex queries involving aggregation and predicates \(e.g. #raw("HAVING") clause\) by pushing the aggregation and predicates computation into the remote database. \(#issue("6667", "https://github.com/trinodb/trino/issues/6667")\)
- Improve performance for certain queries using #raw("stddev_pop"), #raw("stddev_samp"), #raw("var_pop"), #raw("var_samp") aggregation functions by pushing the aggregation and predicates computation into the remote database. \(#issue("6673", "https://github.com/trinodb/trino/issues/6673")\)

== PostgreSQL connector

- Improve performance for certain complex queries involving aggregation and predicates \(e.g. #raw("HAVING") clause\) by pushing the aggregation and predicates computation into the remote database. \(#issue("6667", "https://github.com/trinodb/trino/issues/6667")\)
- Improve performance for certain queries using #raw("stddev_pop"), #raw("stddev_samp"), #raw("var_pop"), #raw("var_samp"), #raw("covar_pop"), #raw("covar_samp"), #raw("corr"), #raw("regr_intercept"), #raw("regr_slope") aggregation functions by pushing the aggregation and predicates computation into the remote database. \(#issue("6731", "https://github.com/trinodb/trino/issues/6731")\)

== Redshift connector

- Use the Redshift JDBC driver to access Redshift. As a result, #raw("connection-url") in catalog configuration files needs to be updated from #raw("jdbc:postgresql:...") to #raw("jdbc:redshift:..."). \(#issue("6465", "https://github.com/trinodb/trino/issues/6465")\)

== SQL Server connector

- Avoid query failures due to transaction deadlocks in SQL Server by using transaction snapshot isolation. \(#issue("6274", "https://github.com/trinodb/trino/issues/6274")\)
- Honor precision of SQL Server's #raw("datetime2") type . \(#issue("6654", "https://github.com/trinodb/trino/issues/6654")\)
- Add support for Trino #raw("timestamp") type in #raw("CREATE TABLE") statement, by mapping it to SQL Server's #raw("datetime2") type. Previously, it was incorrectly mapped to SQL Server's #raw("timestamp") type. \(#issue("6654", "https://github.com/trinodb/trino/issues/6654")\)
- Add support for the #raw("time") type. \(#issue("6654", "https://github.com/trinodb/trino/issues/6654")\)
- Improve performance for certain complex queries involving aggregation and predicates \(e.g. #raw("HAVING") clause\) by pushing the aggregation and predicates computation into the remote database. \(#issue("6667", "https://github.com/trinodb/trino/issues/6667")\)
- Fix failure when querying tables having indexes and constraints. \(#issue("6464", "https://github.com/trinodb/trino/issues/6464")\)

== SPI

- Add support for join pushdown via the #raw("ConnectorMetadata.applyJoin()") method. \(#issue("6752", "https://github.com/trinodb/trino/issues/6752")\)
