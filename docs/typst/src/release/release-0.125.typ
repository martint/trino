#import "/lib/trino-docs.typ": *

#anchor("doc-release-release-0-125")
= Release 0.125

== General

- Fix an issue where certain operations such as #raw("GROUP BY"), #raw("DISTINCT"), etc. on the output of a #raw("RIGHT") or #raw("FULL OUTER JOIN") can return incorrect results if they reference columns from the left relation that are also used in the join clause, and not every row from the right relation has a match.
