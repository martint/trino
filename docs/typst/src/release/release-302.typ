#import "/lib/trino-docs.typ": *

#anchor("doc-release-release-302")
= Release 302 \(6 Feb 2019\)

== General

- Fix cluster starvation when wait for minimum number of workers is enabled. \(#issue("155", "https://github.com/trinodb/trino/issues/155")\)
- Fix backup of queries blocked waiting for minimum number of workers. \(#issue("155", "https://github.com/trinodb/trino/issues/155")\)
- Fix failure when preparing statements that contain a quoted reserved word as a table name. \(#issue("80", "https://github.com/trinodb/trino/issues/80")\)
- Fix query failure when spilling is triggered during certain phases of query execution. \(#issue("164", "https://github.com/trinodb/trino/issues/164")\)
- Fix #raw("SHOW CREATE VIEW") output to preserve table name quoting. \(#issue("80", "https://github.com/trinodb/trino/issues/80")\)
- Add #link(label("doc-connector-elasticsearch"))[Elasticsearch connector]. \(#issue("118", "https://github.com/trinodb/trino/issues/118")\)
- Add support for #raw("boolean") type to #link(label("fn-approx-distinct"), raw("approx_distinct")). \(#issue("82", "https://github.com/trinodb/trino/issues/82")\)
- Add support for boolean columns to #raw("EXPLAIN") with type #raw("IO"). \(#issue("157", "https://github.com/trinodb/trino/issues/157")\)
- Add #raw("SphericalGeography") type and related #link(label("doc-functions-geospatial"))[geospatial functions]. \(#issue("166", "https://github.com/trinodb/trino/issues/166")\)
- Remove deprecated system memory pool. \(#issue("168", "https://github.com/trinodb/trino/issues/168")\)
- Improve query performance for certain queries involving #raw("ROLLUP"). \(#issue("105", "https://github.com/trinodb/trino/issues/105")\)

== CLI

- Add #raw("--trace-token") option to set the trace token. \(#issue("117", "https://github.com/trinodb/trino/issues/117")\)
- Display spilled data size as part of debug information. \(#issue("161", "https://github.com/trinodb/trino/issues/161")\)

== Web UI

- Add spilled data size to query details page. \(#issue("161", "https://github.com/trinodb/trino/issues/161")\)

== Security

- Add #raw("http.server.authentication.krb5.principal-hostname") configuration option to set the hostname for the Kerberos service principal. \(#issue("146", "https://github.com/trinodb/trino/issues/146"), #issue("153", "https://github.com/trinodb/trino/issues/153")\)
- Add support for client-provided extra credentials that can be utilized by connectors. \(#issue("124", "https://github.com/trinodb/trino/issues/124")\)

== Hive connector

- Fix Parquet predicate pushdown for #raw("smallint"), #raw("tinyint") types. \(#issue("131", "https://github.com/trinodb/trino/issues/131")\)
- Add support for Google Cloud Storage \(GCS\). Credentials can be provided globally using the #raw("hive.gcs.json-key-file-path") configuration property, or as a client-provided extra credential named #raw("hive.gcs.oauth") if the #raw("hive.gcs.use-access-token") configuration property is enabled. \(#issue("124", "https://github.com/trinodb/trino/issues/124")\)
- Allow creating tables with the #raw("external_location") property pointing to an empty S3 directory. \(#issue("75", "https://github.com/trinodb/trino/issues/75")\)
- Reduce GC pressure from Parquet reader by constraining the maximum column read size. \(#issue("58", "https://github.com/trinodb/trino/issues/58")\)
- Reduce network utilization and latency for S3 when reading ORC or Parquet. \(#issue("142", "https://github.com/trinodb/trino/issues/142")\)

== Kafka connector

- Fix query failure when reading #raw("information_schema.columns") without an equality condition on #raw("table_name"). \(#issue("120", "https://github.com/trinodb/trino/issues/120")\)

== Redis connector

- Fix query failure when reading #raw("information_schema.columns") without an equality condition on #raw("table_name"). \(#issue("120", "https://github.com/trinodb/trino/issues/120")\)

== SPI

- Include query peak task user memory in #raw("QueryCreatedEvent") and #raw("QueryCompletedEvent"). \(#issue("163", "https://github.com/trinodb/trino/issues/163")\)
- Include plan node cost and statistics estimates in #raw("QueryCompletedEvent"). \(#issue("134", "https://github.com/trinodb/trino/issues/134")\)
- Include physical and internal network input data size in #raw("QueryCompletedEvent"). \(#issue("133", "https://github.com/trinodb/trino/issues/133")\)
