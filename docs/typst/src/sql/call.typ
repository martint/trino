#import "/lib/trino-docs.typ": *

#anchor("doc-sql-call")
= CALL

== Synopsis

#code-block("text", "CALL procedure_name ( [ name => ] expression [, ...] )")

== Description

Call a procedure.

Procedures can be provided by connectors to perform data manipulation or administrative tasks. For example, the #link(label("doc-connector-system"))[System connector] defines a procedure for killing a running query.

Some connectors, such as the #link(label("doc-connector-postgresql"))[PostgreSQL connector], are for systems that have their own stored procedures. These stored procedures are separate from the connector-defined procedures discussed here and thus are not directly callable via #raw("CALL").

See connector documentation for details on available procedures.

== Examples

Call a procedure using positional arguments:

#code-block(none, "CALL test(123, 'apple');")

Call a procedure using named arguments:

#code-block(none, "CALL test(name => 'apple', id => 123);")

Call a procedure using a fully qualified name:

#code-block(none, "CALL catalog.schema.test();")
