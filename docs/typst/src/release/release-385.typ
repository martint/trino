#import "/lib/trino-docs.typ": *

#anchor("doc-release-release-385")
= Release 385 \(8 Jun 2022\)

== General

- Add the #raw("json_array") and #raw("json_object") #link(label("doc-functions-json"))[JSON functions]. \(#issue("9081", "https://github.com/trinodb/trino/issues/9081")\)
- Support all types that can be cast to #raw("varchar") as parameters for the #link(label("ref-json-path-language"))[JSON path]. \(#issue("12682", "https://github.com/trinodb/trino/issues/12682")\)
- Allow #raw("CREATE TABLE LIKE") clause on a table from a different catalog if explicitly excluding table properties. \(#issue("3171", "https://github.com/trinodb/trino/issues/3171")\)
- Reduce #raw("Exceeded limit of N open writers for partitions") errors when fault-tolerant execution is enabled. \(#issue("12721", "https://github.com/trinodb/trino/issues/12721")\)

== Delta Lake connector

- Add support for the #link("https://docs.delta.io/latest/delta-batch.html#-table-properties")[appendOnly field]. \(#issue("12635", "https://github.com/trinodb/trino/issues/12635")\)
- Add support for column comments when creating a table or a column. \(#issue("12455", "https://github.com/trinodb/trino/issues/12455"), #issue("12715", "https://github.com/trinodb/trino/issues/12715")\)

== Hive connector

- Allow cancelling a query on a transactional table if it is waiting for a lock. \(#issue("11798", "https://github.com/trinodb/trino/issues/11798")\)
- Add support for selecting a compression scheme when writing Avro files via the #raw("hive.compression-codec") config property or the #raw("compression_codec") session property. \(#issue("12639", "https://github.com/trinodb/trino/issues/12639")\)

== Iceberg connector

- Improve query performance when a table consists of many small files. \(#issue("12579", "https://github.com/trinodb/trino/issues/12579")\)
- Improve query performance when performing a delete or update. \(#issue("12671", "https://github.com/trinodb/trino/issues/12671")\)
- Add support for the #raw("[VERSION | TIMESTAMP] AS OF") clause. \(#issue("10258", "https://github.com/trinodb/trino/issues/10258")\)
- Show Iceberg location and #raw("format_version") in #raw("SHOW CREATE MATERIALIZED VIEW"). \(#issue("12504", "https://github.com/trinodb/trino/issues/12504")\)

== MariaDB connector

- Add support for #raw("timestamp(p)") type. \(#issue("12200", "https://github.com/trinodb/trino/issues/12200")\)

== TPC-H connector

- Fix query failure when reading the #raw("dbgen_version") table. \(#issue("12673", "https://github.com/trinodb/trino/issues/12673")\)
