#import "/lib/trino-docs.typ": *

#anchor("doc-release-release-323")
= Release 323 \(23 Oct 2019\)

== General

- Fix query failure when referencing columns from a table that contains hidden columns. \(#issue("1796", "https://github.com/trinodb/trino/issues/1796")\)
- Fix a rare issue in which the server produces an extra row containing the boolean value #raw("true") as the last row in the result set. For most queries, this will result in a client error, since this row does not match the result schema, but is a correctness issue when the result schema is a single boolean column. \(#issue("1732", "https://github.com/trinodb/trino/issues/1732")\)
- Allow using #raw(".*") on expressions of type #raw("ROW") in the #raw("SELECT") clause to convert the fields of a row into multiple columns. \(#issue("1017", "https://github.com/trinodb/trino/issues/1017")\)

== JDBC driver

- Fix a compatibility issue when connecting to pre-321 servers. \(#issue("1785", "https://github.com/trinodb/trino/issues/1785")\)
- Fix reporting of views in #raw("DatabaseMetaData.getTables()"). \(#issue("1488", "https://github.com/trinodb/trino/issues/1488")\)

== CLI

- Fix a compatibility issue when connecting to pre-321 servers. \(#issue("1785", "https://github.com/trinodb/trino/issues/1785")\)

== Hive

- Fix the ORC writer to correctly write the file footers. Previously written files were sometimes unreadable in Hive 3.1 when querying the table for a second \(or subsequent\) time. \(#issue("456", "https://github.com/trinodb/trino/issues/456")\)
- Prevent writing to materialized views. \(#issue("1725", "https://github.com/trinodb/trino/issues/1725")\)
- Reduce metastore load when inserting data or analyzing tables. \(#issue("1783", "https://github.com/trinodb/trino/issues/1783"), #issue("1793", "https://github.com/trinodb/trino/issues/1793"), #issue("1794", "https://github.com/trinodb/trino/issues/1794")\)
- Allow using multiple Hive catalogs that use different Kerberos or other authentication configurations. \(#issue("760", "https://github.com/trinodb/trino/issues/760"), #issue("978", "https://github.com/trinodb/trino/issues/978"), #issue("1820", "https://github.com/trinodb/trino/issues/1820")\)

== PostgreSQL

- Support for PostgreSQL arrays is no longer considered experimental, therefore the configuration property #raw("postgresql.experimental.array-mapping") is now named to #raw("postgresql.array-mapping"). \(#issue("1740", "https://github.com/trinodb/trino/issues/1740")\)

== SPI

- Add support for unnesting dictionary blocks duration compaction. \(#issue("1761", "https://github.com/trinodb/trino/issues/1761")\)
- Change #raw("LazyBlockLoader") to directly return the loaded block. \(#issue("1744", "https://github.com/trinodb/trino/issues/1744")\)

#note[
This is a backwards incompatible changes with the previous SPI. If you have written a plugin that instantiates #raw("LazyBlock"), you will need to update your code before deploying this release.
]
