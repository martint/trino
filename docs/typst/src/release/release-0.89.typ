#import "/lib/trino-docs.typ": *

#anchor("doc-release-release-0-89")
= Release 0.89

== DATE type

The memory representation of dates is now the number of days since January 1, 1970 using a 32-bit signed integer.

#note[
This is a backwards incompatible change with the previous date representation, so if you have written a connector, you will need to update your code before deploying this release.
]

== General

- #raw("USE CATALOG") and #raw("USE SCHEMA") have been replaced with #link(label("doc-sql-use"))[USE].
- Fix issue where #raw("SELECT NULL") incorrectly returns 0 rows.
- Fix rare condition where #raw("JOIN") queries could produce incorrect results.
- Fix issue where #raw("UNION") queries involving complex types would fail during planning.
