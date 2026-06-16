#import "/lib/trino-docs.typ": *

#anchor("doc-admin-properties-task")
= Task properties

== #raw("task.concurrency")

- #strong[Type:] #link(label("ref-prop-type-integer"))[prop-type-integer]
- #strong[Restrictions:] Must be a power of two
- #strong[Default value:] The number of physical CPUs of the node, with a minimum value of 2 and a maximum of 32. Defaults to 8 in #link(label("doc-admin-fault-tolerant-execution"))[Fault-tolerant execution] mode.
- #strong[Session property:] #raw("task_concurrency")

Default local concurrency for parallel operators, such as joins and aggregations. This value should be adjusted up or down based on the query concurrency and worker resource utilization. Lower values are better for clusters that run many queries concurrently, because the cluster is already utilized by all the running queries, so adding more concurrency results in slow-downs due to context switching and other overhead. Higher values are better for clusters that only run one or a few queries at a time.

== #raw("task.http-response-threads")

- #strong[Type:] #link(label("ref-prop-type-integer"))[prop-type-integer]
- #strong[Minimum value:] #raw("1")
- #strong[Default value:] #raw("100")

Maximum number of threads that may be created to handle HTTP responses. Threads are created on demand and are cleaned up when idle, thus there is no overhead to a large value, if the number of requests to be handled is small. More threads may be helpful on clusters with a high number of concurrent queries, or on clusters with hundreds or thousands of workers.

== #raw("task.http-timeout-threads")

- #strong[Type:] #link(label("ref-prop-type-integer"))[prop-type-integer]
- #strong[Minimum value:] #raw("1")
- #strong[Default value:] #raw("3")

Number of threads used to handle timeouts when generating HTTP responses. This value should be increased if all the threads are frequently in use. This can be monitored via the #raw("trino.server:name=AsyncHttpExecutionMBean:TimeoutExecutor") JMX object. If #raw("ActiveCount") is always the same as #raw("PoolSize"), increase the number of threads.

== #raw("task.info-update-interval")

- #strong[Type:] #link(label("ref-prop-type-duration"))[prop-type-duration]
- #strong[Minimum value:] #raw("1ms")
- #strong[Maximum value:] #raw("10s")
- #strong[Default value:] #raw("3s")

Controls staleness of task information, which is used in scheduling. Larger values can reduce coordinator CPU load, but may result in suboptimal split scheduling.

== #raw("task.max-drivers-per-task")

- #strong[Type:] #link(label("ref-prop-type-integer"))[prop-type-integer]
- #strong[Minimum value:] #raw("1")
- #strong[Default Value:] #raw("2147483647")

Controls the maximum number of drivers a task runs concurrently. Setting this value reduces the likelihood that a task uses too many drivers and can improve concurrent query performance. This can lead to resource waste if it runs too few concurrent queries.

== #raw("task.max-partial-aggregation-memory")

- #strong[Type:] #link(label("ref-prop-type-data-size"))[prop-type-data-size]
- #strong[Default value:] #raw("16MB")

Maximum size of partial aggregation results for distributed aggregations. Increasing this value can result in less network transfer and lower CPU utilization, by allowing more groups to be kept locally before being flushed, at the cost of additional memory usage.

== #raw("task.max-worker-threads")

- #strong[Type:] #link(label("ref-prop-type-integer"))[prop-type-integer]
- #strong[Default value:] \(Node CPUs \* 2\)

Sets the number of threads used by workers to process splits. Increasing this number can improve throughput, if worker CPU utilization is low and all the threads are in use, but it causes increased heap space usage. Setting the value too high may cause a drop in performance due to a context switching. The number of active threads is available via the #raw("RunningSplits") property of the #raw("trino.execution.executor:name=TaskExecutor.RunningSplits") JMX object.

== #raw("task.min-drivers")

- #strong[Type:] #link(label("ref-prop-type-integer"))[prop-type-integer]
- #strong[Default value:] \(#raw("task.max-worker-threads") \* 2\)

The target number of running leaf splits on a worker. This is a minimum value because each leaf task is guaranteed at least #raw("3") running splits. Non-leaf tasks are also guaranteed to run in order to prevent deadlocks. A lower value may improve responsiveness for new tasks, but can result in underutilized resources. A higher value can increase resource utilization, but uses additional memory.

== #raw("task.min-drivers-per-task")

- #strong[Type:] #link(label("ref-prop-type-integer"))[prop-type-integer]
- #strong[Minimum value:] #raw("1")
- #strong[Default Value:] #raw("3")

The minimum number of drivers guaranteed to run concurrently for a single task given the task has remaining splits to process.

== #raw("task.scale-writers.enabled")

- #strong[Description:] see details at #link(label("ref-prop-task-scale-writers"))[prop-task-scale-writers]

#anchor("ref-prop-task-min-writer-count")

== #raw("task.min-writer-count")

- #strong[Type:] #link(label("ref-prop-type-integer"))[prop-type-integer]
- #strong[Default value:] #raw("1")
- #strong[Session property:] #raw("task_min_writer_count")

The number of concurrent writer threads per worker per query when #link(label("ref-preferred-write-partitioning"))[preferred partitioning] and #link(label("ref-prop-task-scale-writers"))[task writer scaling] are not used. Increasing this value may increase write speed, especially when a query is not I\/O bound and can take advantage of additional CPU for parallel writes.

Some connectors can be bottlenecked on the CPU when writing due to compression or other factors. Setting this too high may cause the cluster to become overloaded due to excessive resource utilization. Especially when the engine is inserting into a partitioned table without using #link(label("ref-preferred-write-partitioning"))[preferred partitioning]. In such case, each writer thread could write to all partitions. This can lead to out of memory error since writing to a partition allocates a certain amount of memory for buffering.

#anchor("ref-prop-task-max-writer-count")

== #raw("task.max-writer-count")

- #strong[Type:] #link(label("ref-prop-type-integer"))[prop-type-integer]
- #strong[Restrictions:] Must be a power of two
- #strong[Default value:] The number of physical CPUs of the node, with a minimum value of 2 and a maximum of 64
- #strong[Session property:] #raw("task_max_writer_count")

The number of concurrent writer threads per worker per query when either #link(label("ref-prop-task-scale-writers"))[task writer scaling] or #link(label("ref-preferred-write-partitioning"))[preferred partitioning] is used. Increasing this value may increase write speed, especially when a query is not I\/O bound and can take advantage of additional CPU for parallel writes. Some connectors can be bottlenecked on CPU when writing due to compression or other factors. Setting this too high may cause the cluster to become overloaded due to excessive resource utilization.

== #raw("task.interrupt-stuck-split-tasks-enabled")

- #strong[Type:] #link(label("ref-prop-type-boolean"))[prop-type-boolean]
- #strong[Default value:] #raw("true")

Enables Trino detecting and failing tasks containing splits that have been stuck. Can be specified by #raw("task.interrupt-stuck-split-tasks-timeout") and #raw("task.interrupt-stuck-split-tasks-detection-interval"). Only applies to threads that are blocked by the third-party Joni regular expression library.

== #raw("task.interrupt-stuck-split-tasks-warning-threshold")

- #strong[Type:] #link(label("ref-prop-type-duration"))[prop-type-duration]
- #strong[Minimum value:] #raw("1m")
- #strong[Default value:] #raw("10m")

Print out call stacks at #raw("/v1/maxActiveSplits") endpoint and generate JMX metrics for splits running longer than the threshold.

== #raw("task.interrupt-stuck-split-tasks-timeout")

- #strong[Type:] #link(label("ref-prop-type-duration"))[prop-type-duration]
- #strong[Minimum value:] #raw("3m")
- #strong[Default value:] #raw("10m")

The length of time Trino waits for a blocked split processing thread before failing the task. Only applies to threads that are blocked by the third-party Joni regular expression library.

== #raw("task.interrupt-stuck-split-tasks-detection-interval")

- #strong[Type:] #link(label("ref-prop-type-duration"))[prop-type-duration]
- #strong[Minimum value:] #raw("1m")
- #strong[Default value:] #raw("2m")

The interval of Trino checks for splits that have processing time exceeding #raw("task.interrupt-stuck-split-tasks-timeout"). Only applies to threads that are blocked by the third-party Joni regular expression library.
