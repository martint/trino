#import "/lib/trino-docs.typ": *

#anchor("doc-sql-prepare")
= PREPARE

== Synopsis

#code-block("text", "PREPARE statement_name FROM statement")

== Description

Prepares a statement for execution at a later time. Prepared statements are queries that are saved in a session with a given name. The statement can include parameters in place of literals to be replaced at execution time. Parameters are represented by question marks.

== Examples

Prepare a select query:

#code-block(none, "PREPARE my_select1 FROM
SELECT * FROM nation;")

Prepare a select query that includes parameters. The values to compare with #raw("regionkey") and #raw("nationkey") will be filled in with the execute statement:

#code-block(none, "PREPARE my_select2 FROM
SELECT name FROM nation WHERE regionkey = ? AND nationkey < ?;")

Prepare an insert query:

#code-block(none, "PREPARE my_insert FROM
INSERT INTO cities VALUES (1, 'San Francisco');")

== See also

execute, deallocate-prepare, execute-immediate, describe-input, describe-output
