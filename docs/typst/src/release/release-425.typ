#import "/lib/trino-docs.typ": *

#anchor("doc-release-release-425")
= Release 425 \(24 Aug 2023\)

== General

- Improve performance of #raw("GROUP BY"). \(#issue("18106", "https://github.com/trinodb/trino/issues/18106")\)
- Fix incorrect reporting of cumulative memory usage. \(#issue("18714", "https://github.com/trinodb/trino/issues/18714")\)

== BlackHole connector

- Remove support for materialized views. \(#issue("18628", "https://github.com/trinodb/trino/issues/18628")\)

== Delta Lake connector

- Add support for check constraints in #raw("MERGE") statements. \(#issue("15411", "https://github.com/trinodb/trino/issues/15411")\)
- Improve performance when statistics are missing from the transaction log. \(#issue("16743", "https://github.com/trinodb/trino/issues/16743")\)
- Improve memory usage accounting of the Parquet writer. \(#issue("18756", "https://github.com/trinodb/trino/issues/18756")\)
- Improve performance of #raw("DELETE") statements when they delete the whole table or when the filters only apply to partition columns. \(#issue("18332 ", "https://github.com/trinodb/trino/issues/18332 ")\)

== Hive connector

- Add support for #raw("CASCADE") option in #raw("DROP SCHEMA") statements. \(#issue("18320", "https://github.com/trinodb/trino/issues/18320")\)
- Create a new directory if the specified external location for a new table does not exist. \(#issue("17920", "https://github.com/trinodb/trino/issues/17920")\)
- Improve memory usage accounting of the Parquet writer. \(#issue("18756", "https://github.com/trinodb/trino/issues/18756")\)
- Improve performance of writing to JSON files. \(#issue("18683", "https://github.com/trinodb/trino/issues/18683")\)

== Iceberg connector

- Improve memory usage accounting of the Parquet writer. \(#issue("18756", "https://github.com/trinodb/trino/issues/18756")\)

== Kudu connector

- Add support for #raw("CASCADE") option in #raw("DROP SCHEMA") statements. \(#issue("18629", "https://github.com/trinodb/trino/issues/18629")\)

== MongoDB connector

- Add support for the #raw("Decimal128") MongoDB type. \(#issue("18722", "https://github.com/trinodb/trino/issues/18722")\)
- Add support for #raw("CASCADE") option in #raw("DROP SCHEMA") statements. \(#issue("18629", "https://github.com/trinodb/trino/issues/18629")\)
- Fix query failure when reading the value of #raw("-0") as a #raw("decimal") type. \(#issue("18777", "https://github.com/trinodb/trino/issues/18777")\)
