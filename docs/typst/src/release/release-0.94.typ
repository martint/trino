#import "/lib/trino-docs.typ": *

#anchor("doc-release-release-0-94")
= Release 0.94

== ORC memory usage

This release contains additional changes to the Presto ORC reader to favor small buffers when reading varchar and varbinary data. Some ORC files contain columns of data that are hundreds of megabytes compressed. When reading these columns, Presto would allocate a single buffer for the compressed column data, and this would cause heap fragmentation in CMS and G1 and eventually OOMs. In this release, the #raw("hive.orc.max-buffer-size") sets the maximum size for a single ORC buffer, and for larger columns we instead stream the data. This reduces heap fragmentation and excessive buffers in ORC at the expense of HDFS IOPS. The default value is #raw("8MB").

== General

- Update Hive CDH 4 connector to CDH 4.7.1
- Fix #raw("ORDER BY") with #raw("LIMIT 0")
- Fix compilation of #raw("try_cast")
- Group threads into Java thread groups to ease debugging
- Add #raw("task.min-drivers") config to help limit number of concurrent readers
