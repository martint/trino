#import "/lib/trino-docs.typ": *

#anchor("doc-security-internal-communication")
= Secure internal communication

The Trino cluster can be configured to use secured communication with internal authentication of the nodes in the cluster, and to optionally use added security with TLS.

#anchor("ref-internal-secret")

== Configure shared secret

You must configure a shared secret to authenticate all communication between nodes of the cluster in the following scenarios:

- When using any authentication between clients and the coordinator.
- When using #link(label("ref-internal-tls"))[internal TLS encryption] between all nodes of the cluster.

Set the shared secret to the same value in #link(label("ref-config-properties"))[config.properties] on all nodes of the cluster:

#code-block("text", "internal-communication.shared-secret=<secret>")

A large random key is recommended, and can be generated with the following Linux command:

#code-block("text", "openssl rand 512 | base64")

#anchor("ref-verify-secrets")

=== Verify configuration

To verify shared secret configuration:

+ Start your Trino cluster with two or more nodes configured with a shared secret.
+ Connect to the #link(label("doc-admin-web-interface"))[Web UI].
+ Confirm the number of #raw("ACTIVE WORKERS") equals the number of nodes configured with your shared secret.
+ Change the value of the shared secret on one worker, and restart the worker.
+ Log in to the Web UI and confirm the number of #raw("ACTIVE WORKERS") is one less. The worker with the invalid secret is not authenticated, and therefore not registered with the coordinator.
+ Stop your Trino cluster, revert the value change on the worker, and restart your cluster.
+ Confirm the number of #raw("ACTIVE WORKERS") equals the number of nodes configured with your shared secret.

#anchor("ref-internal-tls")

== Configure internal TLS

You can optionally add an extra layer of security by configuring the cluster to encrypt communication between nodes with TLS.

You can configure the coordinator and all workers to encrypt all communication with each other using TLS. Every node in the cluster must be configured. Nodes that have not been configured, or are configured incorrectly, are not able to communicate with other nodes in the cluster.

In typical deployments, you should enable #link(label("ref-https-secure-directly"))[TLS directly on the coordinator] for fully encrypted access to the cluster by client tools.

Enable TLS for internal communication with the following configuration identical on all cluster nodes.

+ Configure a shared secret for internal communication as described in the preceding section.
+ Enable automatic certificate creation and trust setup in #raw("etc/config.properties"):
  
  #code-block("properties", "internal-communication.https.required=true")
+ Change the URI for the discovery service to use HTTPS and point to the IP address of the coordinator in #raw("etc/config.properties"):
  
  #code-block("properties", "discovery.uri=https://<coordinator ip address>:<https port>")
  
  Note that using hostnames or fully qualified domain names for the URI is not supported. The automatic certificate creation for internal TLS only supports IP addresses.
+ Enable the HTTPS endpoint on all workers.
  
  #code-block("properties", "http-server.https.enabled=true
  http-server.https.port=<https port>")
+ Restart all nodes.

Certificates are automatically created and used to ensure all communication inside the cluster is secured with TLS.

=== Performance with SSL\/TLS enabled

Enabling encryption impacts performance. The performance degradation can vary based on the environment, queries, and concurrency.

For queries that do not require transferring too much data between the Trino nodes e.g. #raw("SELECT count(*) FROM table"), the performance impact is negligible.

However, for CPU intensive queries which require a considerable amount of data to be transferred between the nodes \(for example, distributed joins, aggregations and window functions, which require repartitioning\), the performance impact can be considerable. The slowdown may vary from 10% to even 100%+, depending on the network traffic and the CPU utilization.

#note[
By default, internal communication with SSL\/TLS enabled uses HTTP\/2 for increased scalability. You can turn off this feature with #raw("internal-communication.http2.enabled=false").
]

#anchor("ref-internal-performance")

=== Advanced performance tuning

In some cases, changing the source of random numbers improves performance significantly.

By default, TLS encryption uses the #raw("/dev/urandom") system device as a source of entropy. This device has limited throughput, so on environments with high network bandwidth \(e.g. InfiniBand\), it may become a bottleneck. In such situations, it is recommended to try to switch the random number generator algorithm to #raw("SHA1PRNG"), by setting it via #raw("http-server.https.secure-random-algorithm") property in #raw("config.properties") on the coordinator and all the workers:

#code-block("text", "http-server.https.secure-random-algorithm=SHA1PRNG")

Be aware that this algorithm takes the initial seed from the blocking #raw("/dev/random") device. For environments that do not have enough entropy to seed the #raw("SHAPRNG") algorithm, the source can be changed to #raw("/dev/urandom") by adding the #raw("java.security.egd") property to #raw("jvm.config"):

#code-block("text", "-Djava.security.egd=file:/dev/urandom")
