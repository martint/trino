#import "/lib/trino-docs.typ": *

#anchor("doc-installation")
= Installation

A Trino server can be installed and deployed on a number of different platforms. Typically you run a cluster of machines with one coordinator and many workers. You can find instructions for deploying such a cluster, and related information, in the following sections:

- #link(label("doc-installation-deployment"))[Deploying Trino]
- #link(label("doc-installation-containers"))[Trino in a Docker container]
- #link(label("doc-installation-kubernetes"))[Trino on Kubernetes with Helm]
- #link(label("doc-installation-plugins"))[Plugins]
- #link(label("doc-installation-query-resiliency"))[Improve query processing resilience]

Once you have a completed the deployment, or if you have access to a running cluster already, you can proceed to configure your #link(label("doc-client"))[client application].
