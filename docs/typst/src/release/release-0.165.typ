#import "/lib/trino-docs.typ": *

#anchor("doc-release-release-0-165")
= Release 0.165

== General

- Make #raw("AT") a non-reserved keyword.
- Improve performance of #link(label("fn-transform"), raw("transform")).
- Improve exchange performance by deserializing in parallel.
- Add support for compressed exchanges. This can be enabled with the #raw("exchange.compression-enabled") config option.
- Add input and hash collision statistics to #link(label("doc-sql-explain-analyze"))[EXPLAIN ANALYZE] output.

== Hive

- Add support for MAP and ARRAY types in optimized Parquet reader.

== MySQL and PostgreSQL

- Fix connection leak on workers.
