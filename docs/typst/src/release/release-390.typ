#import "/lib/trino-docs.typ": *

#anchor("doc-release-release-390")
= Release 390 \(13 Jul 2022\)

== General

- Update minimum required Java version to 17.0.3. \(#issue("13014", "https://github.com/trinodb/trino/issues/13014")\)
- Add support for #link(label("doc-sql-comment"))[setting comments on views]. \(#issue("8349", "https://github.com/trinodb/trino/issues/8349")\)
- Improve performance of queries with an #raw("UNNEST") clause. \(#issue("10506", "https://github.com/trinodb/trino/issues/10506")\)
- Fix potential query failure when spilling to disk is enabled by the #raw("force-spilling-join-operator") configuration property or the #raw("force_spilling_join") session property. \(#issue("13123", "https://github.com/trinodb/trino/issues/13123")\)
- Fix incorrect results for certain join queries containing filters involving explicit or implicit casts. \(#issue("13145 ", "https://github.com/trinodb/trino/issues/13145 ")\)

== Cassandra connector

- Change mapping for Cassandra #raw("inet") type to Trino #raw("ipaddress") type. Previously, #raw("inet") was mapped to #raw("varchar"). \(#issue("851", "https://github.com/trinodb/trino/issues/851")\)
- Remove support for the #raw("cassandra.load-policy.use-token-aware"), #raw("cassandra.load-policy.shuffle-replicas"), and #raw("cassandra.load-policy.allowed-addresses") configuration properties. \(#issue("12223", "https://github.com/trinodb/trino/issues/12223")\)

== Delta Lake connector

- Add support for filtering splits based on #raw("$path") column predicates. \(#issue("13169", "https://github.com/trinodb/trino/issues/13169")\)
- Add support for Databricks runtime 10.4 LTS. \(#issue("13081", "https://github.com/trinodb/trino/issues/13081")\)
- Expose AWS Glue metastore statistics via JMX. \(#issue("13087", "https://github.com/trinodb/trino/issues/13087")\)
- Fix failure when using the Glue metastore and queries contain #raw("IS NULL") or #raw("IS NOT NULL") filters on numeric partition columns. \(#issue("13124", "https://github.com/trinodb/trino/issues/13124")\)

== Hive connector

- Expose AWS Glue metastore statistics via JMX. \(#issue("13087", "https://github.com/trinodb/trino/issues/13087")\)
- Add support for #link(label("doc-sql-comment"))[setting comments on views]. \(#issue("13147", "https://github.com/trinodb/trino/issues/13147")\)
- Fix failure when using the Glue metastore and queries contain #raw("IS NULL") or #raw("IS NOT NULL") filters on numeric partition columns. \(#issue("13124", "https://github.com/trinodb/trino/issues/13124")\)
- Fix and re-enable usage of Amazon S3 Select for uncompressed files. \(#issue("12633", "https://github.com/trinodb/trino/issues/12633")\)

== Iceberg connector

- Add #raw("added_rows_count"), #raw("existing_rows_count"), and #raw("deleted_rows_count") columns to the #raw("$manifests") table. \(#issue("10809", "https://github.com/trinodb/trino/issues/10809")\)
- Add support for #link(label("doc-sql-comment"))[setting comments on views]. \(#issue("13147", "https://github.com/trinodb/trino/issues/13147")\)
- Expose AWS Glue metastore statistics via JMX. \(#issue("13087", "https://github.com/trinodb/trino/issues/13087")\)
- Fix failure when using the Glue metastore and queries contain #raw("IS NULL") or #raw("IS NOT NULL") filters on numeric partition columns. \(#issue("13124", "https://github.com/trinodb/trino/issues/13124")\)

== Memory connector

- Add support for #link(label("doc-sql-comment"))[setting comments on views]. \(#issue("8349", "https://github.com/trinodb/trino/issues/8349")\)

== Prometheus connector

- Fix failure when reading a table without specifying a #raw("labels") column. \(#issue("12510", "https://github.com/trinodb/trino/issues/12510")\)
