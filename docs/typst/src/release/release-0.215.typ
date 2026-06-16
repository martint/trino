#import "/lib/trino-docs.typ": *

#anchor("doc-release-release-0-215")
= Release 0.215

== General

- Fix regression in 0.214 that could cause queries to produce incorrect results for queries using map types.
- Fix reporting of the processed input data for source stages in #raw("EXPLAIN ANALYZE").
- Fail queries that use non-leaf resource groups. Previously, they would remain queued forever.
- Improve CPU usage for specific queries \(#issue("11757", "https://github.com/prestodb/presto/issues/11757")\).
- Extend stats and cost model to support #link(label("fn-row-number"), raw("row_number")) window function estimates.
- Improve the join type selection and the reordering of join sides for cases where the join output size cannot be estimated.
- Add dynamic scheduling support to grouped execution. When a stage is executed with grouped execution and the stage has no remote sources, table partitions can be scheduled to tasks in a dynamic way, which can help mitigating skew for queries using grouped execution. This feature can be enabled with the #raw("dynamic_schedule_for_grouped_execution") session property or the #raw("dynamic-schedule-for-grouped-execution") config property.
- Add #link(label("fn-beta-cdf"), raw("beta_cdf")) and #link(label("fn-inverse-beta-cdf"), raw("inverse_beta_cdf")) functions.
- Split the reporting of raw input data and processed input data for source operators.
- Remove collection and reporting of raw input data statistics for the #raw("Values"), #raw("Local Exchange"), and #raw("Local Merge Sort") operators.
- Simplify #raw("EXPLAIN (TYPE IO)") output when there are too many discrete components. This avoids large output at the cost of reduced granularity.
- Add #raw("parse_presto_data_size") function.
- Add support for #raw("UNION ALL") to optimizer's cost model.
- Add support for estimating the cost of filters by using a default filter factor. The default value for the filter factor can be configured with the #raw("default_filter_factor_enabled") session property or the #raw("optimizer.default-filter-factor-enabled").

== Geospatial

- Add input validation checks to #link(label("fn-st-linestring"), raw("ST_LineString")) to conform with the specification.
- Improve spatial join performance.
- Enable spatial joins for join conditions expressed with the #link(label("fn-st-within"), raw("ST_Within")) function.

== Web UI

- Fix #emph[Capture Snapshot] button for showing current thread stacks.
- Fix dropdown for expanding stage skew component on the query details page.
- Improve the performance of the thread snapshot component on the worker status page.
- Make the reporting of #emph[Cumulative Memory] usage consistent on the query list and query details pages.
- Remove legacy thread UI.

== Hive

- Add predicate pushdown support for the #raw("DATE") type to the Parquet reader. This change also fixes a bug that may cause queries with predicates on #raw("DATE") columns to fail with type mismatch errors.

== Redis

- Prevent printing the value of the #raw("redis.password") configuration property to log files.
