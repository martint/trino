#import "/lib/trino-docs.typ": *

#anchor("doc-admin-properties-query-management")
= Query management properties

== #raw("query.client.timeout")

- #strong[Type:] #link(label("ref-prop-type-duration"))[prop-type-duration]
- #strong[Default value:] #raw("5m")

Configures how long the cluster runs without contact from the client application, such as the CLI, before it abandons and cancels its work.

== #raw("query.execution-policy")

- #strong[Type:] #link(label("ref-prop-type-string"))[prop-type-string]
- #strong[Default value:] #raw("phased")
- #strong[Session property:] #raw("execution_policy")

Configures the algorithm to organize the processing of all the stages of a query. You can use the following execution policies:

- #raw("phased") schedules stages in a sequence to avoid blockages because of inter-stage dependencies. This policy maximizes cluster resource utilization and provides the lowest query wall time.
- #raw("all-at-once") schedules all the stages of a query at one time. As a result, cluster resource utilization is initially high, but inter-stage dependencies typically prevent full processing and cause longer queue times which increases the query wall time overall.

== #raw("query.determine-partition-count-for-write-enabled")

- #strong[Type:] #link(label("ref-prop-type-boolean"))[prop-type-boolean]
- #strong[Default value:] #raw("false")
- #strong[Session property:] #raw("determine_partition_count_for_write_enabled")

Enables determining the number of partitions based on amount of data read and processed by the query for write queries.

== #raw("query.max-hash-partition-count")

- #strong[Type:] #link(label("ref-prop-type-integer"))[prop-type-integer]
- #strong[Default value:] #raw("100")
- #strong[Session property:] #raw("max_hash_partition_count")

The maximum number of partitions to use for processing distributed operations, such as joins, aggregations, partitioned window functions and others.

== #raw("query.min-hash-partition-count")

- #strong[Type:] #link(label("ref-prop-type-integer"))[prop-type-integer]
- #strong[Default value:] #raw("4")
- #strong[Session property:] #raw("min_hash_partition_count")

The minimum number of partitions to use for processing distributed operations, such as joins, aggregations, partitioned window functions and others.

== #raw("query.min-hash-partition-count-for-write")

- #strong[Type:] #link(label("ref-prop-type-integer"))[prop-type-integer]
- #strong[Default value:] #raw("50")
- #strong[Session property:] #raw("min_hash_partition_count_for_write")

The minimum number of partitions to use for processing distributed operations in write queries, such as joins, aggregations, partitioned window functions and others.

== #raw("query.max-writer-task-count")

- #strong[Type:] #link(label("ref-prop-type-integer"))[prop-type-integer]
- #strong[Default value:] #raw("100")
- #strong[Session property:] #raw("max_writer_task_count")

The maximum number of tasks that will take part in writing data during #raw("INSERT"), #raw("CREATE TABLE AS SELECT") and #raw("EXECUTE") queries. The limit is only applicable when #raw("redistribute-writes") or #raw("scale-writers") is enabled.

== #raw("query.low-memory-killer.policy")

- #strong[Type:] #link(label("ref-prop-type-string"))[prop-type-string]
- #strong[Default value:] #raw("total-reservation-on-blocked-nodes")

Configures the behavior to handle killing running queries in the event of low memory availability. Supports the following values:

- #raw("none") - Do not kill any queries in the event of low memory.
- #raw("total-reservation") - Kill the query currently using the most total memory.
- #raw("total-reservation-on-blocked-nodes") - Kill the query currently using the most memory specifically on nodes that are now out of memory.

#note[
Only applies for queries with task level retries disabled \(#raw("retry-policy") set to #raw("NONE") or #raw("QUERY")\)
]

== #raw("task.low-memory-killer.policy")

- #strong[Type:] #link(label("ref-prop-type-string"))[prop-type-string]
- #strong[Default value:] #raw("total-reservation-on-blocked-nodes")

Configures the behavior to handle killing running tasks in the event of low memory availability. Supports the following values:

- #raw("none") - Do not kill any tasks in the event of low memory.
- #raw("total-reservation-on-blocked-nodes") - Kill the tasks that are part of the queries which have task retries enabled and are currently using the most memory specifically on nodes that are now out of memory.
- #raw("least-waste") - Kill the tasks that are part of the queries which have task retries enabled and use significant amount of memory on nodes which are now out of memory. This policy avoids killing tasks which are already executing for a long time, so significant amount of work is not wasted.

#note[
Only applies for queries with task level retries enabled \(#raw("retry-policy=TASK")\)
]

== #raw("query.max-execution-time")

- #strong[Type:] #link(label("ref-prop-type-duration"))[prop-type-duration]
- #strong[Default value:] #raw("100d")
- #strong[Session property:] #raw("query_max_execution_time")

The maximum allowed time for a query to be actively executing on the cluster, before it is terminated. Compared to the run time below, execution time does not include analysis, query planning or wait times in a queue.

== #raw("query.max-length")

- #strong[Type:] #link(label("ref-prop-type-integer"))[prop-type-integer]
- #strong[Default value:] #raw("1,000,000")
- #strong[Maximum value:] #raw("1,000,000,000")

The maximum number of characters allowed for the SQL query text. Longer queries are not processed, and terminated with error #raw("QUERY_TEXT_TOO_LARGE").

== #raw("query.max-planning-time")

- #strong[Type:] #link(label("ref-prop-type-duration"))[prop-type-duration]
- #strong[Default value:] #raw("10m")
- #strong[Session property:] #raw("query_max_planning_time")

The maximum allowed time for a query to be actively planning the execution. After this period the coordinator will make its best effort to stop the query. Note that some operations in planning phase are not easily cancellable and may not terminate immediately.

== #raw("query.max-run-time")

- #strong[Type:] #link(label("ref-prop-type-duration"))[prop-type-duration]
- #strong[Default value:] #raw("100d")
- #strong[Session property:] #raw("query_max_run_time")

The maximum allowed time for a query to be processed on the cluster, before it is terminated. The time includes time for analysis and planning, but also time spent in a queue waiting, so essentially this is the time allowed for a query to exist since creation.

== #raw("query.max-scan-physical-bytes")

- #strong[Type:] #link(label("ref-prop-type-data-size"))[prop-type-data-size]
- #strong[Session property:] #raw("query_max_scan_physical_bytes")

The maximum number of bytes that can be scanned by a query during its execution. When this limit is reached, query processing is terminated to prevent excessive resource usage.

== #raw("query.max-write-physical-size")

- #strong[Type:] #link(label("ref-prop-type-data-size"))[prop-type-data-size]
- #strong[Session property:] #raw("query_max_write_physical_size")

The maximum physical size of data that can be written by a query during its execution. When this limit is reached, query processing is terminated to prevent excessive resource usage.

== #raw("query.max-stage-count")

- #strong[Type:] #link(label("ref-prop-type-integer"))[prop-type-integer]
- #strong[Default value:] #raw("150")
- #strong[Minimum value:] #raw("1")

The maximum number of stages allowed to be generated per query. If a query generates more stages than this it will get killed with error #raw("QUERY_HAS_TOO_MANY_STAGES").

#warning[
Setting this to a high value can cause queries with a large number of stages to introduce instability in the cluster causing unrelated queries to get killed with #raw("REMOTE_TASK_ERROR") and the message #raw("Max requests queued per destination exceeded for HttpDestination ...")
]

== #raw("query.max-history")

- #strong[Type:] #link(label("ref-prop-type-integer"))[prop-type-integer]
- #strong[Default value:] #raw("100")

The maximum number of queries to keep in the query history to provide statistics and other information, and make the data available in the #link(label("doc-admin-web-interface"))[Web UI]. If this amount is reached, queries are removed based on age.

To store query events and therefore information about more queries in an external system you must use #link(label("ref-admin-event-listeners"))[an event listener].

== #raw("query.min-expire-age")

- #strong[Type:] #link(label("ref-prop-type-duration"))[prop-type-duration]
- #strong[Default value:] #raw("15m")

The minimal age of a query in the history before it is expired. An expired query is removed from the query history buffer and no longer available in the #link(label("doc-admin-web-interface"))[Web UI].

To store query events and therefore information about more queries in an external system you must use #link(label("ref-admin-event-listeners"))[an event listener].

== #raw("query.remote-task.enable-adaptive-request-size")

- #strong[Type:] #link(label("ref-prop-type-boolean"))[prop-type-boolean]
- #strong[Default value:] #raw("true")
- #strong[Session property:] #raw("remote_task_adaptive_update_request_size_enabled")

Enables dynamically splitting up server requests sent by tasks, which can prevent out-of-memory errors for large schemas. The default settings are optimized for typical usage and should only be modified by advanced users working with extremely large tables.

== #raw("query.remote-task.guaranteed-splits-per-task")

- #strong[Type:] #link(label("ref-prop-type-integer"))[prop-type-integer]
- #strong[Default value:] #raw("3")
- #strong[Session property:] #raw("remote_task_guaranteed_splits_per_request")

The minimum number of splits that should be assigned to each remote task to ensure that each task has a minimum amount of work to perform. Requires #raw("query.remote-task.enable-adaptive-request-size") to be enabled.

== #raw("query.remote-task.max-error-duration")

- #strong[Type:] #link(label("ref-prop-type-duration"))[prop-type-duration]
- #strong[Default value:] #raw("1m")

Timeout value for remote tasks that fail to communicate with the coordinator. If the coordinator is unable to receive updates from a remote task before this value is reached, the coordinator treats the task as failed.

== #raw("query.remote-task.max-request-size")

- #strong[Type:] #link(label("ref-prop-type-data-size"))[prop-type-data-size]
- #strong[Default value:] #raw("8MB")
- #strong[Session property:] #raw("remote_task_max_request_size")

The maximum size of a single request made by a remote task. Requires #raw("query.remote-task.enable-adaptive-request-size") to be enabled.

== #raw("query.remote-task.request-size-headroom")

- #strong[Type:] #link(label("ref-prop-type-data-size"))[prop-type-data-size]
- #strong[Default value:] #raw("2MB")
- #strong[Session property:] #raw("remote_task_request_size_headroom")

Determines the amount of headroom that should be allocated beyond the size of the request data. Requires #raw("query.remote-task.enable-adaptive-request-size") to be enabled.

== #raw("query.info-url-template")

- #strong[Type:] #link(label("ref-prop-type-string"))[prop-type-string]
- #strong[Default value:] #raw("(URL of the query info page on the coordinator)")

Configure redirection of clients to an alternative location for query information. The URL must contain a query id placeholder #raw("${QUERY_ID}").

For example #raw("https://example.com/query/${QUERY_ID}").

The #raw("${QUERY_ID}") gets replaced with the actual query's id.

== #raw("retry-policy")

- #strong[Type:] #link(label("ref-prop-type-string"))[prop-type-string]
- #strong[Default value:] #raw("NONE")

The #link(label("ref-fte-retry-policy"))[retry policy] to use for #link(label("doc-admin-fault-tolerant-execution"))[Fault-tolerant execution]. Supports the following values:

- #raw("NONE") - Disable fault-tolerant execution.
- #raw("TASK") - Retry individual tasks within a query in the event of failure. Requires configuration of an #link(label("ref-fte-exchange-manager"))[exchange manager].
- #raw("QUERY") - Retry the whole query in the event of failure.
