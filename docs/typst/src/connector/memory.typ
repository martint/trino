#import "/lib/trino-docs.typ": *

#anchor("doc-connector-memory")
= Memory connector

The Memory connector stores all data and metadata in RAM on workers and both are discarded when Trino restarts.

== Configuration

To configure the Memory connector, create a catalog properties file #raw("etc/catalog/example.properties") with the following contents:

#code-block("text", "connector.name=memory
memory.max-data-per-node=128MB")

#raw("memory.max-data-per-node") defines memory limit for pages stored in this connector per each node \(default value is 128MB\).

== Examples

Create a table using the Memory connector:

#code-block(none, "CREATE TABLE example.default.nation AS
SELECT * from tpch.tiny.nation;")

Insert data into a table in the Memory connector:

#code-block(none, "INSERT INTO example.default.nation
SELECT * FROM tpch.tiny.nation;")

Select from the Memory connector:

#code-block(none, "SELECT * FROM example.default.nation;")

Drop table:

#code-block(none, "DROP TABLE example.default.nation;")

Create a table with a column that has a default value:

#code-block("sql", "CREATE TABLE orders (
  orderkey bigint,
  status varchar DEFAULT 'created'
)")

#anchor("ref-memory-type-mapping")

== Type mapping

Trino supports all data types used within the Memory schemas so no mapping is required.

#anchor("ref-memory-sql-support")

== SQL support

The connector provides read and write access to temporary data and metadata stored in memory. In addition to the #link(label("ref-sql-globally-available"))[globally available] and #link(label("ref-sql-read-operations"))[read operation] statements, the connector supports the following features:

- #link(label("doc-sql-insert"))[INSERT]
- #link(label("doc-sql-truncate"))[TRUNCATE]
- #link(label("doc-sql-create-table"))[CREATE TABLE]
- #link(label("doc-sql-create-table-as"))[CREATE TABLE AS]
- #link(label("doc-sql-drop-table"))[DROP TABLE]
- #link(label("doc-sql-alter-table"))[ALTER TABLE]
- #link(label("doc-sql-create-schema"))[CREATE SCHEMA]
- #link(label("doc-sql-drop-schema"))[DROP SCHEMA]
- #link(label("doc-sql-alter-schema"))[ALTER SCHEMA]
- #link(label("doc-sql-comment"))[COMMENT]
- #link(label("ref-sql-view-management"))[SQL statement support]
- #link(label("ref-udf-management"))[SQL statement support]

=== TRUNCATE and DROP TABLE

Upon execution of a #raw("TRUNCATE") and a #raw("DROP TABLE") operation, memory is not released immediately. It is instead released after the next write operation to the catalog.

#anchor("ref-memory-dynamic-filtering")

== Dynamic filtering

The Memory connector supports the #link(label("doc-admin-dynamic-filtering"))[dynamic filtering] optimization. Dynamic filters are pushed into local table scan on worker nodes for broadcast joins.

=== Delayed execution for dynamic filters

For the Memory connector, a table scan is delayed until the collection of dynamic filters. This can be disabled by using the configuration property #raw("memory.enable-lazy-dynamic-filtering") in the catalog file.

== Limitations

- When one worker fails\/restarts, all data that was stored in its memory is lost. To prevent silent data loss the connector throws an error on any read access to such corrupted table.
- When a query fails for any reason during writing to memory table, the table enters an undefined state. The table should be dropped and recreated manually. Reading attempts from the table may fail, or may return partial data.
- When the coordinator fails\/restarts, all metadata about tables is lost. The tables remain on the workers, but become inaccessible.
