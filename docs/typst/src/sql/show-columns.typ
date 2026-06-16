#import "/lib/trino-docs.typ": *

#anchor("doc-sql-show-columns")
= SHOW COLUMNS

== Synopsis

#code-block("text", "SHOW COLUMNS FROM table [ LIKE pattern ]")

== Description

List the columns in a #raw("table") along with their data type and other attributes:

#code-block(none, "SHOW COLUMNS FROM nation;")

#code-block("text", "  Column   |     Type     | Extra | Comment
-----------+--------------+-------+---------
 nationkey | bigint       |       |
 name      | varchar(25)  |       |
 regionkey | bigint       |       |
 comment   | varchar(152) |       |")

#link(label("ref-like-operator"))[Specify a pattern] in the optional #raw("LIKE") clause to filter the results to the desired subset. For example, the following query allows you to find columns ending in #raw("key"):

#code-block(none, "SHOW COLUMNS FROM nation LIKE '%key';")

#code-block("text", "  Column   |     Type     | Extra | Comment
-----------+--------------+-------+---------
 nationkey | bigint       |       |
 regionkey | bigint       |       |")
