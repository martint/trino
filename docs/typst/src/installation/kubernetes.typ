#import "/lib/trino-docs.typ": *

#anchor("doc-installation-kubernetes")
= Trino on Kubernetes with Helm

#link("https://kubernetes.io")[Kubernetes] is a container orchestration platform that allows you to deploy Trino and other applications in a repeatable manner across different types of infrastructure. This can range from deploying on your laptop using tools like #link("https://kind.sigs.k8s.io")[kind], to running on a managed Kubernetes service on cloud services like #link("https://aws.amazon.com/eks")[Amazon Elastic Kubernetes Service], #link("https://cloud.google.com/kubernetes-engine")[Google Kubernetes Engine], #link("https://azure.microsoft.com/services/kubernetes-service")[Azure Kubernetes Service], and others.

The fastest way to run Trino on Kubernetes is to use the #link("https://github.com/trinodb/charts")[Trino Helm chart]. #link("https://helm.sh")[Helm] is a package manager for Kubernetes applications that allows for simpler installation and versioning by templating Kubernetes configuration files. This allows you to prototype on your local or on-premise cluster and use the same deployment mechanism to deploy to the cloud to scale up.

== Requirements

- A Kubernetes cluster with a #link("https://kubernetes.io/releases/")[supported version] of Kubernetes.
  
  - If you don't have a Kubernetes cluster, you can #link(label("ref-running-a-local-kubernetes-cluster-with-kind"))[run one locally using kind].
- #link("https://kubernetes.io/docs/tasks/tools/#kubectl")[kubectl] with a version that adheres to the #link("https://kubernetes.io/releases/version-skew-policy/")[Kubernetes version skew policy] installed on the machine managing the Kubernetes deployment.
- #link("https://helm.sh")[helm] with a version that adheres to the #link("https://helm.sh/docs/topics/version_skew/")[Helm version skew policy] installed on the machine managing the Kubernetes deployment.

#anchor("ref-running-trino-using-helm")

== Running Trino using Helm

Run the following commands from the system with #raw("helm") and #raw("kubectl") installed and configured to connect to your running Kubernetes cluster:

+ Validate #raw("kubectl") is pointing to the correct cluster by running the command:
  
  #code-block("text", "kubectl cluster-info")
  
  You should see output that shows the correct Kubernetes control plane address.
+ Add the Trino Helm chart repository to Helm if you haven't done so already. This tells Helm where to find the Trino charts. You can name the repository whatever you want, #raw("trino") is a good choice.
  
  #code-block("text", "helm repo add trino https://trinodb.github.io/charts")
+ Install Trino on the Kubernetes cluster using the Helm chart. Start by running the #raw("install") command to use all default values and create a cluster called #raw("example-trino-cluster").
  
  #code-block("text", "helm install example-trino-cluster trino/trino")
  
  This generates the Kubernetes configuration files by inserting properties into helm templates. The Helm chart contains #link("https://trinodb.github.io/charts/charts/trino/")[default values] that can be overridden by a YAML file to update default settings.
  
  + #emph[\(Optional\)] To override the default values, #link(label("ref-creating-your-own-yaml"))[create your own YAML configuration] to define the parameters of your deployment. To run the install command using the #raw("example.yaml"), add the #raw("f") parameter in you #raw("install") command. Be sure to follow #link(label("ref-kubernetes-configuration-best-practices"))[best practices and naming conventions] for your configuration files.
    
    #code-block("text", "helm install -f example.yaml example-trino-cluster trino/trino")
  
  You should see output as follows:
  
  #code-block("text", "NAME: example-trino-cluster
  LAST DEPLOYED: Tue Sep 13 14:12:09 2022
  NAMESPACE: default
  STATUS: deployed
  REVISION: 1
  TEST SUITE: None
  NOTES:
  Get the application URL by running these commands:
    export POD_NAME=$(kubectl get pods --namespace default --selector \"app.kubernetes.io/name=trino,app.kubernetes.io/instance=example-trino-cluster,app.kubernetes.io/component=coordinator\" --output name)
    echo \"Visit http://127.0.0.1:8080 to use your application\"
    kubectl port-forward $POD_NAME 8080:8080")
  
  This output depends on your configuration and cluster name. For example, the port #raw("8080") is set by the #raw(".service.port") in the #raw("example.yaml").
+ Run the following command to check that all pods, deployments, and services are running properly.
  
  #code-block("text", "kubectl get all")
  
  You should expect to see output that shows running pods, deployments, and replica sets. A good indicator that everything is running properly is to see all pods are returning a ready status in the  #raw("READY") column.
  
  #code-block("text", "NAME                                               READY   STATUS    RESTARTS   AGE
  pod/example-trino-cluster-coordinator-bfb74c98d-rnrxd   1/1     Running   0          161m
  pod/example-trino-cluster-worker-76f6bf54d6-hvl8n       1/1     Running   0          161m
  pod/example-trino-cluster-worker-76f6bf54d6-tcqgb       1/1     Running   0          161m
  
  NAME                       TYPE        CLUSTER-IP    EXTERNAL-IP   PORT(S)    AGE
  service/example-trino-cluster   ClusterIP   10.96.25.35   <none>        8080/TCP   161m
  
  NAME                                           READY   UP-TO-DATE   AVAILABLE   AGE
  deployment.apps/example-trino-cluster-coordinator   1/1     1            1           161m
  deployment.apps/example-trino-cluster-worker        2/2     2            2           161m
  
  NAME                                                     DESIRED   CURRENT   READY   AGE
  replicaset.apps/example-trino-cluster-coordinator-bfb74c98d   1         1         1       161m
  replicaset.apps/example-trino-cluster-worker-76f6bf54d6       2         2         2       161m")
  
  The output shows running pods. These include the actual Trino containers. To better understand this output, check out the following resources:
  
  + #link("https://kubernetes.io/docs/reference/generated/kubectl/kubectl-commands#get")[kubectl get command reference].
  + #link("https://kubernetes.io/docs/reference/kubectl/docker-cli-to-kubectl/#docker-ps")[kubectl get command example].
  + #link("https://kubernetes.io/docs/tasks/debug/")[Debugging Kubernetes reference].
+ If all pods, deployments, and replica sets are running and in the ready state, Trino has been successfully deployed.

#note[
Unlike some Kubernetes applications, where it's better to have many small pods, Trino works best with fewer pods each having more resources available. We strongly recommend to avoid having multiple Trino pods on a single physical host to avoid contention for resources.
]

#anchor("ref-executing-queries")

== Executing queries

The pods running the Trino containers are all running on a private network internal to Kubernetes. In order to access them, specifically the coordinator, you need to create a tunnel to the coordinator pod and your computer. You can do this by running the commands generated upon installation.

+ Create the tunnel from the client to the coordinator service.
  
  #code-block("text", "kubectl port-forward svc/trino 8080:8080")
  
  Now you can connect to the Trino coordinator at #raw("http://localhost:8080").
+ To connect to Trino, you can use the #link(label("doc-client-cli"))[command-line interface], a #link(label("doc-client-jdbc"))[JDBC client], or any of the #link(label("doc-client"))[other clients]. For this example, #link(label("ref-cli-installation"))[install the command-line interface], and connect to Trino in a new console session.
  
  #code-block("text", "trino --server http://localhost:8080")
+ Using the sample data in the #raw("tpch") catalog, type and execute a query on the #raw("nation") table using the #raw("tiny") schema:
  
  #code-block("text", "trino> select count(*) from tpch.tiny.nation;
   _col0
  -------
    25
  (1 row)
  
  Query 20181105_001601_00002_e6r6y, FINISHED, 1 node
  Splits: 21 total, 21 done (100.00%)
  0:06 [25 rows, 0B] [4 rows/s, 0B/s]")
  
  Try other SQL queries to explore the data set and test your cluster.
+ Once you are done with your exploration, enter the #raw("quit") command in the CLI.
+ Kill the tunnel to the coordinator pod. The is only available while the #raw("kubectl") process is running, so you can just kill the #raw("kubectl") process that's forwarding the port. In most cases that means pressing #raw("CTRL") + #raw("C") in the terminal where the port-forward command is running.

== Configuration

The Helm chart uses the #link(label("doc-installation-containers"))[Trino container image]. The Docker image already contains a default configuration to get started, and some catalogs to allow you to explore Trino. Kubernetes allows you to mimic a #link(label("doc-installation-deployment"))[traditional deployment] by supplying configuration in YAML files. It's important to understand how files such as the Trino configuration, JVM, and various #link(label("doc-connector"))[catalog properties] are configured in Trino before updating the values.

#anchor("ref-creating-your-own-yaml")

=== Creating your own YAML configuration

When you use your own YAML Kubernetes configuration, you only override the values you specify. The remaining properties use their default values. Add an #raw("example.yaml") with the following configuration:

#code-block("yaml", "image:
  tag: \"latest\"
server:
  workers: 3
coordinator:
  jvm:
    maxHeapSize: \"8G\"
worker:
  jvm:
    maxHeapSize: \"8G\"")

These values are higher than the defaults and allow Trino to use more memory and run more demanding queries. If the values are too high, Kubernetes might not be able to schedule some Trino pods, depending on other applications deployed in this cluster and the size of the cluster nodes.

+ #raw(".image.tag") is set to the current version, latest. Set this value if you need to use a specific version of Trino. The default is #raw("latest"), which is not recommended. Using #raw("latest") will publish a new version of Trino with each release and a following Kubernetes deployment.
+ #raw(".server.workers") is set to #raw("3"). This value sets the number of workers, in this case, a coordinator and three worker nodes are deployed.
+ #raw(".coordinator.jvm.maxHeapSize") is set to #raw("8GB"). This sets the maximum heap size in the JVM of the coordinator. See #link(label("ref-jvm-config"))[jvm-config].
+ #raw(".worker.jvm.maxHeapSize") is set to #raw("8GB"). This sets the maximum heap size in the JVM of the worker. See #link(label("ref-jvm-config"))[jvm-config].

#warning[
Some memory settings need to be tuned carefully as setting some values outside the range of the maximum heap size will cause Trino startup to fail. See the warnings listed on #link(label("doc-admin-properties-resource-management"))[Resource management properties].
]

Reference #link("https://trinodb.github.io/charts/charts/trino/")[the full list of properties] that can be overridden in the Helm chart.

#anchor("ref-kubernetes-configuration-best-practices")

#note[
Although #raw("example.yaml") is used to refer to the Kubernetes configuration file in this document, you should use clear naming guidelines for the cluster and deployment you are managing. For example, #raw("cluster-example-trino-etl.yaml") might refer to a Trino deployment for a cluster used primarily for extract-transform-load queries deployed on the #raw("example") Kubernetes cluster. See #link("https://kubernetes.io/docs/concepts/configuration/overview/")[Configuration Best Practices] for more tips on configuring Kubernetes deployments.
]

=== Adding catalogs

A common use-case is to add custom catalogs. You can do this by adding values to the #raw("catalogs") property in the #raw("example.yaml") file.

#code-block("yaml", "catalogs:
  lakehouse: |-
    connector.name=iceberg
    hive.metastore.uri=thrift://example.net:9083
  rdbms: |-
    connector.name=postgresql
    connection-url=jdbc:postgresql://example.net:5432/database
    connection-user=root
    connection-password=secret
  tpch: |-
    connector.name=tpch
    tpch.splits-per-node=4")

This adds both #raw("lakehouse") and #raw("rdbms") catalogs to the Kubernetes deployment configuration.

#anchor("ref-running-a-local-kubernetes-cluster-with-kind")

== Running a local Kubernetes cluster with kind

For local deployments, you can use #link("https://kind.sigs.k8s.io")[kind \(Kubernetes in Docker\)]. Follow the steps below to run #raw("kind") on your system.

+ #raw("kind") runs on #link("https://www.docker.com")[Docker], so first check if Docker is installed:
  
  #code-block("text", "docker --version")
  
  If this command fails, install Docker by following #link("https://docs.docker.com/engine/install/")[Docker installation instructions].
+ Install #raw("kind") by following the #link("https://kind.sigs.k8s.io/docs/user/quick-start/#installation")[kind installation instructions].
+ Run a Kubernetes cluster in #raw("kind") by running the command:
  
  #code-block("text", "kind create cluster --name trino")
  
  #note[
  The #raw("name") parameter is optional but is used to showcase how the namespace is applied in future commands. The cluster name defaults to #raw("kind") if no parameter is added. Use #raw("trino") to make the application on this cluster obvious.
  ]
+ Verify that #raw("kubectl") is running against the correct Kubernetes cluster.
  
  #code-block("text", "kubectl cluster-info --context kind-trino")
  
  If you have multiple Kubernetes clusters already configured within #raw("~/.kube/config"), you need to pass the #raw("context") parameter to the #raw("kubectl") commands to operate with the local #raw("kind") cluster. #raw("kubectl") uses the #link("https://kubernetes.io/docs/reference/kubectl/cheatsheet/#kubectl-context-and-configuration")[default context] if this parameter isn't supplied. Notice the context is the name of the cluster with the #raw("kind-") prefix added. Now you can look at all the Kubernetes objects running on your #raw("kind") cluster.
+ Set up Trino by following the #link(label("ref-running-trino-using-helm"))[running-trino-using-helm] steps. When running the #raw("kubectl get all") command, add the #raw("context") parameter.
  
  #code-block("text", "kubectl get all --context kind-trino")
+ Run some queries by following the #link("#executing-queries")[Executing queries] steps.
+ Once you are done with the cluster using kind, you can delete the cluster.
  
  #code-block("text", "kind delete cluster -n trino")

== Cleaning up

To uninstall Trino from the Kubernetes cluster, run the following command:

#code-block("text", "helm uninstall my-trino-cluster")

You should expect to see the following output:

#code-block("text", "release \"my-trino-cluster\" uninstalled")

To validate that this worked, you can run this #raw("kubectl") command to make sure there are no remaining Kubernetes objects related to the Trino cluster.

#code-block("text", "kubectl get all")
