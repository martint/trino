#import "/lib/trino-docs.typ": *

#anchor("doc-admin-properties-general")
= General properties

== #raw("join-distribution-type")

- #strong[Type:] #link(label("ref-prop-type-string"))[prop-type-string]
- #strong[Allowed values:] #raw("AUTOMATIC"), #raw("PARTITIONED"), #raw("BROADCAST")
- #strong[Default value:] #raw("AUTOMATIC")
- #strong[Session property:] #raw("join_distribution_type")

The type of distributed join to use.  When set to #raw("PARTITIONED"), Trino uses hash distributed joins.  When set to #raw("BROADCAST"), it broadcasts the right table to all nodes in the cluster that have data from the left table. Partitioned joins require redistributing both tables using a hash of the join key. This can be slower, sometimes substantially, than broadcast joins, but allows much larger joins. In particular broadcast joins are faster, if the right table is much smaller than the left.  However, broadcast joins require that the tables on the right side of the join after filtering fit in memory on each node, whereas distributed joins only need to fit in distributed memory across all nodes. When set to #raw("AUTOMATIC"), Trino makes a cost based decision as to which distribution type is optimal. It considers switching the left and right inputs to the join.  In #raw("AUTOMATIC") mode, Trino defaults to hash distributed joins if no cost could be computed, such as if the tables do not have statistics.

== #raw("redistribute-writes")

- #strong[Type:] #link(label("ref-prop-type-boolean"))[prop-type-boolean]
- #strong[Default value:] #raw("true")
- #strong[Session property:] #raw("redistribute_writes")

This property enables redistribution of data before writing. This can eliminate the performance impact of data skew when writing by hashing it across nodes in the cluster. It can be disabled, when it is known that the output data set is not skewed, in order to avoid the overhead of hashing and redistributing all the data across the network.

#anchor("ref-file-compression")

== File compression and decompression

Trino uses the #link("https://github.com/airlift/aircompressor")[aircompressor] library to compress and decompress ORC, Parquet, and other files using the LZ4, zstd, Snappy, and other algorithms. The library takes advantage of using embedded, higher performing, native implementations for these algorithms by default.

If necessary, this behavior can be deactivated to fall back on JVM-based implementations with the following configuration in the #link(label("ref-jvm-config"))[Deploying Trino]:

#code-block("properties", "-Dio.airlift.compress.v3.disable-native=true")

The library relies on the #link(label("ref-tmp-directory"))[temporary directory used by the JVM], including the execution of code in the directory, to load the embedded shared libraries. If this directory is mounted with #raw("noexec"), and therefore not suitable, you can configure usage of a separate directory with an absolute path set with the following configuration in the #link(label("ref-jvm-config"))[Deploying Trino]:

#code-block("properties", "-Daircompressor.tmpdir=/mnt/example")
