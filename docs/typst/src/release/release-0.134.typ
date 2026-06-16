#import "/lib/trino-docs.typ": *

#anchor("doc-release-release-0-134")
= Release 0.134

== General

- Add cumulative memory statistics tracking and expose the stat in the web interface.
- Remove nullability and partition key flags from #link(label("doc-sql-show-columns"))[SHOW COLUMNS].
- Remove non-standard #raw("is_partition_key") column from #raw("information_schema.columns").
- Fix performance regression in creation of #raw("DictionaryBlock").
- Fix rare memory accounting leak in queries with #raw("JOIN").

== Hive

- The comment for partition keys is now prefixed with #emph["Partition Key"].

== SPI

- Remove legacy partition API methods and classes.

#note[
This is a backwards incompatible change with the previous connector SPI. If you have written a connector and have not yet updated to the #raw("TableLayout") API, you will need to update your code before deploying this release.
]
