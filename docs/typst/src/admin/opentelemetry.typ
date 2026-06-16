#import "/lib/trino-docs.typ": *

#anchor("doc-admin-opentelemetry")
= Observability with OpenTelemetry

Trino exposes tracing information for observability of a running Trino deployment for the widely used #link("https://opentelemetry.io/")[OpenTelemetry] collection of APIs, SDKs, and tools. You can use OpenTelemetry to instrument, generate, collect, and export telemetry data such as metrics, logs, and traces to help you analyze application performance and behavior. More information about the observability and the concepts involved is available in the #link("https://opentelemetry.io/docs/concepts/")[OpenTelemetry documentation].

The integration of OpenTelemetry with Trino enables tracing Trino behavior and performance. You can use it to diagnose the overall application as well as processing of specific queries or other narrower aspects.

Trino emits trace information from the coordinator and the workers. Trace information includes the core system such as the query planner and the optimizer, and a wide range of connectors and other plugins.

Trino uses any supplied trace identifiers from client tools across the cluster. If none are supplied, trace identifiers are created for each query. The identifiers are propagated to data sources, metastores, and other connected components. As a result you can use this distributed tracing information to follow all the processing flow of a query from a client tool, through the coordinator and all workers to the data sources and other integrations.

If you want to receive traces from data sources and other integrations, these tools must also support OpenTelemetry tracing and use the supplied identifiers from Trino to propagate the context. Tracing must be enabled separately on these tools.

== Configuration

Use tracing with OpenTelemetry by enabling it and configuring the endpoint in the #link(label("ref-config-properties"))[config.properties file]:

#code-block("properties", "tracing.enabled=true
otel.exporter.endpoint=http://observe.example.com:4317")

Tracing is not enabled by default. The exporter endpoint must specify a URL that is accessible from the coordinator and all workers of the cluster. The preceding example uses a observability platform deployment available by HTTP at the host #raw("observe.example.com"), port #raw("4317").

Use the #raw("otel.exporter.protocol") property to configure the protocol for exporting traces. Defaults to the gRPC protocol with the #raw("grpc") value. Set the value to #raw("http/protobuf") for exporting traces using protocol buffers with HTTP transport.

=== Sampling

Use the #raw("otel.tracing.sampling-ratio") property to control the ratio of traces that are sampled and exported. The value must be between #raw("0") and #raw("1"), where #raw("1") means all traces are sampled and #raw("0") means no traces are sampled. The default value is #raw("1").

For example, to sample only 10% of traces:

#code-block("properties", "tracing.enabled=true
otel.exporter.endpoint=http://observe.example.com:4317
otel.tracing.sampling-ratio=0.1")

This is useful for high-traffic deployments where exporting all traces creates excessive load on the observability backend. The sampler uses a parent-based strategy with trace ID ratio-based sampling for root spans, which means that child spans inherit the sampling decision from their parent.

== Example use

The following steps provide a simple demo setup to run the open source observability platform #link("https://www.jaegertracing.io/")[Jaeger] and Trino locally in Docker containers.

Create a shared network for both servers called #raw("platform"):

#code-block("shell", "docker network create platform")

Start Jaeger in the background:

#code-block("shell", "docker run -d \\
  --name jaeger \\
  --network=platform \\
  --network-alias=jaeger \\
  -e COLLECTOR_OTLP_ENABLED=true \\
  -p 16686:16686 \\
  -p 4317:4317 \\
  jaegertracing/all-in-one:latest")

The preceding command adds Jaeger to the #raw("platform") network with the hostname #raw("jaeger"). It also maps the endpoint and Jaeger UI ports.

Create a #raw("config.properties") file that uses the default setup from the Trino container, and adds the tracing configuration with the #raw("jaeger") hostname:

#code-block("properties", "node-scheduler.include-coordinator=true
http-server.http.port=8080
discovery.uri=http://localhost:8080
tracing.enabled=true
otel.exporter.endpoint=http://jaeger:4317")

Start Trino in the background:

#code-block("shell", "docker run -d \\
  --name trino \\
  --network=platform \\
  -p 8080:8080 \\
  --mount type=bind,source=$PWD/config.properties,target=/etc/trino/config.properties \\
  trinodb/trino:latest")

The preceding command adds Trino to the #raw("platform") network. It also mounts the configuration file into the container so that tracing is enabled.

Now everything is running.

Install and run the #link(label("doc-client-cli"))[Trino CLI] or any other client application and submit a query such as #raw("SHOW CATALOGS;") or #raw("SELECT * FROM tpch.tiny.nation;").

Optionally, log into the #link(label("doc-admin-web-interface"))[Trino Web UI] at #link("http://localhost:8080")[http:\/\/localhost:8080] with a random username. Press the #strong[Finished] button and inspect the details for the completed queries.

Access the Jaeger UI at #link("http://localhost:16686/")[http:\/\/localhost:16686\/], select the service #raw("trino"), and press #strong[Find traces].

As a next step, run more queries and inspect more traces with the Jaeger UI.

Once you are done you can stop the containers:

#code-block("shell", "docker stop trino
docker stop jaeger")

You can start them again for further testing:

#code-block("shell", "docker start jaeger
docker start trino")

Use the following commands to completely remove the network and containers:

#code-block("shell", "docker rm trino
docker rm jaeger
docker network rm platform")
