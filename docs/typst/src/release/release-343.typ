#import "/lib/trino-docs.typ": *

#anchor("doc-release-release-343")
= Release 343 \(25 Sep 2020\)

== BigQuery connector

- Add support for yearly partitioned tables. \(#issue("5298", "https://github.com/trinodb/trino/issues/5298")\)

== Hive connector

- Fix query failure when read from or writing to a bucketed table containing a column of #raw("timestamp") type. \(#issue("5295", "https://github.com/trinodb/trino/issues/5295")\)

== SQL Server connector

- Improve performance of aggregation queries with #raw("stddev"), #raw("stddev_samp"), #raw("stddev_pop"), #raw("variance"), #raw("var_samp"), #raw("var_pop") aggregate functions by computing aggregations within SQL Server database. \(#issue("5299", "https://github.com/trinodb/trino/issues/5299")\)
