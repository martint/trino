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

import com.google.common.collect.ImmutableMap;
import io.trino.metadata.Metadata;
import io.trino.metadata.QualifiedObjectName;
import io.trino.metadata.TableHandle;
import io.trino.spi.connector.ColumnHandle;
import io.trino.spi.connector.Constraint;
import io.trino.spi.connector.ConstraintApplicationResult;
import io.trino.spi.connector.LimitApplicationResult;
import io.trino.spi.predicate.Domain;
import io.trino.spi.predicate.TupleDomain;
import io.trino.spi.statistics.TableStatistics;
import io.trino.spi.type.Type;
import io.trino.testing.QueryRunner;
import org.junit.jupiter.api.AfterAll;
import org.junit.jupiter.api.BeforeAll;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.TestInstance;

import java.util.Optional;

import static io.airlift.slice.Slices.utf8Slice;
import static org.assertj.core.api.Assertions.assertThat;
import static org.junit.jupiter.api.TestInstance.Lifecycle.PER_CLASS;

/**
 * Prototype of a direct-SPI conformance suite. Instead of asserting SQL results, it calls
 * {@link io.trino.spi.connector.ConnectorMetadata} pushdown and statistics methods directly
 * (through the engine {@link Metadata} facade, which delegates straight to the connector) and
 * asserts the SPI contracts that query-level tests cannot reach.
 *
 * <p>The headline case is the {@code applyXxx} <em>idempotency</em> contract: the SPI Javadoc
 * states a connector "must return {@code Optional.empty()} if calling this method has no effect,
 * even if the connector generally supports pushdown" — otherwise the optimizer can loop
 * indefinitely. Plan-shape tests cannot observe this; a direct second call can.
 *
 * <p>This is a memory-connector proof of concept. The intended productionized form is a
 * behavior-gated {@code BaseConnectorSpiConformanceTest} that every connector extends, mapping
 * each {@link io.trino.testing.TestingConnectorBehavior} flag to the SPI method(s) it implies.
 */
@TestInstance(PER_CLASS)
public class TestMemoryConnectorSpiConformance
{
    private static final String TABLE_NAME = "test_spi_conformance";

    private QueryRunner queryRunner;

    @BeforeAll
    public void setUp()
            throws Exception
    {
        queryRunner = MemoryQueryRunner.builder().build();
        queryRunner.execute("CREATE TABLE " + TABLE_NAME + " AS SELECT * FROM (VALUES 1, 2, 3, 4, 5) t(x)");
    }

    @AfterAll
    public void tearDown()
    {
        if (queryRunner != null) {
            queryRunner.close();
            queryRunner = null;
        }
    }

    @Test
    public void testApplyLimitPushdownAndIdempotency()
    {
        queryRunner.inTransaction(queryRunner.getDefaultSession(), session -> {
            Metadata metadata = queryRunner.getPlannerContext().getMetadata();
            TableHandle table = metadata.getTableHandle(session, tableName()).orElseThrow();

            // first application pushes the limit into the connector
            Optional<LimitApplicationResult<TableHandle>> first = metadata.applyLimit(session, table, 10);
            assertThat(first).isPresent();
            assertThat(first.get().isLimitGuaranteed()).isTrue();
            assertThat(first.get().isPrecalculateStatistics()).isTrue();

            // re-applying the same limit to the already-limited handle MUST return empty;
            // otherwise the optimizer would re-trigger the rule forever (the critical SPI contract)
            assertThat(metadata.applyLimit(session, first.get().getHandle(), 10)).isEmpty();

            // a strictly tighter limit can still be pushed
            assertThat(metadata.applyLimit(session, first.get().getHandle(), 5)).isPresent();
            return null;
        });
    }

    @Test
    public void testApplyFilterPushdownAndIdempotency()
    {
        // The memory connector does not implement applyFilter; exercise the bundled tpch catalog, whose
        // ConnectorMetadata pushes an orderstatus predicate on the orders table.
        QualifiedObjectName orders = new QualifiedObjectName("tpch", "tiny", "orders");
        queryRunner.inTransaction(queryRunner.getDefaultSession(), session -> {
            Metadata metadata = queryRunner.getPlannerContext().getMetadata();
            TableHandle table = metadata.getTableHandle(session, orders).orElseThrow();
            ColumnHandle orderStatus = metadata.getColumnHandles(session, table).get("orderstatus");
            Type orderStatusType = metadata.getColumnMetadata(session, table, orderStatus).getType();
            Constraint constraint = new Constraint(TupleDomain.withColumnDomains(
                    ImmutableMap.of(orderStatus, Domain.singleValue(orderStatusType, utf8Slice("O")))));

            // first application pushes the predicate into the connector
            Optional<ConstraintApplicationResult<TableHandle>> first = metadata.applyFilter(session, table, constraint);
            assertThat(first).isPresent();

            // re-applying the same constraint to the returned handle MUST return empty;
            // otherwise the optimizer would re-trigger the rule forever (the critical SPI contract)
            assertThat(metadata.applyFilter(session, first.get().getHandle(), constraint)).isEmpty();
            return null;
        });
    }

    @Test
    public void testGetTableStatisticsRowCount()
    {
        queryRunner.inTransaction(queryRunner.getDefaultSession(), session -> {
            Metadata metadata = queryRunner.getPlannerContext().getMetadata();
            TableHandle table = metadata.getTableHandle(session, tableName()).orElseThrow();

            TableStatistics statistics = metadata.getTableStatistics(session, table);
            assertThat(statistics.getRowCount().isUnknown()).isFalse();
            assertThat(statistics.getRowCount().getValue()).isEqualTo(5.0);
            return null;
        });
    }

    private QualifiedObjectName tableName()
    {
        return new QualifiedObjectName(
                queryRunner.getDefaultSession().getCatalog().orElseThrow(),
                queryRunner.getDefaultSession().getSchema().orElseThrow(),
                TABLE_NAME);
    }
}
