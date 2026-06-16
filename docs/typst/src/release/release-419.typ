#import "/lib/trino-docs.typ": *

#anchor("doc-release-release-419")
= Release 419 \(5 Jun 2023\)

== General

- Add the #link(label("fn-array-histogram"), raw("array_histogram")) function to find the number of occurrences of the unique elements in an array. \(#issue("14725 ", "https://github.com/trinodb/trino/issues/14725 ")\)
- Improve planning performance for queries involving joins. \(#issue("17458", "https://github.com/trinodb/trino/issues/17458")\)
- Fix query failure when the server JSON response exceeds the 5MB limit for string values. \(#issue("17557", "https://github.com/trinodb/trino/issues/17557")\)

== Web UI

- Allow uppercase or mixed case values for the #raw("web-ui.authentication.type") configuration property. \(#issue("17334", "https://github.com/trinodb/trino/issues/17334")\)

== BigQuery connector

- Add support for proxying BigQuery APIs via an HTTP\(S\) proxy. \(#issue("17508", "https://github.com/trinodb/trino/issues/17508")\)
- Improve performance of retrieving metadata from BigQuery. \(#issue("16064", "https://github.com/trinodb/trino/issues/16064")\)

== Delta Lake connector

- Support the #raw("id") and #raw("name") mapping modes when adding new columns. \(#issue("17236", "https://github.com/trinodb/trino/issues/17236")\)
- Improve performance of reading Parquet files. \(#issue("17612", "https://github.com/trinodb/trino/issues/17612")\)
- Improve performance when writing Parquet files with #link(label("ref-structural-data-types"))[structural data types]. \(#issue("17665", "https://github.com/trinodb/trino/issues/17665")\)
- Properly display the schema, table name, and location of tables being inserted into in the output of #raw("EXPLAIN") queries. \(#issue("17590", "https://github.com/trinodb/trino/issues/17590")\)
- Fix query failure when writing to a file location with a trailing #raw("/") in its name. \(#issue("17552", "https://github.com/trinodb/trino/issues/17552")\)

== Hive connector

- Add support for reading ORC files with shorthand timezone ids in the Stripe footer metadata. You can set the #raw("hive.orc.read-legacy-short-zone-id") configuration property to #raw("true") to enable this behavior. \(#issue("12303", "https://github.com/trinodb/trino/issues/12303")\)
- Improve performance of reading ORC files with Bloom filter indexes. \(#issue("17530", "https://github.com/trinodb/trino/issues/17530")\)
- Improve performance of reading Parquet files. \(#issue("17612", "https://github.com/trinodb/trino/issues/17612")\)
- Improve optimized Parquet writer performance for #link(label("ref-structural-data-types"))[structural data types]. \(#issue("17665", "https://github.com/trinodb/trino/issues/17665")\)
- Fix query failure for tables with file paths that contain non-alphanumeric characters. \(#issue("17621", "https://github.com/trinodb/trino/issues/17621")\)

== Hudi connector

- Improve performance of reading Parquet files. \(#issue("17612", "https://github.com/trinodb/trino/issues/17612")\)
- Improve performance when writing Parquet files with #link(label("ref-structural-data-types"))[structural data types]. \(#issue("17665", "https://github.com/trinodb/trino/issues/17665")\)

== Iceberg connector

- Add support for the #link(label("ref-iceberg-nessie-catalog"))[Nessie catalog]. \(#issue("11701", "https://github.com/trinodb/trino/issues/11701")\)
- Disallow use of the #raw("migrate") table procedure on Hive tables with #raw("array"), #raw("map") and #raw("row") types. Previously, this returned incorrect results after the migration. \(#issue("17587", "https://github.com/trinodb/trino/issues/17587")\)
- Improve performance of reading ORC files with Bloom filter indexes. \(#issue("17530", "https://github.com/trinodb/trino/issues/17530")\)
- Improve performance of reading Parquet files. \(#issue("17612", "https://github.com/trinodb/trino/issues/17612")\)
- Improve performance when writing Parquet files with #link(label("ref-structural-data-types"))[structural data types]. \(#issue("17665", "https://github.com/trinodb/trino/issues/17665")\)
- Improve performance of reading table statistics. \(#issue("16745", "https://github.com/trinodb/trino/issues/16745")\)

== SPI

- Remove unused #raw("NullAdaptationPolicy") from #raw("ScalarFunctionAdapter"). \(#issue("17706", "https://github.com/trinodb/trino/issues/17706")\)
