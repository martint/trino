#import "/lib/trino-docs.typ": *

#anchor("doc-release-release-389")
= Release 389 \(7 Jul 2022\)

== General

- Improve performance of queries involving #raw("row") type or certain aggregations such as #raw("sum"), #raw("avg"), etc. \(#issue("12762", "https://github.com/trinodb/trino/issues/12762")\)
- Improve performance when spilling to disk is disabled. \(#issue("12618", "https://github.com/trinodb/trino/issues/12618")\)
- Fix potential incorrect results for queries involving non-equality filters on top of an outer join. \(#issue("13109", "https://github.com/trinodb/trino/issues/13109")\)
- Fix query failure when no arguments are passed to a table function. \(#issue("12951", "https://github.com/trinodb/trino/issues/12951")\)
- Fix potential failure when using #raw("EXPLAIN") with queries involving table functions. \(#issue("13106", "https://github.com/trinodb/trino/issues/13106")\)
- Fix potential resource leaks when calling long-running regular expression functions. \(#issue("13064", "https://github.com/trinodb/trino/issues/13064")\)

== Delta Lake connector

- Improve optimized Parquet writer performance for #link(label("ref-structural-data-types"))[non-structural data types]. \(#issue("13030", "https://github.com/trinodb/trino/issues/13030")\)
- Prevent failure when starting the server if the internal table snapshots cache is disabled. \(#issue("13086", "https://github.com/trinodb/trino/issues/13086")\)

== Elasticsearch connector

- Add #raw("raw_query") table function for full query pass-through to the connector. \(#issue("12324", "https://github.com/trinodb/trino/issues/12324")\)

== Hive connector

- Improve optimized Parquet writer performance for #link(label("ref-structural-data-types"))[non-structural data types]. \(#issue("13030", "https://github.com/trinodb/trino/issues/13030")\)

== Iceberg connector

- Improve performance when writing Parquet files with #link(label("ref-structural-data-types"))[non-structural data types]. \(#issue("13030", "https://github.com/trinodb/trino/issues/13030")\)

== MongoDB connector

- Create a collection when creating a new table. Previously, it was created when the data was written to the table for the first time. \(#issue("12892", "https://github.com/trinodb/trino/issues/12892")\)

== Phoenix connector

- Add support for Java 17. \(#issue("13108", "https://github.com/trinodb/trino/issues/13108")\)

== PostgreSQL connector

- Prevent creating a new table with a name longer than the max length. Previously, the name was truncated to the max length. \(#issue("12892", "https://github.com/trinodb/trino/issues/12892")\)

== SPI

- Remove deprecated version of #raw("ConnectorRecordSetProvider#getRecordSet"). \(#issue("13084", "https://github.com/trinodb/trino/issues/13084")\)
