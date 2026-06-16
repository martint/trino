#import "/lib/trino-docs.typ": *

#anchor("doc-installation-query-resiliency")
= Improve query processing resilience

You can configure Trino to be more resilient against failures during query processing by enabling fault-tolerant execution. This allows Trino to handle larger queries such as batch operations without worker node interruptions causing the query to fail.

When configured, the Trino cluster buffers data used by workers during query processing. If processing on a worker node fails for any reason, such as a network outage or running out of available resources, the coordinator reschedules processing of the failed piece of work on another worker. This allows query processing to continue using buffered data.

== Architecture

The coordinator node uses a configured exchange manager service that buffers data during query processing in an external location, such as an S3 object storage bucket. Worker nodes send data to the buffer as they execute their query tasks.

== Best practices and considerations

A fault-tolerant cluster is best suited for large batch queries. Users may experience latency or similar behavior if they issue a high volume of short-running queries on a fault-tolerant cluster. As such, it is recommended to run a dedicated fault-tolerant cluster for handling batch operations, separate from a cluster that is designated for a higher query volume.

Catalogs using the following connectors support fault-tolerant execution of read and write operations:

- #link(label("doc-connector-delta-lake"))[Delta Lake connector]
- #link(label("doc-connector-hive"))[Hive connector]
- #link(label("doc-connector-iceberg"))[Iceberg connector]
- #link(label("doc-connector-mysql"))[MySQL connector]
- #link(label("doc-connector-postgresql"))[PostgreSQL connector]
- #link(label("doc-connector-sqlserver"))[SQL Server connector]

Catalogs using other connectors only support fault-tolerant execution of read operations. When fault-tolerant execution is enabled on a cluster, write operations fail on any catalogs that do not support fault-tolerant execution of those operations.

The exchange manager may send a large amount of data to the exchange storage, resulting in high I\/O load on that storage. You can configure multiple storage locations for use by the exchange manager to help balance the I\/O load between them.

== Configuration

The following steps describe how to configure a Trino cluster for fault-tolerant execution with an S3-based exchange:

+ Set up an S3 bucket to use as the exchange storage. For this example we are using an AWS S3 bucket, but other storage options are described in the #link(label("doc-admin-fault-tolerant-execution"))[reference documentation] as well. You can use multiple S3 buckets for exchange storage.
  
  For each bucket in AWS, collect the following information:
  
  - S3 URI location for the bucket, such as #raw("s3://exchange-spooling-bucket")
  - Region that the bucket is located in, such as #raw("us-west-1")
  - AWS access and secret keys for the bucket
+ For a #link(label("doc-installation-kubernetes"))[Kubernetes deployment of Trino], add the following exchange manager configuration in the #raw("server.exchangeManager") and #raw("additionalExchangeManagerProperties") sections of the Helm chart, using the gathered S3 bucket information:
  
  #code-block("yaml", "server:
    exchangeManager:
      name=filesystem
      base-directories=s3://exchange-spooling-bucket-1,s3://exchange-spooling-bucket-2
  
  additionalExchangeManagerProperties:
    exchange.s3.region=us-west-1
    exchange.s3.aws-access-key=example-access-key
    exchange.s3.aws-secret-key=example-secret-key")
  
  In non-Kubernetes installations, the same properties must be defined in an #raw("exchange-manager.properties") configuration file on the coordinator and all worker nodes.
+ Add the following configuration for fault-tolerant execution in the #raw("additionalConfigProperties:") section of the Helm chart:
  
  #code-block("yaml", "additionalConfigProperties:
    retry-policy=TASK")
  
  In non-Kubernetes installations, the same property must be defined in the #raw("config.properties") file on the coordinator and all worker nodes.
+ Re-deploy your instance of Trino or, for non-Kubernetes installations, restart the cluster.

Your Trino cluster is now configured with fault-tolerant query execution. If a query run on the cluster would normally fail due to an interruption of query processing, fault-tolerant execution now resumes the query processing to ensure successful execution of the query.

== Next steps

For more information about fault-tolerant execution, including simple query retries that do not require an exchange manager and advanced configuration operations, see the #link(label("doc-admin-fault-tolerant-execution"))[reference documentation].
