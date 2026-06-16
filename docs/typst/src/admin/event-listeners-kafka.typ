#import "/lib/trino-docs.typ": *

#anchor("doc-admin-event-listeners-kafka")
= Kafka event listener

The Kafka event listener plugin allows streaming of query events to an external Kafka-compatible system. The query history in the Kafka topic can then be accessed directly in Kafka, via Trino in a catalog using the #link(label("doc-connector-kafka"))[Kafka connector] or many downstream systems processing and storing the data.

== Rationale

This event listener is a first step to store the query history of your Trino cluster. The query events can provide CPU and memory usage metrics, what data is being accessed with resolution down to specific columns, and metadata about the query processing.

Running the capture system separate from Trino reduces the performance impact and avoids downtime for non-client-facing changes.

#anchor("ref-kafka-event-listener-requirements")

== Requirements

You need to perform the following steps:

- Provide a Kafka service that is network-accessible to Trino.
- Configure #raw("kafka-event-listener.broker-endpoints") in the event listener properties file with the URI of the service
- Configure what events to send as detailed in #link(label("ref-kafka-event-listener-configuration"))[Kafka event listener]

#anchor("ref-kafka-event-listener-configuration")

== Configuration

To configure the Kafka event listener, create an event listener properties file in #raw("etc") named #raw("kafka-event-listener.properties") with the following contents as an example of a minimal required configuration:

#code-block("properties", "event-listener.name=kafka
kafka-event-listener.broker-endpoints=kafka.example.com:9093
kafka-event-listener.created-event.topic=query_create
kafka-event-listener.completed-event.topic=query_complete
kafka-event-listener.client-id=trino-example")

Add #raw("etc/kafka-event-listener.properties") to #raw("event-listener.config-files") in #link(label("ref-config-properties"))[Deploying Trino]:

#code-block("properties", "event-listener.config-files=etc/kafka-event-listener.properties,...")

In some cases, such as when using specialized authentication methods, it is necessary to specify additional Kafka client properties in order to access your Kafka cluster. To do so, add the #raw("kafka-event-listener.config.resources") property to reference your Kafka config files. Note that configs can be overwritten if defined explicitly in #raw("kafka-event-listener.properties"):

#code-block("properties", "event-listener.name=kafka
kafka-event-listener.broker-endpoints=kafka.example.com:9093
kafka-event-listener.created-event.topic=query_create
kafka-event-listener.completed-event.topic=query_complete
kafka-event-listener.client-id=trino-example
kafka-event-listener.config.resources=/etc/kafka-configuration.properties")

The contents of #raw("/etc/kafka-configuration.properties") can for example be:

#code-block("properties", "sasl.mechanism=SCRAM-SHA-512
security.protocol=SASL_SSL
sasl.jaas.config=org.apache.kafka.common.security.scram.ScramLoginModule required \\
  username=\"kafkaclient1\" \\
  password=\"kafkaclient1-secret\";")

Use the following properties for further configuration.

#list-table((
  ([Property name], [Description], [Default],),
  ([#raw("kafka-event-listener.broker-endpoints")], [Comma-separated list of Kafka broker endpoints with URL and port, for example #raw("kafka-1.example.com:9093,kafka-2.example.com:9093").], [],),
  ([#raw("kafka-event-listener.anonymization.enabled")], [#link(label("ref-prop-type-boolean"))[Boolean] switch to enable anonymization of the event data in Trino before it is sent to Kafka.], [#raw("false")],),
  ([#raw("kafka-event-listener.client-id")], [#link(label("ref-prop-type-string"))[String identifier] for the Trino cluster to allow distinction in Kafka, if multiple Trino clusters send events to the same Kafka system.], [],),
  ([#raw("kafka-event-listener.max-request-size")], [#link(label("ref-prop-type-data-size"))[Size value] that specifies the maximum request size the Kafka producer can send; messages exceeding this size will fail.], [#raw("5MB")],),
  ([#raw("kafka-event-listener.batch-size")], [#link(label("ref-prop-type-data-size"))[Size value] that specifies the size to batch before sending records to Kafka.], [#raw("16kB")],),
  ([#raw("kafka-event-listener.publish-created-event")], [#link(label("ref-prop-type-boolean"))[Boolean] switch to control publishing of query creation events.], [#raw("true")],),
  ([#raw("kafka-event-listener.created-event.topic")], [Name of the Kafka topic for the query creation event data.], [],),
  ([#raw("kafka-event-listener.publish-completed-event")], [#link(label("ref-prop-type-boolean"))[Boolean] switch to control publishing of query completion events.], [#raw("true")],),
  ([#raw("kafka-event-listener.completed-event.topic")], [Name of the Kafka topic for the query completion event data.], [],),
  ([#raw("kafka-event-listener.excluded-fields")], [Comma-separated list of field names to exclude from the Kafka event, for example #raw("payload,user"). Values are replaced with null.], [],),
  ([#raw("kafka-event-listener.request-timeout")], [Timeout #link(label("ref-prop-type-duration"))[duration] to complete a Kafka request. Minimum value of #raw("1ms").], [#raw("10s")],),
  ([#raw("kafka-event-listener.terminate-on-initialization-failure")], [Kafka publisher initialization can fail due to network issues reaching the Kafka brokers. This #link(label("ref-prop-type-boolean"))[boolean] switch controls whether to throw an exception in such cases.], [#raw("true")],),
  ([#raw("kafka-event-listener.env-var-prefix")], [When set, Kafka events are sent with additional metadata populated from environment variables. For example, if the value is #raw("TRINO_INSIGHTS_") and an environment variable on the cluster is set at #raw("TRINO_INSIGHTS_CLUSTER_ID=foo"), then the Kafka payload metadata contains #raw("CLUSTER_ID=foo").], [],),
  ([#raw("kafka-event-listener.config.resources")], [A comma-separated list of Kafka client configuration files. These files must exist on the machines running Trino. Only specify this if absolutely necessary to access Kafka. Example: #raw("/etc/kafka-configuration.properties")], [],)
), header-rows: 1, title: "Kafka event listener configuration properties")
