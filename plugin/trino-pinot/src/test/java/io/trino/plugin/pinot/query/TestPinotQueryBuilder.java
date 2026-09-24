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
package io.trino.plugin.pinot.query;

import io.trino.metadata.TestingFunctionResolution;
import io.trino.plugin.pinot.PinotColumnHandle;
import io.trino.spi.connector.ColumnHandle;
import io.trino.spi.predicate.Domain;
import io.trino.spi.predicate.TupleDomain;
import io.trino.spi.type.Type;
import io.trino.sql.ir.Constant;
import io.trino.sql.ir.Expression;
import io.trino.sql.planner.DomainTranslator;
import io.trino.sql.planner.Symbol;
import org.junit.jupiter.api.Test;

import java.util.List;
import java.util.Optional;

import static io.trino.SessionTestUtils.TEST_SESSION;
import static io.trino.plugin.pinot.query.PinotQueryBuilder.getFilterClause;
import static io.trino.spi.type.DoubleType.DOUBLE;
import static io.trino.spi.type.RealType.REAL;
import static io.trino.sql.ir.Booleans.TRUE;
import static io.trino.sql.ir.ComparisonOperator.GREATER_THAN;
import static io.trino.sql.ir.ComparisonOperator.LESS_THAN;
import static io.trino.sql.ir.IrUtils.or;
import static io.trino.sql.ir.TestingIr.comparison;
import static org.assertj.core.api.Assertions.assertThat;

class TestPinotQueryBuilder
{
    @Test
    void testFloatingPointComplementContainingNaN()
    {
        TestingFunctionResolution functions = new TestingFunctionResolution();
        for (Type type : List.of(DOUBLE, REAL)) {
            Symbol symbol = new Symbol(type, "x");
            Constant zero = type.equals(DOUBLE) ? new Constant(type, 0.0) : new Constant(type, 0L);
            Expression predicate = or(
                    comparison(LESS_THAN, symbol.toSymbolReference(), zero),
                    comparison(GREATER_THAN, symbol.toSymbolReference(), zero));
            DomainTranslator.ExtractionResult extraction = DomainTranslator.getExtractionResult(functions.getPlannerContext(), TEST_SESSION, predicate);
            assertThat(extraction.remainingExpression()).isEqualTo(TRUE);
            Domain domain = extraction.tupleDomain().getDomains().orElseThrow().get(symbol);
            assertThat(domain.getValues().complement().isDiscreteSet()).isTrue();
            TupleDomain<ColumnHandle> constraint = extraction.tupleDomain().transformKeys(column -> new PinotColumnHandle(column.name(), column.type()));
            assertThat(getFilterClause(constraint, Optional.empty(), false))
                    .contains("((\"x\" < '0.0') OR (\"x\" > '0.0'))");
        }
    }
}
