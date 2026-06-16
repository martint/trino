#import "/lib/trino-docs.typ": *

#anchor("doc-release-release-305")
= Release 305 \(7 Mar 2019\)

== General

- Fix failure of #link(label("doc-functions-regexp"))[Regular expression functions] for certain patterns and inputs when using the default #raw("JONI") library. \(#issue("350", "https://github.com/trinodb/trino/issues/350")\)
- Fix a rare #raw("ClassLoader") related problem for plugins providing an #raw("EventListenerFactory"). \(#issue("299", "https://github.com/trinodb/trino/issues/299")\)
- Expose #raw("join_max_broadcast_table_size") session property, which was previously hidden. \(#issue("346", "https://github.com/trinodb/trino/issues/346")\)
- Improve performance of queries when spill is enabled but not triggered. \(#issue("315", "https://github.com/trinodb/trino/issues/315")\)
- Consider estimated query peak memory when making cost based decisions. \(#issue("247", "https://github.com/trinodb/trino/issues/247")\)
- Include revocable memory in total memory stats. \(#issue("273", "https://github.com/trinodb/trino/issues/273")\)
- Add peak revocable memory to operator stats. \(#issue("273", "https://github.com/trinodb/trino/issues/273")\)
- Add #link(label("fn-st-points"), raw("ST_Points")) function to access vertices of a linestring. \(#issue("316", "https://github.com/trinodb/trino/issues/316")\)
- Add a system table #raw("system.metadata.analyze_properties") to list all #link(label("doc-sql-analyze"))[ANALYZE] properties. \(#issue("376", "https://github.com/trinodb/trino/issues/376")\)

== Resource groups

- Fix resource group selection when selector uses regular expression variables. \(#issue("373", "https://github.com/trinodb/trino/issues/373")\)

== Web UI

- Display peak revocable memory, current total memory, and peak total memory in detailed query view. \(#issue("273", "https://github.com/trinodb/trino/issues/273")\)

== CLI

- Add option to output CSV without quotes. \(#issue("319", "https://github.com/trinodb/trino/issues/319")\)

== Hive connector

- Fix handling of updated credentials for Google Cloud Storage \(GCS\). \(#issue("398", "https://github.com/trinodb/trino/issues/398")\)
- Fix calculation of bucket number for timestamps that contain a non-zero milliseconds value. Previously, data would be written into the wrong bucket, or could be incorrectly skipped on read. \(#issue("366", "https://github.com/trinodb/trino/issues/366")\)
- Allow writing ORC files compatible with Hive 2.0.0 to 2.2.0 by identifying the writer as an old version of Hive \(rather than Presto\) in the files. This can be enabled using the #raw("hive.orc.writer.use-legacy-version-number") configuration property. \(#issue("353", "https://github.com/trinodb/trino/issues/353")\)
- Support dictionary filtering for Parquet v2 files using #raw("RLE_DICTIONARY") encoding. \(#issue("251", "https://github.com/trinodb/trino/issues/251")\)
- Remove legacy writers for ORC and RCFile. \(#issue("353", "https://github.com/trinodb/trino/issues/353")\)
- Remove support for the DWRF file format. \(#issue("353", "https://github.com/trinodb/trino/issues/353")\)

== Base-JDBC connector library

- Allow access to extra credentials when opening a JDBC connection. \(#issue("281", "https://github.com/trinodb/trino/issues/281")\)
