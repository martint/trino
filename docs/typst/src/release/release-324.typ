#import "/lib/trino-docs.typ": *

#anchor("doc-release-release-324")
= Release 324 \(1 Nov 2019\)

== General

- Fix query failure when #raw("CASE") operands have different types. \(#issue("1825", "https://github.com/trinodb/trino/issues/1825")\)
- Add support for #raw("ESCAPE") clause in #raw("SHOW CATALOGS LIKE ..."). \(#issue("1691", "https://github.com/trinodb/trino/issues/1691")\)
- Add #link(label("fn-line-interpolate-point"), raw("line_interpolate_point")) and #link(label("fn-line-interpolate-points"), raw("line_interpolate_points")). \(#issue("1888", "https://github.com/trinodb/trino/issues/1888")\)
- Allow references to tables in the enclosing query when using #raw(".*"). \(#issue("1867", "https://github.com/trinodb/trino/issues/1867")\)
- Configuration properties for optimizer and spill support no longer have #raw("experimental.") prefix. \(#issue("1875", "https://github.com/trinodb/trino/issues/1875")\)
- Configuration property #raw("experimental.reserved-pool-enabled") was renamed to #raw("experimental.reserved-pool-disabled") \(with meaning reversed\). \(#issue("1916", "https://github.com/trinodb/trino/issues/1916")\)

== Security

- Perform access control checks when displaying table or view definitions with #raw("SHOW CREATE"). \(#issue("1517", "https://github.com/trinodb/trino/issues/1517")\)

== Hive

- Allow using #raw("SHOW GRANTS") on a Hive view when using the #raw("sql-standard") security mode. \(#issue("1842", "https://github.com/trinodb/trino/issues/1842")\)
- Improve performance when filtering dictionary-encoded Parquet columns. \(#issue("1846", "https://github.com/trinodb/trino/issues/1846")\)

== PostgreSQL

- Add support for inserting #raw("MAP(VARCHAR, VARCHAR)") values into columns of #raw("hstore") type. \(#issue("1894", "https://github.com/trinodb/trino/issues/1894")\)

== Elasticsearch

- Fix failure when reading datetime columns in Elasticsearch 5.x. \(#issue("1844", "https://github.com/trinodb/trino/issues/1844")\)
- Add support for mixed-case field names. \(#issue("1914", "https://github.com/trinodb/trino/issues/1914")\)

== SPI

- Introduce a builder for #raw("ColumnMetadata"). The various overloaded constructors are now deprecated. \(#issue("1891", "https://github.com/trinodb/trino/issues/1891")\)
