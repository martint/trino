#import "/lib/trino-docs.typ": *

#anchor("doc-release-release-0-187")
= Release 0.187

== General

- Fix a stability issue that may cause query failures due to a large number of HTTP requests timing out. The issue has been observed in a large deployment under stress.
