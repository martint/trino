#import "/lib/trino-docs.typ": *

#anchor("doc-release-release-0-85")
= Release 0.85

- Improve query planning performance for tables with large numbers of partitions.
- Fix issue when using #raw("JSON") values in #raw("GROUP BY") expressions.
