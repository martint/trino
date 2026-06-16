#import "/lib/trino-docs.typ": *

#anchor("doc-connector-redis")
= Redis connector

The Redis connector allows querying of live data stored in #link("https://redis.io/")[Redis]. This can be used to join data between different systems like Redis and Hive.

Each Redis key\/value pair is presented as a single row in Trino. Rows can be broken down into cells by using table definition files.

Currently, only Redis key of string and zset types are supported, only Redis value of string and hash types are supported.

== Requirements

Requirements for using the connector in a catalog to connect to a Redis data source are:

- Redis 5.0.14 or higher \(Redis Cluster is not supported\)
- Network access, by default on port 6379, from the Trino coordinator and workers to Redis.

== Configuration

To configure the Redis connector, create a catalog properties file #raw("etc/catalog/example.properties") with the following content, replacing the properties as appropriate:

#code-block("text", "connector.name=redis
redis.table-names=schema1.table1,schema1.table2
redis.nodes=host:port")

=== Multiple Redis servers

You can have as many catalogs as you need. If you have additional Redis servers, simply add another properties file to #raw("etc/catalog") with a different name, making sure it ends in #raw(".properties").

== Configuration properties

The following configuration properties are available:

#list-table((
  ([Property name], [Description],),
  ([#raw("redis.table-names")], [List of all tables provided by the catalog],),
  ([#raw("redis.default-schema")], [Default schema name for tables],),
  ([#raw("redis.nodes")], [Location of the Redis server],),
  ([#raw("redis.scan-count")], [Redis parameter for scanning of the keys],),
  ([#raw("redis.max-keys-per-fetch")], [Get values associated with the specified number of keys in the redis command such as MGET\(key...\)],),
  ([#raw("redis.key-prefix-schema-table")], [Redis keys have schema-name:table-name prefix],),
  ([#raw("redis.key-delimiter")], [Delimiter separating schema\_name and table\_name if redis.key-prefix-schema-table is used],),
  ([#raw("redis.table-description-dir")], [Directory containing table description files],),
  ([#raw("redis.table-description-cache-ttl")], [The cache time for table description files],),
  ([#raw("redis.hide-internal-columns")], [Controls whether internal columns are part of the table schema or not],),
  ([#raw("redis.database-index")], [Redis database index],),
  ([#raw("redis.user")], [Redis server username],),
  ([#raw("redis.password")], [Redis server password],)
), header-rows: 1)

=== #raw("redis.table-names")

Comma-separated list of all tables provided by this catalog. A table name can be unqualified \(simple name\) and is placed into the default schema \(see below\), or qualified with a schema name \(#raw("<schema-name>.<table-name>")\).

For each table defined, a table description file \(see below\) may exist. If no table description file exists, the table only contains internal columns \(see below\).

This property is optional; the connector relies on the table description files specified in the #raw("redis.table-description-dir") property.

=== #raw("redis.default-schema")

Defines the schema which will contain all tables that were defined without a qualifying schema name.

This property is optional; the default is #raw("default").

=== #raw("redis.nodes")

The #raw("hostname:port") pair for the Redis server.

This property is required; there is no default.

Redis Cluster is not supported.

=== #raw("redis.scan-count")

The internal COUNT parameter for the Redis SCAN command when connector is using SCAN to find keys for the data. This parameter can be used to tune performance of the Redis connector.

This property is optional; the default is #raw("100").

=== #raw("redis.max-keys-per-fetch")

The internal number of keys for the Redis MGET command and Pipeline HGETALL command when connector is using these commands to find values of keys. This parameter can be used to tune performance of the Redis connector.

This property is optional; the default is #raw("100").

=== #raw("redis.key-prefix-schema-table")

If true, only keys prefixed with the #raw("schema-name:table-name") are scanned for a table, and all other keys are filtered out.  If false, all keys are scanned.

This property is optional; the default is #raw("false").

=== #raw("redis.key-delimiter")

The character used for separating #raw("schema-name") and #raw("table-name") when #raw("redis.key-prefix-schema-table") is #raw("true")

This property is optional; the default is #raw(":").

=== #raw("redis.table-description-dir")

References a folder within Trino deployment that holds one or more JSON files, which must end with #raw(".json") and contain table description files.

Note that the table description files will only be used by the Trino coordinator node.

This property is optional; the default is #raw("etc/redis").

=== #raw("redis.table-description-cache-ttl")

The Redis connector dynamically loads the table description files after waiting for the time specified by this property. Therefore, there is no need to update the #raw("redis.table-names") property and restart the Trino service when adding, updating, or deleting a file end with #raw(".json") to #raw("redis.table-description-dir") folder.

This property is optional; the default is #raw("5m").

=== #raw("redis.hide-internal-columns")

In addition to the data columns defined in a table description file, the connector maintains a number of additional columns for each table. If these columns are hidden, they can still be used in queries, but they do not show up in #raw("DESCRIBE <table-name>") or #raw("SELECT *").

This property is optional; the default is #raw("true").

=== #raw("redis.database-index")

The Redis database to query.

This property is optional; the default is #raw("0").

=== #raw("redis.user")

The username for Redis server.

This property is optional; the default is #raw("null").

=== #raw("redis.password")

The password for password-protected Redis server.

This property is optional; the default is #raw("null").

== Internal columns

For each defined table, the connector maintains the following columns:

#list-table((
  ([Column name], [Type], [Description],),
  ([#raw("_key")], [VARCHAR], [Redis key.],),
  ([#raw("_value")], [VARCHAR], [Redis value corresponding to the key.],),
  ([#raw("_key_length")], [BIGINT], [Number of bytes in the key.],),
  ([#raw("_value_length")], [BIGINT], [Number of bytes in the value.],),
  ([#raw("_key_corrupt")], [BOOLEAN], [True if the decoder could not decode the key for this row. When true, data columns mapped from the key should be treated as invalid.],),
  ([#raw("_value_corrupt")], [BOOLEAN], [True if the decoder could not decode the message for this row. When true, data columns mapped from the value should be treated as invalid.],)
), header-rows: 1)

For tables without a table definition file, the #raw("_key_corrupt") and #raw("_value_corrupt") columns are #raw("false").

== Table definition files

With the Redis connector it is possible to further reduce Redis key\/value pairs into granular cells, provided the key\/value string follows a particular format. This process defines new columns that can be further queried from Trino.

A table definition file consists of a JSON definition for a table. The name of the file can be arbitrary, but must end in #raw(".json").

#code-block("text", "{
    \"tableName\": ...,
    \"schemaName\": ...,
    \"key\": {
        \"dataFormat\": ...,
        \"fields\": [
            ...
        ]
    },
    \"value\": {
        \"dataFormat\": ...,
        \"fields\": [
            ...
       ]
    }
}")

#list-table((
  ([Field], [Required], [Type], [Description],),
  ([#raw("tableName")], [required], [string], [Trino table name defined by this file.],),
  ([#raw("schemaName")], [optional], [string], [Schema which will contain the table. If omitted, the default schema name is used.],),
  ([#raw("key")], [optional], [JSON object], [Field definitions for data columns mapped to the value key.],),
  ([#raw("value")], [optional], [JSON object], [Field definitions for data columns mapped to the value itself.],)
), header-rows: 1)

Please refer to the #link(label("doc-connector-kafka"))[Kafka connector] page for the description of the #raw("dataFormat") as well as various available decoders.

In addition to the above Kafka types, the Redis connector supports #raw("hash") type for the #raw("value") field which represent data stored in the Redis hash.

#code-block("text", "{
    \"tableName\": ...,
    \"schemaName\": ...,
    \"value\": {
        \"dataFormat\": \"hash\",
        \"fields\": [
            ...
       ]
    }
}")

== Type mapping

Because Trino and Redis each support types that the other does not, this connector #link(label("ref-type-mapping-overview"))[maps some types] when reading data. Type mapping depends on the RAW, CSV, JSON, and AVRO file formats.

=== Row decoding

A decoder is used to map data to table columns.

The connector contains the following decoders:

- #raw("raw"): Message is not interpreted; ranges of raw message bytes are mapped to table columns.
- #raw("csv"): Message is interpreted as comma separated message, and fields are mapped to table columns.
- #raw("json"): Message is parsed as JSON, and JSON fields are mapped to table columns.
- #raw("avro"): Message is parsed based on an Avro schema, and Avro fields are mapped to table columns.

#note[
If no table definition file exists for a table, the #raw("dummy") decoder is used, which does not expose any columns.
]

==== Raw decoder

The raw decoder supports reading of raw byte-based values from message or key, and converting it into Trino columns.

For fields, the following attributes are supported:

- #raw("dataFormat") - Selects the width of the data type converted.
- #raw("type") - Trino data type. See the following table for a list of supported data types.
- #raw("mapping") - #raw("<start>[:<end>]") - Start and end position of bytes to convert \(optional\).

The #raw("dataFormat") attribute selects the number of bytes converted. If absent, #raw("BYTE") is assumed. All values are signed.

Supported values are:

- #raw("BYTE") - one byte
- #raw("SHORT") - two bytes \(big-endian\)
- #raw("INT") - four bytes \(big-endian\)
- #raw("LONG") - eight bytes \(big-endian\)
- #raw("FLOAT") - four bytes \(IEEE 754 format\)
- #raw("DOUBLE") - eight bytes \(IEEE 754 format\)

The #raw("type") attribute defines the Trino data type on which the value is mapped.

Depending on the Trino type assigned to a column, different values of dataFormat can be used:

#list-table((
  ([Trino data type], [Allowed #raw("dataFormat") values],),
  ([#raw("BIGINT")], [#raw("BYTE"), #raw("SHORT"), #raw("INT"), #raw("LONG")],),
  ([#raw("INTEGER")], [#raw("BYTE"), #raw("SHORT"), #raw("INT")],),
  ([#raw("SMALLINT")], [#raw("BYTE"), #raw("SHORT")],),
  ([#raw("DOUBLE")], [#raw("DOUBLE"), #raw("FLOAT")],),
  ([#raw("BOOLEAN")], [#raw("BYTE"), #raw("SHORT"), #raw("INT"), #raw("LONG")],),
  ([#raw("VARCHAR") \/ #raw("VARCHAR(x)")], [#raw("BYTE")],)
), header-rows: 1)

No other types are supported.

The #raw("mapping") attribute specifies the range of the bytes in a key or message used for decoding. It can be one or two numbers separated by a colon \(#raw("<start>[:<end>]")\).

If only a start position is given:

- For fixed width types, the column uses the appropriate number of bytes for the specified #raw("dataFormat") \(see above\).
- When the #raw("VARCHAR") value is decoded, all bytes from the start position to the end of the message is used.

If start and end position are given:

- For fixed width types, the size must be equal to the number of bytes used by specified #raw("dataFormat").
- For the #raw("VARCHAR") data type all bytes between start \(inclusive\) and end \(exclusive\) are used.

If no #raw("mapping") attribute is specified, it is equivalent to setting the start position to 0 and leaving the end position undefined.

The decoding scheme of numeric data types \(#raw("BIGINT"), #raw("INTEGER"), #raw("SMALLINT"), #raw("TINYINT"), #raw("DOUBLE")\) is straightforward. A sequence of bytes is read from input message and decoded according to either:

- big-endian encoding \(for integer types\)
- IEEE 754 format for \(for #raw("DOUBLE")\).

The length of a decoded byte sequence is implied by the #raw("dataFormat").

For the #raw("VARCHAR") data type, a sequence of bytes is interpreted according to UTF-8 encoding.

==== CSV decoder

The CSV decoder converts the bytes representing a message or key into a string using UTF-8 encoding, and interprets the result as a link of comma-separated values.

For fields, the #raw("type") and #raw("mapping") attributes must be defined:

- #raw("type") - Trino data type. See the following table for a list of supported data types.
- #raw("mapping") - The index of the field in the CSV record.

The #raw("dataFormat") and #raw("formatHint") attributes are not supported and must be omitted.

#list-table((
  ([Trino data type], [Decoding rules],),
  ([#raw("BIGINT"), #raw("INTEGER"), #raw("SMALLINT"), #raw("TINYINT")], [Decoded using Java #raw("Long.parseLong()")],),
  ([#raw("DOUBLE")], [Decoded using Java #raw("Double.parseDouble()")],),
  ([#raw("BOOLEAN")], ["true" character sequence maps to #raw("true"). Other character sequences map to #raw("false")],),
  ([#raw("VARCHAR") \/ #raw("VARCHAR(x)")], [Used as is],)
), header-rows: 1)

No other types are supported.

==== JSON decoder

The JSON decoder converts the bytes representing a message or key into Javascript Object Notation \(JSON\) according to #link("https://www.rfc-editor.org/rfc/rfc4627")[RFC 4627]. The message or key must convert into a JSON object, not an array or simple type.

For fields, the following attributes are supported:

- #raw("type") - Trino data type of column.
- #raw("dataFormat") - Field decoder to be used for column.
- #raw("mapping") - Slash-separated list of field names to select a field from the JSON object.
- #raw("formatHint") - Only for #raw("custom-date-time").

The JSON decoder supports multiple field decoders with #raw("_default") being used for standard table columns and a number of decoders for date and time-based types.

The following table lists Trino data types, which can be used in #raw("type") and matching field decoders, and specified via #raw("dataFormat") attribute:

#list-table((
  ([Trino data type], [Allowed #raw("dataFormat") values],),
  ([#raw("BIGINT"), #raw("INTEGER"), #raw("SMALLINT"), #raw("TINYINT"), #raw("DOUBLE"), #raw("BOOLEAN"), #raw("VARCHAR"), #raw("VARCHAR(x)")], [Default field decoder \(omitted #raw("dataFormat") attribute\)],),
  ([#raw("DATE")], [#raw("custom-date-time"), #raw("iso8601")],),
  ([#raw("TIME")], [#raw("custom-date-time"), #raw("iso8601"), #raw("milliseconds-since-epoch"), #raw("seconds-since-epoch")],),
  ([#raw("TIME WITH TIME ZONE")], [#raw("custom-date-time"), #raw("iso8601")],),
  ([#raw("TIMESTAMP")], [#raw("custom-date-time"), #raw("iso8601"), #raw("rfc2822"), #raw("milliseconds-since-epoch"), #raw("seconds-since-epoch")],),
  ([#raw("TIMESTAMP WITH TIME ZONE")], [#raw("custom-date-time"), #raw("iso8601"), #raw("rfc2822"), #raw("milliseconds-since-epoch"), #raw("seconds-since-epoch")],)
), header-rows: 1)

No other types are supported.

===== Default field decoder

This is the standard field decoder. It supports all the Trino physical data types. A field value is transformed under JSON conversion rules into boolean, long, double, or string values. This decoder should be used for columns that are not date or time based.

===== Date and time decoders

To convert values from JSON objects to Trino #raw("DATE"), #raw("TIME"), #raw("TIME WITH TIME ZONE"), #raw("TIMESTAMP") or #raw("TIMESTAMP WITH TIME ZONE") columns, select special decoders using the #raw("dataFormat") attribute of a field definition.

- #raw("iso8601") - Text based, parses a text field as an ISO 8601 timestamp.
- #raw("rfc2822") - Text based, parses a text field as an #link("https://www.rfc-editor.org/rfc/rfc2822")[RFC 2822] timestamp.
- #raw("custom-date-time") - Text based, parses a text field according to Joda format pattern specified via #raw("formatHint") attribute. The format pattern should conform to #link("https://www.joda.org/joda-time/apidocs/org/joda/time/format/DateTimeFormat.html")[https:\/\/www.joda.org\/joda-time\/apidocs\/org\/joda\/time\/format\/DateTimeFormat.html].
- #raw("milliseconds-since-epoch") - Number-based, interprets a text or number as number of milliseconds since the epoch.
- #raw("seconds-since-epoch") - Number-based, interprets a text or number as number of milliseconds since the epoch.

For #raw("TIMESTAMP WITH TIME ZONE") and #raw("TIME WITH TIME ZONE") data types, if timezone information is present in decoded value, it is used as a Trino value. Otherwise, the result time zone is set to #raw("UTC").

==== Avro decoder

The Avro decoder converts the bytes representing a message or key in Avro format based on a schema. The message must have the Avro schema embedded. Trino does not support schemaless Avro decoding.

The #raw("dataSchema") must be defined for any key or message using #raw("Avro") decoder. #raw("Avro") decoder should point to the location of a valid Avro schema file of the message which must be decoded. This location can be a remote web server \(e.g.: #raw("dataSchema: 'http://example.org/schema/avro_data.avsc'")\) or local file system\(e.g.: #raw("dataSchema: '/usr/local/schema/avro_data.avsc'")\). The decoder fails if this location is not accessible from the Trino cluster.

The following attributes are supported:

- #raw("name") - Name of the column in the Trino table.
- #raw("type") - Trino data type of column.
- #raw("mapping") - A slash-separated list of field names to select a field from the Avro schema. If the field specified in #raw("mapping") does not exist in the original Avro schema, a read operation returns #raw("NULL").

The following table lists the supported Trino types that can be used in #raw("type") for the equivalent Avro field types:

#list-table((
  ([Trino data type], [Allowed Avro data type],),
  ([#raw("BIGINT")], [#raw("INT"), #raw("LONG")],),
  ([#raw("DOUBLE")], [#raw("DOUBLE"), #raw("FLOAT")],),
  ([#raw("BOOLEAN")], [#raw("BOOLEAN")],),
  ([#raw("VARCHAR") \/ #raw("VARCHAR(x)")], [#raw("STRING")],),
  ([#raw("VARBINARY")], [#raw("FIXED"), #raw("BYTES")],),
  ([#raw("ARRAY")], [#raw("ARRAY")],),
  ([#raw("MAP")], [#raw("MAP")],)
), header-rows: 1)

No other types are supported.

===== Avro schema evolution

The Avro decoder supports schema evolution with backward compatibility. With backward compatibility, a newer schema can be used to read Avro data created with an older schema. Any change in the Avro schema must also be reflected in Trino's topic definition file. Newly added or renamed fields must have a default value in the Avro schema file.

The schema evolution behavior is as follows:

- Column added in new schema: Data created with an older schema produces a #emph[default] value when the table is using the new schema.
- Column removed in new schema: Data created with an older schema no longer outputs the data from the column that was removed.
- Column is renamed in the new schema: This is equivalent to removing the column and adding a new one, and data created with an older schema produces a #emph[default] value when the table is using the new schema.
- Changing type of column in the new schema: If the type coercion is supported by Avro, then the conversion happens. An error is thrown for incompatible types.

#anchor("ref-redis-sql-support")

== SQL support

The connector provides #link(label("ref-sql-globally-available"))[globally available] and #link(label("ref-sql-read-operations"))[read operation] statements to access data and metadata in Redis.

== Performance

The connector includes a number of performance improvements, detailed in the following sections.

#anchor("ref-redis-pushdown")

=== Pushdown

#note[
The connector performs pushdown where performance may be improved, but in order to preserve correctness an operation may not be pushed down. When pushdown of an operation may result in better performance but risks correctness, the connector prioritizes correctness.
]

#anchor("ref-redis-predicate-pushdown")

==== Predicate pushdown support

The connector supports pushdown of keys of #raw("string") type only, the #raw("zset") type is not supported. Key pushdown is not supported when multiple key fields are defined in the table definition file.

The connector supports pushdown of equality predicates, such as #raw("IN") or #raw("="). Inequality predicates, such as #raw("!="), and range predicates, such as #raw(">"), #raw("<"), or #raw("BETWEEN") are not pushed down.

In the following example, the predicate of the first query is not pushed down since #raw(">") is a range predicate. The other queries are pushed down:

#code-block("sql", "-- Not pushed down
SELECT * FROM nation WHERE redis_key > 'CANADA';
-- Pushed down
SELECT * FROM nation WHERE redis_key = 'CANADA';
SELECT * FROM nation WHERE redis_key IN ('CANADA', 'POLAND');")
