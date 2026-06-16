#import "/lib/trino-docs.typ": *

#anchor("doc-release-release-309")
= Release 309 \(25 Apr 2019\)

== General

- Fix incorrect match result for #link(label("doc-functions-regexp"))[Regular expression functions] when pattern ends with a word boundary matcher. This only affects the default #raw("JONI") library. \(#issue("661", "https://github.com/trinodb/trino/issues/661")\)
- Fix failures for queries involving spatial joins. \(#issue("652", "https://github.com/trinodb/trino/issues/652")\)
- Add support for #raw("SphericalGeography") to #link(label("fn-st-area"), raw("ST_Area()")). \(#issue("383", "https://github.com/trinodb/trino/issues/383")\)

== Security

- Add option for specifying the Kerberos GSS name type. \(#issue("645", "https://github.com/trinodb/trino/issues/645")\)

== Server RPM

- Update default JVM configuration to recommended settings \(see #link(label("doc-installation-deployment"))[Deploying Trino]\). \(#issue("642", "https://github.com/trinodb/trino/issues/642")\)

== Hive connector

- Fix rare failure when reading #raw("DECIMAL") values from ORC files. \(#issue("664", "https://github.com/trinodb/trino/issues/664")\)
- Add a hidden #raw("$properties") table for each table that describes its Hive table properties. For example, a table named #raw("example") will have an associated properties table named #raw("example$properties"). \(#issue("268", "https://github.com/trinodb/trino/issues/268")\)

== MySQL connector

- Match schema and table names case insensitively. This behavior can be enabled by setting the #raw("case-insensitive-name-matching") catalog configuration option to true. \(#issue("614", "https://github.com/trinodb/trino/issues/614")\)

== PostgreSQL connector

- Add support for #raw("ARRAY") type. \(#issue("317", "https://github.com/trinodb/trino/issues/317")\)
- Add support writing #raw("TINYINT") values. \(#issue("317", "https://github.com/trinodb/trino/issues/317")\)
- Match schema and table names case insensitively. This behavior can be enabled by setting the #raw("case-insensitive-name-matching") catalog configuration option to true. \(#issue("614", "https://github.com/trinodb/trino/issues/614")\)

== Redshift connector

- Match schema and table names case insensitively. This behavior can be enabled by setting the #raw("case-insensitive-name-matching") catalog configuration option to true. \(#issue("614", "https://github.com/trinodb/trino/issues/614")\)

== SQL Server connector

- Match schema and table names case insensitively. This behavior can be enabled by setting the #raw("case-insensitive-name-matching") catalog configuration option to true. \(#issue("614", "https://github.com/trinodb/trino/issues/614")\)

== Cassandra connector

- Allow reading from tables which have Cassandra column types that are not supported by Presto. These columns will not be visible in Presto. \(#issue("592", "https://github.com/trinodb/trino/issues/592")\)

== SPI

- Add session parameter to the #raw("applyFilter()") and #raw("applyLimit()") methods in #raw("ConnectorMetadata"). \(#issue("636", "https://github.com/trinodb/trino/issues/636")\)

#note[
This is a backwards incompatible changes with the previous SPI. If you have written a connector that implements these methods, you will need to update your code before deploying this release.
]
