#import "/lib/trino-docs.typ": *

#anchor("doc-admin-properties-writer-scaling")
= Writer scaling properties

Writer scaling allows Trino to dynamically scale out the number of writer tasks rather than allocating a fixed number of tasks. Additional tasks are added when the average amount of physical data per writer is above a minimum threshold, but only if the query is bottlenecked on writing.

Writer scaling is useful with connectors like Hive that produce one or more files per writer -- reducing the number of writers results in a larger average file size. However, writer scaling can have a small impact on query wall time due to the decreased writer parallelism while the writer count ramps up to match the needs of the query.

== #raw("scale-writers")

- #strong[Type:] #link(label("ref-prop-type-boolean"))[prop-type-boolean]
- #strong[Default value:] #raw("true")
- #strong[Session property:] #raw("scale_writers")

Enable writer scaling by dynamically increasing the number of writer tasks on the cluster.

#anchor("ref-prop-task-scale-writers")

== #raw("task.scale-writers.enabled")

- #strong[Type:] #link(label("ref-prop-type-boolean"))[prop-type-boolean]
- #strong[Default value:] #raw("true")
- #strong[Session property:] #raw("task_scale_writers_enabled")

Enable scaling the number of concurrent writers within a task. The maximum writer count per task for scaling is #link(label("ref-prop-task-max-writer-count"))[Task properties]. Additional writers are added only when the average amount of uncompressed data processed per writer is above the minimum threshold of #raw("writer-scaling-min-data-processed") and query is bottlenecked on writing.

== #raw("task.scale-writers.max-writer-memory-percentage")

- #strong[Type:] #link(label("ref-prop-type-double"))[prop-type-double]
- #strong[Default value:] #raw("70")
- #strong[Session property:] #raw("task_scale_writers_max_writer_memory_percentage")

Maximum percentage of memory per node that can be used by concurrent writers within a task before stopping writer scaling. This value must be between #raw("0.0") and #raw("100.0"). When the total memory used exceeds this percentage of the maximum memory per node, writer scaling is paused to prevent out-of-memory errors.

#anchor("ref-writer-scaling-min-data-processed")

== #raw("writer-scaling-min-data-processed")

- #strong[Type:] #link(label("ref-prop-type-data-size"))[prop-type-data-size]
- #strong[Default value:] #raw("120MB")
- #strong[Session property:] #raw("writer_scaling_min_data_processed")

The minimum amount of uncompressed data that must be processed by a writer before another writer can be added.
