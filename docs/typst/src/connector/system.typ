#import "/lib/trino-docs.typ": *

#anchor("doc-connector-system")
= System connector

The System connector provides information and metrics about the currently running Trino cluster. It makes this available via normal SQL queries.

== Configuration

The System connector doesn't need to be configured: it is automatically available via a catalog named #raw("system").

== Using the System connector

List the available system schemas:

#code-block(none, "SHOW SCHEMAS FROM system;")

List the tables in one of the schemas:

#code-block(none, "SHOW TABLES FROM system.runtime;")

Query one of the tables:

#code-block(none, "SELECT * FROM system.runtime.nodes;")

Kill a running query:

#code-block(none, "CALL system.runtime.kill_query(query_id => '20151207_215727_00146_tx3nr', message => 'Using too many resources');")

== System connector tables

=== #raw("metadata.catalogs")

The catalogs table contains the list of available catalogs.

=== #raw("metadata.schema_properties")

The schema properties table contains the list of available properties that can be set when creating a new schema.

=== #raw("metadata.table_properties")

The table properties table contains the list of available properties that can be set when creating a new table.

#anchor("ref-system-metadata-materialized-views")

=== #raw("metadata.materialized_views")

The materialized views table contains the following information about all #link(label("ref-sql-materialized-view-management"))[materialized views]:

#list-table((
  ([Column], [Description],),
  ([#raw("catalog_name")], [Name of the catalog containing the materialized view.],),
  ([#raw("schema_name")], [Name of the schema in #raw("catalog_name") containing the materialized view.],),
  ([#raw("name")], [Name of the materialized view.],),
  ([#raw("storage_catalog")], [Name of the catalog used for the storage table backing the materialized view.],),
  ([#raw("storage_schema")], [Name of the schema in #raw("storage_catalog") used for the storage table backing the materialized view.],),
  ([#raw("storage_table")], [Name of the storage table backing the materialized view.],),
  ([#raw("freshness")], [Freshness of data in the storage table. Queries on the materialized view access the storage table if not #raw("STALE"), otherwise the #raw("definition") is used to access the underlying data in the source tables.],),
  ([#raw("last_fresh_time")], [Date and time of the last refresh of the materialized view.],),
  ([#raw("comment")], [User supplied text about the materialized view.],),
  ([#raw("definition")], [SQL query that defines the data provided by the materialized view.],)
), header-rows: 1, title: "Metadata for materialized views")

=== #raw("metadata.materialized_view_properties")

The materialized view properties table contains the list of available properties that can be set when creating a new materialized view.

=== #raw("metadata.table_comments")

The table comments table contains the list of table comment.

=== #raw("runtime.nodes")

The nodes table contains the list of visible nodes in the Trino cluster along with their status.

#anchor("ref-optimizer-rule-stats")

=== #raw("runtime.optimizer_rule_stats")

The #raw("optimizer_rule_stats") table contains the statistics for optimizer rule invocations during the query planning phase. The statistics are aggregated over all queries since the server start-up. The table contains information about invocation frequency, failure rates and performance for optimizer rules. For example, you can look at the multiplication of columns #raw("invocations") and #raw("average_time") to get an idea about which rules generally impact query planning times the most.

=== #raw("runtime.queries")

The queries table contains information about currently and recently running queries on the Trino cluster. From this table you can find out the original query SQL text, the identity of the user who ran the query, and performance information about the query, including how long the query was queued and analyzed.

=== #raw("runtime.tasks")

The tasks table contains information about the tasks involved in a Trino query, including where they were executed, and how many rows and bytes each task processed.

=== #raw("runtime.transactions")

The transactions table contains the list of currently open transactions and related metadata. This includes information such as the create time, idle time, initialization parameters, and accessed catalogs.

== System connector procedures

#function-def("fn-runtime-kill-query", "runtime.kill_query(query_id, message)", none)[
Kill the query identified by #raw("query_id"). The query failure message includes the specified #raw("message"). #raw("message") is optional.
]

#anchor("ref-system-type-mapping")

== Type mapping

Trino supports all data types used within the System schemas so no mapping is required.

#anchor("ref-system-sql-support")

== SQL support

The connector provides #link(label("ref-sql-globally-available"))[globally available] and #link(label("ref-sql-read-operations"))[read operation] statements to access Trino system data and metadata.
