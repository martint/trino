#import "/lib/trino-docs.typ": *

#anchor("doc-sql-create-table-as")
= CREATE TABLE AS

== Synopsis

#code-block("text", "CREATE [ OR REPLACE ] TABLE [ IF NOT EXISTS ] table_name [ ( column_alias, ... ) ]
[ COMMENT table_comment ]
[ WITH ( property_name = expression [, ...] ) ]
AS query
[ WITH [ NO ] DATA ]")

== Description

Create a new table containing the result of a select query. Use create-table to create an empty table.

The optional #raw("OR REPLACE") clause causes an existing table with the specified name to be replaced with the new table definition. Support for table replacement varies across connectors. Refer to the connector documentation for details.

The optional #raw("IF NOT EXISTS") clause causes the error to be suppressed if the table already exists.

#raw("OR REPLACE") and #raw("IF NOT EXISTS") cannot be used together.

The optional #raw("WITH") clause can be used to set properties on the newly created table.  To list all available table properties, run the following query:

#code-block(none, "SELECT * FROM system.metadata.table_properties")

== Examples

Create a new table #raw("orders_column_aliased") with the results of a query and the given column names:

#code-block(none, "CREATE TABLE orders_column_aliased (order_date, total_price)
AS
SELECT orderdate, totalprice
FROM orders")

Create a new table #raw("orders_by_date") that summarizes #raw("orders"):

#code-block(none, "CREATE TABLE orders_by_date
COMMENT 'Summary of orders by date'
WITH (format = 'ORC')
AS
SELECT orderdate, sum(totalprice) AS price
FROM orders
GROUP BY orderdate")

Create the table #raw("orders_by_date") if it does not already exist:

#code-block(none, "CREATE TABLE IF NOT EXISTS orders_by_date AS
SELECT orderdate, sum(totalprice) AS price
FROM orders
GROUP BY orderdate")

Create a new #raw("empty_nation") table with the same schema as #raw("nation") and no data:

#code-block(none, "CREATE TABLE empty_nation AS
SELECT *
FROM nation
WITH NO DATA")

== See also

create-table, select
