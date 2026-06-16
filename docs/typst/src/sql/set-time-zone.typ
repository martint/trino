#import "/lib/trino-docs.typ": *

#anchor("doc-sql-set-time-zone")
= SET TIME ZONE

== Synopsis

#code-block("text", "SET TIME ZONE LOCAL
SET TIME ZONE expression")

== Description

Sets the default time zone for the current session.

If the #raw("LOCAL") option is specified, the time zone for the current session is set to the initial time zone of the session.

If the #raw("expression") option is specified:

- if the type of the #raw("expression") is a string, the time zone for the current session is set to the corresponding region-based time zone ID or the corresponding zone offset.
- if the type of the #raw("expression") is an interval, the time zone for the current session is set to the corresponding zone offset relative to UTC. It must be in the range of \[-14,14\] hours.

== Examples

Use the default time zone for the current session:

#code-block(none, "SET TIME ZONE LOCAL;")

Use a zone offset for specifying the time zone:

#code-block(none, "SET TIME ZONE '-08:00';")

Use an interval literal for specifying the time zone:

#code-block(none, "SET TIME ZONE INTERVAL '10' HOUR;
SET TIME ZONE INTERVAL -'08:00' HOUR TO MINUTE;")

Use a region-based time zone identifier for specifying the time zone:

#code-block(none, "SET TIME ZONE 'America/Los_Angeles';")

The time zone identifier to be used can be passed as the output of a function call:

#code-block(none, "SET TIME ZONE concat_ws('/', 'America', 'Los_Angeles');")

== Limitations

Setting the default time zone for the session has no effect if the #raw("sql.forced-session-time-zone") configuration property is already set.

== See also

- #link(label("fn-current-timezone"), raw("current_timezone"))
