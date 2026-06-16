#import "/lib/trino-docs.typ": *

#anchor("doc-sql-insert")
= INSERT

== Synopsis

#code-block("text", "INSERT INTO table_name [ @ branch_name ] [ ( column [, ... ] ) ] query")

== Description

Insert new rows into a table.

If the list of column names is specified, they must exactly match the list of columns produced by the query. Each column in the table not present in the column list will be filled with a #raw("null") value. Otherwise, if the list of columns is not specified, the columns produced by the query must exactly match the columns in the table being inserted into.

== Examples

Load additional rows into the #raw("orders") table from the #raw("new_orders") table:

#code-block(none, "INSERT INTO orders
SELECT * FROM new_orders;")

Insert a single row into the #raw("cities") table:

#code-block(none, "INSERT INTO cities VALUES (1, 'San Francisco');")

Insert multiple rows into the #raw("cities") table:

#code-block(none, "INSERT INTO cities VALUES (2, 'San Jose'), (3, 'Oakland');")

Insert a single row into the #raw("nation") table with the specified column list:

#code-block(none, "INSERT INTO nation (nationkey, name, regionkey, comment)
VALUES (26, 'POLAND', 3, 'no comment');")

Insert a row without specifying the #raw("comment") column. That column will be #raw("null"):

#code-block(none, "INSERT INTO nation (nationkey, name, regionkey)
VALUES (26, 'POLAND', 3);")

Insert a single row into #raw("audit") branch of the #raw("cities") table:

#code-block("sql", "INSERT INTO cities @ audit VALUES (1, 'San Francisco');")

== See also

values
