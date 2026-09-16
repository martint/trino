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
package io.trino.plugin.memory;

import com.google.inject.Scopes;
import io.trino.Session;
import io.trino.execution.FailureInjector;
import io.trino.execution.TestingFailureInjectionConfig;
import io.trino.execution.TestingFailureInjector;
import io.trino.testing.AbstractTestQueryFramework;
import io.trino.testing.QueryRunner;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.Timeout;

import java.util.List;

import static com.google.inject.multibindings.OptionalBinder.newOptionalBinder;
import static io.airlift.configuration.ConfigBinder.configBinder;
import static io.trino.SystemSessionProperties.FILTERING_SEMI_JOIN_TO_INNER;
import static java.lang.Runtime.getRuntime;
import static org.assertj.core.api.Assertions.assertThat;

public class TestQueryExecutionWithoutDynamicFiltering
        extends AbstractTestQueryFramework
{
    @Override
    protected QueryRunner createQueryRunner()
            throws Exception
    {
        long memoryPoolSize = 2100L * 1024 * 1024;
        return MemoryQueryRunner.builder()
                .setWorkerCount(3)
                .addExtraProperty("query.max-memory-per-node", "100MB")
                .addExtraProperty("memory.heap-headroom-per-node", (getRuntime().maxMemory() - memoryPoolSize) + "B")
                .addExtraProperty("fault-tolerant-execution-task-memory", "1GB")
                .addExtraProperty("retry-initial-delay", "10ms")
                .addExtraProperty("retry-max-delay", "10ms")
                .setAdditionalModule(binder -> {
                    configBinder(binder).bindConfig(TestingFailureInjectionConfig.class);
                    newOptionalBinder(binder, FailureInjector.class).setBinding().to(TestingFailureInjector.class).in(Scopes.SINGLETON);
                })
                .withExchange("filesystem")
                .build();
    }

    private Session session(boolean filtering, String retry)
    {
        return Session.builder(getSession())
                .setSystemProperty("enable_dynamic_filtering", Boolean.toString(filtering))
                .setSystemProperty("join_reordering_strategy", "NONE")
                .setSystemProperty("join_distribution_type", "PARTITIONED")
                .setSystemProperty("retry_policy", retry)
                .build();
    }

    @Test
    @Timeout(120)
    void testJoinsWithoutDynamicFiltering()
    {
        assertUpdate("CREATE TABLE mode_probe AS SELECT * FROM (VALUES 11, 22, 33, NULL) t(k)", 4);
        assertUpdate("CREATE TABLE mode_build AS SELECT * FROM (VALUES 11, 33) t(k)", 2);
        for (String retry : List.of("NONE", "TASK")) {
            for (String distribution : List.of("PARTITIONED", "BROADCAST")) {
                Session session = Session.builder(session(true, retry))
                        .setSystemProperty("join_distribution_type", distribution)
                        .setSystemProperty(FILTERING_SEMI_JOIN_TO_INNER, "false")
                        .build();
                for (String sql : List.of(
                        "SELECT p.k FROM mode_probe p JOIN mode_build b ON p.k = b.k",
                        "SELECT k FROM mode_probe WHERE k IN (SELECT k FROM mode_build)")) {
                    var result = getDistributedQueryRunner().executeWithPlan(session, sql);
                    assertThat(result.result().getOnlyColumnAsSet()).containsExactlyInAnyOrder(11, 33);
                    var statistics = getDistributedQueryRunner().getCoordinator().getQueryManager()
                            .getFullQueryInfo(result.queryId()).getQueryStats().getDynamicFiltersStats();
                    assertThat(statistics.getTotalDynamicFilters()).isZero();
                    assertThat(statistics.getDynamicFiltersCompleted()).isEqualTo(statistics.getTotalDynamicFilters());
                    assertThat(statistics.getDynamicFilterDomainStats()).isEmpty();
                }
            }
        }
    }
}
