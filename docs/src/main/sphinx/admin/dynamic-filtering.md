# Dynamic filtering

Dynamic filters are discovered by the runtime constraint propagation framework
while physical operators are initialized. Constraints travel through operators
according to their row semantics and are bound to connector columns at scans.

Dynamic filtering optimizations significantly improve the performance of queries
with selective joins by avoiding reading of data that would be filtered by join condition.

Consider the following query which captures a common pattern of a fact table `store_sales`
joined with a filtered dimension table `date_dim`:

> SELECT count(\*)
> FROM store_sales
> JOIN date_dim ON store_sales.ss_sold_date_sk = date_dim.d_date_sk
> WHERE d_following_holiday='Y' AND d_year = 2000;

Without dynamic filtering, Trino pushes predicates for the dimension table to the
table scan on `date_dim`, and it scans all the data in the fact table since there
are no filters on `store_sales` in the query. The join operator ends up throwing away
most of the probe-side rows as the join criteria is highly selective.

When dynamic filtering is enabled, Trino collects candidate values for join condition
from the processed dimension table on the right side of join. In the case of broadcast joins,
the runtime predicates generated from this collection are pushed into the local table scan
on the left side of the join running on the same worker.

Additionally, these runtime predicates are communicated to the coordinator over the network
so that dynamic filtering can also be performed on the coordinator during enumeration of
table scan splits.

For example, in the case of the Hive connector, dynamic filters are used
to skip loading of partitions which don't match the join criteria.
This is known as **dynamic partition pruning**.

After completing the collection of dynamic filters, the coordinator also distributes them
to worker nodes over the network for partitioned joins. This allows push down of dynamic
filters from partitioned joins into the table scans on the left side of that join.

The results of dynamic filtering optimization can include the following benefits:

- improved overall query performance
- reduced network traffic between Trino and the data source
- reduced load on the remote data source

Dynamic filtering is enabled by default. It can be disabled by setting either the
`enable-dynamic-filtering` configuration property, or the session property
`enable_dynamic_filtering` to `false`.

Support for push down of dynamic filters is specific to each connector,
and the relevant underlying database or storage system. The documentation for
specific connectors with support for dynamic filtering includes further details,
for example the {ref}`Hive connector <hive-dynamic-filtering>`
or the {ref}`Memory connector <memory-dynamic-filtering>`.

## Analysis and confirmation

Dynamic filtering depends on a number of factors:

- Support for dynamic filtering for a given join operation in Trino.
  Currently inner and right joins with `=`, `<`, `<=`, `>`, `>=` or
  `IS NOT DISTINCT FROM` join conditions, and
  semi-joins with `IN` conditions are supported.
- Connector support for utilizing dynamic filters pushed into the table scan at runtime.
  For example, the Hive connector can push dynamic filters into ORC and Parquet readers
  to perform stripe or row-group pruning.
- Connector support for utilizing dynamic filters at the splits enumeration stage.
- Size of right (build) side of the join.

Static plans do not contain `dynamicFilterAssignments` or dynamic-filter
predicates. Use query and operator statistics to confirm that runtime constraints
were collected and applied.

During execution of a query with dynamic filters, Trino populates statistics
about dynamic filters in the QueryInfo JSON available through the
{doc}`/admin/web-interface`.
In the `queryStats` section, statistics about dynamic filters collected
by the coordinator can be found in the `dynamicFiltersStats` structure.

```text
"dynamicFiltersStats" : {
      "dynamicFilterDomainStats" : [ {
        "dynamicFilterId" : "df_370",
        "simplifiedDomain" : "[ SortedRangeSet[type=bigint, ranges=3, {[2451546], ..., [2451905]}] ]",
        "collectionDuration" : "2.34s"
      } ],
      "lazyDynamicFilters" : 1,
      "replicatedDynamicFilters" : 1,
      "totalDynamicFilters" : 1,
      "dynamicFiltersCompleted" : 1
}
```

Push down of dynamic filters into a table scan on the worker nodes can be
verified by looking at the operator statistics for that table scan.
`dynamicFilterSplitsProcessed` records the number of splits
processed after a dynamic filter is pushed down to the table scan.

```text
"operatorType" : "ScanFilterAndProjectOperator",
"totalDrivers" : 1,
"addInputCalls" : 762,
"addInputWall" : "0.00ns",
"addInputCpu" : "0.00ns",
"physicalInputDataSize" : "0B",
"physicalInputPositions" : 28800991,
"inputPositions" : 28800991,
"dynamicFilterSplitsProcessed" : 1,
```

## Dynamic filter collection thresholds

In order for dynamic filtering to work, the smaller dimension table
needs to be chosen as a join’s build side. The cost-based optimizer can automatically
do this using table statistics provided by connectors. Therefore, it is recommended
to keep {doc}`table statistics </optimizer/statistics>` up to date and rely on the
CBO to correctly choose the smaller table on the build side of join.

Collection of values of the join key columns from the build side for
dynamic filtering may incur additional CPU overhead during query execution.
Therefore, to limit the overhead of collecting dynamic filters
to the cases where the join operator is likely to be selective,
Trino defines thresholds on the size of dynamic filters collected from build side tasks.

Limits on the size of dynamic filters can be configured using the configuration
properties
`dynamic-filtering.max-distinct-values-per-driver`,
`dynamic-filtering.max-size-per-driver` ,
`dynamic-filtering.range-row-limit-per-driver`,
`dynamic-filtering.partitioned.max-distinct-values-per-driver`,
`dynamic-filtering.partitioned.max-size-per-driver` and
`dynamic-filtering.partitioned.range-row-limit-per-driver`.

The `dynamic-filtering.*` limits are applied
when dynamic filters are collected before build side is partitioned on join
keys (when broadcast join is chosen or when fault-tolerant execution is enabled).
The `dynamic-filtering.partitioned.*` limits are applied when dynamic filters
are collected after build side is partitioned on join keys
(when partitioned join is chosen and fault-tolerant execution is disabled).

The properties based on `max-distinct-values-per-driver` and `max-size-per-driver`
define thresholds for the size up to which dynamic filters are collected in a
distinct values data structure. When the build side exceeds these thresholds,
Trino switches to collecting min and max values per column to reduce overhead.
This min-max filter has much lower granularity than the distinct values filter.
However, it may still be beneficial in filtering some data from the probe side,
especially when a range of values is selected from the build side of the join.
The limits for min-max filters collection are defined by the properties
based on `range-row-limit-per-driver`.

## Dimension tables layout

Dynamic filtering works best for dimension tables where
table keys are correlated with columns.

For example, a date dimension key column should be correlated with a date column,
so the table keys monotonically increase with date values.
An address dimension key can be composed of other columns such as
`COUNTRY-STATE-ZIP-ADDRESS_ID` with an example value of `US-NY-10001-1234`.
This usage allows dynamic filtering to succeed even with a large number
of selected rows from the dimension table.

## Limitations

- Min-max dynamic filter collection is not supported for `DOUBLE`, `REAL` and unorderable data types.
- Dynamic filtering is not supported for `DOUBLE` and `REAL` data types when using `IS NOT DISTINCT FROM` predicate.
- Dynamic filtering is supported when the join key contains a cast from the build key type to the
  probe key type. Dynamic filtering is also supported in limited scenarios when there is an implicit
  cast from the probe key type to the build key type. For example, dynamic filtering is supported when
  the build side key is of `DOUBLE` type and the probe side key is of `REAL` or `INTEGER` type.
