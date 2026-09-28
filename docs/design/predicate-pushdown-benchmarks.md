# Predicate pushdown benchmarks

`BenchmarkPredicatePushdown` compares the legacy visitor and iterative rules in
the same build using `iterative_predicate_pushdown_enabled`. The benchmark
measures planning cost; it does not measure query execution throughput.

## Workloads

The `workload` JMH parameter selects a complete case instead of expanding every
dimension into a Cartesian product. Every column is a nullable BIGINT. The mock
connector supplies a positive row-count estimate and refuses filter pushdown.

| Name | Input |
| --- | --- |
| `WIDE_<columns>[_<predicateColumns>]` | Return all table columns; one predicate column by default |
| `NARROW_<schemaColumns>` | Return and filter only the first column of a wide table |
| `UNION_<branches>_<columns>_<predicateColumns>` | Flat union with distinct branch symbols and an outer filter |
| `ENFORCED_<branches>_<columns>_<predicateColumns>` | Same union with equivalent filters already present in every branch |
| `PROJECT_<depth>_<columns>_<predicateColumns>` | Alias projections above a scan, with an outer filter |

Each predicate column has the restriction `BETWEEN 10 AND 100`. Zero predicate
columns provide a traversal control. Union cases use `UNION ALL`, preserving
duplicates. Projection depth is explicit in direct fixtures; SQL optimization
can collapse its corresponding nested subqueries.

Useful independent sweeps are:

* Schema/output columns: 16, 64, 256, 1024, 4096.
* Branches at width 16: 2, 8, 32, 128, 512, 2048.
* Width at 128 branches: 16, 64, 256, 1024.
* Equal leaf-symbol totals: `(branches, columns)` of `(32, 1024)`, `(128, 256)`,
  `(512, 64)`, `(2048, 16)`.
* Predicate columns at width 1024: 0, 1, 8, 64.
* Projection depths at width 256: 1, 4, 16, 64.

## Measurement boundaries

| JMH method | Work included |
| --- | --- |
| `optimizeRelational` | Complete production `PushPredicatesBeforeJoinReordering` phase |
| `optimizeCombined` | Complete production `PushPredicatesAfterProjections` phase, including its simplification and connector-pushdown rules |
| `planSql` | Transaction, parsing, analysis, and logical optimization through `OPTIMIZED`, with `forceSingleNode=true` |
| `createSql` | Transaction, parsing, and initial logical planning through `CREATED`, as an overhead control |

The phase benchmarks include fresh allocators, table-statistics cache, collector,
and iterative memo construction/extraction. They reuse an immutable input built
outside timing, with a live connector transaction for the trial. Neither mode
receives the other mode's output. SQL generation, catalog creation, fixture
generation, and optimizer-factory construction are outside timing.

The SQL methods use `PlanTester`, including its test-only SQL formatting
assertion. Report these as PlanTester SQL-to-plan measurements. Do not subtract
independent `createSql` and `planSql` means to estimate optimizer time. Plans are
returned to JMH without execution or EXPLAIN serialization.

Join reordering and dynamic filtering are disabled. Table-property inference is
enabled, unsafe pushdown is disabled, and the iterative optimizer timeout is ten
minutes. Other settings use the same defaults for both modes. Use an external
deadline below ten minutes for a symmetric bound: the legacy visitor does not
apply the iterative timeout.

## Validation and running

Run `TestBenchmarkPredicatePushdown` with `mvnd`, a 2 GiB build daemon, and an
8 GiB test heap. It checks that direct fixtures retain their requested scan
width/branch count, that both production phases preserve outputs and leave the
expected leaf filters, and that repeated invocations leave their input unchanged.
Small SQL counterparts execute against expected multisets containing NULLs,
duplicates, and predicate boundary values in both modes.

For JMH, compile tests with the regular compiler profile and
`-Dmaven.compiler.proc=full` so that the JMH annotation processor generates
`target/test-classes/META-INF/BenchmarkList`. The Error Prone profile replaces
the annotation processor path and does not generate this registry. When switching
profiles, force test recompilation if Maven considers the existing classes current.

Use the test runtime classpath to run the benchmark main class or JMH's main
class. The benchmark supports an untimed diagnostic entry point:

```text
io.trino.sql.planner.BenchmarkPredicatePushdown --diagnose UNION_128_256_1 true optimizeRelational
io.trino.sql.planner.BenchmarkPredicatePushdown --diagnose UNION_128_256_1 false planSql
```

Diagnostics print input/output node and symbol counts, scan width, union fanout,
projection/filter counts, and rule statistics. SQL diagnostics also print actual
plan shapes entering the two production phases. Diagnostic elapsed time includes
instrumentation and first-use compilation; it is not a warmed JMH result.

For JMH, select the boundary and case explicitly, for example:

```text
io.trino.sql.planner.BenchmarkPredicatePushdown '.*BenchmarkPredicatePushdown.optimizeRelational' -p workload=UNION_128_256_1 -p iterative=true -f 1 -wi 3 -i 5 -w 1s -r 1s -prof gc -rf json -rff result.json
```

Run separate legacy/iterative fork pairs serially in balanced randomized order.
The annotations default to two forks, three one-second warmups, five one-second
measurements, one thread, and an 8 GiB fork heap. Hold JDK, GC, host, and JVM flags
fixed. Preflight large cases before repeated measurement. Monitor process-tree
RSS and available memory; a heap limit is insufficient. Keep local heavy jobs
serial and never use a local JVM heap above 12 GiB.

Retain raw JSON, complete logs and exit statuses, revision/configuration,
workload order, shape diagnostics, deadlines, and memory measurements outside
the checkout. Report time and allocation ratios per case with fork-level
uncertainty, including failures and censored cases. Confirm suspected regressions
with longer warmup and additional fork pairs. These synthetic stress cases do
not define a representative production workload mix.
