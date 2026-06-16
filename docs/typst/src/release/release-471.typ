#import "/lib/trino-docs.typ": *

#anchor("doc-release-release-471")
= Release 471 \(19 Feb 2025\)

== General

- Add #link(label("doc-functions-ai"))[AI functions] for textual tasks on data using OpenAI, Anthropic, or other LLMs using Ollama as backend.  \(#issue("24963", "https://github.com/trinodb/trino/issues/24963")\)
- Include split count and total split distribution time in the #raw("EXPLAIN ANALYZE") output. \(#issue("25028", "https://github.com/trinodb/trino/issues/25028")\)
- Add support for JSON logging format to console with #raw("log.console-format=JSON"). \(#issue("25081", "https://github.com/trinodb/trino/issues/25081")\)
- Support additional Python libraries for use with Python user-defined functions. \(#issue("25058", "https://github.com/trinodb/trino/issues/25058")\)
- Improve performance for Python user-defined functions. \(#issue("25058", "https://github.com/trinodb/trino/issues/25058")\)
- Improve performance for queries involving #raw("ORDER BY ... LIMIT"). \(#issue("24937", "https://github.com/trinodb/trino/issues/24937")\)
- Prevent failures when fault-tolerant execution is configured with an exchange manager that uses Azure storage with workload identity. \(#issue("25063", "https://github.com/trinodb/trino/issues/25063")\)

== Server RPM

- Remove RPM package. Use the tarball or container image instead, or build an RPM with the setup in the #link("https://github.com/trinodb/trino-packages")[trino-packages repository]. \(#issue("24997", "https://github.com/trinodb/trino/issues/24997")\)

== Security

- Ensure that custom XML configuration files specified in the #raw("access-control.properties") file are used during Ranger access control plugin initialization. \(#issue("24887", "https://github.com/trinodb/trino/issues/24887")\)

== Delta Lake connector

- Add support for reading #raw("variant") type. \(#issue("22309", "https://github.com/trinodb/trino/issues/22309")\)
- Add #link(label("doc-object-storage-file-system-local"))[Local file system support]. \(#issue("25006", "https://github.com/trinodb/trino/issues/25006")\)
- Support reading cloned tables. \(#issue("24946", "https://github.com/trinodb/trino/issues/24946")\)
- Add support for configuring #raw("s3.storage-class") when writing objects to S3. \(#issue("24698", "https://github.com/trinodb/trino/issues/24698")\)
- Fix failures when writing large checkpoint files. \(#issue("25011", "https://github.com/trinodb/trino/issues/25011")\)

== Hive connector

- Add #link(label("doc-object-storage-file-system-local"))[Local file system support]. \(#issue("25006", "https://github.com/trinodb/trino/issues/25006")\)
- Add support for configuring #raw("s3.storage-class") when writing objects to S3. \(#issue("24698", "https://github.com/trinodb/trino/issues/24698")\)
- Fix reading restored S3 glacier objects when the configuration property #raw("hive.s3.storage-class-filter") is set to #raw("READ_NON_GLACIER_AND_RESTORED"). \(#issue("24947", "https://github.com/trinodb/trino/issues/24947")\)

== Hudi connector

- Add #link(label("doc-object-storage-file-system-local"))[Local file system support]. \(#issue("25006", "https://github.com/trinodb/trino/issues/25006")\)
- Add support for configuring #raw("s3.storage-class") when writing objects to S3. \(#issue("24698", "https://github.com/trinodb/trino/issues/24698")\)

== Iceberg connector

- Add #link(label("doc-object-storage-file-system-local"))[Local file system support]. \(#issue("25006", "https://github.com/trinodb/trino/issues/25006")\)
- Add support for #link("https://aws.amazon.com/s3/features/tables/")[S3 Tables]. \(#issue("24815", "https://github.com/trinodb/trino/issues/24815")\)
- Add support for configuring #raw("s3.storage-class") when writing objects to S3. \(#issue("24698", "https://github.com/trinodb/trino/issues/24698")\)
- Improve conflict detection to avoid failures from concurrent #raw("MERGE") queries on Iceberg tables. \(#issue("24470", "https://github.com/trinodb/trino/issues/24470")\)
- Ensure that the #raw("task.max-writer-count") configuration is respected for write operations on partitioned tables. \(#issue("25068", "https://github.com/trinodb/trino/issues/25068")\)

== MongoDB connector

- Fix failures caused by tables with case-sensitive name conflicts. \(#issue("24998", "https://github.com/trinodb/trino/issues/24998")\)

== SPI

- Remove #raw("Connector.getInitialMemoryRequirement()"). \(#issue("25055", "https://github.com/trinodb/trino/issues/25055")\)
