#import "/lib/trino-docs.typ": *

#anchor("doc-release-release-0-144-6")
= Release 0.144.6

== General

This release fixes several problems with large and negative intervals.

- Fix parsing of negative interval literals. Previously, the sign of each field was treated independently instead of applying to the entire interval value. For example, the literal #raw("INTERVAL '-2-3' YEAR TO MONTH") was interpreted as a negative interval of #raw("21") months rather than #raw("27") months \(positive #raw("3") months was added to negative #raw("24") months\).
- Fix handling of #raw("INTERVAL DAY TO SECOND") type in REST API. Previously, intervals greater than #raw("2,147,483,647") milliseconds \(about #raw("24") days\) were returned as the wrong value.
- Fix handling of #raw("INTERVAL YEAR TO MONTH") type. Previously, intervals greater than #raw("2,147,483,647") months were returned as the wrong value from the REST API and parsed incorrectly when specified as a literal.
- Fix formatting of negative intervals in REST API. Previously, negative intervals had a negative sign before each component and could not be parsed.
- Fix formatting of negative intervals in JDBC #raw("PrestoInterval") classes.

#note[
Older versions of the JDBC driver will misinterpret most negative intervals from new servers. Make sure to update the JDBC driver along with the server.
]
