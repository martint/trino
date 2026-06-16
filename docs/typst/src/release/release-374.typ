#import "/lib/trino-docs.typ": *

#anchor("doc-release-release-374")
= Release 374 \(17 Mar 2022\)

== General

- Add support for query parameters in #raw("CREATE SCHEMA"). \(#issue("11485", "https://github.com/trinodb/trino/issues/11485")\)
- Improve performance when reading from S3-based spool for #link(label("doc-admin-fault-tolerant-execution"))[fault-tolerant execution]. \(#issue("11050", "https://github.com/trinodb/trino/issues/11050")\)
- Improve performance of queries with #raw("GROUP BY") clauses. \(#issue("11392", "https://github.com/trinodb/trino/issues/11392")\)
- Improve performance of #raw("GROUP BY") with a large number of groups. \(#issue("11011", "https://github.com/trinodb/trino/issues/11011")\)
- Improve handling of queries where individual tasks require lots of memory when #raw("retry-policy") is set to #raw("TASK"). \(#issue("10432", "https://github.com/trinodb/trino/issues/10432")\)
- Produce better query plans by improving cost-based-optimizer estimates in the presence of correlated columns. \(#issue("11324", "https://github.com/trinodb/trino/issues/11324")\)
- Fix memory accounting and improve performance for queries involving certain variable-width data types such as #raw("varchar") or #raw("varbinary"). \(#issue("11315", "https://github.com/trinodb/trino/issues/11315")\)
- Fix performance regression for #raw("GROUP BY") queries. \(#issue("11234", "https://github.com/trinodb/trino/issues/11234")\)
- Fix #raw("trim"), #raw("ltrim") and #raw("rtim") function results when the argument is #raw("char") type. Previously, it returned padded results as #raw("char") type. It returns #raw("varchar") type without padding now. \(#issue("11440", "https://github.com/trinodb/trino/issues/11440")\)

== JDBC driver

- Add support for #raw("DatabaseMetaData.getImportedKeys"). \(#issue("8708", "https://github.com/trinodb/trino/issues/8708")\)
- Fix #raw("Driver.getPropertyInfo()"), and validate allowed properties. \(#issue("10624", "https://github.com/trinodb/trino/issues/10624")\)

== CLI

- Add support for selecting Vim or Emacs editing modes with the #raw("--editing-mode") command line argument. \(#issue("3377", "https://github.com/trinodb/trino/issues/3377")\)

== Cassandra connector

- Add support for #link(label("doc-sql-truncate"))[TRUNCATE TABLE]. \(#issue("11425", "https://github.com/trinodb/trino/issues/11425")\)
- Fix incorrect query results for certain complex queries. \(#issue("11083", "https://github.com/trinodb/trino/issues/11083")\)

== ClickHouse connector

- Add support for #raw("uint8"), #raw("uint16"), #raw("uint32") and #raw("uint64") types. \(#issue("11490", "https://github.com/trinodb/trino/issues/11490")\)

== Delta Lake connector

- Allow specifying STS endpoint to be used when connecting to S3. \(#issue("10169", "https://github.com/trinodb/trino/issues/10169")\)
- Fix query failures due to exhausted file system resources after #raw("DELETE") or #raw("UPDATE"). \(#issue("11418", "https://github.com/trinodb/trino/issues/11418")\)

== Hive connector

- Allow specifying STS endpoint to be used when connecting to S3. \(#issue("10169", "https://github.com/trinodb/trino/issues/10169")\)
- Fix shared metadata caching with Hive ACID tables. \(#issue("11443", "https://github.com/trinodb/trino/issues/11443")\)

== Iceberg connector

- Allow specifying STS endpoint to be used when connecting to S3. \(#issue("10169", "https://github.com/trinodb/trino/issues/10169")\)
- Add support for using Glue metastore as Iceberg catalog. \(#issue("10845", "https://github.com/trinodb/trino/issues/10845")\)

== MongoDB connector

- Add support for #link(label("doc-sql-create-schema"))[#raw("CREATE SCHEMA")] and #link(label("doc-sql-drop-schema"))[#raw("DROP SCHEMA")]. \(#issue("11409", "https://github.com/trinodb/trino/issues/11409")\)
- Add support for #link(label("doc-sql-comment"))[#raw("COMMENT ON TABLE")]. \(#issue("11424", "https://github.com/trinodb/trino/issues/11424")\)
- Add support for #link(label("doc-sql-comment"))[#raw("COMMENT ON COLUMN")]. \(#issue("11457", "https://github.com/trinodb/trino/issues/11457")\)
- Support storing a comment when adding new columns. \(#issue("11487", "https://github.com/trinodb/trino/issues/11487")\)

== PostgreSQL connector

- Improve performance of queries involving #raw("OR") with simple comparisons and #raw("LIKE") predicates by pushing predicate computation to the PostgreSQL database. \(#issue("11086", "https://github.com/trinodb/trino/issues/11086")\)
- Improve performance of aggregation queries with certain complex predicates by computing predicates and aggregations within PostgreSQL. \(#issue("11083", "https://github.com/trinodb/trino/issues/11083")\)
- Fix possible connection leak when connecting to PostgreSQL failed. \(#issue("11449", "https://github.com/trinodb/trino/issues/11449")\)

== SingleStore \(MemSQL\) connector

- The connector now uses the official Single Store JDBC Driver. As a result, #raw("connection-url") in catalog configuration files needs to be updated from #raw("jdbc:mariadb:...") to #raw("jdbc:singlestore:..."). \(#issue("10669", "https://github.com/trinodb/trino/issues/10669")\)
- Deprecate #raw("memsql") as the connector name. We recommend using #raw("singlestore") in the #raw("connector.name") configuration property. \(#issue("11459", "https://github.com/trinodb/trino/issues/11459")\)
