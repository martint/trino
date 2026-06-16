#import "/lib/trino-docs.typ": *

#anchor("doc-admin")
= Administration

The following documents cover a number of different aspect of configuring, running, and managing Trino clusters.

- #link(label("doc-admin-web-interface"))[Web UI]
- #link(label("doc-admin-preview-web-interface"))[Preview Web UI]
- #link(label("doc-admin-logging"))[Logging]
- #link(label("doc-admin-tuning"))[Tuning Trino]
- #link(label("doc-admin-jmx"))[Monitoring with JMX]
- #link(label("doc-admin-opentelemetry"))[Observability with OpenTelemetry]
- #link(label("doc-admin-openmetrics"))[Trino metrics with OpenMetrics]
- #link(label("doc-admin-properties"))[Properties reference]
  - #link(label("doc-admin-properties-general"))[General properties]
  - #link(label("doc-admin-properties-client-protocol"))[Client protocol properties]
  - #link(label("doc-admin-properties-http-server"))[HTTP server properties]
  - #link(label("doc-admin-properties-resource-management"))[Resource management properties]
  - #link(label("doc-admin-properties-query-management"))[Query management properties]
  - #link(label("doc-admin-properties-catalog"))[Catalog management properties]
  - #link(label("doc-admin-properties-sql-environment"))[SQL environment properties]
  - #link(label("doc-admin-properties-spilling"))[Spilling properties]
  - #link(label("doc-admin-properties-exchange"))[Exchange properties]
  - #link(label("doc-admin-properties-task"))[Task properties]
  - #link(label("doc-admin-properties-write-partitioning"))[Write partitioning properties]
  - #link(label("doc-admin-properties-writer-scaling"))[Writer scaling properties]
  - #link(label("doc-admin-properties-node-scheduler"))[Node scheduler properties]
  - #link(label("doc-admin-properties-optimizer"))[Optimizer properties]
  - #link(label("doc-admin-properties-logging"))[Logging properties]
  - #link(label("doc-admin-properties-web-interface"))[Web UI properties]
  - #link(label("doc-admin-properties-regexp-function"))[Regular expression function properties]
  - #link(label("doc-admin-properties-http-client"))[HTTP client properties]
- #link(label("doc-admin-spill"))[Spill to disk]
- #link(label("doc-admin-resource-groups"))[Resource groups]
- #link(label("doc-admin-session-property-managers"))[Session property managers]
- #link(label("doc-admin-dist-sort"))[Distributed sort]
- #link(label("doc-admin-dynamic-filtering"))[Dynamic filtering]
- #link(label("doc-admin-graceful-shutdown"))[Graceful shutdown]
- #link(label("doc-admin-fault-tolerant-execution"))[Fault-tolerant execution]

Details about connecting #link(label("ref-trino-concept-data-source"))[data sources] as #link(label("ref-trino-concept-catalog"))[catalogs] are available in the #link(label("doc-connector"))[connector documentation].

#anchor("ref-admin-event-listeners")

== Event listeners

Event listeners are plugins that allow streaming of query events, such as query started or query finished, to an external system.

Using an event listener you can process and store the query events in a separate system for long periods of time. Some of these external systems can be queried with Trino for further analysis or reporting.

The following event listeners are available:

- #link(label("doc-admin-event-listeners-http"))[HTTP event listener]
- #link(label("doc-admin-event-listeners-kafka"))[Kafka event listener]
- #link(label("doc-admin-event-listeners-mysql"))[MySQL event listener]
- #link(label("doc-admin-event-listeners-openlineage"))[OpenLineage event listener]

Unrelated to event listeners, the coordinator stores information about recent queries in memory for usage by the #link(label("doc-admin-web-interface"))[Web UI] - see also #raw("query.max-history") and #raw("query.min-expire-age") in #link(label("doc-admin-properties-query-management"))[Query management properties].

== Properties reference

Many aspects for running Trino are #link(label("ref-config-properties"))[configured with properties]. The following pages provide an overview and details for specific topics.

- #link(label("doc-admin-properties"))[Properties reference]
  - #link(label("doc-admin-properties-general"))[General properties]
  - #link(label("doc-admin-properties-client-protocol"))[Client protocol properties]
  - #link(label("doc-admin-properties-http-server"))[HTTP server properties]
  - #link(label("doc-admin-properties-resource-management"))[Resource management properties]
  - #link(label("doc-admin-properties-query-management"))[Query management properties]
  - #link(label("doc-admin-properties-catalog"))[Catalog management properties]
  - #link(label("doc-admin-properties-sql-environment"))[SQL environment properties]
  - #link(label("doc-admin-properties-spilling"))[Spilling properties]
  - #link(label("doc-admin-properties-exchange"))[Exchange properties]
  - #link(label("doc-admin-properties-task"))[Task properties]
  - #link(label("doc-admin-properties-write-partitioning"))[Write partitioning properties]
  - #link(label("doc-admin-properties-writer-scaling"))[Writer scaling properties]
  - #link(label("doc-admin-properties-node-scheduler"))[Node scheduler properties]
  - #link(label("doc-admin-properties-optimizer"))[Optimizer properties]
  - #link(label("doc-admin-properties-logging"))[Logging properties]
  - #link(label("doc-admin-properties-web-interface"))[Web UI properties]
  - #link(label("doc-admin-properties-regexp-function"))[Regular expression function properties]
  - #link(label("doc-admin-properties-http-client"))[HTTP client properties]

- #link(label("doc-admin-properties"))[Properties reference overview]
- #link(label("doc-admin-properties-general"))[General properties]
- #link(label("doc-admin-properties-client-protocol"))[Client protocol properties]
- #link(label("doc-admin-properties-http-server"))[HTTP server properties]
- #link(label("doc-admin-properties-resource-management"))[Resource management properties]
- #link(label("doc-admin-properties-query-management"))[Query management properties]
- #link(label("doc-admin-properties-catalog"))[Catalog management properties]
- #link(label("doc-admin-properties-sql-environment"))[SQL environment properties]
- #link(label("doc-admin-properties-spilling"))[Spilling properties]
- #link(label("doc-admin-properties-exchange"))[Exchange properties]
- #link(label("doc-admin-properties-task"))[Task properties]
- #link(label("doc-admin-properties-write-partitioning"))[Write partitioning properties]
- #link(label("doc-admin-properties-writer-scaling"))[Writer scaling properties]
- #link(label("doc-admin-properties-node-scheduler"))[Node scheduler properties]
- #link(label("doc-admin-properties-optimizer"))[Optimizer properties]
- #link(label("doc-admin-properties-logging"))[Logging properties]
- #link(label("doc-admin-properties-web-interface"))[Web UI properties]
- #link(label("doc-admin-properties-regexp-function"))[Regular expression function properties]
- #link(label("doc-admin-properties-http-client"))[HTTP client properties]
