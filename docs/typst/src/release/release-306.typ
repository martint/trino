#import "/lib/trino-docs.typ": *

#anchor("doc-release-release-306")
= Release 306 \(16 Mar 2019\)

== General

- Fix planning failure for queries containing a #raw("LIMIT") after a global aggregation. \(#issue("437", "https://github.com/trinodb/trino/issues/437")\)
- Fix missing column types in #raw("EXPLAIN") output. \(#issue("328", "https://github.com/trinodb/trino/issues/328")\)
- Fix accounting of peak revocable memory reservation. \(#issue("413", "https://github.com/trinodb/trino/issues/413")\)
- Fix double memory accounting for aggregations when spilling is active. \(#issue("413", "https://github.com/trinodb/trino/issues/413")\)
- Fix excessive CPU usage that can occur when spilling for window functions. \(#issue("468", "https://github.com/trinodb/trino/issues/468")\)
- Fix incorrect view name displayed by #raw("SHOW CREATE VIEW"). \(#issue("433", "https://github.com/trinodb/trino/issues/433")\)
- Allow specifying #raw("NOT NULL") when creating tables or adding columns. \(#issue("418", "https://github.com/trinodb/trino/issues/418")\)
- Add a config option \(#raw("query.stage-count-warning-threshold")\) to specify a per-query threshold for the number of stages. When this threshold is exceeded, a #raw("TOO_MANY_STAGES") warning is raised. \(#issue("330", "https://github.com/trinodb/trino/issues/330")\)
- Support session property values with special characters \(e.g., comma or equals sign\). \(#issue("407", "https://github.com/trinodb/trino/issues/407")\)
- Remove the #raw("deprecated.legacy-unnest-array-rows") configuration option. The legacy behavior for #raw("UNNEST") of arrays containing #raw("ROW") values is no longer supported. \(#issue("430", "https://github.com/trinodb/trino/issues/430")\)
- Remove the #raw("deprecated.legacy-row-field-ordinal-access") configuration option. The legacy mechanism for accessing fields of anonymous #raw("ROW") types is no longer supported. \(#issue("428", "https://github.com/trinodb/trino/issues/428")\)
- Remove the #raw("deprecated.group-by-uses-equal") configuration option. The legacy equality semantics for #raw("GROUP BY") are not longer supported. \(#issue("432", "https://github.com/trinodb/trino/issues/432")\)
- Remove the #raw("deprecated.legacy-map-subscript"). The legacy behavior for the map subscript operator on missing keys is no longer supported. \(#issue("429", "https://github.com/trinodb/trino/issues/429")\)
- Remove the #raw("deprecated.legacy-char-to-varchar-coercion") configuration option. The legacy coercion rules between #raw("CHAR") and #raw("VARCHAR") types are no longer supported. \(#issue("431", "https://github.com/trinodb/trino/issues/431")\)
- Remove deprecated #raw("distributed_join") system property. Use #raw("join_distribution_type") instead. \(#issue("452", "https://github.com/trinodb/trino/issues/452")\)

== Hive connector

- Fix calling procedures immediately after startup, before any other queries are run. Previously, the procedure call would fail and also cause all subsequent Hive queries to fail. \(#issue("414", "https://github.com/trinodb/trino/issues/414")\)
- Improve ORC reader performance for decoding #raw("REAL") and #raw("DOUBLE") types. \(#issue("465", "https://github.com/trinodb/trino/issues/465")\)

== MySQL connector

- Allow creating or renaming tables, and adding, renaming, or dropping columns. \(#issue("418", "https://github.com/trinodb/trino/issues/418")\)

== PostgreSQL connector

- Fix predicate pushdown for PostgreSQL #raw("ENUM") type. \(#issue("408", "https://github.com/trinodb/trino/issues/408")\)
- Allow creating or renaming tables, and adding, renaming, or dropping columns. \(#issue("418", "https://github.com/trinodb/trino/issues/418")\)

== Redshift connector

- Allow creating or renaming tables, and adding, renaming, or dropping columns. \(#issue("418", "https://github.com/trinodb/trino/issues/418")\)

== SQL Server connector

- Allow creating or renaming tables, and adding, renaming, or dropping columns. \(#issue("418", "https://github.com/trinodb/trino/issues/418")\)

== Base-JDBC connector library

- Allow mapping column type to Presto type based on #raw("Block"). \(#issue("454", "https://github.com/trinodb/trino/issues/454")\)

== SPI

- Deprecate Table Layout APIs. Connectors can opt out of the legacy behavior by implementing #raw("ConnectorMetadata.usesLegacyTableLayouts()"). \(#issue("420", "https://github.com/trinodb/trino/issues/420")\)
- Add support for limit pushdown into connectors via the #raw("ConnectorMetadata.applyLimit()") method. \(#issue("421", "https://github.com/trinodb/trino/issues/421")\)
- Add time spent waiting for resources to #raw("QueryCompletedEvent"). \(#issue("461", "https://github.com/trinodb/trino/issues/461")\)
