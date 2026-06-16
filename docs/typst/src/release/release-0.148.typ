#import "/lib/trino-docs.typ": *

#anchor("doc-release-release-0-148")
= Release 0.148

== General

- Fix issue where auto-commit transaction can be rolled back for a successfully completed query.
- Fix detection of colocated joins.
- Fix planning bug involving partitioning with constants.
- Fix window functions to correctly handle empty frames between unbounded and bounded in the same direction. For example, a frame such as #raw("ROWS BETWEEN UNBOUNDED PRECEDING AND 2 PRECEDING") would incorrectly use the first row as the window frame for the first two rows rather than using an empty frame.
- Fix correctness issue when grouping on columns that are also arguments to aggregation functions.
- Fix failure when chaining #raw("AT TIME ZONE"), e.g. #raw("SELECT TIMESTAMP '2016-01-02 12:34:56' AT TIME ZONE 'America/Los_Angeles' AT TIME ZONE 'UTC'").
- Fix data duplication when #raw("task.writer-count") configuration mismatches between coordinator and worker.
- Fix bug where #raw("node-scheduler.max-pending-splits-per-node-per-task") config is not always honored by node scheduler. This bug could stop the cluster from making further progress.
- Fix incorrect results for grouping sets with partitioned source.
- Add #raw("colocated-joins-enabled") to enable colocated joins by default for connectors that expose node-partitioned data.
- Add support for colocated unions.
- Reduce initial memory usage of #link(label("fn-array-agg"), raw("array_agg")) function.
- Improve planning of co-partitioned #raw("JOIN") and #raw("UNION").
- Improve planning of aggregations over partitioned data.
- Improve the performance of the #link(label("fn-array-sort"), raw("array_sort")) function.
- Improve outer join predicate push down.
- Increase default value for #raw("query.initial-hash-partitions") to #raw("100").
- Change default value of #raw("query.max-memory-per-node") to #raw("10%") of the Java heap.
- Change default #raw("task.max-worker-threads") to #raw("2") times the number of cores.
- Use HTTPS in JDBC driver when using port 443.
- Warn if Presto server is not using G1 garbage collector.
- Move interval types out of SPI.

== Interval fixes

This release fixes several problems with large and negative intervals.

- Fix parsing of negative interval literals. Previously, the sign of each field was treated independently instead of applying to the entire interval value. For example, the literal #raw("INTERVAL '-2-3' YEAR TO MONTH") was interpreted as a negative interval of #raw("21") months rather than #raw("27") months \(positive #raw("3") months was added to negative #raw("24") months\).
- Fix handling of #raw("INTERVAL DAY TO SECOND") type in REST API. Previously, intervals greater than #raw("2,147,483,647") milliseconds \(about #raw("24") days\) were returned as the wrong value.
- Fix handling of #raw("INTERVAL YEAR TO MONTH") type. Previously, intervals greater than #raw("2,147,483,647") months were returned as the wrong value from the REST API and parsed incorrectly when specified as a literal.
- Fix formatting of negative intervals in REST API. Previously, negative intervals had a negative sign before each component and could not be parsed.
- Fix formatting of negative intervals in JDBC #raw("PrestoInterval") classes.

#note[
Older versions of the JDBC driver will misinterpret most negative intervals from new servers. Make sure to update the JDBC driver along with the server.
]

== Functions and language features

- Add #link(label("fn-element-at"), raw("element_at")) function for map type.
- Add #link(label("fn-split-to-map"), raw("split_to_map")) function.
- Add #link(label("fn-zip"), raw("zip")) function.
- Add #link(label("fn-map-union"), raw("map_union")) aggregation function.
- Add #raw("ROW") syntax for constructing row types.
- Add support for #raw("REVOKE") permission syntax.
- Add support for #raw("SMALLINT") and #raw("TINYINT") types.
- Add support for non-equi outer joins.

== Verifier

- Add #raw("skip-cpu-check-regex") config property which can be used to skip the CPU time comparison for queries that match the given regex.
- Add #raw("check-cpu") config property which can be used to disable CPU time comparison.

== Hive

- Fix #raw("NoClassDefFoundError") for #raw("KMSClientProvider") in HDFS client.
- Fix creating tables on S3 in an empty database.
- Implement #raw("REVOKE") permission syntax.
- Add support for #raw("SMALLINT") and #raw("TINYINT")
- Support #raw("DELETE") from unpartitioned tables.
- Add support for Kerberos authentication when talking to Hive\/HDFS.
- Push down filters for columns of type #raw("DECIMAL").
- Improve CPU efficiency when reading ORC files.

== Cassandra

- Allow configuring load balancing policy and no host available retry.
- Add support for #raw("varchar(n)").

== Kafka

- Update to Kafka client 0.8.2.2. This enables support for LZ4 data.

== JMX

- Add #raw("jmx.history") schema with in-memory periodic samples of values from JMX MBeans.

== MySQL and PostgreSQL

- Push down predicates for #raw("VARCHAR"), #raw("DATE"), #raw("TIME") and #raw("TIMESTAMP") types.

== Other connectors

- Add support for #raw("varchar(n)") to the Redis, TPC-H, MongoDB, Local File and Example HTTP connectors.
