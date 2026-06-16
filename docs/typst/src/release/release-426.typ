#import "/lib/trino-docs.typ": *

#anchor("doc-release-release-426")
= Release 426 \(5 Sep 2023\)

== General

- Add support for #raw("SET SESSION AUTHORIZATION") and #raw("RESET SESSION AUTHORIZATION"). \(#issue("16067", "https://github.com/trinodb/trino/issues/16067")\)
- Add support for automatic type coercion when creating tables. \(#issue("13994", "https://github.com/trinodb/trino/issues/13994")\)
- Improve performance of aggregations over decimal values. \(#issue("18868", "https://github.com/trinodb/trino/issues/18868")\)
- Fix event listener incorrectly reporting output columns for #raw("UPDATE") statements with subqueries. \(#issue("18815", "https://github.com/trinodb/trino/issues/18815")\)
- Fix failure when performing an outer join involving geospatial functions in the join clause. \(#issue("18860", "https://github.com/trinodb/trino/issues/18860")\)
- Fix failure when querying partitioned tables with a #raw("WHERE") clause that contains lambda expressions. \(#issue("18865", "https://github.com/trinodb/trino/issues/18865")\)
- Fix failure for #raw("GROUP BY") queries over #raw("map") and #raw("array") types. \(#issue("18863", "https://github.com/trinodb/trino/issues/18863")\)

== Security

- Fix authentication failure with OAuth 2.0 when authentication tokens are larger than 4 KB. \(#issue("18836", "https://github.com/trinodb/trino/issues/18836")\)

== Delta Lake connector

- Add support for the #raw("TRUNCATE TABLE") statement. \(#issue("18786", "https://github.com/trinodb/trino/issues/18786")\)
- Add support for the #raw("CASCADE") option in #raw("DROP SCHEMA") statements. \(#issue("18333", "https://github.com/trinodb/trino/issues/18333")\)
- Add support for #link("https://docs.databricks.com/en/release-notes/runtime/13.3lts.html")[Databricks 13.3 LTS]. \(#issue("18888", "https://github.com/trinodb/trino/issues/18888")\)
- Fix writing an incorrect transaction log for partitioned tables with an #raw("id") or #raw("name") column mapping mode. \(#issue("18661", "https://github.com/trinodb/trino/issues/18661")\)

== Hive connector

- Add the #raw("hive.metastore.thrift.batch-fetch.enabled") configuration property, which can be set to #raw("false") to disable batch metadata fetching from the Hive metastore. \(#issue("18111", "https://github.com/trinodb/trino/issues/18111")\)
- Fix #raw("ANALYZE") failure when row count stats are missing. \(#issue("18798", "https://github.com/trinodb/trino/issues/18798")\)
- Fix the #raw("hive.target-max-file-size") configuration property being ignored when writing to sorted tables. \(#issue("18653", "https://github.com/trinodb/trino/issues/18653")\)
- Fix query failure when reading large SequenceFile, RCFile, or Avro files. \(#issue("18837", "https://github.com/trinodb/trino/issues/18837")\)

== Iceberg connector

- Fix the #raw("iceberg.target-max-file-size") configuration property being ignored when writing to sorted tables. \(#issue("18653", "https://github.com/trinodb/trino/issues/18653")\)

== SPI

- Remove the deprecated #raw("ConnectorMetadata#dropSchema(ConnectorSession session, String schemaName)") method. \(#issue("18839", "https://github.com/trinodb/trino/issues/18839")\)
