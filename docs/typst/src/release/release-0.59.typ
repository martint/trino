#import "/lib/trino-docs.typ": *

#anchor("doc-release-release-0-59")
= Release 0.59

- Fix hang in #raw("HiveSplitSource").  A query over a large table can hang in split discovery due to a bug introduced in 0.57.
