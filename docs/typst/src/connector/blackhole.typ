#import "/lib/trino-docs.typ": *

#anchor("doc-connector-blackhole")
= Black Hole connector

Primarily Black Hole connector is designed for high performance testing of other components. It works like the #raw("/dev/null") device on Unix-like operating systems for data writing and like #raw("/dev/null") or #raw("/dev/zero") for data reading. However, it also has some other features that allow testing Trino in a more controlled manner. Metadata for any tables created via this connector is kept in memory on the coordinator and discarded when Trino restarts. Created tables are by default always empty, and any data written to them is ignored and data reads return no rows.

During table creation, a desired rows number can be specified. In such cases, writes behave in the same way, but reads always return the specified number of some constant rows. You shouldn't rely on the content of such rows.

== Configuration

Create #raw("etc/catalog/example.properties") to mount the #raw("blackhole") connector as the #raw("example") catalog, with the following contents:

#code-block("text", "connector.name=blackhole")

== Examples

Create a table using the blackhole connector:

#code-block(none, "CREATE TABLE example.test.nation AS
SELECT * from tpch.tiny.nation;")

Insert data into a table in the blackhole connector:

#code-block(none, "INSERT INTO example.test.nation
SELECT * FROM tpch.tiny.nation;")

Select from the blackhole connector:

#code-block(none, "SELECT count(*) FROM example.test.nation;")

The above query always returns zero.

Create a table with a constant number of rows \(500 \* 1000 \* 2000\):

#code-block(none, "CREATE TABLE example.test.nation (
  nationkey BIGINT,
  name VARCHAR
)
WITH (
  split_count = 500,
  pages_per_split = 1000,
  rows_per_page = 2000
);")

Now query it:

#code-block(none, "SELECT count(*) FROM example.test.nation;")

The above query returns 1,000,000,000.

Length of variable length columns can be controlled using the #raw("field_length") table property \(default value is equal to 16\):

#code-block(none, "CREATE TABLE example.test.nation (
  nationkey BIGINT,
  name VARCHAR
)
WITH (
  split_count = 500,
  pages_per_split = 1000,
  rows_per_page = 2000,
  field_length = 100
);")

The consuming and producing rate can be slowed down using the #raw("page_processing_delay") table property. Setting this property to #raw("5s") leads to a 5 second delay before consuming or producing a new page:

#code-block(none, "CREATE TABLE example.test.delay (
  dummy BIGINT
)
WITH (
  split_count = 1,
  pages_per_split = 1,
  rows_per_page = 1,
  page_processing_delay = '5s'
);")

#anchor("ref-blackhole-sql-support")

== SQL support

The connector provides #link(label("ref-sql-globally-available"))[globally available], #link(label("ref-sql-read-operations"))[read operation], and supports the following additional features:

- #link(label("doc-sql-insert"))[INSERT]
- #link(label("doc-sql-update"))[UPDATE]
- #link(label("doc-sql-delete"))[DELETE]
- #link(label("doc-sql-merge"))[MERGE]
- #link(label("doc-sql-create-table"))[CREATE TABLE]
- #link(label("doc-sql-create-table-as"))[CREATE TABLE AS]
- #link(label("doc-sql-show-create-table"))[SHOW CREATE TABLE]
- #link(label("doc-sql-drop-table"))[DROP TABLE]
- #link(label("doc-sql-alter-table"))[ALTER TABLE]
- #link(label("doc-sql-comment"))[COMMENT]
- #link(label("doc-sql-create-schema"))[CREATE SCHEMA]
- #link(label("doc-sql-drop-schema"))[DROP SCHEMA]
- #link(label("doc-sql-create-view"))[CREATE VIEW]
- #link(label("doc-sql-show-create-view"))[SHOW CREATE VIEW]
- #link(label("doc-sql-drop-view"))[DROP VIEW]

#note[
The connector discards all written data. While read operations are supported, they return rows with all NULL values, with the number of rows controlled via table properties.
]
