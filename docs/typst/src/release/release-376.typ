#import "/lib/trino-docs.typ": *

#anchor("doc-release-release-376")
= Release 376 \(7 Apr 2022\)

== General

- Add table redirection awareness for #raw("RENAME table") operations. \(#issue("11277", "https://github.com/trinodb/trino/issues/11277")\)
- Deny adding column with comment if the connector does not support this feature. \(#issue("11486", "https://github.com/trinodb/trino/issues/11486")\)
- Improve performance for queries that contain inequality expressions. \(#issue("11518", "https://github.com/trinodb/trino/issues/11518")\)
- Consider null values as identical values in #raw("array_except"), #raw("array_union"), #raw("map_concat"), #raw("map_from_entries"), #raw("multimap_from_entries"), and #raw("multimap_agg") functions. \(#issue("560", "https://github.com/trinodb/trino/issues/560")\)
- Fix failure of #raw("DISTINCT .. LIMIT") operator when input data is dictionary encoded. \(#issue("11776", "https://github.com/trinodb/trino/issues/11776")\)
- Fix returning of invalid results for distinct aggregation when input data is dictionary encoded. \(#issue("11776", "https://github.com/trinodb/trino/issues/11776")\)
- Fix query failure when performing joins with connectors that support index lookups. \(#issue("11758", "https://github.com/trinodb/trino/issues/11758")\)
- Fix incorrect stage memory statistics reporting for queries running with #raw("retry-policy") set to #raw("TASK"). \(#issue("11801", "https://github.com/trinodb/trino/issues/11801")\)

== Security

- Add support to use two-way TLS\/SSL certificate validation with LDAP authentication. Additionally #raw("ldap.ssl-trust-certificate") config is replaced by #raw("ldap.ssl.truststore.path"). \(#issue("11070", "https://github.com/trinodb/trino/issues/11070")\).
- Fix failures in information schema role tables for catalogs using system roles. \(#issue("11694", "https://github.com/trinodb/trino/issues/11694")\)

== Web UI

- Add new page to display the runtime information of all workers in the cluster. \(#issue("11653", "https://github.com/trinodb/trino/issues/11653")\)

== JDBC driver

- Add support for using the system truststore with the #raw("SSLUseSystemTrustStore") parameter. \(#issue("10482", "https://github.com/trinodb/trino/issues/10482")\)
- Add support for #raw("ResultSet.getAsciiStream()") and #raw("ResultSet.getBinaryStream()"). \(#issue("11753", "https://github.com/trinodb/trino/issues/11753")\)
- Remove #raw("user") property requirement. \(#issue("11350", "https://github.com/trinodb/trino/issues/11350")\)

== CLI

- Add support for using the system truststore with the #raw("--use-system-truststore") option. \(#issue("10482", "https://github.com/trinodb/trino/issues/10482")\)

== Accumulo connector

- Add support for adding and dropping schemas. \(#issue("11808", "https://github.com/trinodb/trino/issues/11808")\)
- Disallow creating tables in a schema that doesn't exist. \(#issue("11808", "https://github.com/trinodb/trino/issues/11808")\)

== ClickHouse connector

- Add support for column comments when creating new tables. \(#issue("11606", "https://github.com/trinodb/trino/issues/11606")\)
- Add support for column comments when adding new columns. \(#issue("11606", "https://github.com/trinodb/trino/issues/11606")\)

== Delta Lake connector

- Add support for #raw("INSERT"), #raw("UPDATE"), and #raw("DELETE") queries on Delta Lake tables with fault-tolerant execution. \(#issue("11591", "https://github.com/trinodb/trino/issues/11591")\)
- Allow setting duration for completion of #link(label("doc-admin-dynamic-filtering"))[dynamic filtering] with the #raw("delta.dynamic-filtering.wait-timeout") configuration property. \(#issue("11600", "https://github.com/trinodb/trino/issues/11600")\)
- Improve query planning time after #raw("ALTER TABLE ... EXECUTE optimize") by always creating a transaction log checkpoint. \(#issue("11721", "https://github.com/trinodb/trino/issues/11721")\)
- Add support for reading Delta Lake tables in with auto-commit mode disabled. \(#issue("11792", "https://github.com/trinodb/trino/issues/11792")\)

== Hive connector

- Store file min\/max ORC statistics for string columns even when actual min or max value exceeds 64 bytes. This improves query performance when filtering on such column. \(#issue("11652", "https://github.com/trinodb/trino/issues/11652")\)
- Improve performance when reading Parquet data. \(#issue("11675", "https://github.com/trinodb/trino/issues/11675")\)
- Improve query performance when the same table is referenced multiple times within a query. \(#issue("11650", "https://github.com/trinodb/trino/issues/11650")\)

== Iceberg connector

- Add support for views when using Iceberg Glue catalog. \(#issue("11499", "https://github.com/trinodb/trino/issues/11499")\)
- Add support for reading Iceberg v2 tables containing deletion files. \(#issue("11642", "https://github.com/trinodb/trino/issues/11642")\)
- Add support for table redirections to the Hive connector. \(#issue("11356", "https://github.com/trinodb/trino/issues/11356")\)
- Include non-Iceberg tables when listing tables from Hive catalogs. \(#issue("11617", "https://github.com/trinodb/trino/issues/11617")\)
- Expose #raw("nan_count") in the #raw("$partitions") metadata table. \(#issue("10709", "https://github.com/trinodb/trino/issues/10709")\)
- Store file min\/max ORC statistics for string columns even when actual min or max value exceeds 64 bytes. This improves query performance when filtering on such column. \(#issue("11652", "https://github.com/trinodb/trino/issues/11652")\)
- Improve performance when reading Parquet data. \(#issue("11675", "https://github.com/trinodb/trino/issues/11675")\)
- Fix NPE when an Iceberg data file is missing null count statistics. \(#issue("11832", "https://github.com/trinodb/trino/issues/11832")\)

== Kudu connector

- Add support for adding columns with comment. \(#issue("11486", "https://github.com/trinodb/trino/issues/11486")\)

== MySQL connector

- Improve performance of queries involving joins by pushing computation to the MySQL database. \(#issue("11638", "https://github.com/trinodb/trino/issues/11638")\)

== Oracle connector

- Improve query performance of queries involving aggregation by pushing aggregation computation to the Oracle database. \(#issue("11657", "https://github.com/trinodb/trino/issues/11657")\)

== SPI

- Add support for table procedures that execute on the coordinator only. \(#issue("11750", "https://github.com/trinodb/trino/issues/11750")\)
