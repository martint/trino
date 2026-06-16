#import "/lib/trino-docs.typ": *

#anchor("doc-connector-cassandra")
= Cassandra connector

The Cassandra connector allows querying data stored in #link("https://cassandra.apache.org/")[Apache Cassandra].

== Requirements

To connect to Cassandra, you need:

- Cassandra version 3.0 or higher.
- Network access from the Trino coordinator and workers to Cassandra. Port 9042 is the default port.

== Configuration

To configure the Cassandra connector, create a catalog properties file #raw("etc/catalog/example.properties") with the following contents, replacing #raw("host1,host2") with a comma-separated list of the Cassandra nodes, used to discovery the cluster topology:

#code-block("text", "connector.name=cassandra
cassandra.contact-points=host1,host2
cassandra.load-policy.dc-aware.local-dc=datacenter1")

You also need to set #raw("cassandra.native-protocol-port"), if your Cassandra nodes are not using the default port 9042.

=== Multiple Cassandra clusters

You can have as many catalogs as you need, so if you have additional Cassandra clusters, simply add another properties file to #raw("etc/catalog") with a different name, making sure it ends in #raw(".properties"). For example, if you name the property file #raw("sales.properties"), Trino creates a catalog named #raw("sales") using the configured connector.

== Configuration properties

The following configuration properties are available:

#list-table((
  ([Property name], [Description],),
  ([#raw("cassandra.contact-points")], [Comma-separated list of hosts in a Cassandra cluster. The Cassandra driver uses these contact points to discover cluster topology. At least one Cassandra host is required.],),
  ([#raw("cassandra.native-protocol-port")], [The Cassandra server port running the native client protocol, defaults to #raw("9042").],),
  ([#raw("cassandra.consistency-level")], [Consistency levels in Cassandra refer to the level of consistency to be used for both read and write operations.  More information about consistency levels can be found in the #link("https://docs.datastax.com/en/cassandra-oss/2.2/cassandra/dml/dmlConfigConsistency.html")[Cassandra consistency] documentation. This property defaults to a consistency level of #raw("ONE"). Possible values include #raw("ALL"), #raw("EACH_QUORUM"), #raw("QUORUM"), #raw("LOCAL_QUORUM"), #raw("ONE"), #raw("TWO"), #raw("THREE"), #raw("LOCAL_ONE"), #raw("ANY"), #raw("SERIAL"), #raw("LOCAL_SERIAL").],),
  ([#raw("cassandra.allow-drop-table")], [Enables #link(label("doc-sql-drop-table"))[DROP TABLE] operations. Defaults to #raw("false").],),
  ([#raw("cassandra.security")], [Configure authentication to Cassandra. Defaults to #raw("NONE"). Set to #raw("PASSWORD") for basic authentication, and configure #raw("cassandra.username") and #raw("cassandra.password").],),
  ([#raw("cassandra.username")], [Username used for authentication to the Cassandra cluster. Requires #raw("cassandra.security=PASSWORD"). This is a global setting used for all connections, regardless of the user connected to Trino.],),
  ([#raw("cassandra.password")], [Password used for authentication to the Cassandra cluster. Requires #raw("cassandra.security=PASSWORD"). This is a global setting used for all connections, regardless of the user connected to Trino.],),
  ([#raw("cassandra.protocol-version")], [It is possible to override the protocol version for older Cassandra clusters. By default, the value corresponds to the default protocol version used in the underlying Cassandra java driver. Possible values include #raw("V3"), #raw("V4"), #raw("V5"), #raw("V6").],)
), header-rows: 1)

#note[
If authorization is enabled, #raw("cassandra.username") must have enough permissions to perform #raw("SELECT") queries on the #raw("system.size_estimates") table.
]

The following advanced configuration properties are available:

#list-table((
  ([Property name], [Description],),
  ([#raw("cassandra.fetch-size")], [Number of rows fetched at a time in a Cassandra query.],),
  ([#raw("cassandra.partition-size-for-batch-select")], [Number of partitions batched together into a single select for a single partition key column table.],),
  ([#raw("cassandra.split-size")], [Number of keys per split when querying Cassandra.],),
  ([#raw("cassandra.splits-per-node")], [Number of splits per node. By default, the values from the #raw("system.size_estimates") table are used. Only override when connecting to Cassandra versions \< 2.1.5, which lacks the #raw("system.size_estimates") table.],),
  ([#raw("cassandra.batch-size")], [Maximum number of statements to execute in one batch.],),
  ([#raw("cassandra.client.read-timeout")], [Maximum time the Cassandra driver waits for an answer to a query from one Cassandra node. Note that the underlying Cassandra driver may retry a query against more than one node in the event of a read timeout. Increasing this may help with queries that use an index.],),
  ([#raw("cassandra.client.connect-timeout")], [Maximum time the Cassandra driver waits to establish a connection to a Cassandra node. Increasing this may help with heavily loaded Cassandra clusters.],),
  ([#raw("cassandra.client.so-linger")], [Number of seconds to linger on close if unsent data is queued. If set to zero, the socket will be closed immediately. When this option is non-zero, a socket lingers that many seconds for an acknowledgement that all data was written to a peer. This option can be used to avoid consuming sockets on a Cassandra server by immediately closing connections when they are no longer needed.],),
  ([#raw("cassandra.retry-policy")], [Policy used to retry failed requests to Cassandra. This property defaults to #raw("DEFAULT"). Using #raw("BACKOFF") may help when queries fail with #emph["not enough replicas"]. The other possible values are #raw("DOWNGRADING_CONSISTENCY") and #raw("FALLTHROUGH").],),
  ([#raw("cassandra.load-policy.use-dc-aware")], [Set to #raw("true") if the load balancing policy requires a local datacenter, defaults to #raw("true").],),
  ([#raw("cassandra.load-policy.dc-aware.local-dc")], [The name of the datacenter considered "local".],),
  ([#raw("cassandra.load-policy.dc-aware.used-hosts-per-remote-dc")], [Uses the provided number of host per remote datacenter as failover for the local hosts for #raw("DefaultLoadBalancingPolicy").],),
  ([#raw("cassandra.load-policy.dc-aware.allow-remote-dc-for-local")], [Set to #raw("true") to allow to use hosts of remote datacenter for local consistency level.],),
  ([#raw("cassandra.no-host-available-retry-timeout")], [Retry timeout for #raw("AllNodesFailedException"), defaults to #raw("1m").],),
  ([#raw("cassandra.speculative-execution.limit")], [The number of speculative executions. This is disabled by default.],),
  ([#raw("cassandra.speculative-execution.delay")], [The delay between each speculative execution, defaults to #raw("500ms").],),
  ([#raw("cassandra.tls.enabled")], [Whether TLS security is enabled, defaults to #raw("false").],),
  ([#raw("cassandra.tls.keystore-path")], [Path to the #link(label("doc-security-inspect-pem"))[PEM] or #link(label("doc-security-inspect-jks"))[JKS] key store file.],),
  ([#raw("cassandra.tls.truststore-path")], [Path to the #link(label("doc-security-inspect-pem"))[PEM] or #link(label("doc-security-inspect-jks"))[JKS] trust store file.],),
  ([#raw("cassandra.tls.keystore-password")], [Password for the key store.],),
  ([#raw("cassandra.tls.truststore-password")], [Password for the trust store.],)
), header-rows: 1)

== Querying Cassandra tables

The #raw("users") table is an example Cassandra table from the Cassandra #link("https://cassandra.apache.org/doc/latest/cassandra/getting_started/index.html")[Getting Started] guide. It can be created along with the #raw("example_keyspace") keyspace using Cassandra's cqlsh \(CQL interactive terminal\):

#code-block("text", "cqlsh> CREATE KEYSPACE example_keyspace
   ... WITH REPLICATION = { 'class' : 'SimpleStrategy', 'replication_factor' : 1 };
cqlsh> USE example_keyspace;
cqlsh:example_keyspace> CREATE TABLE users (
              ...   user_id int PRIMARY KEY,
              ...   fname text,
              ...   lname text
              ... );")

This table can be described in Trino:

#code-block(none, "DESCRIBE example.example_keyspace.users;")

#code-block("text", " Column  |  Type   | Extra | Comment
---------+---------+-------+---------
 user_id | bigint  |       |
 fname   | varchar |       |
 lname   | varchar |       |
(3 rows)")

This table can then be queried in Trino:

#code-block(none, "SELECT * FROM example.example_keyspace.users;")

#anchor("ref-cassandra-type-mapping")

== Type mapping

Because Trino and Cassandra each support types that the other does not, this connector #link(label("ref-type-mapping-overview"))[modifies some types] when reading or writing data. Data types may not map the same way in both directions between Trino and the data source. Refer to the following sections for type mapping in each direction.

=== Cassandra type to Trino type mapping

The connector maps Cassandra types to the corresponding Trino types according to the following table:

#list-table((
  ([Cassandra type], [Trino type], [Notes],),
  ([#raw("BOOLEAN")], [#raw("BOOLEAN")], [],),
  ([#raw("TINYINT")], [#raw("TINYINT")], [],),
  ([#raw("SMALLINT")], [#raw("SMALLINT")], [],),
  ([#raw("INT")], [#raw("INTEGER")], [],),
  ([#raw("BIGINT")], [#raw("BIGINT")], [],),
  ([#raw("FLOAT")], [#raw("REAL")], [],),
  ([#raw("DOUBLE")], [#raw("DOUBLE")], [],),
  ([#raw("DECIMAL")], [#raw("DOUBLE")], [],),
  ([#raw("ASCII")], [#raw("VARCHAR")], [US-ASCII character string],),
  ([#raw("TEXT")], [#raw("VARCHAR")], [UTF-8 encoded string],),
  ([#raw("VARCHAR")], [#raw("VARCHAR")], [UTF-8 encoded string],),
  ([#raw("VARINT")], [#raw("VARCHAR")], [Arbitrary-precision integer],),
  ([#raw("BLOB")], [#raw("VARBINARY")], [],),
  ([#raw("DATE")], [#raw("DATE")], [],),
  ([#raw("TIME")], [#raw("TIME(9)")], [],),
  ([#raw("TIMESTAMP")], [#raw("TIMESTAMP(3) WITH TIME ZONE")], [],),
  ([#raw("LIST<?>")], [#raw("VARCHAR")], [],),
  ([#raw("MAP<?, ?>")], [#raw("VARCHAR")], [],),
  ([#raw("SET<?>")], [#raw("VARCHAR")], [],),
  ([#raw("TUPLE")], [#raw("ROW") with anonymous fields], [],),
  ([#raw("UDT")], [#raw("ROW") with field names], [],),
  ([#raw("INET")], [#raw("IPADDRESS")], [],),
  ([#raw("UUID")], [#raw("UUID")], [],),
  ([#raw("TIMEUUID")], [#raw("UUID")], [],)
), header-rows: 1, title: "Cassandra type to Trino type mapping")

No other types are supported.

=== Trino type to Cassandra type mapping

The connector maps Trino types to the corresponding Cassandra types according to the following table:

#list-table((
  ([Trino type], [Cassandra type], [Notes],),
  ([#raw("BOOLEAN")], [#raw("BOOLEAN")], [],),
  ([#raw("TINYINT")], [#raw("TINYINT")], [],),
  ([#raw("SMALLINT")], [#raw("SMALLINT")], [],),
  ([#raw("INTEGER")], [#raw("INT")], [],),
  ([#raw("BIGINT")], [#raw("BIGINT")], [],),
  ([#raw("REAL")], [#raw("FLOAT")], [],),
  ([#raw("DOUBLE")], [#raw("DOUBLE")], [],),
  ([#raw("VARCHAR")], [#raw("TEXT")], [],),
  ([#raw("DATE")], [#raw("DATE")], [],),
  ([#raw("TIMESTAMP(3) WITH TIME ZONE")], [#raw("TIMESTAMP")], [],),
  ([#raw("IPADDRESS")], [#raw("INET")], [],),
  ([#raw("UUID")], [#raw("UUID")], [],)
), header-rows: 1, title: "Trino type to Cassandra type mapping")

No other types are supported.

== Partition key types

Partition keys can only be of the following types:

- ASCII
- TEXT
- VARCHAR
- BIGINT
- BOOLEAN
- DOUBLE
- INET
- INT
- FLOAT
- DECIMAL
- TIMESTAMP
- UUID
- TIMEUUID

== Limitations

- Queries without filters containing the partition key result in fetching all partitions. This causes a full scan of the entire data set, and is therefore much slower compared to a similar query with a partition key as a filter.
- #raw("IN") list filters are only allowed on index \(that is, partition key or clustering key\) columns.
- Range \(#raw("<") or #raw(">") and #raw("BETWEEN")\) filters can be applied only to the partition keys.

#anchor("ref-cassandra-sql-support")

== SQL support

The connector provides read and write access to data and metadata in the Cassandra database. In addition to the #link(label("ref-sql-globally-available"))[globally available] and #link(label("ref-sql-read-operations"))[read operation] statements, the connector supports the following features:

- #link(label("doc-sql-insert"))[INSERT]
- #link(label("doc-sql-delete"))[DELETE] see #link(label("ref-sql-delete-limitation"))[sql-delete-limitation]
- #link(label("doc-sql-truncate"))[TRUNCATE]
- #link(label("doc-sql-create-table"))[CREATE TABLE]
- #link(label("doc-sql-create-table-as"))[CREATE TABLE AS]
- #link(label("doc-sql-drop-table"))[DROP TABLE]

=== Procedures

==== #raw("system.execute('query')")

The #raw("execute") procedure allows you to execute a query in the underlying data source directly. The query must use supported syntax of the connected data source. Use the procedure to access features which are not available in Trino or to execute queries that return no result set and therefore can not be used with the #raw("query") or #raw("raw_query") pass-through table function. Typical use cases are statements that create or alter objects, and require native feature such as constraints, default values, automatic identifier creation, or indexes. Queries can also invoke statements that insert, update, or delete data, and do not return any data as a result.

The query text is not parsed by Trino, only passed through, and therefore only subject to any security or access control of the underlying data source.

The following example sets the current database to the #raw("example_schema") of the #raw("example") catalog. Then it calls the procedure in that schema to drop the default value from #raw("your_column") on #raw("your_table") table using the standard SQL syntax in the parameter value assigned for #raw("query"):

#code-block("sql", "USE example.example_schema;
CALL system.execute(query => 'ALTER TABLE your_table ALTER COLUMN your_column DROP DEFAULT');")

Verify that the specific database supports this syntax, and adapt as necessary based on the documentation for the specific connected database and database version.

=== Table functions

The connector provides specific #link(label("doc-functions-table"))[table functions] to access Cassandra. .. \_cassandra-query-function:

==== #raw("query(varchar) -> table")

The #raw("query") function allows you to query the underlying Cassandra directly. It requires syntax native to Cassandra, because the full query is pushed down and processed by Cassandra. This can be useful for accessing native features which are not available in Trino or for improving query performance in situations where running a query natively may be faster.

#note[
The query engine does not preserve the order of the results of this function. If the passed query contains an #raw("ORDER BY") clause, the function result may not be ordered as expected.
]

As a simple example, to select an entire table:

#code-block(none, "SELECT
  *
FROM
  TABLE(
    example.system.query(
      query => 'SELECT
        *
      FROM
        tpch.nation'
    )
  );")

=== DROP TABLE

By default, #raw("DROP TABLE") operations are disabled on Cassandra catalogs. To enable #raw("DROP TABLE"), set the #raw("cassandra.allow-drop-table") catalog configuration property to #raw("true"):

#code-block("properties", "cassandra.allow-drop-table=true")

#anchor("ref-sql-delete-limitation")

=== SQL delete limitation

#raw("DELETE") is only supported if the #raw("WHERE") clause matches entire partitions.
