#import "/lib/trino-docs.typ": *

#anchor("doc-connector-elasticsearch")
= Elasticsearch connector

The Elasticsearch connector allows access to #link("https://www.elastic.co/products/elasticsearch")[Elasticsearch] data from Trino. This document describes how to configure a catalog with the Elasticsearch connector to run SQL queries against Elasticsearch.

== Requirements

- Elasticsearch 7.x or 8.x
- Network access from the Trino coordinator and workers to the Elasticsearch nodes.

== Configuration

To configure the Elasticsearch connector, create a catalog properties file #raw("etc/catalog/example.properties") with the following contents, replacing the properties as appropriate for your setup:

#code-block("text", "connector.name=elasticsearch
elasticsearch.host=localhost
elasticsearch.port=9200
elasticsearch.default-schema-name=default")

The following table details all general configuration properties:

#list-table((
  ([Property name], [Description], [Default],),
  ([#raw("elasticsearch.host")], [The comma-separated list of host names for the Elasticsearch node to connect to. This property is required.], [],),
  ([#raw("elasticsearch.port")], [Port to use to connect to Elasticsearch.], [#raw("9200")],),
  ([#raw("elasticsearch.default-schema-name")], [The schema that contains all tables defined without a qualifying schema name.], [#raw("default")],),
  ([#raw("elasticsearch.scroll-size")], [Sets the maximum number of hits that can be returned with each #link("https://www.elastic.co/guide/en/elasticsearch/reference/current/search-request-scroll.html#scroll-search-context")[Elasticsearch scroll request].], [#raw("1000")],),
  ([#raw("elasticsearch.scroll-timeout")], [#link(label("ref-prop-type-duration"))[Duration] for Elasticsearch to keep the search context alive for scroll requests.], [#raw("1m")],),
  ([#raw("elasticsearch.request-timeout")], [Timeout #link(label("ref-prop-type-duration"))[duration] for all Elasticsearch requests.], [#raw("10s")],),
  ([#raw("elasticsearch.connect-timeout")], [Timeout #link(label("ref-prop-type-duration"))[duration] for all Elasticsearch connection attempts.], [#raw("1s")],),
  ([#raw("elasticsearch.backoff-init-delay")], [The minimum #link(label("ref-prop-type-duration"))[duration] between backpressure retry attempts for a single request to Elasticsearch. Setting it too low can overwhelm an already struggling cluster.], [#raw("500ms")],),
  ([#raw("elasticsearch.backoff-max-delay")], [The maximum #link(label("ref-prop-type-duration"))[duration] between backpressure retry attempts for a single request to Elasticsearch.], [#raw("20s")],),
  ([#raw("elasticsearch.max-retry-time")], [The maximum #link(label("ref-prop-type-duration"))[duration] across all retry attempts for a single request to Elasticsearch.], [#raw("30s")],),
  ([#raw("elasticsearch.node-refresh-interval")], [#link(label("ref-prop-type-duration"))[Duration] between requests to refresh the list of available Elasticsearch nodes.], [#raw("1m")],),
  ([#raw("elasticsearch.ignore-publish-address")], [Disable using the address published by the Elasticsearch API to connect for queries. Some deployments map Elasticsearch ports to a random public port and enabling this property can help in these cases.], [#raw("false")],)
), header-rows: 1, title: "Elasticsearch configuration properties")

=== Authentication

The connection to Elasticsearch can use AWS or password authentication.

To enable AWS authentication and authorization using IAM policies, the #raw("elasticsearch.security") option must be set to #raw("AWS"). Additionally, the following options must be configured:

#list-table((
  ([Property name], [Description],),
  ([#raw("elasticsearch.aws.region")], [AWS region of the Elasticsearch endpoint. This option is required.],),
  ([#raw("elasticsearch.aws.access-key")], [AWS access key to use to connect to the Elasticsearch domain. If not set, the default AWS credentials provider chain is used.],),
  ([#raw("elasticsearch.aws.secret-key")], [AWS secret key to use to connect to the Elasticsearch domain. If not set, the default AWS credentials provider chain is used.],),
  ([#raw("elasticsearch.aws.iam-role")], [Optional ARN of an IAM role to assume to connect to Elasticsearch. Note that the configured IAM user must be able to assume this role.],),
  ([#raw("elasticsearch.aws.external-id")], [Optional external ID to pass while assuming an AWS IAM role.],)
), header-rows: 1)

To enable password authentication, the #raw("elasticsearch.security") option must be set to #raw("PASSWORD"). Additionally the following options must be configured:

#list-table((
  ([Property name], [Description],),
  ([#raw("elasticsearch.auth.user")], [Username to use to connect to Elasticsearch.],),
  ([#raw("elasticsearch.auth.password")], [Password to use to connect to Elasticsearch.],)
), header-rows: 1)

=== Connection security with TLS

The connector provides additional security options to connect to Elasticsearch clusters with TLS enabled.

If your cluster has globally-trusted certificates, you should only need to enable TLS. If you require custom configuration for certificates, the connector supports key stores and trust stores in P12 \(PKCS\) or Java Key Store \(JKS\) format.

The available configuration values are listed in the following table:

#list-table((
  ([Property name], [Description],),
  ([#raw("elasticsearch.tls.enabled")], [Enables TLS security.],),
  ([#raw("elasticsearch.tls.keystore-path")], [The path to the P12 \(PKCS\) or #link(label("doc-security-inspect-jks"))[JKS] key store.],),
  ([#raw("elasticsearch.tls.truststore-path")], [The path to P12 \(PKCS\) or #link(label("doc-security-inspect-jks"))[JKS] trust store.],),
  ([#raw("elasticsearch.tls.keystore-password")], [The key password for the key store specified by #raw("elasticsearch.tls.keystore-path").],),
  ([#raw("elasticsearch.tls.truststore-password")], [The key password for the trust store specified by #raw("elasticsearch.tls.truststore-path").],),
  ([#raw("elasticsearch.tls.verify-hostnames")], [Flag to determine if the hostnames in the certificates must be verified. Defaults to #raw("true").],)
), header-rows: 1, title: "TLS Security Properties")

#anchor("ref-elasticsearch-type-mapping")

== Type mapping

Because Trino and Elasticsearch each support types that the other does not, this connector #link(label("ref-type-mapping-overview"))[maps some types] when reading data.

=== Elasticsearch type to Trino type mapping

The connector maps Elasticsearch types to the corresponding Trino types according to the following table:

#list-table((
  ([Elasticsearch type], [Trino type], [Notes],),
  ([#raw("BOOLEAN")], [#raw("BOOLEAN")], [],),
  ([#raw("DOUBLE")], [#raw("DOUBLE")], [],),
  ([#raw("FLOAT")], [#raw("REAL")], [],),
  ([#raw("BYTE")], [#raw("TINYINT")], [],),
  ([#raw("SHORT")], [#raw("SMALLINT")], [],),
  ([#raw("INTEGER")], [#raw("INTEGER")], [],),
  ([#raw("LONG")], [#raw("BIGINT")], [],),
  ([#raw("KEYWORD")], [#raw("VARCHAR")], [],),
  ([#raw("TEXT")], [#raw("VARCHAR")], [],),
  ([#raw("DATE")], [#raw("TIMESTAMP")], [For more information, see #link(label("ref-elasticsearch-date-types"))[Elasticsearch connector].],),
  ([#raw("IPADDRESS")], [#raw("IP")], [],)
), header-rows: 1, title: "Elasticsearch type to Trino type mapping")

No other types are supported.

#anchor("ref-elasticsearch-array-types")

=== Array types

Fields in Elasticsearch can contain #link("https://www.elastic.co/guide/en/elasticsearch/reference/current/array.html")[zero or more values], but there is no dedicated array type. To indicate a field contains an array, it can be annotated in a Trino-specific structure in the #link("https://www.elastic.co/guide/en/elasticsearch/reference/current/mapping-meta-field.html")[\_meta] section of the index mapping.

For example, you can have an Elasticsearch index that contains documents with the following structure:

#code-block("json", "{
    \"array_string_field\": [\"trino\",\"the\",\"lean\",\"machine-ohs\"],
    \"long_field\": 314159265359,
    \"id_field\": \"564e6982-88ee-4498-aa98-df9e3f6b6109\",
    \"timestamp_field\": \"2025-09-17T06:22:48.000Z\",
    \"object_field\": {
        \"array_int_field\": [86,75,309],
        \"int_field\": 2
    }
}")

The array fields of this structure can be defined by using the following command to add the field property definition to the #raw("_meta.trino") property of the target index mapping with Elasticsearch available at #raw("search.example.com:9200"):

#code-block("shell", "curl --request PUT \\
    --url search.example.com:9200/doc/_mapping \\
    --header 'content-type: application/json' \\
    --data '
{
    \"_meta\": {
        \"trino\":{
            \"array_string_field\":{
                \"isArray\":true
            },
            \"object_field\":{
                \"array_int_field\":{
                    \"isArray\":true
                }
            },
        }
    }
}'")

#note[
It is not allowed to use #raw("asRawJson") and #raw("isArray") flags simultaneously for the same column.
]

#anchor("ref-elasticsearch-date-types")

=== Date types

The Elasticsearch connector supports only the default #raw("date") type. All other #link("https://www.elastic.co/guide/en/elasticsearch/reference/current/date.html")[date] formats including #link("https://www.elastic.co/guide/en/elasticsearch/reference/current/mapping-date-format.html#built-in-date-formats")[built-in date formats] and #link("https://www.elastic.co/guide/en/elasticsearch/reference/current/mapping-date-format.html#custom-date-formats")[custom date formats] are not supported. Dates with the #link("https://www.elastic.co/guide/en/elasticsearch/reference/current/mapping-date-format.html#mapping-date-format")[format] property are ignored.

=== Raw JSON transform

Documents in Elasticsearch can include more complex structures that are not represented in the mapping. For example, a single #raw("keyword") field can have widely different content including a single #raw("keyword") value, an array, or a multidimensional #raw("keyword") array with any level of nesting.

The following command configures #raw("array_string_field") mapping with Elasticsearch available at #raw("search.example.com:9200"):

#code-block("shell", "curl --request PUT \\
    --url search.example.com:9200/doc/_mapping \\
    --header 'content-type: application/json' \\
    --data '
{
    \"properties\": {
        \"array_string_field\":{
            \"type\": \"keyword\"
        }
    }
}'")

All the following documents are legal for Elasticsearch with #raw("array_string_field") mapping:

#code-block("json", "[
    {
        \"array_string_field\": \"trino\"
    },
    {
        \"array_string_field\": [\"trino\",\"is\",\"the\",\"best\"]
    },
    {
        \"array_string_field\": [\"trino\",[\"is\",\"the\",\"best\"]]
    },
    {
        \"array_string_field\": [\"trino\",[\"is\",[\"the\",\"best\"]]]
    }
]")

See the #link("https://www.elastic.co/guide/en/elasticsearch/reference/current/array.html")[Elasticsearch array documentation] for more details.

Further, Elasticsearch supports types, such as #link("https://www.elastic.co/guide/en/elasticsearch/reference/current/dense-vector.html")[dense\_vector], that are not supported in Trino. These and other types can cause parsing exceptions for users that use of these types in Elasticsearch. To manage all of these scenarios, you can transform fields to raw JSON by annotating it in a Trino-specific structure in the #link("https://www.elastic.co/guide/en/elasticsearch/reference/current/mapping-meta-field.html")[\_meta] section of the index mapping. This indicates to Trino that the field, and all nested fields beneath, need to be cast to a #raw("VARCHAR") field that contains the raw JSON content. These fields can be defined by using the following command to add the field property definition to the #raw("_meta.trino") property of the target index mapping.

#code-block("shell", "curl --request PUT \\
    --url search.example.com:9200/doc/_mapping \\
    --header 'content-type: application/json' \\
    --data '
{
    \"_meta\": {
        \"trino\":{
            \"array_string_field\":{
                \"asRawJson\":true
            }
        }
    }
}'")

This preceding configuration causes Trino to return the #raw("array_string_field") field as a #raw("VARCHAR") containing raw JSON. You can parse these fields with the #link(label("doc-functions-json"))[built-in JSON functions].

#note[
It is not allowed to use #raw("asRawJson") and #raw("isArray") flags simultaneously for the same column.
]

== Special columns

The following hidden columns are available:

#list-table((
  ([Column], [Description],),
  ([#raw("_id")], [The Elasticsearch document ID.],),
  ([#raw("_score")], [The document score returned by the Elasticsearch query.],),
  ([#raw("_source")], [The source of the original document.],)
), header-rows: 1)

#anchor("ref-elasticsearch-full-text-queries")

== Full text queries

Trino SQL queries can be combined with Elasticsearch queries by providing the #link("https://www.elastic.co/guide/en/elasticsearch/reference/current/query-dsl-query-string-query.html#query-string-syntax")[full text query] as part of the table name, separated by a colon. For example:

#code-block("sql", "SELECT * FROM \"tweets: +trino SQL^2\"")

#anchor("ref-elasticsearch-sql-support")

== SQL support

The connector provides #link(label("ref-sql-globally-available"))[globally available] and #link(label("ref-sql-read-operations"))[read operation] statements to access data and metadata in the Elasticsearch catalog.

=== Wildcard table

The connector provides support to query multiple tables using a concise #link("https://www.elastic.co/guide/en/elasticsearch/reference/current/search-multiple-indices.html")[wildcard table] notation.

#code-block("sql", "SELECT *
FROM example.web.\"page_views_*\";")

=== Table functions

The connector provides specific #link(label("doc-functions-table"))[table functions] to access Elasticsearch.

#anchor("ref-elasticsearch-raw-query-function")

==== #raw("raw_query(varchar) -> table")

The #raw("raw_query") function allows you to query the underlying database directly. This function requires #link("https://www.elastic.co/guide/en/elasticsearch/reference/current/query-dsl.html")[Elastic Query DSL] syntax. The full DSL query is pushed down and processed in Elasticsearch. This can be useful for accessing native features which are not available in Trino or for improving query performance in situations where running a query natively may be faster.

The native query passed to the underlying data source is required to return a table as a result set. Only the data source performs validation or security checks for these queries using its own configuration. Trino does not perform these tasks. Only use passthrough queries to read data.

The #raw("raw_query") function requires three parameters:

- #raw("schema"): The schema in the catalog that the query is to be executed on.
- #raw("index"): The index in Elasticsearch to be searched.
- #raw("query"): The query to execute, written in #link("https://www.elastic.co/guide/en/elasticsearch/reference/current/query-dsl.html")[Elastic Query DSL].

Once executed, the query returns a single row containing the resulting JSON payload returned by Elasticsearch.

For example, query the #raw("example") catalog and use the #raw("raw_query") table function to search for documents in the #raw("orders") index where the country name is #raw("ALGERIA") as defined as a JSON-formatted query matcher and passed to the #raw("raw_query") table function in the #raw("query") parameter:

#code-block(none, "SELECT
  *
FROM
  TABLE(
    example.system.raw_query(
      schema => 'sales',
      index => 'orders',
      query => '{
        \"query\": {
          \"match\": {
            \"name\": \"ALGERIA\"
          }
        }
      }'
    )
  );")

#note[
The query engine does not preserve the order of the results of this function. If the passed query contains an #raw("ORDER BY") clause, the function result may not be ordered as expected.
]

== Performance

The connector includes a number of performance improvements, detailed in the following sections.

=== Parallel data access

The connector requests data from multiple nodes of the Elasticsearch cluster for query processing in parallel.

=== Predicate push down

The connector supports #link(label("ref-predicate-pushdown"))[predicate push down] for the following data types:

#list-table((
  ([Elasticsearch], [Trino],),
  ([#raw("boolean")], [#raw("BOOLEAN")],),
  ([#raw("double")], [#raw("DOUBLE")],),
  ([#raw("float")], [#raw("REAL")],),
  ([#raw("byte")], [#raw("TINYINT")],),
  ([#raw("short")], [#raw("SMALLINT")],),
  ([#raw("integer")], [#raw("INTEGER")],),
  ([#raw("long")], [#raw("BIGINT")],),
  ([#raw("keyword")], [#raw("VARCHAR")],),
  ([#raw("date")], [#raw("TIMESTAMP")],)
), header-rows: 1)

No other data types are supported for predicate push down.
