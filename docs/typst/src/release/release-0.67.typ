#import "/lib/trino-docs.typ": *

#anchor("doc-release-release-0-67")
= Release 0.67

- Fix resource leak in Hive connector
- Improve error categorization in event logging
- Fix planning issue with certain queries using window functions

== SPI

The #raw("ConnectorSplitSource") interface now extends #raw("Closeable").

#note[
This is a backwards incompatible change to #raw("ConnectorSplitSource") in the SPI, so if you have written a connector, you will need to update your code before deploying this release.
]
