#import "/lib/trino-docs.typ": *

#anchor("doc-connector-mongodb")
= MongoDB connector

The #raw("mongodb") connector allows the use of #link("https://www.mongodb.com/")[MongoDB] collections as tables in Trino.

== Requirements

To connect to MongoDB, you need:

- MongoDB 4.2 or higher.
- Network access from the Trino coordinator and workers to MongoDB. Port 27017 is the default port.
- Write access to the #link(label("ref-table-definition-label"))[schema information collection] in MongoDB.

== Configuration

To configure the MongoDB connector, create a catalog properties file #raw("etc/catalog/example.properties") with the following contents, replacing the properties as appropriate:

#code-block("text", "connector.name=mongodb
mongodb.connection-url=mongodb://user:pass@sample.host:27017/")

=== Multiple MongoDB clusters

You can have as many catalogs as you need, so if you have additional MongoDB clusters, simply add another properties file to #raw("etc/catalog") with a different name, making sure it ends in #raw(".properties")\). For example, if you name the property file #raw("sales.properties"), Trino will create a catalog named #raw("sales") using the configured connector.

== Configuration properties

The following configuration properties are available:

#list-table((
  ([Property name], [Description],),
  ([#raw("mongodb.connection-url")], [The connection url that the driver uses to connect to a MongoDB deployment],),
  ([#raw("mongodb.schema-collection")], [A collection which contains schema information],),
  ([#raw("mongodb.case-insensitive-name-matching")], [Match database and collection names case insensitively],),
  ([#raw("mongodb.min-connections-per-host")], [The minimum size of the connection pool per host],),
  ([#raw("mongodb.connections-per-host")], [The maximum size of the connection pool per host],),
  ([#raw("mongodb.max-wait-time")], [The maximum wait time],),
  ([#raw("mongodb.max-connection-idle-time")], [The maximum idle time of a pooled connection],),
  ([#raw("mongodb.connection-timeout")], [The socket connect timeout],),
  ([#raw("mongodb.socket-timeout")], [The socket timeout],),
  ([#raw("mongodb.tls.enabled")], [Use TLS\/SSL for connections to mongod\/mongos],),
  ([#raw("mongodb.tls.keystore-path")], [Path to the  or JKS key store],),
  ([#raw("mongodb.tls.truststore-path")], [Path to the  or JKS trust store],),
  ([#raw("mongodb.tls.keystore-password")], [Password for the key store],),
  ([#raw("mongodb.tls.truststore-password")], [Password for the trust store],),
  ([#raw("mongodb.read-preference")], [The read preference],),
  ([#raw("mongodb.write-concern")], [The write concern],),
  ([#raw("mongodb.required-replica-set")], [The required replica set name],),
  ([#raw("mongodb.cursor-batch-size")], [The number of elements to return in a batch],),
  ([#raw("mongodb.allow-local-scheduling")], [Assign MongoDB splits to a specific worker],),
  ([#raw("mongodb.dynamic-filtering.wait-timeout")], [Duration to wait for completion of dynamic filters during split generation],)
), header-rows: 1)

=== #raw("mongodb.connection-url")

A connection string containing the protocol, credential, and host info for use in connecting to your MongoDB deployment.

For example, the connection string may use the format #raw("mongodb://<user>:<pass>@<host>:<port>/?<options>") or #raw("mongodb+srv://<user>:<pass>@<host>/?<options>"), depending on the protocol used. The user\/pass credentials must be for a user with write access to the #link(label("ref-table-definition-label"))[schema information collection].

See the #link("https://docs.mongodb.com/drivers/java/sync/current/fundamentals/connection/#connection-uri")[MongoDB Connection URI] for more information.

This property is required; there is no default. A connection URL must be provided to connect to a MongoDB deployment.

=== #raw("mongodb.schema-collection")

As MongoDB is a document database, there is no fixed schema information in the system. So a special collection in each MongoDB database should define the schema of all tables. Please refer the #link(label("ref-table-definition-label"))[table-definition-label] section for the details.

At startup, the connector tries to guess the data type of fields based on the #link(label("ref-mongodb-type-mapping"))[type mapping].

The initial guess can be incorrect for your specific collection. In that case, you need to modify it manually. Please refer the #link(label("ref-table-definition-label"))[table-definition-label] section for the details.

Creating new tables using #raw("CREATE TABLE") and #raw("CREATE TABLE AS SELECT") automatically create an entry for you.

This property is optional; the default is #raw("_schema").

=== #raw("mongodb.case-insensitive-name-matching")

Match database and collection names case insensitively.

This property is optional; the default is #raw("false").

=== #raw("mongodb.min-connections-per-host")

The minimum number of connections per host for this MongoClient instance. Those connections are kept in a pool when idle, and the pool ensures over time that it contains at least this minimum number.

This property is optional; the default is #raw("0").

=== #raw("mongodb.connections-per-host")

The maximum number of connections allowed per host for this MongoClient instance. Those connections are kept in a pool when idle. Once the pool is exhausted, any operation requiring a connection blocks waiting for an available connection.

This property is optional; the default is #raw("100").

=== #raw("mongodb.max-wait-time")

The maximum wait time in milliseconds, that a thread may wait for a connection to become available. A value of #raw("0") means that it does not wait. A negative value means to wait indefinitely for a connection to become available.

This property is optional; the default is #raw("120000").

=== #raw("mongodb.max-connection-idle-time")

The maximum idle time of a pooled connection in milliseconds. A value of #raw("0") indicates no limit to the idle time. A pooled connection that has exceeded its idle time will be closed and replaced when necessary by a new connection.

This property is optional; the default is #raw("0").

=== #raw("mongodb.connection-timeout")

The connection timeout in milliseconds. A value of #raw("0") means no timeout. It is used solely when establishing a new connection.

This property is optional; the default is #raw("10000").

=== #raw("mongodb.socket-timeout")

The socket timeout in milliseconds. It is used for I\/O socket read and write operations.

This property is optional; the default is #raw("0") and means no timeout.

=== #raw("mongodb.tls.enabled")

This flag enables TLS connections to MongoDB servers.

This property is optional; the default is #raw("false").

=== #raw("mongodb.tls.keystore-path")

The path to the #link(label("doc-security-inspect-pem"))[PEM] or #link(label("doc-security-inspect-jks"))[JKS] key store.

This property is optional.

=== #raw("mongodb.tls.truststore-path")

The path to #link(label("doc-security-inspect-pem"))[PEM] or #link(label("doc-security-inspect-jks"))[JKS] trust store.

This property is optional.

=== #raw("mongodb.tls.keystore-password")

The key password for the key store specified by #raw("mongodb.tls.keystore-path").

This property is optional.

=== #raw("mongodb.tls.truststore-password")

The key password for the trust store specified by #raw("mongodb.tls.truststore-path").

This property is optional.

=== #raw("mongodb.read-preference")

The read preference to use for queries, map-reduce, aggregation, and count. The available values are #raw("PRIMARY"), #raw("PRIMARY_PREFERRED"), #raw("SECONDARY"), #raw("SECONDARY_PREFERRED") and #raw("NEAREST").

This property is optional; the default is #raw("PRIMARY").

=== #raw("mongodb.write-concern")

The write concern to use. The available values are #raw("ACKNOWLEDGED"), #raw("JOURNALED"), #raw("MAJORITY") and #raw("UNACKNOWLEDGED").

This property is optional; the default is #raw("ACKNOWLEDGED").

=== #raw("mongodb.required-replica-set")

The required replica set name. With this option set, the MongoClient instance performs the following actions:

#code-block(none, "#. Connect in replica set mode, and discover all members of the set based on the given servers
#. Make sure that the set name reported by all members matches the required set name.
#. Refuse to service any requests, if authenticated user is not part of a replica set with the required name.")

This property is optional; no default value.

=== #raw("mongodb.cursor-batch-size")

Limits the number of elements returned in one batch. A cursor typically fetches a batch of result objects and stores them locally. If batchSize is 0, Driver's default are used. If batchSize is positive, it represents the size of each batch of objects retrieved. It can be adjusted to optimize performance and limit data transfer. If batchSize is negative, it limits the number of objects returned, that fit within the max batch size limit \(usually 4MB\), and the cursor is closed. For example if batchSize is -10, then the server returns a maximum of 10 documents, and as many as can fit in 4MB, then closes the cursor.

#note[
Do not use a batch size of #raw("1").
]

This property is optional; the default is #raw("0").

=== #raw("mongodb.allow-local-scheduling")

Set the value of this property to #raw("true") if Trino and MongoDB share the same cluster, and specific MongoDB splits should be processed on the same worker and MongoDB node. Note that a shared deployment is not recommended, and enabling this property can lead to resource contention.

This property is optional, and defaults to false.

=== #raw("mongodb.dynamic-filtering.wait-timeout")

Duration to wait for completion of dynamic filters during split generation.

This property is optional; the default is #raw("5s").

#anchor("ref-table-definition-label")

== Table definition

MongoDB maintains table definitions on the special collection where #raw("mongodb.schema-collection") configuration value specifies.

#note[
The plugin cannot detect that a collection has been deleted. You must delete the entry by executing #raw("db.getCollection(\"_schema\").remove( { table: deleted_table_name })") in the MongoDB Shell. You can also drop a collection in Trino by running #raw("DROP TABLE table_name").
]

A schema collection consists of a MongoDB document for a table.

#code-block("text", "{
    \"table\": ...,
    \"fields\": [
          { \"name\" : ...,
            \"type\" : \"varchar|bigint|boolean|double|date|array(bigint)|...\",
            \"hidden\" : false },
            ...
        ]
    }
}")

The connector quotes the fields for a row type when auto-generating the schema; however, the auto-generated schema must be corrected manually in the collection to match the information in the tables.

Manually altered fields must be explicitly quoted, for example, #raw("row(\"UpperCase\" varchar)").

#list-table((
  ([Field], [Required], [Type], [Description],),
  ([#raw("table")], [required], [string], [Trino table name],),
  ([#raw("fields")], [required], [array], [A list of field definitions. Each field definition creates a new column in the Trino table.],)
), header-rows: 1)

Each field definition:

#code-block("text", "{
    \"name\": ...,
    \"type\": ...,
    \"hidden\": ...
}")

#list-table((
  ([Field], [Required], [Type], [Description],),
  ([#raw("name")], [required], [string], [Name of the column in the Trino table.],),
  ([#raw("type")], [required], [string], [Trino type of the column.],),
  ([#raw("hidden")], [optional], [boolean], [Hides the column from #raw("DESCRIBE <table name>") and #raw("SELECT *"). Defaults to #raw("false").],)
), header-rows: 1)

There is no limit on field descriptions for either key or message.

== ObjectId

MongoDB collection has the special field #raw("_id"). The connector tries to follow the same rules for this special field, so there will be hidden field #raw("_id").

#code-block("sql", "CREATE TABLE IF NOT EXISTS orders (
    orderkey BIGINT,
    orderstatus VARCHAR,
    totalprice DOUBLE,
    orderdate DATE
);

INSERT INTO orders VALUES(1, 'bad', 50.0, current_date);
INSERT INTO orders VALUES(2, 'good', 100.0, current_date);
SELECT _id, * FROM orders;")

#code-block("text", "                 _id                 | orderkey | orderstatus | totalprice | orderdate
-------------------------------------+----------+-------------+------------+------------
 55 b1 51 63 38 64 d6 43 8c 61 a9 ce |        1 | bad         |       50.0 | 2015-07-23
 55 b1 51 67 38 64 d6 43 8c 61 a9 cf |        2 | good        |      100.0 | 2015-07-23
(2 rows)")

#code-block("sql", "SELECT _id, * FROM orders WHERE _id = ObjectId('55b151633864d6438c61a9ce');")

#code-block("text", "                 _id                 | orderkey | orderstatus | totalprice | orderdate
-------------------------------------+----------+-------------+------------+------------
 55 b1 51 63 38 64 d6 43 8c 61 a9 ce |        1 | bad         |       50.0 | 2015-07-23
(1 row)")

You can render the #raw("_id") field to readable values with a cast to #raw("VARCHAR"):

#code-block("sql", "SELECT CAST(_id AS VARCHAR), * FROM orders WHERE _id = ObjectId('55b151633864d6438c61a9ce');")

#code-block("text", "           _id             | orderkey | orderstatus | totalprice | orderdate
---------------------------+----------+-------------+------------+------------
 55b151633864d6438c61a9ce  |        1 | bad         |       50.0 | 2015-07-23
(1 row)")

=== ObjectId timestamp functions

The first four bytes of each #link("https://docs.mongodb.com/manual/reference/method/ObjectId")[ObjectId] represent an embedded timestamp of its creation time. Trino provides a couple of functions to take advantage of this MongoDB feature.

#function-def("fn-objectid-timestamp", "objectid_timestamp(ObjectId)", "timestamp")[
Extracts the TIMESTAMP WITH TIME ZONE from a given ObjectId:

#code-block("sql", "SELECT objectid_timestamp(ObjectId('507f191e810c19729de860ea'));
-- 2012-10-17 20:46:22.000 UTC")
]

#function-def("fn-timestamp-objectid", "timestamp_objectid(timestamp)", "ObjectId")[
Creates an ObjectId from a TIMESTAMP WITH TIME ZONE:

#code-block("sql", "SELECT timestamp_objectid(TIMESTAMP '2021-08-07 17:51:36 +00:00');
-- 61 0e c8 28 00 00 00 00 00 00 00 00")
]

In MongoDB, you can filter all the documents created after #raw("2021-08-07 17:51:36") with a query like this:

#code-block("text", "db.collection.find({\"_id\": {\"$gt\": ObjectId(\"610ec8280000000000000000\")}})")

In Trino, the same can be achieved with this query:

#code-block("sql", "SELECT *
FROM collection
WHERE _id > timestamp_objectid(TIMESTAMP '2021-08-07 17:51:36 +00:00');")

#anchor("ref-mongodb-fte-support")

=== Fault-tolerant execution support

The connector supports #link(label("doc-admin-fault-tolerant-execution"))[Fault-tolerant execution] of query processing. Read and write operations are both supported with any retry policy.

#anchor("ref-mongodb-type-mapping")

== Type mapping

Because Trino and MongoDB each support types that the other does not, this connector #link(label("ref-type-mapping-overview"))[modifies some types] when reading or writing data. Data types may not map the same way in both directions between Trino and the data source. Refer to the following sections for type mapping in each direction.

=== MongoDB to Trino type mapping

The connector maps MongoDB types to the corresponding Trino types following this table:

#list-table((
  ([MongoDB type], [Trino type], [Notes],),
  ([#raw("Boolean")], [#raw("BOOLEAN")], [],),
  ([#raw("Int32")], [#raw("BIGINT")], [],),
  ([#raw("Int64")], [#raw("BIGINT")], [],),
  ([#raw("Double")], [#raw("DOUBLE")], [],),
  ([#raw("Decimal128")], [#raw("DECIMAL(p, s)")], [],),
  ([#raw("Date")], [#raw("TIMESTAMP(3)")], [],),
  ([#raw("String")], [#raw("VARCHAR")], [],),
  ([#raw("Binary")], [#raw("VARBINARY")], [],),
  ([#raw("ObjectId")], [#raw("ObjectId")], [],),
  ([#raw("Object")], [#raw("ROW")], [],),
  ([#raw("Array")], [#raw("ARRAY")], [Map to #raw("ROW") if the element type is not unique.],),
  ([#raw("DBRef")], [#raw("ROW")], [],)
), header-rows: 1, title: "MongoDB to Trino type mapping")

No other types are supported.

=== Trino to MongoDB type mapping

The connector maps Trino types to the corresponding MongoDB types following this table:

#list-table((
  ([Trino type], [MongoDB type],),
  ([#raw("BOOLEAN")], [#raw("Boolean")],),
  ([#raw("BIGINT")], [#raw("Int64")],),
  ([#raw("DOUBLE")], [#raw("Double")],),
  ([#raw("DECIMAL(p, s)")], [#raw("Decimal128")],),
  ([#raw("TIMESTAMP(3)")], [#raw("Date")],),
  ([#raw("VARCHAR")], [#raw("String")],),
  ([#raw("VARBINARY")], [#raw("Binary")],),
  ([#raw("ObjectId")], [#raw("ObjectId")],),
  ([#raw("ROW")], [#raw("Object")],),
  ([#raw("ARRAY")], [#raw("Array")],)
), header-rows: 1, title: "Trino to MongoDB type mapping")

No other types are supported.

#anchor("ref-mongodb-sql-support")

== SQL support

The connector provides read and write access to data and metadata in MongoDB. In addition to the #link(label("ref-sql-globally-available"))[globally available] and #link(label("ref-sql-read-operations"))[read operation] statements, the connector supports the following features:

- #link(label("doc-sql-insert"))[INSERT]
- #link(label("doc-sql-delete"))[DELETE]
- #link(label("doc-sql-create-table"))[CREATE TABLE]
- #link(label("doc-sql-create-table-as"))[CREATE TABLE AS]
- #link(label("doc-sql-drop-table"))[DROP TABLE]
- #link(label("doc-sql-alter-table"))[ALTER TABLE]
- #link(label("doc-sql-create-schema"))[CREATE SCHEMA]
- #link(label("doc-sql-drop-schema"))[DROP SCHEMA]
- #link(label("doc-sql-comment"))[COMMENT]

=== ALTER TABLE

The connector supports #raw("ALTER TABLE RENAME TO"), #raw("ALTER TABLE ADD COLUMN") and #raw("ALTER TABLE DROP COLUMN") operations. Other uses of #raw("ALTER TABLE") are not supported.

=== Table functions

The connector provides specific #link(label("doc-functions-table"))[table functions] to access MongoDB.

#anchor("ref-mongodb-query-function")

==== #raw("query(database, collection, filter) -> table")

The #raw("query") function allows you to query the underlying MongoDB directly. It requires syntax native to MongoDB, because the full query is pushed down and processed by MongoDB. This can be useful for accessing native features which are not available in Trino or for improving query performance in situations where running a query natively may be faster.

For example, get all rows where #raw("regionkey") field is 0:

#code-block(none, "SELECT
  *
FROM
  TABLE(
    example.system.query(
      database => 'tpch',
      collection => 'region',
      filter => '{ regionkey: 0 }'
    )
  );")
