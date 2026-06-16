#import "/lib/trino-docs.typ": *

#anchor("doc-release-release-0-124")
= Release 0.124

== General

- Fix race in memory tracking of #raw("JOIN") which could cause the cluster to become over committed and possibly crash.
- The #link(label("fn-approx-percentile"), raw("approx_percentile")) aggregation now also accepts an array of percentages.
- Allow nested row type references.
- Fix correctness for some queries with #raw("IN") lists. When all constants in the list are in the range of 32-bit signed integers but the test value can be outside of the range, #raw("true") may be produced when the correct result should be #raw("false").
- Fail queries submitted while coordinator is starting.
- Add JMX stats to track authentication and authorization successes and failures.
- Add configuration support for the system access control plugin. The system access controller can be selected and configured using #raw("etc/access-control.properties"). Note that Presto currently does not ship with any system access controller implementations.
- Add support for #raw("WITH NO DATA") syntax in #raw("CREATE TABLE ... AS SELECT").
- Fix issue where invalid plans are generated for queries with multiple aggregations that require input values to be cast in different ways.
- Fix performance issue due to redundant processing in queries involving #raw("DISTINCT") and #raw("LIMIT").
- Add optimization that can reduce the amount of data sent over the network for grouped aggregation queries. This feature can be enabled by #raw("optimizer.use-intermediate-aggregations") config property or #raw("task_intermediate_aggregation") session property.

== Hive

- Do not count expected exceptions as errors in the Hive metastore client stats.
- Improve performance when reading ORC files with many tiny stripes.

== Verifier

- Add support for pre and post control and test queries.

If you are upgrading, you need to alter your #raw("verifier_queries") table:

#code-block(none, "ALTER TABLE verifier_queries ADD COLUMN test_postqueries text;
ALTER TABLE verifier_queries ADD COLUMN test_prequeries text;
ALTER TABLE verifier_queries ADD COLUMN control_postqueries text;
ALTER TABLE verifier_queries ADD COLUMN control_prequeries text;")
