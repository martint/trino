#import "/lib/trino-docs.typ": *

#anchor("doc-release-release-335")
= Release 335 \(14 Jun 2020\)

== General

- Fix failure when #link(label("fn-reduce-agg"), raw("reduce_agg")) is used as a window function. \(#issue("3883", "https://github.com/trinodb/trino/issues/3883")\)
- Fix incorrect cast from #raw("TIMESTAMP") \(without time zone\) to #raw("TIME") type. \(#issue("3848", "https://github.com/trinodb/trino/issues/3848")\)
- Fix incorrect query results when converting very large #raw("TIMESTAMP") values into #raw("TIMESTAMP WITH TIME ZONE"), or when parsing very large #raw("TIMESTAMP WITH TIME ZONE") values. \(#issue("3956", "https://github.com/trinodb/trino/issues/3956")\)
- Return #raw("VARCHAR") type when #link(label("fn-substr"), raw("substr")) argument is #raw("CHAR") type. \(#issue("3599", "https://github.com/trinodb/trino/issues/3599"), #issue("3456", "https://github.com/trinodb/trino/issues/3456")\)
- Improve optimized local scheduling with regard to non-uniform data distribution. \(#issue("3922", "https://github.com/trinodb/trino/issues/3922")\)
- Add support for variable-precision #raw("TIMESTAMP") \(without time zone\) type. \(#issue("3783", "https://github.com/trinodb/trino/issues/3783")\)
- Add a variant of #link(label("fn-substring"), raw("substring")) that takes a #raw("CHAR") argument. \(#issue("3949", "https://github.com/trinodb/trino/issues/3949")\)
- Add  #raw("information_schema.role_authorization_descriptors") table that returns information about the roles granted to principals. \(#issue("3535", "https://github.com/trinodb/trino/issues/3535")\)

== Security

- Add schema access rules to #link(label("doc-security-file-system-access-control"))[File-based access control]. \(#issue("3766", "https://github.com/trinodb/trino/issues/3766")\)

== Web UI

- Fix the value displayed in the worker memory pools bar. \(#issue("3920", "https://github.com/trinodb/trino/issues/3920")\)

== Accumulo connector

- The server-side iterators are now in a JAR file named #raw("presto-accumulo-iterators"). \(#issue("3673", "https://github.com/trinodb/trino/issues/3673")\)

== Hive connector

- Collect column statistics for inserts into empty tables. \(#issue("2469", "https://github.com/trinodb/trino/issues/2469")\)
- Add support for #raw("information_schema.role_authorization_descriptors") table when using the #raw("sql-standard") security mode. \(#issue("3535", "https://github.com/trinodb/trino/issues/3535")\)
- Allow non-lowercase column names in #link(label("ref-hive-procedures"))[system.sync\_partition\_metadata] procedure. This can be enabled by passing #raw("case_sensitive=false") when invoking the procedure. \(#issue("3431", "https://github.com/trinodb/trino/issues/3431")\)
- Support caching with secured coordinator. \(#issue("3874", "https://github.com/trinodb/trino/issues/3874")\)
- Prevent caching from becoming disabled due to intermittent network failures. \(#issue("3874", "https://github.com/trinodb/trino/issues/3874")\)
- Ensure HDFS impersonation is not enabled when caching is enabled. \(#issue("3913", "https://github.com/trinodb/trino/issues/3913")\)
- Add #raw("hive.cache.ttl") and #raw("hive.cache.disk-usage-percentage") cache properties. \(#issue("3840", "https://github.com/trinodb/trino/issues/3840")\)
- Improve query performance when caching is enabled by scheduling work on nodes with cached data. \(#issue("3922", "https://github.com/trinodb/trino/issues/3922")\)
- Add support for #raw("UNIONTYPE").  This is mapped to #raw("ROW") containing a #raw("tag") field and a field for each data type in the union. For example, #raw("UNIONTYPE<INT, DOUBLE>") is mapped to #raw("ROW(tag INTEGER, field0 INTEGER, field1 DOUBLE)"). \(#issue("3483", "https://github.com/trinodb/trino/issues/3483")\)
- Make #raw("partition_values") argument to #raw("drop_stats") procedure optional. \(#issue("3937", "https://github.com/trinodb/trino/issues/3937")\)
- Add support for dynamic partition pruning to improve performance of complex queries over partitioned data. \(#issue("1072", "https://github.com/trinodb/trino/issues/1072")\)

== Phoenix connector

- Allow configuring whether #raw("DROP TABLE") is allowed. This is controlled by the new #raw("allow-drop-table") catalog configuration property and defaults to #raw("true"), compatible with the previous behavior. \(#issue("3953", "https://github.com/trinodb/trino/issues/3953")\)

== SPI

- Add support for aggregation pushdown into connectors via the #raw("ConnectorMetadata.applyAggregation()") method. \(#issue("3697", "https://github.com/trinodb/trino/issues/3697")\)
