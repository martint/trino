#import "/lib/trino-docs.typ": *

#anchor("doc-release-release-459")
= Release 459 \(25 Sep 2024\)

== General

- Fix possible query failure when #raw("retry_policy") is set to #raw("TASK") and when adaptive join reordering is enabled. \(#issue("23407", "https://github.com/trinodb/trino/issues/23407")\)

== Docker image

- Update Java runtime to Java 23. \(#issue("23482", "https://github.com/trinodb/trino/issues/23482")\)

== CLI

- Display data sizes and rates with binary \(1024-based\) abbreviations such as #raw("KiB") and #raw("MiB"). Add flag #raw("--decimal-data-size") to use decimal \(1000-based\) values and abbreviations such as #raw("KB") and #raw("MB"). \(#issue("13054", "https://github.com/trinodb/trino/issues/13054")\)

== BigQuery connector

- Improve performance of queries that access only a subset of fields from nested data. \(#issue("23443", "https://github.com/trinodb/trino/issues/23443")\)
- Fix query failure when the #raw("bigquery.service-cache-ttl") property isn't #raw("0ms") and case insensitive name matching is enabled. \(#issue("23481", "https://github.com/trinodb/trino/issues/23481")\)

== ClickHouse connector

- Improve performance for queries involving conditions with #raw("varchar") data. \(#issue("23516", "https://github.com/trinodb/trino/issues/23516")\)

== Delta Lake connector

- Allow configuring maximum concurrent HTTP requests to Azure on every node in #link(label("doc-object-storage-file-system-azure"))[Azure Storage file system support] with #raw("azure.max-http-requests"). \(#issue("22915", "https://github.com/trinodb/trino/issues/22915")\)
- Add support for WASB to #link(label("doc-object-storage-file-system-azure"))[Azure Storage file system support]. \(#issue("23511", "https://github.com/trinodb/trino/issues/23511")\)
- Allow disabling caching of Delta Lake transaction logs when file system caching is enabled with the #raw("delta.fs.cache.disable-transaction-log-caching") property. \(#issue("21451", "https://github.com/trinodb/trino/issues/21451")\)
- Improve cache hit ratio for the #link(label("doc-object-storage-file-system-cache"))[File system cache]. \(#issue("23172", "https://github.com/trinodb/trino/issues/23172")\)
- Fix incorrect results when writing #link("https://docs.delta.io/latest/delta-deletion-vectors.html")[deletion vectors]. \(#issue("23229", "https://github.com/trinodb/trino/issues/23229")\)
- Fix failures for queries with containing aggregations with a #raw("DISTINCT") clause on metadata tables. \(#issue("23529", "https://github.com/trinodb/trino/issues/23529")\)

== Elasticsearch connector

- Fix failures for #raw("count(*)") queries with predicates containing non-ASCII strings. \(#issue("23425", "https://github.com/trinodb/trino/issues/23425")\)

== Hive connector

- Allow configuring maximum concurrent HTTP requests to Azure on every node in #link(label("doc-object-storage-file-system-azure"))[Azure Storage file system support] with #raw("azure.max-http-requests"). \(#issue("22915", "https://github.com/trinodb/trino/issues/22915")\)
- Add support for WASB to #link(label("doc-object-storage-file-system-azure"))[Azure Storage file system support]. \(#issue("23511", "https://github.com/trinodb/trino/issues/23511")\)
- Improve cache hit ratio for the #link(label("doc-object-storage-file-system-cache"))[File system cache]. \(#issue("23172", "https://github.com/trinodb/trino/issues/23172")\)
- Fix failures for queries with containing aggregations with a #raw("DISTINCT") clause on metadata tables. \(#issue("23529", "https://github.com/trinodb/trino/issues/23529")\)

== Hudi connector

- Allow configuring maximum concurrent HTTP requests to Azure on every node in #link(label("doc-object-storage-file-system-azure"))[Azure Storage file system support] with #raw("azure.max-http-requests"). \(#issue("22915", "https://github.com/trinodb/trino/issues/22915")\)
- Add support for WASB to #link(label("doc-object-storage-file-system-azure"))[Azure Storage file system support]. \(#issue("23511", "https://github.com/trinodb/trino/issues/23511")\)
- Fix failures for queries with containing aggregations with a #raw("DISTINCT") clause on metadata tables. \(#issue("23529", "https://github.com/trinodb/trino/issues/23529")\)

== Iceberg connector

- Allow configuring maximum concurrent HTTP requests to Azure on every node in #link(label("doc-object-storage-file-system-azure"))[Azure Storage file system support] with #raw("azure.max-http-requests"). \(#issue("22915", "https://github.com/trinodb/trino/issues/22915")\)
- Add support for WASB to #link(label("doc-object-storage-file-system-azure"))[Azure Storage file system support]. \(#issue("23511", "https://github.com/trinodb/trino/issues/23511")\)
- Improve cache hit ratio for the #link(label("doc-object-storage-file-system-cache"))[File system cache]. \(#issue("23172", "https://github.com/trinodb/trino/issues/23172")\)
- Fix failures for queries with containing aggregations with a #raw("DISTINCT") clause on metadata tables. \(#issue("23529", "https://github.com/trinodb/trino/issues/23529")\)

== Local file connector

- #breaking-marker("../release.html#breaking-changes") Remove the local file connector. \(#issue("23556", "https://github.com/trinodb/trino/issues/23556")\)

== OpenSearch connector

- Fix failures for #raw("count(*)") queries with predicates containing non-ASCII strings. \(#issue("23425", "https://github.com/trinodb/trino/issues/23425")\)

== SPI

- Add #raw("ConnectorAccessControl") argument to the #raw("ConnectorMetadata.getTableHandleForExecute") method. \(#issue("23524", "https://github.com/trinodb/trino/issues/23524")\)
