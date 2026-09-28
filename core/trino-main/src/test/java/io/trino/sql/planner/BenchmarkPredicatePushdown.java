/*
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */
package io.trino.sql.planner;

import com.google.common.collect.ImmutableList;
import com.google.common.collect.ImmutableListMultimap;
import com.google.common.collect.ImmutableMap;
import io.trino.Session;
import io.trino.connector.MockConnectorFactory;
import io.trino.connector.MockConnectorPlugin;
import io.trino.connector.MockConnectorTableHandle;
import io.trino.cost.CachingTableStatsProvider;
import io.trino.cost.RuntimeInfoProvider;
import io.trino.execution.querystats.PlanOptimizersStatsCollector;
import io.trino.metadata.QualifiedObjectName;
import io.trino.metadata.TableHandle;
import io.trino.spi.connector.ColumnHandle;
import io.trino.spi.connector.ColumnMetadata;
import io.trino.spi.predicate.TupleDomain;
import io.trino.spi.statistics.Estimate;
import io.trino.spi.statistics.TableStatistics;
import io.trino.sql.ir.Constant;
import io.trino.sql.ir.Expression;
import io.trino.sql.planner.iterative.IterativeOptimizer;
import io.trino.sql.planner.optimizations.PlanOptimizer;
import io.trino.sql.planner.plan.Assignments;
import io.trino.sql.planner.plan.FilterNode;
import io.trino.sql.planner.plan.PlanNode;
import io.trino.sql.planner.plan.ProjectNode;
import io.trino.sql.planner.plan.TableScanNode;
import io.trino.sql.planner.plan.UnionNode;
import io.trino.testing.PlanTester;
import org.openjdk.jmh.annotations.Benchmark;
import org.openjdk.jmh.annotations.BenchmarkMode;
import org.openjdk.jmh.annotations.Fork;
import org.openjdk.jmh.annotations.Measurement;
import org.openjdk.jmh.annotations.Mode;
import org.openjdk.jmh.annotations.OutputTimeUnit;
import org.openjdk.jmh.annotations.Param;
import org.openjdk.jmh.annotations.Scope;
import org.openjdk.jmh.annotations.Setup;
import org.openjdk.jmh.annotations.State;
import org.openjdk.jmh.annotations.TearDown;
import org.openjdk.jmh.annotations.Threads;
import org.openjdk.jmh.annotations.Warmup;
import org.openjdk.jmh.infra.BenchmarkParams;
import org.openjdk.jmh.runner.Runner;
import org.openjdk.jmh.runner.options.CommandLineOptions;
import org.openjdk.jmh.runner.options.OptionsBuilder;

import java.util.ArrayDeque;
import java.util.Collections;
import java.util.List;
import java.util.Map;
import java.util.Optional;
import java.util.Set;
import java.util.concurrent.TimeUnit;
import java.util.stream.IntStream;

import static com.google.common.base.Preconditions.checkArgument;
import static com.google.common.base.Preconditions.checkState;
import static com.google.common.collect.ImmutableList.toImmutableList;
import static com.google.common.collect.MoreCollectors.onlyElement;
import static io.trino.execution.querystats.PlanOptimizersStatsCollector.createPlanOptimizersStatsCollector;
import static io.trino.execution.warnings.WarningCollector.NOOP;
import static io.trino.spi.type.BigintType.BIGINT;
import static io.trino.sql.ir.ComparisonOperator.GREATER_THAN_OR_EQUAL;
import static io.trino.sql.ir.ComparisonOperator.LESS_THAN_OR_EQUAL;
import static io.trino.sql.ir.IrUtils.and;
import static io.trino.sql.ir.TestingIr.comparison;
import static io.trino.sql.planner.LogicalPlanner.Stage.CREATED;
import static io.trino.sql.planner.LogicalPlanner.Stage.OPTIMIZED;
import static io.trino.sql.planner.SymbolsExtractor.extractOutputSymbols;
import static io.trino.testing.TestingSession.testSessionBuilder;
import static java.util.stream.Collectors.joining;

/// Compare complete production predicate phases and SQL-to-plan cost using the
/// session fallback switch. SQL formatting assertions in PlanTester are included
/// in planSql; optimizeRelational and optimizeCombined exclude SQL processing.
@BenchmarkMode(Mode.AverageTime)
@OutputTimeUnit(TimeUnit.MILLISECONDS)
@Fork(value = 2, jvmArgsAppend = "-Xmx8g")
@Warmup(iterations = 3, time = 1)
@Measurement(iterations = 5, time = 1)
@Threads(1)
public class BenchmarkPredicatePushdown
{
    @State(Scope.Thread)
    public static class BenchmarkData
    {
        // Named cases avoid an accidental Cartesian product of width and fanout.
        @Param({
                "WIDE_16", "WIDE_256", "WIDE_1024", "WIDE_4096", "NARROW_4096",
                "UNION_8_16_1", "UNION_128_16_1", "UNION_512_16_1", "UNION_2048_16_1",
                "UNION_128_256_1", "UNION_128_1024_1", "ENFORCED_128_64_8", "PROJECT_16_256_8",
        })
        public String workload = "WIDE_16";

        @Param({"false", "true"})
        public boolean iterative;

        PlanTester planTester;
        Session phaseSession;
        Workload parameters;
        String sql;
        PlanNode input;
        Set<Symbol> symbols;
        int nextNodeId;
        List<PlanOptimizer> optimizers;
        PlanOptimizer relational;
        PlanOptimizer combined;
        boolean createFixture = true;

        @Setup
        public void setup(BenchmarkParams benchmarkParams)
        {
            createFixture = !benchmarkParams.getBenchmark().endsWith("Sql");
            setup();
        }

        public void setup()
        {
            parameters = Workload.parse(workload);
            Session session = testSessionBuilder()
                    .setCatalog("bench")
                    .setSchema("default")
                    .setSystemProperty("iterative_predicate_pushdown_enabled", Boolean.toString(iterative))
                    .setSystemProperty("iterative_optimizer_timeout", "10m")
                    .setSystemProperty("join_reordering_strategy", "NONE")
                    .setSystemProperty("enable_dynamic_filtering", "false")
                    .setSystemProperty("predicate_pushdown_use_table_properties", "true")
                    .setSystemProperty("allow_unsafe_pushdown", "false")
                    .build();
            planTester = PlanTester.create(session);
            List<ColumnMetadata> columns = IntStream.range(0, parameters.schemaColumns())
                    .mapToObj(i -> new ColumnMetadata("c" + i, BIGINT))
                    .collect(toImmutableList());
            planTester.installPlugin(new MockConnectorPlugin(MockConnectorFactory.builder()
                    .withGetTableHandle((_, name) -> new MockConnectorTableHandle(name))
                    .withGetColumns(_ -> columns)
                    .withGetTableStatistics(_ -> TableStatistics.builder().setRowCount(Estimate.of(1_000_000)).build())
                    .withData(_ -> testRows(parameters.schemaColumns()))
                    .build()));
            planTester.createCatalog("bench", "mock", ImmutableMap.of());
            optimizers = planTester.getPlanOptimizers(true);
            relational = findPhase("PushPredicatesBeforeJoinReordering");
            combined = findPhase("PushPredicatesAfterProjections");
            sql = parameters.sql();
            if (!createFixture) {
                return;
            }

            // Keep the fixture's connector transaction alive for the trial. Each
            // invocation still gets fresh allocators, caches, collector and memo.
            phaseSession = planTester.getDefaultSession().beginTransactionId(
                    planTester.getTransactionManager().beginTransaction(false),
                    planTester.getTransactionManager(),
                    planTester.getAccessControl());
            planTester.getPlannerContext().getMetadata().beginQuery(phaseSession);
            input = createInput();
            symbols = extractOutputSymbols(input);
            Shape shape = Shape.of(input);
            checkState(shape.scans() == parameters.branches(), "Unexpected scan count: %s", shape);
            checkState(shape.scanColumns() == (long) parameters.branches() * parameters.columns(), "Unexpected scan width: %s", shape);
            checkState(input.getOutputSymbols().size() == parameters.columns(), "Unexpected output width");
        }

        private PlanOptimizer findPhase(String name)
        {
            return optimizers.stream()
                    .filter(IterativeOptimizer.class::isInstance)
                    .map(IterativeOptimizer.class::cast)
                    .filter(optimizer -> optimizer.getName().equals(name))
                    .collect(onlyElement());
        }

        private PlanNode createInput()
        {
            var metadata = planTester.getPlannerContext().getMetadata();
            TableHandle table = metadata.getTableHandle(phaseSession, new QualifiedObjectName("bench", "default", "t")).orElseThrow();
            Map<String, ColumnHandle> handles = metadata.getColumnHandles(phaseSession, table);
            PlanNodeIdAllocator ids = new PlanNodeIdAllocator();
            SymbolAllocator allocator = new SymbolAllocator(ImmutableList.of());
            ImmutableList.Builder<PlanNode> sources = ImmutableList.builder();
            for (int branch = 0; branch < parameters.branches(); branch++) {
                List<Symbol> outputs = newSymbols(allocator, parameters.columns());
                ImmutableMap.Builder<Symbol, ColumnHandle> assignments = ImmutableMap.builder();
                for (int column = 0; column < outputs.size(); column++) {
                    assignments.put(outputs.get(column), handles.get("c" + column));
                }
                PlanNode source = new TableScanNode(ids.getNextId(), table, outputs, assignments.buildOrThrow(), TupleDomain.all(), Optional.empty(), false, Optional.empty());
                if (parameters.enforced()) {
                    source = new FilterNode(ids.getNextId(), source, predicate(outputs, parameters.predicates()));
                }
                sources.add(source);
            }
            List<PlanNode> branches = sources.build();
            PlanNode root = branches.getFirst();
            if (branches.size() > 1) {
                List<Symbol> outputs = newSymbols(allocator, parameters.columns());
                ImmutableListMultimap.Builder<Symbol, Symbol> mapping = ImmutableListMultimap.builder();
                for (int column = 0; column < outputs.size(); column++) {
                    for (PlanNode branch : branches) {
                        mapping.put(outputs.get(column), branch.getOutputSymbols().get(column));
                    }
                }
                root = new UnionNode(ids.getNextId(), branches, mapping.build(), outputs);
            }
            for (int depth = 0; depth < parameters.depth(); depth++) {
                List<Symbol> outputs = newSymbols(allocator, parameters.columns());
                Assignments.Builder assignments = Assignments.builder();
                for (int column = 0; column < outputs.size(); column++) {
                    assignments.put(outputs.get(column), root.getOutputSymbols().get(column).toSymbolReference());
                }
                root = new ProjectNode(ids.getNextId(), root, assignments.build());
            }
            if (parameters.predicates() > 0) {
                root = new FilterNode(ids.getNextId(), root, predicate(root.getOutputSymbols(), parameters.predicates()));
            }
            nextNodeId = Integer.parseInt(ids.getNextId().toString());
            return root;
        }

        PlanNode optimize(PlanOptimizer optimizer, PlanOptimizersStatsCollector collector)
        {
            return optimizer.optimize(input, new PlanOptimizer.Context(
                    phaseSession,
                    new SymbolAllocator(symbols),
                    new PlanNodeIdAllocator(nextNodeId),
                    NOOP,
                    collector,
                    new CachingTableStatsProvider(planTester.getPlannerContext().getMetadata(), phaseSession, () -> false),
                    RuntimeInfoProvider.noImplementation()));
        }

        @TearDown
        public void tearDown()
                throws Exception
        {
            try {
                if (phaseSession != null) {
                    planTester.getPlannerContext().getMetadata().cleanupQuery(phaseSession);
                    planTester.getTransactionManager().asyncAbort(phaseSession.getRequiredTransactionId()).get();
                }
            }
            finally {
                if (planTester != null) {
                    planTester.close();
                }
            }
        }
    }

    @Benchmark
    public PlanNode optimizeRelational(BenchmarkData data)
    {
        return data.optimize(data.relational, createPlanOptimizersStatsCollector());
    }

    @Benchmark
    public PlanNode optimizeCombined(BenchmarkData data)
    {
        return data.optimize(data.combined, createPlanOptimizersStatsCollector());
    }

    @Benchmark
    public Plan planSql(BenchmarkData data)
    {
        return data.planTester.inTransaction(session -> data.planTester.createPlan(
                session, data.sql, data.optimizers, OPTIMIZED, NOOP, createPlanOptimizersStatsCollector()));
    }

    @Benchmark
    public Plan createSql(BenchmarkData data)
    {
        return data.planTester.inTransaction(session -> data.planTester.createPlan(
                session, data.sql, data.optimizers, CREATED, NOOP, createPlanOptimizersStatsCollector()));
    }

    record Workload(int schemaColumns, int columns, int branches, int predicates, int depth, boolean enforced)
    {
        Workload
        {
            checkArgument(columns > 0 && schemaColumns >= columns && branches > 0 && depth >= 0, "Invalid plan dimensions");
            checkArgument(predicates >= 0 && predicates <= columns, "Invalid predicate width");
        }

        static Workload parse(String name)
        {
            String[] parts = name.split("_");
            int size = Integer.parseInt(parts[1]);
            return switch (parts[0]) {
                case "WIDE" -> new Workload(size, size, 1, parts.length > 2 ? Integer.parseInt(parts[2]) : 1, 0, false);
                case "NARROW" -> new Workload(size, 1, 1, 1, 0, false);
                case "UNION", "ENFORCED" -> new Workload(Integer.parseInt(parts[2]), Integer.parseInt(parts[2]), size, Integer.parseInt(parts[3]), 0, parts[0].equals("ENFORCED"));
                case "PROJECT" -> new Workload(Integer.parseInt(parts[2]), Integer.parseInt(parts[2]), 1, Integer.parseInt(parts[3]), size, false);
                default -> throw new IllegalArgumentException("Unknown workload: " + name);
            };
        }

        String sql()
        {
            String outputs = IntStream.range(0, columns).mapToObj(i -> "c" + i).collect(joining(", "));
            String filter = predicates == 0 ? "" : " WHERE " + IntStream.range(0, predicates)
                                                               .mapToObj(i -> "c" + i + " BETWEEN 10 AND 100")
                                                               .collect(joining(" AND "));
            String branch = "SELECT " + outputs + " FROM bench.default.t" + (enforced ? filter : "");
            String source = String.join(" UNION ALL ", Collections.nCopies(branches, branch));
            for (int level = 0; level < depth; level++) {
                source = "SELECT " + outputs + " FROM (" + source + ") p";
            }
            return "SELECT " + outputs + " FROM (" + source + ") u" + filter;
        }
    }

    record Shape(int nodes, int scans, long scanColumns, long symbolSlots, int maxWidth, int unions, int maxFanout, int projects, int filters)
    {
        static Shape of(PlanNode root)
        {
            int nodes = 0;
            int scans = 0;
            long scanColumns = 0;
            long symbolSlots = 0;
            int maxWidth = 0;
            int unions = 0;
            int maxFanout = 0;
            int projects = 0;
            int filters = 0;
            ArrayDeque<PlanNode> pending = new ArrayDeque<>();
            pending.add(root);
            while (!pending.isEmpty()) {
                PlanNode node = pending.removeLast();
                nodes++;
                symbolSlots += node.getOutputSymbols().size();
                maxWidth = Math.max(maxWidth, node.getOutputSymbols().size());
                if (node instanceof TableScanNode) {
                    scans++;
                    scanColumns += node.getOutputSymbols().size();
                }
                if (node instanceof UnionNode) {
                    unions++;
                    maxFanout = Math.max(maxFanout, node.getSources().size());
                }
                if (node instanceof ProjectNode) {
                    projects++;
                }
                if (node instanceof FilterNode) {
                    filters++;
                }
                pending.addAll(node.getSources());
            }
            return new Shape(nodes, scans, scanColumns, symbolSlots, maxWidth, unions, maxFanout, projects, filters);
        }
    }

    private static List<Symbol> newSymbols(SymbolAllocator allocator, int columns)
    {
        return IntStream.range(0, columns).mapToObj(i -> allocator.newSymbol("c" + i, BIGINT)).collect(toImmutableList());
    }

    private static Expression predicate(List<Symbol> outputs, int columns)
    {
        return and(IntStream.range(0, columns)
                .mapToObj(i -> and(
                        comparison(GREATER_THAN_OR_EQUAL, outputs.get(i).toSymbolReference(), new Constant(BIGINT, 10L)),
                        comparison(LESS_THAN_OR_EQUAL, outputs.get(i).toSymbolReference(), new Constant(BIGINT, 100L))))
                .collect(toImmutableList()));
    }

    private static List<List<?>> testRows(int columns)
    {
        ImmutableList.Builder<List<?>> rows = ImmutableList.builder();
        for (long value : new long[] {0, 5, 10, 11, 100, 101, 11}) {
            rows.add(IntStream.range(0, columns).mapToObj(column -> value + column).collect(toImmutableList()));
        }
        return rows.build();
    }

    public static void main(String[] args)
            throws Exception
    {
        if (args.length > 0 && args[0].equals("--diagnose")) {
            BenchmarkData data = new BenchmarkData();
            data.workload = args[1];
            data.iterative = Boolean.parseBoolean(args[2]);
            try {
                data.setup();
                System.out.println("INPUT %s iterative=%s sqlChars=%s %s".formatted(data.workload, data.iterative, data.sql.length(), Shape.of(data.input)));
                PlanOptimizersStatsCollector collector = createPlanOptimizersStatsCollector();
                long start = System.nanoTime();
                PlanNode result = switch (args[3]) {
                    case "optimizeRelational" -> data.optimize(data.relational, collector);
                    case "optimizeCombined" -> data.optimize(data.combined, collector);
                    case "planSql" -> {
                        List<PlanOptimizer> diagnosticOptimizers = data.optimizers.stream()
                                .<PlanOptimizer>map(optimizer -> (plan, context) -> {
                                    if (optimizer == data.relational || optimizer == data.combined) {
                                        System.out.println("SQL_PHASE_INPUT %s %s".formatted(((IterativeOptimizer) optimizer).getName(), Shape.of(plan)));
                                    }
                                    return optimizer.optimize(plan, context);
                                })
                                .collect(toImmutableList());
                        yield data.planTester.inTransaction(session -> data.planTester.createPlan(
                                session, data.sql, diagnosticOptimizers, OPTIMIZED, NOOP, collector)).getRoot();
                    }
                    case "createSql" -> new BenchmarkPredicatePushdown().createSql(data).getRoot();
                    default -> throw new IllegalArgumentException("Unknown boundary: " + args[3]);
                };
                long elapsed = System.nanoTime() - start;
                System.out.println("OUTPUT %s elapsedMs=%.3f %s".formatted(args[3], elapsed / 1_000_000.0, Shape.of(result)));
                collector.getTopRuleStats().forEach(stat -> System.out.println("RULE " + stat));
            }
            finally {
                data.tearDown();
            }
            return;
        }
        CommandLineOptions options = new CommandLineOptions(args);
        OptionsBuilder builder = new OptionsBuilder();
        builder.parent(options);
        if (options.getIncludes().isEmpty()) {
            builder.include(BenchmarkPredicatePushdown.class.getSimpleName());
        }
        new Runner(builder.build()).run();
    }
}
