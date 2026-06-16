#import "/lib/trino-docs.typ": *

#anchor("doc-release-release-0-64")
= Release 0.64

- Fix approximate aggregation error bound calculation
- Error handling and classification improvements
- Fix #raw("GROUP BY") failure when keys are too large
- Add thread visualization UI at #raw("/ui/thread")
- Fix regression in #raw("CREATE TABLE") that can cause column data to be swapped. This bug was introduced in version 0.57.
