#import "/lib/trino-docs.typ": *

#anchor("doc-sql-values")
= VALUES

== Synopsis

#code-block("text", "VALUES row [, ...]")

where #raw("row") is a single expression or

#code-block("text", "( column_expression [, ...] )")

== Description

Defines a literal inline table.

#raw("VALUES") can be used anywhere a query can be used \(e.g., the #raw("FROM") clause of a select, an insert, or even at the top level\). #raw("VALUES") creates an anonymous table without column names, but the table and columns can be named using an #raw("AS") clause with column aliases.

== Examples

Return a table with one column and three rows:

#code-block(none, "VALUES 1, 2, 3")

Return a table with two columns and three rows:

#code-block(none, "VALUES
    (1, 'a'),
    (2, 'b'),
    (3, 'c')")

Return table with column #raw("id") and #raw("name"):

#code-block(none, "SELECT * FROM (
    VALUES
        (1, 'a'),
        (2, 'b'),
        (3, 'c')
) AS t (id, name)")

Create a new table with column #raw("id") and #raw("name"):

#code-block(none, "CREATE TABLE example AS
SELECT * FROM (
    VALUES
        (1, 'a'),
        (2, 'b'),
        (3, 'c')
) AS t (id, name)")

== See also

insert, select
