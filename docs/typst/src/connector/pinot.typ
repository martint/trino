#import "/lib/trino-docs.typ": *

#anchor("doc-connector-pinot")
= Pinot connector

The Pinot connector allows Trino to query data stored in #link("https://pinot.apache.org/")[Apache Pinot™].

== Requirements

To connect to Pinot, you need:

- Pinot 1.1.0 or higher.
- Network access from the Trino coordinator and workers to the Pinot controller nodes. Port 8098 is the default port.

== Configuration

To configure the Pinot connector, create a catalog properties file e.g. #raw("etc/catalog/example.properties") with at least the following contents:

#code-block("text", "connector.name=pinot
pinot.controller-urls=host1:8098,host2:8098")

Replace #raw("host1:8098,host2:8098") with a comma-separated list of Pinot controller nodes. This can be the ip or the FQDN, the url scheme \(#raw("http://")\) is optional.

== Configuration properties

=== General configuration properties

#list-table((
  ([Property name], [Required], [Description],),
  ([#raw("pinot.controller-urls")], [Yes], [A comma separated list of controller hosts. If Pinot is deployed via #link("https://kubernetes.io/")[Kubernetes] this needs to point to the controller service endpoint. The Pinot broker and server must be accessible via DNS as Pinot returns hostnames and not IP addresses.],),
  ([#raw("pinot.broker-url")], [No], [A host and port of broker. If broker URL exposed by Pinot controller API is not accessible, this property can be used to specify the broker endpoint. Enabling this property will disable broker discovery.],),
  ([#raw("pinot.connection-timeout")], [No], [Pinot connection timeout, default is #raw("1m").],),
  ([#raw("pinot.metadata-expiry")], [No], [Pinot metadata expiration time, default is #raw("2m").],),
  ([#raw("pinot.controller.authentication.type")], [No], [Pinot authentication method for controller requests. Allowed values are #raw("NONE") and #raw("PASSWORD") - defaults to #raw("NONE") which is no authentication.],),
  ([#raw("pinot.controller.authentication.user")], [No], [Controller username for basic authentication method.],),
  ([#raw("pinot.controller.authentication.password")], [No], [Controller password for basic authentication method.],),
  ([#raw("pinot.broker.authentication.type")], [No], [Pinot authentication method for broker requests. Allowed values are #raw("NONE") and #raw("PASSWORD") - defaults to #raw("NONE") which is no authentication.],),
  ([#raw("pinot.broker.authentication.user")], [No], [Broker username for basic authentication method.],),
  ([#raw("pinot.broker.authentication.password")], [No], [Broker password for basic authentication method.],),
  ([#raw("pinot.max-rows-per-split-for-segment-queries")], [No], [Fail query if Pinot server split returns more rows than configured, default to #raw("2,147,483,646").],),
  ([#raw("pinot.prefer-broker-queries")], [No], [Pinot query plan prefers to query Pinot broker, default is #raw("false").],),
  ([#raw("pinot.forbid-segment-queries")], [No], [Forbid parallel querying and force all querying to happen via the broker, default is #raw("false").],),
  ([#raw("pinot.segments-per-split")], [No], [The number of segments processed in a split. Setting this higher reduces the number of requests made to Pinot. This is useful for smaller Pinot clusters, default is #raw("1").],),
  ([#raw("pinot.fetch-retry-count")], [No], [Retry count for retriable Pinot data fetch calls, default is #raw("2").],),
  ([#raw("pinot.non-aggregate-limit-for-broker-queries")], [No], [Max limit for non aggregate queries to the Pinot broker, default is #raw("25,000").],),
  ([#raw("pinot.max-rows-for-broker-queries")], [No], [Max rows for a broker query can return, default is #raw("50,000").],),
  ([#raw("pinot.aggregation-pushdown.enabled")], [No], [Push down aggregation queries, default is #raw("true").],),
  ([#raw("pinot.count-distinct-pushdown.enabled")], [No], [Push down count distinct queries to Pinot, default is #raw("true").],),
  ([#raw("pinot.target-segment-page-size")], [No], [Max allowed page size for segment query, default is #raw("1MB").],),
  ([#raw("pinot.proxy.enabled")], [No], [Use Pinot Proxy for controller and broker requests, default is #raw("false").],)
), header-rows: 1)

If #raw("pinot.controller.authentication.type") is set to #raw("PASSWORD") then both #raw("pinot.controller.authentication.user") and #raw("pinot.controller.authentication.password") are required.

If #raw("pinot.broker.authentication.type") is set to #raw("PASSWORD") then both #raw("pinot.broker.authentication.user") and #raw("pinot.broker.authentication.password") are required.

If #raw("pinot.controller-urls") uses #raw("https") scheme then TLS is enabled for all connections including brokers.

=== gRPC configuration properties

#list-table((
  ([Property name], [Required], [Description],),
  ([#raw("pinot.grpc.port")], [No], [Pinot gRPC port, default to #raw("8090").],),
  ([#raw("pinot.grpc.max-inbound-message-size")], [No], [Max inbound message bytes when init gRPC client, default is #raw("128MB").],),
  ([#raw("pinot.grpc.use-plain-text")], [No], [Use plain text for gRPC communication, default to #raw("true").],),
  ([#raw("pinot.grpc.tls.keystore-type")], [No], [TLS keystore type for gRPC connection, default is #raw("JKS").],),
  ([#raw("pinot.grpc.tls.keystore-path")], [No], [TLS keystore file location for gRPC connection, default is empty.],),
  ([#raw("pinot.grpc.tls.keystore-password")], [No], [TLS keystore password, default is empty.],),
  ([#raw("pinot.grpc.tls.truststore-type")], [No], [TLS truststore type for gRPC connection, default is #raw("JKS").],),
  ([#raw("pinot.grpc.tls.truststore-path")], [No], [TLS truststore file location for gRPC connection, default is empty.],),
  ([#raw("pinot.grpc.tls.truststore-password")], [No], [TLS truststore password, default is empty.],),
  ([#raw("pinot.grpc.tls.ssl-provider")], [No], [SSL provider, default is #raw("JDK").],),
  ([#raw("pinot.grpc.proxy-uri")], [No], [Pinot Rest Proxy gRPC endpoint URI, default is null.],)
), header-rows: 1)

For more Apache Pinot TLS configurations, please also refer to #link("https://docs.pinot.apache.org/operators/tutorials/configuring-tls-ssl")[Configuring TLS\/SSL].

You can use #link(label("doc-security-secrets"))[secrets] to avoid actual values in the catalog properties files.

== Querying Pinot tables

The Pinot connector automatically exposes all tables in the default schema of the catalog. You can list all tables in the pinot catalog with the following query:

#code-block(none, "SHOW TABLES FROM example.default;")

You can list columns in the flight\_status table:

#code-block(none, "DESCRIBE example.default.flight_status;
SHOW COLUMNS FROM example.default.flight_status;")

Queries written with SQL are fully supported and can include filters and limits:

#code-block(none, "SELECT foo
FROM pinot_table
WHERE bar = 3 AND baz IN ('ONE', 'TWO', 'THREE')
LIMIT 25000;")

#anchor("ref-pinot-dynamic-tables")

== Dynamic tables

To leverage Pinot's fast aggregation, a Pinot query written in PQL can be used as the table name. Filters and limits in the outer query are pushed down to Pinot. Let's look at an example query:

#code-block(none, "SELECT *
FROM example.default.\"SELECT MAX(col1), COUNT(col2) FROM pinot_table GROUP BY col3, col4\"
WHERE col3 IN ('FOO', 'BAR') AND col4 > 50
LIMIT 30000")

Filtering and limit processing is pushed down to Pinot.

The queries are routed to the broker and are more suitable to aggregate queries.

For #raw("SELECT") queries without aggregates it is more performant to issue a regular SQL query. Processing is routed directly to the servers that store the data.

The above query is translated to the following Pinot PQL query:

#code-block(none, "SELECT MAX(col1), COUNT(col2)
FROM pinot_table
WHERE col3 IN('FOO', 'BAR') and col4 > 50
TOP 30000")

#anchor("ref-pinot-type-mapping")

== Type mapping

Because Trino and Pinot each support types that the other does not, this connector #link(label("ref-type-mapping-overview"))[maps some types] when reading data.

=== Pinot type to Trino type mapping

The connector maps Pinot types to the corresponding Trino types according to the following table:

#list-table((
  ([Pinot type], [Trino type],),
  ([#raw("INT")], [#raw("INTEGER")],),
  ([#raw("LONG")], [#raw("BIGINT")],),
  ([#raw("FLOAT")], [#raw("REAL")],),
  ([#raw("DOUBLE")], [#raw("DOUBLE")],),
  ([#raw("STRING")], [#raw("VARCHAR")],),
  ([#raw("BYTES")], [#raw("VARBINARY")],),
  ([#raw("JSON")], [#raw("JSON")],),
  ([#raw("TIMESTAMP")], [#raw("TIMESTAMP")],),
  ([#raw("INT_ARRAY")], [#raw("VARCHAR")],),
  ([#raw("LONG_ARRAY")], [#raw("VARCHAR")],),
  ([#raw("FLOAT_ARRAY")], [#raw("VARCHAR")],),
  ([#raw("DOUBLE_ARRAY")], [#raw("VARCHAR")],),
  ([#raw("STRING_ARRAY")], [#raw("VARCHAR")],)
), header-rows: 1, title: "Pinot type to Trino type mapping")

No other types are supported.

==== Date Type

For Pinot #raw("DateTimeFields"), if the #raw("FormatSpec") is in days, then it is converted to a Trino #raw("DATE") type. Pinot allows for #raw("LONG") fields to have a #raw("FormatSpec") of days as well, if the value is larger than #raw("Integer.MAX_VALUE") then the conversion to Trino #raw("DATE") fails.

==== Null Handling

If a Pinot TableSpec has #raw("nullHandlingEnabled") set to true, then for numeric types the null value is encoded as #raw("MIN_VALUE") for that type. For Pinot #raw("STRING") type, the value #raw("null") is interpreted as a #raw("NULL") value.

#anchor("ref-pinot-sql-support")

== SQL support

The connector provides #link(label("ref-sql-globally-available"))[globally available] and #link(label("ref-sql-read-operations"))[read operation] statements to access data and metadata in Pinot.

#anchor("ref-pinot-pushdown")

== Pushdown

The connector supports pushdown for a number of operations:

- #link(label("ref-limit-pushdown"))[limit-pushdown]

#link(label("ref-aggregation-pushdown"))[Aggregate pushdown] for the following functions:

- #link(label("fn-avg"), raw("avg"))
- #link(label("fn-approx-distinct"), raw("approx_distinct"))
- #raw("count(*)") and #raw("count(distinct)") variations of #link(label("fn-count"), raw("count"))
- #link(label("fn-max"), raw("max"))
- #link(label("fn-min"), raw("min"))
- #link(label("fn-sum"), raw("sum"))

Aggregate function pushdown is enabled by default, but can be disabled with the catalog property #raw("pinot.aggregation-pushdown.enabled") or the catalog session property #raw("aggregation_pushdown_enabled").

A #raw("count(distinct)") pushdown may cause Pinot to run a full table scan with significant performance impact. If you encounter this problem, you can disable it with the catalog property #raw("pinot.count-distinct-pushdown.enabled") or the catalog session property #raw("count_distinct_pushdown_enabled").

#note[
The connector performs pushdown where performance may be improved, but in order to preserve correctness an operation may not be pushed down. When pushdown of an operation may result in better performance but risks correctness, the connector prioritizes correctness.
]
