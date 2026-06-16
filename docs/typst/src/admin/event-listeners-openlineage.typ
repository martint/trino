#import "/lib/trino-docs.typ": *

#anchor("doc-admin-event-listeners-openlineage")
= OpenLineage event listener

The OpenLineage event listener plugin allows streaming of lineage information, encoded in JSON format aligned with OpenLineage specification, to an external, OpenLineage compatible API, by POSTing them to a specified URI.

== Rationale

This event listener is aiming to capture every query that creates or modifies Trino tables and transform it into lineage information. Linage can be understood as relationship\/flow between data\/tables. OpenLineage is a widely used open-source standard for capturing lineage information from variety of system including \(but not limited to\) Spark, Airflow, Flink.

#list-table((
  ([Trino], [OpenLineage],),
  ([#raw("{UUIDv7(Query.createTime, hash(Query.Id))}")], [Run ID],),
  ([#raw("{queryCreatedEvent.getCreateTime()} or {queryCompletedEvent.getEndTime()} ")], [Run Event Time],),
  ([Query Id], [Job Facet Name \(default, can be overriden\)],),
  ([#raw("trino:// + {openlineage-event-listener.trino.uri.getHost()} + \":\" + {openlineage-event-listener.trino.uri.getPort()}")], [Job Facet Namespace \(default, can be overridden\)],),
  ([#raw("{schema}.{table}")], [Dataset Name],),
  ([#raw("trino:// + {openlineage-event-listener.trino.uri.getHost()} + \":\" + {openlineage-event-listener.trino.uri.getPort()}")], [Dataset Namespace],)
), header-rows: 1, title: "Trino Query attributes mapping to OpenLineage attributes")

#anchor("ref-trino-facets")

=== Available Trino Facets

==== Trino Metadata

Facet containing properties \(if present\):

- #raw("queryPlan")
- #raw("transactionId") - transaction id used for query processing

related to query based on which OpenLineage Run Event was generated.

Available in both #raw("Start") and #raw("Complete/Fail") OpenLineage events.

If you want to disable this facet, add #raw("trino_metadata") to #raw("openlineage-event-listener.disabled-facets").

==== Trino Query Context

Facet containing properties:

- #raw("serverVersion") - version of Trino server that was used to process the query
- #raw("environment") - inherited from #raw("node.environment") of #link(label("ref-node-properties"))[Deploying Trino]
- #raw("queryType") - one of query types configured via #raw("openlineage-event-listener.trino.include-query-types")

related to query based on which OpenLineage Run Event was generated.

Available in both #raw("Start") and #raw("Complete/Fail") OpenLineage events.

If you want to disable this facet, add #raw("trino_query_context") to #raw("openlineage-event-listener.disabled-facets").

==== Trino Query Statistics

Facet containing full contents of query statistics of completed. Available only in OpenLineage #raw("Complete/Fail") events.

If you want to disable this facet, add #raw("trino_query_statistics") to #raw("openlineage-event-listener.disabled-facets").

#anchor("ref-openlineage-event-listener-requirements")

== Requirements

You need to perform the following steps:

- Provide an HTTP\/S service that accepts POST events with a JSON body and is compatible with the OpenLineage API format.
- Configure #raw("openlineage-event-listener.transport.url") in the event listener properties file with the URI of the service
- Configure #raw("openlineage-event-listener.trino.uri") so proper OpenLineage job namespace is render within produced events. Needs to be proper uri with scheme, host and port \(otherwise plugin will fail to start\).
- Configure what events to send as detailed in #link(label("ref-openlineage-event-listener-configuration"))[OpenLineage event listener]

#anchor("ref-openlineage-event-listener-configuration")

== Configuration

To configure the OpenLineage event listener, create an event listener properties file in #raw("etc") named #raw("openlineage-event-listener.properties") with the following contents as an example of minimal required configuration:

#code-block("properties", "event-listener.name=openlineage
openlineage-event-listener.trino.uri=<Address of your Trino coordinator>")

Add #raw("etc/openlineage-event-listener.properties") to #raw("event-listener.config-files") in #link(label("ref-config-properties"))[Deploying Trino]:

#code-block("properties", "event-listener.config-files=etc/openlineage-event-listener.properties,...")

#list-table((
  ([Property name], [Description], [Default],),
  ([openlineage-event-listener.transport.type], [Type of transport to use when emitting lineage information. See #link(label("ref-supported-transport-types"))[OpenLineage event listener] for list of available options with descriptions.], [#raw("CONSOLE")],),
  ([openlineage-event-listener.trino.uri], [Required Trino URL with host and port. Used to render Job Namespace in OpenLineage.], [None.],),
  ([openlineage-event-listener.trino.include-query-types], [Which types of queries should be taken into account when emitting lineage information. List of values split by comma. Each value must be matching #raw("io.trino.spi.resourcegroups.QueryType") enum. Query types not included here are filtered out.], [#raw("DELETE,INSERT,MERGE,UPDATE,ALTER_TABLE_EXECUTE")],),
  ([openlineage-event-listener.disabled-facets], [Which #link(label("ref-trino-facets"))[OpenLineage event listener] should be not included in final OpenLineage event. Allowed values: #raw("trino_metadata"), #raw("trino_query_context"), #raw("trino_query_statistics").], [None.],),
  ([openlineage-event-listener.namespace], [Custom namespace to be used for Job #raw("namespace") attribute. If blank will default to Dataset Namespace.], [None.],),
  ([openlineage-event-listener.job.name-format], [Custom namespace to use for the job #raw("name") attribute. Use any string with, with optional substitution variables: #raw("$QUERY_ID"), #raw("$USER"), #raw("$SOURCE"), #raw("$CLIENT_IP"). For example: #raw("As $USER from $CLIENT_IP via $SOURCE").], [#raw("$QUERY_ID").],)
), header-rows: 1, title: "OpenLineage event listener configuration properties")

#anchor("ref-supported-transport-types")

=== Supported Transport Types

- #raw("CONSOLE") - sends OpenLineage JSON event to Trino coordinator standard output.
- #raw("HTTP") - sends OpenLineage JSON event to OpenLineage compatible HTTP endpoint.

#list-table((
  ([Property name], [Description], [Default],),
  ([openlineage-event-listener.transport.url], [URL of OpenLineage . Required if #raw("HTTP") transport is configured.], [None.],),
  ([openlineage-event-listener.transport.endpoint], [Custom path for OpenLineage compatible endpoint. If configured, there cannot be any custom path within #raw("openlineage-event-listener.transport.url").], [#raw("/api/v1").],),
  ([openlineage-event-listener.transport.api-key], [API key \(string value\) used to authenticate with the service. at #raw("openlineage-event-listener.transport.url").], [None.],),
  ([openlineage-event-listener.transport.timeout], [#link(label("ref-prop-type-duration"))[Timeout] when making HTTP Requests.], [#raw("5000ms")],),
  ([openlineage-event-listener.transport.headers], [List of custom HTTP headers to be sent along with the events. See #link(label("ref-openlineage-event-listener-custom-headers"))[OpenLineage event listener] for more details.], [Empty],),
  ([openlineage-event-listener.transport.url-params], [List of custom url params to be added to final HTTP Request. See #link(label("ref-openlineage-event-listener-custom-url-params"))[OpenLineage event listener] for more details.], [Empty],),
  ([openlineage-event-listener.transport.compression], [Compression codec used for reducing size of HTTP body. Allowed values: #raw("none"), #raw("gzip").], [#raw("none")],)
), header-rows: 1, title: "OpenLineage `HTTP` Transport Configuration properties")

#anchor("ref-openlineage-event-listener-custom-headers")

=== Custom HTTP headers

Providing custom HTTP headers is a useful mechanism for sending metadata along with event messages.

Providing headers follows the pattern of #raw("key:value") pairs separated by commas:

#code-block("text", "openlineage-event-listener.transport.headers=\"Header-Name-1:header value 1,Header-Value-2:header value 2,...\"")

If you need to use a comma\(#raw(",")\) or colon\(#raw(":")\) in a header name or value, escape it using a backslash \(#raw("\\")\).

Keep in mind that these are static, so they can not carry information taken from the event itself.

#anchor("ref-openlineage-event-listener-custom-url-params")

=== Custom URL Params

Providing additional URL Params included in final HTTP Request.

Providing url params follows the pattern of #raw("key:value") pairs separated by commas:

#code-block("text", "openlineage-event-listener.transport.url-params=\"Param-Name-1:param value 1,Param-Value-2:param value 2,...\"")

Keep in mind that these are static, so they can not carry information taken from the event itself.
