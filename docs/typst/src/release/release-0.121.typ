#import "/lib/trino-docs.typ": *

#anchor("doc-release-release-0-121")
= Release 0.121

== General

- Fix regression that causes task scheduler to not retry requests in some cases.
- Throttle task info refresher on errors.
- Fix planning failure that prevented the use of large #raw("IN") lists.
- Fix comparison of #raw("array(T)") where #raw("T") is a comparable, non-orderable type.
