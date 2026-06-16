#import "/lib/trino-docs.typ": *

#anchor("doc-release-release-432")
= Release 432 \(2 Nov 2023\)

#note[
Release notes now include a ⚠️ symbol to highlight any changes as potentially breaking changes. The following changes are considered and may require adjustments:

- Removal or renaming of configuration properties that may prevent startup or require configuration changes
- Changes to default values for configuration properties that may significantly change the behavior of a system
- Updates to the requirements for external systems or software used with Trino, such as removal of support for an old version of a data source in a connector
- Non-backwards compatible changes to the SPI which may require plugins to be updated
- Otherwise significant changes that requires specific attention from teams managing a Trino deployment
]

== General

- Improve performance of #raw("CREATE TABLE AS ... SELECT") queries that contain a redundant #raw("ORDER BY") clause. \(#issue("19547", "https://github.com/trinodb/trino/issues/19547")\)
- #breaking-marker("../release.html#breaking-changes") Remove support for late materialization, including the #raw("experimental.late-materialization.enabled") and #raw("experimental.work-processor-pipelines") configuration properties. \(#issue("19611", "https://github.com/trinodb/trino/issues/19611")\)
- Fix potential query failure when using inline functions. \(#issue("19561", "https://github.com/trinodb/trino/issues/19561")\)

== Docker image

- Update Java runtime to Java 21. \(#issue("19553", "https://github.com/trinodb/trino/issues/19553")\)

== CLI

- Fix crashes when using Homebrew's version of the #raw("stty") command. \(#issue("19549", "https://github.com/trinodb/trino/issues/19549")\)

== Delta Lake connector

- Improve performance of filtering on columns with long strings stored in Parquet files. \(#issue("19038", "https://github.com/trinodb/trino/issues/19038")\)

== Hive connector

- Improve performance of filtering on columns with long strings stored in Parquet files. \(#issue("19038", "https://github.com/trinodb/trino/issues/19038")\)

== Iceberg connector

- Add support for the #raw("register_table") and #raw("unregister_table") procedures with the REST catalog. \(#issue("15512", "https://github.com/trinodb/trino/issues/15512")\)
- Add support for the #link("https://projectnessie.org/tools/client_config/")[#raw("BEARER") authentication type] for connecting to the Nessie catalog. \(#issue("17725", "https://github.com/trinodb/trino/issues/17725")\)
- Improve performance of filtering on columns with long strings stored in Parquet files. \(#issue("19038", "https://github.com/trinodb/trino/issues/19038")\)

== MongoDB connector

- Add support for predicate pushdown on #raw("real") and #raw("double") types. \(#issue("19575", "https://github.com/trinodb/trino/issues/19575")\)

== SPI

- Add Trino version to SystemAccessControlContext. \(#issue("19585", "https://github.com/trinodb/trino/issues/19585")\)
- #breaking-marker("../release.html#breaking-changes") Remove null-suppression from RowBlock fields. Add new factory methods to create a #raw("RowBlock"), and remove the old factory methods. \(#issue("19479", "https://github.com/trinodb/trino/issues/19479")\)
