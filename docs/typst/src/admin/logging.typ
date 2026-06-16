#import "/lib/trino-docs.typ": *

#anchor("doc-admin-logging")
= Logging

Trino include numerous features to better understand and monitor a running system, such as #link(label("doc-admin-opentelemetry"))[Observability with OpenTelemetry] or #link(label("doc-admin-jmx"))[Monitoring with JMX]. Logging and configuring logging is one important aspect for operating and troubleshooting Trino.

#anchor("ref-logging-configuration")

== Configuration

Trino application logging is optional and configured in the #raw("log.properties") file in your Trino installation #raw("etc") configuration directory as set by the #link(label("ref-running-trino"))[launcher].

Use it to add specific loggers and configure the minimum log levels. Every logger has a name, which is typically the fully qualified name of the class that uses the logger. Loggers have a hierarchy based on the dots in the name, like Java packages. The four log levels are #raw("DEBUG"), #raw("INFO"), #raw("WARN") and #raw("ERROR"), sorted by decreasing verbosity.

For example, consider the following log levels file:

#code-block("properties", "io.trino=WARN
io.trino.plugin.iceberg=DEBUG
io.trino.parquet=DEBUG")

The preceding configuration sets the changes the level for all loggers in the #raw("io.trino") namespace to #raw("WARN") as an update from the default #raw("INFO") to make logging less verbose. The example also increases logging verbosity for the Iceberg connector using the #raw("io.trino.plugin.iceberg") namespace, and the Parquet file reader and writer support located in the #raw("io.trino.parquet") namespace to #raw("DEBUG") for troubleshooting purposes.

Additional loggers can include other package namespaces from libraries and dependencies embedded within Trino or part of the Java runtime, for example:

- #raw("io.airlift") for the #link("https://github.com/airlift/airlift")[Airlift] application framework used by Trino.
- #raw("org.eclipse.jetty") for the #link("https://jetty.org/")[Eclipse Jetty] web server used by Trino.
- #raw("org.postgresql") for the #link("https://github.com/pgjdbc")[PostgresSQL JDBC driver] used by the PostgreSQL connector.
- #raw("javax.net.ssl") for TLS from the Java runtime.
- #raw("java.io") for I\/O operations.

There are numerous additional properties available to customize logging in #link(label("ref-config-properties"))[Deploying Trino], with details documented in #link(label("doc-admin-properties-logging"))[Logging properties] and in following example sections.

== Log output

By default, logging output is file-based with rotated files in #raw("var/log"):

- #raw("launcher.log") for logging out put from the application startup from the #link(label("ref-running-trino"))[launcher]. Only used if the launcher starts Trino in the background, and therefore not used in the Trino container.
- #raw("http-request.log") for HTTP request logs, mostly from the #link(label("doc-client-client-protocol"))[client protocol] and the #link(label("doc-admin-web-interface"))[Web UI].
- #raw("server.log") for the main application log of Trino, including logging from all plugins.

== JSON and TCP channel logging

Trino supports logging to JSON-formatted output files with the configuration #raw("log.format=json"). Optionally you can set #raw("node.annotations-file") as path to a properties file such as the following example:

#code-block("properties", "host_ip=1.2.3.4
service_name=trino
node_name=${ENV:MY_NODE_NAME}
pod_name=${ENV:MY_POD_NAME}
pod_namespace=${ENV:MY_POD_NAMESPACE}")

The annotations file supports environment variable substitution, so that the above example attaches the name of the Trino node as #raw("pod_name") and other information to every log line. When running Trino on Kubernetes, you have access to #link("https://kubernetes.io/docs/tasks/inject-data-application/environment-variable-expose-pod-information/")[a lot of information to use in the log].

TCP logging allows you to log to a TCP socket instead of a file with the configuration #raw("log.path=tcp://<server_ip>:<server_port>"). The endpoint must be available at the URL configured with #raw("server_ip") and #raw("server_port") and is assumed to be stable.

You can use an application such as #link("https://fluentbit.io/")[fluentbit] as a consumer for these JSON-formatted logs.

Example fluentbit configuration file #raw("config.yaml"):

#code-block("yaml", "pipeline:
  inputs:
  - name: tcp
    tag: trino
    listen: 0.0.0.0
    port: 5170
    buffer_size: 2048
    format: json
  outputs:
  - name: stdout
    match: '*'")

Start the application with the command:

#code-block("shell", "fluent-bit -c config.yaml")

Use the following Trino properties configuration:

#code-block("properties", "log.path=tcp://localhost:5170
log.format=json
node.annotation-file=etc/annotations.properties")

File #raw("etc/annotation.properties"):

#code-block("properties", "host_ip=1.2.3.4
service_name=trino
pod_name=${ENV:HOSTNAME}")

As a result, Trino logs appear as structured JSON log lines in fluentbit in the user interface, and can also be #link("https://docs.fluentbit.io/manual/pipeline/outputs")[forwarded into a configured logging system].
