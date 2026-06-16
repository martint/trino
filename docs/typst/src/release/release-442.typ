#import "/lib/trino-docs.typ": *

#anchor("doc-release-release-442")
= Release 442 \(14 Mar 2024\)

== Delta Lake connector

- Fix query failure when a partition value contains forward slash characters. \(#issue("21030", "https://github.com/trinodb/trino/issues/21030")\)

== Hive connector

- Restore support for #raw("SymlinkTextInputFormat") for text formats. \(#issue("21092", "https://github.com/trinodb/trino/issues/21092")\)

== Iceberg connector

- Fix large queries failing with a #raw("NullPointerException"). \(#issue("21074", "https://github.com/trinodb/trino/issues/21074")\)

== OpenSearch connector

- Add support for configuring AWS deployment type with the #raw("opensearch.aws.deployment-type") configuration property. \(#issue("21059", "https://github.com/trinodb/trino/issues/21059")\)
