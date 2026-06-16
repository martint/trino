#import "/lib/trino-docs.typ": *

#anchor("doc-sql-reset-session")
= RESET SESSION

== Synopsis

#code-block("text", "RESET SESSION name
RESET SESSION catalog.name")

== Description

Reset a #link(label("ref-session-properties-definition"))[session property] value to the default value.

== Examples

#code-block("sql", "RESET SESSION query_max_run_time;
RESET SESSION hive.optimized_reader_enabled;")

== See also

set-session, show-session
