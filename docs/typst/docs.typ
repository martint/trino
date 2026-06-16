#import "/lib/trino-docs.typ": *

// Navigation entries: (document label, title, docpath, built).
#let nav-entries = (
  ("doc-overview", "Overview", "overview", true),
  ("doc-installation", "Installation", "installation", true),
  ("doc-client", "Clients", "client", true),
  ("doc-security", "Security", "security", true),
  ("doc-admin", "Administration", "admin", true),
  ("doc-optimizer", "Query optimizer", "optimizer", true),
  ("doc-connector", "Connectors", "connector", true),
  ("doc-object-storage", "Object storage", "object-storage", true),
  ("doc-functions", "Functions and operators", "functions", true),
  ("doc-udf", "User-defined functions", "udf", true),
  ("doc-language", "SQL language", "language", true),
  ("doc-sql", "SQL statement syntax", "sql", true),
  ("doc-develop", "Developer guide", "develop", true),
  ("doc-glossary", "Glossary", "glossary", true),
  ("doc-appendix", "Appendix", "appendix", true),
)

// Build the sidebar for the page at `current` docpath,
// marking the top-level section that contains it.
#let nav-for(current) = nav-sidebar(nav-entries.map(e => (
  label: e.at(0), title: e.at(1), built: e.at(3),
  current: current == e.at(2) or current.starts-with(e.at(2) + "/"),
)))

#document("admin.html", page-shell(
  title: "Administration — Trino docs",
  css: "trino.css",
  nav: nav-for("admin"),
  include "src/admin.typ",
))
#document("admin/dist-sort.html", page-shell(
  title: "Distributed sort — Trino docs",
  css: "../trino.css",
  nav: nav-for("admin/dist-sort"),
  include "src/admin/dist-sort.typ",
))
#document("admin/dynamic-filtering.html", page-shell(
  title: "Dynamic filtering — Trino docs",
  css: "../trino.css",
  nav: nav-for("admin/dynamic-filtering"),
  include "src/admin/dynamic-filtering.typ",
))
#document("admin/event-listeners-http.html", page-shell(
  title: "HTTP event listener — Trino docs",
  css: "../trino.css",
  nav: nav-for("admin/event-listeners-http"),
  include "src/admin/event-listeners-http.typ",
))
#document("admin/event-listeners-kafka.html", page-shell(
  title: "Kafka event listener — Trino docs",
  css: "../trino.css",
  nav: nav-for("admin/event-listeners-kafka"),
  include "src/admin/event-listeners-kafka.typ",
))
#document("admin/event-listeners-mysql.html", page-shell(
  title: "MySQL event listener — Trino docs",
  css: "../trino.css",
  nav: nav-for("admin/event-listeners-mysql"),
  include "src/admin/event-listeners-mysql.typ",
))
#document("admin/event-listeners-openlineage.html", page-shell(
  title: "OpenLineage event listener — Trino docs",
  css: "../trino.css",
  nav: nav-for("admin/event-listeners-openlineage"),
  include "src/admin/event-listeners-openlineage.typ",
))
#document("admin/fault-tolerant-execution.html", page-shell(
  title: "Fault-tolerant execution — Trino docs",
  css: "../trino.css",
  nav: nav-for("admin/fault-tolerant-execution"),
  include "src/admin/fault-tolerant-execution.typ",
))
#document("admin/graceful-shutdown.html", page-shell(
  title: "Graceful shutdown — Trino docs",
  css: "../trino.css",
  nav: nav-for("admin/graceful-shutdown"),
  include "src/admin/graceful-shutdown.typ",
))
#document("admin/jmx.html", page-shell(
  title: "Monitoring with JMX — Trino docs",
  css: "../trino.css",
  nav: nav-for("admin/jmx"),
  include "src/admin/jmx.typ",
))
#document("admin/logging.html", page-shell(
  title: "Logging — Trino docs",
  css: "../trino.css",
  nav: nav-for("admin/logging"),
  include "src/admin/logging.typ",
))
#document("admin/openmetrics.html", page-shell(
  title: "Trino metrics with OpenMetrics — Trino docs",
  css: "../trino.css",
  nav: nav-for("admin/openmetrics"),
  include "src/admin/openmetrics.typ",
))
#document("admin/opentelemetry.html", page-shell(
  title: "Observability with OpenTelemetry — Trino docs",
  css: "../trino.css",
  nav: nav-for("admin/opentelemetry"),
  include "src/admin/opentelemetry.typ",
))
#document("admin/preview-web-interface.html", page-shell(
  title: "Preview Web UI — Trino docs",
  css: "../trino.css",
  nav: nav-for("admin/preview-web-interface"),
  include "src/admin/preview-web-interface.typ",
))
#document("admin/properties.html", page-shell(
  title: "Properties reference — Trino docs",
  css: "../trino.css",
  nav: nav-for("admin/properties"),
  include "src/admin/properties.typ",
))
#document("admin/properties-catalog.html", page-shell(
  title: "Catalog management properties — Trino docs",
  css: "../trino.css",
  nav: nav-for("admin/properties-catalog"),
  include "src/admin/properties-catalog.typ",
))
#document("admin/properties-client-protocol.html", page-shell(
  title: "Client protocol properties — Trino docs",
  css: "../trino.css",
  nav: nav-for("admin/properties-client-protocol"),
  include "src/admin/properties-client-protocol.typ",
))
#document("admin/properties-exchange.html", page-shell(
  title: "Exchange properties — Trino docs",
  css: "../trino.css",
  nav: nav-for("admin/properties-exchange"),
  include "src/admin/properties-exchange.typ",
))
#document("admin/properties-general.html", page-shell(
  title: "General properties — Trino docs",
  css: "../trino.css",
  nav: nav-for("admin/properties-general"),
  include "src/admin/properties-general.typ",
))
#document("admin/properties-http-client.html", page-shell(
  title: "HTTP client properties — Trino docs",
  css: "../trino.css",
  nav: nav-for("admin/properties-http-client"),
  include "src/admin/properties-http-client.typ",
))
#document("admin/properties-http-server.html", page-shell(
  title: "HTTP server properties — Trino docs",
  css: "../trino.css",
  nav: nav-for("admin/properties-http-server"),
  include "src/admin/properties-http-server.typ",
))
#document("admin/properties-logging.html", page-shell(
  title: "Logging properties — Trino docs",
  css: "../trino.css",
  nav: nav-for("admin/properties-logging"),
  include "src/admin/properties-logging.typ",
))
#document("admin/properties-node-scheduler.html", page-shell(
  title: "Node scheduler properties — Trino docs",
  css: "../trino.css",
  nav: nav-for("admin/properties-node-scheduler"),
  include "src/admin/properties-node-scheduler.typ",
))
#document("admin/properties-optimizer.html", page-shell(
  title: "Optimizer properties — Trino docs",
  css: "../trino.css",
  nav: nav-for("admin/properties-optimizer"),
  include "src/admin/properties-optimizer.typ",
))
#document("admin/properties-query-management.html", page-shell(
  title: "Query management properties — Trino docs",
  css: "../trino.css",
  nav: nav-for("admin/properties-query-management"),
  include "src/admin/properties-query-management.typ",
))
#document("admin/properties-regexp-function.html", page-shell(
  title: "Regular expression function properties — Trino docs",
  css: "../trino.css",
  nav: nav-for("admin/properties-regexp-function"),
  include "src/admin/properties-regexp-function.typ",
))
#document("admin/properties-resource-management.html", page-shell(
  title: "Resource management properties — Trino docs",
  css: "../trino.css",
  nav: nav-for("admin/properties-resource-management"),
  include "src/admin/properties-resource-management.typ",
))
#document("admin/properties-spilling.html", page-shell(
  title: "Spilling properties — Trino docs",
  css: "../trino.css",
  nav: nav-for("admin/properties-spilling"),
  include "src/admin/properties-spilling.typ",
))
#document("admin/properties-sql-environment.html", page-shell(
  title: "SQL environment properties — Trino docs",
  css: "../trino.css",
  nav: nav-for("admin/properties-sql-environment"),
  include "src/admin/properties-sql-environment.typ",
))
#document("admin/properties-task.html", page-shell(
  title: "Task properties — Trino docs",
  css: "../trino.css",
  nav: nav-for("admin/properties-task"),
  include "src/admin/properties-task.typ",
))
#document("admin/properties-web-interface.html", page-shell(
  title: "Web UI properties — Trino docs",
  css: "../trino.css",
  nav: nav-for("admin/properties-web-interface"),
  include "src/admin/properties-web-interface.typ",
))
#document("admin/properties-write-partitioning.html", page-shell(
  title: "Write partitioning properties — Trino docs",
  css: "../trino.css",
  nav: nav-for("admin/properties-write-partitioning"),
  include "src/admin/properties-write-partitioning.typ",
))
#document("admin/properties-writer-scaling.html", page-shell(
  title: "Writer scaling properties — Trino docs",
  css: "../trino.css",
  nav: nav-for("admin/properties-writer-scaling"),
  include "src/admin/properties-writer-scaling.typ",
))
#document("admin/resource-groups.html", page-shell(
  title: "Resource groups — Trino docs",
  css: "../trino.css",
  nav: nav-for("admin/resource-groups"),
  include "src/admin/resource-groups.typ",
))
#document("admin/session-property-managers.html", page-shell(
  title: "Session property managers — Trino docs",
  css: "../trino.css",
  nav: nav-for("admin/session-property-managers"),
  include "src/admin/session-property-managers.typ",
))
#document("admin/spill.html", page-shell(
  title: "Spill to disk — Trino docs",
  css: "../trino.css",
  nav: nav-for("admin/spill"),
  include "src/admin/spill.typ",
))
#document("admin/tuning.html", page-shell(
  title: "Tuning Trino — Trino docs",
  css: "../trino.css",
  nav: nav-for("admin/tuning"),
  include "src/admin/tuning.typ",
))
#document("admin/web-interface.html", page-shell(
  title: "Web UI — Trino docs",
  css: "../trino.css",
  nav: nav-for("admin/web-interface"),
  include "src/admin/web-interface.typ",
))
#document("appendix.html", page-shell(
  title: "Appendix — Trino docs",
  css: "trino.css",
  nav: nav-for("appendix"),
  include "src/appendix.typ",
))
#document("appendix/from-hive.html", page-shell(
  title: "Migrating from Hive — Trino docs",
  css: "../trino.css",
  nav: nav-for("appendix/from-hive"),
  include "src/appendix/from-hive.typ",
))
#document("appendix/legal-notices.html", page-shell(
  title: "Legal notices — Trino docs",
  css: "../trino.css",
  nav: nav-for("appendix/legal-notices"),
  include "src/appendix/legal-notices.typ",
))
#document("client.html", page-shell(
  title: "Clients — Trino docs",
  css: "trino.css",
  nav: nav-for("client"),
  include "src/client.typ",
))
#document("client/cli.html", page-shell(
  title: "Command line interface — Trino docs",
  css: "../trino.css",
  nav: nav-for("client/cli"),
  include "src/client/cli.typ",
))
#document("client/client-protocol.html", page-shell(
  title: "Client protocol — Trino docs",
  css: "../trino.css",
  nav: nav-for("client/client-protocol"),
  include "src/client/client-protocol.typ",
))
#document("client/jdbc.html", page-shell(
  title: "JDBC driver — Trino docs",
  css: "../trino.css",
  nav: nav-for("client/jdbc"),
  include "src/client/jdbc.typ",
))
#document("connector.html", page-shell(
  title: "Connectors — Trino docs",
  css: "trino.css",
  nav: nav-for("connector"),
  include "src/connector.typ",
))
#document("connector/bigquery.html", page-shell(
  title: "BigQuery connector — Trino docs",
  css: "../trino.css",
  nav: nav-for("connector/bigquery"),
  include "src/connector/bigquery.typ",
))
#document("connector/blackhole.html", page-shell(
  title: "Black Hole connector — Trino docs",
  css: "../trino.css",
  nav: nav-for("connector/blackhole"),
  include "src/connector/blackhole.typ",
))
#document("connector/cassandra.html", page-shell(
  title: "Cassandra connector — Trino docs",
  css: "../trino.css",
  nav: nav-for("connector/cassandra"),
  include "src/connector/cassandra.typ",
))
#document("connector/clickhouse.html", page-shell(
  title: "ClickHouse connector — Trino docs",
  css: "../trino.css",
  nav: nav-for("connector/clickhouse"),
  include "src/connector/clickhouse.typ",
))
#document("connector/delta-lake.html", page-shell(
  title: "Delta Lake connector — Trino docs",
  css: "../trino.css",
  nav: nav-for("connector/delta-lake"),
  include "src/connector/delta-lake.typ",
))
#document("connector/druid.html", page-shell(
  title: "Druid connector — Trino docs",
  css: "../trino.css",
  nav: nav-for("connector/druid"),
  include "src/connector/druid.typ",
))
#document("connector/duckdb.html", page-shell(
  title: "DuckDB connector — Trino docs",
  css: "../trino.css",
  nav: nav-for("connector/duckdb"),
  include "src/connector/duckdb.typ",
))
#document("connector/elasticsearch.html", page-shell(
  title: "Elasticsearch connector — Trino docs",
  css: "../trino.css",
  nav: nav-for("connector/elasticsearch"),
  include "src/connector/elasticsearch.typ",
))
#document("connector/exasol.html", page-shell(
  title: "Exasol connector — Trino docs",
  css: "../trino.css",
  nav: nav-for("connector/exasol"),
  include "src/connector/exasol.typ",
))
#document("connector/faker.html", page-shell(
  title: "Faker connector — Trino docs",
  css: "../trino.css",
  nav: nav-for("connector/faker"),
  include "src/connector/faker.typ",
))
#document("connector/googlesheets.html", page-shell(
  title: "Google Sheets connector — Trino docs",
  css: "../trino.css",
  nav: nav-for("connector/googlesheets"),
  include "src/connector/googlesheets.typ",
))
#document("connector/hive.html", page-shell(
  title: "Hive connector — Trino docs",
  css: "../trino.css",
  nav: nav-for("connector/hive"),
  include "src/connector/hive.typ",
))
#document("connector/hudi.html", page-shell(
  title: "Hudi connector — Trino docs",
  css: "../trino.css",
  nav: nav-for("connector/hudi"),
  include "src/connector/hudi.typ",
))
#document("connector/iceberg.html", page-shell(
  title: "Iceberg connector — Trino docs",
  css: "../trino.css",
  nav: nav-for("connector/iceberg"),
  include "src/connector/iceberg.typ",
))
#document("connector/ignite.html", page-shell(
  title: "Ignite connector — Trino docs",
  css: "../trino.css",
  nav: nav-for("connector/ignite"),
  include "src/connector/ignite.typ",
))
#document("connector/jmx.html", page-shell(
  title: "JMX connector — Trino docs",
  css: "../trino.css",
  nav: nav-for("connector/jmx"),
  include "src/connector/jmx.typ",
))
#document("connector/kafka.html", page-shell(
  title: "Kafka connector — Trino docs",
  css: "../trino.css",
  nav: nav-for("connector/kafka"),
  include "src/connector/kafka.typ",
))
#document("connector/kafka-tutorial.html", page-shell(
  title: "Kafka connector tutorial — Trino docs",
  css: "../trino.css",
  nav: nav-for("connector/kafka-tutorial"),
  include "src/connector/kafka-tutorial.typ",
))
#document("connector/lakehouse.html", page-shell(
  title: "Lakehouse connector — Trino docs",
  css: "../trino.css",
  nav: nav-for("connector/lakehouse"),
  include "src/connector/lakehouse.typ",
))
#document("connector/loki.html", page-shell(
  title: "Loki connector — Trino docs",
  css: "../trino.css",
  nav: nav-for("connector/loki"),
  include "src/connector/loki.typ",
))
#document("connector/mariadb.html", page-shell(
  title: "MariaDB connector — Trino docs",
  css: "../trino.css",
  nav: nav-for("connector/mariadb"),
  include "src/connector/mariadb.typ",
))
#document("connector/memory.html", page-shell(
  title: "Memory connector — Trino docs",
  css: "../trino.css",
  nav: nav-for("connector/memory"),
  include "src/connector/memory.typ",
))
#document("connector/mongodb.html", page-shell(
  title: "MongoDB connector — Trino docs",
  css: "../trino.css",
  nav: nav-for("connector/mongodb"),
  include "src/connector/mongodb.typ",
))
#document("connector/mysql.html", page-shell(
  title: "MySQL connector — Trino docs",
  css: "../trino.css",
  nav: nav-for("connector/mysql"),
  include "src/connector/mysql.typ",
))
#document("connector/opensearch.html", page-shell(
  title: "OpenSearch connector — Trino docs",
  css: "../trino.css",
  nav: nav-for("connector/opensearch"),
  include "src/connector/opensearch.typ",
))
#document("connector/oracle.html", page-shell(
  title: "Oracle connector — Trino docs",
  css: "../trino.css",
  nav: nav-for("connector/oracle"),
  include "src/connector/oracle.typ",
))
#document("connector/pinot.html", page-shell(
  title: "Pinot connector — Trino docs",
  css: "../trino.css",
  nav: nav-for("connector/pinot"),
  include "src/connector/pinot.typ",
))
#document("connector/postgresql.html", page-shell(
  title: "PostgreSQL connector — Trino docs",
  css: "../trino.css",
  nav: nav-for("connector/postgresql"),
  include "src/connector/postgresql.typ",
))
#document("connector/prometheus.html", page-shell(
  title: "Prometheus connector — Trino docs",
  css: "../trino.css",
  nav: nav-for("connector/prometheus"),
  include "src/connector/prometheus.typ",
))
#document("connector/redis.html", page-shell(
  title: "Redis connector — Trino docs",
  css: "../trino.css",
  nav: nav-for("connector/redis"),
  include "src/connector/redis.typ",
))
#document("connector/redshift.html", page-shell(
  title: "Redshift connector — Trino docs",
  css: "../trino.css",
  nav: nav-for("connector/redshift"),
  include "src/connector/redshift.typ",
))
#document("connector/removed.html", page-shell(
  title: "404 - Connector removed — Trino docs",
  css: "../trino.css",
  nav: nav-for("connector/removed"),
  include "src/connector/removed.typ",
))
#document("connector/singlestore.html", page-shell(
  title: "SingleStore connector — Trino docs",
  css: "../trino.css",
  nav: nav-for("connector/singlestore"),
  include "src/connector/singlestore.typ",
))
#document("connector/snowflake.html", page-shell(
  title: "Snowflake connector — Trino docs",
  css: "../trino.css",
  nav: nav-for("connector/snowflake"),
  include "src/connector/snowflake.typ",
))
#document("connector/sqlserver.html", page-shell(
  title: "SQL Server connector — Trino docs",
  css: "../trino.css",
  nav: nav-for("connector/sqlserver"),
  include "src/connector/sqlserver.typ",
))
#document("connector/system.html", page-shell(
  title: "System connector — Trino docs",
  css: "../trino.css",
  nav: nav-for("connector/system"),
  include "src/connector/system.typ",
))
#document("connector/thrift.html", page-shell(
  title: "Thrift connector — Trino docs",
  css: "../trino.css",
  nav: nav-for("connector/thrift"),
  include "src/connector/thrift.typ",
))
#document("connector/tpcds.html", page-shell(
  title: "TPC-DS connector — Trino docs",
  css: "../trino.css",
  nav: nav-for("connector/tpcds"),
  include "src/connector/tpcds.typ",
))
#document("connector/tpch.html", page-shell(
  title: "TPC-H connector — Trino docs",
  css: "../trino.css",
  nav: nav-for("connector/tpch"),
  include "src/connector/tpch.typ",
))
#document("develop.html", page-shell(
  title: "Developer guide — Trino docs",
  css: "trino.css",
  nav: nav-for("develop"),
  include "src/develop.typ",
))
#document("develop/certificate-authenticator.html", page-shell(
  title: "Certificate authenticator — Trino docs",
  css: "../trino.css",
  nav: nav-for("develop/certificate-authenticator"),
  include "src/develop/certificate-authenticator.typ",
))
#document("develop/client-protocol.html", page-shell(
  title: "Trino client REST API — Trino docs",
  css: "../trino.css",
  nav: nav-for("develop/client-protocol"),
  include "src/develop/client-protocol.typ",
))
#document("develop/connectors.html", page-shell(
  title: "Connectors — Trino docs",
  css: "../trino.css",
  nav: nav-for("develop/connectors"),
  include "src/develop/connectors.typ",
))
#document("develop/event-listener.html", page-shell(
  title: "Event listener — Trino docs",
  css: "../trino.css",
  nav: nav-for("develop/event-listener"),
  include "src/develop/event-listener.typ",
))
#document("develop/example-http.html", page-shell(
  title: "Example HTTP connector — Trino docs",
  css: "../trino.css",
  nav: nav-for("develop/example-http"),
  include "src/develop/example-http.typ",
))
#document("develop/example-jdbc.html", page-shell(
  title: "Example JDBC connector — Trino docs",
  css: "../trino.css",
  nav: nav-for("develop/example-jdbc"),
  include "src/develop/example-jdbc.typ",
))
#document("develop/functions.html", page-shell(
  title: "Functions — Trino docs",
  css: "../trino.css",
  nav: nav-for("develop/functions"),
  include "src/develop/functions.typ",
))
#document("develop/group-provider.html", page-shell(
  title: "Group provider — Trino docs",
  css: "../trino.css",
  nav: nav-for("develop/group-provider"),
  include "src/develop/group-provider.typ",
))
#document("develop/header-authenticator.html", page-shell(
  title: "Header authenticator — Trino docs",
  css: "../trino.css",
  nav: nav-for("develop/header-authenticator"),
  include "src/develop/header-authenticator.typ",
))
#document("develop/insert.html", page-shell(
  title: "Supporting INSERT and CREATE TABLE AS — Trino docs",
  css: "../trino.css",
  nav: nav-for("develop/insert"),
  include "src/develop/insert.typ",
))
#document("develop/password-authenticator.html", page-shell(
  title: "Password authenticator — Trino docs",
  css: "../trino.css",
  nav: nav-for("develop/password-authenticator"),
  include "src/develop/password-authenticator.typ",
))
#document("develop/spi-overview.html", page-shell(
  title: "SPI overview — Trino docs",
  css: "../trino.css",
  nav: nav-for("develop/spi-overview"),
  include "src/develop/spi-overview.typ",
))
#document("develop/supporting-merge.html", page-shell(
  title: "Supporting MERGE — Trino docs",
  css: "../trino.css",
  nav: nav-for("develop/supporting-merge"),
  include "src/develop/supporting-merge.typ",
))
#document("develop/system-access-control.html", page-shell(
  title: "System access control — Trino docs",
  css: "../trino.css",
  nav: nav-for("develop/system-access-control"),
  include "src/develop/system-access-control.typ",
))
#document("develop/table-functions.html", page-shell(
  title: "Table functions — Trino docs",
  css: "../trino.css",
  nav: nav-for("develop/table-functions"),
  include "src/develop/table-functions.typ",
))
#document("develop/tests.html", page-shell(
  title: "Test writing guidelines — Trino docs",
  css: "../trino.css",
  nav: nav-for("develop/tests"),
  include "src/develop/tests.typ",
))
#document("develop/types.html", page-shell(
  title: "Types — Trino docs",
  css: "../trino.css",
  nav: nav-for("develop/types"),
  include "src/develop/types.typ",
))
#document("functions.html", page-shell(
  title: "Functions and operators — Trino docs",
  css: "trino.css",
  nav: nav-for("functions"),
  include "src/functions.typ",
))
#document("functions/aggregate.html", page-shell(
  title: "Aggregate functions — Trino docs",
  css: "../trino.css",
  nav: nav-for("functions/aggregate"),
  include "src/functions/aggregate.typ",
))
#document("functions/ai.html", page-shell(
  title: "AI functions — Trino docs",
  css: "../trino.css",
  nav: nav-for("functions/ai"),
  include "src/functions/ai.typ",
))
#document("functions/array.html", page-shell(
  title: "Array functions and operators — Trino docs",
  css: "../trino.css",
  nav: nav-for("functions/array"),
  include "src/functions/array.typ",
))
#document("functions/binary.html", page-shell(
  title: "Binary functions and operators — Trino docs",
  css: "../trino.css",
  nav: nav-for("functions/binary"),
  include "src/functions/binary.typ",
))
#document("functions/bitwise.html", page-shell(
  title: "Bitwise functions — Trino docs",
  css: "../trino.css",
  nav: nav-for("functions/bitwise"),
  include "src/functions/bitwise.typ",
))
#document("functions/color.html", page-shell(
  title: "Color functions — Trino docs",
  css: "../trino.css",
  nav: nav-for("functions/color"),
  include "src/functions/color.typ",
))
#document("functions/comparison.html", page-shell(
  title: "Comparison functions and operators — Trino docs",
  css: "../trino.css",
  nav: nav-for("functions/comparison"),
  include "src/functions/comparison.typ",
))
#document("functions/conditional.html", page-shell(
  title: "Conditional expressions — Trino docs",
  css: "../trino.css",
  nav: nav-for("functions/conditional"),
  include "src/functions/conditional.typ",
))
#document("functions/conversion.html", page-shell(
  title: "Conversion functions — Trino docs",
  css: "../trino.css",
  nav: nav-for("functions/conversion"),
  include "src/functions/conversion.typ",
))
#document("functions/datasketches.html", page-shell(
  title: "DataSketches functions — Trino docs",
  css: "../trino.css",
  nav: nav-for("functions/datasketches"),
  include "src/functions/datasketches.typ",
))
#document("functions/datetime.html", page-shell(
  title: "Date and time functions and operators — Trino docs",
  css: "../trino.css",
  nav: nav-for("functions/datetime"),
  include "src/functions/datetime.typ",
))
#document("functions/decimal.html", page-shell(
  title: "Decimal functions and operators — Trino docs",
  css: "../trino.css",
  nav: nav-for("functions/decimal"),
  include "src/functions/decimal.typ",
))
#document("functions/geospatial.html", page-shell(
  title: "Geospatial functions — Trino docs",
  css: "../trino.css",
  nav: nav-for("functions/geospatial"),
  include "src/functions/geospatial.typ",
))
#document("functions/hyperloglog.html", page-shell(
  title: "HyperLogLog functions — Trino docs",
  css: "../trino.css",
  nav: nav-for("functions/hyperloglog"),
  include "src/functions/hyperloglog.typ",
))
#document("functions/ipaddress.html", page-shell(
  title: "IP Address Functions — Trino docs",
  css: "../trino.css",
  nav: nav-for("functions/ipaddress"),
  include "src/functions/ipaddress.typ",
))
#document("functions/json.html", page-shell(
  title: "JSON functions and operators — Trino docs",
  css: "../trino.css",
  nav: nav-for("functions/json"),
  include "src/functions/json.typ",
))
#document("functions/lambda.html", page-shell(
  title: "Lambda expressions — Trino docs",
  css: "../trino.css",
  nav: nav-for("functions/lambda"),
  include "src/functions/lambda.typ",
))
#document("functions/list.html", page-shell(
  title: "List of functions and operators — Trino docs",
  css: "../trino.css",
  nav: nav-for("functions/list"),
  include "src/functions/list.typ",
))
#document("functions/list-by-topic.html", page-shell(
  title: "List of functions by topic — Trino docs",
  css: "../trino.css",
  nav: nav-for("functions/list-by-topic"),
  include "src/functions/list-by-topic.typ",
))
#document("functions/logical.html", page-shell(
  title: "Logical operators — Trino docs",
  css: "../trino.css",
  nav: nav-for("functions/logical"),
  include "src/functions/logical.typ",
))
#document("functions/map.html", page-shell(
  title: "Map functions and operators — Trino docs",
  css: "../trino.css",
  nav: nav-for("functions/map"),
  include "src/functions/map.typ",
))
#document("functions/math.html", page-shell(
  title: "Mathematical functions and operators — Trino docs",
  css: "../trino.css",
  nav: nav-for("functions/math"),
  include "src/functions/math.typ",
))
#document("functions/ml.html", page-shell(
  title: "Machine learning functions — Trino docs",
  css: "../trino.css",
  nav: nav-for("functions/ml"),
  include "src/functions/ml.typ",
))
#document("functions/qdigest.html", page-shell(
  title: "Quantile digest functions — Trino docs",
  css: "../trino.css",
  nav: nav-for("functions/qdigest"),
  include "src/functions/qdigest.typ",
))
#document("functions/regexp.html", page-shell(
  title: "Regular expression functions — Trino docs",
  css: "../trino.css",
  nav: nav-for("functions/regexp"),
  include "src/functions/regexp.typ",
))
#document("functions/session.html", page-shell(
  title: "Session information — Trino docs",
  css: "../trino.css",
  nav: nav-for("functions/session"),
  include "src/functions/session.typ",
))
#document("functions/setdigest.html", page-shell(
  title: "Set Digest functions — Trino docs",
  css: "../trino.css",
  nav: nav-for("functions/setdigest"),
  include "src/functions/setdigest.typ",
))
#document("functions/string.html", page-shell(
  title: "String functions and operators — Trino docs",
  css: "../trino.css",
  nav: nav-for("functions/string"),
  include "src/functions/string.typ",
))
#document("functions/system.html", page-shell(
  title: "System information — Trino docs",
  css: "../trino.css",
  nav: nav-for("functions/system"),
  include "src/functions/system.typ",
))
#document("functions/table.html", page-shell(
  title: "Table functions — Trino docs",
  css: "../trino.css",
  nav: nav-for("functions/table"),
  include "src/functions/table.typ",
))
#document("functions/tdigest.html", page-shell(
  title: "T-Digest functions — Trino docs",
  css: "../trino.css",
  nav: nav-for("functions/tdigest"),
  include "src/functions/tdigest.typ",
))
#document("functions/teradata.html", page-shell(
  title: "Teradata functions — Trino docs",
  css: "../trino.css",
  nav: nav-for("functions/teradata"),
  include "src/functions/teradata.typ",
))
#document("functions/url.html", page-shell(
  title: "URL functions — Trino docs",
  css: "../trino.css",
  nav: nav-for("functions/url"),
  include "src/functions/url.typ",
))
#document("functions/uuid.html", page-shell(
  title: "UUID functions — Trino docs",
  css: "../trino.css",
  nav: nav-for("functions/uuid"),
  include "src/functions/uuid.typ",
))
#document("functions/variant.html", page-shell(
  title: "VARIANT functions and operators — Trino docs",
  css: "../trino.css",
  nav: nav-for("functions/variant"),
  include "src/functions/variant.typ",
))
#document("functions/window.html", page-shell(
  title: "Window functions — Trino docs",
  css: "../trino.css",
  nav: nav-for("functions/window"),
  include "src/functions/window.typ",
))
#document("glossary.html", page-shell(
  title: "Glossary — Trino docs",
  css: "trino.css",
  nav: nav-for("glossary"),
  include "src/glossary.typ",
))
#document("index.html", page-shell(
  title: "Trino documentation — Trino docs",
  css: "trino.css",
  nav: nav-for("index"),
  include "src/index.typ",
))
#document("installation.html", page-shell(
  title: "Installation — Trino docs",
  css: "trino.css",
  nav: nav-for("installation"),
  include "src/installation.typ",
))
#document("installation/containers.html", page-shell(
  title: "Trino in a Docker container — Trino docs",
  css: "../trino.css",
  nav: nav-for("installation/containers"),
  include "src/installation/containers.typ",
))
#document("installation/deployment.html", page-shell(
  title: "Deploying Trino — Trino docs",
  css: "../trino.css",
  nav: nav-for("installation/deployment"),
  include "src/installation/deployment.typ",
))
#document("installation/kubernetes.html", page-shell(
  title: "Trino on Kubernetes with Helm — Trino docs",
  css: "../trino.css",
  nav: nav-for("installation/kubernetes"),
  include "src/installation/kubernetes.typ",
))
#document("installation/plugins.html", page-shell(
  title: "Plugins — Trino docs",
  css: "../trino.css",
  nav: nav-for("installation/plugins"),
  include "src/installation/plugins.typ",
))
#document("installation/query-resiliency.html", page-shell(
  title: "Improve query processing resilience — Trino docs",
  css: "../trino.css",
  nav: nav-for("installation/query-resiliency"),
  include "src/installation/query-resiliency.typ",
))
#document("language.html", page-shell(
  title: "SQL language — Trino docs",
  css: "trino.css",
  nav: nav-for("language"),
  include "src/language.typ",
))
#document("language/comments.html", page-shell(
  title: "Comments — Trino docs",
  css: "../trino.css",
  nav: nav-for("language/comments"),
  include "src/language/comments.typ",
))
#document("language/reserved.html", page-shell(
  title: "Keywords and identifiers — Trino docs",
  css: "../trino.css",
  nav: nav-for("language/reserved"),
  include "src/language/reserved.typ",
))
#document("language/sql-support.html", page-shell(
  title: "SQL statement support — Trino docs",
  css: "../trino.css",
  nav: nav-for("language/sql-support"),
  include "src/language/sql-support.typ",
))
#document("language/types.html", page-shell(
  title: "Data types — Trino docs",
  css: "../trino.css",
  nav: nav-for("language/types"),
  include "src/language/types.typ",
))
#document("object-storage.html", page-shell(
  title: "Object storage — Trino docs",
  css: "trino.css",
  nav: nav-for("object-storage"),
  include "src/object-storage.typ",
))
#document("object-storage/file-formats.html", page-shell(
  title: "Object storage file formats — Trino docs",
  css: "../trino.css",
  nav: nav-for("object-storage/file-formats"),
  include "src/object-storage/file-formats.typ",
))
#document("object-storage/file-system-alluxio.html", page-shell(
  title: "Alluxio file system support — Trino docs",
  css: "../trino.css",
  nav: nav-for("object-storage/file-system-alluxio"),
  include "src/object-storage/file-system-alluxio.typ",
))
#document("object-storage/file-system-azure.html", page-shell(
  title: "Azure Storage file system support — Trino docs",
  css: "../trino.css",
  nav: nav-for("object-storage/file-system-azure"),
  include "src/object-storage/file-system-azure.typ",
))
#document("object-storage/file-system-cache.html", page-shell(
  title: "File system cache — Trino docs",
  css: "../trino.css",
  nav: nav-for("object-storage/file-system-cache"),
  include "src/object-storage/file-system-cache.typ",
))
#document("object-storage/file-system-gcs.html", page-shell(
  title: "Google Cloud Storage file system support — Trino docs",
  css: "../trino.css",
  nav: nav-for("object-storage/file-system-gcs"),
  include "src/object-storage/file-system-gcs.typ",
))
#document("object-storage/file-system-hdfs.html", page-shell(
  title: "HDFS file system support — Trino docs",
  css: "../trino.css",
  nav: nav-for("object-storage/file-system-hdfs"),
  include "src/object-storage/file-system-hdfs.typ",
))
#document("object-storage/file-system-local.html", page-shell(
  title: "Local file system support — Trino docs",
  css: "../trino.css",
  nav: nav-for("object-storage/file-system-local"),
  include "src/object-storage/file-system-local.typ",
))
#document("object-storage/file-system-s3.html", page-shell(
  title: "S3 file system support — Trino docs",
  css: "../trino.css",
  nav: nav-for("object-storage/file-system-s3"),
  include "src/object-storage/file-system-s3.typ",
))
#document("object-storage/metastores.html", page-shell(
  title: "Metastores — Trino docs",
  css: "../trino.css",
  nav: nav-for("object-storage/metastores"),
  include "src/object-storage/metastores.typ",
))
#document("optimizer.html", page-shell(
  title: "Query optimizer — Trino docs",
  css: "trino.css",
  nav: nav-for("optimizer"),
  include "src/optimizer.typ",
))
#document("optimizer/adaptive-plan-optimizations.html", page-shell(
  title: "Adaptive plan optimizations — Trino docs",
  css: "../trino.css",
  nav: nav-for("optimizer/adaptive-plan-optimizations"),
  include "src/optimizer/adaptive-plan-optimizations.typ",
))
#document("optimizer/cost-based-optimizations.html", page-shell(
  title: "Cost-based optimizations — Trino docs",
  css: "../trino.css",
  nav: nav-for("optimizer/cost-based-optimizations"),
  include "src/optimizer/cost-based-optimizations.typ",
))
#document("optimizer/cost-in-explain.html", page-shell(
  title: "Cost in EXPLAIN — Trino docs",
  css: "../trino.css",
  nav: nav-for("optimizer/cost-in-explain"),
  include "src/optimizer/cost-in-explain.typ",
))
#document("optimizer/pushdown.html", page-shell(
  title: "Pushdown — Trino docs",
  css: "../trino.css",
  nav: nav-for("optimizer/pushdown"),
  include "src/optimizer/pushdown.typ",
))
#document("optimizer/statistics.html", page-shell(
  title: "Table statistics — Trino docs",
  css: "../trino.css",
  nav: nav-for("optimizer/statistics"),
  include "src/optimizer/statistics.typ",
))
#document("overview.html", page-shell(
  title: "Overview — Trino docs",
  css: "trino.css",
  nav: nav-for("overview"),
  include "src/overview.typ",
))
#document("overview/concepts.html", page-shell(
  title: "Trino concepts — Trino docs",
  css: "../trino.css",
  nav: nav-for("overview/concepts"),
  include "src/overview/concepts.typ",
))
#document("overview/use-cases.html", page-shell(
  title: "Use cases — Trino docs",
  css: "../trino.css",
  nav: nav-for("overview/use-cases"),
  include "src/overview/use-cases.typ",
))
#document("release.html", page-shell(
  title: "Release notes — Trino docs",
  css: "trino.css",
  nav: nav-for("release"),
  include "src/release.typ",
))
#document("release/release-0.100.html", page-shell(
  title: "Release 0.100 — Trino docs",
  css: "../trino.css",
  nav: nav-for("release/release-0.100"),
  include "src/release/release-0.100.typ",
))
#document("release/release-0.101.html", page-shell(
  title: "Release 0.101 — Trino docs",
  css: "../trino.css",
  nav: nav-for("release/release-0.101"),
  include "src/release/release-0.101.typ",
))
#document("release/release-0.102.html", page-shell(
  title: "Release 0.102 — Trino docs",
  css: "../trino.css",
  nav: nav-for("release/release-0.102"),
  include "src/release/release-0.102.typ",
))
#document("release/release-0.103.html", page-shell(
  title: "Release 0.103 — Trino docs",
  css: "../trino.css",
  nav: nav-for("release/release-0.103"),
  include "src/release/release-0.103.typ",
))
#document("release/release-0.104.html", page-shell(
  title: "Release 0.104 — Trino docs",
  css: "../trino.css",
  nav: nav-for("release/release-0.104"),
  include "src/release/release-0.104.typ",
))
#document("release/release-0.105.html", page-shell(
  title: "Release 0.105 — Trino docs",
  css: "../trino.css",
  nav: nav-for("release/release-0.105"),
  include "src/release/release-0.105.typ",
))
#document("release/release-0.106.html", page-shell(
  title: "Release 0.106 — Trino docs",
  css: "../trino.css",
  nav: nav-for("release/release-0.106"),
  include "src/release/release-0.106.typ",
))
#document("release/release-0.107.html", page-shell(
  title: "Release 0.107 — Trino docs",
  css: "../trino.css",
  nav: nav-for("release/release-0.107"),
  include "src/release/release-0.107.typ",
))
#document("release/release-0.108.html", page-shell(
  title: "Release 0.108 — Trino docs",
  css: "../trino.css",
  nav: nav-for("release/release-0.108"),
  include "src/release/release-0.108.typ",
))
#document("release/release-0.109.html", page-shell(
  title: "Release 0.109 — Trino docs",
  css: "../trino.css",
  nav: nav-for("release/release-0.109"),
  include "src/release/release-0.109.typ",
))
#document("release/release-0.110.html", page-shell(
  title: "Release 0.110 — Trino docs",
  css: "../trino.css",
  nav: nav-for("release/release-0.110"),
  include "src/release/release-0.110.typ",
))
#document("release/release-0.111.html", page-shell(
  title: "Release 0.111 — Trino docs",
  css: "../trino.css",
  nav: nav-for("release/release-0.111"),
  include "src/release/release-0.111.typ",
))
#document("release/release-0.112.html", page-shell(
  title: "Release 0.112 — Trino docs",
  css: "../trino.css",
  nav: nav-for("release/release-0.112"),
  include "src/release/release-0.112.typ",
))
#document("release/release-0.113.html", page-shell(
  title: "Release 0.113 — Trino docs",
  css: "../trino.css",
  nav: nav-for("release/release-0.113"),
  include "src/release/release-0.113.typ",
))
#document("release/release-0.114.html", page-shell(
  title: "Release 0.114 — Trino docs",
  css: "../trino.css",
  nav: nav-for("release/release-0.114"),
  include "src/release/release-0.114.typ",
))
#document("release/release-0.115.html", page-shell(
  title: "Release 0.115 — Trino docs",
  css: "../trino.css",
  nav: nav-for("release/release-0.115"),
  include "src/release/release-0.115.typ",
))
#document("release/release-0.116.html", page-shell(
  title: "Release 0.116 — Trino docs",
  css: "../trino.css",
  nav: nav-for("release/release-0.116"),
  include "src/release/release-0.116.typ",
))
#document("release/release-0.117.html", page-shell(
  title: "Release 0.117 — Trino docs",
  css: "../trino.css",
  nav: nav-for("release/release-0.117"),
  include "src/release/release-0.117.typ",
))
#document("release/release-0.118.html", page-shell(
  title: "Release 0.118 — Trino docs",
  css: "../trino.css",
  nav: nav-for("release/release-0.118"),
  include "src/release/release-0.118.typ",
))
#document("release/release-0.119.html", page-shell(
  title: "Release 0.119 — Trino docs",
  css: "../trino.css",
  nav: nav-for("release/release-0.119"),
  include "src/release/release-0.119.typ",
))
#document("release/release-0.120.html", page-shell(
  title: "Release 0.120 — Trino docs",
  css: "../trino.css",
  nav: nav-for("release/release-0.120"),
  include "src/release/release-0.120.typ",
))
#document("release/release-0.121.html", page-shell(
  title: "Release 0.121 — Trino docs",
  css: "../trino.css",
  nav: nav-for("release/release-0.121"),
  include "src/release/release-0.121.typ",
))
#document("release/release-0.122.html", page-shell(
  title: "Release 0.122 — Trino docs",
  css: "../trino.css",
  nav: nav-for("release/release-0.122"),
  include "src/release/release-0.122.typ",
))
#document("release/release-0.123.html", page-shell(
  title: "Release 0.123 — Trino docs",
  css: "../trino.css",
  nav: nav-for("release/release-0.123"),
  include "src/release/release-0.123.typ",
))
#document("release/release-0.124.html", page-shell(
  title: "Release 0.124 — Trino docs",
  css: "../trino.css",
  nav: nav-for("release/release-0.124"),
  include "src/release/release-0.124.typ",
))
#document("release/release-0.125.html", page-shell(
  title: "Release 0.125 — Trino docs",
  css: "../trino.css",
  nav: nav-for("release/release-0.125"),
  include "src/release/release-0.125.typ",
))
#document("release/release-0.126.html", page-shell(
  title: "Release 0.126 — Trino docs",
  css: "../trino.css",
  nav: nav-for("release/release-0.126"),
  include "src/release/release-0.126.typ",
))
#document("release/release-0.127.html", page-shell(
  title: "Release 0.127 — Trino docs",
  css: "../trino.css",
  nav: nav-for("release/release-0.127"),
  include "src/release/release-0.127.typ",
))
#document("release/release-0.128.html", page-shell(
  title: "Release 0.128 — Trino docs",
  css: "../trino.css",
  nav: nav-for("release/release-0.128"),
  include "src/release/release-0.128.typ",
))
#document("release/release-0.129.html", page-shell(
  title: "Release 0.129 — Trino docs",
  css: "../trino.css",
  nav: nav-for("release/release-0.129"),
  include "src/release/release-0.129.typ",
))
#document("release/release-0.130.html", page-shell(
  title: "Release 0.130 — Trino docs",
  css: "../trino.css",
  nav: nav-for("release/release-0.130"),
  include "src/release/release-0.130.typ",
))
#document("release/release-0.131.html", page-shell(
  title: "Release 0.131 — Trino docs",
  css: "../trino.css",
  nav: nav-for("release/release-0.131"),
  include "src/release/release-0.131.typ",
))
#document("release/release-0.132.html", page-shell(
  title: "Release 0.132 — Trino docs",
  css: "../trino.css",
  nav: nav-for("release/release-0.132"),
  include "src/release/release-0.132.typ",
))
#document("release/release-0.133.html", page-shell(
  title: "Release 0.133 — Trino docs",
  css: "../trino.css",
  nav: nav-for("release/release-0.133"),
  include "src/release/release-0.133.typ",
))
#document("release/release-0.134.html", page-shell(
  title: "Release 0.134 — Trino docs",
  css: "../trino.css",
  nav: nav-for("release/release-0.134"),
  include "src/release/release-0.134.typ",
))
#document("release/release-0.135.html", page-shell(
  title: "Release 0.135 — Trino docs",
  css: "../trino.css",
  nav: nav-for("release/release-0.135"),
  include "src/release/release-0.135.typ",
))
#document("release/release-0.136.html", page-shell(
  title: "Release 0.136 — Trino docs",
  css: "../trino.css",
  nav: nav-for("release/release-0.136"),
  include "src/release/release-0.136.typ",
))
#document("release/release-0.137.html", page-shell(
  title: "Release 0.137 — Trino docs",
  css: "../trino.css",
  nav: nav-for("release/release-0.137"),
  include "src/release/release-0.137.typ",
))
#document("release/release-0.138.html", page-shell(
  title: "Release 0.138 — Trino docs",
  css: "../trino.css",
  nav: nav-for("release/release-0.138"),
  include "src/release/release-0.138.typ",
))
#document("release/release-0.139.html", page-shell(
  title: "Release 0.139 — Trino docs",
  css: "../trino.css",
  nav: nav-for("release/release-0.139"),
  include "src/release/release-0.139.typ",
))
#document("release/release-0.140.html", page-shell(
  title: "Release 0.140 — Trino docs",
  css: "../trino.css",
  nav: nav-for("release/release-0.140"),
  include "src/release/release-0.140.typ",
))
#document("release/release-0.141.html", page-shell(
  title: "Release 0.141 — Trino docs",
  css: "../trino.css",
  nav: nav-for("release/release-0.141"),
  include "src/release/release-0.141.typ",
))
#document("release/release-0.142.html", page-shell(
  title: "Release 0.142 — Trino docs",
  css: "../trino.css",
  nav: nav-for("release/release-0.142"),
  include "src/release/release-0.142.typ",
))
#document("release/release-0.143.html", page-shell(
  title: "Release 0.143 — Trino docs",
  css: "../trino.css",
  nav: nav-for("release/release-0.143"),
  include "src/release/release-0.143.typ",
))
#document("release/release-0.144.html", page-shell(
  title: "Release 0.144 — Trino docs",
  css: "../trino.css",
  nav: nav-for("release/release-0.144"),
  include "src/release/release-0.144.typ",
))
#document("release/release-0.144.1.html", page-shell(
  title: "Release 0.144.1 — Trino docs",
  css: "../trino.css",
  nav: nav-for("release/release-0.144.1"),
  include "src/release/release-0.144.1.typ",
))
#document("release/release-0.144.2.html", page-shell(
  title: "Release 0.144.2 — Trino docs",
  css: "../trino.css",
  nav: nav-for("release/release-0.144.2"),
  include "src/release/release-0.144.2.typ",
))
#document("release/release-0.144.3.html", page-shell(
  title: "Release 0.144.3 — Trino docs",
  css: "../trino.css",
  nav: nav-for("release/release-0.144.3"),
  include "src/release/release-0.144.3.typ",
))
#document("release/release-0.144.4.html", page-shell(
  title: "Release 0.144.4 — Trino docs",
  css: "../trino.css",
  nav: nav-for("release/release-0.144.4"),
  include "src/release/release-0.144.4.typ",
))
#document("release/release-0.144.5.html", page-shell(
  title: "Release 0.144.5 — Trino docs",
  css: "../trino.css",
  nav: nav-for("release/release-0.144.5"),
  include "src/release/release-0.144.5.typ",
))
#document("release/release-0.144.6.html", page-shell(
  title: "Release 0.144.6 — Trino docs",
  css: "../trino.css",
  nav: nav-for("release/release-0.144.6"),
  include "src/release/release-0.144.6.typ",
))
#document("release/release-0.144.7.html", page-shell(
  title: "Release 0.144.7 — Trino docs",
  css: "../trino.css",
  nav: nav-for("release/release-0.144.7"),
  include "src/release/release-0.144.7.typ",
))
#document("release/release-0.145.html", page-shell(
  title: "Release 0.145 — Trino docs",
  css: "../trino.css",
  nav: nav-for("release/release-0.145"),
  include "src/release/release-0.145.typ",
))
#document("release/release-0.146.html", page-shell(
  title: "Release 0.146 — Trino docs",
  css: "../trino.css",
  nav: nav-for("release/release-0.146"),
  include "src/release/release-0.146.typ",
))
#document("release/release-0.147.html", page-shell(
  title: "Release 0.147 — Trino docs",
  css: "../trino.css",
  nav: nav-for("release/release-0.147"),
  include "src/release/release-0.147.typ",
))
#document("release/release-0.148.html", page-shell(
  title: "Release 0.148 — Trino docs",
  css: "../trino.css",
  nav: nav-for("release/release-0.148"),
  include "src/release/release-0.148.typ",
))
#document("release/release-0.149.html", page-shell(
  title: "Release 0.149 — Trino docs",
  css: "../trino.css",
  nav: nav-for("release/release-0.149"),
  include "src/release/release-0.149.typ",
))
#document("release/release-0.150.html", page-shell(
  title: "Release 0.150 — Trino docs",
  css: "../trino.css",
  nav: nav-for("release/release-0.150"),
  include "src/release/release-0.150.typ",
))
#document("release/release-0.151.html", page-shell(
  title: "Release 0.151 — Trino docs",
  css: "../trino.css",
  nav: nav-for("release/release-0.151"),
  include "src/release/release-0.151.typ",
))
#document("release/release-0.152.html", page-shell(
  title: "Release 0.152 — Trino docs",
  css: "../trino.css",
  nav: nav-for("release/release-0.152"),
  include "src/release/release-0.152.typ",
))
#document("release/release-0.152.1.html", page-shell(
  title: "Release 0.152.1 — Trino docs",
  css: "../trino.css",
  nav: nav-for("release/release-0.152.1"),
  include "src/release/release-0.152.1.typ",
))
#document("release/release-0.152.2.html", page-shell(
  title: "Release 0.152.2 — Trino docs",
  css: "../trino.css",
  nav: nav-for("release/release-0.152.2"),
  include "src/release/release-0.152.2.typ",
))
#document("release/release-0.152.3.html", page-shell(
  title: "Release 0.152.3 — Trino docs",
  css: "../trino.css",
  nav: nav-for("release/release-0.152.3"),
  include "src/release/release-0.152.3.typ",
))
#document("release/release-0.153.html", page-shell(
  title: "Release 0.153 — Trino docs",
  css: "../trino.css",
  nav: nav-for("release/release-0.153"),
  include "src/release/release-0.153.typ",
))
#document("release/release-0.154.html", page-shell(
  title: "Release 0.154 — Trino docs",
  css: "../trino.css",
  nav: nav-for("release/release-0.154"),
  include "src/release/release-0.154.typ",
))
#document("release/release-0.155.html", page-shell(
  title: "Release 0.155 — Trino docs",
  css: "../trino.css",
  nav: nav-for("release/release-0.155"),
  include "src/release/release-0.155.typ",
))
#document("release/release-0.156.html", page-shell(
  title: "Release 0.156 — Trino docs",
  css: "../trino.css",
  nav: nav-for("release/release-0.156"),
  include "src/release/release-0.156.typ",
))
#document("release/release-0.157.html", page-shell(
  title: "Release 0.157 — Trino docs",
  css: "../trino.css",
  nav: nav-for("release/release-0.157"),
  include "src/release/release-0.157.typ",
))
#document("release/release-0.157.1.html", page-shell(
  title: "Release 0.157.1 — Trino docs",
  css: "../trino.css",
  nav: nav-for("release/release-0.157.1"),
  include "src/release/release-0.157.1.typ",
))
#document("release/release-0.158.html", page-shell(
  title: "Release 0.158 — Trino docs",
  css: "../trino.css",
  nav: nav-for("release/release-0.158"),
  include "src/release/release-0.158.typ",
))
#document("release/release-0.159.html", page-shell(
  title: "Release 0.159 — Trino docs",
  css: "../trino.css",
  nav: nav-for("release/release-0.159"),
  include "src/release/release-0.159.typ",
))
#document("release/release-0.160.html", page-shell(
  title: "Release 0.160 — Trino docs",
  css: "../trino.css",
  nav: nav-for("release/release-0.160"),
  include "src/release/release-0.160.typ",
))
#document("release/release-0.161.html", page-shell(
  title: "Release 0.161 — Trino docs",
  css: "../trino.css",
  nav: nav-for("release/release-0.161"),
  include "src/release/release-0.161.typ",
))
#document("release/release-0.162.html", page-shell(
  title: "Release 0.162 — Trino docs",
  css: "../trino.css",
  nav: nav-for("release/release-0.162"),
  include "src/release/release-0.162.typ",
))
#document("release/release-0.163.html", page-shell(
  title: "Release 0.163 — Trino docs",
  css: "../trino.css",
  nav: nav-for("release/release-0.163"),
  include "src/release/release-0.163.typ",
))
#document("release/release-0.164.html", page-shell(
  title: "Release 0.164 — Trino docs",
  css: "../trino.css",
  nav: nav-for("release/release-0.164"),
  include "src/release/release-0.164.typ",
))
#document("release/release-0.165.html", page-shell(
  title: "Release 0.165 — Trino docs",
  css: "../trino.css",
  nav: nav-for("release/release-0.165"),
  include "src/release/release-0.165.typ",
))
#document("release/release-0.166.html", page-shell(
  title: "Release 0.166 — Trino docs",
  css: "../trino.css",
  nav: nav-for("release/release-0.166"),
  include "src/release/release-0.166.typ",
))
#document("release/release-0.167.html", page-shell(
  title: "Release 0.167 — Trino docs",
  css: "../trino.css",
  nav: nav-for("release/release-0.167"),
  include "src/release/release-0.167.typ",
))
#document("release/release-0.168.html", page-shell(
  title: "Release 0.168 — Trino docs",
  css: "../trino.css",
  nav: nav-for("release/release-0.168"),
  include "src/release/release-0.168.typ",
))
#document("release/release-0.169.html", page-shell(
  title: "Release 0.169 — Trino docs",
  css: "../trino.css",
  nav: nav-for("release/release-0.169"),
  include "src/release/release-0.169.typ",
))
#document("release/release-0.170.html", page-shell(
  title: "Release 0.170 — Trino docs",
  css: "../trino.css",
  nav: nav-for("release/release-0.170"),
  include "src/release/release-0.170.typ",
))
#document("release/release-0.171.html", page-shell(
  title: "Release 0.171 — Trino docs",
  css: "../trino.css",
  nav: nav-for("release/release-0.171"),
  include "src/release/release-0.171.typ",
))
#document("release/release-0.172.html", page-shell(
  title: "Release 0.172 — Trino docs",
  css: "../trino.css",
  nav: nav-for("release/release-0.172"),
  include "src/release/release-0.172.typ",
))
#document("release/release-0.173.html", page-shell(
  title: "Release 0.173 — Trino docs",
  css: "../trino.css",
  nav: nav-for("release/release-0.173"),
  include "src/release/release-0.173.typ",
))
#document("release/release-0.174.html", page-shell(
  title: "Release 0.174 — Trino docs",
  css: "../trino.css",
  nav: nav-for("release/release-0.174"),
  include "src/release/release-0.174.typ",
))
#document("release/release-0.175.html", page-shell(
  title: "Release 0.175 — Trino docs",
  css: "../trino.css",
  nav: nav-for("release/release-0.175"),
  include "src/release/release-0.175.typ",
))
#document("release/release-0.176.html", page-shell(
  title: "Release 0.176 — Trino docs",
  css: "../trino.css",
  nav: nav-for("release/release-0.176"),
  include "src/release/release-0.176.typ",
))
#document("release/release-0.177.html", page-shell(
  title: "Release 0.177 — Trino docs",
  css: "../trino.css",
  nav: nav-for("release/release-0.177"),
  include "src/release/release-0.177.typ",
))
#document("release/release-0.178.html", page-shell(
  title: "Release 0.178 — Trino docs",
  css: "../trino.css",
  nav: nav-for("release/release-0.178"),
  include "src/release/release-0.178.typ",
))
#document("release/release-0.179.html", page-shell(
  title: "Release 0.179 — Trino docs",
  css: "../trino.css",
  nav: nav-for("release/release-0.179"),
  include "src/release/release-0.179.typ",
))
#document("release/release-0.180.html", page-shell(
  title: "Release 0.180 — Trino docs",
  css: "../trino.css",
  nav: nav-for("release/release-0.180"),
  include "src/release/release-0.180.typ",
))
#document("release/release-0.181.html", page-shell(
  title: "Release 0.181 — Trino docs",
  css: "../trino.css",
  nav: nav-for("release/release-0.181"),
  include "src/release/release-0.181.typ",
))
#document("release/release-0.182.html", page-shell(
  title: "Release 0.182 — Trino docs",
  css: "../trino.css",
  nav: nav-for("release/release-0.182"),
  include "src/release/release-0.182.typ",
))
#document("release/release-0.183.html", page-shell(
  title: "Release 0.183 — Trino docs",
  css: "../trino.css",
  nav: nav-for("release/release-0.183"),
  include "src/release/release-0.183.typ",
))
#document("release/release-0.184.html", page-shell(
  title: "Release 0.184 — Trino docs",
  css: "../trino.css",
  nav: nav-for("release/release-0.184"),
  include "src/release/release-0.184.typ",
))
#document("release/release-0.185.html", page-shell(
  title: "Release 0.185 — Trino docs",
  css: "../trino.css",
  nav: nav-for("release/release-0.185"),
  include "src/release/release-0.185.typ",
))
#document("release/release-0.186.html", page-shell(
  title: "Release 0.186 — Trino docs",
  css: "../trino.css",
  nav: nav-for("release/release-0.186"),
  include "src/release/release-0.186.typ",
))
#document("release/release-0.187.html", page-shell(
  title: "Release 0.187 — Trino docs",
  css: "../trino.css",
  nav: nav-for("release/release-0.187"),
  include "src/release/release-0.187.typ",
))
#document("release/release-0.188.html", page-shell(
  title: "Release 0.188 — Trino docs",
  css: "../trino.css",
  nav: nav-for("release/release-0.188"),
  include "src/release/release-0.188.typ",
))
#document("release/release-0.189.html", page-shell(
  title: "Release 0.189 — Trino docs",
  css: "../trino.css",
  nav: nav-for("release/release-0.189"),
  include "src/release/release-0.189.typ",
))
#document("release/release-0.190.html", page-shell(
  title: "Release 0.190 — Trino docs",
  css: "../trino.css",
  nav: nav-for("release/release-0.190"),
  include "src/release/release-0.190.typ",
))
#document("release/release-0.191.html", page-shell(
  title: "Release 0.191 — Trino docs",
  css: "../trino.css",
  nav: nav-for("release/release-0.191"),
  include "src/release/release-0.191.typ",
))
#document("release/release-0.192.html", page-shell(
  title: "Release 0.192 — Trino docs",
  css: "../trino.css",
  nav: nav-for("release/release-0.192"),
  include "src/release/release-0.192.typ",
))
#document("release/release-0.193.html", page-shell(
  title: "Release 0.193 — Trino docs",
  css: "../trino.css",
  nav: nav-for("release/release-0.193"),
  include "src/release/release-0.193.typ",
))
#document("release/release-0.194.html", page-shell(
  title: "Release 0.194 — Trino docs",
  css: "../trino.css",
  nav: nav-for("release/release-0.194"),
  include "src/release/release-0.194.typ",
))
#document("release/release-0.195.html", page-shell(
  title: "Release 0.195 — Trino docs",
  css: "../trino.css",
  nav: nav-for("release/release-0.195"),
  include "src/release/release-0.195.typ",
))
#document("release/release-0.196.html", page-shell(
  title: "Release 0.196 — Trino docs",
  css: "../trino.css",
  nav: nav-for("release/release-0.196"),
  include "src/release/release-0.196.typ",
))
#document("release/release-0.197.html", page-shell(
  title: "Release 0.197 — Trino docs",
  css: "../trino.css",
  nav: nav-for("release/release-0.197"),
  include "src/release/release-0.197.typ",
))
#document("release/release-0.198.html", page-shell(
  title: "Release 0.198 — Trino docs",
  css: "../trino.css",
  nav: nav-for("release/release-0.198"),
  include "src/release/release-0.198.typ",
))
#document("release/release-0.199.html", page-shell(
  title: "Release 0.199 — Trino docs",
  css: "../trino.css",
  nav: nav-for("release/release-0.199"),
  include "src/release/release-0.199.typ",
))
#document("release/release-0.200.html", page-shell(
  title: "Release 0.200 — Trino docs",
  css: "../trino.css",
  nav: nav-for("release/release-0.200"),
  include "src/release/release-0.200.typ",
))
#document("release/release-0.201.html", page-shell(
  title: "Release 0.201 — Trino docs",
  css: "../trino.css",
  nav: nav-for("release/release-0.201"),
  include "src/release/release-0.201.typ",
))
#document("release/release-0.202.html", page-shell(
  title: "Release 0.202 — Trino docs",
  css: "../trino.css",
  nav: nav-for("release/release-0.202"),
  include "src/release/release-0.202.typ",
))
#document("release/release-0.203.html", page-shell(
  title: "Release 0.203 — Trino docs",
  css: "../trino.css",
  nav: nav-for("release/release-0.203"),
  include "src/release/release-0.203.typ",
))
#document("release/release-0.204.html", page-shell(
  title: "Release 0.204 — Trino docs",
  css: "../trino.css",
  nav: nav-for("release/release-0.204"),
  include "src/release/release-0.204.typ",
))
#document("release/release-0.205.html", page-shell(
  title: "Release 0.205 — Trino docs",
  css: "../trino.css",
  nav: nav-for("release/release-0.205"),
  include "src/release/release-0.205.typ",
))
#document("release/release-0.206.html", page-shell(
  title: "Release 0.206 — Trino docs",
  css: "../trino.css",
  nav: nav-for("release/release-0.206"),
  include "src/release/release-0.206.typ",
))
#document("release/release-0.207.html", page-shell(
  title: "Release 0.207 — Trino docs",
  css: "../trino.css",
  nav: nav-for("release/release-0.207"),
  include "src/release/release-0.207.typ",
))
#document("release/release-0.208.html", page-shell(
  title: "Release 0.208 — Trino docs",
  css: "../trino.css",
  nav: nav-for("release/release-0.208"),
  include "src/release/release-0.208.typ",
))
#document("release/release-0.209.html", page-shell(
  title: "Release 0.209 — Trino docs",
  css: "../trino.css",
  nav: nav-for("release/release-0.209"),
  include "src/release/release-0.209.typ",
))
#document("release/release-0.210.html", page-shell(
  title: "Release 0.210 — Trino docs",
  css: "../trino.css",
  nav: nav-for("release/release-0.210"),
  include "src/release/release-0.210.typ",
))
#document("release/release-0.211.html", page-shell(
  title: "Release 0.211 — Trino docs",
  css: "../trino.css",
  nav: nav-for("release/release-0.211"),
  include "src/release/release-0.211.typ",
))
#document("release/release-0.212.html", page-shell(
  title: "Release 0.212 — Trino docs",
  css: "../trino.css",
  nav: nav-for("release/release-0.212"),
  include "src/release/release-0.212.typ",
))
#document("release/release-0.213.html", page-shell(
  title: "Release 0.213 — Trino docs",
  css: "../trino.css",
  nav: nav-for("release/release-0.213"),
  include "src/release/release-0.213.typ",
))
#document("release/release-0.214.html", page-shell(
  title: "Release 0.214 — Trino docs",
  css: "../trino.css",
  nav: nav-for("release/release-0.214"),
  include "src/release/release-0.214.typ",
))
#document("release/release-0.215.html", page-shell(
  title: "Release 0.215 — Trino docs",
  css: "../trino.css",
  nav: nav-for("release/release-0.215"),
  include "src/release/release-0.215.typ",
))
#document("release/release-0.54.html", page-shell(
  title: "Release 0.54 — Trino docs",
  css: "../trino.css",
  nav: nav-for("release/release-0.54"),
  include "src/release/release-0.54.typ",
))
#document("release/release-0.55.html", page-shell(
  title: "Release 0.55 — Trino docs",
  css: "../trino.css",
  nav: nav-for("release/release-0.55"),
  include "src/release/release-0.55.typ",
))
#document("release/release-0.56.html", page-shell(
  title: "Release 0.56 — Trino docs",
  css: "../trino.css",
  nav: nav-for("release/release-0.56"),
  include "src/release/release-0.56.typ",
))
#document("release/release-0.57.html", page-shell(
  title: "Release 0.57 — Trino docs",
  css: "../trino.css",
  nav: nav-for("release/release-0.57"),
  include "src/release/release-0.57.typ",
))
#document("release/release-0.58.html", page-shell(
  title: "Release 0.58 — Trino docs",
  css: "../trino.css",
  nav: nav-for("release/release-0.58"),
  include "src/release/release-0.58.typ",
))
#document("release/release-0.59.html", page-shell(
  title: "Release 0.59 — Trino docs",
  css: "../trino.css",
  nav: nav-for("release/release-0.59"),
  include "src/release/release-0.59.typ",
))
#document("release/release-0.60.html", page-shell(
  title: "Release 0.60 — Trino docs",
  css: "../trino.css",
  nav: nav-for("release/release-0.60"),
  include "src/release/release-0.60.typ",
))
#document("release/release-0.61.html", page-shell(
  title: "Release 0.61 — Trino docs",
  css: "../trino.css",
  nav: nav-for("release/release-0.61"),
  include "src/release/release-0.61.typ",
))
#document("release/release-0.62.html", page-shell(
  title: "Release 0.62 — Trino docs",
  css: "../trino.css",
  nav: nav-for("release/release-0.62"),
  include "src/release/release-0.62.typ",
))
#document("release/release-0.63.html", page-shell(
  title: "Release 0.63 — Trino docs",
  css: "../trino.css",
  nav: nav-for("release/release-0.63"),
  include "src/release/release-0.63.typ",
))
#document("release/release-0.64.html", page-shell(
  title: "Release 0.64 — Trino docs",
  css: "../trino.css",
  nav: nav-for("release/release-0.64"),
  include "src/release/release-0.64.typ",
))
#document("release/release-0.65.html", page-shell(
  title: "Release 0.65 — Trino docs",
  css: "../trino.css",
  nav: nav-for("release/release-0.65"),
  include "src/release/release-0.65.typ",
))
#document("release/release-0.66.html", page-shell(
  title: "Release 0.66 — Trino docs",
  css: "../trino.css",
  nav: nav-for("release/release-0.66"),
  include "src/release/release-0.66.typ",
))
#document("release/release-0.67.html", page-shell(
  title: "Release 0.67 — Trino docs",
  css: "../trino.css",
  nav: nav-for("release/release-0.67"),
  include "src/release/release-0.67.typ",
))
#document("release/release-0.68.html", page-shell(
  title: "Release 0.68 — Trino docs",
  css: "../trino.css",
  nav: nav-for("release/release-0.68"),
  include "src/release/release-0.68.typ",
))
#document("release/release-0.69.html", page-shell(
  title: "Release 0.69 — Trino docs",
  css: "../trino.css",
  nav: nav-for("release/release-0.69"),
  include "src/release/release-0.69.typ",
))
#document("release/release-0.70.html", page-shell(
  title: "Release 0.70 — Trino docs",
  css: "../trino.css",
  nav: nav-for("release/release-0.70"),
  include "src/release/release-0.70.typ",
))
#document("release/release-0.71.html", page-shell(
  title: "Release 0.71 — Trino docs",
  css: "../trino.css",
  nav: nav-for("release/release-0.71"),
  include "src/release/release-0.71.typ",
))
#document("release/release-0.72.html", page-shell(
  title: "Release 0.72 — Trino docs",
  css: "../trino.css",
  nav: nav-for("release/release-0.72"),
  include "src/release/release-0.72.typ",
))
#document("release/release-0.73.html", page-shell(
  title: "Release 0.73 — Trino docs",
  css: "../trino.css",
  nav: nav-for("release/release-0.73"),
  include "src/release/release-0.73.typ",
))
#document("release/release-0.74.html", page-shell(
  title: "Release 0.74 — Trino docs",
  css: "../trino.css",
  nav: nav-for("release/release-0.74"),
  include "src/release/release-0.74.typ",
))
#document("release/release-0.75.html", page-shell(
  title: "Release 0.75 — Trino docs",
  css: "../trino.css",
  nav: nav-for("release/release-0.75"),
  include "src/release/release-0.75.typ",
))
#document("release/release-0.76.html", page-shell(
  title: "Release 0.76 — Trino docs",
  css: "../trino.css",
  nav: nav-for("release/release-0.76"),
  include "src/release/release-0.76.typ",
))
#document("release/release-0.77.html", page-shell(
  title: "Release 0.77 — Trino docs",
  css: "../trino.css",
  nav: nav-for("release/release-0.77"),
  include "src/release/release-0.77.typ",
))
#document("release/release-0.78.html", page-shell(
  title: "Release 0.78 — Trino docs",
  css: "../trino.css",
  nav: nav-for("release/release-0.78"),
  include "src/release/release-0.78.typ",
))
#document("release/release-0.79.html", page-shell(
  title: "Release 0.79 — Trino docs",
  css: "../trino.css",
  nav: nav-for("release/release-0.79"),
  include "src/release/release-0.79.typ",
))
#document("release/release-0.80.html", page-shell(
  title: "Release 0.80 — Trino docs",
  css: "../trino.css",
  nav: nav-for("release/release-0.80"),
  include "src/release/release-0.80.typ",
))
#document("release/release-0.81.html", page-shell(
  title: "Release 0.81 — Trino docs",
  css: "../trino.css",
  nav: nav-for("release/release-0.81"),
  include "src/release/release-0.81.typ",
))
#document("release/release-0.82.html", page-shell(
  title: "Release 0.82 — Trino docs",
  css: "../trino.css",
  nav: nav-for("release/release-0.82"),
  include "src/release/release-0.82.typ",
))
#document("release/release-0.83.html", page-shell(
  title: "Release 0.83 — Trino docs",
  css: "../trino.css",
  nav: nav-for("release/release-0.83"),
  include "src/release/release-0.83.typ",
))
#document("release/release-0.84.html", page-shell(
  title: "Release 0.84 — Trino docs",
  css: "../trino.css",
  nav: nav-for("release/release-0.84"),
  include "src/release/release-0.84.typ",
))
#document("release/release-0.85.html", page-shell(
  title: "Release 0.85 — Trino docs",
  css: "../trino.css",
  nav: nav-for("release/release-0.85"),
  include "src/release/release-0.85.typ",
))
#document("release/release-0.86.html", page-shell(
  title: "Release 0.86 — Trino docs",
  css: "../trino.css",
  nav: nav-for("release/release-0.86"),
  include "src/release/release-0.86.typ",
))
#document("release/release-0.87.html", page-shell(
  title: "Release 0.87 — Trino docs",
  css: "../trino.css",
  nav: nav-for("release/release-0.87"),
  include "src/release/release-0.87.typ",
))
#document("release/release-0.88.html", page-shell(
  title: "Release 0.88 — Trino docs",
  css: "../trino.css",
  nav: nav-for("release/release-0.88"),
  include "src/release/release-0.88.typ",
))
#document("release/release-0.89.html", page-shell(
  title: "Release 0.89 — Trino docs",
  css: "../trino.css",
  nav: nav-for("release/release-0.89"),
  include "src/release/release-0.89.typ",
))
#document("release/release-0.90.html", page-shell(
  title: "Release 0.90 — Trino docs",
  css: "../trino.css",
  nav: nav-for("release/release-0.90"),
  include "src/release/release-0.90.typ",
))
#document("release/release-0.91.html", page-shell(
  title: "Release 0.91 — Trino docs",
  css: "../trino.css",
  nav: nav-for("release/release-0.91"),
  include "src/release/release-0.91.typ",
))
#document("release/release-0.92.html", page-shell(
  title: "Release 0.92 — Trino docs",
  css: "../trino.css",
  nav: nav-for("release/release-0.92"),
  include "src/release/release-0.92.typ",
))
#document("release/release-0.93.html", page-shell(
  title: "Release 0.93 — Trino docs",
  css: "../trino.css",
  nav: nav-for("release/release-0.93"),
  include "src/release/release-0.93.typ",
))
#document("release/release-0.94.html", page-shell(
  title: "Release 0.94 — Trino docs",
  css: "../trino.css",
  nav: nav-for("release/release-0.94"),
  include "src/release/release-0.94.typ",
))
#document("release/release-0.95.html", page-shell(
  title: "Release 0.95 — Trino docs",
  css: "../trino.css",
  nav: nav-for("release/release-0.95"),
  include "src/release/release-0.95.typ",
))
#document("release/release-0.96.html", page-shell(
  title: "Release 0.96 — Trino docs",
  css: "../trino.css",
  nav: nav-for("release/release-0.96"),
  include "src/release/release-0.96.typ",
))
#document("release/release-0.97.html", page-shell(
  title: "Release 0.97 — Trino docs",
  css: "../trino.css",
  nav: nav-for("release/release-0.97"),
  include "src/release/release-0.97.typ",
))
#document("release/release-0.98.html", page-shell(
  title: "Release 0.98 — Trino docs",
  css: "../trino.css",
  nav: nav-for("release/release-0.98"),
  include "src/release/release-0.98.typ",
))
#document("release/release-0.99.html", page-shell(
  title: "Release 0.99 — Trino docs",
  css: "../trino.css",
  nav: nav-for("release/release-0.99"),
  include "src/release/release-0.99.typ",
))
#document("release/release-300.html", page-shell(
  title: "Release 300 (22 Jan 2019) — Trino docs",
  css: "../trino.css",
  nav: nav-for("release/release-300"),
  include "src/release/release-300.typ",
))
#document("release/release-301.html", page-shell(
  title: "Release 301 (31 Jan 2019) — Trino docs",
  css: "../trino.css",
  nav: nav-for("release/release-301"),
  include "src/release/release-301.typ",
))
#document("release/release-302.html", page-shell(
  title: "Release 302 (6 Feb 2019) — Trino docs",
  css: "../trino.css",
  nav: nav-for("release/release-302"),
  include "src/release/release-302.typ",
))
#document("release/release-303.html", page-shell(
  title: "Release 303 (13 Feb 2019) — Trino docs",
  css: "../trino.css",
  nav: nav-for("release/release-303"),
  include "src/release/release-303.typ",
))
#document("release/release-304.html", page-shell(
  title: "Release 304 (27 Feb 2019) — Trino docs",
  css: "../trino.css",
  nav: nav-for("release/release-304"),
  include "src/release/release-304.typ",
))
#document("release/release-305.html", page-shell(
  title: "Release 305 (7 Mar 2019) — Trino docs",
  css: "../trino.css",
  nav: nav-for("release/release-305"),
  include "src/release/release-305.typ",
))
#document("release/release-306.html", page-shell(
  title: "Release 306 (16 Mar 2019) — Trino docs",
  css: "../trino.css",
  nav: nav-for("release/release-306"),
  include "src/release/release-306.typ",
))
#document("release/release-307.html", page-shell(
  title: "Release 307 (3 Apr 2019) — Trino docs",
  css: "../trino.css",
  nav: nav-for("release/release-307"),
  include "src/release/release-307.typ",
))
#document("release/release-308.html", page-shell(
  title: "Release 308 (11 Apr 2019) — Trino docs",
  css: "../trino.css",
  nav: nav-for("release/release-308"),
  include "src/release/release-308.typ",
))
#document("release/release-309.html", page-shell(
  title: "Release 309 (25 Apr 2019) — Trino docs",
  css: "../trino.css",
  nav: nav-for("release/release-309"),
  include "src/release/release-309.typ",
))
#document("release/release-310.html", page-shell(
  title: "Release 310 (3 May 2019) — Trino docs",
  css: "../trino.css",
  nav: nav-for("release/release-310"),
  include "src/release/release-310.typ",
))
#document("release/release-311.html", page-shell(
  title: "Release 311 (14 May 2019) — Trino docs",
  css: "../trino.css",
  nav: nav-for("release/release-311"),
  include "src/release/release-311.typ",
))
#document("release/release-312.html", page-shell(
  title: "Release 312 (29 May 2019) — Trino docs",
  css: "../trino.css",
  nav: nav-for("release/release-312"),
  include "src/release/release-312.typ",
))
#document("release/release-313.html", page-shell(
  title: "Release 313 (31 May 2019) — Trino docs",
  css: "../trino.css",
  nav: nav-for("release/release-313"),
  include "src/release/release-313.typ",
))
#document("release/release-314.html", page-shell(
  title: "Release 314 (7 Jun 2019) — Trino docs",
  css: "../trino.css",
  nav: nav-for("release/release-314"),
  include "src/release/release-314.typ",
))
#document("release/release-315.html", page-shell(
  title: "Release 315 (14 Jun 2019) — Trino docs",
  css: "../trino.css",
  nav: nav-for("release/release-315"),
  include "src/release/release-315.typ",
))
#document("release/release-316.html", page-shell(
  title: "Release 316 (8 Jul 2019) — Trino docs",
  css: "../trino.css",
  nav: nav-for("release/release-316"),
  include "src/release/release-316.typ",
))
#document("release/release-317.html", page-shell(
  title: "Release 317 (1 Aug 2019) — Trino docs",
  css: "../trino.css",
  nav: nav-for("release/release-317"),
  include "src/release/release-317.typ",
))
#document("release/release-318.html", page-shell(
  title: "Release 318 (26 Aug 2019) — Trino docs",
  css: "../trino.css",
  nav: nav-for("release/release-318"),
  include "src/release/release-318.typ",
))
#document("release/release-319.html", page-shell(
  title: "Release 319 (22 Sep 2019) — Trino docs",
  css: "../trino.css",
  nav: nav-for("release/release-319"),
  include "src/release/release-319.typ",
))
#document("release/release-320.html", page-shell(
  title: "Release 320 (10 Oct 2019) — Trino docs",
  css: "../trino.css",
  nav: nav-for("release/release-320"),
  include "src/release/release-320.typ",
))
#document("release/release-321.html", page-shell(
  title: "Release 321 (15 Oct 2019) — Trino docs",
  css: "../trino.css",
  nav: nav-for("release/release-321"),
  include "src/release/release-321.typ",
))
#document("release/release-322.html", page-shell(
  title: "Release 322 (16 Oct 2019) — Trino docs",
  css: "../trino.css",
  nav: nav-for("release/release-322"),
  include "src/release/release-322.typ",
))
#document("release/release-323.html", page-shell(
  title: "Release 323 (23 Oct 2019) — Trino docs",
  css: "../trino.css",
  nav: nav-for("release/release-323"),
  include "src/release/release-323.typ",
))
#document("release/release-324.html", page-shell(
  title: "Release 324 (1 Nov 2019) — Trino docs",
  css: "../trino.css",
  nav: nav-for("release/release-324"),
  include "src/release/release-324.typ",
))
#document("release/release-325.html", page-shell(
  title: "Release 325 (14 Nov 2019) — Trino docs",
  css: "../trino.css",
  nav: nav-for("release/release-325"),
  include "src/release/release-325.typ",
))
#document("release/release-326.html", page-shell(
  title: "Release 326 (27 Nov 2019) — Trino docs",
  css: "../trino.css",
  nav: nav-for("release/release-326"),
  include "src/release/release-326.typ",
))
#document("release/release-327.html", page-shell(
  title: "Release 327 (20 Dec 2019) — Trino docs",
  css: "../trino.css",
  nav: nav-for("release/release-327"),
  include "src/release/release-327.typ",
))
#document("release/release-328.html", page-shell(
  title: "Release 328 (10 Jan 2020) — Trino docs",
  css: "../trino.css",
  nav: nav-for("release/release-328"),
  include "src/release/release-328.typ",
))
#document("release/release-329.html", page-shell(
  title: "Release 329 (23 Jan 2020) — Trino docs",
  css: "../trino.css",
  nav: nav-for("release/release-329"),
  include "src/release/release-329.typ",
))
#document("release/release-330.html", page-shell(
  title: "Release 330 (18 Feb 2020) — Trino docs",
  css: "../trino.css",
  nav: nav-for("release/release-330"),
  include "src/release/release-330.typ",
))
#document("release/release-331.html", page-shell(
  title: "Release 331 (16 Mar 2020) — Trino docs",
  css: "../trino.css",
  nav: nav-for("release/release-331"),
  include "src/release/release-331.typ",
))
#document("release/release-332.html", page-shell(
  title: "Release 332 (08 Apr 2020) — Trino docs",
  css: "../trino.css",
  nav: nav-for("release/release-332"),
  include "src/release/release-332.typ",
))
#document("release/release-333.html", page-shell(
  title: "Release 333 (04 May 2020) — Trino docs",
  css: "../trino.css",
  nav: nav-for("release/release-333"),
  include "src/release/release-333.typ",
))
#document("release/release-334.html", page-shell(
  title: "Release 334 (29 May 2020) — Trino docs",
  css: "../trino.css",
  nav: nav-for("release/release-334"),
  include "src/release/release-334.typ",
))
#document("release/release-335.html", page-shell(
  title: "Release 335 (14 Jun 2020) — Trino docs",
  css: "../trino.css",
  nav: nav-for("release/release-335"),
  include "src/release/release-335.typ",
))
#document("release/release-336.html", page-shell(
  title: "Release 336 (16 Jun 2020) — Trino docs",
  css: "../trino.css",
  nav: nav-for("release/release-336"),
  include "src/release/release-336.typ",
))
#document("release/release-337.html", page-shell(
  title: "Release 337 (25 Jun 2020) — Trino docs",
  css: "../trino.css",
  nav: nav-for("release/release-337"),
  include "src/release/release-337.typ",
))
#document("release/release-338.html", page-shell(
  title: "Release 338 (07 Jul 2020) — Trino docs",
  css: "../trino.css",
  nav: nav-for("release/release-338"),
  include "src/release/release-338.typ",
))
#document("release/release-339.html", page-shell(
  title: "Release 339 (21 Jul 2020) — Trino docs",
  css: "../trino.css",
  nav: nav-for("release/release-339"),
  include "src/release/release-339.typ",
))
#document("release/release-340.html", page-shell(
  title: "Release 340 (8 Aug 2020) — Trino docs",
  css: "../trino.css",
  nav: nav-for("release/release-340"),
  include "src/release/release-340.typ",
))
#document("release/release-341.html", page-shell(
  title: "Release 341 (8 Sep 2020) — Trino docs",
  css: "../trino.css",
  nav: nav-for("release/release-341"),
  include "src/release/release-341.typ",
))
#document("release/release-342.html", page-shell(
  title: "Release 342 (24 Sep 2020) — Trino docs",
  css: "../trino.css",
  nav: nav-for("release/release-342"),
  include "src/release/release-342.typ",
))
#document("release/release-343.html", page-shell(
  title: "Release 343 (25 Sep 2020) — Trino docs",
  css: "../trino.css",
  nav: nav-for("release/release-343"),
  include "src/release/release-343.typ",
))
#document("release/release-344.html", page-shell(
  title: "Release 344 (9 Oct 2020) — Trino docs",
  css: "../trino.css",
  nav: nav-for("release/release-344"),
  include "src/release/release-344.typ",
))
#document("release/release-345.html", page-shell(
  title: "Release 345 (23 Oct 2020) — Trino docs",
  css: "../trino.css",
  nav: nav-for("release/release-345"),
  include "src/release/release-345.typ",
))
#document("release/release-346.html", page-shell(
  title: "Release 346 (10 Nov 2020) — Trino docs",
  css: "../trino.css",
  nav: nav-for("release/release-346"),
  include "src/release/release-346.typ",
))
#document("release/release-347.html", page-shell(
  title: "Release 347 (25 Nov 2020) — Trino docs",
  css: "../trino.css",
  nav: nav-for("release/release-347"),
  include "src/release/release-347.typ",
))
#document("release/release-348.html", page-shell(
  title: "Release 348 (14 Dec 2020) — Trino docs",
  css: "../trino.css",
  nav: nav-for("release/release-348"),
  include "src/release/release-348.typ",
))
#document("release/release-349.html", page-shell(
  title: "Release 349 (28 Dec 2020) — Trino docs",
  css: "../trino.css",
  nav: nav-for("release/release-349"),
  include "src/release/release-349.typ",
))
#document("release/release-350.html", page-shell(
  title: "Release 350 (28 Dec 2020) — Trino docs",
  css: "../trino.css",
  nav: nav-for("release/release-350"),
  include "src/release/release-350.typ",
))
#document("release/release-351.html", page-shell(
  title: "Release 351 (3 Jan 2021) — Trino docs",
  css: "../trino.css",
  nav: nav-for("release/release-351"),
  include "src/release/release-351.typ",
))
#document("release/release-352.html", page-shell(
  title: "Release 352 (9 Feb 2021) — Trino docs",
  css: "../trino.css",
  nav: nav-for("release/release-352"),
  include "src/release/release-352.typ",
))
#document("release/release-353.html", page-shell(
  title: "Release 353 (5 Mar 2021) — Trino docs",
  css: "../trino.css",
  nav: nav-for("release/release-353"),
  include "src/release/release-353.typ",
))
#document("release/release-354.html", page-shell(
  title: "Release 354 (19 Mar 2021) — Trino docs",
  css: "../trino.css",
  nav: nav-for("release/release-354"),
  include "src/release/release-354.typ",
))
#document("release/release-355.html", page-shell(
  title: "Release 355 (8 Apr 2021) — Trino docs",
  css: "../trino.css",
  nav: nav-for("release/release-355"),
  include "src/release/release-355.typ",
))
#document("release/release-356.html", page-shell(
  title: "Release 356 (30 Apr 2021) — Trino docs",
  css: "../trino.css",
  nav: nav-for("release/release-356"),
  include "src/release/release-356.typ",
))
#document("release/release-357.html", page-shell(
  title: "Release 357 (21 May 2021) — Trino docs",
  css: "../trino.css",
  nav: nav-for("release/release-357"),
  include "src/release/release-357.typ",
))
#document("release/release-358.html", page-shell(
  title: "Release 358 (1 Jun 2021) — Trino docs",
  css: "../trino.css",
  nav: nav-for("release/release-358"),
  include "src/release/release-358.typ",
))
#document("release/release-359.html", page-shell(
  title: "Release 359 (1 Jul 2021) — Trino docs",
  css: "../trino.css",
  nav: nav-for("release/release-359"),
  include "src/release/release-359.typ",
))
#document("release/release-360.html", page-shell(
  title: "Release 360 (30 Jul 2021) — Trino docs",
  css: "../trino.css",
  nav: nav-for("release/release-360"),
  include "src/release/release-360.typ",
))
#document("release/release-361.html", page-shell(
  title: "Release 361 (27 Aug 2021) — Trino docs",
  css: "../trino.css",
  nav: nav-for("release/release-361"),
  include "src/release/release-361.typ",
))
#document("release/release-362.html", page-shell(
  title: "Release 362 (20 Sep 2021) — Trino docs",
  css: "../trino.css",
  nav: nav-for("release/release-362"),
  include "src/release/release-362.typ",
))
#document("release/release-363.html", page-shell(
  title: "Release 363 (6 Oct 2021) — Trino docs",
  css: "../trino.css",
  nav: nav-for("release/release-363"),
  include "src/release/release-363.typ",
))
#document("release/release-364.html", page-shell(
  title: "Release 364 (1 Nov 2021) — Trino docs",
  css: "../trino.css",
  nav: nav-for("release/release-364"),
  include "src/release/release-364.typ",
))
#document("release/release-365.html", page-shell(
  title: "Release 365 (3 Dec 2021) — Trino docs",
  css: "../trino.css",
  nav: nav-for("release/release-365"),
  include "src/release/release-365.typ",
))
#document("release/release-366.html", page-shell(
  title: "Release 366 (14 Dec 2021) — Trino docs",
  css: "../trino.css",
  nav: nav-for("release/release-366"),
  include "src/release/release-366.typ",
))
#document("release/release-367.html", page-shell(
  title: "Release 367 (22 Dec 2021) — Trino docs",
  css: "../trino.css",
  nav: nav-for("release/release-367"),
  include "src/release/release-367.typ",
))
#document("release/release-368.html", page-shell(
  title: "Release 368 (11 Jan 2022) — Trino docs",
  css: "../trino.css",
  nav: nav-for("release/release-368"),
  include "src/release/release-368.typ",
))
#document("release/release-369.html", page-shell(
  title: "Release 369 (24 Jan 2022) — Trino docs",
  css: "../trino.css",
  nav: nav-for("release/release-369"),
  include "src/release/release-369.typ",
))
#document("release/release-370.html", page-shell(
  title: "Release 370 (3 Feb 2022) — Trino docs",
  css: "../trino.css",
  nav: nav-for("release/release-370"),
  include "src/release/release-370.typ",
))
#document("release/release-371.html", page-shell(
  title: "Release 371 (16 Feb 2022) — Trino docs",
  css: "../trino.css",
  nav: nav-for("release/release-371"),
  include "src/release/release-371.typ",
))
#document("release/release-372.html", page-shell(
  title: "Release 372 (2 Mar 2022) — Trino docs",
  css: "../trino.css",
  nav: nav-for("release/release-372"),
  include "src/release/release-372.typ",
))
#document("release/release-373.html", page-shell(
  title: "Release 373 (9 Mar 2022) — Trino docs",
  css: "../trino.css",
  nav: nav-for("release/release-373"),
  include "src/release/release-373.typ",
))
#document("release/release-374.html", page-shell(
  title: "Release 374 (17 Mar 2022) — Trino docs",
  css: "../trino.css",
  nav: nav-for("release/release-374"),
  include "src/release/release-374.typ",
))
#document("release/release-375.html", page-shell(
  title: "Release 375 (28 Mar 2022) — Trino docs",
  css: "../trino.css",
  nav: nav-for("release/release-375"),
  include "src/release/release-375.typ",
))
#document("release/release-376.html", page-shell(
  title: "Release 376 (7 Apr 2022) — Trino docs",
  css: "../trino.css",
  nav: nav-for("release/release-376"),
  include "src/release/release-376.typ",
))
#document("release/release-377.html", page-shell(
  title: "Release 377 (13 Apr 2022) — Trino docs",
  css: "../trino.css",
  nav: nav-for("release/release-377"),
  include "src/release/release-377.typ",
))
#document("release/release-378.html", page-shell(
  title: "Release 378 (21 Apr 2022) — Trino docs",
  css: "../trino.css",
  nav: nav-for("release/release-378"),
  include "src/release/release-378.typ",
))
#document("release/release-379.html", page-shell(
  title: "Release 379 (28 Apr 2022) — Trino docs",
  css: "../trino.css",
  nav: nav-for("release/release-379"),
  include "src/release/release-379.typ",
))
#document("release/release-380.html", page-shell(
  title: "Release 380 (6 May 2022) — Trino docs",
  css: "../trino.css",
  nav: nav-for("release/release-380"),
  include "src/release/release-380.typ",
))
#document("release/release-381.html", page-shell(
  title: "Release 381 (16 May 2022) — Trino docs",
  css: "../trino.css",
  nav: nav-for("release/release-381"),
  include "src/release/release-381.typ",
))
#document("release/release-382.html", page-shell(
  title: "Release 382 (25 May 2022) — Trino docs",
  css: "../trino.css",
  nav: nav-for("release/release-382"),
  include "src/release/release-382.typ",
))
#document("release/release-383.html", page-shell(
  title: "Release 383 (1 Jun 2022) — Trino docs",
  css: "../trino.css",
  nav: nav-for("release/release-383"),
  include "src/release/release-383.typ",
))
#document("release/release-384.html", page-shell(
  title: "Release 384 (3 Jun 2022) — Trino docs",
  css: "../trino.css",
  nav: nav-for("release/release-384"),
  include "src/release/release-384.typ",
))
#document("release/release-385.html", page-shell(
  title: "Release 385 (8 Jun 2022) — Trino docs",
  css: "../trino.css",
  nav: nav-for("release/release-385"),
  include "src/release/release-385.typ",
))
#document("release/release-386.html", page-shell(
  title: "Release 386 (15 Jun 2022) — Trino docs",
  css: "../trino.css",
  nav: nav-for("release/release-386"),
  include "src/release/release-386.typ",
))
#document("release/release-387.html", page-shell(
  title: "Release 387 (22 Jun 2022) — Trino docs",
  css: "../trino.css",
  nav: nav-for("release/release-387"),
  include "src/release/release-387.typ",
))
#document("release/release-388.html", page-shell(
  title: "Release 388 (29 Jun 2022) — Trino docs",
  css: "../trino.css",
  nav: nav-for("release/release-388"),
  include "src/release/release-388.typ",
))
#document("release/release-389.html", page-shell(
  title: "Release 389 (7 Jul 2022) — Trino docs",
  css: "../trino.css",
  nav: nav-for("release/release-389"),
  include "src/release/release-389.typ",
))
#document("release/release-390.html", page-shell(
  title: "Release 390 (13 Jul 2022) — Trino docs",
  css: "../trino.css",
  nav: nav-for("release/release-390"),
  include "src/release/release-390.typ",
))
#document("release/release-391.html", page-shell(
  title: "Release 391 (22 Jul 2022) — Trino docs",
  css: "../trino.css",
  nav: nav-for("release/release-391"),
  include "src/release/release-391.typ",
))
#document("release/release-392.html", page-shell(
  title: "Release 392 (3 Aug 2022) — Trino docs",
  css: "../trino.css",
  nav: nav-for("release/release-392"),
  include "src/release/release-392.typ",
))
#document("release/release-393.html", page-shell(
  title: "Release 393 (17 Aug 2022) — Trino docs",
  css: "../trino.css",
  nav: nav-for("release/release-393"),
  include "src/release/release-393.typ",
))
#document("release/release-394.html", page-shell(
  title: "Release 394 (29 Aug 2022) — Trino docs",
  css: "../trino.css",
  nav: nav-for("release/release-394"),
  include "src/release/release-394.typ",
))
#document("release/release-395.html", page-shell(
  title: "Release 395 (7 Sep 2022) — Trino docs",
  css: "../trino.css",
  nav: nav-for("release/release-395"),
  include "src/release/release-395.typ",
))
#document("release/release-396.html", page-shell(
  title: "Release 396 (15 Sep 2022) — Trino docs",
  css: "../trino.css",
  nav: nav-for("release/release-396"),
  include "src/release/release-396.typ",
))
#document("release/release-397.html", page-shell(
  title: "Release 397 (21 Sep 2022) — Trino docs",
  css: "../trino.css",
  nav: nav-for("release/release-397"),
  include "src/release/release-397.typ",
))
#document("release/release-398.html", page-shell(
  title: "Release 398 (28 Sep 2022) — Trino docs",
  css: "../trino.css",
  nav: nav-for("release/release-398"),
  include "src/release/release-398.typ",
))
#document("release/release-399.html", page-shell(
  title: "Release 399 (6 Oct 2022) — Trino docs",
  css: "../trino.css",
  nav: nav-for("release/release-399"),
  include "src/release/release-399.typ",
))
#document("release/release-400.html", page-shell(
  title: "Release 400 (13 Oct 2022) — Trino docs",
  css: "../trino.css",
  nav: nav-for("release/release-400"),
  include "src/release/release-400.typ",
))
#document("release/release-401.html", page-shell(
  title: "Release 401 (26 Oct 2022) — Trino docs",
  css: "../trino.css",
  nav: nav-for("release/release-401"),
  include "src/release/release-401.typ",
))
#document("release/release-402.html", page-shell(
  title: "Release 402 (2 Nov 2022) — Trino docs",
  css: "../trino.css",
  nav: nav-for("release/release-402"),
  include "src/release/release-402.typ",
))
#document("release/release-403.html", page-shell(
  title: "Release 403 (15 Nov 2022) — Trino docs",
  css: "../trino.css",
  nav: nav-for("release/release-403"),
  include "src/release/release-403.typ",
))
#document("release/release-404.html", page-shell(
  title: "Release 404 (???) — Trino docs",
  css: "../trino.css",
  nav: nav-for("release/release-404"),
  include "src/release/release-404.typ",
))
#document("release/release-405.html", page-shell(
  title: "Release 405 (28 Dec 2022) — Trino docs",
  css: "../trino.css",
  nav: nav-for("release/release-405"),
  include "src/release/release-405.typ",
))
#document("release/release-406.html", page-shell(
  title: "Release 406 (25 Jan 2023) — Trino docs",
  css: "../trino.css",
  nav: nav-for("release/release-406"),
  include "src/release/release-406.typ",
))
#document("release/release-407.html", page-shell(
  title: "Release 407 (16 Feb 2023) — Trino docs",
  css: "../trino.css",
  nav: nav-for("release/release-407"),
  include "src/release/release-407.typ",
))
#document("release/release-408.html", page-shell(
  title: "Release 408 (23 Feb 2023) — Trino docs",
  css: "../trino.css",
  nav: nav-for("release/release-408"),
  include "src/release/release-408.typ",
))
#document("release/release-409.html", page-shell(
  title: "Release 409 (3 Mar 2023) — Trino docs",
  css: "../trino.css",
  nav: nav-for("release/release-409"),
  include "src/release/release-409.typ",
))
#document("release/release-410.html", page-shell(
  title: "Release 410 (8 Mar 2023) — Trino docs",
  css: "../trino.css",
  nav: nav-for("release/release-410"),
  include "src/release/release-410.typ",
))
#document("release/release-411.html", page-shell(
  title: "Release 411 (29 Mar 2023) — Trino docs",
  css: "../trino.css",
  nav: nav-for("release/release-411"),
  include "src/release/release-411.typ",
))
#document("release/release-412.html", page-shell(
  title: "Release 412 (5 Apr 2023) — Trino docs",
  css: "../trino.css",
  nav: nav-for("release/release-412"),
  include "src/release/release-412.typ",
))
#document("release/release-413.html", page-shell(
  title: "Release 413 (12 Apr 2023) — Trino docs",
  css: "../trino.css",
  nav: nav-for("release/release-413"),
  include "src/release/release-413.typ",
))
#document("release/release-414.html", page-shell(
  title: "Release 414 (19 Apr 2023) — Trino docs",
  css: "../trino.css",
  nav: nav-for("release/release-414"),
  include "src/release/release-414.typ",
))
#document("release/release-415.html", page-shell(
  title: "Release 415 (28 Apr 2023) — Trino docs",
  css: "../trino.css",
  nav: nav-for("release/release-415"),
  include "src/release/release-415.typ",
))
#document("release/release-416.html", page-shell(
  title: "Release 416 (3 May 2023) — Trino docs",
  css: "../trino.css",
  nav: nav-for("release/release-416"),
  include "src/release/release-416.typ",
))
#document("release/release-417.html", page-shell(
  title: "Release 417 (10 May 2023) — Trino docs",
  css: "../trino.css",
  nav: nav-for("release/release-417"),
  include "src/release/release-417.typ",
))
#document("release/release-418.html", page-shell(
  title: "Release 418 (17 May 2023) — Trino docs",
  css: "../trino.css",
  nav: nav-for("release/release-418"),
  include "src/release/release-418.typ",
))
#document("release/release-419.html", page-shell(
  title: "Release 419 (5 Jun 2023) — Trino docs",
  css: "../trino.css",
  nav: nav-for("release/release-419"),
  include "src/release/release-419.typ",
))
#document("release/release-420.html", page-shell(
  title: "Release 420 (22 Jun 2023) — Trino docs",
  css: "../trino.css",
  nav: nav-for("release/release-420"),
  include "src/release/release-420.typ",
))
#document("release/release-421.html", page-shell(
  title: "Release 421 (6 Jul 2023) — Trino docs",
  css: "../trino.css",
  nav: nav-for("release/release-421"),
  include "src/release/release-421.typ",
))
#document("release/release-422.html", page-shell(
  title: "Release 422 (13 Jul 2023) — Trino docs",
  css: "../trino.css",
  nav: nav-for("release/release-422"),
  include "src/release/release-422.typ",
))
#document("release/release-423.html", page-shell(
  title: "Release 423 (10 Aug 2023) — Trino docs",
  css: "../trino.css",
  nav: nav-for("release/release-423"),
  include "src/release/release-423.typ",
))
#document("release/release-424.html", page-shell(
  title: "Release 424 (17 Aug 2023) — Trino docs",
  css: "../trino.css",
  nav: nav-for("release/release-424"),
  include "src/release/release-424.typ",
))
#document("release/release-425.html", page-shell(
  title: "Release 425 (24 Aug 2023) — Trino docs",
  css: "../trino.css",
  nav: nav-for("release/release-425"),
  include "src/release/release-425.typ",
))
#document("release/release-426.html", page-shell(
  title: "Release 426 (5 Sep 2023) — Trino docs",
  css: "../trino.css",
  nav: nav-for("release/release-426"),
  include "src/release/release-426.typ",
))
#document("release/release-427.html", page-shell(
  title: "Release 427 (26 Sep 2023) — Trino docs",
  css: "../trino.css",
  nav: nav-for("release/release-427"),
  include "src/release/release-427.typ",
))
#document("release/release-428.html", page-shell(
  title: "Release 428 (4 Oct 2023) — Trino docs",
  css: "../trino.css",
  nav: nav-for("release/release-428"),
  include "src/release/release-428.typ",
))
#document("release/release-429.html", page-shell(
  title: "Release 429 (11 Oct 2023) — Trino docs",
  css: "../trino.css",
  nav: nav-for("release/release-429"),
  include "src/release/release-429.typ",
))
#document("release/release-430.html", page-shell(
  title: "Release 430 (20 Oct 2023) — Trino docs",
  css: "../trino.css",
  nav: nav-for("release/release-430"),
  include "src/release/release-430.typ",
))
#document("release/release-431.html", page-shell(
  title: "Release 431 (27 Oct 2023) — Trino docs",
  css: "../trino.css",
  nav: nav-for("release/release-431"),
  include "src/release/release-431.typ",
))
#document("release/release-432.html", page-shell(
  title: "Release 432 (2 Nov 2023) — Trino docs",
  css: "../trino.css",
  nav: nav-for("release/release-432"),
  include "src/release/release-432.typ",
))
#document("release/release-433.html", page-shell(
  title: "Release 433 (10 Nov 2023) — Trino docs",
  css: "../trino.css",
  nav: nav-for("release/release-433"),
  include "src/release/release-433.typ",
))
#document("release/release-434.html", page-shell(
  title: "Release 434 (29 Nov 2023) — Trino docs",
  css: "../trino.css",
  nav: nav-for("release/release-434"),
  include "src/release/release-434.typ",
))
#document("release/release-435.html", page-shell(
  title: "Release 435 (13 Dec 2023) — Trino docs",
  css: "../trino.css",
  nav: nav-for("release/release-435"),
  include "src/release/release-435.typ",
))
#document("release/release-436.html", page-shell(
  title: "Release 436 (11 Jan 2024) — Trino docs",
  css: "../trino.css",
  nav: nav-for("release/release-436"),
  include "src/release/release-436.typ",
))
#document("release/release-437.html", page-shell(
  title: "Release 437 (24 Jan 2024) — Trino docs",
  css: "../trino.css",
  nav: nav-for("release/release-437"),
  include "src/release/release-437.typ",
))
#document("release/release-438.html", page-shell(
  title: "Release 438 (1 Feb 2024) — Trino docs",
  css: "../trino.css",
  nav: nav-for("release/release-438"),
  include "src/release/release-438.typ",
))
#document("release/release-439.html", page-shell(
  title: "Release 439 (15 Feb 2024) — Trino docs",
  css: "../trino.css",
  nav: nav-for("release/release-439"),
  include "src/release/release-439.typ",
))
#document("release/release-440.html", page-shell(
  title: "Release 440 (8 Mar 2024) — Trino docs",
  css: "../trino.css",
  nav: nav-for("release/release-440"),
  include "src/release/release-440.typ",
))
#document("release/release-441.html", page-shell(
  title: "Release 441 (13 Mar 2024) — Trino docs",
  css: "../trino.css",
  nav: nav-for("release/release-441"),
  include "src/release/release-441.typ",
))
#document("release/release-442.html", page-shell(
  title: "Release 442 (14 Mar 2024) — Trino docs",
  css: "../trino.css",
  nav: nav-for("release/release-442"),
  include "src/release/release-442.typ",
))
#document("release/release-443.html", page-shell(
  title: "Release 443 (21 Mar 2024) — Trino docs",
  css: "../trino.css",
  nav: nav-for("release/release-443"),
  include "src/release/release-443.typ",
))
#document("release/release-444.html", page-shell(
  title: "Release 444 (3 Apr 2024) — Trino docs",
  css: "../trino.css",
  nav: nav-for("release/release-444"),
  include "src/release/release-444.typ",
))
#document("release/release-445.html", page-shell(
  title: "Release 445 (17 Apr 2024) — Trino docs",
  css: "../trino.css",
  nav: nav-for("release/release-445"),
  include "src/release/release-445.typ",
))
#document("release/release-446.html", page-shell(
  title: "Release 446 (1 May 2024) — Trino docs",
  css: "../trino.css",
  nav: nav-for("release/release-446"),
  include "src/release/release-446.typ",
))
#document("release/release-447.html", page-shell(
  title: "Release 447 (8 May 2024) — Trino docs",
  css: "../trino.css",
  nav: nav-for("release/release-447"),
  include "src/release/release-447.typ",
))
#document("release/release-448.html", page-shell(
  title: "Release 448 (15 May 2024) — Trino docs",
  css: "../trino.css",
  nav: nav-for("release/release-448"),
  include "src/release/release-448.typ",
))
#document("release/release-449.html", page-shell(
  title: "Release 449 (31 May 2024) — Trino docs",
  css: "../trino.css",
  nav: nav-for("release/release-449"),
  include "src/release/release-449.typ",
))
#document("release/release-450.html", page-shell(
  title: "Release 450 (19 Jun 2024) — Trino docs",
  css: "../trino.css",
  nav: nav-for("release/release-450"),
  include "src/release/release-450.typ",
))
#document("release/release-451.html", page-shell(
  title: "Release 451 (27 Jun 2024) — Trino docs",
  css: "../trino.css",
  nav: nav-for("release/release-451"),
  include "src/release/release-451.typ",
))
#document("release/release-452.html", page-shell(
  title: "Release 452 (11 Jul 2024) — Trino docs",
  css: "../trino.css",
  nav: nav-for("release/release-452"),
  include "src/release/release-452.typ",
))
#document("release/release-453.html", page-shell(
  title: "Release 453 (25 Jul 2024) — Trino docs",
  css: "../trino.css",
  nav: nav-for("release/release-453"),
  include "src/release/release-453.typ",
))
#document("release/release-454.html", page-shell(
  title: "Release 454 (15 Aug 2024) — Trino docs",
  css: "../trino.css",
  nav: nav-for("release/release-454"),
  include "src/release/release-454.typ",
))
#document("release/release-455.html", page-shell(
  title: "Release 455 (29 Aug 2024) — Trino docs",
  css: "../trino.css",
  nav: nav-for("release/release-455"),
  include "src/release/release-455.typ",
))
#document("release/release-456.html", page-shell(
  title: "Release 456 (6 Sep 2024) — Trino docs",
  css: "../trino.css",
  nav: nav-for("release/release-456"),
  include "src/release/release-456.typ",
))
#document("release/release-457.html", page-shell(
  title: "Release 457 (6 Sep 2024) — Trino docs",
  css: "../trino.css",
  nav: nav-for("release/release-457"),
  include "src/release/release-457.typ",
))
#document("release/release-458.html", page-shell(
  title: "Release 458 (17 Sep 2024) — Trino docs",
  css: "../trino.css",
  nav: nav-for("release/release-458"),
  include "src/release/release-458.typ",
))
#document("release/release-459.html", page-shell(
  title: "Release 459 (25 Sep 2024) — Trino docs",
  css: "../trino.css",
  nav: nav-for("release/release-459"),
  include "src/release/release-459.typ",
))
#document("release/release-460.html", page-shell(
  title: "Release 460 (3 Oct 2024) — Trino docs",
  css: "../trino.css",
  nav: nav-for("release/release-460"),
  include "src/release/release-460.typ",
))
#document("release/release-461.html", page-shell(
  title: "Release 461 (10 Oct 2024) — Trino docs",
  css: "../trino.css",
  nav: nav-for("release/release-461"),
  include "src/release/release-461.typ",
))
#document("release/release-462.html", page-shell(
  title: "Release 462 (16 Oct 2024) — Trino docs",
  css: "../trino.css",
  nav: nav-for("release/release-462"),
  include "src/release/release-462.typ",
))
#document("release/release-463.html", page-shell(
  title: "Release 463 (23 Oct 2024) — Trino docs",
  css: "../trino.css",
  nav: nav-for("release/release-463"),
  include "src/release/release-463.typ",
))
#document("release/release-464.html", page-shell(
  title: "Release 464 (30 Oct 2024) — Trino docs",
  css: "../trino.css",
  nav: nav-for("release/release-464"),
  include "src/release/release-464.typ",
))
#document("release/release-465.html", page-shell(
  title: "Release 465 (20 Nov 2024) — Trino docs",
  css: "../trino.css",
  nav: nav-for("release/release-465"),
  include "src/release/release-465.typ",
))
#document("release/release-466.html", page-shell(
  title: "Release 466 (27 Nov 2024) — Trino docs",
  css: "../trino.css",
  nav: nav-for("release/release-466"),
  include "src/release/release-466.typ",
))
#document("release/release-467.html", page-shell(
  title: "Release 467 (6 Dec 2024) — Trino docs",
  css: "../trino.css",
  nav: nav-for("release/release-467"),
  include "src/release/release-467.typ",
))
#document("release/release-468.html", page-shell(
  title: "Release 468 (17 Dec 2024) — Trino docs",
  css: "../trino.css",
  nav: nav-for("release/release-468"),
  include "src/release/release-468.typ",
))
#document("release/release-469.html", page-shell(
  title: "Release 469 (27 Jan 2025) — Trino docs",
  css: "../trino.css",
  nav: nav-for("release/release-469"),
  include "src/release/release-469.typ",
))
#document("release/release-470.html", page-shell(
  title: "Release 470 (5 Feb 2025) — Trino docs",
  css: "../trino.css",
  nav: nav-for("release/release-470"),
  include "src/release/release-470.typ",
))
#document("release/release-471.html", page-shell(
  title: "Release 471 (19 Feb 2025) — Trino docs",
  css: "../trino.css",
  nav: nav-for("release/release-471"),
  include "src/release/release-471.typ",
))
#document("release/release-472.html", page-shell(
  title: "Release 472 (5 Mar 2025) — Trino docs",
  css: "../trino.css",
  nav: nav-for("release/release-472"),
  include "src/release/release-472.typ",
))
#document("release/release-473.html", page-shell(
  title: "Release 473 (19 Mar 2025) — Trino docs",
  css: "../trino.css",
  nav: nav-for("release/release-473"),
  include "src/release/release-473.typ",
))
#document("release/release-474.html", page-shell(
  title: "Release 474 (21 Mar 2025) — Trino docs",
  css: "../trino.css",
  nav: nav-for("release/release-474"),
  include "src/release/release-474.typ",
))
#document("release/release-475.html", page-shell(
  title: "Release 475 (23 Apr 2025) — Trino docs",
  css: "../trino.css",
  nav: nav-for("release/release-475"),
  include "src/release/release-475.typ",
))
#document("release/release-476.html", page-shell(
  title: "Release 476 (5 Jun 2025) — Trino docs",
  css: "../trino.css",
  nav: nav-for("release/release-476"),
  include "src/release/release-476.typ",
))
#document("release/release-477.html", page-shell(
  title: "Release 477 (24 Sep 2025) — Trino docs",
  css: "../trino.css",
  nav: nav-for("release/release-477"),
  include "src/release/release-477.typ",
))
#document("release/release-478.html", page-shell(
  title: "Release 478 (29 Oct 2025) — Trino docs",
  css: "../trino.css",
  nav: nav-for("release/release-478"),
  include "src/release/release-478.typ",
))
#document("release/release-479.html", page-shell(
  title: "Release 479 (14 Dec 2025) — Trino docs",
  css: "../trino.css",
  nav: nav-for("release/release-479"),
  include "src/release/release-479.typ",
))
#document("release/release-480.html", page-shell(
  title: "Release 480 (24 Mar 2026) — Trino docs",
  css: "../trino.css",
  nav: nav-for("release/release-480"),
  include "src/release/release-480.typ",
))
#document("release/release-481.html", page-shell(
  title: "Release 481 (11 May 2026) — Trino docs",
  css: "../trino.css",
  nav: nav-for("release/release-481"),
  include "src/release/release-481.typ",
))
#document("security.html", page-shell(
  title: "Security — Trino docs",
  css: "trino.css",
  nav: nav-for("security"),
  include "src/security.typ",
))
#document("security/authentication-types.html", page-shell(
  title: "Authentication types — Trino docs",
  css: "../trino.css",
  nav: nav-for("security/authentication-types"),
  include "src/security/authentication-types.typ",
))
#document("security/built-in-system-access-control.html", page-shell(
  title: "System access control — Trino docs",
  css: "../trino.css",
  nav: nav-for("security/built-in-system-access-control"),
  include "src/security/built-in-system-access-control.typ",
))
#document("security/certificate.html", page-shell(
  title: "Certificate authentication — Trino docs",
  css: "../trino.css",
  nav: nav-for("security/certificate"),
  include "src/security/certificate.typ",
))
#document("security/file-system-access-control.html", page-shell(
  title: "File-based access control — Trino docs",
  css: "../trino.css",
  nav: nav-for("security/file-system-access-control"),
  include "src/security/file-system-access-control.typ",
))
#document("security/group-mapping.html", page-shell(
  title: "Group mapping — Trino docs",
  css: "../trino.css",
  nav: nav-for("security/group-mapping"),
  include "src/security/group-mapping.typ",
))
#document("security/inspect-jks.html", page-shell(
  title: "JKS files — Trino docs",
  css: "../trino.css",
  nav: nav-for("security/inspect-jks"),
  include "src/security/inspect-jks.typ",
))
#document("security/inspect-pem.html", page-shell(
  title: "PEM files — Trino docs",
  css: "../trino.css",
  nav: nav-for("security/inspect-pem"),
  include "src/security/inspect-pem.typ",
))
#document("security/internal-communication.html", page-shell(
  title: "Secure internal communication — Trino docs",
  css: "../trino.css",
  nav: nav-for("security/internal-communication"),
  include "src/security/internal-communication.typ",
))
#document("security/jwt.html", page-shell(
  title: "JWT authentication — Trino docs",
  css: "../trino.css",
  nav: nav-for("security/jwt"),
  include "src/security/jwt.typ",
))
#document("security/kerberos.html", page-shell(
  title: "Kerberos authentication — Trino docs",
  css: "../trino.css",
  nav: nav-for("security/kerberos"),
  include "src/security/kerberos.typ",
))
#document("security/ldap.html", page-shell(
  title: "LDAP authentication — Trino docs",
  css: "../trino.css",
  nav: nav-for("security/ldap"),
  include "src/security/ldap.typ",
))
#document("security/oauth2.html", page-shell(
  title: "OAuth 2.0 authentication — Trino docs",
  css: "../trino.css",
  nav: nav-for("security/oauth2"),
  include "src/security/oauth2.typ",
))
#document("security/opa-access-control.html", page-shell(
  title: "Open Policy Agent access control — Trino docs",
  css: "../trino.css",
  nav: nav-for("security/opa-access-control"),
  include "src/security/opa-access-control.typ",
))
#document("security/overview.html", page-shell(
  title: "Security overview — Trino docs",
  css: "../trino.css",
  nav: nav-for("security/overview"),
  include "src/security/overview.typ",
))
#document("security/password-file.html", page-shell(
  title: "Password file authentication — Trino docs",
  css: "../trino.css",
  nav: nav-for("security/password-file"),
  include "src/security/password-file.typ",
))
#document("security/ranger-access-control.html", page-shell(
  title: "Ranger access control — Trino docs",
  css: "../trino.css",
  nav: nav-for("security/ranger-access-control"),
  include "src/security/ranger-access-control.typ",
))
#document("security/salesforce.html", page-shell(
  title: "Salesforce authentication — Trino docs",
  css: "../trino.css",
  nav: nav-for("security/salesforce"),
  include "src/security/salesforce.typ",
))
#document("security/secrets.html", page-shell(
  title: "Secrets — Trino docs",
  css: "../trino.css",
  nav: nav-for("security/secrets"),
  include "src/security/secrets.typ",
))
#document("security/tls.html", page-shell(
  title: "TLS and HTTPS — Trino docs",
  css: "../trino.css",
  nav: nav-for("security/tls"),
  include "src/security/tls.typ",
))
#document("security/user-mapping.html", page-shell(
  title: "User mapping — Trino docs",
  css: "../trino.css",
  nav: nav-for("security/user-mapping"),
  include "src/security/user-mapping.typ",
))
#document("sql.html", page-shell(
  title: "SQL statement syntax — Trino docs",
  css: "trino.css",
  nav: nav-for("sql"),
  include "src/sql.typ",
))
#document("sql/alter-branch.html", page-shell(
  title: "ALTER BRANCH — Trino docs",
  css: "../trino.css",
  nav: nav-for("sql/alter-branch"),
  include "src/sql/alter-branch.typ",
))
#document("sql/alter-materialized-view.html", page-shell(
  title: "ALTER MATERIALIZED VIEW — Trino docs",
  css: "../trino.css",
  nav: nav-for("sql/alter-materialized-view"),
  include "src/sql/alter-materialized-view.typ",
))
#document("sql/alter-schema.html", page-shell(
  title: "ALTER SCHEMA — Trino docs",
  css: "../trino.css",
  nav: nav-for("sql/alter-schema"),
  include "src/sql/alter-schema.typ",
))
#document("sql/alter-table.html", page-shell(
  title: "ALTER TABLE — Trino docs",
  css: "../trino.css",
  nav: nav-for("sql/alter-table"),
  include "src/sql/alter-table.typ",
))
#document("sql/alter-view.html", page-shell(
  title: "ALTER VIEW — Trino docs",
  css: "../trino.css",
  nav: nav-for("sql/alter-view"),
  include "src/sql/alter-view.typ",
))
#document("sql/analyze.html", page-shell(
  title: "ANALYZE — Trino docs",
  css: "../trino.css",
  nav: nav-for("sql/analyze"),
  include "src/sql/analyze.typ",
))
#document("sql/call.html", page-shell(
  title: "CALL — Trino docs",
  css: "../trino.css",
  nav: nav-for("sql/call"),
  include "src/sql/call.typ",
))
#document("sql/comment.html", page-shell(
  title: "COMMENT — Trino docs",
  css: "../trino.css",
  nav: nav-for("sql/comment"),
  include "src/sql/comment.typ",
))
#document("sql/commit.html", page-shell(
  title: "COMMIT — Trino docs",
  css: "../trino.css",
  nav: nav-for("sql/commit"),
  include "src/sql/commit.typ",
))
#document("sql/create-branch.html", page-shell(
  title: "CREATE BRANCH — Trino docs",
  css: "../trino.css",
  nav: nav-for("sql/create-branch"),
  include "src/sql/create-branch.typ",
))
#document("sql/create-catalog.html", page-shell(
  title: "CREATE CATALOG — Trino docs",
  css: "../trino.css",
  nav: nav-for("sql/create-catalog"),
  include "src/sql/create-catalog.typ",
))
#document("sql/create-function.html", page-shell(
  title: "CREATE FUNCTION — Trino docs",
  css: "../trino.css",
  nav: nav-for("sql/create-function"),
  include "src/sql/create-function.typ",
))
#document("sql/create-materialized-view.html", page-shell(
  title: "CREATE MATERIALIZED VIEW — Trino docs",
  css: "../trino.css",
  nav: nav-for("sql/create-materialized-view"),
  include "src/sql/create-materialized-view.typ",
))
#document("sql/create-role.html", page-shell(
  title: "CREATE ROLE — Trino docs",
  css: "../trino.css",
  nav: nav-for("sql/create-role"),
  include "src/sql/create-role.typ",
))
#document("sql/create-schema.html", page-shell(
  title: "CREATE SCHEMA — Trino docs",
  css: "../trino.css",
  nav: nav-for("sql/create-schema"),
  include "src/sql/create-schema.typ",
))
#document("sql/create-table.html", page-shell(
  title: "CREATE TABLE — Trino docs",
  css: "../trino.css",
  nav: nav-for("sql/create-table"),
  include "src/sql/create-table.typ",
))
#document("sql/create-table-as.html", page-shell(
  title: "CREATE TABLE AS — Trino docs",
  css: "../trino.css",
  nav: nav-for("sql/create-table-as"),
  include "src/sql/create-table-as.typ",
))
#document("sql/create-view.html", page-shell(
  title: "CREATE VIEW — Trino docs",
  css: "../trino.css",
  nav: nav-for("sql/create-view"),
  include "src/sql/create-view.typ",
))
#document("sql/deallocate-prepare.html", page-shell(
  title: "DEALLOCATE PREPARE — Trino docs",
  css: "../trino.css",
  nav: nav-for("sql/deallocate-prepare"),
  include "src/sql/deallocate-prepare.typ",
))
#document("sql/delete.html", page-shell(
  title: "DELETE — Trino docs",
  css: "../trino.css",
  nav: nav-for("sql/delete"),
  include "src/sql/delete.typ",
))
#document("sql/deny.html", page-shell(
  title: "DENY — Trino docs",
  css: "../trino.css",
  nav: nav-for("sql/deny"),
  include "src/sql/deny.typ",
))
#document("sql/describe.html", page-shell(
  title: "DESCRIBE — Trino docs",
  css: "../trino.css",
  nav: nav-for("sql/describe"),
  include "src/sql/describe.typ",
))
#document("sql/describe-input.html", page-shell(
  title: "DESCRIBE INPUT — Trino docs",
  css: "../trino.css",
  nav: nav-for("sql/describe-input"),
  include "src/sql/describe-input.typ",
))
#document("sql/describe-output.html", page-shell(
  title: "DESCRIBE OUTPUT — Trino docs",
  css: "../trino.css",
  nav: nav-for("sql/describe-output"),
  include "src/sql/describe-output.typ",
))
#document("sql/drop-branch.html", page-shell(
  title: "DROP BRANCH — Trino docs",
  css: "../trino.css",
  nav: nav-for("sql/drop-branch"),
  include "src/sql/drop-branch.typ",
))
#document("sql/drop-catalog.html", page-shell(
  title: "DROP CATALOG — Trino docs",
  css: "../trino.css",
  nav: nav-for("sql/drop-catalog"),
  include "src/sql/drop-catalog.typ",
))
#document("sql/drop-function.html", page-shell(
  title: "DROP FUNCTION — Trino docs",
  css: "../trino.css",
  nav: nav-for("sql/drop-function"),
  include "src/sql/drop-function.typ",
))
#document("sql/drop-materialized-view.html", page-shell(
  title: "DROP MATERIALIZED VIEW — Trino docs",
  css: "../trino.css",
  nav: nav-for("sql/drop-materialized-view"),
  include "src/sql/drop-materialized-view.typ",
))
#document("sql/drop-role.html", page-shell(
  title: "DROP ROLE — Trino docs",
  css: "../trino.css",
  nav: nav-for("sql/drop-role"),
  include "src/sql/drop-role.typ",
))
#document("sql/drop-schema.html", page-shell(
  title: "DROP SCHEMA — Trino docs",
  css: "../trino.css",
  nav: nav-for("sql/drop-schema"),
  include "src/sql/drop-schema.typ",
))
#document("sql/drop-table.html", page-shell(
  title: "DROP TABLE — Trino docs",
  css: "../trino.css",
  nav: nav-for("sql/drop-table"),
  include "src/sql/drop-table.typ",
))
#document("sql/drop-view.html", page-shell(
  title: "DROP VIEW — Trino docs",
  css: "../trino.css",
  nav: nav-for("sql/drop-view"),
  include "src/sql/drop-view.typ",
))
#document("sql/execute.html", page-shell(
  title: "EXECUTE — Trino docs",
  css: "../trino.css",
  nav: nav-for("sql/execute"),
  include "src/sql/execute.typ",
))
#document("sql/execute-immediate.html", page-shell(
  title: "EXECUTE IMMEDIATE — Trino docs",
  css: "../trino.css",
  nav: nav-for("sql/execute-immediate"),
  include "src/sql/execute-immediate.typ",
))
#document("sql/explain.html", page-shell(
  title: "EXPLAIN — Trino docs",
  css: "../trino.css",
  nav: nav-for("sql/explain"),
  include "src/sql/explain.typ",
))
#document("sql/explain-analyze.html", page-shell(
  title: "EXPLAIN ANALYZE — Trino docs",
  css: "../trino.css",
  nav: nav-for("sql/explain-analyze"),
  include "src/sql/explain-analyze.typ",
))
#document("sql/grant.html", page-shell(
  title: "GRANT privilege — Trino docs",
  css: "../trino.css",
  nav: nav-for("sql/grant"),
  include "src/sql/grant.typ",
))
#document("sql/grant-roles.html", page-shell(
  title: "GRANT role — Trino docs",
  css: "../trino.css",
  nav: nav-for("sql/grant-roles"),
  include "src/sql/grant-roles.typ",
))
#document("sql/insert.html", page-shell(
  title: "INSERT — Trino docs",
  css: "../trino.css",
  nav: nav-for("sql/insert"),
  include "src/sql/insert.typ",
))
#document("sql/match-recognize.html", page-shell(
  title: "MATCH_RECOGNIZE — Trino docs",
  css: "../trino.css",
  nav: nav-for("sql/match-recognize"),
  include "src/sql/match-recognize.typ",
))
#document("sql/merge.html", page-shell(
  title: "MERGE — Trino docs",
  css: "../trino.css",
  nav: nav-for("sql/merge"),
  include "src/sql/merge.typ",
))
#document("sql/pattern-recognition-in-window.html", page-shell(
  title: "Row pattern recognition in window structures — Trino docs",
  css: "../trino.css",
  nav: nav-for("sql/pattern-recognition-in-window"),
  include "src/sql/pattern-recognition-in-window.typ",
))
#document("sql/prepare.html", page-shell(
  title: "PREPARE — Trino docs",
  css: "../trino.css",
  nav: nav-for("sql/prepare"),
  include "src/sql/prepare.typ",
))
#document("sql/refresh-materialized-view.html", page-shell(
  title: "REFRESH MATERIALIZED VIEW — Trino docs",
  css: "../trino.css",
  nav: nav-for("sql/refresh-materialized-view"),
  include "src/sql/refresh-materialized-view.typ",
))
#document("sql/reset-session.html", page-shell(
  title: "RESET SESSION — Trino docs",
  css: "../trino.css",
  nav: nav-for("sql/reset-session"),
  include "src/sql/reset-session.typ",
))
#document("sql/reset-session-authorization.html", page-shell(
  title: "RESET SESSION AUTHORIZATION — Trino docs",
  css: "../trino.css",
  nav: nav-for("sql/reset-session-authorization"),
  include "src/sql/reset-session-authorization.typ",
))
#document("sql/revoke.html", page-shell(
  title: "REVOKE privilege — Trino docs",
  css: "../trino.css",
  nav: nav-for("sql/revoke"),
  include "src/sql/revoke.typ",
))
#document("sql/revoke-roles.html", page-shell(
  title: "REVOKE role — Trino docs",
  css: "../trino.css",
  nav: nav-for("sql/revoke-roles"),
  include "src/sql/revoke-roles.typ",
))
#document("sql/rollback.html", page-shell(
  title: "ROLLBACK — Trino docs",
  css: "../trino.css",
  nav: nav-for("sql/rollback"),
  include "src/sql/rollback.typ",
))
#document("sql/select.html", page-shell(
  title: "SELECT — Trino docs",
  css: "../trino.css",
  nav: nav-for("sql/select"),
  include "src/sql/select.typ",
))
#document("sql/set-path.html", page-shell(
  title: "SET PATH — Trino docs",
  css: "../trino.css",
  nav: nav-for("sql/set-path"),
  include "src/sql/set-path.typ",
))
#document("sql/set-role.html", page-shell(
  title: "SET ROLE — Trino docs",
  css: "../trino.css",
  nav: nav-for("sql/set-role"),
  include "src/sql/set-role.typ",
))
#document("sql/set-session.html", page-shell(
  title: "SET SESSION — Trino docs",
  css: "../trino.css",
  nav: nav-for("sql/set-session"),
  include "src/sql/set-session.typ",
))
#document("sql/set-session-authorization.html", page-shell(
  title: "SET SESSION AUTHORIZATION — Trino docs",
  css: "../trino.css",
  nav: nav-for("sql/set-session-authorization"),
  include "src/sql/set-session-authorization.typ",
))
#document("sql/set-time-zone.html", page-shell(
  title: "SET TIME ZONE — Trino docs",
  css: "../trino.css",
  nav: nav-for("sql/set-time-zone"),
  include "src/sql/set-time-zone.typ",
))
#document("sql/show-branches.html", page-shell(
  title: "SHOW BRANCHES — Trino docs",
  css: "../trino.css",
  nav: nav-for("sql/show-branches"),
  include "src/sql/show-branches.typ",
))
#document("sql/show-catalogs.html", page-shell(
  title: "SHOW CATALOGS — Trino docs",
  css: "../trino.css",
  nav: nav-for("sql/show-catalogs"),
  include "src/sql/show-catalogs.typ",
))
#document("sql/show-columns.html", page-shell(
  title: "SHOW COLUMNS — Trino docs",
  css: "../trino.css",
  nav: nav-for("sql/show-columns"),
  include "src/sql/show-columns.typ",
))
#document("sql/show-create-function.html", page-shell(
  title: "SHOW CREATE FUNCTION — Trino docs",
  css: "../trino.css",
  nav: nav-for("sql/show-create-function"),
  include "src/sql/show-create-function.typ",
))
#document("sql/show-create-materialized-view.html", page-shell(
  title: "SHOW CREATE MATERIALIZED VIEW — Trino docs",
  css: "../trino.css",
  nav: nav-for("sql/show-create-materialized-view"),
  include "src/sql/show-create-materialized-view.typ",
))
#document("sql/show-create-schema.html", page-shell(
  title: "SHOW CREATE SCHEMA — Trino docs",
  css: "../trino.css",
  nav: nav-for("sql/show-create-schema"),
  include "src/sql/show-create-schema.typ",
))
#document("sql/show-create-table.html", page-shell(
  title: "SHOW CREATE TABLE — Trino docs",
  css: "../trino.css",
  nav: nav-for("sql/show-create-table"),
  include "src/sql/show-create-table.typ",
))
#document("sql/show-create-view.html", page-shell(
  title: "SHOW CREATE VIEW — Trino docs",
  css: "../trino.css",
  nav: nav-for("sql/show-create-view"),
  include "src/sql/show-create-view.typ",
))
#document("sql/show-functions.html", page-shell(
  title: "SHOW FUNCTIONS — Trino docs",
  css: "../trino.css",
  nav: nav-for("sql/show-functions"),
  include "src/sql/show-functions.typ",
))
#document("sql/show-grants.html", page-shell(
  title: "SHOW GRANTS — Trino docs",
  css: "../trino.css",
  nav: nav-for("sql/show-grants"),
  include "src/sql/show-grants.typ",
))
#document("sql/show-role-grants.html", page-shell(
  title: "SHOW ROLE GRANTS — Trino docs",
  css: "../trino.css",
  nav: nav-for("sql/show-role-grants"),
  include "src/sql/show-role-grants.typ",
))
#document("sql/show-roles.html", page-shell(
  title: "SHOW ROLES — Trino docs",
  css: "../trino.css",
  nav: nav-for("sql/show-roles"),
  include "src/sql/show-roles.typ",
))
#document("sql/show-schemas.html", page-shell(
  title: "SHOW SCHEMAS — Trino docs",
  css: "../trino.css",
  nav: nav-for("sql/show-schemas"),
  include "src/sql/show-schemas.typ",
))
#document("sql/show-session.html", page-shell(
  title: "SHOW SESSION — Trino docs",
  css: "../trino.css",
  nav: nav-for("sql/show-session"),
  include "src/sql/show-session.typ",
))
#document("sql/show-stats.html", page-shell(
  title: "SHOW STATS — Trino docs",
  css: "../trino.css",
  nav: nav-for("sql/show-stats"),
  include "src/sql/show-stats.typ",
))
#document("sql/show-tables.html", page-shell(
  title: "SHOW TABLES — Trino docs",
  css: "../trino.css",
  nav: nav-for("sql/show-tables"),
  include "src/sql/show-tables.typ",
))
#document("sql/start-transaction.html", page-shell(
  title: "START TRANSACTION — Trino docs",
  css: "../trino.css",
  nav: nav-for("sql/start-transaction"),
  include "src/sql/start-transaction.typ",
))
#document("sql/truncate.html", page-shell(
  title: "TRUNCATE — Trino docs",
  css: "../trino.css",
  nav: nav-for("sql/truncate"),
  include "src/sql/truncate.typ",
))
#document("sql/update.html", page-shell(
  title: "UPDATE — Trino docs",
  css: "../trino.css",
  nav: nav-for("sql/update"),
  include "src/sql/update.typ",
))
#document("sql/use.html", page-shell(
  title: "USE — Trino docs",
  css: "../trino.css",
  nav: nav-for("sql/use"),
  include "src/sql/use.typ",
))
#document("sql/values.html", page-shell(
  title: "VALUES — Trino docs",
  css: "../trino.css",
  nav: nav-for("sql/values"),
  include "src/sql/values.typ",
))
#document("udf.html", page-shell(
  title: "User-defined functions — Trino docs",
  css: "trino.css",
  nav: nav-for("udf"),
  include "src/udf.typ",
))
#document("udf/function.html", page-shell(
  title: "FUNCTION — Trino docs",
  css: "../trino.css",
  nav: nav-for("udf/function"),
  include "src/udf/function.typ",
))
#document("udf/introduction.html", page-shell(
  title: "Introduction to UDFs — Trino docs",
  css: "../trino.css",
  nav: nav-for("udf/introduction"),
  include "src/udf/introduction.typ",
))
#document("udf/python.html", page-shell(
  title: "Python user-defined functions — Trino docs",
  css: "../trino.css",
  nav: nav-for("udf/python"),
  include "src/udf/python.typ",
))
#document("udf/python/examples.html", page-shell(
  title: "Example Python UDFs — Trino docs",
  css: "../../trino.css",
  nav: nav-for("udf/python/examples"),
  include "src/udf/python/examples.typ",
))
#document("udf/sql.html", page-shell(
  title: "SQL user-defined functions — Trino docs",
  css: "../trino.css",
  nav: nav-for("udf/sql"),
  include "src/udf/sql.typ",
))
#document("udf/sql/begin.html", page-shell(
  title: "BEGIN — Trino docs",
  css: "../../trino.css",
  nav: nav-for("udf/sql/begin"),
  include "src/udf/sql/begin.typ",
))
#document("udf/sql/case.html", page-shell(
  title: "CASE — Trino docs",
  css: "../../trino.css",
  nav: nav-for("udf/sql/case"),
  include "src/udf/sql/case.typ",
))
#document("udf/sql/declare.html", page-shell(
  title: "DECLARE — Trino docs",
  css: "../../trino.css",
  nav: nav-for("udf/sql/declare"),
  include "src/udf/sql/declare.typ",
))
#document("udf/sql/examples.html", page-shell(
  title: "Example SQL UDFs — Trino docs",
  css: "../../trino.css",
  nav: nav-for("udf/sql/examples"),
  include "src/udf/sql/examples.typ",
))
#document("udf/sql/if.html", page-shell(
  title: "IF — Trino docs",
  css: "../../trino.css",
  nav: nav-for("udf/sql/if"),
  include "src/udf/sql/if.typ",
))
#document("udf/sql/iterate.html", page-shell(
  title: "ITERATE — Trino docs",
  css: "../../trino.css",
  nav: nav-for("udf/sql/iterate"),
  include "src/udf/sql/iterate.typ",
))
#document("udf/sql/leave.html", page-shell(
  title: "LEAVE — Trino docs",
  css: "../../trino.css",
  nav: nav-for("udf/sql/leave"),
  include "src/udf/sql/leave.typ",
))
#document("udf/sql/loop.html", page-shell(
  title: "LOOP — Trino docs",
  css: "../../trino.css",
  nav: nav-for("udf/sql/loop"),
  include "src/udf/sql/loop.typ",
))
#document("udf/sql/repeat.html", page-shell(
  title: "REPEAT — Trino docs",
  css: "../../trino.css",
  nav: nav-for("udf/sql/repeat"),
  include "src/udf/sql/repeat.typ",
))
#document("udf/sql/return.html", page-shell(
  title: "RETURN — Trino docs",
  css: "../../trino.css",
  nav: nav-for("udf/sql/return"),
  include "src/udf/sql/return.typ",
))
#document("udf/sql/set.html", page-shell(
  title: "SET — Trino docs",
  css: "../../trino.css",
  nav: nav-for("udf/sql/set"),
  include "src/udf/sql/set.typ",
))
#document("udf/sql/while.html", page-shell(
  title: "WHILE — Trino docs",
  css: "../../trino.css",
  nav: nav-for("udf/sql/while"),
  include "src/udf/sql/while.typ",
))

#asset("trino.css", read("theme/trino.css", encoding: none))
#asset("images/functions_color_bar.png", read("assets/images/functions_color_bar.png", encoding: none))
