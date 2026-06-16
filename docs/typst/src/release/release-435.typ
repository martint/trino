#import "/lib/trino-docs.typ": *

#anchor("doc-release-release-435")
= Release 435 \(13 Dec 2023\)

== General

- Add support for the #raw("json_table") table function. \(#issue("18017", "https://github.com/trinodb/trino/issues/18017")\)
- Reduce coordinator memory usage. \(#issue("20018", "https://github.com/trinodb/trino/issues/20018"), #issue("20022", "https://github.com/trinodb/trino/issues/20022")\)
- Increase reliability and memory consumption of inserts. \(#issue("20040", "https://github.com/trinodb/trino/issues/20040")\)
- Fix incorrect results for #raw("LIKE") with some strings containing repeated substrings. \(#issue("20089", "https://github.com/trinodb/trino/issues/20089")\)
- Fix coordinator memory leak. \(#issue("20023", "https://github.com/trinodb/trino/issues/20023")\)
- Fix possible query failure for #raw("MERGE") queries when #raw("retry-policy") set to #raw("TASK") and #raw("query.determine-partition-count-for-write-enabled") set to #raw("true"). \(#issue("19979", "https://github.com/trinodb/trino/issues/19979")\)
- Prevent hanging query processing with #raw("retry.policy") set to #raw("TASK") when a worker node died. \(#issue("18603 ", "https://github.com/trinodb/trino/issues/18603 ")\)
- Fix query failure when reading array columns. \(#issue("20065", "https://github.com/trinodb/trino/issues/20065")\)

== Delta Lake connector

- #breaking-marker("../release.html#breaking-changes") Remove support for registering external tables with #raw("CREATE TABLE") and the #raw("location") table property. Use the #raw("register_table") procedure as replacement. The property #raw("delta.legacy-create-table-with-existing-location.enabled") is also removed. \(#issue("17016", "https://github.com/trinodb/trino/issues/17016")\)
- Improve query planning performance on Delta Lake tables. \(#issue("19795", "https://github.com/trinodb/trino/issues/19795")\)
- Ensure AWS access keys are used for connections to the AWS Security Token Service. \(#issue("19982", "https://github.com/trinodb/trino/issues/19982")\)
- Reduce memory usage for inserts into partitioned tables. \(#issue("19649", "https://github.com/trinodb/trino/issues/19649")\)
- Improve reliability when reading from GCS. \(#issue("20003", "https://github.com/trinodb/trino/issues/20003")\)
- Fix failure when reading ORC data. \(#issue("19935", "https://github.com/trinodb/trino/issues/19935")\)

== Elasticsearch connector

- Ensure certificate validation is skipped when #raw("elasticsearch.tls.verify-hostnames") is #raw("false"). \(#issue("20076", "https://github.com/trinodb/trino/issues/20076")\)

== Hive connector

- Add support for columns that changed from integer types to #raw("decimal") type. \(#issue("19931", "https://github.com/trinodb/trino/issues/19931")\)
- Add support for columns that changed from #raw("date") to #raw("varchar") type. \(#issue("19500", "https://github.com/trinodb/trino/issues/19500")\)
- Rename #raw("presto_version") table property to #raw("trino_version"). \(#issue("19967", "https://github.com/trinodb/trino/issues/19967")\)
- Rename #raw("presto_query_id") table property to #raw("trino_query_id"). \(#issue("19967", "https://github.com/trinodb/trino/issues/19967")\)
- Ensure AWS access keys are used for connections to the AWS Security Token Service. \(#issue("19982", "https://github.com/trinodb/trino/issues/19982")\)
- Improve query planning time on Hive tables without statistics. \(#issue("20034", "https://github.com/trinodb/trino/issues/20034")\)
- Reduce memory usage for inserts into partitioned tables. \(#issue("19649", "https://github.com/trinodb/trino/issues/19649")\)
- Improve reliability when reading from GCS. \(#issue("20003", "https://github.com/trinodb/trino/issues/20003")\)
- Fix failure when reading ORC data. \(#issue("19935", "https://github.com/trinodb/trino/issues/19935")\)

== Hudi connector

- Ensure AWS access keys are used for connections to the AWS Security Token Service. \(#issue("19982", "https://github.com/trinodb/trino/issues/19982")\)
- Improve reliability when reading from GCS. \(#issue("20003", "https://github.com/trinodb/trino/issues/20003")\)
- Fix failure when reading ORC data. \(#issue("19935", "https://github.com/trinodb/trino/issues/19935")\)

== Iceberg connector

- Fix incorrect removal of statistics files when executing #raw("remove_orphan_files"). \(#issue("19965", "https://github.com/trinodb/trino/issues/19965")\)
- Ensure AWS access keys are used for connections to the AWS Security Token Service. \(#issue("19982", "https://github.com/trinodb/trino/issues/19982")\)
- Improve performance of metadata queries involving materialized views. \(#issue("19939", "https://github.com/trinodb/trino/issues/19939")\)
- Reduce memory usage for inserts into partitioned tables. \(#issue("19649", "https://github.com/trinodb/trino/issues/19649")\)
- Improve reliability when reading from GCS. \(#issue("20003", "https://github.com/trinodb/trino/issues/20003")\)
- Fix failure when reading ORC data. \(#issue("19935", "https://github.com/trinodb/trino/issues/19935")\)

== Ignite connector

- Improve performance of queries involving #raw("OR") with #raw("IS NULL"), #raw("IS NOT NULL") predicates, or involving #raw("NOT") expression by pushing predicate computation to the Ignite database. \(#issue("19453", "https://github.com/trinodb/trino/issues/19453")\)

== MongoDB connector

- Allow configuration to use local scheduling of MongoDB splits with #raw("mongodb.allow-local-scheduling"). \(#issue("20078", "https://github.com/trinodb/trino/issues/20078")\)

== SQL Server connector

- Fix incorrect results when reading dates between #raw("1582-10-05") and #raw("1582-10-14"). \(#issue("20005", "https://github.com/trinodb/trino/issues/20005")\)
