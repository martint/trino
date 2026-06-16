#import "/lib/trino-docs.typ": *

#anchor("doc-release-release-359")
= Release 359 \(1 Jul 2021\)

== General

- Raise minimum required Java version for running Trino server to 11.0.11. \(#issue("8103", "https://github.com/trinodb/trino/issues/8103")\)
- Add support for row pattern recognition in window specification. \(#issue("8141", "https://github.com/trinodb/trino/issues/8141")\)
- Add support for #link(label("doc-sql-set-time-zone"))[SET TIME ZONE]. \(#issue("8112", "https://github.com/trinodb/trino/issues/8112")\)
- Add #link(label("fn-geometry-nearest-points"), raw("geometry_nearest_points")). \(#issue("8280", "https://github.com/trinodb/trino/issues/8280")\)
- Add #link(label("fn-current-groups"), raw("current_groups")). \(#issue("8446", "https://github.com/trinodb/trino/issues/8446")\)
- Add support for #raw("varchar"), #raw("varbinary") and #raw("date") types to #link(label("fn-make-set-digest"), raw("make_set_digest")). \(#issue("8295", "https://github.com/trinodb/trino/issues/8295")\)
- Add support for granting #raw("UPDATE") privileges. \(#issue("8279", "https://github.com/trinodb/trino/issues/8279")\)
- List materialized view columns in the #raw("information_schema.columns") table. \(#issue("8113", "https://github.com/trinodb/trino/issues/8113")\)
- Expose comments in views and materialized views in #raw("system.metadata.table_comments") correctly. \(#issue("8327", "https://github.com/trinodb/trino/issues/8327")\)
- Fix query failure for certain queries with #raw("ORDER BY ... LIMIT") on sorted data. \(#issue("8184", "https://github.com/trinodb/trino/issues/8184")\)
- Fix incorrect query results for certain queries using #raw("LIKE") with pattern against #raw("char") columns in the #raw("WHERE") clause. \(#issue("8311", "https://github.com/trinodb/trino/issues/8311")\)
- Fix planning failure when using #link(label("fn-hash-counts"), raw("hash_counts")). \(#issue("8248", "https://github.com/trinodb/trino/issues/8248")\)
- Fix error message when grouping expressions in #raw("GROUP BY") queries contain aggregations, window functions or grouping operations. \(#issue("8247", "https://github.com/trinodb/trino/issues/8247")\)

== Security

- Fix spurious impersonation check when applying user mapping for password authentication. \(#issue("7027", "https://github.com/trinodb/trino/issues/7027")\)
- Fix handling of multiple LDAP user bind patterns. \(#issue("8134", "https://github.com/trinodb/trino/issues/8134")\)

== Web UI

- Show session timezone in query details page. \(#issue("4196", "https://github.com/trinodb/trino/issues/4196")\)

== Docker image

- Add support for ARM64. \(#issue("8397", "https://github.com/trinodb/trino/issues/8397")\)

== CLI

- Add support for logging of network traffic via the #raw("--network-logging") command line option. \(#issue("8329", "https://github.com/trinodb/trino/issues/8329")\)

== BigQuery connector

- Add #raw("bigquery.views-cache-ttl") config property to allow configuring the cache expiration for BigQuery views. \(#issue("8236", "https://github.com/trinodb/trino/issues/8236")\)
- Fix incorrect results when accessing BigQuery records with wrong index. \(#issue("8183", "https://github.com/trinodb/trino/issues/8183")\)

== Elasticsearch connector

- Fix potential incorrect results when queries contain an #raw("IS NULL") predicate. \(#issue("3605", "https://github.com/trinodb/trino/issues/3605")\)
- Fix failure when multiple indexes share the same alias. \(#issue("8158", "https://github.com/trinodb/trino/issues/8158")\)

== Hive connector

- Rename #raw("hive-hadoop2") connector to #raw("hive"). \(#issue("8166", "https://github.com/trinodb/trino/issues/8166")\)
- Add support for Hive views which use #raw("GROUP BY") over a subquery that also uses #raw("GROUP BY") on matching columns. \(#issue("7635", "https://github.com/trinodb/trino/issues/7635")\)
- Add support for granting #raw("UPDATE") privileges when #raw("hive.security=sql-standard") is used. \(#issue("8279", "https://github.com/trinodb/trino/issues/8279")\)
- Add support for inserting data into CSV and TEXT tables with #raw("skip_header_line_count") table property set to 1. The same applies to creating tables with data using #raw("CREATE TABLE ... AS SELECT") syntax. \(#issue("8390", "https://github.com/trinodb/trino/issues/8390")\)
- Disallow creating CSV and TEXT tables with data if #raw("skip_header_line_count") is set to a value greater than 0. \(#issue("8373", "https://github.com/trinodb/trino/issues/8373")\)
- Fix query failure when reading from a non-ORC insert-only transactional table. \(#issue("8259", "https://github.com/trinodb/trino/issues/8259")\)
- Fix incorrect results when reading ORC ACID tables containing deleted rows. \(#issue("8208", "https://github.com/trinodb/trino/issues/8208")\)
- Respect #raw("hive.metastore.glue.get-partition-threads") configuration property. \(#issue("8320", "https://github.com/trinodb/trino/issues/8320")\)

== Iceberg connector

- Do not include Hive views in #raw("SHOW TABLES") query results. \(#issue("8153", "https://github.com/trinodb/trino/issues/8153")\)

== MongoDB connector

- Skip creating an index for the #raw("_schema") collection if it already exists. \(#issue("8264", "https://github.com/trinodb/trino/issues/8264")\)

== MySQL connector

- Support reading and writing #raw("timestamp") values with precision higher than 3. \(#issue("6910", "https://github.com/trinodb/trino/issues/6910")\)
- Support predicate pushdown on #raw("timestamp") columns. \(#issue("7413", "https://github.com/trinodb/trino/issues/7413")\)
- Handle #raw("timestamp") values during forward offset changes \('gaps' in DST\) correctly. \(#issue("5449", "https://github.com/trinodb/trino/issues/5449")\)

== SPI

- Introduce #raw("ConnectorMetadata#listMaterializedViews") for listing materialized view names. \(#issue("8113", "https://github.com/trinodb/trino/issues/8113")\)
- Introduce #raw("ConnectorMetadata#getMaterializedViews") for getting materialized view definitions. \(#issue("8113", "https://github.com/trinodb/trino/issues/8113")\)
- Enable connector to delegate materialized view refresh to itself. \(#issue("7960", "https://github.com/trinodb/trino/issues/7960")\)
- Allow computing HyperLogLog based approximate set summary as a column statistic during #raw("ConnectorMetadata") driven statistics collection flow. \(#issue("8355", "https://github.com/trinodb/trino/issues/8355")\)
- Report output column types through #raw("EventListener"). \(#issue("8405", "https://github.com/trinodb/trino/issues/8405")\)
- Report input column information for queries involving set operations \(#raw("UNION"), #raw("INTERSECT") and #raw("EXCEPT")\). \(#issue("8371", "https://github.com/trinodb/trino/issues/8371")\)
