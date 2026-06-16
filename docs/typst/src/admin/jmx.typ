#import "/lib/trino-docs.typ": *

#anchor("doc-admin-jmx")
= Monitoring with JMX

Trino exposes a large number of different metrics via the Java Management Extensions \(JMX\).

You have to enable JMX by setting the ports used by the RMI registry and server in the #link(label("ref-config-properties"))[config.properties file]:

#code-block("text", "jmx.rmiregistry.port=9080
jmx.rmiserver.port=9081")

- #raw("jmx.rmiregistry.port"): Specifies the port for the JMX RMI registry. JMX clients should connect to this port.
- #raw("jmx.rmiserver.port"): Specifies the port for the JMX RMI server. Trino exports many metrics, that are useful for monitoring via JMX.

Additionally configure a Java system property in the #link(label("ref-jvm-config"))[jvm.config] with the RMI server port:

#code-block("properties", "-Dcom.sun.management.jmxremote.rmi.port=9081")

JConsole \(supplied with the JDK\), #link("https://visualvm.github.io/")[VisualVM], and many other tools can be used to access the metrics in a client application. Many monitoring solutions support JMX. You can also use the #link(label("doc-connector-jmx"))[JMX connector] and query the metrics using SQL.

Many of these JMX metrics are a complex metric object such as a #raw("CounterStat") that has a collection of related metrics. For example, #raw("InputPositions") has #raw("InputPositions.TotalCount"), #raw("InputPositions.OneMinute.Count"), and so on.

A small subset of the available metrics are described below.

== JVM

- Heap size: #raw("java.lang:type=Memory:HeapMemoryUsage.used")
- Thread count: #raw("java.lang:type=Threading:ThreadCount")

== Trino cluster and nodes

- Active nodes: #raw("trino.failuredetector:name=HeartbeatFailureDetector:ActiveCount")
- Free memory \(general pool\): #raw("trino.memory:type=ClusterMemoryPool:name=general:FreeDistributedBytes")
- Cumulative count \(since Trino started\) of queries that ran out of memory and were killed: #raw("trino.memory:name=ClusterMemoryManager:QueriesKilledDueToOutOfMemory")

== Trino queries

- Active queries currently executing or queued: #raw("trino.execution:name=QueryManager:RunningQueries")
- Queries started: #raw("trino.execution:name=QueryManager:StartedQueries.FiveMinute.Count")
- Failed queries from last 5 min \(all\): #raw("trino.execution:name=QueryManager:FailedQueries.FiveMinute.Count")
- Failed queries from last 5 min \(internal\): #raw("trino.execution:name=QueryManager:InternalFailures.FiveMinute.Count")
- Failed queries from last 5 min \(external\): #raw("trino.execution:name=QueryManager:ExternalFailures.FiveMinute.Count")
- Failed queries \(user\): #raw("trino.execution:name=QueryManager:UserErrorFailures.FiveMinute.Count")
- Execution latency \(P50\): #raw("trino.execution:name=QueryManager:ExecutionTime.FiveMinutes.P50")
- Input data rate \(P90\): #raw("trino.execution:name=QueryManager:WallInputBytesRate.FiveMinutes.P90")

== Trino tasks

- Input data bytes: #raw("trino.execution:name=SqlTaskManager:InputDataSize.FiveMinute.Count")
- Input rows: #raw("trino.execution:name=SqlTaskManager:InputPositions.FiveMinute.Count")

== Connectors

Many connectors provide their own metrics. The metric names typically start with #raw("trino.plugin").
