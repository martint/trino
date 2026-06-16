#import "/lib/trino-docs.typ": *

#anchor("doc-release-release-303")
= Release 303 \(13 Feb 2019\)

== General

- Fix incorrect padding for #raw("CHAR") values containing Unicode supplementary characters. Previously, such values would be incorrectly padded with too few spaces. \(#issue("195", "https://github.com/trinodb/trino/issues/195")\)
- Fix an issue where a union of a table with a #raw("VALUES") statement would execute on a single node,  which could lead to out of memory errors. \(#issue("207", "https://github.com/trinodb/trino/issues/207")\)
- Fix #raw("/v1/info") to report started status after all plugins have been registered and initialized. \(#issue("213", "https://github.com/trinodb/trino/issues/213")\)
- Improve performance of window functions by avoiding unnecessary data exchanges over the network. \(#issue("177", "https://github.com/trinodb/trino/issues/177")\)
- Choose the distribution type for semi joins based on cost when the #raw("join_distribution_type") session property is set to #raw("AUTOMATIC"). \(#issue("160", "https://github.com/trinodb/trino/issues/160")\)
- Expand grouped execution support to window functions, making it possible to execute them with less peak memory usage. \(#issue("169", "https://github.com/trinodb/trino/issues/169")\)

== Web UI

- Add additional details to and improve rendering of live plan. \(#issue("182", "https://github.com/trinodb/trino/issues/182")\)

== CLI

- Add #raw("--progress") option to show query progress in batch mode. \(#issue("34", "https://github.com/trinodb/trino/issues/34")\)

== Hive connector

- Fix query failure when reading Parquet data with no columns selected. This affects queries such as #raw("SELECT count(*)"). \(#issue("203", "https://github.com/trinodb/trino/issues/203")\)

== Mongo connector

- Fix failure for queries involving joins or aggregations on #raw("ObjectId") type. \(#issue("215", "https://github.com/trinodb/trino/issues/215")\)

== Base-JDBC connector library

- Allow customizing how query predicates are pushed down to the underlying database. \(#issue("109", "https://github.com/trinodb/trino/issues/109")\)
- Allow customizing how values are written to the underlying database. \(#issue("109", "https://github.com/trinodb/trino/issues/109")\)

== SPI

- Remove deprecated methods #raw("getSchemaName") and #raw("getTableName") from the #raw("SchemaTablePrefix") class. These were replaced by the #raw("getSchema") and #raw("getTable") methods. \(#issue("89", "https://github.com/trinodb/trino/issues/89")\)
- Remove deprecated variants of methods #raw("listTables") and #raw("listViews") from the #raw("ConnectorMetadata") class. \(#issue("89", "https://github.com/trinodb/trino/issues/89")\)
