#import "/lib/trino-docs.typ": *

#anchor("doc-release-release-412")
= Release 412 \(5 Apr 2023\)

== General

- Add support for aggregate functions and parameters as arguments for the #link(label("ref-json-object"))[#raw("json_object()")] and #link(label("ref-json-array"))[#raw("json_array()")] functions. \(#issue("16489", "https://github.com/trinodb/trino/issues/16489"), #issue("16523", "https://github.com/trinodb/trino/issues/16523"), #issue("16525", "https://github.com/trinodb/trino/issues/16525")\)
- Expose optimizer rule execution statistics in query statistics. The number of rules for which statistics are collected can be limited with the #raw("query.reported-rule-stats-limit") configuration property. \(#issue("2578", "https://github.com/trinodb/trino/issues/2578")\)
- Add the #link(label("fn-exclude-columns"), raw("exclude_columns")) table function. \(#issue("16584", "https://github.com/trinodb/trino/issues/16584")\)
- Allow disabling the use of the cost-based optimizer to determine partitioning of a stage with the #raw("optimizer.use-cost-based-partitioning")configuration property or the #raw("use_cost_based_partitioning") session property. \(#issue("16781", "https://github.com/trinodb/trino/issues/16781")\)
- Improve performance of queries involving table functions with table arguments. \(#issue("16012", "https://github.com/trinodb/trino/issues/16012")\)
- Improve latency for small queries when fault-tolerant execution is enabled. \(#issue("16103", "https://github.com/trinodb/trino/issues/16103")\)
- Fix failure when querying a nested field of a #raw("row") type in queries involving #raw("ORDER BY ... LIMIT"). \(#issue("16768", "https://github.com/trinodb/trino/issues/16768")\)

== JDBC driver

- Allow configuring a custom DNS resolver. \(#issue("16647", "https://github.com/trinodb/trino/issues/16647")\)

== ClickHouse connector

- Improve performance of queries involving #raw("sum(DISTINCT ...)") by pushing computation down to ClickHouse. \(#issue("16452", "https://github.com/trinodb/trino/issues/16452")\)

== Delta Lake connector

- Add support for arithmetic binary expressions in table check constraints. \(#issue("16721", "https://github.com/trinodb/trino/issues/16721")\)
- Improve performance of queries that only read partition columns. \(#issue("16788", "https://github.com/trinodb/trino/issues/16788")\)

== Hive connector

- Fix query failure when bucketing or sorting column names are registered in a metastore in uppercase. \(#issue("16796", "https://github.com/trinodb/trino/issues/16796")\)
- Fix query failure when reading transactional tables with locations containing hidden directories. \(#issue("16773", "https://github.com/trinodb/trino/issues/16773")\)

== Iceberg connector

- Fix incorrect results for the #raw("migrate") procedure when the table location contains a hidden directory. \(#issue("16779", "https://github.com/trinodb/trino/issues/16779")\)

== Ignite connector

- Add support for #raw("ALTER TABLE ... ADD COLUMN"). \(#issue("16755", "https://github.com/trinodb/trino/issues/16755")\)
- Improve performance of queries involving #raw("sum(DISTINCT ...)") by pushing computation to Ignite. \(#issue("16452", "https://github.com/trinodb/trino/issues/16452")\)

== MariaDB connector

- Improve performance of queries involving #raw("sum(DISTINCT ...)") by pushing computation down to MariaDB. \(#issue("16452", "https://github.com/trinodb/trino/issues/16452")\)

== MySQL connector

- Improve performance of queries involving #raw("sum(DISTINCT ...)") by pushing computation down to MySQL. \(#issue("16452", "https://github.com/trinodb/trino/issues/16452")\)

== Oracle connector

- Improve performance of queries involving #raw("sum(DISTINCT ...)") by pushing computation down to Oracle. \(#issue("16452", "https://github.com/trinodb/trino/issues/16452")\)

== PostgreSQL connector

- Add support for #link(label("doc-sql-comment"))[table comments]. \(#issue("16135", "https://github.com/trinodb/trino/issues/16135")\)
- Improve performance of queries involving #raw("sum(DISTINCT ...)") by pushing computation down to PostgreSQL. \(#issue("16452", "https://github.com/trinodb/trino/issues/16452")\)

== Redshift connector

- Improve performance of queries involving #raw("sum(DISTINCT ...)") by pushing computation down to Redshift. \(#issue("16452", "https://github.com/trinodb/trino/issues/16452")\)

== SQL Server connector

- Improve performance of queries involving #raw("sum(DISTINCT ...)") by pushing computation down to SQL Server. \(#issue("16452", "https://github.com/trinodb/trino/issues/16452")\)

== SPI

- Allow table functions to return anonymous columns. \(#issue("16584", "https://github.com/trinodb/trino/issues/16584")\)
