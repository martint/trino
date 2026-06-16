#import "/lib/trino-docs.typ": *

#anchor("doc-release-release-445")
= Release 445 \(17 Apr 2024\)

== General

- Add support for large constant arrays. \(#issue("21566", "https://github.com/trinodb/trino/issues/21566")\)
- Add the #raw("query.dispatcher-query-pool-size") configuration property to prevent the coordinator from hanging when too many queries are being executed at once. \(#issue("20817", "https://github.com/trinodb/trino/issues/20817")\)
- Improve performance of queries selecting only catalog, schema, and name from the #raw("system.metadata.materialized_views") table. \(#issue("21448", "https://github.com/trinodb/trino/issues/21448")\)
- #breaking-marker("../release.html#breaking-changes") Remove the deprecated #raw("legacy.materialized-view-grace-period") configuration property. \(#issue("21474", "https://github.com/trinodb/trino/issues/21474")\)
- Increase the number of columns supported by #raw("MERGE") queries before failing with a #raw("MethodTooLargeException") error. \(#issue("21299", "https://github.com/trinodb/trino/issues/21299")\)
- Fix potential query hang when there is an error processing data. \(#issue("21397", "https://github.com/trinodb/trino/issues/21397")\)
- Fix possible worker crashes when running aggregation queries due to out-of-memory error. \(#issue("21425", "https://github.com/trinodb/trino/issues/21425")\)
- Fix incorrect results when performing aggregations over null values. \(#issue("21457", "https://github.com/trinodb/trino/issues/21457")\)
- Fix failure for queries containing expressions involving types that do not support the #raw("=") operator \(e.g., #raw("HyperLogLog"), #raw("Geometry"), etc.\). \(#issue("21508", "https://github.com/trinodb/trino/issues/21508")\)
- Fix incorrect results for distinct count aggregations over a constant value. \(#issue("18562", "https://github.com/trinodb/trino/issues/18562")\)
- Fix sporadic query failure when filesystem caching is enabled. \(#issue("21342", "https://github.com/trinodb/trino/issues/21342")\)
- Fix unexpected failure for join queries containing predicates that might raise an error for some inputs. \(#issue("21521", "https://github.com/trinodb/trino/issues/21521")\)

== BigQuery connector

- Add support for reading materialized views. \(#issue("21487", "https://github.com/trinodb/trino/issues/21487")\)
- Add support for using filters when materializing BigQuery views. \(#issue("21488", "https://github.com/trinodb/trino/issues/21488")\)

== Delta Lake connector

- Add support for #link(label("ref-delta-time-travel"))[time travel] queries. \(#issue("21052", "https://github.com/trinodb/trino/issues/21052")\)
- Add support for the #raw("REPLACE") modifier as part of a #raw("CREATE TABLE") statement. \(#issue("13180", "https://github.com/trinodb/trino/issues/13180")\) \(#issue("19991", "https://github.com/trinodb/trino/issues/19991")\)

== Hive connector

- Add support for creating views with custom properties. \(#issue("21401", "https://github.com/trinodb/trino/issues/21401")\)
- Add support for writing Bloom filters in Parquet files. \(#issue("20662", "https://github.com/trinodb/trino/issues/20662")\)
- #breaking-marker("../release.html#breaking-changes") Remove the deprecated #raw("PARTITION_COLUMN") and #raw("PARTITION_VALUE") arguments from the #raw("flush_metadata_cache") procedure in favor of #raw("PARTITION_COLUMNS") and #raw("PARTITION_VALUES"). \(#issue("21410", "https://github.com/trinodb/trino/issues/21410")\)

== Iceberg connector

- Deprecate the #raw("iceberg.materialized-views.hide-storage-table") configuration property. \(#issue("21485", "https://github.com/trinodb/trino/issues/21485")\)

== MongoDB connector

- Add support for #link(label("doc-admin-dynamic-filtering"))[dynamic filtering]. \(#issue("21355", "https://github.com/trinodb/trino/issues/21355")\)

== MySQL connector

- Improve performance of queries with #raw("timestamp(n)") values. \(#issue("21244", "https://github.com/trinodb/trino/issues/21244")\)

== PostgreSQL connector

- Improve performance of queries with #raw("timestamp(n)") values. \(#issue("21244", "https://github.com/trinodb/trino/issues/21244")\)

== Redis connector

- Upgrade minimum required Redis version to 5.0.14 or later. \(#issue("21455", "https://github.com/trinodb/trino/issues/21455")\)

== Snowflake connector

- Add support for pushing down execution of the #raw("variance"), #raw("var_pop"), #raw("var_samp"),#raw("covar_pop"), #raw("covar_samp"), #raw("corr"), #raw("regr_intercept"), and #raw("regr_slope") functions to the underlying database. \(#issue("21384", "https://github.com/trinodb/trino/issues/21384")\)
