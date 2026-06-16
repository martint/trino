#import "/lib/trino-docs.typ": *

#anchor("doc-connector-opensearch")
= OpenSearch connector

The OpenSearch connector allows access to #link("https://opensearch.org/")[OpenSearch] data from Trino. This document describes how to configure a catalog with the OpenSearch connector to run SQL queries against OpenSearch.

== Requirements

- OpenSearch 1.1.0 or higher.
- Network access from the Trino coordinator and workers to the OpenSearch nodes.

== Configuration

To configure the OpenSearch connector, create a catalog properties file #raw("etc/catalog/example.properties") with the following content, replacing the properties as appropriate for your setup:

#code-block("text", "connector.name=opensearch
opensearch.host=search.example.com
opensearch.port=9200
opensearch.default-schema-name=default")

The following table details all general configuration properties:

#list-table((
  ([Property name], [Description], [Default],),
  ([#raw("opensearch.host")], [The comma-separated list of host names of the OpenSearch cluster. This property is required.], [],),
  ([#raw("opensearch.port")], [Port to use to connect to OpenSearch.], [#raw("9200")],),
  ([#raw("opensearch.default-schema-name")], [The schema that contains all tables defined without a qualifying schema name.], [#raw("default")],),
  ([#raw("opensearch.scroll-size")], [Sets the maximum number of hits that can be returned with each #link("https://opensearch.org/docs/latest/api-reference/scroll/")[OpenSearch scroll request].], [#raw("1000")],),
  ([#raw("opensearch.scroll-timeout")], [#link(label("ref-prop-type-duration"))[Duration] for OpenSearch to keep the search context alive for scroll requests.], [#raw("1m")],),
  ([#raw("opensearch.request-timeout")], [Timeout #link(label("ref-prop-type-duration"))[duration] for all OpenSearch requests.], [#raw("10s")],),
  ([#raw("opensearch.connect-timeout")], [Timeout #link(label("ref-prop-type-duration"))[duration] for all OpenSearch connection attempts.], [#raw("1s")],),
  ([#raw("opensearch.backoff-init-delay")], [The minimum #link(label("ref-prop-type-duration"))[duration] between backpressure retry attempts for a single request to OpenSearch. Setting it too low can overwhelm an already struggling cluster.], [#raw("500ms")],),
  ([#raw("opensearch.backoff-max-delay")], [The maximum #link(label("ref-prop-type-duration"))[duration] between backpressure retry attempts for a single request.], [#raw("20s")],),
  ([#raw("opensearch.max-retry-time")], [The maximum #link(label("ref-prop-type-duration"))[duration] across all retry attempts for a single request.], [#raw("30s")],),
  ([#raw("opensearch.node-refresh-interval")], [#link(label("ref-prop-type-duration"))[Duration] between requests to refresh the list of available OpenSearch nodes.], [#raw("1m")],),
  ([#raw("opensearch.ignore-publish-address")], [Disable using the address published by the OpenSearch API to connect for queries. Some deployments map OpenSearch ports to a random public port and enabling this property can help in these cases.], [#raw("false")],),
  ([#raw("opensearch.projection-pushdown-enabled")], [Read only projected fields from row columns while performing #raw("SELECT") queries], [#raw("true")],)
), header-rows: 1, title: "OpenSearch configuration properties")

=== Authentication

The connection to OpenSearch can use AWS or password authentication.

To enable AWS authentication and authorization using IAM policies, the #raw("opensearch.security") option must be set to #raw("AWS"). Additionally, the following options must be configured:

#list-table((
  ([Property name], [Description],),
  ([#raw("opensearch.aws.region")], [AWS region of the OpenSearch endpoint. This option is required.],),
  ([#raw("opensearch.aws.access-key")], [AWS access key to use to connect to the OpenSearch domain. If not set, the default AWS credentials provider chain is used.],),
  ([#raw("opensearch.aws.secret-key")], [AWS secret key to use to connect to the OpenSearch domain. If not set, the default AWS credentials provider chain is used.],),
  ([#raw("opensearch.aws.iam-role")], [Optional ARN of an IAM role to assume to connect to OpenSearch. Note that the configured IAM user must be able to assume this role.],),
  ([#raw("opensearch.aws.external-id")], [Optional external ID to pass while assuming an AWS IAM role.],),
  ([#raw("opensearch.aws.deployment-type")], [AWS OpenSearch deployment type. Possible values are #raw("PROVISIONED") & #raw("SERVERLESS"). This option is required.],)
), header-rows: 1)

To enable password authentication, the #raw("opensearch.security") option must be set to #raw("PASSWORD"). Additionally the following options must be configured:

#list-table((
  ([Property name], [Description],),
  ([#raw("opensearch.auth.user")], [Username to use to connect to OpenSearch.],),
  ([#raw("opensearch.auth.password")], [Password to use to connect to OpenSearch.],)
), header-rows: 1)

=== Connection security with TLS

The connector provides additional security options to connect to OpenSearch clusters with TLS enabled.

If your cluster uses globally-trusted certificates, you only need to enable TLS. If you require custom configuration for certificates, the connector supports key stores and trust stores in P12 \(PKCS\) or Java Key Store \(JKS\) format.

The available configuration values are listed in the following table:

#list-table((
  ([Property name], [Description],),
  ([#raw("opensearch.tls.enabled")], [Enable TLS security. Defaults to #raw("false").],),
  ([#raw("opensearch.tls.keystore-path")], [The path to the P12 \(PKCS\) or #link(label("doc-security-inspect-jks"))[JKS] key store.],),
  ([#raw("opensearch.tls.truststore-path")], [The path to P12 \(PKCS\) or #link(label("doc-security-inspect-jks"))[JKS] trust store.],),
  ([#raw("opensearch.tls.keystore-password")], [The password for the key store specified by #raw("opensearch.tls.keystore-path").],),
  ([#raw("opensearch.tls.truststore-password")], [The password for the trust store specified by #raw("opensearch.tls.truststore-path").],),
  ([#raw("opensearch.tls.verify-hostnames")], [Flag to determine if the hostnames in the certificates must be verified. Defaults to #raw("true").],)
), header-rows: 1, title: "TLS configuration properties")

#anchor("ref-opensearch-type-mapping")

== Type mapping

Because Trino and OpenSearch each support types that the other does not, the connector #link(label("ref-type-mapping-overview"))[maps some types] when reading data.

=== OpenSearch type to Trino type mapping

The connector maps OpenSearch types to the corresponding Trino types according to the following table:

#list-table((
  ([OpenSearch type], [Trino type], [Notes],),
  ([#raw("BOOLEAN")], [#raw("BOOLEAN")], [],),
  ([#raw("DOUBLE")], [#raw("DOUBLE")], [],),
  ([#raw("FLOAT")], [#raw("REAL")], [],),
  ([#raw("BYTE")], [#raw("TINYINT")], [],),
  ([#raw("SHORT")], [#raw("SMALLINT")], [],),
  ([#raw("INTEGER")], [#raw("INTEGER")], [],),
  ([#raw("LONG")], [#raw("BIGINT")], [],),
  ([#raw("KEYWORD")], [#raw("VARCHAR")], [],),
  ([#raw("TEXT")], [#raw("VARCHAR")], [],),
  ([#raw("DATE")], [#raw("TIMESTAMP")], [For more information, see #link(label("ref-opensearch-date-types"))[OpenSearch connector].],),
  ([#raw("IPADDRESS")], [#raw("IP")], [],)
), header-rows: 1, title: "OpenSearch type to Trino type mapping")

No other types are supported.

#anchor("ref-opensearch-array-types")

=== Array types

Fields in OpenSearch can contain #link("https://opensearch.org/docs/latest/field-types/supported-field-types/date/#custom-formats")[zero or more values], but there is no dedicated array type. To indicate a field contains an array, it can be annotated in a Trino-specific structure in the #link("https://opensearch.org/docs/latest/field-types/index/#get-a-mapping")[\_meta] section of the index mapping in OpenSearch.

For example, you can have an OpenSearch index that contains documents with the following structure:

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

The array fields of this structure can be defined by using the following command to add the field property definition to the #raw("_meta.trino") property of the target index mapping with OpenSearch available at #raw("search.example.com:9200"):

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

#anchor("ref-opensearch-date-types")

=== Date types

The OpenSearch connector supports only the default #raw("date") type. All other OpenSearch #link("https://opensearch.org/docs/latest/field-types/supported-field-types/date/")[date] formats including #link("https://opensearch.org/docs/latest/field-types/supported-field-types/date/#custom-formats")[built-in date formats] and #link("https://opensearch.org/docs/latest/field-types/supported-field-types/date/#custom-formats")[custom date formats] are not supported. Dates with the #link("https://opensearch.org/docs/latest/query-dsl/term/range/#format")[format] property are ignored.

=== Raw JSON transform

Documents in OpenSearch can include more complex structures that are not represented in the mapping. For example, a single #raw("keyword") field can have widely different content including a single #raw("keyword") value, an array, or a multidimensional #raw("keyword") array with any level of nesting.

The following command configures #raw("array_string_field") mapping with OpenSearch available at #raw("search.example.com:9200"):

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

All the following documents are legal for OpenSearch with #raw("array_string_field") mapping:

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

See the #link("https://opensearch.org/docs/latest/field-types/supported-field-types/index/#arrays")[OpenSearch array documentation] for more details.

Further, OpenSearch supports types, such as #link("https://opensearch.org/docs/latest/field-types/supported-field-types/knn-vector/")[k-NN vector], that are not supported in Trino. These and other types can cause parsing exceptions for users that use of these types in OpenSearch. To manage all of these scenarios, you can transform fields to raw JSON by annotating it in a Trino-specific structure in the #link("https://opensearch.org/docs/latest/field-types/index/")[\_meta] section of the OpenSearch index mapping. This indicates to Trino that the field, and all nested fields beneath, must be cast to a #raw("VARCHAR") field that contains the raw JSON content. These fields can be defined by using the following command to add the field property definition to the #raw("_meta.trino") property of the target index mapping.

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

The preceding configuration causes Trino to return the #raw("array_string_field") field as a #raw("VARCHAR") containing raw JSON. You can parse these fields with the #link(label("doc-functions-json"))[built-in JSON functions].

#note[
It is not allowed to use #raw("asRawJson") and #raw("isArray") flags simultaneously for the same column.
]

== Special columns

The following hidden columns are available:

#list-table((
  ([Column], [Description],),
  ([#raw("_id")], [The OpenSearch document ID.],),
  ([#raw("_score")], [The document score returned by the OpenSearch query.],),
  ([#raw("_source")], [The source of the original document.],)
), header-rows: 1)

#anchor("ref-opensearch-sql-support")

== SQL support

The connector provides #link(label("ref-sql-globally-available"))[globally available] and #link(label("ref-sql-read-operations"))[read operation] statements to access data and metadata in the OpenSearch catalog.

=== Wildcard table

The connector provides support to query multiple tables using a concise #link("https://opensearch.org/docs/latest/api-reference/multi-search/#metadata-only-options")[wildcard table] notation.

#code-block("sql", "SELECT *
FROM example.web.\"page_views_*\";")

=== Table functions

The connector provides specific #link(label("doc-functions-table"))[table functions] to access OpenSearch.

#anchor("ref-opensearch-raw-query-function")

==== #raw("raw_query(varchar) -> table")

The #raw("raw_query") function allows you to query the underlying database directly using the #link("https://opensearch.org/docs/latest/query-dsl/index/")[OpenSearch Query DSL] syntax. The full DSL query is pushed down and processed in OpenSearch. This can be useful for accessing native features which are not available in Trino, or for improving query performance in situations where running a query natively may be faster.

The native query passed to the underlying data source is required to return a table as a result set. Only the data source performs validation or security checks for these queries using its own configuration. Trino does not perform these tasks. Only use passthrough queries to read data.

The #raw("raw_query") function requires three parameters:

- #raw("schema"): The schema in the catalog that the query is to be executed on.
- #raw("index"): The index in OpenSearch to search.
- #raw("query"): The query to execute, written in #link("https://opensearch.org/docs/latest/query-dsl")[OpenSearch Query DSL].

Once executed, the query returns a single row containing the resulting JSON payload returned by OpenSearch.

For example, query the #raw("example") catalog and use the #raw("raw_query") table function to search for documents in the #raw("orders") index where the country name is #raw("ALGERIA") as defined as a JSON-formatted query matcher and passed to the #raw("raw_query") table function in the #raw("query") parameter:

#code-block("sql", "SELECT
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

The connector requests data from multiple nodes of the OpenSearch cluster for query processing in parallel.

=== Predicate push down

The connector supports #link(label("ref-predicate-pushdown"))[predicate push down] for the following data types:

#list-table((
  ([OpenSearch], [Trino],),
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
