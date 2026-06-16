#import "/lib/trino-docs.typ": *

#anchor("doc-release-release-436")
= Release 436 \(11 Jan 2024\)

== General

- #breaking-marker("../release.html#breaking-changes") Require JDK 21.0.1 to run Trino, including updated #link(label("ref-jvm-config"))[Deploying Trino]. \(#issue("20010", "https://github.com/trinodb/trino/issues/20010")\)
- Improve performance by not generating redundant predicates. \(#issue("16520", "https://github.com/trinodb/trino/issues/16520")\)
- Fix query failure when invoking the #raw("json_table") function. \(#issue("20122", "https://github.com/trinodb/trino/issues/20122")\)
- Fix query hang when a #link(label("doc-udf-sql"))[SQL user-defined functions] dereferences a row field. \(#issue("19997", "https://github.com/trinodb/trino/issues/19997")\).
- Fix potential incorrect results when using the #link(label("fn-st-centroid"), raw("ST_Centroid")) and #link(label("fn-st-buffer"), raw("ST_Buffer")) functions for tiny geometries. \(#issue("20237", "https://github.com/trinodb/trino/issues/20237")\)

== Delta Lake connector

- Add support for querying files with corrupt or incorrect statistics, which can be enabled with the #raw("parquet_ignore_statistics") catalog session property. \(#issue("20228", "https://github.com/trinodb/trino/issues/20228")\)
- Improve performance of queries with selective joins on partition columns. \(#issue("20261", "https://github.com/trinodb/trino/issues/20261")\)
- Reduce the number of requests made to AWS Glue when listing tables, schemas, or functions. \(#issue("20189", "https://github.com/trinodb/trino/issues/20189")\)
- Fix incorrect results when querying Parquet files containing column indexes when the query has filters on multiple columns. \(#issue("20267", "https://github.com/trinodb/trino/issues/20267")\)

== ElasticSearch connector

- #breaking-marker("../release.html#breaking-changes") Add support for ElasticSearch #link("https://www.elastic.co/guide/en/elasticsearch/reference/current/es-release-notes.html")[version 8], and remove support for ElasticSearch version 6. \(#issue("20258", "https://github.com/trinodb/trino/issues/20258")\)
- Add #link(label("doc-connector-opensearch"))[OpenSearch connector]. \(#issue("11377", "https://github.com/trinodb/trino/issues/11377")\)

== Hive connector

- Reduce the number of requests made to AWS Glue when listing tables, schemas, or functions. \(#issue("20189", "https://github.com/trinodb/trino/issues/20189")\)
- Fix failure when reading certain Avro data with Union data types. \(#issue("20233", "https://github.com/trinodb/trino/issues/20233")\)
- Fix incorrect results when querying Parquet files containing column indexes when the query has filters on multiple columns. \(#issue("20267", "https://github.com/trinodb/trino/issues/20267")\)

== Hudi connector

- Add support for enforcing that a filter on a partition key must be present in the query. This can be enabled by with the #raw("hudi.query-partition-filter-required") configuration property or the #raw("query_partition_filter_required") catalog session property. \(#issue("19906", "https://github.com/trinodb/trino/issues/19906")\)
- Fix incorrect results when querying Parquet files containing column indexes when the query has filters on multiple columns. \(#issue("20267", "https://github.com/trinodb/trino/issues/20267")\)

== Iceberg connector

- Add support for querying files with corrupt or incorrect statistics, which can be enabled with the #raw("parquet_ignore_statistics") catalog session property. \(#issue("20228", "https://github.com/trinodb/trino/issues/20228")\)
- Improve performance of queries with selective joins on partition columns. \(#issue("20212", "https://github.com/trinodb/trino/issues/20212")\)
- Reduce the number of requests made to AWS Glue when listing tables, schemas, or functions. \(#issue("20189", "https://github.com/trinodb/trino/issues/20189")\)
- Fix potential loss of data when running multiple #raw("INSERT") queries at the same time. \(#issue("20092", "https://github.com/trinodb/trino/issues/20092")\)
- Fix incorrect results when providing a nonexistent namespace while listing namespaces. \(#issue("19980", "https://github.com/trinodb/trino/issues/19980")\)
- Fix predicate pushdown not running for Parquet files when columns have been renamed. \(#issue("18855", "https://github.com/trinodb/trino/issues/18855")\)

== SQL Server connector

- Fix incorrect results for #raw("DATETIMEOFFSET") values before the year 1400. \(#issue("16559", "https://github.com/trinodb/trino/issues/16559")\)
