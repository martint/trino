#import "/lib/trino-docs.typ": *

#anchor("doc-connector-loki")
= Loki connector

The Loki connector allows querying log data stored in #link("https://grafana.com/oss/loki/")[Grafana Loki]. This document describes how to configure a catalog with the Loki connector to run SQL queries against Loki.

== Requirements

To connect to Loki, you need:

- Loki 3.2.0 or higher.
- Network access from the Trino coordinator and workers to Loki. Port 3100 is the default port.

== Configuration

The connector can query log data in Loki. Create a catalog properties file that specifies the Loki connector by setting the #raw("connector.name") to #raw("loki").

For example, to access a database as the #raw("example") catalog, create the file #raw("etc/catalog/example.properties").

#code-block("text", "connector.name=loki
loki.uri=http://loki.example.com:3100")

The following table contains a list of all available configuration properties.

#list-table((
  ([Property name], [Description],),
  ([#raw("loki.uri")], [The URI endpoint for the Loki server that Trino cluster nodes use to access the Loki APIs.],),
  ([#raw("loki.query-timeout")], [#link(label("ref-prop-type-duration"))[Duration] that Trino waits for a result from Loki before the specific query request times out. Defaults to #raw("10s"). A minimum of #raw("1s") is required.],)
), header-rows: 1, title: "Loki configuration properties")

#anchor("ref-loki-type-mapping")

== Type mapping

Because Trino and Loki each support types that the other does not, this connector #link(label("ref-type-mapping-overview"))[modifies some types] when reading data.

=== Loki to Trino type mapping

Each log line in Loki is split up by the connector into three columns:

- #raw("timestamp")
- #raw("values")
- #raw("labels")

These are separately mapped to Trino types:

#list-table((
  ([Loki type], [Trino type],),
  ([#raw("timestamp")], [#raw("TIMESTAMP WITH TIME ZONE")],),
  ([#raw("values") for #link("https://grafana.com/docs/loki/latest/query/log_queries/")[log queries]], [#raw("VARCHAR")],),
  ([#raw("values") for #link("https://grafana.com/docs/loki/latest/query/metric_queries/")[metrics queries]], [#raw("DOUBLE")],),
  ([#raw("labels")], [#raw("MAP") with label names and values as #raw("VARCHAR") key value pairs],)
), header-rows: 1, title: "Loki log entry to Trino type mapping")

No other types are supported.

#anchor("ref-loki-sql-support")

== SQL support

The Loki connector does not provide access to any schema or tables. Instead you must use the #link(label("ref-loki-query-range"))[query\_range] table function to return a table representation of the desired log data. Use the data in the returned table like any other table in a SQL query, including use of functions, joins, and other SQL functionality.

#anchor("ref-lok-table-functions")

=== Table functions

The connector provides the following #link(label("doc-functions-table"))[table function] to access Loki.

#anchor("ref-loki-query-range")

=== #raw("query_range(varchar, timestamp, timestamp) -> table")

The #raw("query_range") function allows you to query the log data in Loki with the following parameters:

- The first parameter is a #raw("varchar") string that uses valid #link("https://grafana.com/docs/loki/latest/query/")[LogQL] query.
- The second parameter is a #raw("timestamp") formatted data and time representing the start date and time of the log data range to query.
- The third parameter is a #raw("timestamp") formatted data and time representing the end date and time of the log data range to query.

The table function is available in the #raw("system") schema of the catalog using the Loki connector, and returns a table with the columns #raw("timestamp"), #raw("value"), and #raw("labels") described in the #link(label("ref-loki-type-mapping"))[Loki connector] section.

The following query invokes the #raw("query_range") table function in the #raw("example") catalog. It uses the LogQL query string #raw("{origin=\"CA\"}") to retrieve all log data with the value #raw("CA") for the #raw("origin") label on the log entries. The timestamp parameters set a range of all log entries from the first of January 2025.

#code-block("sql", "SELECT timestamp, value 
FROM
  TABLE(
    example.system.query_range(
      '{origin=\"CA\"}',
      TIMESTAMP '2025-01-01 00:00:00',
      TIMESTAMP '2025-01-02 00:00:00'
    )
  )
;")

The query only returns the timestamp and value for each log entry, and omits the label data in the #raw("labels") column. The value is a #raw("varchar") string since the LoqQL query is a log query.

== Examples

The following examples showcase combinations of #link("https://grafana.com/docs/loki/latest/query/")[LogQL] queries passed through the table function with SQL accessing the data in the returned table.

The following query uses a metrics query and therefore returns a #raw("count") column with double values, limiting the result data to the latest 100 values.

#code-block("sql", "SELECT value AS count
FROM
  TABLE(
    example.system.query_range(
      'count_over_time({test=\"metrics_query\"}[5m])',
      TIMESTAMP '2025-01-01 00:00:00',
      TIMESTAMP '2025-01-02 00:00:00'
    )
  )
ORDER BY timestamp DESC
LIMIT 100;")

The following query accesses the value of the label named #raw("province") and returns it as separate column.

#code-block("sql", "SELECT 
  timestamp, 
  value, 
  labels['province'] AS province
FROM
  TABLE(
    example.system.query_range(
      '{origin=\"CA\"}',
      TIMESTAMP '2025-01-01 00:00:00',
      TIMESTAMP '2025-01-02 00:00:00'
    )
  )
;")
