#import "/lib/trino-docs.typ": *

#anchor("doc-admin-openmetrics")
= Trino metrics with OpenMetrics

Trino supports the metrics standard #link("https://openmetrics.io/")[OpenMetrics], that originated with the open-source systems monitoring and alerting toolkit #link("https://prometheus.io/")[Prometheus].

Metrics are automatically enabled and available on the coordinator at the #raw("/metrics") endpoint. The endpoint is protected with the configured #link(label("ref-security-authentication"))[authentication], identical to the #link(label("doc-admin-web-interface"))[Web UI] and the #link(label("doc-client-client-protocol"))[Client protocol].

For example, you can retrieve metrics data from an unsecured Trino server running on #raw("localhost:8080") with random username #raw("example"):

#code-block("shell", "curl -H X-Trino-User:foo localhost:8080/metrics")

The result follows the #link("https://github.com/OpenObservability/OpenMetrics/blob/main/specification/OpenMetrics.md")[OpenMetrics specification] and looks similar to the following example output:

#code-block(none, "# TYPE io_airlift_http_client_type_HttpClient_name_ForDiscoveryClient_CurrentResponseProcessTime_Min gauge
io_airlift_http_client_type_HttpClient_name_ForDiscoveryClient_CurrentResponseProcessTime_Min NaN
# TYPE io_airlift_http_client_type_HttpClient_name_ForDiscoveryClient_CurrentResponseProcessTime_P25 gauge
io_airlift_http_client_type_HttpClient_name_ForDiscoveryClient_CurrentResponseProcessTime_P25 NaN
# TYPE io_airlift_http_client_type_HttpClient_name_ForDiscoveryClient_CurrentResponseProcessTime_Total gauge
io_airlift_http_client_type_HttpClient_name_ForDiscoveryClient_CurrentResponseProcessTime_Total 0.0
# TYPE io_airlift_http_client_type_HttpClient_name_ForDiscoveryClient_CurrentResponseProcessTime_P90 gauge
io_airlift_http_client_type_HttpClient_name_ForDiscoveryClient_CurrentResponseProcessTime_P90 NaN")

The same data is available when using a browser, and logging manually.

The user, #raw("foo") in the example, must have read permission to system information on a secured deployment, and the URL and port must be adjusted accordingly.

Each Trino node, so the coordinator and all workers, provide separate metrics independently.

Use the property #raw("openmetrics.jmx-object-names") in #link(label("ref-config-properties"))[Deploying Trino] to define  the JMX object names to include when retrieving all metrics. Multiple object names are must be separated with #raw("|").  Metrics use the package namespace for any metric. Use #raw(":*") to expose all metrics. Use #raw("name") to select specific classes or #raw("type") for specific metric types.

Examples:

- #raw("trino.plugin.exchange.filesystem:name=FileSystemExchangeStats") for metrics from the #raw("FileSystemExchangeStats") class in the #raw("trino.plugin.exchange.filesystem") package.
- #raw("trino.plugin.exchange.filesystem.s3:name=S3FileSystemExchangeStorageStats") for metrics from the #raw("S3FileSystemExchangeStorageStats") class in the #raw("trino.plugin.exchange.filesystem.s3") package.
- #raw("io.trino.hdfs:*") for all metrics in the #raw("io.trino.hdfs") package.
- #raw("java.lang:type=Memory") for all memory metrics in the #raw("java.lang") package.

Typically, Prometheus or a similar application is configured to monitor the endpoint. The same application can then be used to inspect the metrics data.

Trino also includes a #link(label("doc-connector-prometheus"))[Prometheus connector] that allows you to query Prometheus data using SQL.

== Examples

The following sections provide tips and tricks for your usage with small examples.

Other configurations with tools such as #link("https://grafana.com/docs/agent/latest/")[grafana-agent] or #link("https://grafana.com/docs/alloy/latest/")[grafana alloy opentelemetry agent] are also possible, and can use platforms such as #link("https://cortexmetrics.io/")[Cortex] or #link("https://grafana.com/oss/mimir/mimir")[Grafana Mimir] for metrics storage and related monitoring and analysis.

=== Simple example with Docker and Prometheus

The following steps provide a simple demo setup to run #link("https://prometheus.io/")[Prometheus] and Trino locally in Docker containers.

Create a shared network for both servers called #raw("platform"):

#code-block("shell", "docker network create platform")

Start Trino in the background:

#code-block("shell", "docker run -d \\
  --name=trino \\
  --network=platform \\
  --network-alias=trino \\
  -p 8080:8080 \\
  trinodb/trino:latest")

The preceding command starts Trino and adds it to the #raw("platform") network with the hostname #raw("trino").

Create a #raw("prometheus.yml") configuration file with the following content, that point Prometheus at the #raw("trino") hostname:

#code-block("yaml", "scrape_configs:
- job_name: trino
  basic_auth:
    username: trino-user
  static_configs:
    - targets:
      - trino:8080")

Start Prometheus from the same directory as the configuration file:

#code-block("shell", "docker run -d \\
  --name=prometheus \\
  --network=platform \\
  -p 9090:9090 \\
  --mount type=bind,source=$PWD/prometheus.yml,target=/etc/prometheus/prometheus.yml \\
  prom/prometheus")

The preceding command adds Prometheus to the #raw("platform") network. It also mounts the configuration file into the container so that metrics from Trino are gathered by Prometheus.

Now everything is running.

Install and run the #link(label("doc-client-cli"))[Trino CLI] or any other client application and submit a query such as #raw("SHOW CATALOGS;") or #raw("SELECT * FROM tpch.tiny.nation;").

Optionally, log into the #link(label("doc-admin-web-interface"))[Trino Web UI] at #link("http://localhost:8080")[http:\/\/localhost:8080] with a random username. Press the #strong[Finished] button and inspect the details for the completed queries.

Access the Prometheus UI at #link("http://localhost:9090/")[http:\/\/localhost:9090\/], select #strong[Status] \> #strong[Targets] and see the configured endpoint for Trino metrics.

To see an example graph, select #strong[Graph], add the metric name #raw("trino_execution_name_QueryManager_RunningQueries") in the input field and press #strong[Execute]. Press #strong[Table] for the raw data or #strong[Graph] for a visualization.

As a next step, run more queries and inspect the effect on the metrics.

Once you are done you can stop the containers:

#code-block("shell", "docker stop prometheus
docker stop trino")

You can start them again for further testing:

#code-block("shell", "docker start trino
docker start prometheus")

Use the following commands to completely remove the network and containers:

#code-block("shell", "docker rm trino
docker rm prometheus
docker network rm platform")

== Coordinator and worker metrics with Kubernetes

To get a complete picture of the metrics on your cluster, you must access the coordinator and the worker metrics. This section details tips for setting up for this scenario with the #link("https://github.com/trinodb/charts")[Trino Helm chart] on Kubernetes.

Add an annotation to flag all cluster nodes for scraping in your values for the Trino Helm chart:

#code-block("yaml", "coordinator:
  annotations:
    prometheus.io/trino_scrape: \"true\"
worker:
  annotations:
    prometheus.io/trino_scrape: \"true\"")

Configure metrics retrieval from the workers in your Prometheus configuration:

#code-block("yaml", "    - job_name: trino-metrics-worker
      scrape_interval: 10s
      scrape_timeout: 10s
      kubernetes_sd_configs:
        - role: pod
      relabel_configs:
      - source_labels: [__meta_kubernetes_pod_annotation_prometheus_io_trino_scrape]
        action: keep # scrape only pods with the trino scrape anotation
        regex: true
      - source_labels: [__meta_kubernetes_pod_container_name]
        action: keep # dont try to scrape non trino container
        regex: trino-worker
      - action: hashmod
        modulus: $(SHARDS)
        source_labels:
        - __address__
        target_label: __tmp_hash
      - action: keep
        regex: $(SHARD)
        source_labels:
        - __tmp_hash
      - source_labels: [__meta_kubernetes_pod_name]
        action: replace
        target_label: pod
      - source_labels: [__meta_kubernetes_pod_container_name]
        action: replace
        target_label: container
      metric_relabel_configs:
          - source_labels: [__name__]
            regex: \".+_FifteenMinute.+|.+_FiveMinute.+|.+IterativeOptimizer.+|.*io_airlift_http_client_type_HttpClient.+\"
            action: drop # droping some highly granular metrics 
          - source_labels: [__meta_kubernetes_pod_name]
            regex: \".+\"
            target_label: pod
            action: replace 
          - source_labels: [__meta_kubernetes_pod_container_name]
            regex: \".+\"
            target_label: container
            action: replace 
            
      scheme: http
      tls_config:
        insecure_skip_verify: true
      basic_auth:
        username: myuser # replace with a username that has system information permission
        # DO NOT ADD PASSWORD")

The worker authentication uses a user with access to the system information, yet does not add a password and uses access via HTTP.

Configure metrics retrieval from the coordinator in your Prometheus configuration:

#code-block("yaml", "    - job_name: trino-metrics-coordinator
      scrape_interval: 10s
      scrape_timeout: 10s
      kubernetes_sd_configs:
        - role: pod
      relabel_configs:
      - source_labels: [__meta_kubernetes_pod_annotation_prometheus_io_trino_scrape]
        action: keep # scrape only pods with the trino scrape anotation
        regex: true
      - source_labels: [__meta_kubernetes_pod_container_name]
        action: keep # dont try to scrape non trino container
        regex: trino-coordinator
      - action: hashmod
        modulus: $(SHARDS)
        source_labels:
        - __address__
        target_label: __tmp_hash
      - action: keep
        regex: $(SHARD)
        source_labels:
        - __tmp_hash
      - source_labels: [__meta_kubernetes_pod_name]
        action: replace
        target_label: pod
      - source_labels: [__meta_kubernetes_pod_container_name]
        action: replace
        target_label: container
      - action: replace  # override the address to the https ingress address 
        target_label: __address__
        replacement: {{ .Values.trinourl }} 
      metric_relabel_configs:
          - source_labels: [__name__]
            regex: \".+_FifteenMinute.+|.+_FiveMinute.+|.+IterativeOptimizer.+|.*io_airlift_http_client_type_HttpClient.+\"
            action: drop # droping some highly granular metrics 
          - source_labels: [__meta_kubernetes_pod_name]
            regex: \".+\"
            target_label: pod
            action: replace 
          - source_labels: [__meta_kubernetes_pod_container_name]
            regex: \".+\"
            target_label: container
            action: replace 
            
      scheme: https
      tls_config:
        insecure_skip_verify: true
      basic_auth:
        username: myuser # replace with a username that has system information permission
        password_file: /some/password/file")

The coordinator authentication uses a user with access to the system information and requires authentication and access via HTTPS.
