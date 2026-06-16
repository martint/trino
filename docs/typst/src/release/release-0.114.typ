#import "/lib/trino-docs.typ": *

#anchor("doc-release-release-0-114")
= Release 0.114

== General

- Fix #raw("%k") specifier for #link(label("fn-date-format"), raw("date_format")) and #raw("date_parse"). It previously used #raw("24") rather than #raw("0") for the midnight hour.

== Hive

- Fix ORC reader for Hive connector.
