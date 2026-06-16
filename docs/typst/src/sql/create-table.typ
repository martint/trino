#import "/lib/trino-docs.typ": *

#anchor("doc-sql-create-table")
= CREATE TABLE

== Synopsis

#code-block("text", "CREATE [ OR REPLACE ] TABLE [ IF NOT EXISTS ]
table_name (
  { column_name data_type [ DEFAULT default ] [ NOT NULL ]
      [ COMMENT comment ]
      [ WITH ( property_name = expression [, ...] ) ]
  | LIKE existing_table_name
      [ { INCLUDING | EXCLUDING } PROPERTIES ]
  }
  [, ...]
)
[ COMMENT table_comment ]
[ WITH ( property_name = expression [, ...] ) ]")

== Description

Create a new, empty table with the specified columns. Use create-table-as to create a table with data.

The optional #raw("OR REPLACE") clause causes an existing table with the specified name to be replaced with the new table definition. Support for table replacement varies across connectors. Refer to the connector documentation for details.

The optional #raw("IF NOT EXISTS") clause causes the error to be suppressed if the table already exists.

#raw("OR REPLACE") and #raw("IF NOT EXISTS") cannot be used together.

The optional #raw("WITH") clause can be used to set properties on the newly created table or on single columns.  To list all available table properties, run the following query:

#code-block(none, "SELECT * FROM system.metadata.table_properties")

To list all available column properties, run the following query:

#code-block(none, "SELECT * FROM system.metadata.column_properties")

The #raw("LIKE") clause can be used to include all the column definitions from an existing table in the new table. Multiple #raw("LIKE") clauses may be specified, which allows copying the columns from multiple tables.

If #raw("INCLUDING PROPERTIES") is specified, all the table properties are copied to the new table. If the #raw("WITH") clause specifies the same property name as one of the copied properties, the value from the #raw("WITH") clause will be used. The default behavior is #raw("EXCLUDING PROPERTIES"). The #raw("INCLUDING PROPERTIES") option maybe specified for at most one table.

== Examples

Create a new table #raw("orders"):

#code-block(none, "CREATE TABLE orders (
  orderkey bigint,
  orderstatus varchar,
  totalprice double,
  orderdate date
)
WITH (format = 'ORC')")

Create the table #raw("orders") if it does not already exist, adding a table comment and a column comment and a column with default value:

#code-block(none, "CREATE TABLE IF NOT EXISTS orders (
  orderkey bigint,
  orderstatus varchar,
  totalprice double COMMENT 'Price in cents.',
  orderdate date,
  status varchar DEFAULT 'created'
)
COMMENT 'A table to keep track of orders.'")

Create the table #raw("bigger_orders") using the columns from #raw("orders") plus additional columns at the start and end:

#code-block(none, "CREATE TABLE bigger_orders (
  another_orderkey bigint,
  LIKE orders,
  another_orderdate date
)")

== See also

alter-table, drop-table, create-table-as, show-create-table
