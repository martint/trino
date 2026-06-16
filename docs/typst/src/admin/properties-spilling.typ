#import "/lib/trino-docs.typ": *

#anchor("doc-admin-properties-spilling")
= Spilling properties

These properties control spill.

== #raw("spill-enabled")

- #strong[Type:] #link(label("ref-prop-type-boolean"))[prop-type-boolean]
- #strong[Default value:] #raw("false")
- #strong[Session property:] #raw("spill_enabled")

Try spilling memory to disk to avoid exceeding memory limits for the query.

Spilling works by offloading memory to disk. This process can allow a query with a large memory footprint to pass at the cost of slower execution times. Spilling is supported for aggregations, joins \(inner and outer\), sorting, and window functions. This property does not reduce memory usage required for other join types.

== #raw("spiller-spill-path")

- #strong[Type:] #link(label("ref-prop-type-string"))[prop-type-string]
- #strong[No default value.] Must be set when spilling is enabled

Directory where spilled content is written. It can be a comma separated list to spill simultaneously to multiple directories, which helps to utilize multiple drives installed in the system.

It is not recommended to spill to system drives. Most importantly, do not spill to the drive on which the JVM logs are written, as disk overutilization might cause JVM to pause for lengthy periods, causing queries to fail.

== #raw("spiller-max-used-space-threshold")

- #strong[Type:] #link(label("ref-prop-type-double"))[prop-type-double]
- #strong[Default value:] #raw("0.9")

If disk space usage ratio of a given spill path is above this threshold, this spill path is not eligible for spilling.

== #raw("spiller-threads")

- #strong[Type:] #link(label("ref-prop-type-integer"))[prop-type-integer]
- #strong[Default value:] The number of spill directories multiplied by 2, with a minimum value of 4.

Number of spiller threads. Increase this value if the default is not able to saturate the underlying spilling device \(for example, when using RAID\).

== #raw("max-spill-per-node")

- #strong[Type:] #link(label("ref-prop-type-data-size"))[prop-type-data-size]
- #strong[Default value:] #raw("100GB")

Max spill space to use by all queries on a single node. This only needs to be configured on worker nodes.

== #raw("query-max-spill-per-node")

- #strong[Type:] #link(label("ref-prop-type-data-size"))[prop-type-data-size]
- #strong[Default value:] #raw("100GB")

Max spill space to use by a single query on a single node. This only needs to be configured on worker nodes.

== #raw("aggregation-operator-unspill-memory-limit")

- #strong[Type:] #link(label("ref-prop-type-data-size"))[prop-type-data-size]
- #strong[Default value:] #raw("4MB")

Limit for memory used for unspilling a single aggregation operator instance.

#anchor("ref-prop-spill-compression-codec")

== #raw("spill-compression-codec")

- #strong[Type:] #link(label("ref-prop-type-string"))[prop-type-string]
- #strong[Allowed values:] #raw("NONE"), #raw("LZ4"), #raw("ZSTD")
- #strong[Default value:] #raw("NONE")

The compression codec to use when spilling pages to disk.

== #raw("spill-encryption-enabled")

- #strong[Type:] #link(label("ref-prop-type-boolean"))[prop-type-boolean]
- #strong[Default value:] #raw("false")

Enables using a randomly generated secret key \(per spill file\) to encrypt and decrypt data spilled to disk.
