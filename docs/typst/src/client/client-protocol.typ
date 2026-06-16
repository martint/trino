#import "/lib/trino-docs.typ": *

#anchor("doc-client-client-protocol")
= Client protocol

The Trino client protocol is a HTTP-based protocol that allows #link(label("doc-client"))[clients] to submit SQL queries and receive results.

The protocol is a sequence of REST API calls to the #link(label("ref-trino-concept-coordinator"))[coordinator] of the Trino #link(label("ref-trino-concept-cluster"))[cluster]. Following is a high-level overview:

+ Client submits SQL query text to the coordinator of the Trino cluster.
+ The coordinator starts processing the query.
+ The coordinator returns a result set and a URI #raw("nextUri") on the coordinator.
+ The client receives the result set and initiates another request for more data from the URI #raw("nextUri").
+ The coordinator continues processing the query and returns further data with a new URI.
+ The client and coordinator continue with steps 4. and 5. until all result set data is returned to the client or the client stops requesting more data.
+ If the client fails to fetch the result set, the coordinator does not initiate further processing, fails the query, and returns a #raw("USER_CANCELED") error.
+ The final response when the query is complete is #raw("FINISHED").

The client protocol supports two modes. Configure the #link(label("ref-protocol-spooling"))[spooling protocol] for optimal throughput for your clients.

#anchor("ref-protocol-spooling")

== Spooling protocol

The spooling protocol uses an object storage location to store the data for retrieval by the client. The coordinator and all workers can write result set data to the storage in parallel. The coordinator only provides the URLs to all the individual data segments on the object storage to the cluster. The spooling protocol also allows compression of the data.

Data on the object storage is automatically removed after download by the client.

The spooling protocol has the following characteristics, compared to the #link(label("ref-protocol-direct"))[direct protocol].

- Provides higher throughput for data transfer, specifically for queries that return more data.
- Results in faster query processing completion on the cluster, independent of the client retrieving all data, since data is read from the object storage.
- Requires object storage and configuration on the Trino cluster.
- Reduces CPU and I\/O load on the coordinator.
- Automatically falls back to the direct protocol for queries that don't benefit from using the spooling protocol.
- Requires newer client drivers or client applications that support the spooling protocol and actively request usage of the spooling protocol.
- Clients must have access to the object storage.
- Works with older client drivers and client applications by automatically falling back to the direct protocol if spooling protocol is not supported.

=== Configuration

The following steps are necessary to configure support for the spooling protocol on a Trino cluster:

- Configure the spooling protocol usage in #link(label("ref-config-properties"))[Deploying Trino] using the #link(label("ref-prop-protocol-spooling"))[Client protocol properties].
- Choose a suitable object storage that is accessible to your Trino cluster and your clients.
- Create a location in your object storage that is not shared with any object storage catalog or spooling for any other Trino clusters.
- Configure the object storage in #raw("etc/spooling-manager.properties") using the #link(label("ref-prop-spooling-file-system"))[Client protocol properties].

Minimal configuration in #link(label("ref-config-properties"))[Deploying Trino]:

#code-block("properties", "protocol.spooling.enabled=true
protocol.spooling.shared-secret-key=jxTKysfCBuMZtFqUf8UJDQ1w9ez8rynEJsJqgJf66u0=")

#note[
The #raw("protocol.spooling.shared-secret-key") property requires a 256-bit, base64-encoded secret key.
]

Refer to #link(label("ref-prop-protocol-spooling"))[Client protocol properties] for further optional configuration.

Suitable object storage systems for spooling are S3 and compatible systems, Azure Storage, and Google Cloud Storage. The object storage system must provide good connectivity for all cluster nodes as well as any clients.

Activate the desired system with #raw("fs.s3.enabled"), #raw("fs.azure.enabled"), or #raw("fs.gcs.enabled") in #raw("etc/spooling-manager.properties") and configure further details using relevant properties from #link(label("ref-prop-spooling-file-system"))[Client protocol properties], #link(label("doc-object-storage-file-system-s3"))[S3 file system support], #link(label("doc-object-storage-file-system-azure"))[Azure Storage file system support], and #link(label("doc-object-storage-file-system-gcs"))[Google Cloud Storage file system support].

The #raw("spooling-manager.name") property must be set to #raw("filesystem").

Following is a minimalistic example for using the S3-compatible MinIO object storage:

#code-block("properties", "spooling-manager.name=filesystem
fs.s3.enabled=true
fs.location=s3://spooling
s3.endpoint=http://minio:9080/
s3.region=fake-value
s3.aws-access-key=minio-access-key
s3.aws-secret-key=minio-secret-key
s3.path-style-access=true")

Refer to #link(label("ref-prop-spooling-file-system"))[Client protocol properties] for further configuration properties.

The system assumes the object storage to be unbounded in terms of data and data transfer volume. Spooled segments on object storage are automatically removed by the clients after reads as well as the coordinator in specific intervals. Sizing and transfer demands vary with the query workload on your cluster.

Segments on object storage are encrypted, compressed, and can only be used by the specific client who initiated the query.

#note[
When using S3 or S3-compatible storage, the bucket must allow Server-Side Encryption with Customer-provided keys \(SSE-C\) operations. The spooling protocol encrypts segments using SSE-C by default \(controlled by the #link(label("ref-prop-spooling-file-system"))[Client protocol properties] property #raw("fs.segment.encryption")\). If the bucket policy or storage configuration does not support SSE-C, segment writes fail.
]

The following client drivers and client applications support the spooling protocol.

- #link(label("ref-jdbc-spooling-protocol"))[Trino JDBC driver], version 466 and newer
- #link(label("ref-cli-spooling-protocol"))[Trino command line interface], version 466 and newer
- #link("https://github.com/trinodb/trino-python-client")[Trino Python client], version 0.332.0 and newer
- #link("https://github.com/trinodb/trino-go-client")[Trino Go client], version 0.328.0 and newer

Refer to the documentation for your specific client drivers and client applications for up to date information.

#anchor("ref-protocol-direct")

== Direct protocol

The direct protocol transfers all data from the workers to the coordinator, and from there directly to the client.

The direct protocol, also known as the #raw("v1") protocol, has the following characteristics, compared to the spooling protocol:

- Provides lower performance, specifically for queries that return more data.
- Results in slower query processing completion on the cluster, since data is provided by the coordinator and read by the client sequentially.
- Requires #strong[no] object storage or configuration in the Trino cluster.
- Increases CPU and I\/O load on the coordinator.
- Works with older client drivers and client applications without support for the spooling protocol.

=== Configuration

Use of the direct protocol requires no configuration. Find optional configuration properties in #link(label("ref-prop-protocol-shared"))[Client protocol properties].

== Development and reference information

Further technical details about the client protocol, including information useful for developing a client driver, are available in the #link(label("doc-develop-client-protocol"))[Trino client REST API developer reference].
