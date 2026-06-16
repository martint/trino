#import "/lib/trino-docs.typ": *

#anchor("doc-release-release-331")
= Release 331 \(16 Mar 2020\)

== General

- Prevent query failures when worker is shut down gracefully. \(#issue("2648", "https://github.com/trinodb/trino/issues/2648")\)
- Fix join failures for queries involving #raw("OR") predicate with non-comparable functions. \(#issue("2861", "https://github.com/trinodb/trino/issues/2861")\)
- Ensure query completed event is fired when there is an error during analysis or planning. \(#issue("2842", "https://github.com/trinodb/trino/issues/2842")\)
- Fix memory accounting for #raw("ORDER BY") queries. \(#issue("2612", "https://github.com/trinodb/trino/issues/2612")\)
- Fix #link(label("fn-last-day-of-month"), raw("last_day_of_month")) for #raw("timestamp with time zone") values. \(#issue("2851", "https://github.com/trinodb/trino/issues/2851")\)
- Fix excessive runtime when parsing deeply nested expressions with unmatched parenthesis. \(#issue("2968", "https://github.com/trinodb/trino/issues/2968")\)
- Correctly reject #raw("date") literals that cannot be represented in Presto. \(#issue("2888", "https://github.com/trinodb/trino/issues/2888")\)
- Improve query performance by removing redundant data reshuffling. \(#issue("2853", "https://github.com/trinodb/trino/issues/2853")\)
- Improve performance of inequality joins involving #raw("BETWEEN"). \(#issue("2859", "https://github.com/trinodb/trino/issues/2859")\)
- Improve join performance for dictionary encoded data. \(#issue("2862", "https://github.com/trinodb/trino/issues/2862")\)
- Enable dynamic filtering by default. \(#issue("2793", "https://github.com/trinodb/trino/issues/2793")\)
- Show reorder join cost in #raw("EXPLAIN ANALYZE VERBOSE") \(#issue("2725", "https://github.com/trinodb/trino/issues/2725")\)
- Allow configuring resource groups selection based on user's groups. \(#issue("3023", "https://github.com/trinodb/trino/issues/3023")\)
- Add #raw("SET AUTHORIZATION") action to #link(label("doc-sql-alter-schema"))[ALTER SCHEMA]. \(#issue("2673", "https://github.com/trinodb/trino/issues/2673")\)
- Add #link(label("doc-connector-bigquery"))[BigQuery connector]. \(#issue("2532", "https://github.com/trinodb/trino/issues/2532")\)
- Add support for large prepared statements. \(#issue("2719", "https://github.com/trinodb/trino/issues/2719")\)

== Security

- Remove unused #raw("internal-communication.jwt.enabled") configuration property. \(#issue("2709", "https://github.com/trinodb/trino/issues/2709")\)
- Rename JWT configuration properties from #raw("http.authentication.jwt.*") to #raw("http-server.authentication.jwt.*"). \(#issue("2712", "https://github.com/trinodb/trino/issues/2712")\)
- Add access control checks for query execution, view query, and kill query. This can be configured using #link(label("ref-query-rules"))[query-rules] in #link(label("doc-security-file-system-access-control"))[File-based access control]. \(#issue("2213", "https://github.com/trinodb/trino/issues/2213")\)
- Hide columns of tables for which the user has no privileges in #link(label("doc-security-file-system-access-control"))[File-based access control]. \(#issue("2925", "https://github.com/trinodb/trino/issues/2925")\)

== JDBC driver

- Implement #raw("PreparedStatement.getMetaData()"). \(#issue("2770", "https://github.com/trinodb/trino/issues/2770")\)

== Web UI

- Fix copying worker address to clipboard. \(#issue("2865", "https://github.com/trinodb/trino/issues/2865")\)
- Fix copying query ID to clipboard. \(#issue("2872", "https://github.com/trinodb/trino/issues/2872")\)
- Fix display of data size values. \(#issue("2810", "https://github.com/trinodb/trino/issues/2810")\)
- Fix redirect from #raw("/") to #raw("/ui/") when Presto is behind a proxy. \(#issue("2908", "https://github.com/trinodb/trino/issues/2908")\)
- Fix display of prepared queries. \(#issue("2784", "https://github.com/trinodb/trino/issues/2784")\)
- Display physical input read rate. \(#issue("2873", "https://github.com/trinodb/trino/issues/2873")\)
- Add simple form based authentication that utilizes the configured password authenticator. \(#issue("2755", "https://github.com/trinodb/trino/issues/2755")\)
- Allow disabling the UI via the #raw("web-ui.enabled") configuration property. \(#issue("2755", "https://github.com/trinodb/trino/issues/2755")\)

== CLI

- Fix formatting of #raw("varbinary") in nested data types. \(#issue("2858", "https://github.com/trinodb/trino/issues/2858")\)
- Add #raw("--timezone") parameter. \(#issue("2961", "https://github.com/trinodb/trino/issues/2961")\)

== Hive connector

- Fix incorrect results for reads from #raw("information_schema") tables and metadata queries when using a Hive 3.x metastore. \(#issue("3008", "https://github.com/trinodb/trino/issues/3008")\)
- Fix query failure when using Glue metastore and the table storage descriptor has no properties. \(#issue("2905", "https://github.com/trinodb/trino/issues/2905")\)
- Fix deadlock when Hive caching is enabled and has a refresh interval configured. \(#issue("2984", "https://github.com/trinodb/trino/issues/2984")\)
- Respect #raw("bucketing_version") table property when using Glue metastore. \(#issue("2905", "https://github.com/trinodb/trino/issues/2905")\)
- Improve performance of partition fetching from Glue. \(#issue("3024", "https://github.com/trinodb/trino/issues/3024")\)
- Add support for bucket sort order in Glue when creating or updating a table or partition. \(#issue("1870", "https://github.com/trinodb/trino/issues/1870")\)
- Add support for Hive full ACID tables. \(#issue("2068", "https://github.com/trinodb/trino/issues/2068"), #issue("1591", "https://github.com/trinodb/trino/issues/1591"), #issue("2790", "https://github.com/trinodb/trino/issues/2790")\)
- Allow data conversion when reading decimal data from Parquet files and precision or scale in the file schema is different from the precision or scale in partition schema. \(#issue("2823", "https://github.com/trinodb/trino/issues/2823")\)
- Add option to enforce that a filter on a partition key be present in the query. This can be enabled by setting the #raw("hive.query-partition-filter-required") configuration property or the #raw("query_partition_filter_required") session property to #raw("true"). \(#issue("2334", "https://github.com/trinodb/trino/issues/2334")\)
- Allow selecting the #raw("Intelligent-Tiering") S3 storage class when writing data to S3. This can be enabled by setting the #raw("hive.s3.storage-class") configuration property to #raw("INTELLIGENT_TIERING"). \(#issue("3032", "https://github.com/trinodb/trino/issues/3032")\)
- Hide the Hive system schema #raw("sys") for security reasons. \(#issue("3008", "https://github.com/trinodb/trino/issues/3008")\)
- Add support for changing the owner of a schema. \(#issue("2673", "https://github.com/trinodb/trino/issues/2673")\)

== MongoDB connector

- Fix incorrect results when queries contain filters on certain data types, such as #raw("real") or #raw("decimal"). \(#issue("1781", "https://github.com/trinodb/trino/issues/1781")\)

== Other connectors

These changes apply to the MemSQL, MySQL, PostgreSQL, Redshift, Phoenix, and SQL Server connectors.

- Add support for dropping schemas. \(#issue("2956", "https://github.com/trinodb/trino/issues/2956")\)

== SPI

- Remove deprecated #raw("Identity") constructors. \(#issue("2877", "https://github.com/trinodb/trino/issues/2877")\)
- Introduce a builder for #raw("ConnectorIdentity") and deprecate its public constructors. \(#issue("2877", "https://github.com/trinodb/trino/issues/2877")\)
- Add support for row filtering and column masking via the #raw("getRowFilter()") and #raw("getColumnMask()") APIs in #raw("SystemAccessControl") and #raw("ConnectorAccessControl"). \(#issue("1480", "https://github.com/trinodb/trino/issues/1480")\)
- Add access control check for executing procedures. \(#issue("2924", "https://github.com/trinodb/trino/issues/2924")\)
