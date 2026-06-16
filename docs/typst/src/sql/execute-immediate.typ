#import "/lib/trino-docs.typ": *

#anchor("doc-sql-execute-immediate")
= EXECUTE IMMEDIATE

== Synopsis

#code-block("text", "EXECUTE IMMEDIATE `statement` [ USING parameter1 [ , parameter2, ... ] ]")

== Description

Executes a statement without the need to prepare or deallocate the statement. Parameter values are defined in the #raw("USING") clause.

== Examples

Execute a query with no parameters:

#code-block(none, "EXECUTE IMMEDIATE
'SELECT name FROM nation';")

Execute a query with two parameters:

#code-block(none, "EXECUTE IMMEDIATE
'SELECT name FROM nation WHERE regionkey = ? and nationkey < ?'
USING 1, 3;")

This is equivalent to:

#code-block(none, "PREPARE statement_name FROM SELECT name FROM nation WHERE regionkey = ? and nationkey < ?
EXECUTE statement_name USING 1, 3
DEALLOCATE PREPARE statement_name")

== See also

execute, prepare, deallocate-prepare
