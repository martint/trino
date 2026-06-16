#import "/lib/trino-docs.typ": *

#anchor("doc-installation-plugins")
= Plugins

Trino uses a plugin architecture to extend its capabilities and integrate with various data sources and other systems. Trino includes many plugins as part of the binary packages - specifically the #link(label("ref-glosstarball"))[tarball] and the #link(label("ref-glosscontainer"))[Docker image].

Plugins implement some of the following capabilities:

- #link(label("doc-connector"))[Connectors]
- #link(label("ref-security-authentication"))[Authentication types]
- #link(label("ref-security-access-control"))[Access control systems]
- #link(label("ref-admin-event-listeners"))[Event listeners]
- Additional types and global functions
- Block encodings
- Resource group configuration managers
- Session property configuration managers
- Exchange managers
- Spooling managers

All plugins are optional for your use of Trino because they support specific functionality that is potentially not needed for your use case. Plugins are located in the #raw("plugin") folder of your Trino installation and are loaded automatically during Trino startup.

#anchor("ref-plugins-download")

== Download

Typically, downloading a plugin is not necessary because Trino binaries include many plugins as part of the binary package. Every Trino release publishes each plugin as a ZIP archive to #link("https://github.com/trinodb/trino/releases")[GitHub]. Refer to #link(label("ref-plugins-list"))[Plugins] for details.

The specific name is derived from the Maven coordinates of each plugin as defined in the #raw("pom.xml") of the source code for the plugin.

For example, the PostgreSQL connector plugin can be found in the #raw("plugin/trino-postgresql") directory, and the #raw("pom.xml") file contains the following identifier section:

#code-block("xml", "<parent>
    <groupId>io.trino</groupId>
    <artifactId>trino-root</artifactId>
    <version>latest</version>
    <relativePath>../../pom.xml</relativePath>
</parent>

<artifactId>trino-postgresql</artifactId>
<packaging>trino-plugin</packaging>")

The coordinates translate into a path to the ZIP archive on GitHub releases. Use this URL to download the plugin.

For example, the PostgreSQL connector plugin can be downloaded at

#code-block(none, "https://github.com/trinodb/trino/releases/download/latest/trino-postgresql-latest.zip")

Availability of plugins from other projects and organizations varies widely, and may require building a plugin from source.

When downloading a plugin you must ensure to download a version of the plugin that is compatible with your Trino installation. Full compatibility is only guaranteed when using the same Trino version used for the plugin build and the deployment, and therefore using the same version is recommended. Use the documentation or the source code of the specific plugin to confirm and refer to the #link(label("ref-spi-compatibility"))[SPI compatibility notes] for further technical details.

#anchor("ref-plugins-installation")

== Installation

To install a plugin, extract the ZIP archive into a directory in the #raw("plugin") directory of your Trino installation on all nodes of the cluster. The directory contains all necessary resources.

For example, for a plugin called #raw("example-plugin") with a version of #raw("1.0"), extract the #raw("example-plugin-1.0.zip") archive. Rename the resulting directory #raw("example-plugin-1.0") to #raw("example-plugin") and copy it into the #raw("plugin") directory of your Trino installation on all workers and the coordinator of the cluster.

#note[
Every Trino plugin must be in a separate directory underneath the #raw("plugin") directory. Do not put JAR files directly into the #raw("plugin") directory. Each plugin directory should only contain JAR files. Any subdirectories and other files are ignored.
]

By default, the plugin directory is the #raw("plugin") directory relative to the directory in which Trino is installed, but it is configurable using the configuration variable #raw("plugin.dir") with the launcher. The #link(label("doc-installation-containers"))[Docker image] uses the path #raw("/usr/lib/trino/plugin").

Restart Trino to use the plugin.

The #link("https://github.com/trinodb/trino-packages")[trino-packages project] contains example projects to create a tarball and Docker image with a selection of plugins by installing only the desired plugins.

#anchor("ref-plugins-removal")

== Removal

Plugins can be safely removed if the functionality is not needed or desired on your Trino cluster. Use the following steps for a safe removal across the cluster:

- Shut down Trino on all nodes.
- Delete the directory in the #raw("plugin") folder of the Trino installation on all nodes.
- Start Trino on all nodes.

Refer to the #link(label("ref-plugins-list"))[Plugins] for relevant directory names.

For repeated deployments, you can remove the plugin from the binary package for your installation by creating a custom tarball or a custom Docker image.

#anchor("ref-plugins-development")

== Development

You can develop plugins in your own fork of the Trino codebase or a separate project. Refer to the #link(label("doc-develop"))[Developer guide] for further details.

#anchor("ref-plugins-list")

== List of plugins

The following list of plugins is available from the Trino project. They are included in the build and release process and the resulting the binary packages.

#list-table((
  ([Plugin directory], [Description], [Download],),
  ([ai-functions], [#link(label("doc-functions-ai"))[AI functions]], [#raw("ai-functions")],),
  ([bigquery], [#link(label("doc-connector-bigquery"))[BigQuery connector]], [#raw("bigquery")],),
  ([blackhole], [#link(label("doc-connector-blackhole"))[Black Hole connector]], [#raw("blackhole")],),
  ([cassandra], [#link(label("doc-connector-cassandra"))[Cassandra connector]], [#raw("cassandra")],),
  ([clickhouse], [#link(label("doc-connector-clickhouse"))[ClickHouse connector]], [#raw("clickhouse")],),
  ([delta-lake], [#link(label("doc-connector-delta-lake"))[Delta Lake connector]], [#raw("delta-lake")],),
  ([druid], [#link(label("doc-connector-druid"))[Druid connector]], [#raw("druid")],),
  ([duckdb], [#link(label("doc-connector-duckdb"))[DuckDB connector]], [#raw("duckdb")],),
  ([elasticsearch], [#link(label("doc-connector-elasticsearch"))[Elasticsearch connector]], [#raw("elasticsearch")],),
  ([example-http], [#link(label("doc-develop-example-http"))[Example HTTP connector]], [#raw("example-http")],),
  ([exasol], [#link(label("doc-connector-exasol"))[Exasol connector]], [#raw("exasol")],),
  ([exchange-filesystem], [#link(label("doc-admin-fault-tolerant-execution"))[Fault-tolerant execution] exchange file system], [#raw("exchange-filesystem")],),
  ([exchange-hdfs], [#link(label("doc-admin-fault-tolerant-execution"))[Fault-tolerant execution] exchange file system for HDFS], [#raw("exchange-hdfs")],),
  ([faker], [#link(label("doc-connector-faker"))[Faker connector]], [#raw("faker")],),
  ([functions-python], [#link(label("doc-udf-python"))[Python user-defined functions]], [#raw("functions-python")],),
  ([geospatial], [#link(label("doc-functions-geospatial"))[Geospatial functions]], [#raw("geospatial")],),
  ([google-sheets], [#link(label("doc-connector-googlesheets"))[Google Sheets connector]], [#raw("google-sheets")],),
  ([hive], [#link(label("doc-connector-hive"))[Hive connector]], [#raw("hive")],),
  ([http-event-listener], [#link(label("doc-admin-event-listeners-http"))[HTTP event listener]], [#raw("http-event-listener")],),
  ([http-server-event-listener], [HTTP server event listener], [#raw("http-server-event-listener")],),
  ([hudi], [#link(label("doc-connector-hudi"))[Hudi connector]], [#raw("hudi")],),
  ([iceberg], [#link(label("doc-connector-iceberg"))[Iceberg connector]], [#raw("iceberg")],),
  ([ignite], [#link(label("doc-connector-ignite"))[Ignite connector]], [#raw("ignite")],),
  ([jmx], [#link(label("doc-connector-jmx"))[JMX connector]], [#raw("jmx")],),
  ([kafka], [#link(label("doc-connector-kafka"))[Kafka connector]], [#raw("kafka")],),
  ([kafka-event-listener], [#link(label("doc-admin-event-listeners-kafka"))[Kafka event listener]], [#raw("kafka-event-listener")],),
  ([lakehouse], [#link(label("doc-connector-lakehouse"))[Lakehouse connector]], [#raw("lakehouse")],),
  ([loki], [#link(label("doc-connector-loki"))[Loki connector]], [#raw("loki")],),
  ([mariadb], [#link(label("doc-connector-mariadb"))[MariaDB connector]], [#raw("mariadb")],),
  ([memory], [#link(label("doc-connector-memory"))[Memory connector]], [#raw("memory")],),
  ([ml], [#link(label("doc-functions-ml"))[Machine learning functions]], [#raw("ml")],),
  ([mongodb], [#link(label("doc-connector-mongodb"))[MongoDB connector]], [#raw("mongodb")],),
  ([mysql], [#link(label("doc-connector-mysql"))[MySQL connector]], [#raw("mysql")],),
  ([mysql-event-listener], [#link(label("doc-admin-event-listeners-mysql"))[MySQL event listener]], [#raw("mysql-event-listener")],),
  ([opa], [#link(label("doc-security-opa-access-control"))[Open Policy Agent access control]], [#raw("opa")],),
  ([openlineage], [#link(label("doc-admin-event-listeners-openlineage"))[OpenLineage event listener]], [#raw("openlineage")],),
  ([opensearch], [#link(label("doc-connector-opensearch"))[OpenSearch connector]], [#raw("opensearch")],),
  ([oracle], [#link(label("doc-connector-oracle"))[Oracle connector]], [#raw("oracle")],),
  ([password-authenticators], [Password authentication], [#raw("password-authenticators")],),
  ([pinot], [#link(label("doc-connector-pinot"))[Pinot connector]], [#raw("pinot")],),
  ([postgresql], [#link(label("doc-connector-postgresql"))[PostgreSQL connector]], [#raw("postgresql")],),
  ([prometheus], [#link(label("doc-connector-prometheus"))[Prometheus connector]], [#raw("prometheus")],),
  ([ranger], [#link(label("doc-security-ranger-access-control"))[Ranger access control]], [#raw("ranger")],),
  ([redis], [#link(label("doc-connector-redis"))[Redis connector]], [#raw("redis")],),
  ([redshift], [#link(label("doc-connector-redshift"))[Redshift connector]], [#raw("redshift")],),
  ([resource-group-managers], [#link(label("doc-admin-resource-groups"))[Resource groups]], [#raw("resource-group-managers")],),
  ([session-property-managers], [#link(label("doc-admin-session-property-managers"))[Session property managers]], [#raw("session-property-managers")],),
  ([singlestore], [#link(label("doc-connector-singlestore"))[SingleStore connector]], [#raw("singlestore")],),
  ([snowflake], [#link(label("doc-connector-snowflake"))[Snowflake connector]], [#raw("snowflake")],),
  ([spooling-filesystem], [Server side support for #link(label("ref-protocol-spooling"))[Client protocol]], [#raw("spooling-filesystem")],),
  ([sqlserver], [#link(label("doc-connector-sqlserver"))[SQL Server connector]], [#raw("sqlserver")],),
  ([teradata-functions], [#link(label("doc-functions-teradata"))[Teradata functions]], [#raw("teradata-functions")],),
  ([thrift], [#link(label("doc-connector-thrift"))[Thrift connector]], [#raw("thrift")],),
  ([tpcds], [#link(label("doc-connector-tpcds"))[TPC-DS connector]], [#raw("tpcds")],),
  ([tpch], [#link(label("doc-connector-tpch"))[TPC-H connector]], [#raw("tpch")],)
), header-rows: 1, title: "List of plugins")
