#import "/lib/trino-docs.typ": *

#anchor("doc-release-release-0-144-2")
= Release 0.144.2

== General

- Fix potential memory leak in coordinator query history.
- Add #raw("driver.max-page-partitioning-buffer-size") config to control buffer size used to repartition pages for exchanges.
