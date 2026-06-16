#import "/lib/trino-docs.typ": *

#anchor("doc-release-release-451")
= Release 451 \(27 Jun 2024\)

== General

- Add support for configuring a proxy for the S3 native filesystem with the #raw("s3.http-proxy.username"), #raw("s3.http-proxy.password"), #raw("s3.http-proxy.non-proxy-hosts"), and #raw("s3.http-proxy.preemptive-basic-auth") configuration properties. \(#issue("22207", "https://github.com/trinodb/trino/issues/22207")\)
- Add support for the #link(label("fn-t-pdf"), raw("t_pdf")) and #link(label("fn-t-cdf"), raw("t_cdf")) functions. \(#issue("22507", "https://github.com/trinodb/trino/issues/22507")\)
- Improve performance of reading JSON array data. \(#issue("22379", "https://github.com/trinodb/trino/issues/22379")\)
- Improve performance of certain queries involving the #link(label("fn-row-number"), raw("row_number")), #link(label("fn-rank"), raw("rank")), or #link(label("fn-dense-rank"), raw("dense_rank")) window functions with partitioning and filters. \(#issue("22509", "https://github.com/trinodb/trino/issues/22509")\)
- Fix error when reading empty files with the native S3 file system. \(#issue("22469", "https://github.com/trinodb/trino/issues/22469")\)
- Fix rare error where query execution could hang when fault-tolerant execution is enabled. \(#issue("22472", "https://github.com/trinodb/trino/issues/22472")\)
- Fix incorrect results for CASE expressions of the form #raw("CASE WHEN ... THEN true ELSE false END"). \(#issue("22530", "https://github.com/trinodb/trino/issues/22530")\)

== Delta Lake connector

- Improve performance of reading from Parquet files with large schemas. \(#issue("22451", "https://github.com/trinodb/trino/issues/22451")\)

== Hive connector

- Improve performance of reading from Parquet files with large schemas. \(#issue("22451", "https://github.com/trinodb/trino/issues/22451")\)

== Hudi connector

- Improve performance of reading from Parquet files with large schemas. \(#issue("22451", "https://github.com/trinodb/trino/issues/22451")\)

== Iceberg connector

- Add support for incremental refresh for basic materialized views. \(#issue("20959", "https://github.com/trinodb/trino/issues/20959")\)
- Add support for adding and dropping fields inside an array. \(#issue("22232", "https://github.com/trinodb/trino/issues/22232")\)
- Add support for specifying a resource #link("https://github.com/apache/iceberg/blob/a47937c0c1fcafe57d7dc83551d8c9a3ce0ab1b9/open-api/rest-catalog-open-api.yaml#L1449-L1455")[prefix] in the Iceberg REST catalog. \(#issue("22441", "https://github.com/trinodb/trino/issues/22441")\)
- Add support for partitioning on nested #raw("ROW") fields. \(#issue("15712", "https://github.com/trinodb/trino/issues/15712")\)
- Add support for writing Parquet Bloom filters. \(#issue("21570", "https://github.com/trinodb/trino/issues/21570")\)
- Add support for uppercase characters in the #raw("partitioning") table property. \(#issue("12668", "https://github.com/trinodb/trino/issues/12668")\)
- Improve performance of reading from Parquet files with large schemas. \(#issue("22451", "https://github.com/trinodb/trino/issues/22451")\)

== Kudu connector

- Add support for the Kudu #raw("DATE") type. \(#issue("22497", "https://github.com/trinodb/trino/issues/22497")\)
- Fix query failure when a filter is applied on a #raw("varbinary") column. \(#issue("22496", "https://github.com/trinodb/trino/issues/22496")\)

== SPI

- Add a #raw("Connector.getInitialMemoryRequirement()") API for pre-allocating memory during catalog initialization. \(#issue("22197", "https://github.com/trinodb/trino/issues/22197")\)
