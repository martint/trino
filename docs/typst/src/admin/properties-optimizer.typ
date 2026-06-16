#import "/lib/trino-docs.typ": *

#anchor("doc-admin-properties-optimizer")
= Optimizer properties

== #raw("optimizer.dictionary-aggregation")

- #strong[Type:] #link(label("ref-prop-type-boolean"))[prop-type-boolean]
- #strong[Default value:] #raw("false")
- #strong[Session property:] #raw("dictionary_aggregation")

Enables optimization for aggregations on dictionaries.

== #raw("optimizer.optimize-metadata-queries")

- #strong[Type:] #link(label("ref-prop-type-boolean"))[prop-type-boolean]
- #strong[Default value:] #raw("false")
- #strong[Session property:] #raw("optimize_metadata_queries")

Enable optimization of some aggregations by using values that are stored as metadata. This allows Trino to execute some simple queries in constant time. Currently, this optimization applies to #raw("max"), #raw("min") and #raw("approx_distinct") of partition keys and other aggregation insensitive to the cardinality of the input,including #raw("DISTINCT") aggregates. Using this may speed up some queries significantly.

The main drawback is that it can produce incorrect results, if the connector returns partition keys for partitions that have no rows. In particular, the Hive connector can return empty partitions, if they were created by other systems. Trino cannot create them.

== #raw("optimizer.distinct-aggregations-strategy")

- #strong[Type:] #link(label("ref-prop-type-string"))[prop-type-string]
- #strong[Allowed values:] #raw("AUTOMATIC"), #raw("MARK_DISTINCT"), #raw("SINGLE_STEP"), #raw("PRE_AGGREGATE"), #raw("SPLIT_TO_SUBQUERIES")
- #strong[Default value:] #raw("AUTOMATIC")
- #strong[Session property:] #raw("distinct_aggregations_strategy")

The strategy to use for multiple distinct aggregations.

- #raw("SINGLE_STEP") Computes distinct aggregations in single-step without any pre-aggregations. This strategy will perform poorly if the number of distinct grouping keys is small.
- #raw("MARK_DISTINCT") uses #raw("MarkDistinct") for multiple distinct aggregations or for mix of distinct and non-distinct aggregations.
- #raw("PRE_AGGREGATE") Computes distinct aggregations using a combination of aggregation and pre-aggregation steps.
- #raw("SPLIT_TO_SUBQUERIES") Splits the aggregation input to independent sub-queries, where each subquery computes single distinct aggregation thus improving parallelism
- #raw("AUTOMATIC") chooses the strategy automatically.

Single-step strategy is preferred. However, for cases with limited concurrency due to a small number of distinct grouping keys, it will choose an alternative strategy based on input data statistics.

== #raw("optimizer.push-aggregation-through-outer-join")

- #strong[Type:] #link(label("ref-prop-type-boolean"))[prop-type-boolean]
- #strong[Default value:] #raw("true")
- #strong[Session property:] #raw("push_aggregation_through_outer_join")

When an aggregation is above an outer join and all columns from the outer side of the join are in the grouping clause, the aggregation is pushed below the outer join. This optimization is particularly useful for correlated scalar subqueries, which get rewritten to an aggregation over an outer join. For example:

#code-block(none, "SELECT * FROM item i
    WHERE i.i_current_price > (
        SELECT AVG(j.i_current_price) FROM item j
            WHERE i.i_category = j.i_category);")

Enabling this optimization can substantially speed up queries by reducing the amount of data that needs to be processed by the join. However, it may slow down some queries that have very selective joins.

== #raw("optimizer.push-table-write-through-union")

- #strong[Type:] #link(label("ref-prop-type-boolean"))[prop-type-boolean]
- #strong[Default value:] #raw("true")
- #strong[Session property:] #raw("push_table_write_through_union")

Parallelize writes when using #raw("UNION ALL") in queries that write data. This improves the speed of writing output tables in #raw("UNION ALL") queries, because these writes do not require additional synchronization when collecting results. Enabling this optimization can improve #raw("UNION ALL") speed, when write speed is not yet saturated. However, it may slow down queries in an already heavily loaded system.

== #raw("optimizer.push-filter-into-values-max-row-count")

- #strong[Type:] #link(label("ref-prop-type-integer"))[prop-type-integer]
- #strong[Default value:] #raw("100")
- #strong[Minimum value:] #raw("0")
- #strong[Session property:] #raw("push_filter_into_values_max_row_count")

The number of rows in #link(label("doc-sql-values"))[VALUES] below which the planner evaluates a filter on top of #raw("VALUES") to optimize the query plan.

== #raw("optimizer.join-reordering-strategy")

- #strong[Type:] #link(label("ref-prop-type-string"))[prop-type-string]
- #strong[Allowed values:] #raw("AUTOMATIC"), #raw("ELIMINATE_CROSS_JOINS"), #raw("NONE")
- #strong[Default value:] #raw("AUTOMATIC")
- #strong[Session property:] #raw("join_reordering_strategy")

The join reordering strategy to use.  #raw("NONE") maintains the order the tables are listed in the query.  #raw("ELIMINATE_CROSS_JOINS") reorders joins to eliminate cross joins, where possible, and otherwise maintains the original query order. When reordering joins, it also strives to maintain the original table order as much as possible. #raw("AUTOMATIC") enumerates possible orders, and uses statistics-based cost estimation to determine the least cost order. If stats are not available, or if for any reason a cost could not be computed, the #raw("ELIMINATE_CROSS_JOINS") strategy is used.

== #raw("optimizer.max-reordered-joins")

- #strong[Type:] #link(label("ref-prop-type-integer"))[prop-type-integer]
- #strong[Default value:] #raw("8")
- #strong[Session property:] #raw("max_reordered_joins")

When optimizer.join-reordering-strategy is set to cost-based, this property determines the maximum number of joins that can be reordered at once.

#warning[
The number of possible join orders scales factorially with the number of relations, so increasing this value can cause serious performance issues.
]

== #raw("optimizer.optimize-duplicate-insensitive-joins")

- #strong[Type:] #link(label("ref-prop-type-boolean"))[prop-type-boolean]
- #strong[Default value:] #raw("true")
- #strong[Session property:] #raw("optimize_duplicate_insensitive_joins")

Reduces number of rows produced by joins when optimizer detects that duplicated join output rows can be skipped.

== #raw("optimizer.use-exact-partitioning")

- #strong[Type:] #link(label("ref-prop-type-boolean"))[prop-type-boolean]
- #strong[Default value:] #raw("false")
- #strong[Session property:] #raw("use_exact_partitioning")

Re-partition data unless the partitioning of the upstream #link(label("ref-trino-concept-stage"))[stage] exactly matches what the downstream stage expects.

== #raw("optimizer.use-table-scan-node-partitioning")

- #strong[Type:] #link(label("ref-prop-type-boolean"))[prop-type-boolean]
- #strong[Default value:] #raw("true")
- #strong[Session property:] #raw("use_table_scan_node_partitioning")

Use connector provided table node partitioning when reading tables. For example, table node partitioning corresponds to Hive table buckets. When set to #raw("true") and minimal partition to task ratio is matched or exceeded, each table partition is read by a separate worker. The minimal ratio is defined in #raw("optimizer.table-scan-node-partitioning-min-bucket-to-task-ratio").

Partition reader assignments are distributed across workers for parallel processing. Use of table scan node partitioning can improve query performance by reducing query complexity. For example, cluster wide data reshuffling might not be needed when processing an aggregation query. However, query parallelism might be reduced when partition count is low compared to number of workers.

== #raw("optimizer.table-scan-node-partitioning-min-bucket-to-task-ratio")

- #strong[Type:] #link(label("ref-prop-type-double"))[prop-type-double]
- #strong[Default value:] #raw("0.5")
- #strong[Session property:] #raw("table_scan_node_partitioning_min_bucket_to_task_ratio")

Specifies minimal bucket to task ratio that has to be matched or exceeded in order to use table scan node partitioning. When the table bucket count is small compared to the number of workers, then the table scan is distributed across all workers for improved parallelism.

== #raw("optimizer.colocated-joins-enabled")

- #strong[Type:] #link(label("ref-prop-type-boolean"))[prop-type-boolean]
- #strong[Default value:] #raw("true")
- #strong[Session property:] #raw("colocated_join")

Use co-located joins when both sides of a join have the same table partitioning on the join keys and the conditions for #raw("optimizer.use-table-scan-node-partitioning") are met. For example, a join on bucketed Hive tables with matching bucketing schemes can avoid exchanging data between workers using a co-located join to improve query performance.

== #raw("optimizer.filter-conjunction-independence-factor")

- #strong[Type:] #link(label("ref-prop-type-double"))[prop-type-double]
- #strong[Default value:] #raw("0.75")
- #strong[Min allowed value:] #raw("0")
- #strong[Max allowed value:] #raw("1")
- #strong[Session property:] #raw("filter_conjunction_independence_factor")

Scales the strength of independence assumption for estimating the selectivity of the conjunction of multiple predicates. Lower values for this property will produce more conservative estimates by assuming a greater degree of correlation between the columns of the predicates in a conjunction. A value of #raw("0") results in the optimizer assuming that the columns of the predicates are fully correlated and only the most selective predicate drives the selectivity of a conjunction of predicates.

== #raw("optimizer.join-multi-clause-independence-factor")

- #strong[Type:] #link(label("ref-prop-type-double"))[prop-type-double]
- #strong[Default value:] #raw("0.25")
- #strong[Min allowed value:] #raw("0")
- #strong[Max allowed value:] #raw("1")
- #strong[Session property:] #raw("join_multi_clause_independence_factor")

Scales the strength of independence assumption for estimating the output of a multi-clause join. Lower values for this property will produce more conservative estimates by assuming a greater degree of correlation between the columns of the clauses in a join. A value of #raw("0") results in the optimizer assuming that the columns of the join clauses are fully correlated and only the most selective clause drives the selectivity of the join.

== #raw("optimizer.non-estimatable-predicate-approximation.enabled")

- #strong[Type:] #link(label("ref-prop-type-boolean"))[prop-type-boolean]
- #strong[Default value:] #raw("true")
- #strong[Session property:] #raw("non_estimatable_predicate_approximation_enabled")

Enables approximation of the output row count of filters whose costs cannot be accurately estimated even with complete statistics. This allows the optimizer to produce more efficient plans in the presence of filters which were previously not estimated.

== #raw("optimizer.join-partitioned-build-min-row-count")

- #strong[Type:] #link(label("ref-prop-type-integer"))[prop-type-integer]
- #strong[Default value:] #raw("1000000")
- #strong[Min allowed value:] #raw("0")
- #strong[Session property:] #raw("join_partitioned_build_min_row_count")

The minimum number of join build side rows required to use partitioned join lookup. If the build side of a join is estimated to be smaller than the configured threshold, single threaded join lookup is used to improve join performance. A value of #raw("0") disables this optimization.

== #raw("optimizer.min-input-size-per-task")

- #strong[Type:] #link(label("ref-prop-type-data-size"))[prop-type-data-size]
- #strong[Default value:] #raw("5GB")
- #strong[Min allowed value:] #raw("0MB")
- #strong[Session property:] #raw("min_input_size_per_task")

The minimum input size required per task. This will help optimizer to determine hash partition count for joins and aggregations. Limiting hash partition count for small queries increases concurrency on large clusters where multiple small queries are running concurrently. The estimated value will always be between #raw("min_hash_partition_count") and #raw("max_hash_partition_count") session property. A value of #raw("0MB") disables this optimization.

== #raw("optimizer.min-input-rows-per-task")

- #strong[Type:] #link(label("ref-prop-type-integer"))[prop-type-integer]
- #strong[Default value:] #raw("10000000")
- #strong[Min allowed value:] #raw("0")
- #strong[Session property:] #raw("min_input_rows_per_task")

The minimum number of input rows required per task. This will help optimizer to determine hash partition count for joins and aggregations. Limiting hash partition count for small queries increases concurrency on large clusters where multiple small queries are running concurrently. The estimated value will always be between #raw("min_hash_partition_count") and #raw("max_hash_partition_count") session property. A value of #raw("0") disables this optimization.

== #raw("optimizer.use-cost-based-partitioning")

- #strong[Type:] #link(label("ref-prop-type-boolean"))[prop-type-boolean]
- #strong[Default value:] #raw("true")
- #strong[Session property:] #raw("use_cost_based_partitioning")

When enabled the cost based optimizer is used to determine if repartitioning the output of an already partitioned stage is necessary.
