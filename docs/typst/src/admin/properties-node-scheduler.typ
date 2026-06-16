#import "/lib/trino-docs.typ": *

#anchor("doc-admin-properties-node-scheduler")
= Node scheduler properties

== #raw("node-scheduler.include-coordinator")

- #strong[Type:] #link(label("ref-prop-type-boolean"))[prop-type-boolean]
- #strong[Default value:] #raw("true")

Allows scheduling work on the coordinator so that a single machine can function as both coordinator and worker. For large clusters, processing work on the coordinator can negatively impact query performance because the machine's resources are not available for the critical coordinator tasks of scheduling, managing, and monitoring query execution.

=== Splits

== #raw("node-scheduler.max-splits-per-node")

- #strong[Type:] #link(label("ref-prop-type-integer"))[prop-type-integer]
- #strong[Default value:] #raw("256")

The target value for the total number of splits that can be running for each worker node, assuming all splits have the standard split weight.

Using a higher value is recommended, if queries are submitted in large batches \(e.g., running a large group of reports periodically\), or for connectors that produce many splits that complete quickly but do not support assigning split weight values to express that to the split scheduler. Increasing this value may improve query latency, by ensuring that the workers have enough splits to keep them fully utilized.

When connectors do support weight based split scheduling, the number of splits assigned will depend on the weight of the individual splits. If splits are small, more of them are allowed to be assigned to each worker to compensate.

Setting this too high wastes memory and may result in lower performance due to splits not being balanced across workers. Ideally, it should be set such that there is always at least one split waiting to be processed, but not higher.

== #raw("node-scheduler.min-pending-splits-per-task")

- #strong[Type:] #link(label("ref-prop-type-integer"))[prop-type-integer]
- #strong[Default value:] #raw("16")

The minimum number of outstanding splits with the standard split weight guaranteed to be scheduled on a node \(even when the node is already at the limit for total number of splits\) for a single task given the task has remaining splits to process. Allowing a minimum number of splits per stage is required to prevent starvation and deadlocks.

This value must be smaller or equal than #raw("max-adjusted-pending-splits-per-task") and #raw("node-scheduler.max-splits-per-node"), is usually increased for the same reasons, and has similar drawbacks if set too high.

== #raw("node-scheduler.max-adjusted-pending-splits-per-task")

- #strong[Type:] #link(label("ref-prop-type-integer"))[prop-type-integer]
- #strong[Default value:] #raw("2000")

The maximum number of outstanding splits with the standard split weight guaranteed to be scheduled on a node \(even when the node is already at the limit for total number of splits\) for a single task given the task has remaining splits to process. Split queue size is adjusted dynamically during split scheduling and cannot exceed #raw("node-scheduler.max-adjusted-pending-splits-per-task"). Split queue size per task will be adjusted upward if node processes splits faster than it receives them.

Usually increased for the same reasons as #raw("node-scheduler.max-splits-per-node"), with smaller drawbacks if set too high.

#note[
Only applies for #raw("uniform") #link(label("ref-node-scheduler-policy"))[scheduler policy].
]

== #raw("node-scheduler.max-unacknowledged-splits-per-task")

- #strong[Type:] #link(label("ref-prop-type-integer"))[prop-type-integer]
- #strong[Default value:] #raw("2000")

Maximum number of splits that are either queued on the coordinator, but not yet sent or confirmed to have been received by the worker. This limit enforcement takes precedence over other existing split limit configurations like #raw("node-scheduler.max-splits-per-node") or #raw("node-scheduler.max-adjusted-pending-splits-per-task") and is designed to prevent large task update requests that might cause a query to fail.

== #raw("node-scheduler.min-candidates")

- #strong[Type:] #link(label("ref-prop-type-integer"))[prop-type-integer]
- #strong[Minimum value:] #raw("1")
- #strong[Default value:] #raw("10")

The minimum number of candidate nodes that are evaluated by the node scheduler when choosing the target node for a split. Setting this value too low may prevent splits from being properly balanced across all worker nodes. Setting it too high may increase query latency and increase CPU usage on the coordinator.

#anchor("ref-node-scheduler-policy")

== #raw("node-scheduler.policy")

- #strong[Type:] #link(label("ref-prop-type-string"))[prop-type-string]
- #strong[Allowed values:] #raw("uniform"), #raw("topology")
- #strong[Default value:] #raw("uniform")

Sets the node scheduler policy to use when scheduling splits. #raw("uniform")  attempts to schedule splits on the host where the data is located, while maintaining a uniform distribution across all hosts. #raw("topology") tries to schedule splits according to the topology distance between nodes and splits. It is recommended to use #raw("uniform") for clusters where distributed storage runs on the same nodes as Trino workers.

=== Network topology

== #raw("node-scheduler.network-topology.segments")

- #strong[Type:] #link(label("ref-prop-type-string"))[prop-type-string]
- #strong[Default value:] #raw("machine")

A comma-separated string describing the meaning of each segment of a network location. For example, setting #raw("region,rack,machine") means a network location contains three segments.

== #raw("node-scheduler.network-topology.type")

- #strong[Type:] #link(label("ref-prop-type-string"))[prop-type-string]
- #strong[Allowed values:] #raw("flat"), #raw("file"), #raw("subnet")
- #strong[Default value:] #raw("flat")

Sets the network topology type. To use this option, #raw("node-scheduler.policy") must be set to #raw("topology").

- #raw("flat"): the topology has only one segment, with one value for each machine.
- #raw("file"): the topology is loaded from a file using the properties #raw("node-scheduler.network-topology.file") and #raw("node-scheduler.network-topology.refresh-period") described in the following sections.
- #raw("subnet"): the topology is derived based on subnet configuration provided through properties #raw("node-scheduler.network-topology.subnet.cidr-prefix-lengths") and #raw("node-scheduler.network-topology.subnet.ip-address-protocol") described in the following sections.

=== File based network topology

== #raw("node-scheduler.network-topology.file")

- #strong[Type:] #link(label("ref-prop-type-string"))[prop-type-string]

Load the network topology from a file. To use this option, #raw("node-scheduler.network-topology.type") must be set to #raw("file"). Each line contains a mapping between a host name and a network location, separated by whitespace. Network location must begin with a leading #raw("/") and segments are separated by a #raw("/").

#code-block("text", "192.168.0.1 /region1/rack1/machine1
192.168.0.2 /region1/rack1/machine2
hdfs01.example.com /region2/rack2/machine3")

== #raw("node-scheduler.network-topology.refresh-period")

- #strong[Type:] #link(label("ref-prop-type-duration"))[prop-type-duration]
- #strong[Minimum value:] #raw("1ms")
- #strong[Default value:] #raw("5m")

Controls how often the network topology file is reloaded.  To use this option, #raw("node-scheduler.network-topology.type") must be set to #raw("file").

=== Subnet based network topology

== #raw("node-scheduler.network-topology.subnet.ip-address-protocol")

- #strong[Type:] #link(label("ref-prop-type-string"))[prop-type-string]
- #strong[Allowed values:] #raw("IPv4"), #raw("IPv6")
- #strong[Default value:] #raw("IPv4")

Sets the IP address protocol to be used for computing subnet based topology.  To use this option, #raw("node-scheduler.network-topology.type") must be set to #raw("subnet").

== #raw("node-scheduler.network-topology.subnet.cidr-prefix-lengths")

A comma-separated list of #link(label("ref-prop-type-integer"))[prop-type-integer] values defining CIDR prefix lengths for subnet masks. The prefix lengths must be in increasing order. The maximum prefix length values for IPv4 and IPv6 protocols are 32 and 128 respectively. To use this option, #raw("node-scheduler.network-topology.type") must be set to #raw("subnet").

For example, the value #raw("24,25,27") for this property with IPv4 protocol means that masks applied on the IP address to compute location segments are #raw("255.255.255.0"), #raw("255.255.255.128") and #raw("255.255.255.224"). So the segments created for an address #raw("192.168.0.172") are #raw("[192.168.0.0, 192.168.0.128, 192.168.0.160, 192.168.0.172]").
