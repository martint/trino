#import "/lib/trino-docs.typ": *

#anchor("doc-admin-properties-write-partitioning")
= Write partitioning properties

#anchor("ref-preferred-write-partitioning")

== #raw("use-preferred-write-partitioning")

- #strong[Type:] #link(label("ref-prop-type-boolean"))[prop-type-boolean]
- #strong[Default value:] #raw("true")
- #strong[Session property:] #raw("use_preferred_write_partitioning")

Enable preferred write partitioning. When set to #raw("true"), each partition is written by a separate writer. For some connectors such as the Hive connector, only a single new file is written per partition, instead of multiple files. Partition writer assignments are distributed across worker nodes for parallel processing.
