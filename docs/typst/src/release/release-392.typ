#import "/lib/trino-docs.typ": *

#anchor("doc-release-release-392")
= Release 392 \(3 Aug 2022\)

== General

- Add support for dynamic filtering when task-based fault-tolerant execution is enabled. \(#issue("9935", "https://github.com/trinodb/trino/issues/9935")\)
- Add support for correlated sub-queries in #raw("DELETE") queries. \(#issue("9447", "https://github.com/trinodb/trino/issues/9447")\)
- Fix potential query failure in certain complex queries with multiple joins and aggregations. \(#issue("13315", "https://github.com/trinodb/trino/issues/13315")\)

== JDBC driver

- Add the #raw("assumeLiteralUnderscoreInMetadataCallsForNonConformingClients") configuration property as a replacement for #raw("assumeLiteralNamesInMetadataCallsForNonConformingClients"), which is deprecated and planned to be removed in a future release. \(#issue("12761", "https://github.com/trinodb/trino/issues/12761")\)

== ClickHouse connector

- Report the total time spent reading data from the data source. \(#issue("13132", "https://github.com/trinodb/trino/issues/13132")\)

== Delta Lake connector

- Add support for using a randomized location when creating a table, so that future table renames or drops do not interfere with new tables created with the same name. This can be disabled by setting the #raw("delta.unique-table-location") configuration property to false. \(#issue("12980", "https://github.com/trinodb/trino/issues/12980")\)
- Add #raw("delta.metadata.live-files.cache-ttl") configuration property for the caching duration of active data files. \(#issue("13316", "https://github.com/trinodb/trino/issues/13316")\)
- Retain metadata properties and column metadata after schema changes. \(#issue("13368", "https://github.com/trinodb/trino/issues/13368"), #issue("13418", "https://github.com/trinodb/trino/issues/13418")\)
- Prevent writing to a table with #raw("NOT NULL") or #link("https://github.com/delta-io/delta/blob/master/PROTOCOL.md#column-invariants")[column invariants] columns. \(#issue("13353", "https://github.com/trinodb/trino/issues/13353")\)
- Fix incorrect min and max column statistics when writing #raw("NULL") values. \(#issue("13389", "https://github.com/trinodb/trino/issues/13389")\)

== Druid connector

- Add support for #raw("timestamp(p)") predicate pushdown. \(#issue("8404", "https://github.com/trinodb/trino/issues/8404")\)
- Report the total time spent reading data from the data source. \(#issue("13132", "https://github.com/trinodb/trino/issues/13132")\)
- Change mapping for the Druid #raw("float") type to the Trino #raw("real") type instead of the #raw("double") type. \(#issue("13412", "https://github.com/trinodb/trino/issues/13412")\)

== Hive connector

- Add support for short timezone IDs when translating Hive views. For example, #raw("JST") now works as an alias for #raw("Asia/Tokyo"). \(#issue("13179", "https://github.com/trinodb/trino/issues/13179")\)
- Add support for Amazon S3 Select pushdown for JSON files. \(#issue("13354", "https://github.com/trinodb/trino/issues/13354")\)

== Iceberg connector

- Add support for hidden #raw("$file_modified_time") columns. \(#issue("13082", "https://github.com/trinodb/trino/issues/13082")\)
- Add support for the Avro file format. \(#issue("12125", "https://github.com/trinodb/trino/issues/12125")\)
- Add support for filtering splits based on #raw("$path") column predicates. \(#issue("12785", "https://github.com/trinodb/trino/issues/12785")\)
- Improve query performance for tables with updated or deleted rows. \(#issue("13092", "https://github.com/trinodb/trino/issues/13092")\)
- Improve performance of the #raw("expire_snapshots") command for tables with many snapshots. \(#issue("13399", "https://github.com/trinodb/trino/issues/13399")\)
- Use unique table locations by default. This can be disabled by setting the #raw("iceberg.unique-table-location") configuration property to false. \(#issue("12941", "https://github.com/trinodb/trino/issues/12941")\)
- Use the correct table schema when reading a past version of a table. \(#issue("12786", "https://github.com/trinodb/trino/issues/12786")\)
- Return the #raw("$path") column without encoding when the path contains double slashes on S3. \(#issue("13012", "https://github.com/trinodb/trino/issues/13012")\)
- Fix failure when inserting into a Parquet table with columns that have quotation marks in their names. \(#issue("13074", "https://github.com/trinodb/trino/issues/13074")\)

== MariaDB connector

- Report the total time spent reading data from the data source. \(#issue("13132", "https://github.com/trinodb/trino/issues/13132")\)

== MySQL connector

- Report the total time spent reading data from the data source. \(#issue("13132", "https://github.com/trinodb/trino/issues/13132")\)
- Change mapping for the MySQL #raw("enum") type to the Trino #raw("varchar") type instead of the #raw("char") type. \(#issue("13303", "https://github.com/trinodb/trino/issues/13303")\)
- Fix failure when reading table statistics while the #raw("information_schema.column_statistics") table doesn't exist. \(#issue("13323", "https://github.com/trinodb/trino/issues/13323")\)

== Oracle connector

- Report the total time spent reading data from the data source. \(#issue("13132", "https://github.com/trinodb/trino/issues/13132")\)

== Phoenix connector

- Report the total time spent reading data from the data source. \(#issue("13132", "https://github.com/trinodb/trino/issues/13132")\)

== Pinot connector

- Redact the values of #raw("pinot.grpc.tls.keystore-password") and #raw("pinot.grpc.tls.truststore-password") in the server log. \(#issue("13422", "https://github.com/trinodb/trino/issues/13422")\)

== PostgreSQL connector

- Report the total time spent reading data from the data source. \(#issue("13132", "https://github.com/trinodb/trino/issues/13132")\)
- Improve performance of queries with an #raw("IN") expression within a complex expression. \(#issue("13136", "https://github.com/trinodb/trino/issues/13136")\)

== Redshift connector

- Report the total time spent reading data from the data source. \(#issue("13132", "https://github.com/trinodb/trino/issues/13132")\)

== SingleStore \(MemSQL\) connector

- Report the total time spent reading data from the data source. \(#issue("13132", "https://github.com/trinodb/trino/issues/13132")\)

== SQL Server connector

- Report the total time spent reading data from the data source. \(#issue("13132", "https://github.com/trinodb/trino/issues/13132")\)
