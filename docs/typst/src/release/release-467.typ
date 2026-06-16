#import "/lib/trino-docs.typ": *

#anchor("doc-release-release-467")
= Release 467 \(6 Dec 2024\)

== General

- Add support for the #raw("DISTINCT") clause in windowed aggregate functions. \(#issue("24352", "https://github.com/trinodb/trino/issues/24352")\)
- Allow using #raw("LISTAGG") as a windowed aggregate function. \(#issue("24366", "https://github.com/trinodb/trino/issues/24366")\)
- Change default protocol for internal communication to HTTP\/1.1 to address issues with HTTP\/2. \(#issue("24299", "https://github.com/trinodb/trino/issues/24299")\)
- Return compressed results to clients by default when using the spooling protocol. \(#issue("24332", "https://github.com/trinodb/trino/issues/24332")\)
- Add application identifier #raw("azure.application-id"), #raw("gcs.application-id"), or #raw("s3.application-id") to the storage when using the spooling protocol. \(#issue("24361", "https://github.com/trinodb/trino/issues/24361")\)
- Add support for OpenTelemetry tracing to the HTTP, Kafka, and MySQL event listener. \(#issue("24389", "https://github.com/trinodb/trino/issues/24389")\)
- Fix incorrect handling of SIGTERM signal, which prevented the server from shutting down. \(#issue("24380", "https://github.com/trinodb/trino/issues/24380")\)
- Fix query failures or missing statistics in #raw("SHOW STATS") when a connector returns #raw("NaN") values for table statistics. \(#issue("24315", "https://github.com/trinodb/trino/issues/24315")\)

== Docker image

- Remove the #raw("microdnf") package manager.  \(#issue("24281", "https://github.com/trinodb/trino/issues/24281")\)

== Iceberg connector

- Add the #raw("$all_manifests") metadata tables. \(#issue("24330", "https://github.com/trinodb/trino/issues/24330")\)
- #breaking-marker("../release.html#breaking-changes") Remove the deprecated #raw("schema") and #raw("table") arguments from the #raw("table_changes") table function. Use #raw("schema_name") and #raw("table_name") instead. \(#issue("24324", "https://github.com/trinodb/trino/issues/24324")\)
- #breaking-marker("../release.html#breaking-changes") Use the #raw("iceberg.rest-catalog.warehouse") configuration property instead of #raw("iceberg.rest-catalog.parent-namespace") with Unity catalogs. \(#issue("24269", "https://github.com/trinodb/trino/issues/24269")\)
- Fix failure when writing concurrently with #link("https://iceberg.apache.org/spec/#partition-transforms")[transformed partition] columns. \(#issue("24160", "https://github.com/trinodb/trino/issues/24160")\)
- Clean up table transaction files when #raw("CREATE TABLE") fails. \(#issue("24279", "https://github.com/trinodb/trino/issues/24279")\)

== Delta Lake

- Add the #raw("$transactions") metadata table. \(#issue("24330", "https://github.com/trinodb/trino/issues/24330")\)
- Add the #raw("operation_metrics") column to the #raw("$history") metadata table. \(#issue("24379", "https://github.com/trinodb/trino/issues/24379")\)

== SPI

- #breaking-marker("../release.html#breaking-changes") Remove the deprecated #raw("SystemAccessControlFactory#create") method. \(#issue("24382", "https://github.com/trinodb/trino/issues/24382")\)
