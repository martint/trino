#import "/lib/trino-docs.typ": *

#anchor("doc-release-release-437")
= Release 437 \(24 Jan 2024\)

== General

- Add support for #raw("char(n)") values in #link(label("fn-to-utf8"), raw("to_utf8")). \(#issue("20158", "https://github.com/trinodb/trino/issues/20158")\)
- Add support for #raw("char(n)") values in #link(label("fn-lpad"), raw("lpad")). \(#issue("16907", "https://github.com/trinodb/trino/issues/16907")\)
- #breaking-marker("../release.html#breaking-changes") Replace the #raw("exchange.compression-enabled") configuration property and #raw("exchange_compression") session property with #link(label("ref-prop-exchange-compression-codec"))[the #raw("exchange.compression-codec")and #raw("exchange_compression_codec") properties], respectively. \(#issue("20274", "https://github.com/trinodb/trino/issues/20274")\)
- #breaking-marker("../release.html#breaking-changes") Replace the #raw("spill-compression-enabled") configuration property with #link(label("ref-prop-spill-compression-codec"))[the #raw("spill-compression-codec") property]. \(#issue("20274", "https://github.com/trinodb/trino/issues/20274")\)
- #breaking-marker("../release.html#breaking-changes") Remove the deprecated #raw("experimental.spill-compression-enabled") configuration property. \(#issue("20274", "https://github.com/trinodb/trino/issues/20274")\)
- Fix failure when invoking functions that may return null values. \(#issue("18456", "https://github.com/trinodb/trino/issues/18456")\)
- Fix #raw("ArrayIndexOutOfBoundsException") with RowBlockBuilder during output operations. \(#issue("20426", "https://github.com/trinodb/trino/issues/20426")\)

== Delta Lake connector

- Improve query performance for queries that don't use table statistics. \(#issue("20054", "https://github.com/trinodb/trino/issues/20054")\)

== Hive connector

- Fix error when coercing union-typed data to a single type when reading Avro files. \(#issue("20310", "https://github.com/trinodb/trino/issues/20310")\)

== Iceberg connector

- Fix materialized views being permanently stale when they reference #link(label("doc-functions-table"))[table functions]. \(#issue("19904", "https://github.com/trinodb/trino/issues/19904")\)
- Improve performance of queries with filters on #raw("ROW") columns stored in Parquet files. \(#issue("17133", "https://github.com/trinodb/trino/issues/17133")\)
