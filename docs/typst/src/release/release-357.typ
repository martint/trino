#import "/lib/trino-docs.typ": *

#anchor("doc-release-release-357")
= Release 357 \(21 May 2021\)

== General

- Add support for subquery expressions that return multiple columns. Example: #raw("SELECT x = (VALUES (1, 'a'))") \(#issue("7773", "https://github.com/trinodb/trino/issues/7773"), #issue("7863", "https://github.com/trinodb/trino/issues/7863")\)
- Allow aggregation pushdown when #raw("COUNT(1)") is used with #raw("GROUP BY"). \(#issue("7251", "https://github.com/trinodb/trino/issues/7251")\)
- Add support for #raw("CURRENT_CATALOG") and #raw("CURRENT_SCHEMA"). \(#issue("7824", "https://github.com/trinodb/trino/issues/7824")\)
- Add #link(label("fn-format-number"), raw("format_number")) function. \(#issue("1878", "https://github.com/trinodb/trino/issues/1878")\)
- Change #raw("row") to #raw("json") cast to produce JSON objects instead of JSON arrays. This behavior can be restored with the #raw("deprecated.legacy-row-to-json-cast") configuration option. \(#issue("3536", "https://github.com/trinodb/trino/issues/3536")\)
- Print dynamic filters summary in #raw("EXPLAIN ANALYZE"). \(#issue("7874", "https://github.com/trinodb/trino/issues/7874")\)
- Improve performance for queries using #raw("IN") predicate with a short list of constants. \(#issue("7840", "https://github.com/trinodb/trino/issues/7840")\)
- Release memory immediately when queries involving window functions fail. \(#issue("7947", "https://github.com/trinodb/trino/issues/7947")\)
- Fix incorrect handling of row expressions for #raw("IN") predicates, quantified comparisons and scalar subqueries. Previously, the queries would succeed where they should have failed with a type mismatch error. \(#issue("7797", "https://github.com/trinodb/trino/issues/7797")\)
- Fix failure when using #raw("PREPARE") with a #raw("GRANT") statement that contains quoted SQL keywords. \(#issue("7941", "https://github.com/trinodb/trino/issues/7941")\)
- Fix cluster instability after executing certain large #raw("EXPLAIN") queries. \(#issue("8017", "https://github.com/trinodb/trino/issues/8017")\)

== Security

- Enforce materialized view creator security policies when view is fresh. \(#issue("7618", "https://github.com/trinodb/trino/issues/7618")\)
- Use system truststore for OAuth2 and JWK for JWT authentication. Previously, the truststore configured for internal communication was used. This means that globally trusted certificates will work by default. \(#issue("7936", "https://github.com/trinodb/trino/issues/7936")\)
- Fix handling of SNI for multiple TLS certificates. \(#issue("8007", "https://github.com/trinodb/trino/issues/8007")\)

== Web UI

- Make the UI aware of principal-field \(configured with #raw("http-server.authentication.oauth2.principal-field")\) when #raw("web-ui.authentication.type") is set to #raw("oauth2"). \(#issue("7526", "https://github.com/trinodb/trino/issues/7526")\)

== JDBC driver

- Cancel Trino query execution when JDBC statement is closed. \(#issue(" 7819", "https://github.com/trinodb/trino/issues/ 7819")\)
- Close statement when connection is closed. \(#issue(" 7819", "https://github.com/trinodb/trino/issues/ 7819")\)

== CLI

- Add #raw("clear") command to clear the screen. \(#issue("7632", "https://github.com/trinodb/trino/issues/7632")\)

== BigQuery connector

- Fix failures for queries accessing #raw("information_schema.columns") when #raw("case-insensitive-name-matching") is disabled. \(#issue("7830", "https://github.com/trinodb/trino/issues/7830")\)
- Fix query failure when a predicate on a BigQuery #raw("string") column contains a value with a single quote \(#raw("'")\). \(#issue("7784", "https://github.com/trinodb/trino/issues/7784")\)

== ClickHouse connector

- Improve performance of aggregation queries by computing aggregations within ClickHouse. Currently, the following aggregate functions are eligible for pushdown: #raw("count"),  #raw("min"), #raw("max"), #raw("sum") and #raw("avg"). \(#issue("7434", "https://github.com/trinodb/trino/issues/7434")\)
- Map ClickHouse #raw("UUID") columns as #raw("UUID") type in Trino instead of #raw("VARCHAR"). \(#issue("7097", "https://github.com/trinodb/trino/issues/7097")\)

== Elasticsearch connector

- Support decoding #raw("timestamp") columns encoded as strings containing milliseconds since epoch values. \(#issue("7838", "https://github.com/trinodb/trino/issues/7838")\)
- Retry requests with backoff when Elasticsearch is overloaded. \(#issue("7423", "https://github.com/trinodb/trino/issues/7423")\)

== Kinesis connector

- Add #raw("kinesis.table-description-refresh-interval") configuration property to set the refresh interval for fetching table descriptions from S3. \(#issue("1609", "https://github.com/trinodb/trino/issues/1609")\)

== Kudu connector

- Fix query failures for grouped execution on range partitioned tables. \(#issue("7738", "https://github.com/trinodb/trino/issues/7738")\)

== MongoDB connector

- Redact the value of #raw("mongodb.credentials") in the server log. \(#issue("7862", "https://github.com/trinodb/trino/issues/7862")\)
- Add support for dropping columns. \(#issue("7853", "https://github.com/trinodb/trino/issues/7853")\)

== Pinot connector

- Add support for complex filter expressions in passthrough queries. \(#issue("7161", "https://github.com/trinodb/trino/issues/7161")\)

== Other connectors

This change applies to the Druid, MemSQL, MySQL, Oracle, Phoenix, PosgreSQL, Redshift, and SQL Server connectors.

- Add rule support for identifier mapping. The rules can be configured via the #raw("case-insensitive-name-matching.config-file") configuration property. \(#issue("7841", "https://github.com/trinodb/trino/issues/7841")\)

== SPI

- Make #raw("ConnectorMaterializedViewDefinition") non-serializable. It is the responsibility of the connector to serialize and store the materialized view definitions in an appropriate format. \(#issue("7762", "https://github.com/trinodb/trino/issues/7762")\)
- Deprecate #raw("TupleDomain.transform"). \(#issue("7980", "https://github.com/trinodb/trino/issues/7980")\)
