#import "/lib/trino-docs.typ": *

#anchor("doc-release-release-433")
= Release 433 \(10 Nov 2023\)

== General

- Improve planning time and resulting plan efficiency for queries involving #raw("UNION ALL") with #raw("LIMIT"). \(#issue("19471", "https://github.com/trinodb/trino/issues/19471")\)
- Fix long query planning times for queries with multiple window functions. \(#issue("18491", "https://github.com/trinodb/trino/issues/18491")\)
- Fix resource groups not noticing updates to the #raw("softMemoryLimit") if it is changed from a percent-based value to an absolute value. \(#issue("19626", "https://github.com/trinodb/trino/issues/19626")\)
- Fix potential query failure for queries involving arrays, #raw("GROUP BY"), or #raw("DISTINCT"). \(#issue("19596", "https://github.com/trinodb/trino/issues/19596")\)

== BigQuery connector

- Fix incorrect results for queries involving projections and the #raw("query") table function. \(#issue("19570", "https://github.com/trinodb/trino/issues/19570")\)

== Delta Lake connector

- Fix query failure when reading ORC files with a #raw("DECIMAL") column that contains only null values. \(#issue("19636", "https://github.com/trinodb/trino/issues/19636")\)
- Fix possible JVM crash when reading short decimal columns in Parquet files created by Impala. \(#issue("19697", "https://github.com/trinodb/trino/issues/19697")\)

== Hive connector

- Add support for reading tables where a column's type has been changed from #raw("boolean") to #raw("varchar"). \(#issue("19571", "https://github.com/trinodb/trino/issues/19571")\)
- Add support for reading tables where a column's type has been changed from #raw("varchar") to #raw("double"). \(#issue("19517", "https://github.com/trinodb/trino/issues/19517")\)
- Add support for reading tables where a column's type has been changed from #raw("tinyint"), #raw("smallint"), #raw("integer"), or #raw("bigint") to #raw("double"). \(#issue("19520", "https://github.com/trinodb/trino/issues/19520")\)
- Add support for altering table comments in the Glue catalog. \(#issue("19073", "https://github.com/trinodb/trino/issues/19073")\)
- Fix query failure when reading ORC files with a #raw("DECIMAL") column that contains only null values. \(#issue("19636", "https://github.com/trinodb/trino/issues/19636")\)
- Fix possible JVM crash when reading short decimal columns in Parquet files created by Impala. \(#issue("19697", "https://github.com/trinodb/trino/issues/19697")\)

== Hudi connector

- Fix query failure when reading ORC files with a #raw("DECIMAL") column that contains only null values. \(#issue("19636", "https://github.com/trinodb/trino/issues/19636")\)
- Fix possible JVM crash when reading short decimal columns in Parquet files created by Impala. \(#issue("19697", "https://github.com/trinodb/trino/issues/19697")\)

== Iceberg connector

- Fix incorrect query results when querying Parquet files with dynamic filtering on #raw("UUID") columns. \(#issue("19670", "https://github.com/trinodb/trino/issues/19670")\)
- Fix query failure when reading ORC files with a #raw("DECIMAL") column that contains only null values. \(#issue("19636", "https://github.com/trinodb/trino/issues/19636")\)
- Fix possible JVM crash when reading short decimal columns in Parquet files created by Impala. \(#issue("19697", "https://github.com/trinodb/trino/issues/19697")\)
- Prevent creation of separate entries for storage tables of materialized views. \(#issue("18853", "https://github.com/trinodb/trino/issues/18853")\)

== SPI

- Add JMX metrics for event listeners through #raw("trino.eventlistener:name=EventListenerManager"). \(#issue("19623", "https://github.com/trinodb/trino/issues/19623")\)
