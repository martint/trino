#import "/lib/trino-docs.typ": *

#anchor("doc-connector-kafka")
= Kafka connector

- #link(label("doc-connector-kafka-tutorial"))[Kafka connector tutorial]

This connector allows the use of #link("https://kafka.apache.org/")[Apache Kafka] topics as tables in Trino. Each message is presented as a row in Trino.

Topics can be live. Rows appear as data arrives, and disappear as segments get dropped. This can result in strange behavior if accessing the same table multiple times in a single query \(e.g., performing a self join\).

The connector reads and writes message data from Kafka topics in parallel across workers to achieve a significant performance gain. The size of data sets for this parallelization is configurable and can therefore be adapted to your specific needs.

See the kafka-tutorial.

#anchor("ref-kafka-requirements")

== Requirements

To connect to Kafka, you need:

- Kafka broker version 3.3 or higher \(with KRaft enabled\).
- Network access from the Trino coordinator and workers to the Kafka nodes. Port 9092 is the default port.

When using Protobuf decoder with the #link(label("ref-confluent-table-description-supplier"))[Confluent table description supplier], the following additional steps must be taken:

- Copy the #raw("kafka-protobuf-provider") and #raw("kafka-protobuf-types") JAR files from #link("https://packages.confluent.io/maven/io/confluent/")[Confluent] for Confluent version 8.1.1 to the Kafka connector plugin directory \(#raw("<install directory>/plugin/kafka")\) on all nodes in the cluster. The plugin directory depends on the #link(label("doc-installation"))[Installation] method.
- By copying those JARs and using them, you agree to the terms of the #link("https://github.com/confluentinc/schema-registry/blob/master/LICENSE-ConfluentCommunity")[Confluent Community License Agreement] under which Confluent makes them available.

These steps are not required if you are not using Protobuf and Confluent table description supplier.

== Configuration

To configure the Kafka connector, create a catalog properties file #raw("etc/catalog/example.properties") with the following content, replacing the properties as appropriate.

In some cases, such as when using specialized authentication methods, it is necessary to specify additional Kafka client properties in order to access your Kafka cluster. To do so, add the #raw("kafka.config.resources") property to reference your Kafka config files. Note that configs can be overwritten if defined explicitly in #raw("kafka.properties"):

#code-block("text", "connector.name=kafka
kafka.table-names=table1,table2
kafka.nodes=host1:port,host2:port
kafka.config.resources=/etc/kafka-configuration.properties")

=== Multiple Kafka clusters

You can have as many catalogs as you need, so if you have additional Kafka clusters, simply add another properties file to #raw("etc/catalog") with a different name \(making sure it ends in #raw(".properties")\). For example, if you name the property file #raw("sales.properties"), Trino creates a catalog named #raw("sales") using the configured connector.

=== Log levels

Kafka consumer logging can be verbose and pollute Trino logs. To lower the #link(label("ref-logging-configuration"))[log level], simply add the following to #raw("etc/log.properties"):

#code-block("text", "org.apache.kafka=WARN")

== Configuration properties

The following configuration properties are available:

#list-table((
  ([Property name], [Description],),
  ([#raw("kafka.default-schema")], [Default schema name for tables.],),
  ([#raw("kafka.nodes")], [List of nodes in the Kafka cluster.],),
  ([#raw("kafka.buffer-size")], [Kafka read buffer size.],),
  ([#raw("kafka.hide-internal-columns")], [Controls whether internal columns are part of the table schema or not.],),
  ([#raw("kafka.internal-column-prefix")], [Prefix for internal columns, defaults to #raw("_")],),
  ([#raw("kafka.messages-per-split")], [Number of messages that are processed by each Trino split; defaults to #raw("100000").],),
  ([#raw("kafka.protobuf-any-support-enabled")], [Enable support for encoding Protobuf #raw("any") types to #raw("JSON") by setting the property to #raw("true"), defaults to #raw("false").],),
  ([#raw("kafka.timestamp-upper-bound-force-push-down-enabled")], [Controls if upper bound timestamp pushdown is enabled for topics using #raw("CreateTime") mode.],),
  ([#raw("kafka.security-protocol")], [Security protocol for connection to Kafka cluster; defaults to #raw("PLAINTEXT").],),
  ([#raw("kafka.ssl.keystore.location")], [Location of the keystore file.],),
  ([#raw("kafka.ssl.keystore.password")], [Password for the keystore file.],),
  ([#raw("kafka.ssl.keystore.type")], [File format of the keystore file; defaults to #raw("JKS").],),
  ([#raw("kafka.ssl.truststore.location")], [Location of the truststore file.],),
  ([#raw("kafka.ssl.truststore.password")], [Password for the truststore file.],),
  ([#raw("kafka.ssl.truststore.type")], [File format of the truststore file; defaults to #raw("JKS").],),
  ([#raw("kafka.ssl.key.password")], [Password for the private key in the keystore file.],),
  ([#raw("kafka.ssl.endpoint-identification-algorithm")], [Endpoint identification algorithm used by clients to validate server host name; defaults to #raw("https").],),
  ([#raw("kafka.config.resources")], [A comma-separated list of Kafka client configuration files. These files must exist on the machines running Trino. Only specify this if absolutely necessary to access Kafka. Example: #raw("/etc/kafka-configuration.properties")],)
), header-rows: 1)

In addition, you must configure #link(label("ref-kafka-table-schema-registry"))[table schema and schema registry usage] with the relevant properties.

=== #raw("kafka.default-schema")

Defines the schema which contains all tables that were defined without a qualifying schema name.

This property is optional; the default is #raw("default").

=== #raw("kafka.nodes")

A comma separated list of #raw("hostname:port") pairs for the Kafka data nodes.

This property is required; there is no default and at least one node must be defined.

#note[
Trino must still be able to connect to all nodes of the cluster even if only a subset is specified here, as segment files may be located only on a specific node.
]

=== #raw("kafka.buffer-size")

Size of the internal data buffer for reading data from Kafka. The data buffer must be able to hold at least one message and ideally can hold many messages. There is one data buffer allocated per worker and data node.

This property is optional; the default is #raw("64kb").

=== #raw("kafka.timestamp-upper-bound-force-push-down-enabled")

The upper bound predicate on #raw("_timestamp") column is pushed down only for topics using #raw("LogAppendTime") mode.

For topics using #raw("CreateTime") mode, upper bound pushdown must be explicitly enabled via #raw("kafka.timestamp-upper-bound-force-push-down-enabled") config property or #raw("timestamp_upper_bound_force_push_down_enabled") session property.

This property is optional; the default is #raw("false").

=== #raw("kafka.hide-internal-columns")

In addition to the data columns defined in a table description file, the connector maintains a number of additional columns for each table. If these columns are hidden, they can still be used in queries but do not show up in #raw("DESCRIBE <table-name>") or #raw("SELECT *").

This property is optional; the default is #raw("true").

=== #raw("kafka.security-protocol")

Protocol used to communicate with brokers. Valid values are: #raw("PLAINTEXT"), #raw("SSL").

This property is optional; default is #raw("PLAINTEXT").

=== #raw("kafka.ssl.keystore.location")

Location of the keystore file used for connection to Kafka cluster.

This property is optional.

=== #raw("kafka.ssl.keystore.password")

Password for the keystore file used for connection to Kafka cluster.

This property is optional, but required when #raw("kafka.ssl.keystore.location") is given.

=== #raw("kafka.ssl.keystore.type")

File format of the keystore file. Valid values are: #raw("JKS"), #raw("PKCS12").

This property is optional; default is #raw("JKS").

=== #raw("kafka.ssl.truststore.location")

Location of the truststore file used for connection to Kafka cluster.

This property is optional.

=== #raw("kafka.ssl.truststore.password")

Password for the truststore file used for connection to Kafka cluster.

This property is optional, but required when #raw("kafka.ssl.truststore.location") is given.

=== #raw("kafka.ssl.truststore.type")

File format of the truststore file. Valid values are: JKS, PKCS12.

This property is optional; default is #raw("JKS").

=== #raw("kafka.ssl.key.password")

Password for the private key in the keystore file used for connection to Kafka cluster.

This property is optional. This is required for clients only if two-way authentication is configured, i.e. #raw("ssl.client.auth=required").

=== #raw("kafka.ssl.endpoint-identification-algorithm")

The endpoint identification algorithm used by clients to validate server host name for connection to Kafka cluster. Kafka uses #raw("https") as default. Use #raw("disabled") to disable server host name validation.

This property is optional; default is #raw("https").

== Internal columns

The internal column prefix is configurable by #raw("kafka.internal-column-prefix") configuration property and defaults to #raw("_"). A different prefix affects the internal column names in the following sections. For example, a value of #raw("internal_") changes the partition ID column name from #raw("_partition_id") to #raw("internal_partition_id").

For each defined table, the connector maintains the following columns:

#list-table((
  ([Column name], [Type], [Description],),
  ([#raw("_partition_id")], [BIGINT], [ID of the Kafka partition which contains this row.],),
  ([#raw("_partition_offset")], [BIGINT], [Offset within the Kafka partition for this row.],),
  ([#raw("_segment_start")], [BIGINT], [Lowest offset in the segment \(inclusive\) which contains this row. This offset is partition specific.],),
  ([#raw("_segment_end")], [BIGINT], [Highest offset in the segment \(exclusive\) which contains this row. The offset is partition specific. This is the same value as #raw("_segment_start") of the next segment \(if it exists\).],),
  ([#raw("_segment_count")], [BIGINT], [Running count for the current row within the segment. For an uncompacted topic, #raw("_segment_start + _segment_count") is equal to #raw("_partition_offset").],),
  ([#raw("_message_corrupt")], [BOOLEAN], [True if the decoder could not decode the message for this row. When true, data columns mapped from the message should be treated as invalid.],),
  ([#raw("_message")], [VARCHAR], [Message bytes as a UTF-8 encoded string. This is only useful for a text topic.],),
  ([#raw("_message_length")], [BIGINT], [Number of bytes in the message.],),
  ([#raw("_headers")], [map\(VARCHAR, array\(VARBINARY\)\)], [Headers of the message where values with the same key are grouped as array.],),
  ([#raw("_key_corrupt")], [BOOLEAN], [True if the key decoder could not decode the key for this row. When true, data columns mapped from the key should be treated as invalid.],),
  ([#raw("_key")], [VARCHAR], [Key bytes as a UTF-8 encoded string. This is only useful for textual keys.],),
  ([#raw("_key_length")], [BIGINT], [Number of bytes in the key.],),
  ([#raw("_timestamp")], [TIMESTAMP], [Message timestamp.],)
), header-rows: 1)

For tables without a table definition file, the #raw("_key_corrupt") and #raw("_message_corrupt") columns will always be #raw("false").

#anchor("ref-kafka-table-schema-registry")

== Table schema and schema registry usage

The table schema for the messages can be supplied to the connector with a configuration file or a schema registry. It also provides a mechanism for the connector to discover tables.

You must configure the supplier with the #raw("kafka.table-description-supplier") property, setting it to #raw("FILE") or #raw("CONFLUENT"). Each table description supplier has a separate set of configuration properties.

Refer to the following subsections for more detail. The #raw("FILE") table description supplier is the default, and the value is case-insensitive.

=== File table description supplier

In order to use the file-based table description supplier, the #raw("kafka.table-description-supplier") must be set to #raw("FILE"), which is the default.

In addition, you must set #raw("kafka.table-names") and #raw("kafka.table-description-dir") as described in the following sections:

==== #raw("kafka.table-names")

Comma-separated list of all tables provided by this catalog. A table name can be unqualified \(simple name\), and is placed into the default schema \(see below\), or it can be qualified with a schema name \(#raw("<schema-name>.<table-name>")\).

For each table defined here, a table description file \(see below\) may exist. If no table description file exists, the table name is used as the topic name on Kafka, and no data columns are mapped into the table. The table still contains all internal columns \(see below\).

This property is required; there is no default and at least one table must be defined.

==== #raw("kafka.table-description-dir")

References a folder within Trino deployment that holds one or more JSON files \(must end with #raw(".json")\) which contain table description files.

This property is optional; the default is #raw("etc/kafka").

#anchor("ref-table-definition-files")

==== Table definition files

Kafka maintains topics only as byte messages and leaves it to producers and consumers to define how a message should be interpreted. For Trino, this data must be mapped into columns to allow queries against the data.

#note[
For textual topics that contain JSON data, it is entirely possible to not use any table definition files, but instead use the Trino #link(label("doc-functions-json"))[JSON functions and operators] to parse the #raw("_message") column which contains the bytes mapped into a UTF-8 string. This is cumbersome and makes it difficult to write SQL queries. This only works when reading data.
]

A table definition file consists of a JSON definition for a table. The name of the file can be arbitrary but must end in #raw(".json"). Place the file in the directory configured with the #raw("kafka.table-description-dir") property. The table definition file must be accessible from all Trino nodes.

#code-block("text", "{
    \"tableName\": ...,
    \"schemaName\": ...,
    \"topicName\": ...,
    \"key\": {
        \"dataFormat\": ...,
        \"fields\": [
            ...
        ]
    },
    \"message\": {
        \"dataFormat\": ...,
        \"fields\": [
            ...
       ]
    }
}")

#list-table((
  ([Field], [Required], [Type], [Description],),
  ([#raw("tableName")], [required], [string], [Trino table name defined by this file.],),
  ([#raw("schemaName")], [optional], [string], [Schema containing the table. If omitted, the default schema name is used.],),
  ([#raw("topicName")], [required], [string], [Kafka topic that is mapped.],),
  ([#raw("key")], [optional], [JSON object], [Field definitions for data columns mapped to the message key.],),
  ([#raw("message")], [optional], [JSON object], [Field definitions for data columns mapped to the message itself.],)
), header-rows: 1)

==== Key and message in Kafka

Starting with Kafka 0.8, each message in a topic can have an optional key. A table definition file contains sections for both key and message to map the data onto table columns.

Each of the #raw("key") and #raw("message") fields in the table definition is a JSON object that must contain two fields:

#list-table((
  ([Field], [Required], [Type], [Description],),
  ([#raw("dataFormat")], [required], [string], [Selects the decoder for this group of fields.],),
  ([#raw("fields")], [required], [JSON array], [A list of field definitions. Each field definition creates a new column in the Trino table.],)
), header-rows: 1)

Each field definition is a JSON object:

#code-block("text", "{
    \"name\": ...,
    \"type\": ...,
    \"dataFormat\": ...,
    \"mapping\": ...,
    \"formatHint\": ...,
    \"hidden\": ...,
    \"comment\": ...
}")

#list-table((
  ([Field], [Required], [Type], [Description],),
  ([#raw("name")], [required], [string], [Name of the column in the Trino table.],),
  ([#raw("type")], [required], [string], [Trino type of the column.],),
  ([#raw("dataFormat")], [optional], [string], [Selects the column decoder for this field. Defaults to the default decoder for this row data format and column type.],),
  ([#raw("dataSchema")], [optional], [string], [The path or URL where the Avro schema resides. Used only for Avro decoder.],),
  ([#raw("mapping")], [optional], [string], [Mapping information for the column. This is decoder specific, see below.],),
  ([#raw("formatHint")], [optional], [string], [Sets a column-specific format hint to the column decoder.],),
  ([#raw("hidden")], [optional], [boolean], [Hides the column from #raw("DESCRIBE <table name>") and #raw("SELECT *"). Defaults to #raw("false").],),
  ([#raw("comment")], [optional], [string], [Adds a column comment, which is shown with #raw("DESCRIBE <table name>").],)
), header-rows: 1)

There is no limit on field descriptions for either key or message.

#anchor("ref-confluent-table-description-supplier")

=== Confluent table description supplier

The Confluent table description supplier uses the #link("https://docs.confluent.io/1.0/schema-registry/docs/intro.html")[Confluent Schema Registry] to discover table definitions. It is only tested to work with the Confluent Schema Registry.

The benefits of using the Confluent table description supplier over the file table description supplier are:

- New tables can be defined without a cluster restart.
- Schema updates are detected automatically.
- There is no need to define tables manually.
- Some Protobuf specific types like #raw("oneof") and #raw("any") are supported and mapped to JSON.

When using Protobuf decoder with the Confluent table description supplier, some additional steps are necessary. For details, refer to #link(label("ref-kafka-requirements"))[kafka-requirements].

Set #raw("kafka.table-description-supplier") to #raw("CONFLUENT") to use the schema registry. You must also configure the additional properties in the following table:

#note[
Inserts are not supported, and the only data format supported is AVRO.
]

#list-table((
  ([Property name], [Description], [Default value],),
  ([#raw("kafka.confluent-schema-registry-url")], [Comma-separated list of URL addresses for the Confluent schema registry. For example, #raw("http://schema-registry-1.example.org:8081,http://schema-registry-2.example.org:8081")], [],),
  ([#raw("kafka.confluent-schema-registry-client-cache-size")], [The maximum number of subjects that can be stored in the local cache. The cache stores the schemas locally by subjectId, and is provided by the Confluent #raw("CachingSchemaRegistry") client.], [1000],),
  ([#raw("kafka.empty-field-strategy")], [Avro allows empty struct fields, but this is not allowed in Trino. There are three strategies for handling empty struct fields:

- #raw("IGNORE") - Ignore structs with no fields. This propagates to parents. For example, an array of structs with no fields is ignored.
- #raw("FAIL") - Fail the query if a struct with no fields is defined.
- #raw("MARK") - Add a marker field named #raw("$empty_field_marker"), which of type boolean with a null value. This may be desired if the struct represents a marker field.

This can also be modified via the #raw("empty_field_strategy") session property.], [#raw("IGNORE")],),
  ([#raw("kafka.confluent-subjects-cache-refresh-interval")], [The interval used for refreshing the list of subjects and the definition of the schema for the subject in the subject's cache.], [#raw("1s")],)
), header-rows: 1, title: "Confluent table description supplier properties")

==== Confluent subject to table name mapping

The #link("https://docs.confluent.io/platform/current/schema-registry/serdes-develop/index.html#sr-schemas-subject-name-strategy")[subject naming strategy] determines how a subject is resolved from the table name.

The default strategy is the #raw("TopicNameStrategy"), where the key subject is defined as #raw("<topic-name>-key") and the value subject is defined as #raw("<topic-name>-value"). If other strategies are used there is no way to determine the subject name beforehand, so it must be specified manually in the table name.

To manually specify the key and value subjects, append to the topic name, for example: #raw("<topic name>&key-subject=<key subject>&value-subject=<value subject>"). Both the #raw("key-subject") and #raw("value-subject") parameters are optional. If neither is specified, then the default #raw("TopicNameStrategy") is used to resolve the subject name via the topic name. Note that a case-insensitive match must be done, as identifiers cannot contain upper case characters.

==== Protobuf-specific type handling in Confluent table description supplier

When using the Confluent table description supplier, the following Protobuf specific types are supported in addition to the #link(label("ref-kafka-protobuf-decoding"))[normally supported types]:

===== oneof

Protobuf schemas containing #raw("oneof") fields are mapped to a #raw("JSON") field in Trino.

For example, given the following Protobuf schema:

#code-block("text", "syntax = \"proto3\";

message schema {
    oneof test_oneof_column {
        string string_column = 1;
        uint32 integer_column = 2;
        uint64 long_column = 3;
        double double_column = 4;
        float float_column = 5;
        bool boolean_column = 6;
    }
}")

The corresponding Trino row is a #raw("JSON") field #raw("test_oneof_column") containing a JSON object with a single key. The value of the key matches the name of the #raw("oneof") type that is present.

In the above example, if the Protobuf message has the #raw("test_oneof_column") containing #raw("string_column") set to a value #raw("Trino") then the corresponding Trino row includes a column named #raw("test_oneof_column") with the value #raw("JSON '{\"string_column\": \"Trino\"}'").

#anchor("ref-kafka-sql-inserts")

== Kafka inserts

The Kafka connector supports the use of #link(label("doc-sql-insert"))[INSERT] statements to write data to a Kafka topic. Table column data is mapped to Kafka messages as defined in the #link("#table-definition-files")[table definition file]. There are five supported data formats for key and message encoding:

- #link(label("ref-raw-encoder"))[raw format]
- #link(label("ref-csv-encoder"))[CSV format]
- #link(label("ref-json-encoder"))[JSON format]
- #link(label("ref-avro-encoder"))[Avro format]
- #link(label("ref-kafka-protobuf-encoding"))[Protobuf format]

These data formats each have an encoder that maps column values into bytes to be sent to a Kafka topic.

Trino supports at-least-once delivery for Kafka producers. This means that messages are guaranteed to be sent to Kafka topics at least once. If a producer acknowledgement times out, or if the producer receives an error, it might retry sending the message. This could result in a duplicate message being sent to the Kafka topic.

The Kafka connector does not allow the user to define which partition will be used as the target for a message. If a message includes a key, the producer will use a hash algorithm to choose the target partition for the message. The same key will always be assigned the same partition.

#anchor("ref-kafka-type-mapping")

== Type mapping

Because Trino and Kafka each support types that the other does not, this connector #link(label("ref-type-mapping-overview"))[maps some types] when reading \(#link(label("ref-kafka-row-decoding"))[decoding]\) or writing \(#link(label("ref-kafka-row-encoding"))[encoding]\) data. Type mapping depends on the format \(Raw, Avro, JSON, CSV\).

#anchor("ref-kafka-row-encoding")

=== Row encoding

Encoding is required to allow writing data; it defines how table columns in Trino map to Kafka keys and message data.

The Kafka connector contains the following encoders:

- #link(label("ref-raw-encoder"))[raw encoder] - Table columns are mapped to a Kafka message as raw bytes.
- #link(label("ref-csv-encoder"))[CSV encoder] - Kafka message is formatted as a comma-separated value.
- #link(label("ref-json-encoder"))[JSON encoder] - Table columns are mapped to JSON fields.
- #link(label("ref-avro-encoder"))[Avro encoder] - Table columns are mapped to Avro fields based on an Avro schema.
- #link(label("ref-kafka-protobuf-encoding"))[Protobuf encoder] - Table columns are mapped to Protobuf fields based on a Protobuf schema.

#note[
A #link("#table-definition-files")[table definition file] must be defined for the encoder to work.
]

#anchor("ref-raw-encoder")

==== Raw encoder

The raw encoder formats the table columns as raw bytes using the mapping information specified in the #link("#table-definition-files")[table definition file].

The following field attributes are supported:

- #raw("dataFormat") - Specifies the width of the column data type.
- #raw("type") - Trino data type.
- #raw("mapping") - start and optional end position of bytes to convert \(specified as #raw("start") or #raw("start:end")\).

The #raw("dataFormat") attribute selects the number of bytes converted. If absent, #raw("BYTE") is assumed. All values are signed.

Supported values:

- #raw("BYTE") - one byte
- #raw("SHORT") - two bytes \(big-endian\)
- #raw("INT") - four bytes \(big-endian\)
- #raw("LONG") - eight bytes \(big-endian\)
- #raw("FLOAT") - four bytes \(IEEE 754 format, big-endian\)
- #raw("DOUBLE") - eight bytes \(IEEE 754 format, big-endian\)

The #raw("type") attribute defines the Trino data type.

Different values of #raw("dataFormat") are supported, depending on the Trino data type:

#list-table((
  ([Trino data type], [#raw("dataFormat") values],),
  ([#raw("BIGINT")], [#raw("BYTE"), #raw("SHORT"), #raw("INT"), #raw("LONG")],),
  ([#raw("INTEGER")], [#raw("BYTE"), #raw("SHORT"), #raw("INT")],),
  ([#raw("SMALLINT")], [#raw("BYTE"), #raw("SHORT")],),
  ([#raw("TINYINT")], [#raw("BYTE")],),
  ([#raw("REAL")], [#raw("FLOAT")],),
  ([#raw("DOUBLE")], [#raw("FLOAT"), #raw("DOUBLE")],),
  ([#raw("BOOLEAN")], [#raw("BYTE"), #raw("SHORT"), #raw("INT"), #raw("LONG")],),
  ([#raw("VARCHAR") \/ #raw("VARCHAR(x)")], [#raw("BYTE")],)
), header-rows: 1)

No other types are supported.

The #raw("mapping") attribute specifies the range of bytes in a key or message used for encoding.

#note[
Both a start and end position must be defined for #raw("VARCHAR") types. Otherwise, there is no way to know how many bytes the message contains. The raw format mapping information is static and cannot be dynamically changed to fit the variable width of some Trino data types.
]

If only a start position is given:

- For fixed width types, the appropriate number of bytes are used for the specified #raw("dataFormat") \(see above\).

If both a start and end position are given, then:

- For fixed width types, the size must be equal to number of bytes used by specified #raw("dataFormat").
- All bytes between start \(inclusive\) and end \(exclusive\) are used.

#note[
All mappings must include a start position for encoding to work.
]

The encoding for numeric data types \(#raw("BIGINT"), #raw("INTEGER"), #raw("SMALLINT"), #raw("TINYINT"), #raw("REAL"), #raw("DOUBLE")\) is straightforward. All numeric types use big-endian. Floating point types use IEEE 754 format.

Example raw field definition in a #link("#table-definition-files")[table definition file] for a Kafka message:

#code-block("json", "{
  \"tableName\": \"example_table_name\",
  \"schemaName\": \"example_schema_name\",
  \"topicName\": \"example_topic_name\",
  \"key\": { \"...\" },
  \"message\": {
    \"dataFormat\": \"raw\",
    \"fields\": [
      {
        \"name\": \"field1\",
        \"type\": \"BIGINT\",
        \"dataFormat\": \"LONG\",
        \"mapping\": \"0\"
      },
      {
        \"name\": \"field2\",
        \"type\": \"INTEGER\",
        \"dataFormat\": \"INT\",
        \"mapping\": \"8\"
      },
      {
        \"name\": \"field3\",
        \"type\": \"SMALLINT\",
        \"dataFormat\": \"LONG\",
        \"mapping\": \"12\"
      },
      {
        \"name\": \"field4\",
        \"type\": \"VARCHAR(6)\",
        \"dataFormat\": \"BYTE\",
        \"mapping\": \"20:26\"
      }
    ]
  }
}")

Columns should be defined in the same order they are mapped. There can be no gaps or overlaps between column mappings. The width of the column as defined by the column mapping must be equivalent to the width of the #raw("dataFormat") for all types except for variable width types.

Example insert query for the above table definition:

#code-block(none, "INSERT INTO example_raw_table (field1, field2, field3, field4)
  VALUES (123456789, 123456, 1234, 'abcdef');")

#note[
The raw encoder requires the field size to be known ahead of time, including for variable width data types like #raw("VARCHAR"). It also disallows inserting values that do not match the width defined in the table definition file. This is done to ensure correctness, as otherwise longer values are truncated, and shorter values are read back incorrectly due to an undefined padding character.
]

#anchor("ref-csv-encoder")

==== CSV encoder

The CSV encoder formats the values for each row as a line of comma-separated-values \(CSV\) using UTF-8 encoding. The CSV line is formatted with a comma #raw(",") as the column delimiter.

The #raw("type") and #raw("mapping") attributes must be defined for each field:

- #raw("type") - Trino data type
- #raw("mapping") - The integer index of the column in the CSV line \(the first column is 0, the second is 1, and so on\)

#raw("dataFormat") and #raw("formatHint") are not supported and must be omitted.

The following Trino data types are supported by the CSV encoder:

- #raw("BIGINT")
- #raw("INTEGER")
- #raw("SMALLINT")
- #raw("TINYINT")
- #raw("DOUBLE")
- #raw("REAL")
- #raw("BOOLEAN")
- #raw("VARCHAR") \/ #raw("VARCHAR(x)")

No other types are supported.

Column values are converted to strings before they are formatted as a CSV line.

The following is an example CSV field definition in a #link("#table-definition-files")[table definition file] for a Kafka message:

#code-block("json", "{
  \"tableName\": \"example_table_name\",
  \"schemaName\": \"example_schema_name\",
  \"topicName\": \"example_topic_name\",
  \"key\": { \"...\" },
  \"message\": {
    \"dataFormat\": \"csv\",
    \"fields\": [
      {
        \"name\": \"field1\",
        \"type\": \"BIGINT\",
        \"mapping\": \"0\"
      },
      {
        \"name\": \"field2\",
        \"type\": \"VARCHAR\",
        \"mapping\": \"1\"
      },
      {
        \"name\": \"field3\",
        \"type\": \"BOOLEAN\",
        \"mapping\": \"2\"
      }
    ]
  }
}")

Example insert query for the above table definition:

#code-block(none, "INSERT INTO example_csv_table (field1, field2, field3)
  VALUES (123456789, 'example text', TRUE);")

#anchor("ref-json-encoder")

==== JSON encoder

The JSON encoder maps table columns to JSON fields defined in the #link("#table-definition-files")[table definition file] according to #link("https://www.rfc-editor.org/rfc/rfc4627")[RFC 4627].

For fields, the following attributes are supported:

- #raw("type") - Trino data type of column.
- #raw("mapping") - A slash-separated list of field names to select a field from the JSON object.
- #raw("dataFormat") - Name of formatter. Required for temporal types.
- #raw("formatHint") - Pattern to format temporal data. Only use with #raw("custom-date-time") formatter.

The following Trino data types are supported by the JSON encoder:

- #raw("BIGINT")
- #raw("INTEGER")
- #raw("SMALLINT")
- #raw("TINYINT")
- #raw("DOUBLE")
- #raw("REAL")
- #raw("BOOLEAN")
- #raw("VARCHAR")
- #raw("DATE")
- #raw("TIME")
- #raw("TIME WITH TIME ZONE")
- #raw("TIMESTAMP")
- #raw("TIMESTAMP WITH TIME ZONE")

No other types are supported.

The following #raw("dataFormats") are available for temporal data:

- #raw("iso8601")
- #raw("rfc2822")
- #raw("custom-date-time") - Formats temporal data according to #link("https://www.joda.org/joda-time/key_format.html")[Joda Time] pattern given by #raw("formatHint") field.
- #raw("milliseconds-since-epoch")
- #raw("seconds-since-epoch")

All temporal data in Kafka supports milliseconds precision.

The following table defines which temporal data types are supported by #raw("dataFormats"):

#list-table((
  ([Trino data type], [Decoding rules],),
  ([#raw("DATE")], [#raw("custom-date-time"), #raw("iso8601")],),
  ([#raw("TIME")], [#raw("custom-date-time"), #raw("iso8601"), #raw("milliseconds-since-epoch"), #raw("seconds-since-epoch")],),
  ([#raw("TIME WITH TIME ZONE")], [#raw("custom-date-time"), #raw("iso8601")],),
  ([#raw("TIMESTAMP")], [#raw("custom-date-time"), #raw("iso8601"), #raw("rfc2822"), #raw("milliseconds-since-epoch"), #raw("seconds-since-epoch")],),
  ([#raw("TIMESTAMP WITH TIME ZONE")], [#raw("custom-date-time"), #raw("iso8601"), #raw("rfc2822"), #raw("milliseconds-since-epoch"), #raw("seconds-since-epoch")],)
), header-rows: 1)

The following is an example JSON field definition in a #link("#table-definition-files")[table definition file] for a Kafka message:

#code-block("json", "{
  \"tableName\": \"example_table_name\",
  \"schemaName\": \"example_schema_name\",
  \"topicName\": \"example_topic_name\",
  \"key\": { \"...\" },
  \"message\": {
    \"dataFormat\": \"json\",
    \"fields\": [
      {
        \"name\": \"field1\",
        \"type\": \"BIGINT\",
        \"mapping\": \"field1\"
      },
      {
        \"name\": \"field2\",
        \"type\": \"VARCHAR\",
        \"mapping\": \"field2\"
      },
      {
        \"name\": \"field3\",
        \"type\": \"TIMESTAMP\",
        \"dataFormat\": \"custom-date-time\",
        \"formatHint\": \"yyyy-dd-MM HH:mm:ss.SSS\",
        \"mapping\": \"field3\"
      }
    ]
  }
}")

The following shows an example insert query for the preceding table definition:

#code-block(none, "INSERT INTO example_json_table (field1, field2, field3)
  VALUES (123456789, 'example text', TIMESTAMP '2020-07-15 01:02:03.456');")

#anchor("ref-avro-encoder")

==== Avro encoder

The Avro encoder serializes rows to Avro records as defined by the #link("https://avro.apache.org/docs/current/")[Avro schema]. Trino does not support schemaless Avro encoding.

#note[
The Avro schema is encoded with the table column values in each Kafka message.
]

The #raw("dataSchema") must be defined in the table definition file to use the Avro encoder. It points to the location of the Avro schema file for the key or message.

Avro schema files can be retrieved via HTTP or HTTPS from remote server with the syntax:

#raw("\"dataSchema\": \"http://example.org/schema/avro_data.avsc\"")

Local files need to be available on all Trino nodes and use an absolute path in the syntax, for example:

#raw("\"dataSchema\": \"/usr/local/schema/avro_data.avsc\"")

The following field attributes are supported:

- #raw("name") - Name of the column in the Trino table.
- #raw("type") - Trino data type of column.
- #raw("mapping") - A slash-separated list of field names to select a field from the Avro schema. If the field specified in #raw("mapping") does not exist in the original Avro schema, then a write operation fails.

The following table lists supported Trino data types, which can be used in #raw("type") for the equivalent Avro field type.

#list-table((
  ([Trino data type], [Avro data type],),
  ([#raw("BIGINT")], [#raw("INT"), #raw("LONG")],),
  ([#raw("REAL")], [#raw("FLOAT")],),
  ([#raw("DOUBLE")], [#raw("FLOAT"), #raw("DOUBLE")],),
  ([#raw("BOOLEAN")], [#raw("BOOLEAN")],),
  ([#raw("VARCHAR") \/ #raw("VARCHAR(x)")], [#raw("STRING")],)
), header-rows: 1)

No other types are supported.

The following example shows an Avro field definition in a #link("#table-definition-files")[table definition file] for a Kafka message:

#code-block("json", "{
  \"tableName\": \"example_table_name\",
  \"schemaName\": \"example_schema_name\",
  \"topicName\": \"example_topic_name\",
  \"key\": { \"...\" },
  \"message\":
  {
    \"dataFormat\": \"avro\",
    \"dataSchema\": \"/avro_message_schema.avsc\",
    \"fields\":
    [
      {
        \"name\": \"field1\",
        \"type\": \"BIGINT\",
        \"mapping\": \"field1\"
      },
      {
        \"name\": \"field2\",
        \"type\": \"VARCHAR\",
        \"mapping\": \"field2\"
      },
      {
        \"name\": \"field3\",
        \"type\": \"BOOLEAN\",
        \"mapping\": \"field3\"
      }
    ]
  }
}")

In the following example, an Avro schema definition for the preceding table definition is shown:

#code-block("json", "{
  \"type\" : \"record\",
  \"name\" : \"example_avro_message\",
  \"namespace\" : \"io.trino.plugin.kafka\",
  \"fields\" :
  [
    {
      \"name\":\"field1\",
      \"type\":[\"null\", \"long\"],
      \"default\": null
    },
    {
      \"name\": \"field2\",
      \"type\":[\"null\", \"string\"],
      \"default\": null
    },
    {
      \"name\":\"field3\",
      \"type\":[\"null\", \"boolean\"],
      \"default\": null
    }
  ],
  \"doc:\" : \"A basic avro schema\"
}")

The following is an example insert query for the preceding table definition:

#quote(block: true)[
/ INSERT INTO example\_avro\_table \(field1, field2, field3\): VALUES \(123456789, 'example text', FALSE\);
]

#anchor("ref-kafka-protobuf-encoding")

==== Protobuf encoder

The Protobuf encoder serializes rows to Protobuf DynamicMessages as defined by the #link("https://developers.google.com/protocol-buffers/docs/overview")[Protobuf schema].

#note[
The Protobuf schema is encoded with the table column values in each Kafka message.
]

The #raw("dataSchema") must be defined in the table definition file to use the Protobuf encoder. It points to the location of the #raw("proto") file for the key or message.

Protobuf schema files can be retrieved via HTTP or HTTPS from a remote server with the syntax:

#raw("\"dataSchema\": \"http://example.org/schema/schema.proto\"")

Local files need to be available on all Trino nodes and use an absolute path in the syntax, for example:

#raw("\"dataSchema\": \"/usr/local/schema/schema.proto\"")

The following field attributes are supported:

- #raw("name") - Name of the column in the Trino table.
- #raw("type") - Trino type of column.
- #raw("mapping") - slash-separated list of field names to select a field from the Protobuf schema. If the field specified in #raw("mapping") does not exist in the original Protobuf schema, then a write operation fails.

The following table lists supported Trino data types, which can be used in #raw("type") for the equivalent Protobuf field type.

#list-table((
  ([Trino data type], [Protobuf data type],),
  ([#raw("BOOLEAN")], [#raw("bool")],),
  ([#raw("INTEGER")], [#raw("int32"), #raw("uint32"), #raw("sint32"), #raw("fixed32"), #raw("sfixed32")],),
  ([#raw("BIGINT")], [#raw("int64"), #raw("uint64"), #raw("sint64"), #raw("fixed64"), #raw("sfixed64")],),
  ([#raw("DOUBLE")], [#raw("double")],),
  ([#raw("REAL")], [#raw("float")],),
  ([#raw("VARCHAR") \/ #raw("VARCHAR(x)")], [#raw("string")],),
  ([#raw("VARBINARY")], [#raw("bytes")],),
  ([#raw("ROW")], [#raw("Message")],),
  ([#raw("ARRAY")], [Protobuf type with #raw("repeated") field],),
  ([#raw("MAP")], [#raw("Map")],),
  ([#raw("TIMESTAMP")], [#raw("Timestamp"), predefined in #raw("timestamp.proto")],)
), header-rows: 1)

The following example shows a Protobuf field definition in a #link("#table-definition-files")[table definition file] for a Kafka message:

#code-block("json", "{
  \"tableName\": \"example_table_name\",
  \"schemaName\": \"example_schema_name\",
  \"topicName\": \"example_topic_name\",
  \"key\": { \"...\" },
  \"message\":
  {
    \"dataFormat\": \"protobuf\",
    \"dataSchema\": \"/message_schema.proto\",
    \"fields\":
    [
      {
        \"name\": \"field1\",
        \"type\": \"BIGINT\",
        \"mapping\": \"field1\"
      },
      {
        \"name\": \"field2\",
        \"type\": \"VARCHAR\",
        \"mapping\": \"field2\"
      },
      {
        \"name\": \"field3\",
        \"type\": \"BOOLEAN\",
        \"mapping\": \"field3\"
      }
    ]
  }
}")

In the following example, a Protobuf schema definition for the preceding table definition is shown:

#code-block("text", "syntax = \"proto3\";

message schema {
  uint64 field1 = 1 ;
  string field2 = 2;
  bool field3 = 3;
}")

The following is an example insert query for the preceding table definition:

#code-block("sql", "INSERT INTO example_protobuf_table (field1, field2, field3)
  VALUES (123456789, 'example text', FALSE);")

#anchor("ref-kafka-row-decoding")

=== Row decoding

For key and message, a decoder is used to map message and key data onto table columns.

The Kafka connector contains the following decoders:

- #raw("raw") - Kafka message is not interpreted; ranges of raw message bytes are mapped to table columns.
- #raw("csv") - Kafka message is interpreted as comma separated message, and fields are mapped to table columns.
- #raw("json") - Kafka message is parsed as JSON, and JSON fields are mapped to table columns.
- #raw("avro") - Kafka message is parsed based on an Avro schema, and Avro fields are mapped to table columns.
- #raw("protobuf") - Kafka message is parsed based on a Protobuf schema, and Protobuf fields are mapped to table columns.

#note[
If no table definition file exists for a table, the #raw("dummy") decoder is used, which does not expose any columns.
]

==== Raw decoder

The raw decoder supports reading of raw byte-based values from Kafka message or key, and converting it into Trino columns.

For fields, the following attributes are supported:

- #raw("dataFormat") - Selects the width of the data type converted.
- #raw("type") - Trino data type. See table later min this document for list of supported data types.
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
  ([#raw("TINYINT")], [#raw("BYTE")],),
  ([#raw("DOUBLE")], [#raw("DOUBLE"), #raw("FLOAT")],),
  ([#raw("BOOLEAN")], [#raw("BYTE"), #raw("SHORT"), #raw("INT"), #raw("LONG")],),
  ([#raw("VARCHAR") \/ #raw("VARCHAR(x)")], [#raw("BYTE")],)
), header-rows: 1)

No other types are supported.

The #raw("mapping") attribute specifies the range of the bytes in a key or message used for decoding. It can be one or two numbers separated by a colon \(#raw("<start>[:<end>]")\).

If only a start position is given:

- For fixed width types, the column will use the appropriate number of bytes for the specified #raw("dataFormat") \(see above\).
- When #raw("VARCHAR") value is decoded, all bytes from start position till the end of the message will be used.

If start and end position are given:

- For fixed width types, the size must be equal to number of bytes used by specified #raw("dataFormat").
- For #raw("VARCHAR") all bytes between start \(inclusive\) and end \(exclusive\) are used.

If no #raw("mapping") attribute is specified, it is equivalent to setting start position to 0 and leaving end position undefined.

The decoding scheme of numeric data types \(#raw("BIGINT"), #raw("INTEGER"), #raw("SMALLINT"), #raw("TINYINT"), #raw("DOUBLE")\) is straightforward. A sequence of bytes is read from input message and decoded according to either:

- big-endian encoding \(for integer types\)
- IEEE 754 format for \(for #raw("DOUBLE")\).

Length of decoded byte sequence is implied by the #raw("dataFormat").

For #raw("VARCHAR") data type a sequence of bytes is interpreted according to UTF-8 encoding.

==== CSV decoder

The CSV decoder converts the bytes representing a message or key into a string using UTF-8 encoding and then interprets the result as a CSV \(comma-separated value\) line.

For fields, the #raw("type") and #raw("mapping") attributes must be defined:

- #raw("type") - Trino data type. See the following table for a list of supported data types.
- #raw("mapping") - The index of the field in the CSV record.

The #raw("dataFormat") and #raw("formatHint") attributes are not supported and must be omitted.

Table below lists supported Trino types, which can be used in #raw("type") and decoding scheme:

#list-table((
  ([Trino data type], [Decoding rules],),
  ([#raw("BIGINT"), #raw("INTEGER"), #raw("SMALLINT"), #raw("TINYINT")], [Decoded using Java #raw("Long.parseLong()")],),
  ([#raw("DOUBLE")], [Decoded using Java #raw("Double.parseDouble()")],),
  ([#raw("BOOLEAN")], ["true" character sequence maps to #raw("true"); Other character sequences map to #raw("false")],),
  ([#raw("VARCHAR"), #raw("VARCHAR(x)")], [Used as is],)
), header-rows: 1)

No other types are supported.

==== JSON decoder

The JSON decoder converts the bytes representing a message or key into a JSON according to #link("https://www.rfc-editor.org/rfc/rfc4627")[RFC 4627]. Note that the message or key #emph[MUST] convert into a JSON object, not an array or simple type.

For fields, the following attributes are supported:

- #raw("type") - Trino data type of column.
- #raw("dataFormat") - Field decoder to be used for column.
- #raw("mapping") - slash-separated list of field names to select a field from the JSON object.
- #raw("formatHint") - Only for #raw("custom-date-time").

The JSON decoder supports multiple field decoders, with #raw("_default") being used for standard table columns and a number of decoders for date- and time-based types.

The following table lists Trino data types, which can be used as in #raw("type"), and matching field decoders, which can be specified via #raw("dataFormat") attribute.

#list-table((
  ([Trino data type], [Allowed #raw("dataFormat") values],),
  ([#raw("BIGINT"), #raw("INTEGER"), #raw("SMALLINT"), #raw("TINYINT"), #raw("DOUBLE"), #raw("BOOLEAN"), #raw("VARCHAR"), #raw("VARCHAR(x)")], [Default field decoder \(omitted #raw("dataFormat") attribute\)],),
  ([#raw("DATE")], [#raw("custom-date-time"), #raw("iso8601")],),
  ([#raw("TIME")], [#raw("custom-date-time"), #raw("iso8601"), #raw("milliseconds-since-epoch"), #raw("seconds-since-epoch")],),
  ([#raw("TIME WITH TIME ZONE")], [#raw("custom-date-time"), #raw("iso8601")],),
  ([#raw("TIMESTAMP")], [#raw("custom-date-time"), #raw("iso8601"), #raw("rfc2822"), #raw("milliseconds-since-epoch"), #raw("seconds-since-epoch")],),
  ([#raw("TIMESTAMP WITH TIME ZONE")], [#raw("custom-date-time"), #raw("iso8601"), #raw("rfc2822"), #raw("milliseconds-since-epoch") #raw("seconds-since-epoch")],)
), header-rows: 1)

No other types are supported.

===== Default field decoder

This is the standard field decoder, supporting all the Trino physical data types. A field value is transformed under JSON conversion rules into boolean, long, double or string values. For non-date\/time based columns, this decoder should be used.

===== Date and time decoders

To convert values from JSON objects into Trino #raw("DATE"), #raw("TIME"), #raw("TIME WITH TIME ZONE"), #raw("TIMESTAMP") or #raw("TIMESTAMP WITH TIME ZONE") columns, special decoders must be selected using the #raw("dataFormat") attribute of a field definition.

- #raw("iso8601") - Text based, parses a text field as an ISO 8601 timestamp.
- #raw("rfc2822") - Text based, parses a text field as an #link("https://www.rfc-editor.org/rfc/rfc2822")[RFC 2822] timestamp.
- / #raw("custom-date-time") - Text based, parses a text field according to Joda format pattern: specified via #raw("formatHint") attribute. Format pattern should conform to #link("https://www.joda.org/joda-time/apidocs/org/joda/time/format/DateTimeFormat.html")[https:\/\/www.joda.org\/joda-time\/apidocs\/org\/joda\/time\/format\/DateTimeFormat.html].
- #raw("milliseconds-since-epoch") - Number-based; interprets a text or number as number of milliseconds since the epoch.
- #raw("seconds-since-epoch") - Number-based; interprets a text or number as number of milliseconds since the epoch.

For #raw("TIMESTAMP WITH TIME ZONE") and #raw("TIME WITH TIME ZONE") data types, if timezone information is present in decoded value, it will be used as Trino value. Otherwise result time zone will be set to #raw("UTC").

==== Avro decoder

The Avro decoder converts the bytes representing a message or key in Avro format based on a schema. The message must have the Avro schema embedded. Trino does not support schemaless Avro decoding.

For key\/message, using #raw("avro") decoder, the #raw("dataSchema") must be defined. This should point to the location of a valid Avro schema file of the message which needs to be decoded. This location can be a remote web server \(e.g.: #raw("dataSchema: 'http://example.org/schema/avro_data.avsc'")\) or local file system\(e.g.: #raw("dataSchema: '/usr/local/schema/avro_data.avsc'")\). The decoder fails if this location is not accessible from the Trino coordinator node.

For fields, the following attributes are supported:

- #raw("name") - Name of the column in the Trino table.
- #raw("type") - Trino data type of column.
- #raw("mapping") - A slash-separated list of field names to select a field from the Avro schema. If field specified in #raw("mapping") does not exist in the original Avro schema, then a read operation returns #raw("NULL").

The following table lists the supported Trino types which can be used in #raw("type") for the equivalent Avro field types:

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

The Avro decoder supports schema evolution feature with backward compatibility. With backward compatibility, a newer schema can be used to read Avro data created with an older schema. Any change in the Avro schema must also be reflected in Trino's topic definition file. Newly added\/renamed fields #emph[must] have a default value in the Avro schema file.

The schema evolution behavior is as follows:

- Column added in new schema: Data created with an older schema produces a #emph[default] value when the table is using the new schema.
- Column removed in new schema: Data created with an older schema no longer outputs the data from the column that was removed.
- Column is renamed in the new schema: This is equivalent to removing the column and adding a new one, and data created with an older schema produces a #emph[default] value when table is using the new schema.
- Changing type of column in the new schema: If the type coercion is supported by Avro, then the conversion happens. An error is thrown for incompatible types.

#anchor("ref-kafka-protobuf-decoding")

==== Protobuf decoder

The Protobuf decoder converts the bytes representing a message or key in Protobuf formatted message based on a schema.

For key\/message, using the #raw("protobuf") decoder, the #raw("dataSchema") must be defined. It points to the location of a valid #raw("proto") file of the message which needs to be decoded. This location can be a remote web server, #raw("dataSchema: 'http://example.org/schema/schema.proto'"),  or local file, #raw("dataSchema: '/usr/local/schema/schema.proto'"). The decoder fails if the location is not accessible from the coordinator.

For fields, the following attributes are supported:

- #raw("name") - Name of the column in the Trino table.
- #raw("type") - Trino data type of column.
- #raw("mapping") - slash-separated list of field names to select a field from the Protobuf schema. If field specified in #raw("mapping") does not exist in the original #raw("proto") file then a read operation returns NULL.

The following table lists the supported Trino types which can be used in #raw("type") for the equivalent Protobuf field types:

#list-table((
  ([Trino data type], [Allowed Protobuf data type],),
  ([#raw("BOOLEAN")], [#raw("bool")],),
  ([#raw("INTEGER")], [#raw("int32"), #raw("uint32"), #raw("sint32"), #raw("fixed32"), #raw("sfixed32")],),
  ([#raw("BIGINT")], [#raw("int64"), #raw("uint64"), #raw("sint64"), #raw("fixed64"), #raw("sfixed64")],),
  ([#raw("DOUBLE")], [#raw("double")],),
  ([#raw("REAL")], [#raw("float")],),
  ([#raw("VARCHAR") \/ #raw("VARCHAR(x)")], [#raw("string")],),
  ([#raw("VARBINARY")], [#raw("bytes")],),
  ([#raw("ROW")], [#raw("Message")],),
  ([#raw("ARRAY")], [Protobuf type with #raw("repeated") field],),
  ([#raw("MAP")], [#raw("Map")],),
  ([#raw("TIMESTAMP")], [#raw("Timestamp"), predefined in #raw("timestamp.proto")],),
  ([#raw("JSON")], [#raw("oneof") \(Confluent table supplier only\), #raw("Any")],)
), header-rows: 1)

===== any

Message types with an #link("https://protobuf.dev/programming-guides/proto3/#any")[Any] field contain an arbitrary serialized message as bytes and a type URL to resolve that message's type with a scheme of #raw("file://"), #raw("http://"), or #raw("https://"). The connector reads the contents of the URL to create the type descriptor for the #raw("Any") message and convert the message to JSON. This behavior is enabled by setting #raw("kafka.protobuf-any-support-enabled") to #raw("true").

The descriptors for each distinct URL are cached for performance reasons and any modifications made to the type returned by the URL requires a restart of Trino.

For example, given the following Protobuf schema which defines #raw("MyMessage") with three columns:

#code-block("text", "syntax = \"proto3\";

message MyMessage {
  string stringColumn = 1;
  uint32 integerColumn = 2;
  uint64 longColumn = 3;
}")

And a separate schema which uses an #raw("Any") type which is a packed message of the above type and a valid URL:

#code-block("text", "syntax = \"proto3\";

import \"google/protobuf/any.proto\";

message schema {
    google.protobuf.Any any_message = 1;
}")

The corresponding Trino column is named #raw("any_message") of type #raw("JSON") containing a JSON-serialized representation of the Protobuf message:

#code-block("text", "{
  \"@type\":\"file:///path/to/schemas/MyMessage\",
  \"longColumn\":\"493857959588286460\",
  \"numberColumn\":\"ONE\",
  \"stringColumn\":\"Trino\"
}")

===== Protobuf schema evolution

The Protobuf decoder supports the schema evolution feature with backward compatibility. With backward compatibility, a newer schema can be used to read Protobuf data created with an older schema. Any change in the Protobuf schema #emph[must] also be reflected in the topic definition file.

The schema evolution behavior is as follows:

- Column added in new schema: Data created with an older schema produces a #emph[default] value when the table is using the new schema.
- Column removed in new schema: Data created with an older schema no longer outputs the data from the column that was removed.
- Column is renamed in the new schema: This is equivalent to removing the column and adding a new one, and data created with an older schema produces a #emph[default] value when table is using the new schema.
- Changing type of column in the new schema: If the type coercion is supported by Protobuf, then the conversion happens. An error is thrown for incompatible types.

===== Protobuf limitations

- Protobuf Timestamp has a nanosecond precision but Trino supports decoding\/encoding at microsecond precision.

#anchor("ref-kafka-sql-support")

== SQL support

The connector provides read and write access to data and metadata in Trino tables populated by Kafka topics. See #link(label("ref-kafka-row-decoding"))[kafka-row-decoding] for more information.

In addition to the #link(label("ref-sql-globally-available"))[globally available] and #link(label("ref-sql-read-operations"))[read operation] statements, the connector supports the following features:

- #link(label("doc-sql-insert"))[INSERT], encoded to a specified data format. See also #link(label("ref-kafka-sql-inserts"))[kafka-sql-inserts].
