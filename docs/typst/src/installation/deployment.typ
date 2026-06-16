#import "/lib/trino-docs.typ": *

#anchor("doc-installation-deployment")
= Deploying Trino

#anchor("ref-requirements")

== Requirements

#anchor("ref-requirements-linux")

=== Linux operating system

- 64-bit required
- newer release preferred, especially when running on containers
- adequate ulimits for the user that runs the Trino process. These limits may depend on the specific Linux distribution you are using. The number of open file descriptors needed for a particular Trino instance scales as roughly the number of machines in the cluster, times some factor depending on the workload. The #raw("nofile") limit sets the maximum number of file descriptors that a process can have, while the #raw("nproc") limit restricts the number of processes, and therefore threads on the JVM, a user can create. We recommend setting limits to the following values at a minimum. Typically, this configuration is located in #raw("/etc/security/limits.conf"):
  
  #code-block("text", "trino soft nofile 131072
  trino hard nofile 131072
  trino soft nproc 128000
  trino hard nproc 128000")

#anchor("ref-requirements-java")

=== Java runtime environment

Trino requires a 64-bit version of Java 25, with a minimum required version of 25.0.1 and a recommendation to use the latest patch version. Earlier versions such as Java 8, Java 11, Java 17, Java 21 or Java 24 do not work. Newer versions such as Java 26 are not supported -- they may work, but are not tested.

We recommend using the Eclipse Temurin OpenJDK distribution from #link("https://adoptium.net/")[Adoptium] as the JDK for Trino, as Trino is tested against that distribution. Eclipse Temurin is also the JDK used by the #link("https://hub.docker.com/r/trinodb/trino")[Trino Docker image].

== Installing Trino

Download the Trino server tarball, #raw("server"), and unpack it. The tarball contains a single top-level directory, #raw("trino-server-latest"), which we call the #emph[installation] directory.

The default tarball contains all plugins and must be configured for use. The minimal #raw("server-core") tarball, #raw("server-core"), contains a minimal set of essential plugins, and it is therefore mostly suitable as a base for custom tarball creation.

The #link("https://github.com/trinodb/trino-packages")[trino-packages project] includes a module to create a fully configured tarball with an example configuration. The custom tarball is ready to use and can be further configured and adjusted to your needs.

Trino needs a #emph[data] directory for storing logs, etc. By default, an installation from the tarball uses the same location for the installation and data directories.

We recommend creating a data directory outside the installation directory, which allows it to be easily preserved when upgrading Trino. This directory path must be configured with the #link(label("ref-node-properties"))[Deploying Trino].

The user that runs the Trino process must have full read access to the installation directory, and read and write access to the data directory.

== Configuring Trino

Create an #raw("etc") directory inside the installation directory. This holds the following configuration:

- Node Properties: environmental configuration specific to each node
- JVM Config: command line options for the Java Virtual Machine
- Config Properties: configuration for the Trino server. See the #link(label("doc-admin-properties"))[Properties reference] for available configuration properties.
- Catalog Properties: configuration for #link(label("doc-connector"))[Connectors] \(data sources\). The available catalog configuration properties for a connector are described in the respective connector documentation.

#anchor("ref-node-properties")

=== Node properties

The node properties file, #raw("etc/node.properties"), contains configuration specific to each node. A #emph[node] is a single installed instance of Trino on a machine. This file is typically created by the deployment system when Trino is first installed. The following is a minimal #raw("etc/node.properties"):

#code-block("text", "node.environment=production
node.id=ffffffff-ffff-ffff-ffff-ffffffffffff
node.data-dir=/var/trino/data")

The above properties are described below:

- #raw("node.environment"): The name of the environment. All Trino nodes in a cluster must have the same environment name. The name must start with a lowercase alphanumeric character and only contain lowercase alphanumeric or underscore \(#raw("_")\) characters.
- #raw("node.id"): The unique identifier for this installation of Trino. This must be unique for every node. This identifier should remain consistent across reboots or upgrades of Trino. If running multiple installations of Trino on a single machine \(i.e. multiple nodes on the same machine\), each installation must have a unique identifier. The identifier must start with an alphanumeric character and only contain alphanumeric, #raw("-"), or #raw("_") characters.
- #raw("node.data-dir"): The location \(filesystem path\) of the data directory. Trino stores logs and other data here.

#anchor("ref-jvm-config")

=== JVM config

The JVM config file, #raw("etc/jvm.config"), contains a list of command line options used for launching the Java Virtual Machine. The format of the file is a list of options, one per line. These options are not interpreted by the shell, so options containing spaces or other special characters should not be quoted.

The following provides a good starting point for creating #raw("etc/jvm.config"):

#code-block("text", "-server
-Xmx16G
-XX:InitialRAMPercentage=80
-XX:MaxRAMPercentage=80
-XX:G1HeapRegionSize=32M
-XX:+ExplicitGCInvokesConcurrent
-XX:+ExitOnOutOfMemoryError
-XX:+HeapDumpOnOutOfMemoryError
-XX:-OmitStackTraceInFastThrow
-XX:ReservedCodeCacheSize=512M
-XX:PerMethodRecompilationCutoff=10000
-XX:PerBytecodeRecompilationCutoff=10000
-Djdk.attach.allowAttachSelf=true
-Djdk.nio.maxCachedBufferSize=2000000
--add-modules=jdk.incubator.vector")

You must adjust the value for the memory used by Trino, specified with #raw("-Xmx") to the available memory on your nodes. Typically, values representing 70 to 85 percent of the total available memory is recommended. For example, if all workers and the coordinator use nodes with 64GB of RAM, you can use #raw("-Xmx54G"). Trino uses most of the allocated memory for processing, with a small percentage used by JVM-internal processes such as garbage collection.

The rest of the available node memory must be sufficient for the operating system and other running services, as well as off-heap memory used for native code initiated the JVM process.

On larger nodes, the percentage value can be lower. Allocation of all memory  to the JVM or using swap space is not supported, and disabling swap space on the operating system level is recommended.

Large memory allocation beyond 32GB is recommended for production clusters.

Because an #raw("OutOfMemoryError") typically leaves the JVM in an inconsistent state, we write a heap dump, for debugging, and forcibly terminate the process when this occurs.

#anchor("ref-tmp-directory")

==== Temporary directory

The temporary directory used by the JVM must allow execution of code, because Trino accesses and uses shared library binaries for purposes such as #link(label("ref-file-compression"))[General properties].

Specifically, the partition mount and directory must not have the #raw("noexec") flag set. The default #raw("/tmp") directory is mounted with this flag in some operating system installations, which prevents Trino from starting. You can work around this by overriding the temporary directory by adding #raw("-Djava.io.tmpdir=/path/to/other/tmpdir") to the list of JVM options.

#anchor("ref-config-properties")

=== Config properties

The config properties file, #raw("etc/config.properties"), contains the configuration for the Trino server. Every Trino server can function as both a coordinator and a worker. A cluster is required to include one coordinator, and dedicating a machine to only perform coordination work provides the best performance on larger clusters. Scaling and parallelization is achieved by using many workers.

The following is a minimal configuration for the coordinator:

#code-block("text", "coordinator=true
node-scheduler.include-coordinator=false
http-server.http.port=8080
discovery.uri=http://example.net:8080")

And this is a minimal configuration for the workers:

#code-block("text", "coordinator=false
http-server.http.port=8080
discovery.uri=http://example.net:8080")

Alternatively, if you are setting up a single machine for testing, that functions as both a coordinator and worker, use this configuration:

#code-block("text", "coordinator=true
node-scheduler.include-coordinator=true
http-server.http.port=8080
discovery.uri=http://example.net:8080")

These properties require some explanation:

- #raw("coordinator"): Allow this Trino instance to function as a coordinator, so to accept queries from clients and manage query execution.
- #raw("node-scheduler.include-coordinator"): Allow scheduling work on the coordinator. For larger clusters, processing work on the coordinator can impact query performance because the machine's resources are not available for the critical task of scheduling, managing and monitoring query execution.
- #raw("http-server.http.port"): Specifies the port for the #link(label("doc-admin-properties-http-server"))[HTTP server]. Trino uses HTTP for all communication, internal and external.
- #raw("discovery.uri"): The Trino coordinator has a discovery service that is used by all the nodes to find each other. Every Trino instance registers itself with the discovery service on startup and continuously heartbeats to keep its registration active. The discovery service shares the HTTP server with Trino and thus uses the same port. Replace #raw("example.net:8080") to match the host and port of the Trino coordinator. If you have disabled HTTP on the coordinator, the URI scheme must be #raw("https"), not #raw("http").

The above configuration properties are a #emph[minimal set] to help you get started. All additional configuration is optional and varies widely based on the specific cluster and supported use cases. The #link(label("doc-admin"))[Administration] and #link(label("doc-security"))[Security] sections contain documentation for many aspects, including #link(label("doc-admin-resource-groups"))[Resource groups] for configuring queuing policies and #link(label("doc-admin-fault-tolerant-execution"))[Fault-tolerant execution].

The #link(label("doc-admin-properties"))[Properties reference] provides a comprehensive list of the supported properties for topics such as #link(label("doc-admin-properties-general"))[General properties], #link(label("doc-admin-properties-resource-management"))[Resource management properties], #link(label("doc-admin-properties-query-management"))[Query management properties], #link(label("doc-admin-properties-web-interface"))[Web UI properties], and others.

Further configuration can include #link(label("doc-admin-logging"))[Logging], #link(label("doc-admin-opentelemetry"))[Observability with OpenTelemetry], #link(label("doc-admin-jmx"))[Monitoring with JMX], #link(label("doc-admin-openmetrics"))[Trino metrics with OpenMetrics], and other functionality described in the #link(label("doc-admin"))[Administration] section.

#anchor("ref-catalog-properties")

=== Catalog properties

Trino accesses data in a #link(label("ref-trino-concept-data-source"))[data source] with a #link(label("ref-trino-concept-connector"))[connector], which is configured in a #link(label("ref-trino-concept-catalog"))[catalog]. The connector provides all the schemas and tables inside the catalog.

For example, the Hive connector maps each Hive database to a schema. If the Hive connector is configured in the #raw("example") catalog, and Hive contains a table #raw("clicks") in the database #raw("web"), that table can be accessed in Trino as #raw("example.web.clicks").

Catalogs are registered by creating a catalog properties file in the #raw("etc/catalog") directory. For example, create #raw("etc/catalog/jmx.properties") with the following contents to mount the #raw("jmx") connector as the #raw("jmx") catalog:

#code-block("text", "connector.name=jmx")

See #link(label("doc-connector"))[Connectors] for more information about configuring catalogs.

#anchor("ref-running-trino")

== Running Trino

The installation provides a #raw("bin/launcher") script that can be used manually or as a daemon startup script. It accepts the following commands:

#list-table((
  ([Command], [Action],),
  ([#raw("run")], [Starts the server in the foreground and leaves it running. To shut down the server, use Ctrl+C in this terminal or the #raw("stop") command from another terminal.],),
  ([#raw("start")], [Starts the server as a daemon and returns its process ID.],),
  ([#raw("stop")], [Shuts down a server started with either #raw("start") or #raw("run"). Sends the SIGTERM signal.],),
  ([#raw("restart")], [Stops then restarts a running server, or starts a stopped server, assigning a new process ID.],),
  ([#raw("kill")], [Shuts down a possibly hung server by sending the SIGKILL signal.],),
  ([#raw("status")], [Prints a status line, either #emph[Stopped pid] or #emph[Running as pid].],)
), header-rows: 1, title: "`launcher` commands")

A number of additional options allow you to specify configuration file and directory locations, as well as Java options. Run the launcher with #raw("--help") to see the supported commands, command line options, and default values.

The #raw("-v") or #raw("--verbose") option for each command prepends the server's current settings before the command's usual output.

Trino can be started as a daemon by running the following:

#code-block("text", "bin/launcher start")

Use the status command with the verbose option for the pid and a list of configuration settings:

#code-block("text", "bin/launcher -v status")

Alternatively, it can be run in the foreground, with the logs and other output written to stdout\/stderr. Both streams should be captured if using a supervision system like daemontools:

#code-block("text", "bin/launcher run")

The launcher configures default values for the configuration directory #raw("etc"), configuration files in #raw("etc"), the data directory identical to the installation directory, the pid file as #raw("var/run/launcher.pid") and log files in the #raw("var/log") directory.

You can change these values to adjust your Trino usage to any requirements, such as using a directory outside the installation directory, specific mount points or locations, and even using other file names. For example, the #link("https://github.com/trinodb/trino-packages")[Trino RPM] adjusts the used directories to better follow the Linux Filesystem Hierarchy Standard \(FHS\).

After starting Trino, you can find log files in the #raw("log") directory inside the data directory #raw("var"):

- #raw("launcher.log"): This log is created by the launcher and is connected to the stdout and stderr streams of the server. It contains a few log messages that occur while the server logging is being initialized, and any errors or diagnostics produced by the JVM.
- #raw("server.log"): This is the main log file used by Trino. It typically contains the relevant information if the server fails during initialization. It is automatically rotated and compressed.
- #raw("http-request.log"): This is the HTTP request log which contains every HTTP request received by the server. It is automatically rotated and compressed.
