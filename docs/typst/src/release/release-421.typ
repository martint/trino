#import "/lib/trino-docs.typ": *

#anchor("doc-release-release-421")
= Release 421 \(6 Jul 2023\)

== General

- Add support for check constraints in an #raw("UPDATE") statement. \(#issue("17195", "https://github.com/trinodb/trino/issues/17195")\)
- Improve performance for queries involving a #raw("year") function within an #raw("IN") predicate. \(#issue("18092", "https://github.com/trinodb/trino/issues/18092")\)
- Fix failure when cancelling a query with a window function. \(#issue("18061", "https://github.com/trinodb/trino/issues/18061")\)
- Fix failure for queries involving the #raw("concat_ws") function on arrays with more than 254 values. \(#issue("17816", "https://github.com/trinodb/trino/issues/17816")\)
- Fix query failure or incorrect results when coercing a #link(label("ref-structural-data-types"))[structural data type] that contains a timestamp. \(#issue("17900", "https://github.com/trinodb/trino/issues/17900")\)

== JDBC driver

- Add support for using an alternative hostname with the #raw("hostnameInCertificate") property when SSL verification is set to #raw("FULL"). \(#issue("17939", "https://github.com/trinodb/trino/issues/17939")\)

== Delta Lake connector

- Add support for check constraints and column invariants in #raw("UPDATE") statements. \(#issue("17195", "https://github.com/trinodb/trino/issues/17195")\)
- Add support for creating tables with the #raw("column") mapping mode. \(#issue("12638", "https://github.com/trinodb/trino/issues/12638")\)
- Add support for using the #raw("OPTIMIZE") procedure on column mapping tables. \(#issue("17527", "https://github.com/trinodb/trino/issues/17527")\)
- Add support for #raw("DROP COLUMN"). \(#issue("15792", "https://github.com/trinodb/trino/issues/15792")\)

== Google Sheets connector

- Add support for #link(label("doc-sql-insert"))[INSERT] statements. \(#issue("3866", "https://github.com/trinodb/trino/issues/3866")\)

== Hive connector

- Add Hive partition projection column properties to the output of #raw("SHOW CREATE TABLE"). \(#issue("18076", "https://github.com/trinodb/trino/issues/18076")\)
- Fix incorrect query results when using S3 Select with #raw("IS NULL") or #raw("IS NOT NULL") predicates. \(#issue("17563", "https://github.com/trinodb/trino/issues/17563")\)
- Fix incorrect query results when using S3 Select and a table's #raw("null_format") field is set. \(#issue("17563", "https://github.com/trinodb/trino/issues/17563")\)

== Iceberg connector

- Add support for migrating a bucketed Hive table into a non-bucketed Iceberg table. \(#issue("18103", "https://github.com/trinodb/trino/issues/18103")\)

== Kafka connector

- Add support for reading Protobuf messages containing the #raw("Any") Protobuf type. This is disabled by default and can be enabled by setting the #raw("kafka.protobuf-any-support-enabled") configuration property to #raw("true"). \(#issue("17394", "https://github.com/trinodb/trino/issues/17394")\)

== MongoDB connector

- Improve query performance on tables with #raw("row") columns when only a subset of fields is needed for the query. \(#issue("17710", "https://github.com/trinodb/trino/issues/17710")\)

== Redshift connector

- Add support for #link(label("doc-sql-comment"))[table comments]. \(#issue("16900", "https://github.com/trinodb/trino/issues/16900")\)

== SPI

- Add the #raw("BLOCK_AND_POSITION_NOT_NULL") argument convention. \(#issue("18035", "https://github.com/trinodb/trino/issues/18035")\)
- Add the #raw("BLOCK_BUILDER") return convention that writes function results directly to a #raw("BlockBuilder"). \(#issue("18094", "https://github.com/trinodb/trino/issues/18094")\)
- Add the #raw("READ_VALUE") operator that can read a value from any argument convention to any return convention.  \(#issue("18094", "https://github.com/trinodb/trino/issues/18094")\)
- Remove write methods from the BlockBuilder interface. \(#issue("17342", "https://github.com/trinodb/trino/issues/17342")\)
- Change array, map, and row build to use a single #raw("writeEntry"). \(#issue("17342", "https://github.com/trinodb/trino/issues/17342")\)
