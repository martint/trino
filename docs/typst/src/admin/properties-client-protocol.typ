#import "/lib/trino-docs.typ": *

#anchor("doc-admin-properties-client-protocol")
= Client protocol properties

The following sections provide a reference for all properties related to the #link(label("doc-client-client-protocol"))[client protocol].

#anchor("ref-prop-protocol-spooling")

== Spooling protocol properties

The following properties are related to the #link(label("ref-protocol-spooling"))[Client protocol].

=== #raw("protocol.spooling.enabled")

- #strong[Type:] #link(label("ref-prop-type-boolean"))[Properties reference]
- #strong[Default value:] #raw("true")
- #strong[Session property:] #raw("spooling_enabled")

Enable the support for the client #link(label("ref-protocol-spooling"))[Client protocol]. The protocol is used if client drivers and applications request usage, otherwise the direct protocol is used automatically.

=== #raw("protocol.spooling.shared-secret-key")

- #strong[Type:] #link(label("ref-prop-type-string"))[Properties reference]

A required 256 bit, base64-encoded secret key used to secure spooled metadata exchanged with the client. Create a suitable value with the following command:

#code-block("shell", "openssl rand -base64 32")

=== #raw("protocol.spooling.retrieval-mode")

- #strong[Type:] #link(label("ref-prop-type-string"))[Properties reference]
- #strong[Default value:] #raw("STORAGE")

Determines how the client retrieves the segment. Following are possible values:

- #raw("STORAGE") - client accesses the storage directly with the pre-signed URI. Uses one client HTTP request per data segment.
- #raw("COORDINATOR_STORAGE_REDIRECT") - client first accesses the coordinator, which redirects the client to the storage with the pre-signed URI. Uses two client HTTP requests per data segment.
- #raw("COORDINATOR_PROXY") - client accesses the coordinator and gets data segment through it. Uses one client HTTP request per data segment, but requires a coordinator HTTP request to the storage.
- #raw("WORKER_PROXY") - client accesses the coordinator, which redirects to an available worker node. It fetches the data from the storage and provides it to the client. Uses two client HTTP requests, and requires a worker request to the storage.

=== #raw("protocol.spooling.encoding.json.enabled")

- #strong[Type:] #link(label("ref-prop-type-boolean"))[Properties reference]
- #strong[Default value:] #raw("true")

Activate support for using uncompressed JSON encoding for spooled segments.

=== #raw("protocol.spooling.encoding.json+zstd.enabled")

- #strong[Type:] #link(label("ref-prop-type-boolean"))[Properties reference]
- #strong[Default value:] #raw("true")

Activate support for using JSON encoding with Zstandard compression for spooled segments.

=== #raw("protocol.spooling.encoding.json+lz4.enabled")

- #strong[Type:] #link(label("ref-prop-type-boolean"))[Properties reference]
- #strong[Default value:] #raw("true")

Activate support for using JSON encoding with LZ4 compression for spooled segments.

=== #raw("protocol.spooling.encoding.compression.threshold")

- #strong[Type:] #link(label("ref-prop-type-data-size"))[Properties reference]
- #strong[Default value:] #raw("8kB")
- #strong[Minimum value:] #raw("1kB")
- #strong[Maximum value:] #raw("4MB")

Threshold for enabling compression with larger segments.

=== #raw("protocol.spooling.initial-segment-size")

- #strong[Type:] #link(label("ref-prop-type-data-size"))[Properties reference]
- #strong[Default value:] #raw("8MB")
- #strong[Minimum value:] #raw("1kB")
- #strong[Maximum value:] #raw("128MB")
- #strong[Session property:] #raw("spooling_initial_segment_size")

Initial size of the spooled segments.

=== #raw("protocol.spooling.max-segment-size")

- #strong[Type:] #link(label("ref-prop-type-data-size"))[Properties reference]
- #strong[Default value:] #raw("16MB")
- #strong[Minimum value:] #raw("1kB")
- #strong[Maximum value:] #raw("128MB")
- #strong[Session property:] #raw("spooling_max_segment_size")

Maximum size for each spooled segment.

=== #raw("protocol.spooling.inlining.enabled")

- #strong[Type:] #link(label("ref-prop-type-boolean"))[Properties reference]
- #strong[Default value:] #raw("true")
- #strong[Session property:] #raw("spooling_inlining_enabled")

Allow spooled protocol to inline initial rows to decrease time to return the first row.

=== #raw("protocol.spooling.inlining.max-rows")

- #strong[Type:] #link(label("ref-prop-type-integer"))[Properties reference]
- #strong[Default value:] #raw("1000")
- #strong[Minimum value:] #raw("1")
- #strong[Maximum value:] #raw("1000000")
- #strong[Session property:] #raw("spooling_inlining_max_rows")

Maximum number of rows to inline per worker.

=== #raw("protocol.spooling.inlining.max-size")

- #strong[Type:] #link(label("ref-prop-type-data-size"))[Properties reference]
- #strong[Default value:] #raw("128kB")
- #strong[Minimum value:] #raw("1kB")
- #strong[Maximum value:] #raw("1MB")
- #strong[Session property:] #raw("spooling_inlining_max_size")

Maximum size of rows to inline per worker.

#anchor("ref-prop-spooling-file-system")

== Spooling file system properties

The following properties are used to configure the object storage used with the #link(label("ref-protocol-spooling"))[Client protocol].

=== #raw("fs.azure.enabled")

- #strong[Type:] #link(label("ref-prop-type-boolean"))[Properties reference]
- #strong[Default value:] #raw("false")

Activate #link(label("doc-object-storage-file-system-azure"))[Azure Storage file system support] for spooling segments.

=== #raw("fs.s3.enabled")

- #strong[Type:] #link(label("ref-prop-type-boolean"))[Properties reference]
- #strong[Default value:] #raw("false")

Activate #link(label("doc-object-storage-file-system-s3"))[S3 file system support] for spooling segments.

=== #raw("fs.gcs.enabled")

- #strong[Type:] #link(label("ref-prop-type-boolean"))[Properties reference]
- #strong[Default value:] #raw("false")

Activate #link(label("doc-object-storage-file-system-gcs"))[Google Cloud Storage file system support] for spooling segments.

=== #raw("fs.location")

- #strong[Type:] #link(label("ref-prop-type-string"))[Properties reference]

The object storage location to use for spooling segments. Must be accessible by the coordinator and all workers. With the #raw("protocol.spooling.retrieval-mode") retrieval modes #raw("STORAGE") and #raw("COORDINATOR_STORAGE_REDIRECT") the location must also be accessible by all clients. Valid location values vary by object storage type, and follow these patterns:

Examples:

- #strong[S3:] #raw("s3://my-spooling-bucket/my-segments/")
- #strong[Azure Storage:] #raw("abfss://my-spooling-container@account.dfs.core.windows.net/my-segments/")
- #strong[Google Cloud Storage:] #raw("gs://my-spooling-bucket/my-segments/")

#note[
For Azure Storage, use the ABFS format with hierarchical namespace enabled. The legacy WASB format \(#raw("wasbs://") or #raw("wasb://")\) is also supported but deprecated.
]

#caution[
The specified object storage location must not be used for spooling for another Trino cluster or any object storage catalog. When using the same object storage for multiple services, you must use separate locations for each one. For example:

- #raw("s3://my-spooling-bucket/my-segments/cluster1-spooling/")
- #raw("s3://my-spooling-bucket/my-segments/cluster2-spooling/")
- #raw("s3://my-spooling-bucket/my-segments/iceberg-catalog/")
]

=== #raw("fs.segment.ttl")

- #strong[Type:] #link(label("ref-prop-type-duration"))[Properties reference]
- #strong[Default value:] #raw("12h")

Maximum available time for the client to retrieve spooled segment before it expires and is pruned.

=== #raw("fs.segment.direct.ttl")

- #strong[Type:] #link(label("ref-prop-type-duration"))[Properties reference]
- #strong[Default value:] #raw("1h")

Maximum available time for the client to retrieve spooled segment using the pre-signed URI.

=== #raw("fs.segment.encryption")

- #strong[Type:] #link(label("ref-prop-type-boolean"))[Properties reference]
- #strong[Default value:] #raw("true")

Encrypt segments with ephemeral keys using Server-Side Encryption with Customer key \(SSE-C\).

=== #raw("fs.segment.explicit-ack")

- #strong[Type:] #link(label("ref-prop-type-boolean"))[Properties reference]
- #strong[Default value:] #raw("true")

Activate pruning of segments on client acknowledgment of a successful read of each segment.

=== #raw("fs.segment.pruning.enabled")

- #strong[Type:] #link(label("ref-prop-type-boolean"))[Properties reference]
- #strong[Default value:] #raw("true")

Activate periodic pruning of expired segments.

=== #raw("fs.segment.pruning.interval")

- #strong[Type:] #link(label("ref-prop-type-duration"))[Properties reference]
- #strong[Default value:] #raw("5m")

Interval to prune expired segments.

=== #raw("fs.segment.pruning.batch-size")

- #strong[Type:] #link(label("ref-prop-type-integer"))[Properties reference]
- #strong[Default value:] #raw("250")

Number of expired segments to prune as a single batch operation.

#anchor("ref-prop-protocol-shared")

== Shared protocol properties

The following properties are related to the #link(label("ref-protocol-spooling"))[Client protocol] and the #link(label("ref-protocol-direct"))[Client protocol], formerly named the V1 protocol.

=== #raw("protocol.v1.prepared-statement-compression.length-threshold")

- #strong[Type:] #link(label("ref-prop-type-integer"))[Properties reference]
- #strong[Default value:] #raw("2048")

Prepared statements that are submitted to Trino for processing, and are longer than the value of this property, are compressed for transport via the HTTP header to improve handling, and to avoid failures due to hitting HTTP header size limits.

=== #raw("protocol.v1.prepared-statement-compression.min-gain")

- #strong[Type:] #link(label("ref-prop-type-integer"))[Properties reference]
- #strong[Default value:] #raw("512")

Prepared statement compression is not applied if the size gain is less than the configured value. Smaller statements do not benefit from compression, and are left uncompressed.
