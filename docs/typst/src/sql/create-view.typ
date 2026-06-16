#import "/lib/trino-docs.typ": *

#anchor("doc-sql-create-view")
= CREATE VIEW

== Synopsis

#code-block("text", "CREATE [ OR REPLACE ] VIEW view_name
[ COMMENT view_comment ]
[ SECURITY { DEFINER | INVOKER } ]
AS query")

== Description

Create a new view of a select query. The view is a logical table that can be referenced by future queries. Views do not contain any data. Instead, the query stored by the view is executed every time the view is referenced by another query.

The optional #raw("OR REPLACE") clause causes the view to be replaced if it already exists rather than raising an error.

== Security

In the default #raw("DEFINER") security mode, tables referenced in the view are accessed using the permissions of the view owner \(the #emph[creator] or #emph[definer] of the view\) rather than the user executing the query. This allows providing restricted access to the underlying tables, for which the user may not be allowed to access directly.

In the #raw("INVOKER") security mode, tables referenced in the view are accessed using the permissions of the user executing the query \(the #emph[invoker] of the view\). A view created in this mode is simply a stored query.

Regardless of the security mode, the #raw("current_user") function will always return the user executing the query and thus may be used within views to filter out rows or otherwise restrict access.

== Examples

Create a simple view #raw("test") over the #raw("orders") table:

#code-block(none, "CREATE VIEW test AS
SELECT orderkey, orderstatus, totalprice / 2 AS half
FROM orders")

Create a view #raw("test_with_comment") with a view comment:

#code-block(none, "CREATE VIEW test_with_comment
COMMENT 'A view to keep track of orders.'
AS
SELECT orderkey, orderstatus, totalprice
FROM orders")

Create a view #raw("orders_by_date") that summarizes #raw("orders"):

#code-block(none, "CREATE VIEW orders_by_date AS
SELECT orderdate, sum(totalprice) AS price
FROM orders
GROUP BY orderdate")

Create a view that replaces an existing view:

#code-block(none, "CREATE OR REPLACE VIEW test AS
SELECT orderkey, orderstatus, totalprice / 4 AS quarter
FROM orders")

== See also

- #link(label("doc-sql-alter-view"))[ALTER VIEW]
- #link(label("doc-sql-drop-view"))[DROP VIEW]
- #link(label("doc-sql-show-create-view"))[SHOW CREATE VIEW]
- #link(label("doc-sql-show-tables"))[SHOW TABLES]
