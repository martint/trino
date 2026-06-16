#import "/lib/trino-docs.typ": *

#anchor("doc-release-release-380")
= Release 380 \(6 May 2022\)

== General

- Enable automatic #link(label("doc-admin-properties-writer-scaling"))[writer scaling] by default. \(#issue("10614", "https://github.com/trinodb/trino/issues/10614")\)
- Improve performance of joins involving comparisons with the #raw("<"),#raw("<="), #raw(">"),#raw(">=") operators. \(#issue("12236", "https://github.com/trinodb/trino/issues/12236")\)

== Cassandra connector

- Add support for the v5 and v6 protocols. \(#issue("7729", "https://github.com/trinodb/trino/issues/7729")\)
- Removes support for v2 protocol. \(#issue("7729", "https://github.com/trinodb/trino/issues/7729")\)
- Make the #raw("cassandra.load-policy.use-dc-aware") and #raw("cassandra.load-policy.dc-aware.local-dc") catalog configuration properties mandatory. \(#issue("7729", "https://github.com/trinodb/trino/issues/7729")\)

== Hive connector

- Support table redirections from Hive to Delta Lake. \(#issue("11550", "https://github.com/trinodb/trino/issues/11550")\)
- Allow configuring a default value for the #raw("auto_purge") table property with the #raw("hive.auto-purge") catalog property. \(#issue("11749", "https://github.com/trinodb/trino/issues/11749")\)
- Allow configuration of the Hive views translation security semantics with the #raw("hive.hive-views.run-as-invoker") catalog configuration property. \(#issue("9227", "https://github.com/trinodb/trino/issues/9227")\)
- Rename catalog configuration property #raw("hive.translate-hive-views") to #raw("hive.hive-views.enabled"). The former name is still accepted. \(#issue("12238", "https://github.com/trinodb/trino/issues/12238")\)
- Rename catalog configuration property #raw("hive.legacy-hive-view-translation") to #raw("hive.hive-views.legacy-translation"). The former name is still accepted. \(#issue("12238", "https://github.com/trinodb/trino/issues/12238")\)
- Rename session property #raw("legacy_hive_view_translation") to #raw("hive_views_legacy_translation"). \(#issue("12238", "https://github.com/trinodb/trino/issues/12238")\)

== Iceberg connector

- Allow updating tables from the Iceberg v1 table format to v2 with #raw("ALTER TABLE ... SET PROPERTIES"). \(#issue("12161", "https://github.com/trinodb/trino/issues/12161")\)
- Allow changing the default #link(label("ref-iceberg-table-properties"))[file format] for a table with #raw("ALTER TABLE ... SET PROPERTIES"). \(#issue("12161", "https://github.com/trinodb/trino/issues/12161")\)
- Prevent potential corruption when a table change is interrupted by networking or timeout failures. \(#issue("10462", "https://github.com/trinodb/trino/issues/10462")\)

== MongoDB connector

- Add support for #link(label("doc-sql-alter-table"))[#raw("ALTER TABLE ... RENAME TO ...")]. \(#issue("11423", "https://github.com/trinodb/trino/issues/11423")\)
- Fix failure when reading decimal values with precision larger than 18. \(#issue("12205", "https://github.com/trinodb/trino/issues/12205")\)

== SQL Server connector

- Add support for bulk data insertion. \(#issue("12176", "https://github.com/trinodb/trino/issues/12176")\)
