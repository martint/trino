#import "/lib/trino-docs.typ": *

#anchor("doc-release-release-472")
= Release 472 \(5 Mar 2025\)

== General

- Color the server console output for improved readability. \(#issue("25090", "https://github.com/trinodb/trino/issues/25090")\)
- #breaking-marker("../release.html#breaking-changes") Rename HTTP client property prefixes from #raw("workerInfo") and #raw("memoryManager") to #raw("worker-info") and #raw("memory-manager"). \(#issue("25099", "https://github.com/trinodb/trino/issues/25099")\)
- Fix failure for queries with large numbers of expressions in the #raw("SELECT") clause. \(#issue("25040", "https://github.com/trinodb/trino/issues/25040")\)
- Improve performance of certain queries involving #raw("ORDER BY ... LIMIT") with subqueries. \(#issue("25138", "https://github.com/trinodb/trino/issues/25138")\)
- Fix incorrect results when passing an array that contains nulls to #raw("cosine_distance") and #raw("cosine_similarity"). \(#issue("25195", "https://github.com/trinodb/trino/issues/25195")\)
- Prevent improper use of #raw("WITH SESSION") with non-#raw("SELECT") queries. \(#issue("25112", "https://github.com/trinodb/trino/issues/25112")\)

== JDBC driver

- Provide a #raw("javax.sql.DataSource") implementation. \(#issue("24985", "https://github.com/trinodb/trino/issues/24985")\)
- Fix roles being cleared after invoking #raw("SET SESSION AUTHORIZATION") or #raw("RESET SESSION AUTHORIZATION"). \(#issue("25191", "https://github.com/trinodb/trino/issues/25191")\)

== Docker image

- Improve performance when using Snappy compression. \(#issue("25143", "https://github.com/trinodb/trino/issues/25143")\)
- Fix initialization failure for the DuckDB connector. \(#issue("25143", "https://github.com/trinodb/trino/issues/25143")\)

== BigQuery connector

- Improve performance of listing tables when #raw("bigquery.case-insensitive-name-matching") is enabled. \(#issue("25222", "https://github.com/trinodb/trino/issues/25222")\)

== Delta Lake connector

- Improve support for highly concurrent table modifications. \(#issue("25141", "https://github.com/trinodb/trino/issues/25141")\)

== Faker connector

- Add support for the #raw("row") type and generate empty values for #raw("array"), #raw("map"), and #raw("json") types. \(#issue("25120", "https://github.com/trinodb/trino/issues/25120")\)

== Iceberg connector

- Add the #raw("$partition") hidden column. \(#issue("24301", "https://github.com/trinodb/trino/issues/24301")\)
- Fix incorrect results when reading Iceberg tables after deletes were performed. \(#issue("25151", "https://github.com/trinodb/trino/issues/25151")\)

== Loki connector

- Fix connection failures with Loki version higher than 3.2.0. \(#issue("25156", "https://github.com/trinodb/trino/issues/25156")\)

== PostgreSQL connector

- Improve performance for queries involving cast of #link(label("ref-integer-data-types"))[integer types]. \(#issue("24950", "https://github.com/trinodb/trino/issues/24950")\)

== SPI

- Remove the deprecated #raw("ConnectorMetadata.addColumn(ConnectorSession session, ConnectorTableHandle tableHandle, ColumnMetadata column)") method. Use the #raw("ConnectorMetadata.addColumn(ConnectorSession session, ConnectorTableHandle tableHandle, ColumnMetadata column, ColumnPosition position)") instead. \(#issue("25163", "https://github.com/trinodb/trino/issues/25163")\)
