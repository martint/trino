#import "/lib/trino-docs.typ": *

#anchor("doc-release-release-464")
= Release 464 \(30 Oct 2024\)

== General

- #breaking-marker("../release.html#breaking-changes") Require JDK 23 to run Trino, including updated #link(label("ref-jvm-config"))[Deploying Trino]. \(#issue("21316", "https://github.com/trinodb/trino/issues/21316")\)
- Add the #link(label("doc-connector-faker"))[Faker connector] for easy generation of data. \(#issue("23691", "https://github.com/trinodb/trino/issues/23691")\)
- Add the Vertica connector. \(#issue("23948", "https://github.com/trinodb/trino/issues/23948")\)
- Rename the #raw("fault-tolerant-execution-eager-speculative-tasks-node_memory-overcommit") configuration property to #raw("fault-tolerant-execution-eager-speculative-tasks-node-memory-overcommit"). \(#issue("23876", "https://github.com/trinodb/trino/issues/23876")\)

== Accumulo connector

- #breaking-marker("../release.html#breaking-changes") Remove the Accumulo connector. \(#issue("23792", "https://github.com/trinodb/trino/issues/23792")\)

== BigQuery connector

- Fix incorrect results when reading array columns and #raw("bigquery.arrow-serialization.enabled") is set to true. \(#issue("23982", "https://github.com/trinodb/trino/issues/23982")\)

== Delta Lake connector

- Fix failure of S3 file listing of buckets that enforce #link("https://docs.aws.amazon.com/AmazonS3/latest/userguide/RequesterPaysBuckets.html")[requester pays]. \(#issue("23906", "https://github.com/trinodb/trino/issues/23906")\)

== Hive connector

- Use the #raw("hive.metastore.partition-batch-size.max") catalog configuration property value in the #raw("sync_partition_metadata") procedure. Change the default batch size from 1000 to 100. \(#issue("23895", "https://github.com/trinodb/trino/issues/23895")\)
- Fix failure of S3 file listing of buckets that enforce #link("https://docs.aws.amazon.com/AmazonS3/latest/userguide/RequesterPaysBuckets.html")[requester pays]. \(#issue("23906", "https://github.com/trinodb/trino/issues/23906")\)

== Hudi connector

- Fix failure of S3 file listing of buckets that enforce #link("https://docs.aws.amazon.com/AmazonS3/latest/userguide/RequesterPaysBuckets.html")[requester pays]. \(#issue("23906", "https://github.com/trinodb/trino/issues/23906")\)

== Iceberg connector

- Improve performance of #raw("OPTIMIZE") on large partitioned tables. \(#issue("10785", "https://github.com/trinodb/trino/issues/10785")\)
- Rename the #raw("iceberg.expire_snapshots.min-retention") configuration property to #raw("iceberg.expire-snapshots.min-retention"). \(#issue("23876", "https://github.com/trinodb/trino/issues/23876")\)
- Rename the #raw("iceberg.remove_orphan_files.min-retention") configuration property to #raw("iceberg.remove-orphan-files.min-retention"). \(#issue("23876", "https://github.com/trinodb/trino/issues/23876")\)
- Fix failure of S3 file listing of buckets that enforce #link("https://docs.aws.amazon.com/AmazonS3/latest/userguide/RequesterPaysBuckets.html")[requester pays]. \(#issue("23906", "https://github.com/trinodb/trino/issues/23906")\)
- Fix incorrect column constraints when using the #raw("migrate") procedure on tables that contain #raw("NULL") values. \(#issue("23928", "https://github.com/trinodb/trino/issues/23928")\)

== Phoenix connector

- #breaking-marker("../release.html#breaking-changes") Require JVM configuration to allow the Java security manager. \(#issue("24207", "https://github.com/trinodb/trino/issues/24207")\)
