#import "/lib/trino-docs.typ": *

#anchor("doc-release-release-0-84")
= Release 0.84

- Fix handling of #raw("NaN") and infinity in ARRAYs
- Fix approximate queries that use #raw("JOIN")
- Reduce excessive memory allocation and GC pressure in the coordinator
- Fix an issue where setting #raw("node-scheduler.location-aware-scheduling-enabled=false") would cause queries to fail for connectors whose splits were not remotely accessible
- Fix error when running #raw("COUNT(*)") over tables in #raw("information_schema") and #raw("sys")
