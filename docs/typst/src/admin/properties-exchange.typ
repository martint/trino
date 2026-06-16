#import "/lib/trino-docs.typ": *

#anchor("doc-admin-properties-exchange")
= Exchange properties

Exchanges transfer data between Trino nodes for different stages of a query. Adjusting these properties may help to resolve inter-node communication issues or improve network utilization.

Additionally, you can configure the exchange #link(label("doc-admin-properties-http-client"))[HTTP client usage].

== #raw("exchange.client-threads")

- #strong[Type:] #link(label("ref-prop-type-integer"))[prop-type-integer]
- #strong[Minimum value:] #raw("1")
- #strong[Default value:] #raw("25")

Number of threads used by exchange clients to fetch data from other Trino nodes. A higher value can improve performance for large clusters or clusters with very high concurrency, but excessively high values may cause a drop in performance due to context switches and additional memory usage.

== #raw("exchange.concurrent-request-multiplier")

- #strong[Type:] #link(label("ref-prop-type-integer"))[prop-type-integer]
- #strong[Minimum value:] #raw("1")
- #strong[Default value:] #raw("3")

Multiplier determining the number of concurrent requests relative to available buffer memory. The maximum number of requests is determined using a heuristic of the number of clients that can fit into available buffer space, based on average buffer usage per request times this multiplier. For example, with an #raw("exchange.max-buffer-size") of #raw("32 MB") and #raw("20 MB") already used and average size per request being #raw("2MB"), the maximum number of clients is #raw("multiplier * ((32MB - 20MB) / 2MB) = multiplier * 6"). Tuning this value adjusts the heuristic, which may increase concurrency and improve network utilization.

#anchor("ref-prop-exchange-compression-codec")

== #raw("exchange.compression-codec")

- #strong[Type:] #link(label("ref-prop-type-string"))[prop-type-string]
- #strong[Allowed values:] #raw("NONE"), #raw("LZ4"), #raw("ZSTD")
- #strong[Default value:] #raw("NONE")

The compression codec to use for #link(label("ref-file-compression"))[General properties] when exchanging data between nodes and the exchange storage with #link(label("doc-admin-fault-tolerant-execution"))[Fault-tolerant execution] mode.

== #raw("exchange.data-integrity-verification")

- #strong[Type:] #link(label("ref-prop-type-string"))[prop-type-string]
- #strong[Allowed values:] #raw("NONE"), #raw("ABORT"), #raw("RETRY")
- #strong[Default value:] #raw("ABORT")

Configure the resulting behavior of data integrity issues. By default, #raw("ABORT") causes queries to be aborted when data integrity issues are detected as part of the built-in verification. Setting the property to #raw("NONE") disables the verification. #raw("RETRY") causes the data exchange to be repeated when integrity issues are detected.

== #raw("exchange.max-buffer-size")

- #strong[Type:] #link(label("ref-prop-type-data-size"))[prop-type-data-size]
- #strong[Default value:] #raw("32MB")

Size of buffer in the exchange client that holds data fetched from other nodes before it is processed. A larger buffer can increase network throughput for larger clusters, and thus decrease query processing time, but reduces the amount of memory available for other usages.

== #raw("exchange.max-response-size")

- #strong[Type:] #link(label("ref-prop-type-data-size"))[prop-type-data-size]
- #strong[Minimum value:] #raw("1MB")
- #strong[Default value:] #raw("16MB")

Maximum size of a response returned from an exchange request. The response is placed in the exchange client buffer, which is shared across all concurrent requests for the exchange.

Increasing the value may improve network throughput, if there is high latency. Decreasing the value may improve query performance for large clusters as it reduces skew, due to the exchange client buffer holding responses for more tasks, rather than hold more data from fewer tasks.

== #raw("sink.max-buffer-size")

- #strong[Type:] #link(label("ref-prop-type-data-size"))[prop-type-data-size]
- #strong[Default value:] #raw("32MB")

Output buffer size for task data that is waiting to be pulled by upstream tasks. If the task output is hash partitioned, then the buffer is shared across all the partitioned consumers. Increasing this value may improve network throughput for data transferred between stages, if the network has high latency, or if there are many nodes in the cluster.

== #raw("sink.max-broadcast-buffer-size")

- #strong[Type] #raw("data size")
- #strong[Default value:] #raw("200MB")

Broadcast output buffer size for task data that is waiting to be pulled by upstream tasks. The broadcast buffer is used to store and transfer build side data for replicated joins. If the buffer is too small, it prevents scaling of join probe side tasks, when new nodes are added to the cluster.
