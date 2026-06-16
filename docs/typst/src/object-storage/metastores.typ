#import "/lib/trino-docs.typ": *

#anchor("doc-object-storage-metastores")
= Metastores

Object storage access is mediated through a #emph[metastore]. Metastores provide information on directory structure, file format, and metadata about the stored data. Object storage connectors support the use of one or more metastores. A supported metastore is required to use any object storage connector.

Additional configuration is required in order to access tables with Athena partition projection metadata or implement first class support for Avro tables. These requirements are discussed later in this topic.

#anchor("ref-general-metastore-properties")

== General metastore configuration properties

The following table describes general metastore configuration properties, most of which are used with either metastore.

At a minimum, each Delta Lake, Hive or Hudi object storage catalog file must set the #raw("hive.metastore") configuration property to define the type of metastore to use. Iceberg catalogs instead use the #raw("iceberg.catalog.type") configuration property to define the type of metastore to use.

Additional configuration properties specific to the Thrift and Glue Metastores are also available. They are discussed later in this topic.

#list-table((
  ([Property Name], [Description], [Default],),
  ([#raw("hive.metastore")], [The type of Hive metastore to use. Trino currently supports the default Hive Thrift metastore \(#raw("thrift")\), and the AWS Glue Catalog \(#raw("glue")\) as metadata sources. You must use this for all object storage catalogs except Iceberg.], [#raw("thrift")],),
  ([#raw("iceberg.catalog.type")], [The Iceberg table format manages most metadata in metadata files in the object storage itself. A small amount of metadata, however, still requires the use of a metastore. In the Iceberg ecosystem, these smaller metastores are called Iceberg metadata catalogs, or just catalogs. The examples in each subsection depict the contents of a Trino catalog file that uses the Iceberg connector to configures different Iceberg metadata catalogs.

You must set this property in all Iceberg catalog property files. Valid values are #raw("hive_metastore"), #raw("glue"), #raw("jdbc"), #raw("rest"), #raw("nessie"), and #raw("snowflake").], [#raw("hive_metastore")],),
  ([#raw("hive.metastore-cache.cache-partitions")], [Enable caching for partition metadata. You can disable caching to avoid inconsistent behavior that results from it.], [#raw("true")],),
  ([#raw("hive.metastore-cache.cache-missing")], [Enable caching the fact that a table is missing to prevent future metastore calls for that table.], [#raw("true")],),
  ([#raw("hive.metastore-cache.cache-missing-partitions")], [Enable caching the fact that a partition is missing to prevent future metastore calls for that partition.], [#raw("false")],),
  ([#raw("hive.metastore-cache.cache-missing-stats")], [Enable caching the fact that table statistics for a specific table are missing to prevent future metastore calls.], [#raw("false")],),
  ([#raw("hive.metastore-cache-ttl")], [#link(label("ref-prop-type-duration"))[Duration] of how long cached metastore data is considered valid.], [#raw("0s")],),
  ([#raw("hive.metastore-stats-cache-ttl")], [#link(label("ref-prop-type-duration"))[Duration] of how long cached metastore statistics are considered valid.], [#raw("5m")],),
  ([#raw("hive.metastore-cache-maximum-size")], [Maximum number of metastore data objects in the Hive metastore cache.], [#raw("20000")],),
  ([#raw("hive.metastore-refresh-interval")], [Asynchronously refresh cached metastore data after access if it is older than this but is not yet expired, allowing subsequent accesses to see fresh data.], [],),
  ([#raw("hive.metastore-refresh-max-threads")], [Maximum threads used to refresh cached metastore data.], [#raw("10")],),
  ([#raw("hive.user-metastore-cache-ttl")], [#link(label("ref-prop-type-duration"))[Duration] of how long cached metastore statistics, which are user specific in user impersonation scenarios, are considered valid.], [#raw("0s")],),
  ([#raw("hive.user-metastore-cache-maximum-size")], [Maximum number of metastore data objects in the Hive metastore cache, which are user specific in user impersonation scenarios.], [#raw("1000")],),
  ([#raw("hive.hide-delta-lake-tables")], [Controls whether to hide Delta Lake tables in table listings. Currently applies only when using the AWS Glue metastore.], [#raw("false")],)
), header-rows: 1, title: "General metastore configuration properties")

#anchor("ref-hive-thrift-metastore")

== Thrift metastore configuration properties

In order to use a Hive Thrift metastore, you must configure the metastore with #raw("hive.metastore=thrift") and provide further details with the following properties:

#list-table((
  ([Property name], [Description], [Default],),
  ([#raw("hive.metastore.uri")], [The URIs of the Hive metastore to connect to using the Thrift protocol. If a comma-separated list of URIs is provided, the first URI is used by default, and the rest of the URIs are fallback metastores. This property is required. Example: #raw("thrift://192.0.2.3:9083") or #raw("thrift://192.0.2.3:9083,thrift://192.0.2.4:9083")], [],),
  ([#raw("hive.metastore.username")], [The username Trino uses to access the Hive metastore.], [],),
  ([#raw("hive.metastore.authentication.type")], [Hive metastore authentication type. Possible values are #raw("NONE") or #raw("KERBEROS").], [#raw("NONE")],),
  ([#raw("hive.metastore.thrift.client.connect-timeout")], [Socket connect timeout for metastore client.], [#raw("10s")],),
  ([#raw("hive.metastore.thrift.client.read-timeout")], [Socket read timeout for metastore client.], [#raw("10s")],),
  ([#raw("hive.metastore.thrift.impersonation.enabled")], [Enable Hive metastore end user impersonation.], [],),
  ([#raw("hive.metastore.thrift.use-spark-table-statistics-fallback")], [Enable usage of table statistics generated by Apache Spark when Hive table statistics are not available.], [#raw("true")],),
  ([#raw("hive.metastore.thrift.delegation-token.cache-ttl")], [Time to live delegation token cache for metastore.], [#raw("1h")],),
  ([#raw("hive.metastore.thrift.delegation-token.cache-maximum-size")], [Delegation token cache maximum size.], [#raw("1000")],),
  ([#raw("hive.metastore.thrift.client.ssl.enabled")], [Use SSL when connecting to metastore.], [#raw("false")],),
  ([#raw("hive.metastore.thrift.client.ssl.key")], [Path to private key and client certification \(key store\).], [],),
  ([#raw("hive.metastore.thrift.client.ssl.key-password")], [Password for the private key.], [],),
  ([#raw("hive.metastore.thrift.client.ssl.trust-certificate")], [Path to the server certificate chain \(trust store\). Required when SSL is enabled.], [],),
  ([#raw("hive.metastore.thrift.client.ssl.trust-certificate-password")], [Password for the trust store.], [],),
  ([#raw("hive.metastore.service.principal")], [The Kerberos principal of the Hive metastore service.], [],),
  ([#raw("hive.metastore.client.principal")], [The Kerberos principal that Trino uses when connecting to the Hive metastore service.], [],),
  ([#raw("hive.metastore.client.keytab")], [Hive metastore client keytab location.], [],),
  ([#raw("hive.metastore.thrift.delete-files-on-drop")], [Actively delete the files for managed tables when performing drop table or partition operations, for cases when the metastore does not delete the files.], [#raw("false")],),
  ([#raw("hive.metastore.thrift.assume-canonical-partition-keys")], [Allow the metastore to assume that the values of partition columns can be converted to string values. This can lead to performance improvements in queries which apply filters on the partition columns. Partition keys with a #raw("TIMESTAMP") type do not get canonicalized.], [#raw("false")],),
  ([#raw("hive.metastore.thrift.client.socks-proxy")], [SOCKS proxy to use for the Thrift Hive metastore.], [],),
  ([#raw("hive.metastore.thrift.client.max-retries")], [Maximum number of retry attempts for metastore requests.], [#raw("9")],),
  ([#raw("hive.metastore.thrift.client.backoff-scale-factor")], [Scale factor for metastore request retry delay.], [#raw("2.0")],),
  ([#raw("hive.metastore.thrift.client.max-retry-time")], [Total allowed time limit for a metastore request to be retried.], [#raw("30s")],),
  ([#raw("hive.metastore.thrift.client.min-backoff-delay")], [Minimum delay between metastore request retries.], [#raw("1s")],),
  ([#raw("hive.metastore.thrift.client.max-backoff-delay")], [Maximum delay between metastore request retries.], [#raw("1s")],),
  ([#raw("hive.metastore.thrift.txn-lock-max-wait")], [Maximum time to wait to acquire hive transaction lock.], [#raw("10m")],),
  ([#raw("hive.metastore.thrift.catalog-name")], [The term "Hive metastore catalog name" refers to the abstraction concept within Hive, enabling various systems to connect to distinct, independent catalogs stored in the metastore. By default, the catalog name in Hive metastore is set to "hive". When this configuration property is left empty, the default catalog of the Hive metastore will be accessed.], [],)
), header-rows: 1, title: "Thrift metastore configuration properties")

#anchor("ref-iceberg-hive-catalog")

=== Iceberg-specific Hive catalog configuration properties

When using the Hive catalog, the Iceberg connector supports the same #link(label("ref-hive-thrift-metastore"))[general Thrift metastore configuration properties] as previously described with the following additional property:

#list-table((
  ([Property name], [Description], [Default],),
  ([#raw("iceberg.hive-catalog.locking-enabled")], [Commit to tables using Hive locks.], [#raw("true")],)
), header-rows: 1, title: "Iceberg Hive catalog configuration property")

#warning[
Setting #raw("iceberg.hive-catalog.locking-enabled=false") will cause the catalog to commit to tables without using Hive locks. This should only be set to false if all following conditions are met:

- #link("https://issues.apache.org/jira/browse/HIVE-26882")[HIVE-26882] is available on the Hive metastore server. Requires version 2.3.10, 4.0.0-beta-1 or later.
- #link("https://issues.apache.org/jira/browse/HIVE-28121")[HIVE-28121] is available on the Hive metastore server, if it is backed by MySQL or MariaDB. Requires version 2.3.10, 4.1.0, 4.0.1 or later.
- All other catalogs committing to tables that this catalogs commits to are also on Iceberg 1.3 or later, and disabled Hive locks on commit.
]

#anchor("ref-hive-thrift-metastore-authentication")

=== Thrift metastore authentication

In a Kerberized Hadoop cluster, Trino connects to the Hive metastore Thrift service using SASL and authenticates using Kerberos. Kerberos authentication for the metastore is configured in the connector's properties file using the following optional properties:

#list-table((
  ([Property value], [Description], [Default],),
  ([#raw("hive.metastore.authentication.type")], [Hive metastore authentication type. One of #raw("NONE") or #raw("KERBEROS"). When using the default value of #raw("NONE"), Kerberos authentication is disabled, and no other properties must be configured.

When set to #raw("KERBEROS") the Hive connector connects to the Hive metastore Thrift service using SASL and authenticate using Kerberos.], [#raw("NONE")],),
  ([#raw("hive.metastore.thrift.impersonation.enabled")], [Enable Hive metastore end user impersonation. See #link(label("ref-hive-security-metastore-impersonation"))[Metastores] for more information.], [#raw("false")],),
  ([#raw("hive.metastore.service.principal")], [The Kerberos principal of the Hive metastore service. The coordinator uses this to authenticate the Hive metastore.

The #raw("_HOST") placeholder can be used in this property value. When connecting to the Hive metastore, the Hive connector substitutes in the hostname of the #strong[metastore] server it is connecting to. This is useful if the metastore runs on multiple hosts.

Example: #raw("hive/hive-server-host@EXAMPLE.COM") or #raw("hive/_HOST@EXAMPLE.COM").], [],),
  ([#raw("hive.metastore.client.principal")], [The Kerberos principal that Trino uses when connecting to the Hive metastore service.

Example: #raw("trino/trino-server-node@EXAMPLE.COM") or #raw("trino/_HOST@EXAMPLE.COM").

The #raw("_HOST") placeholder can be used in this property value. When connecting to the Hive metastore, the Hive connector substitutes in the hostname of the #strong[worker] node Trino is running on. This is useful if each worker node has its own Kerberos principal.

Unless #link(label("ref-hive-security-metastore-impersonation"))[Metastores] is enabled, the principal specified by #raw("hive.metastore.client.principal") must have sufficient privileges to remove files and directories within the #raw("hive/warehouse") directory.

#strong[Warning:] If the principal does have sufficient permissions, only the metadata is removed, and the data continues to consume disk space. This occurs because the Hive metastore is responsible for deleting the internal table data. When the metastore is configured to use Kerberos authentication, all the HDFS operations performed by the metastore are impersonated. Errors deleting data are silently ignored.], [],),
  ([#raw("hive.metastore.client.keytab")], [The path to the keytab file that contains a key for the principal specified by #raw("hive.metastore.client.principal"). This file must be readable by the operating system user running Trino.], [],)
), header-rows: 1, title: "Hive metastore Thrift service authentication properties")

The following sections describe the configuration properties and values needed for the various authentication configurations needed to use the Hive metastore Thrift service with the Hive connector.

==== Default #raw("NONE") authentication without impersonation

#code-block("text", "hive.metastore.authentication.type=NONE")

The default authentication type for the Hive metastore is #raw("NONE"). When the authentication type is #raw("NONE"), Trino connects to an unsecured Hive metastore. Kerberos is not used.

#anchor("ref-hive-security-metastore-impersonation")

==== #raw("KERBEROS") authentication with impersonation

#code-block("text", "hive.metastore.authentication.type=KERBEROS
hive.metastore.thrift.impersonation.enabled=true
hive.metastore.service.principal=hive/hive-metastore-host.example.com@EXAMPLE.COM
hive.metastore.client.principal=trino@EXAMPLE.COM
hive.metastore.client.keytab=/etc/trino/hive.keytab")

When the authentication type for the Hive metastore Thrift service is #raw("KERBEROS"), Trino connects as the Kerberos principal specified by the property #raw("hive.metastore.client.principal"). Trino authenticates this principal using the keytab specified by the #raw("hive.metastore.client.keytab") property, and verifies that the identity of the metastore matches #raw("hive.metastore.service.principal").

When using #raw("KERBEROS") Metastore authentication with impersonation, the principal specified by the #raw("hive.metastore.client.principal") property must be allowed to impersonate the current Trino user, as discussed in the section #link(label("ref-hdfs-security-impersonation"))[HDFS file system support].

Keytab files must be distributed to every node in the Trino cluster.

#anchor("ref-hive-glue-metastore")

== AWS Glue catalog configuration properties

In order to use an AWS Glue catalog, you must configure your catalog file as follows:

#raw("hive.metastore=glue") and provide further details with the following properties:

#list-table((
  ([Property Name], [Description], [Default],),
  ([#raw("hive.metastore.glue.region")], [AWS region of the Glue Catalog. This is required when not running in EC2, or when the catalog is in a different region. Example: #raw("us-east-1")], [],),
  ([#raw("hive.metastore.glue.endpoint-url")], [Glue API endpoint URL \(optional\). Example: #raw("https://glue.us-east-1.amazonaws.com")], [],),
  ([#raw("hive.metastore.glue.sts.region")], [AWS region of the STS service to authenticate with. This is required when running in a GovCloud region. Example: #raw("us-gov-east-1")], [],),
  ([#raw("hive.metastore.glue.sts.endpoint")], [STS endpoint URL to use when authenticating to Glue \(optional\). Example: #raw("https://sts.us-gov-east-1.amazonaws.com")], [],),
  ([#raw("hive.metastore.glue.pin-client-to-current-region")], [Pin Glue requests to the same region as the EC2 instance where Trino is running.], [#raw("false")],),
  ([#raw("hive.metastore.glue.max-connections")], [Max number of concurrent connections to Glue.], [#raw("30")],),
  ([#raw("hive.metastore.glue.max-error-retries")], [Maximum number of error retries for the Glue client.], [#raw("10")],),
  ([#raw("hive.metastore.glue.default-warehouse-dir")], [Default warehouse directory for schemas created without an explicit #raw("location") property.], [],),
  ([#raw("hive.metastore.glue.use-web-identity-token-credentials-provider")], [If you are running Trino on Amazon EKS, and authenticate using a Kubernetes service account, you can set this property to #raw("true"). Setting to #raw("true") forces Trino to not try using different credential providers from the default credential provider chain, and instead directly use credentials from the service account.], [#raw("false")],),
  ([#raw("hive.metastore.glue.aws-access-key")], [AWS access key to use to connect to the Glue Catalog. If specified along with #raw("hive.metastore.glue.aws-secret-key"), this parameter takes precedence over #raw("hive.metastore.glue.iam-role").], [],),
  ([#raw("hive.metastore.glue.aws-secret-key")], [AWS secret key to use to connect to the Glue Catalog. If specified along with #raw("hive.metastore.glue.aws-access-key"), this parameter takes precedence over #raw("hive.metastore.glue.iam-role").], [],),
  ([#raw("hive.metastore.glue.catalogid")], [The ID of the Glue Catalog in which the metadata database resides.], [],),
  ([#raw("hive.metastore.glue.iam-role")], [ARN of an IAM role to assume when connecting to the Glue Catalog.], [],),
  ([#raw("hive.metastore.glue.external-id")], [External ID for the IAM role trust policy when connecting to the Glue Catalog.], [],),
  ([#raw("hive.metastore.glue.partitions-segments")], [Number of segments for partitioned Glue tables.], [#raw("5")],),
  ([#raw("hive.metastore.glue.skip-archive")], [AWS Glue has the ability to archive older table versions and a user can roll back the table to any historical version if needed. By default, the Hive Connector backed by Glue will not skip the archival of older table versions.], [#raw("false")],)
), header-rows: 1, title: "AWS Glue catalog configuration properties")

#anchor("ref-iceberg-glue-catalog")

=== Iceberg-specific Glue catalog configuration properties

When using the Glue catalog, the Iceberg connector supports the same #link(label("ref-hive-glue-metastore"))[general Glue configuration properties] as previously described with the following additional property:

#list-table((
  ([Property name], [Description], [Default],),
  ([#raw("iceberg.glue.cache-table-metadata")], [While updating the table in AWS Glue, store the table metadata with the purpose of accelerating #raw("information_schema.columns") and #raw("system.metadata.table_comments") queries.], [#raw("true")],)
), header-rows: 1, title: "Iceberg Glue catalog configuration property")

== Iceberg-specific metastores

The Iceberg table format manages most metadata in metadata files in the object storage itself. A small amount of metadata, however, still requires the use of a metastore. In the Iceberg ecosystem, these smaller metastores are called Iceberg metadata catalogs, or just catalogs.

You can use a general metastore such as an HMS or AWS Glue, or you can use the Iceberg-specific REST, Nessie or JDBC metadata catalogs, as discussed in this section.

#anchor("ref-iceberg-rest-catalog")

=== REST catalog

In order to use the Iceberg REST catalog, configure the catalog type with #raw("iceberg.catalog.type=rest"), and provide further details with the following properties:

#list-table((
  ([Property name], [Description],),
  ([#raw("iceberg.rest-catalog.uri")], [REST server API endpoint URI \(required\). Example: #raw("http://iceberg-with-rest:8181")],),
  ([#raw("iceberg.rest-catalog.prefix")], [The prefix for the resource path to use with the REST catalog server \(optional\). Example: #raw("dev")],),
  ([#raw("iceberg.rest-catalog.warehouse")], [Warehouse identifier\/location for the catalog \(optional\). Example: #raw("s3://my_bucket/warehouse_location")],),
  ([#raw("iceberg.rest-catalog.security")], [The type of security to use \(default: #raw("NONE")\). Possible values are #raw("NONE"), #raw("SIGV4"), #raw("GOOGLE") or #raw("OAUTH2"). #raw("OAUTH2") requires either a #raw("token") or a #raw("credential").],),
  ([#raw("iceberg.rest-catalog.session")], [Session information included when communicating with the REST Catalog. Options are #raw("NONE") or #raw("USER") \(default: #raw("NONE")\).],),
  ([#raw("iceberg.rest-catalog.connection-timeout")], [Maximum time #link(label("ref-prop-type-duration"))[Duration] allowed for socket connection requests to complete before timing out.],),
  ([#raw("iceberg.rest-catalog.socket-timeout")], [Maximum time #link(label("ref-prop-type-duration"))[Duration] allowed socket read\/write operations before timing out.],),
  ([#raw("iceberg.rest-catalog.session-timeout")], [#link(label("ref-prop-type-duration"))[Duration] to keep authentication session in cache. Defaults to #raw("1h").],),
  ([#raw("iceberg.rest-catalog.oauth2.token")], [The bearer token used for interactions with the server. A #raw("token") or #raw("credential") is required for #raw("OAUTH2") security. Example: #raw("AbCdEf123456")],),
  ([#raw("iceberg.rest-catalog.oauth2.credential")], [The credential to exchange for a token in the OAuth2 client credentials flow with the server. A #raw("token") or #raw("credential") is required for #raw("OAUTH2") security. Example: #raw("AbCdEf123456")],),
  ([#raw("iceberg.rest-catalog.oauth2.scope")], [Scope to be used when communicating with the REST Catalog. Applicable only when using #raw("credential").],),
  ([#raw("iceberg.rest-catalog.oauth2.server-uri")], [The endpoint to retrieve access token from OAuth2 Server.],),
  ([#raw("iceberg.rest-catalog.oauth2.token-refresh-enabled")], [Controls whether a token should be refreshed if information about its expiration time is available. Defaults to #raw("true")],),
  ([#raw("iceberg.rest-catalog.oauth2.token-exchange-enabled")], [Controls whether to use the token exchange flow to acquire new tokens. Defaults to #raw("true")],),
  ([#raw("iceberg.rest-catalog.vended-credentials-enabled")], [Use credentials provided by the REST backend for file system access. Defaults to #raw("false").],),
  ([#raw("iceberg.rest-catalog.nested-namespace-enabled")], [Support querying objects under nested namespace. Defaults to #raw("false").],),
  ([#raw("iceberg.rest-catalog.view-endpoints-enabled")], [Enable view endpoints. Defaults to #raw("true").],),
  ([#raw("iceberg.rest-catalog.signing-name")], [AWS SigV4 signing service name. Defaults to #raw("execute-api").],),
  ([#raw("iceberg.rest-catalog.google-project-id")], [Google Cloud project name. This property must be set when #raw("iceberg.rest-catalog.security") config property is set to #raw("GOOGLE"). Example: #raw("development-123456").],),
  ([#raw("iceberg.rest-catalog.case-insensitive-name-matching")], [Match namespace, table, and view names case insensitively. Defaults to #raw("false").],),
  ([#raw("iceberg.rest-catalog.case-insensitive-name-matching.cache-ttl")], [#link(label("ref-prop-type-duration"))[Duration] for which case-insensitive namespace, table, and view names are cached. Defaults to #raw("1m").],),
  ([#raw("iceberg.rest-catalog.http-headers")], [Additional #emph[non-sensitive] HTTP headers to include with requests to the REST catalog. Example: #raw("Header-1: value 1, Header-2: value 2").],)
), header-rows: 1, title: "Iceberg REST catalog configuration properties")

The following example shows a minimal catalog configuration using an Iceberg REST metadata catalog:

#code-block("properties", "connector.name=iceberg
iceberg.catalog.type=rest
iceberg.rest-catalog.uri=http://iceberg-with-rest:8181")

#raw("iceberg.security") must be #raw("read_only") when connecting to Databricks Unity catalog using an Iceberg REST catalog:

#code-block("properties", "connector.name=iceberg
iceberg.catalog.type=rest
iceberg.rest-catalog.uri=https://dbc-12345678-9999.cloud.databricks.com/api/2.1/unity-catalog/iceberg
iceberg.security=read_only
iceberg.rest-catalog.security=OAUTH2
iceberg.rest-catalog.oauth2.token=***")

#raw("iceberg.rest-catalog.security") must be #raw("GOOGLE") when connecting to BigLake metastore using an Iceberg REST catalog.

#code-block("properties", "connector.name=iceberg
iceberg.catalog.type=rest
iceberg.unique-table-location=false
iceberg.rest-catalog.warehouse=gs://example-bucket
iceberg.rest-catalog.uri=https://biglake.googleapis.com/iceberg/v1beta/restcatalog
iceberg.rest-catalog.security=GOOGLE
iceberg.rest-catalog.google-project-id=example-project-id
iceberg.rest-catalog.view-endpoints-enabled=false
fs.gcs.enabled=true
gcs.json-key-file-path=/path/to/gcs_keyfile.json")

The REST catalog supports #link(label("ref-sql-view-management"))[view management] using the #link("https://iceberg.apache.org/view-spec/")[Iceberg View specification].

The REST catalog does not support #link(label("ref-sql-materialized-view-management"))[materialized view management].

#anchor("ref-iceberg-jdbc-catalog")

=== JDBC catalog

The Iceberg JDBC catalog is supported for the Iceberg connector.  At a minimum, #raw("iceberg.jdbc-catalog.driver-class"), #raw("iceberg.jdbc-catalog.connection-url"), #raw("iceberg.jdbc-catalog.default-warehouse-dir"), and #raw("iceberg.jdbc-catalog.catalog-name") must be configured. When using any database besides PostgreSQL, a JDBC driver jar file must be placed in the plugin directory.

#list-table((
  ([Property name], [Description],),
  ([#raw("iceberg.jdbc-catalog.driver-class")], [JDBC driver class name.],),
  ([#raw("iceberg.jdbc-catalog.connection-url")], [The URI to connect to the JDBC server.],),
  ([#raw("iceberg.jdbc-catalog.connection-user")], [Username for JDBC client.],),
  ([#raw("iceberg.jdbc-catalog.connection-password")], [Password for JDBC client.],),
  ([#raw("iceberg.jdbc-catalog.catalog-name")], [Iceberg JDBC metastore catalog name.],),
  ([#raw("iceberg.jdbc-catalog.default-warehouse-dir")], [The default warehouse directory to use for JDBC.],),
  ([#raw("iceberg.jdbc-catalog.schema-version")], [JDBC catalog schema version. Valid values are #raw("V0") or #raw("V1"). Defaults to #raw("V1").],),
  ([#raw("iceberg.jdbc-catalog.retryable-status-codes")], [On connection error to JDBC metastore, retry if it is one of these JDBC status codes. Valid value is a comma-separated list of status codes. Note: JDBC catalog always retries the following status codes: #raw("08000,08003,08006,08007,40001"). Specify only additional codes \(such as #raw("57000,57P03,57P04") if using PostgreSQL driver\) here.],)
), header-rows: 1, title: "JDBC catalog configuration properties")

#warning[
The JDBC catalog may have compatibility issues if Iceberg introduces breaking changes in the future. Consider the #link(label("ref-iceberg-rest-catalog"))[REST catalog] as an alternative solution.

The JDBC catalog requires the metadata tables to already exist. Refer to #link("https://github.com/apache/iceberg/blob/main/core/src/main/java/org/apache/iceberg/jdbc/JdbcUtil.java")[Iceberg repository] for creating those tables.
]

The following example shows a minimal catalog configuration using an Iceberg JDBC metadata catalog:

#code-block("text", "connector.name=iceberg
iceberg.catalog.type=jdbc
iceberg.jdbc-catalog.catalog-name=test
iceberg.jdbc-catalog.driver-class=org.postgresql.Driver
iceberg.jdbc-catalog.connection-url=jdbc:postgresql://example.net:5432/database
iceberg.jdbc-catalog.connection-user=admin
iceberg.jdbc-catalog.connection-password=test
iceberg.jdbc-catalog.default-warehouse-dir=s3://bucket")

The JDBC catalog does not support #link(label("ref-sql-materialized-view-management"))[materialized view management].

#anchor("ref-iceberg-nessie-catalog")

=== Nessie catalog

In order to use a Nessie catalog, configure the catalog type with #raw("iceberg.catalog.type=nessie") and provide further details with the following properties:

#list-table((
  ([Property name], [Description],),
  ([#raw("iceberg.nessie-catalog.uri")], [Nessie API endpoint URI \(required\). Example: #raw("https://localhost:19120/api/v2")],),
  ([#raw("iceberg.nessie-catalog.ref")], [The branch\/tag to use for Nessie. Defaults to #raw("main").],),
  ([#raw("iceberg.nessie-catalog.default-warehouse-dir")], [Default warehouse directory for schemas created without an explicit #raw("location") property. Example: #raw("/tmp")],),
  ([#raw("iceberg.nessie-catalog.read-timeout")], [The read timeout #link(label("ref-prop-type-duration"))[duration] for requests to the Nessie server. Defaults to #raw("25s").],),
  ([#raw("iceberg.nessie-catalog.connection-timeout")], [The connection timeout #link(label("ref-prop-type-duration"))[duration] for connection requests to the Nessie server. Defaults to #raw("5s").],),
  ([#raw("iceberg.nessie-catalog.enable-compression")], [Configure whether compression should be enabled or not for requests to the Nessie server. Defaults to #raw("true").],),
  ([#raw("iceberg.nessie-catalog.authentication.type")], [The authentication type to use. Available value is #raw("BEARER"). Defaults to no authentication.],),
  ([#raw("iceberg.nessie-catalog.authentication.token")], [The token to use with #raw("BEARER") authentication. Example: #raw("SXVLUXUhIExFQ0tFUiEK")],),
  ([#raw("iceberg.nessie-catalog.client-api-version")], [Optional version of the Client API version to use. By default it is inferred from the #raw("iceberg.nessie-catalog.uri") value. Valid values are #raw("V1") or #raw("V2").],)
), header-rows: 1, title: "Nessie catalog configuration properties")

#code-block("text", "connector.name=iceberg
iceberg.catalog.type=nessie
iceberg.nessie-catalog.uri=https://localhost:19120/api/v2
iceberg.nessie-catalog.default-warehouse-dir=/tmp")

The Nessie catalog does not support #link(label("ref-sql-view-management"))[view management] or #link(label("ref-sql-materialized-view-management"))[materialized view management].

#anchor("ref-iceberg-snowflake-catalog")

=== Snowflake catalog

In order to use a Snowflake catalog, configure the catalog type with #raw("iceberg.catalog.type=snowflake") and provide further details with the following properties:

#list-table((
  ([Property name], [Description],),
  ([#raw("iceberg.snowflake-catalog.account-uri")], [Snowflake JDBC account URI \(required\). Example: #raw("jdbc:snowflake://example123456789.snowflakecomputing.com")],),
  ([#raw("iceberg.snowflake-catalog.user")], [Snowflake user \(required\).],),
  ([#raw("iceberg.snowflake-catalog.password")], [Snowflake password \(required\).],),
  ([#raw("iceberg.snowflake-catalog.database")], [Snowflake database name \(required\).],),
  ([#raw("iceberg.snowflake-catalog.role")], [Snowflake role name],)
), header-rows: 1, title: "Snowflake catalog configuration properties")

#code-block("text", "connector.name=iceberg
iceberg.catalog.type=snowflake
iceberg.snowflake-catalog.account-uri=jdbc:snowflake://example1234567890.snowflakecomputing.com
iceberg.snowflake-catalog.user=user
iceberg.snowflake-catalog.password=secret
iceberg.snowflake-catalog.database=db")

When using the Snowflake catalog, data management tasks such as creating tables, must be performed in Snowflake because using the catalog from external systems like Trino only supports #raw("SELECT") queries and other #link(label("ref-sql-read-operations"))[read operations].

Additionally, the #link("https://docs.snowflake.com/en/sql-reference/sql/create-iceberg-table-snowflake")[Snowflake-created Iceberg tables] do not expose partitioning information, which prevents efficient parallel reads and therefore can have significant negative performance implications.

The Snowflake catalog does not support #link(label("ref-sql-view-management"))[view management] or #link(label("ref-sql-materialized-view-management"))[materialized view management].

Further information is available in the #link("https://docs.snowflake.com/en/user-guide/tables-iceberg-catalog")[Snowflake catalog documentation].

#anchor("ref-partition-projection")

== Access tables with Athena partition projection metadata

#link("https://docs.aws.amazon.com/athena/latest/ug/partition-projection.html")[Partition projection] is a feature of AWS Athena often used to speed up query processing with highly partitioned tables when using the Hive connector.

Trino supports partition projection table properties stored in the Hive metastore or Glue catalog, and it reimplements this functionality. Currently, there is a limitation in comparison to AWS Athena for date projection, as it only supports intervals of #raw("DAYS"), #raw("HOURS"), #raw("MINUTES"), and #raw("SECONDS").

If there are any compatibility issues blocking access to a requested table when partition projection is enabled, set the #raw("partition_projection_ignore") table property to #raw("true") for a table to bypass any errors.

Refer to #link(label("ref-hive-table-properties"))[hive-table-properties] and #link(label("ref-hive-column-properties"))[hive-column-properties] for configuration of partition projection.

== Configure metastore for Avro

For catalogs using the Hive connector, you must add the following property definition to the Hive metastore configuration file #raw("hive-site.xml") and restart the metastore service to enable first-class support for Avro tables when using Hive 3.x:

#code-block("xml", "<property>
     <!-- https://community.hortonworks.com/content/supportkb/247055/errorjavalangunsupportedoperationexception-storage.html -->
     <name>metastore.storage.schema.reader.impl</name>
     <value>org.apache.hadoop.hive.metastore.SerDeStorageSchemaReader</value>
 </property>")
