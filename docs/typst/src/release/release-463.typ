#import "/lib/trino-docs.typ": *

#anchor("doc-release-release-463")
= Release 463 \(23 Oct 2024\)

== General

- Enable HTTP\/2 for internal communication by default. The previous behavior can be restored by setting #raw("internal-communication.http2.enabled") to #raw("false"). \(#issue("21793", "https://github.com/trinodb/trino/issues/21793")\)
- Support connecting over HTTP\/2 for client drivers and client applications. \(#issue("21793", "https://github.com/trinodb/trino/issues/21793")\)
- Add #link(label("fn-timezone"), raw("timezone")) functions to extract the timezone identifier from from a #raw("timestamp(p) with time zone") or #raw("time(p) with time zone"). \(#issue("20893", "https://github.com/trinodb/trino/issues/20893")\)
- Include table functions with #raw("SHOW FUNCTIONS") output. \(#issue("12550", "https://github.com/trinodb/trino/issues/12550")\)
- Print peak memory usage in #raw("EXPLAIN ANALYZE") output. \(#issue("23874", "https://github.com/trinodb/trino/issues/23874")\)
- Disallow the window framing clause for #link(label("fn-ntile"), raw("ntile")), #link(label("fn-rank"), raw("rank")), #link(label("fn-dense-rank"), raw("dense_rank")), #link(label("fn-percent-rank"), raw("percent_rank")),  #link(label("fn-cume-dist"), raw("cume_dist")), and #link(label("fn-row-number"), raw("row_number")). \(#issue("23742", "https://github.com/trinodb/trino/issues/23742")\)

== JDBC driver

- Support connecting over HTTP\/2. \(#issue("21793", "https://github.com/trinodb/trino/issues/21793")\)

== CLI

- Support connecting over HTTP\/2. \(#issue("21793", "https://github.com/trinodb/trino/issues/21793")\)

== ClickHouse connector

- Improve performance for queries with #raw("IS NULL") expressions. \(#issue("23459", "https://github.com/trinodb/trino/issues/23459")\)

== Delta Lake connector

- Add support for writing change data feed when #link("https://docs.delta.io/latest/delta-deletion-vectors.html")[deletion vector] is enabled. \(#issue("23620", "https://github.com/trinodb/trino/issues/23620")\)

== Iceberg connector

- Add support for nested namespaces with the REST catalog. \(#issue("22916", "https://github.com/trinodb/trino/issues/22916")\)
- Add support for configuring the maximum number of rows per row-group in the ORC writer with the #raw("orc_writer_max_row_group_rows") catalog session property. \(#issue("23722", "https://github.com/trinodb/trino/issues/23722")\)
- Clean up position delete files when #raw("OPTIMIZE") is run on a subset of the table's partitions. \(#issue("23801", "https://github.com/trinodb/trino/issues/23801")\)
- Rename #raw("iceberg.add_files-procedure.enabled") catalog configuration property to #raw("iceberg.add-files-procedure.enabled"). \(#issue("23873", "https://github.com/trinodb/trino/issues/23873")\)

== SingleStore connector

- Fix incorrect column length of #raw("varchar") type in SingleStore version 8. \(#issue("23780", "https://github.com/trinodb/trino/issues/23780")\)
