#import "/lib/trino-docs.typ": *

#anchor("doc-release-release-400")
= Release 400 \(13 Oct 2022\)

== General

- Add output buffer utilization to #raw("EXPLAIN ANALYZE VERBOSE"). \(#issue("14396", "https://github.com/trinodb/trino/issues/14396")\)
- Increase concurrency for large clusters. \(#issue("14395", "https://github.com/trinodb/trino/issues/14395")\)
- Fix JSON serialization failure for #raw("QueryCompletedEvent") in event listener. \(#issue("14604", "https://github.com/trinodb/trino/issues/14604")\)
- Fix occasional #raw("maximum pending connection acquisitions exceeded") failure when fault-tolerant execution is enabled. \(#issue("14580", "https://github.com/trinodb/trino/issues/14580")\)
- Fix incorrect results when calling the #raw("round") function on large #raw("real") and #raw("double") values. \(#issue("14613", "https://github.com/trinodb/trino/issues/14613")\)
- Fix query failure when using the #raw("merge(qdigest)") function. \(#issue("14616", "https://github.com/trinodb/trino/issues/14616")\)

== BigQuery connector

- Add support for #link(label("doc-sql-truncate"))[truncating tables]. \(#issue("14494", "https://github.com/trinodb/trino/issues/14494")\)

== Delta Lake connector

- Prevent coordinator out-of-memory failure when querying a large number of tables in a short period of time. \(#issue("14571", "https://github.com/trinodb/trino/issues/14571")\)

== Hive connector

- Reduce memory usage when scanning a large number of partitions, and add the #raw("hive.max-partitions-for-eager-load") configuration property to manage the number of partitions that can be loaded into memory. \(#issue("14225", "https://github.com/trinodb/trino/issues/14225")\)
- Increase the default value of the #raw("hive.max-partitions-per-scan") configuration property to #raw("1000000") from #raw("100000"). \(#issue("14225", "https://github.com/trinodb/trino/issues/14225")\)
- Utilize the #raw("hive.metastore.thrift.delete-files-on-drop") configuration property when dropping partitions and tables. Previously, it was only used when dropping tables. \(#issue("13545", "https://github.com/trinodb/trino/issues/13545")\)

== Hudi connector

- Hide Hive system schemas. \(#issue("14510", "https://github.com/trinodb/trino/issues/14510")\)

== Iceberg connector

- Reduce query latency when querying tables with a large number of files. \(#issue("14504", "https://github.com/trinodb/trino/issues/14504")\)
- Prevent table corruption when changing a table fails due to an inability to release the table lock from the Hive metastore. \(#issue("14386", "https://github.com/trinodb/trino/issues/14386")\)
- Fix query failure when reading from a table with a leading double slash in the metadata location. \(#issue("14299", "https://github.com/trinodb/trino/issues/14299")\)

== Pinot connector

- Add support for the Pinot proxy for controller\/broker and server gRPC requests. \(#issue("13015", "https://github.com/trinodb/trino/issues/13015")\)
- Update minimum required version to 0.10.0. \(#issue("14090", "https://github.com/trinodb/trino/issues/14090")\)

== SQL Server connector

- Allow renaming column names containing special characters. \(#issue("14272", "https://github.com/trinodb/trino/issues/14272")\)

== SPI

- Add #raw("ConnectorAccessControl.checkCanGrantExecuteFunctionPrivilege") overload which must be implemented to allow views that use table functions. \(#issue("13944", "https://github.com/trinodb/trino/issues/13944")\)
