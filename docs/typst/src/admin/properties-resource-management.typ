#import "/lib/trino-docs.typ": *

#anchor("doc-admin-properties-resource-management")
= Resource management properties

#anchor("ref-prop-resource-query-max-cpu-time")

== #raw("query.max-cpu-time")

- #strong[Type:] #link(label("ref-prop-type-duration"))[prop-type-duration]
- #strong[Default value:] #raw("1_000_000_000d")

This is the max amount of CPU time that a query can use across the entire cluster. Queries that exceed this limit are killed.

#anchor("ref-prop-resource-query-max-memory-per-node")

== #raw("query.max-memory-per-node")

- #strong[Type:] #link(label("ref-prop-type-heap-size"))[prop-type-heap-size]
- #strong[Default value:] \(30% of maximum heap size on the node\)

This is the max amount of user memory a query can use on a worker. User memory is allocated during execution for things that are directly attributable to, or controllable by, a user query. For example, memory used by the hash tables built during execution, memory used during sorting, etc. When the user memory allocation of a query on any worker hits this limit, it is killed.

#warning[
The sum of #link(label("ref-prop-resource-query-max-memory-per-node"))[prop-resource-query-max-memory-per-node] and #link(label("ref-prop-resource-memory-heap-headroom-per-node"))[prop-resource-memory-heap-headroom-per-node] must be less than the maximum heap size in the JVM on the node. See #link(label("ref-jvm-config"))[jvm-config].
]

#note[
Does not apply for queries with task level retries enabled \(#raw("retry-policy=TASK")\)
]

#anchor("ref-prop-resource-query-max-memory")

== #raw("query.max-memory")

- #strong[Type:] #link(label("ref-prop-type-data-size"))[prop-type-data-size]
- #strong[Default value:] #raw("20GB")

This is the max amount of user memory a query can use across the entire cluster. User memory is allocated during execution for things that are directly attributable to, or controllable by, a user query. For example, memory used by the hash tables built during execution, memory used during sorting, etc. When the user memory allocation of a query across all workers hits this limit it is killed.

#warning[
#link(label("ref-prop-resource-query-max-total-memory"))[prop-resource-query-max-total-memory] must be greater than #link(label("ref-prop-resource-query-max-memory"))[prop-resource-query-max-memory].
]

#note[
Does not apply for queries with task level retries enabled \(#raw("retry-policy=TASK")\)
]

#anchor("ref-prop-resource-query-max-total-memory")

== #raw("query.max-total-memory")

- #strong[Type:] #link(label("ref-prop-type-data-size"))[prop-type-data-size]
- #strong[Default value:] \(#raw("query.max-memory") \* 2\)

This is the max amount of memory a query can use across the entire cluster, including revocable memory. When the memory allocated by a query across all workers hits this limit it is killed. The value of #raw("query.max-total-memory") must be greater than #raw("query.max-memory").

#warning[
#link(label("ref-prop-resource-query-max-total-memory"))[prop-resource-query-max-total-memory] must be greater than #link(label("ref-prop-resource-query-max-memory"))[prop-resource-query-max-memory].
]

#note[
Does not apply for queries with task level retries enabled \(#raw("retry-policy=TASK")\)
]

#anchor("ref-prop-resource-memory-heap-headroom-per-node")

== #raw("memory.heap-headroom-per-node")

- #strong[Type:] #link(label("ref-prop-type-heap-size"))[prop-type-heap-size]
- #strong[Default value:] \(30% of maximum heap size on the node\)

This is the amount of memory set aside as headroom\/buffer in the JVM heap for allocations that are not tracked by Trino.

#warning[
The sum of #link(label("ref-prop-resource-query-max-memory-per-node"))[prop-resource-query-max-memory-per-node] and #link(label("ref-prop-resource-memory-heap-headroom-per-node"))[prop-resource-memory-heap-headroom-per-node] must be less than the maximum heap size in the JVM on the node. See #link(label("ref-jvm-config"))[jvm-config].
]

#anchor("ref-prop-resource-exchange-deduplication-buffer-size")

== #raw("exchange.deduplication-buffer-size")

- #strong[Type:] #link(label("ref-prop-type-data-size"))[prop-type-data-size]
- #strong[Default value:] #raw("32MB")

Size of the buffer used for spooled data during #link(label("doc-admin-fault-tolerant-execution"))[Fault-tolerant execution].
