#import "/lib/trino-docs.typ": *

#anchor("doc-release-release-325")
= Release 325 \(14 Nov 2019\)

#warning[
There is a performance regression in this release.
]

== General

- Fix incorrect results for certain queries involving #raw("FULL") or #raw("RIGHT") joins and #raw("LATERAL"). \(#issue("1952", "https://github.com/trinodb/trino/issues/1952")\)
- Fix incorrect results when using #raw("IS DISTINCT FROM") on columns of #raw("DECIMAL") type with precision larger than 18. \(#issue("1985", "https://github.com/trinodb/trino/issues/1985")\)
- Fix query failure when row types contain a field named after a reserved SQL keyword. \(#issue("1963", "https://github.com/trinodb/trino/issues/1963")\)
- Add support for #raw("LIKE") predicate to #raw("SHOW SESSION") and #raw("SHOW FUNCTIONS"). \(#issue("1688", "https://github.com/trinodb/trino/issues/1688"), #issue("1692", "https://github.com/trinodb/trino/issues/1692")\)
- Add support for late materialization to join operations. \(#issue("1256", "https://github.com/trinodb/trino/issues/1256")\)
- Reduce number of metadata queries during planning. This change disables stats collection for non-#raw("EXPLAIN") queries. If you want to have access to such stats and cost in query completion events, you need to re-enable stats collection using the #raw("collect-plan-statistics-for-all-queries") configuration property. \(#issue("1866", "https://github.com/trinodb/trino/issues/1866")\)
- Add variant of #link(label("fn-strpos"), raw("strpos")) that returns the Nth occurrence of a substring. \(#issue("1811", "https://github.com/trinodb/trino/issues/1811")\)
- Add #link(label("fn-to-encoded-polyline"), raw("to_encoded_polyline")) and #link(label("fn-from-encoded-polyline"), raw("from_encoded_polyline")) geospatial functions. \(#issue("1827", "https://github.com/trinodb/trino/issues/1827")\)

== Web UI

- Show actual query for an #raw("EXECUTE") statement. \(#issue("1980", "https://github.com/trinodb/trino/issues/1980")\)

== Hive

- Fix incorrect behavior of #raw("CREATE TABLE") when Hive metastore is configured with #raw("metastore.create.as.acid") set to #raw("true"). \(#issue("1958", "https://github.com/trinodb/trino/issues/1958")\)
- Fix query failure when reading Parquet files that contain character data without statistics. \(#issue("1955", "https://github.com/trinodb/trino/issues/1955")\)
- Allow analyzing a subset of table columns \(rather than all columns\). \(#issue("1907", "https://github.com/trinodb/trino/issues/1907")\)
- Support overwriting unpartitioned tables for insert queries when using AWS Glue. \(#issue("1243", "https://github.com/trinodb/trino/issues/1243")\)
- Add support for reading Parquet files where the declared precision of decimal columns does not match the precision in the table or partition schema. \(#issue("1949", "https://github.com/trinodb/trino/issues/1949")\)
- Improve performance when reading Parquet files with small row groups. \(#issue("1925", "https://github.com/trinodb/trino/issues/1925")\)

== Other connectors

These changes apply to the MySQL, PostgreSQL, Redshift, and SQL Server connectors.

- Fix incorrect insertion of data when the target table has an unsupported type. \(#issue("1930", "https://github.com/trinodb/trino/issues/1930")\)
