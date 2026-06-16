#import "/lib/trino-docs.typ": *

#anchor("doc-release-release-465")
= Release 465 \(20 Nov 2024\)

== General

- Add the #link(label("fn-cosine-similarity"), raw("cosine_similarity")) function for dense vectors. \(#issue("23964", "https://github.com/trinodb/trino/issues/23964")\)
- Add support for reading geometries in #link("https://en.wikipedia.org/wiki/Well-known_text_representation_of_geometry")[EWKB format] with the #link(label("fn-st-geomfrombinary"), raw("ST_GeomFromBinary")) function. \(#issue("23824", "https://github.com/trinodb/trino/issues/23824")\)
- Add support for parameter of #raw("bigint") type for the #link(label("fn-repeat"), raw("repeat")) function. \(#issue("22867", "https://github.com/trinodb/trino/issues/22867")\)
- Add support for the #raw("ORDER BY") clause in a windowed aggregate function. \(#issue("23929", "https://github.com/trinodb/trino/issues/23929")\)
- #breaking-marker("../release.html#breaking-changes") Change the data type for #raw("client_info") in the MySQL event listener to #raw("MEDIUMTEXT"). \(#issue("22362", "https://github.com/trinodb/trino/issues/22362")\)
- Improve performance of queries with selective joins. \(#issue("22824", "https://github.com/trinodb/trino/issues/22824")\)
- Improve performance when using various string functions in queries involving joins. \(#issue("24182", "https://github.com/trinodb/trino/issues/24182")\)
- Reduce chance of out of memory query failure when #raw("retry-policy") is set to #raw("task"). \(#issue("24114", "https://github.com/trinodb/trino/issues/24114")\)
- Prevent some query failures when #raw("retry-policy") is set to #raw("task"). \(#issue("24165", "https://github.com/trinodb/trino/issues/24165")\)

== JDBC driver

- Add support for #raw("LocalDateTime") and #raw("Instant") in #raw("getObject") and #raw("setObject"). \(#issue("22906", "https://github.com/trinodb/trino/issues/22906")\)

== CLI

- Fix incorrect quoting of output values when the #raw("CSV_UNQUOTED") or the #raw("CSV_HEADER_UNQUOTED") format is used. \(#issue("24113", "https://github.com/trinodb/trino/issues/24113")\)

== BigQuery connector

- Fix failure when reading views with #raw("timestamp") columns. \(#issue("24004", "https://github.com/trinodb/trino/issues/24004")\)

== Cassandra connector

- #breaking-marker("../release.html#breaking-changes") Require setting the #raw("cassandra.security") configuration property to #raw("PASSWORD") along with #raw("cassandra.username") and #raw("cassandra.password") for password-based authentication. \(#issue("23899", "https://github.com/trinodb/trino/issues/23899")\)

== Clickhouse connector

- Fix insert of invalid time zone data for tables using the timestamp with time zone type. \(#issue("23785", "https://github.com/trinodb/trino/issues/23785")\)
- Fix connector initialization issue when multiple catalogs with the connector are configured. \(#issue("24058", "https://github.com/trinodb/trino/issues/24058")\)

== Delta Lake connector

- Add support for customer-provided SSE key in #link(label("doc-object-storage-file-system-s3"))[S3 file system]. \(#issue("22992", "https://github.com/trinodb/trino/issues/22992")\)
- Fix incorrect results for queries filtering on a partition columns and the #raw("NAME") column mapping mode is used. \(#issue("24104", "https://github.com/trinodb/trino/issues/24104")\)

== Druid connector

- Fix connector initialization issue when multiple catalogs with the connector are configured. \(#issue("24058", "https://github.com/trinodb/trino/issues/24058")\)

== Exasol connector

- Fix connector initialization issue when multiple catalogs with the connector are configured. \(#issue("24058", "https://github.com/trinodb/trino/issues/24058")\)

== Faker connector

- Add the #link(label("fn-random-string"), raw("random_string")) catalog function. \(#issue("23990", "https://github.com/trinodb/trino/issues/23990")\)
- Make generated data deterministic for repeated queries. \(#issue("24008", "https://github.com/trinodb/trino/issues/24008")\)
- Allow configuring locale with the #raw("faker.locale") configuration property. \(#issue("24152", "https://github.com/trinodb/trino/issues/24152")\)

== Hive connector

- Add support for skipping archiving when committing to a table in the Glue metastore and the #raw("hive.metastore.glue.skip-archive") configuration property is set to #raw("true"). \(#issue("23817", "https://github.com/trinodb/trino/issues/23817")\)
- Add support for customer-provided SSE key in #link(label("doc-object-storage-file-system-s3"))[S3 file system]. \(#issue("22992", "https://github.com/trinodb/trino/issues/22992")\)

== Hudi connector

- Add support for customer-provided SSE key in #link(label("doc-object-storage-file-system-s3"))[S3 file system]. \(#issue("22992", "https://github.com/trinodb/trino/issues/22992")\)

== Iceberg connector

- Add support for reading and writing arbitrary table properties with the #raw("extra_properties") table property. \(#issue("17427", "https://github.com/trinodb/trino/issues/17427"), #issue("24031", "https://github.com/trinodb/trino/issues/24031")\)
- Add the #raw("spec_id"), #raw("partition"), #raw("sort_order_id"), and #raw("readable_metrics") columns to the #raw("$files") metadata table. \(#issue("24102", "https://github.com/trinodb/trino/issues/24102")\)
- Add support for configuring an OAuth2 server URI with the #raw("iceberg.rest-catalog.oauth2.server-uri") configuration property. \(#issue("23086", "https://github.com/trinodb/trino/issues/23086")\)
- Add support for retrying requests to a JDBC catalog with the #raw("iceberg.jdbc-catalog.retryable-status-codes") configuration property. \(#issue("23095", "https://github.com/trinodb/trino/issues/23095")\)
- Add support for case-insensitive name matching in the REST catalog. \(#issue("23715", "https://github.com/trinodb/trino/issues/23715")\)
- Add support for customer-provided SSE key in #link(label("doc-object-storage-file-system-s3"))[S3 file system]. \(#issue("22992", "https://github.com/trinodb/trino/issues/22992")\)
- Disallow adding duplicate files in the #raw("add_files") and #raw("add_files_from_table") procedures. \(#issue("24188", "https://github.com/trinodb/trino/issues/24188")\)
- Improve performance of Iceberg queries involving multiple table scans. \(#issue("23945", "https://github.com/trinodb/trino/issues/23945")\)
- Prevent #raw("MERGE"), #raw("UPDATE"), and #raw("DELETE") query failures for tables with equality deletes. \(#issue("15952", "https://github.com/trinodb/trino/issues/15952")\)

== Ignite connector

- Fix connector initialization issue when multiple catalogs with the connector are configured. \(#issue("24058", "https://github.com/trinodb/trino/issues/24058")\)

== MariaDB connector

- Fix connector initialization issue when multiple catalogs with the connector are configured. \(#issue("24058", "https://github.com/trinodb/trino/issues/24058")\)

== MySQL connector

- Fix connector initialization issue when multiple catalogs with the connector are configured. \(#issue("24058", "https://github.com/trinodb/trino/issues/24058")\)

== Oracle connector

- Fix connector initialization issue when multiple catalogs with the connector are configured. \(#issue("24058", "https://github.com/trinodb/trino/issues/24058")\)

== PostgreSQL connector

- Add support for the #raw("geometry") type. \(#issue("5580", "https://github.com/trinodb/trino/issues/5580")\)
- Fix connector initialization issue when multiple catalogs with the connector are configured. \(#issue("24058", "https://github.com/trinodb/trino/issues/24058")\)

== Redshift connector

- Add support pushing down casts from varchar to varchar and char to char into Redshift. \(#issue("23808", "https://github.com/trinodb/trino/issues/23808")\)
- Fix connector initialization issue when multiple catalogs with the connector are configured. \(#issue("24058", "https://github.com/trinodb/trino/issues/24058")\)

== SingleStore connector

- Fix connector initialization issue when multiple catalogs with the connector are configured. \(#issue("24058", "https://github.com/trinodb/trino/issues/24058")\)

== Snowflake connector

- Fix connector initialization issue when multiple catalogs with the connector are configured. \(#issue("24058", "https://github.com/trinodb/trino/issues/24058")\)

== SQL Server connector

- Update required SQL Server version to SQL Server 2019 or higher. \(#issue("24173", "https://github.com/trinodb/trino/issues/24173")\)
- Fix connector initialization issue when multiple catalogs with the connector are configured. \(#issue("24058", "https://github.com/trinodb/trino/issues/24058")\)

== Vertica connector

- Fix connector initialization issue when multiple catalogs with the connector are configured. \(#issue("24058", "https://github.com/trinodb/trino/issues/24058")\)

== SPI

- #breaking-marker("../release.html#breaking-changes") Remove deprecated variants of #raw("checkCanExecuteQuery") and #raw("checkCanSetSystemSessionProperty") without a #raw("QueryId") parameter from #raw("SystemAccessControl"). \(#issue("23244", "https://github.com/trinodb/trino/issues/23244")\)
