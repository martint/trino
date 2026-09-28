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

import io.trino.sql.planner.BenchmarkPredicatePushdown.BenchmarkData;
import io.trino.sql.planner.BenchmarkPredicatePushdown.Shape;
import io.trino.sql.planner.plan.PlanNode;
import io.trino.testing.PlanTester.MaterializedResultOutput;
import org.junit.jupiter.params.ParameterizedTest;
import org.junit.jupiter.params.provider.ValueSource;

import java.util.Arrays;
import java.util.List;
import java.util.stream.IntStream;

import static com.google.common.collect.ImmutableList.toImmutableList;
import static io.trino.execution.querystats.PlanOptimizersStatsCollector.createPlanOptimizersStatsCollector;
import static io.trino.execution.warnings.WarningCollector.NOOP;
import static io.trino.sql.planner.LogicalPlanner.Stage.OPTIMIZED_AND_VALIDATED;
import static java.util.stream.Collectors.joining;
import static org.assertj.core.api.Assertions.assertThat;

class TestBenchmarkPredicatePushdown
{
    @ParameterizedTest
    @ValueSource(booleans = {false, true})
    void testFixturesAndResults(boolean iterative)
            throws Exception
    {
        for (String workload : List.of("WIDE_16", "NARROW_64", "UNION_3_4_2", "ENFORCED_3_4_2", "PROJECT_4_4_2", "UNION_3_4_0")) {
            BenchmarkData data = new BenchmarkData();
            data.workload = workload;
            data.iterative = iterative;
            try {
                data.setup();
                Shape original = Shape.of(data.input);
                for (var optimizer : List.of(data.relational, data.combined)) {
                    PlanNode result = data.optimize(optimizer, createPlanOptimizersStatsCollector());
                    assertThat(result.getOutputSymbols()).isEqualTo(data.input.getOutputSymbols());
                    Shape shape = Shape.of(result);
                    assertThat(shape.scans()).isEqualTo(data.parameters.branches());
                    assertThat(shape.scanColumns()).isEqualTo((long) data.parameters.branches() * data.parameters.columns());
                    assertThat(shape.filters()).isEqualTo(data.parameters.predicates() == 0 ? 0 : data.parameters.branches());
                    assertThat(Shape.of(data.input)).isEqualTo(original);
                    assertThat(Shape.of(data.optimize(optimizer, createPlanOptimizersStatsCollector()))).isEqualTo(shape);
                }

                // MockConnector's row adapter rejects null cells. Introduce NULLs
                // through a projection while retaining executable table scans.
                String nullableTable = "(SELECT " + IntStream.range(0, data.parameters.schemaColumns())
                        .mapToObj(i -> "NULLIF(c" + i + ", " + i + ") AS c" + i)
                        .collect(joining(", ")) + " FROM bench.default.t) fixture";
                String sql = data.sql.replace("bench.default.t", nullableTable);
                var result = data.planTester.executePlan(
                        session -> data.planTester.createPlan(session, sql, data.optimizers, OPTIMIZED_AND_VALIDATED, NOOP, createPlanOptimizersStatsCollector()),
                        new MaterializedResultOutput());
                List<Long> values = Arrays.asList(null, 5L, 10L, 11L, 100L, 101L, 11L).stream()
                        .filter(value -> data.parameters.predicates() == 0 || (value != null && value >= 10 && value + data.parameters.predicates() - 1 <= 100))
                        .toList();
                List<List<Object>> expected = IntStream.range(0, data.parameters.branches())
                        .boxed()
                        .flatMap(_ -> values.stream().map(value -> IntStream.range(0, data.parameters.columns())
                                .<Object>mapToObj(column -> value == null ? null : value + column)
                                .toList()))
                        .collect(toImmutableList());
                assertThat(result.getMaterializedRows().stream().map(row -> row.getFields()).toList())
                        .containsExactlyInAnyOrderElementsOf(expected);
            }
            finally {
                data.tearDown();
            }
        }
    }
}
