#import "/lib/trino-docs.typ": *

#anchor("doc-release-release-310")
= Release 310 \(3 May 2019\)

== General

- Reduce compilation failures for expressions over types containing an extremely large number of nested types. \(#issue("537", "https://github.com/trinodb/trino/issues/537")\)
- Fix error reporting when query fails with due to running out of memory. \(#issue("696", "https://github.com/trinodb/trino/issues/696")\)
- Improve performance of #raw("JOIN") queries involving join keys of different types. \(#issue("665", "https://github.com/trinodb/trino/issues/665")\)
- Add initial and experimental support for late materialization. This feature can be enabled via #raw("experimental.work-processor-pipelines") feature config or via #raw("work_processor_pipelines") session config. Simple select queries of type #raw("SELECT ... FROM table ORDER BY cols LIMIT n") can experience significant CPU and performance improvement. \(#issue("602", "https://github.com/trinodb/trino/issues/602")\)
- Add support for #raw("FETCH FIRST") syntax. \(#issue("666", "https://github.com/trinodb/trino/issues/666")\)

== CLI

- Make the final query time consistent with query stats. \(#issue("692", "https://github.com/trinodb/trino/issues/692")\)

== Hive connector

- Ignore boolean column statistics when the count is #raw("-1"). \(#issue("241", "https://github.com/trinodb/trino/issues/241")\)
- Prevent failures for #raw("information_schema") queries when a table has an invalid storage format. \(#issue("568", "https://github.com/trinodb/trino/issues/568")\)
- Add support for assuming AWS role when accessing S3 or Glue. \(#issue("698", "https://github.com/trinodb/trino/issues/698")\)
- Add support for coercions between #raw("DECIMAL"), #raw("DOUBLE"), and #raw("REAL") for partition and table schema mismatch. \(#issue("352", "https://github.com/trinodb/trino/issues/352")\)
- Fix typo in Metastore recorder duration property name. \(#issue("711", "https://github.com/trinodb/trino/issues/711")\)

== PostgreSQL connector

- Support for the #raw("ARRAY") type has been disabled by default.  \(#issue("687", "https://github.com/trinodb/trino/issues/687")\)

== Blackhole connector

- Support having tables with same name in different Blackhole schemas. \(#issue("550", "https://github.com/trinodb/trino/issues/550")\)
