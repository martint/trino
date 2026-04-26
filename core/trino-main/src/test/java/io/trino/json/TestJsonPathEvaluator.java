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
package io.trino.json;

import com.google.common.collect.ImmutableList;
import com.google.common.collect.ImmutableMap;
import io.trino.json.ir.IrJsonPath;
import io.trino.json.ir.IrPathNode;
import io.trino.json.ir.IrPredicate;
import io.trino.spi.type.DecimalType;
import io.trino.spi.type.Int128;
import io.trino.spi.type.LongTimestamp;
import io.trino.spi.type.NumberType;
import io.trino.spi.type.TrinoNumber;
import io.trino.spi.type.TypeSignature;
import io.trino.sql.planner.PathNodes;
import org.assertj.core.api.AssertProvider;
import org.assertj.core.api.RecursiveComparisonAssert;
import org.assertj.core.api.recursive.comparison.RecursiveComparisonConfiguration;
import org.junit.jupiter.api.Test;

import java.math.BigDecimal;
import java.util.List;
import java.util.Map;

import static io.airlift.slice.Slices.utf8Slice;
import static io.trino.json.JsonEmptySequence.EMPTY_SEQUENCE;
import static io.trino.metadata.FunctionManager.createTestingFunctionManager;
import static io.trino.metadata.TestingMetadataManager.createTestingMetadataManager;
import static io.trino.spi.type.BigintType.BIGINT;
import static io.trino.spi.type.BooleanType.BOOLEAN;
import static io.trino.spi.type.CharType.createCharType;
import static io.trino.spi.type.DateType.DATE;
import static io.trino.spi.type.DecimalType.createDecimalType;
import static io.trino.spi.type.Decimals.MAX_PRECISION;
import static io.trino.spi.type.Decimals.encodeScaledValue;
import static io.trino.spi.type.Decimals.encodeShortScaledValue;
import static io.trino.spi.type.DoubleType.DOUBLE;
import static io.trino.spi.type.IntegerType.INTEGER;
import static io.trino.spi.type.SmallintType.SMALLINT;
import static io.trino.spi.type.TimestampType.createTimestampType;
import static io.trino.spi.type.TinyintType.TINYINT;
import static io.trino.spi.type.VarcharType.VARCHAR;
import static io.trino.spi.type.VarcharType.createVarcharType;
import static io.trino.sql.planner.PathNodes.abs;
import static io.trino.sql.planner.PathNodes.add;
import static io.trino.sql.planner.PathNodes.arrayAccessor;
import static io.trino.sql.planner.PathNodes.at;
import static io.trino.sql.planner.PathNodes.ceiling;
import static io.trino.sql.planner.PathNodes.conjunction;
import static io.trino.sql.planner.PathNodes.contextVariable;
import static io.trino.sql.planner.PathNodes.currentItem;
import static io.trino.sql.planner.PathNodes.descendantMemberAccessor;
import static io.trino.sql.planner.PathNodes.disjunction;
import static io.trino.sql.planner.PathNodes.divide;
import static io.trino.sql.planner.PathNodes.emptySequence;
import static io.trino.sql.planner.PathNodes.equal;
import static io.trino.sql.planner.PathNodes.exists;
import static io.trino.sql.planner.PathNodes.filter;
import static io.trino.sql.planner.PathNodes.floor;
import static io.trino.sql.planner.PathNodes.greaterThan;
import static io.trino.sql.planner.PathNodes.greaterThanOrEqual;
import static io.trino.sql.planner.PathNodes.isUnknown;
import static io.trino.sql.planner.PathNodes.jsonNull;
import static io.trino.sql.planner.PathNodes.keyValue;
import static io.trino.sql.planner.PathNodes.last;
import static io.trino.sql.planner.PathNodes.lessThan;
import static io.trino.sql.planner.PathNodes.lessThanOrEqual;
import static io.trino.sql.planner.PathNodes.likeRegex;
import static io.trino.sql.planner.PathNodes.literal;
import static io.trino.sql.planner.PathNodes.memberAccessor;
import static io.trino.sql.planner.PathNodes.minus;
import static io.trino.sql.planner.PathNodes.modulo;
import static io.trino.sql.planner.PathNodes.multiply;
import static io.trino.sql.planner.PathNodes.negation;
import static io.trino.sql.planner.PathNodes.notEqual;
import static io.trino.sql.planner.PathNodes.path;
import static io.trino.sql.planner.PathNodes.plus;
import static io.trino.sql.planner.PathNodes.range;
import static io.trino.sql.planner.PathNodes.sequence;
import static io.trino.sql.planner.PathNodes.singletonSequence;
import static io.trino.sql.planner.PathNodes.size;
import static io.trino.sql.planner.PathNodes.startsWith;
import static io.trino.sql.planner.PathNodes.subtract;
import static io.trino.sql.planner.PathNodes.toDouble;
import static io.trino.sql.planner.PathNodes.type;
import static io.trino.sql.planner.PathNodes.wildcardArrayAccessor;
import static io.trino.sql.planner.PathNodes.wildcardMemberAccessor;
import static io.trino.testing.TestingSession.testSessionBuilder;
import static java.lang.Boolean.FALSE;
import static java.lang.Boolean.TRUE;
import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;

public class TestJsonPathEvaluator
{
    private static final RecursiveComparisonConfiguration COMPARISON_CONFIGURATION = RecursiveComparisonConfiguration.builder().withStrictTypeChecking(true).build();

    private static final Map<String, Object> PARAMETERS = ImmutableMap.<String, Object>builder()
            .put("tinyint_parameter", new TypedValue(TINYINT, 1L))
            .put("bigint_parameter", new TypedValue(BIGINT, -2L))
            .put("short_decimal_parameter", new TypedValue(createDecimalType(3, 1), -123L))
            .put("long_decimal_parameter", new TypedValue(createDecimalType(30, 20), Int128.valueOf("100000000000000000000"))) // 1
            .put("double_parameter", new TypedValue(DOUBLE, 5e0))
            .put("string_parameter", new TypedValue(createCharType(5), utf8Slice("xyz")))
            .put("boolean_parameter", new TypedValue(BOOLEAN, true))
            .put("date_parameter", new TypedValue(DATE, 1234L))
            .put("timestamp_parameter", new TypedValue(createTimestampType(7), new LongTimestamp(20, 30)))
            .put("number_parameter", new TypedValue(NumberType.NUMBER, TrinoNumber.from(new BigDecimal("-123456789012345678901234567890.5"))))
            .put("number_nan_parameter", new TypedValue(NumberType.NUMBER, TrinoNumber.from(new TrinoNumber.NotANumber())))
            .put("number_neg_inf_parameter", new TypedValue(NumberType.NUMBER, TrinoNumber.from(new TrinoNumber.Infinity(true))))
            .put("empty_sequence_parameter", EMPTY_SEQUENCE)
            .put("null_parameter", JsonNull.JSON_NULL)
            .put("json_number_parameter", jsonParameter(integer(-6)))
            .put("json_text_parameter", jsonParameter(text("JSON text")))
            .put("json_boolean_parameter", jsonParameter(bool(false)))
            .put("json_array_parameter", jsonParameter(array(text("element"), dbl(7e0), JsonNull.JSON_NULL)))
            .put("json_object_parameter", jsonParameter(object(member("key1", text("bound_value")), member("key2", JsonNull.JSON_NULL))))
            .buildOrThrow();

    private static final List<String> PARAMETERS_ORDER = ImmutableList.copyOf(PARAMETERS.keySet());

    @Test
    public void testLiterals()
    {
        assertThat(pathResult(
                JsonNull.JSON_NULL,
                path(true, literal(BIGINT, 1L))))
                .isEqualTo(singletonSequence(new TypedValue(BIGINT, 1L)));

        assertThat(pathResult(
                JsonNull.JSON_NULL,
                path(true, literal(createVarcharType(5), utf8Slice("abc")))))
                .isEqualTo(singletonSequence(new TypedValue(createVarcharType(5), utf8Slice("abc"))));

        assertThat(pathResult(
                JsonNull.JSON_NULL,
                path(true, literal(BOOLEAN, false))))
                .isEqualTo(singletonSequence(new TypedValue(BOOLEAN, false)));

        assertThat(pathResult(
                JsonNull.JSON_NULL,
                path(true, literal(DATE, 1000L))))
                .isEqualTo(singletonSequence(new TypedValue(DATE, 1000L)));
    }

    @Test
    public void testNullLiteral()
    {
        assertThat(pathResult(
                array(),
                path(true, jsonNull())))
                .isEqualTo(singletonSequence(JsonNull.JSON_NULL));
    }

    @Test
    public void testContextVariable()
    {
        JsonValue input = array(bool(true), bool(false));
        assertThat(pathResult(
                input,
                path(true, contextVariable())))
                .isEqualTo(singletonSequence(input));
    }

    @Test
    public void testNamedVariable()
    {
        assertThat(pathResult(
                array(),
                path(true, variable("tinyint_parameter"))))
                .isEqualTo(singletonSequence(new TypedValue(TINYINT, 1L)));

        assertThat(pathResult(
                array(),
                path(true, variable("null_parameter"))))
                .isEqualTo(singletonSequence(JsonNull.JSON_NULL));

        // variables of type IrNamedValueVariable can only take SQL values or JSON null. other JSON objects are handled by IrNamedJsonVariable
        assertThatThrownBy(() -> evaluate(
                array(),
                path(true, variable("json_object_parameter"))))
                .isInstanceOf(IllegalStateException.class)
                .hasMessage("expected SQL value or JSON null, got non-null JSON");
    }

    @Test
    public void testNamedJsonVariable()
    {
        assertThat(pathResult(
                array(),
                path(true, jsonVariable("null_parameter"))))
                .isEqualTo(singletonSequence(JsonNull.JSON_NULL));

        assertThat(pathResult(
                array(),
                path(true, jsonVariable("json_object_parameter"))))
                .isEqualTo(singletonSequence(object(member("key1", text("bound_value")), member("key2", JsonNull.JSON_NULL))));

        // variables of type IrNamedJsonVariable can only take JSON objects. SQL values are handled by IrNamedValueVariable
        assertThatThrownBy(() -> evaluate(
                array(),
                path(true, jsonVariable("tinyint_parameter"))))
                .isInstanceOf(IllegalStateException.class)
                .hasMessage("expected JSON, got SQL value");
    }

    @Test
    public void testAbsMethod()
    {
        assertThat(pathResult(
                integer(-5),
                path(true, abs(contextVariable()))))
                .isEqualTo(singletonSequence(new TypedValue(INTEGER, 5L)));

        assertThat(pathResult(
                integer(-5),
                path(true, abs(variable("short_decimal_parameter")))))
                .isEqualTo(singletonSequence(new TypedValue(createDecimalType(3, 1), 123L)));

        assertThat(pathResult(
                integer(-5),
                path(true, abs(jsonVariable("json_number_parameter")))))
                .isEqualTo(singletonSequence(new TypedValue(INTEGER, 6L)));

        // multiple inputs
        assertThat(pathResult(
                array(dbl(-1e0), integer(2), smallint((short) -3)),
                path(true, abs(wildcardArrayAccessor(contextVariable())))))
                .isEqualTo(sequence(new TypedValue(DOUBLE, 1e0), new TypedValue(INTEGER, 2L), new TypedValue(SMALLINT, 3L)));

        // multiple inputs -- array is automatically unwrapped in lax mode
        assertThat(pathResult(
                array(dbl(-1e0), integer(2), smallint((short) -3)),
                path(true, abs(contextVariable()))))
                .isEqualTo(sequence(new TypedValue(DOUBLE, 1e0), new TypedValue(INTEGER, 2L), new TypedValue(SMALLINT, 3L)));

        // overflow
        assertThatThrownBy(() -> evaluate(
                integer(-5),
                path(true, abs(literal(TINYINT, -128L)))))
                .isInstanceOf(PathEvaluationException.class);

        // type mismatch
        assertThatThrownBy(() -> evaluate(
                integer(-5),
                path(true, abs(jsonVariable("null_parameter")))))
                .isInstanceOf(PathEvaluationException.class)
                .hasMessage("path evaluation failed: invalid item type. Expected: NUMBER, actual: NULL");
    }

    @Test
    public void testArithmeticBinary()
    {
        assertThat(pathResult(
                integer(-5),
                path(true, add(contextVariable(), variable("short_decimal_parameter")))))
                .isEqualTo(singletonSequence(new TypedValue(createDecimalType(12, 1), -173L)));

        assertThat(pathResult(
                integer(-5),
                path(true, subtract(literal(DOUBLE, 0e0), variable("short_decimal_parameter")))))
                .isEqualTo(singletonSequence(new TypedValue(DOUBLE, 12.3e0)));

        assertThat(pathResult(
                integer(-5),
                path(true, multiply(jsonVariable("json_number_parameter"), literal(BIGINT, 3L)))))
                .isEqualTo(singletonSequence(new TypedValue(BIGINT, -18L)));

        assertThat(pathResult(
                integer(-5),
                path(true, subtract(variable("short_decimal_parameter"), variable("long_decimal_parameter")))))
                .withEqualsForType(TypeSignature::equals, TypeSignature.class) // we don't want deep TypeSignature comparison because of cached hashCode
                .isEqualTo(singletonSequence(new TypedValue(createDecimalType(31, 20), Int128.valueOf("-1330000000000000000000"))));

        // division by 0
        assertThatThrownBy(() -> evaluate(
                integer(-5),
                path(true, divide(jsonVariable("json_number_parameter"), literal(BIGINT, 0L)))))
                .isInstanceOf(PathEvaluationException.class);

        // type mismatch
        assertThatThrownBy(() -> evaluate(
                integer(-5),
                path(true, modulo(jsonVariable("json_number_parameter"), literal(BOOLEAN, true)))))
                .isInstanceOf(PathEvaluationException.class)
                .hasMessage("path evaluation failed: invalid operand types to MODULO operator (integer, boolean)");

        // left operand is not singleton
        assertThatThrownBy(() -> evaluate(
                integer(-5),
                path(true, add(wildcardArrayAccessor(jsonVariable("json_array_parameter")), literal(BIGINT, 0L)))))
                .isInstanceOf(PathEvaluationException.class)
                .hasMessage("path evaluation failed: arithmetic binary expression requires singleton operands");

        // array is automatically unwrapped in lax mode
        assertThat(pathResult(
                array(integer(-5)),
                path(true, multiply(contextVariable(), literal(BIGINT, 3L)))))
                .isEqualTo(singletonSequence(new TypedValue(BIGINT, -15L)));
    }

    @Test
    public void testArithmeticUnary()
    {
        assertThat(pathResult(
                integer(-5),
                path(true, plus(contextVariable()))))
                .isEqualTo(singletonSequence(new TypedValue(INTEGER, -5L)));

        assertThat(pathResult(
                integer(-5),
                path(true, minus(variable("short_decimal_parameter")))))
                .isEqualTo(singletonSequence(new TypedValue(createDecimalType(3, 1), 123L)));

        assertThat(pathResult(
                integer(-5),
                path(true, plus(jsonVariable("json_number_parameter")))))
                .isEqualTo(singletonSequence(new TypedValue(INTEGER, -6L)));

        // multiple inputs
        assertThat(pathResult(
                array(dbl(-1e0), integer(2), smallint((short) -3)),
                path(true, minus(wildcardArrayAccessor(contextVariable())))))
                .isEqualTo(sequence(new TypedValue(DOUBLE, 1e0), new TypedValue(INTEGER, -2L), new TypedValue(SMALLINT, 3L)));

        // multiple inputs -- array is automatically unwrapped in lax mode
        assertThat(pathResult(
                array(dbl(-1e0), integer(2), smallint((short) -3)),
                path(true, minus(contextVariable()))))
                .isEqualTo(sequence(new TypedValue(DOUBLE, 1e0), new TypedValue(INTEGER, -2L), new TypedValue(SMALLINT, 3L)));

        // overflow
        assertThatThrownBy(() -> evaluate(
                integer(-5),
                path(true, minus(literal(TINYINT, -128L)))))
                .isInstanceOf(PathEvaluationException.class);

        // type mismatch
        assertThatThrownBy(() -> evaluate(
                integer(-5),
                path(true, plus(jsonVariable("null_parameter")))))
                .isInstanceOf(PathEvaluationException.class)
                .hasMessage("path evaluation failed: invalid item type. Expected: NUMBER, actual: NULL");
    }

    @Test
    public void testArrayAccessor()
    {
        // wildcard accessor
        assertThat(pathResult(
                array(dbl(-1e0), bool(true), text("some_text")),
                path(true, wildcardArrayAccessor(contextVariable()))))
                .isEqualTo(sequence(dbl(-1e0), bool(true), text("some_text")));

        assertThat(pathResult(
                integer(-5),
                path(true, wildcardArrayAccessor(jsonVariable("json_array_parameter")))))
                .isEqualTo(sequence(text("element"), dbl(7e0), JsonNull.JSON_NULL));

        // single element subscript
        assertThat(pathResult(
                integer(-5),
                path(true, arrayAccessor(jsonVariable("json_array_parameter"), at(literal(DOUBLE, 0e0))))))
                .isEqualTo(singletonSequence(text("element")));

        // range subscript
        assertThat(pathResult(
                integer(-5),
                path(true, arrayAccessor(jsonVariable("json_array_parameter"), range(literal(DOUBLE, 0e0), literal(INTEGER, 1L))))))
                .isEqualTo(sequence(text("element"), dbl(7e0)));

        // multiple overlapping subscripts
        assertThat(pathResult(
                array(text("first"), text("second"), text("third"), text("fourth"), text("fifth")),
                path(true, arrayAccessor(
                        contextVariable(),
                        range(literal(INTEGER, 3L), literal(INTEGER, 4L)),
                        range(literal(INTEGER, 1L), literal(INTEGER, 2L)),
                        at(literal(INTEGER, 0L))))))
                .isEqualTo(sequence(text("fourth"), text("fifth"), text("second"), text("third"), text("first")));

        // multiple input arrays
        assertThat(pathResult(
                array(
                                array(text("first"), text("second"), text("third")),
                                array(integer(1), integer(2), integer(3))),
                path(true, arrayAccessor(wildcardArrayAccessor(contextVariable()), range(literal(INTEGER, 1L), literal(INTEGER, 2L))))))
                .isEqualTo(sequence(text("second"), text("third"), integer(2), integer(3)));

        // usage of last variable
        assertThat(pathResult(
                integer(-5),
                path(true, arrayAccessor(jsonVariable("json_array_parameter"), range(literal(DOUBLE, 1e0), last())))))
                .isEqualTo(sequence(dbl(7e0), JsonNull.JSON_NULL));

        // incorrect usage of last variable: no enclosing array
        assertThatThrownBy(() -> evaluate(
                integer(-5),
                path(true, last())))
                .isInstanceOf(PathEvaluationException.class)
                .hasMessage("path evaluation failed: accessing the last array index with no enclosing array");

        // last variable in nested arrays
        assertThat(pathResult(
                array(
                                array(integer(2), integer(3), integer(5)),
                                integer(7)),
                path(true, multiply(
                        arrayAccessor(arrayAccessor(contextVariable(), at(literal(INTEGER, 0L))), at(last())), // 5
                        arrayAccessor(contextVariable(), at(last())))))) // 7
                .isEqualTo(singletonSequence(new TypedValue(INTEGER, 35L)));

        // subscript out of bounds (lax mode)
        assertThat(pathResult(
                array(text("first"), text("second"), text("third"), text("fourth"), text("fifth")),
                path(true, arrayAccessor(contextVariable(), at(literal(INTEGER, 100L))))))
                .isEqualTo(emptySequence());

        assertThat(pathResult(
                array(text("first"), text("second"), text("third"), text("fourth"), text("fifth")),
                path(true, arrayAccessor(contextVariable(), range(literal(INTEGER, 3L), literal(INTEGER, 100L))))))
                .isEqualTo(sequence(text("fourth"), text("fifth")));

        // incorrect subscript: from > to (lax mode)
        assertThat(pathResult(
                array(text("first"), text("second"), text("third"), text("fourth"), text("fifth")),
                path(true, arrayAccessor(contextVariable(), range(literal(INTEGER, 3L), literal(INTEGER, 2L))))))
                .isEqualTo(emptySequence());

        // subscript out of bounds (strict mode)
        assertThatThrownBy(() -> evaluate(
                array(text("first"), text("second"), text("third"), text("fourth"), text("fifth")),
                path(false, arrayAccessor(contextVariable(), at(literal(INTEGER, 100L))))))
                .isInstanceOf(PathEvaluationException.class)
                .hasMessage("path evaluation failed: structural error: invalid array subscript: [100, 100] for array of size 5");

        assertThatThrownBy(() -> evaluate(
                array(text("first"), text("second"), text("third"), text("fourth"), text("fifth")),
                path(false, arrayAccessor(contextVariable(), range(literal(INTEGER, 3L), literal(INTEGER, 100L))))))
                .isInstanceOf(PathEvaluationException.class)
                .hasMessage("path evaluation failed: structural error: invalid array subscript: [3, 100] for array of size 5");

        // incorrect subscript: from > to (strict mode)
        assertThatThrownBy(() -> evaluate(
                array(text("first"), text("second"), text("third"), text("fourth"), text("fifth")),
                path(false, arrayAccessor(contextVariable(), range(literal(INTEGER, 3L), literal(INTEGER, 2L))))))
                .isInstanceOf(PathEvaluationException.class)
                .hasMessage("path evaluation failed: structural error: invalid array subscript: [3, 2] for array of size 5");

        // type mismatch (lax mode) -> the value is wrapped in a singleton array
        assertThat(pathResult(
                integer(-5),
                path(true, arrayAccessor(contextVariable(), at(literal(INTEGER, 0L))))))
                .isEqualTo(singletonSequence(integer(-5)));

        // type mismatch (strict mode)
        assertThatThrownBy(() -> evaluate(
                integer(-5),
                path(false, arrayAccessor(contextVariable(), at(literal(INTEGER, 0L))))))
                .isInstanceOf(PathEvaluationException.class)
                .hasMessage("path evaluation failed: invalid item type. Expected: ARRAY, actual: NUMBER");
    }

    @Test
    public void testCeilingMethod()
    {
        assertThat(pathResult(
                integer(-5),
                path(true, ceiling(contextVariable()))))
                .isEqualTo(singletonSequence(new TypedValue(INTEGER, -5L)));

        assertThat(pathResult(
                integer(-5),
                path(true, ceiling(variable("short_decimal_parameter")))))
                .isEqualTo(singletonSequence(new TypedValue(createDecimalType(3, 0), -12L)));

        assertThat(pathResult(
                integer(-5),
                path(true, ceiling(jsonVariable("json_number_parameter")))))
                .isEqualTo(singletonSequence(new TypedValue(INTEGER, -6L)));

        // multiple inputs
        assertThat(pathResult(
                array(dbl(1.5e0), integer(2), decimal(BigDecimal.valueOf(-15, 1))),
                path(true, ceiling(wildcardArrayAccessor(contextVariable())))))
                .isEqualTo(sequence(new TypedValue(DOUBLE, 2e0), new TypedValue(INTEGER, 2L), new TypedValue(createDecimalType(2, 0), -1L)));

        // multiple inputs -- array is automatically unwrapped in lax mode
        assertThat(pathResult(
                array(dbl(1.5e0), integer(2), decimal(BigDecimal.valueOf(-15, 1))),
                path(true, ceiling(contextVariable()))))
                .isEqualTo(sequence(new TypedValue(DOUBLE, 2e0), new TypedValue(INTEGER, 2L), new TypedValue(createDecimalType(2, 0), -1L)));

        // type mismatch
        assertThatThrownBy(() -> evaluate(
                integer(-5),
                path(true, ceiling(jsonVariable("null_parameter")))))
                .isInstanceOf(PathEvaluationException.class)
                .hasMessage("path evaluation failed: invalid item type. Expected: NUMBER, actual: NULL");
    }

    @Test
    public void testDescendantMemberAccessor()
    {
        // non-structural value
        assertThat(pathResult(
                bool(true),
                path(true, descendantMemberAccessor(contextVariable(), "key1"))))
                .isEqualTo(emptySequence());

        // array
        assertThat(pathResult(
                array(bool(true), text("foo")),
                path(true, descendantMemberAccessor(contextVariable(), "key1"))))
                .isEqualTo(emptySequence());

        // object
        assertThat(pathResult(
                object(member("first", bool(true)), member("second", integer(42))),
                path(true, descendantMemberAccessor(contextVariable(), "second"))))
                .isEqualTo(singletonSequence(integer(42)));

        assertThat(pathResult(
                object(member("first", bool(true)), member("second", integer(42))),
                path(true, descendantMemberAccessor(contextVariable(), "third"))))
                .isEqualTo(emptySequence());

        // deep nesting array(object(array(object)))
        assertThat(pathResult(
                array(
                        bool(true),
                        object(member("key1", integer(42)),
                                                member("key2", array(
                                        JsonNull.JSON_NULL,
                                        object(member("key3", text("foo")),
                                                member("key1", bool(false))))))),
                path(true, descendantMemberAccessor(contextVariable(), "key1"))))
                .isEqualTo(sequence(
                        integer(42),
                        bool(false)));

        // preorder: member from top-level object first
        assertThat(pathResult(
                object(member("key1", object(member("key2", bool(false)))),
                                                member("key2", integer(42))),
                path(true, descendantMemberAccessor(contextVariable(), "key2"))))
                .isEqualTo(sequence(
                        integer(42),
                        bool(false)));

        // matching a structural value
        assertThat(pathResult(
                object(member("key1", object(member("key1", bool(false)))),
                                                member("key2", integer(42))),
                path(true, descendantMemberAccessor(contextVariable(), "key1"))))
                .isEqualTo(sequence(
                        object(member("key1", bool(false))),
                        bool(false)));

        // strict mode
        assertThat(pathResult(
                bool(true),
                path(false, descendantMemberAccessor(contextVariable(), "key1"))))
                .isEqualTo(emptySequence());
    }

    @Test
    public void testDoubleMethod()
    {
        assertThat(pathResult(
                integer(-5),
                path(true, toDouble(contextVariable()))))
                .isEqualTo(singletonSequence(new TypedValue(DOUBLE, -5e0)));

        assertThat(pathResult(
                integer(-5),
                path(true, toDouble(variable("short_decimal_parameter")))))
                .isEqualTo(singletonSequence(new TypedValue(DOUBLE, -12.3e0)));

        assertThat(pathResult(
                integer(-5),
                path(true, toDouble(jsonVariable("json_number_parameter")))))
                .isEqualTo(singletonSequence(new TypedValue(DOUBLE, -6e0)));

        assertThat(pathResult(
                text("123"),
                path(true, toDouble(contextVariable()))))
                .isEqualTo(singletonSequence(new TypedValue(DOUBLE, 123e0)));

        assertThat(pathResult(
                text("-12.3e5"),
                path(true, toDouble(contextVariable()))))
                .isEqualTo(singletonSequence(new TypedValue(DOUBLE, -12.3e5)));

        // multiple inputs
        assertThat(pathResult(
                array(dbl(1.5e0), integer(2), decimal(BigDecimal.valueOf(-15, 1))),
                path(true, toDouble(wildcardArrayAccessor(contextVariable())))))
                .isEqualTo(sequence(new TypedValue(DOUBLE, 1.5e0), new TypedValue(DOUBLE, 2e0), new TypedValue(DOUBLE, -1.5e0)));

        // multiple inputs -- array is automatically unwrapped in lax mode
        assertThat(pathResult(
                array(dbl(1.5e0), integer(2), decimal(BigDecimal.valueOf(-15, 1))),
                path(true, toDouble(contextVariable()))))
                .isEqualTo(sequence(new TypedValue(DOUBLE, 1.5e0), new TypedValue(DOUBLE, 2e0), new TypedValue(DOUBLE, -1.5e0)));

        // type mismatch
        assertThatThrownBy(() -> evaluate(
                integer(-5),
                path(true, toDouble(jsonVariable("null_parameter")))))
                .isInstanceOf(PathEvaluationException.class)
                .hasMessage("path evaluation failed: invalid item type. Expected: NUMBER or TEXT, actual: NULL");
    }

    @Test
    public void testFloorMethod()
    {
        assertThat(pathResult(
                integer(-5),
                path(true, floor(contextVariable()))))
                .isEqualTo(singletonSequence(new TypedValue(INTEGER, -5L)));

        assertThat(pathResult(
                integer(-5),
                path(true, floor(variable("short_decimal_parameter")))))
                .isEqualTo(singletonSequence(new TypedValue(createDecimalType(3, 0), -13L)));

        assertThat(pathResult(
                integer(-5),
                path(true, floor(jsonVariable("json_number_parameter")))))
                .isEqualTo(singletonSequence(new TypedValue(INTEGER, -6L)));

        // multiple inputs
        assertThat(pathResult(
                array(dbl(1.5e0), integer(2), decimal(BigDecimal.valueOf(-15, 1))),
                path(true, floor(wildcardArrayAccessor(contextVariable())))))
                .isEqualTo(sequence(new TypedValue(DOUBLE, 1e0), new TypedValue(INTEGER, 2L), new TypedValue(createDecimalType(2, 0), -2L)));

        // multiple inputs -- array is automatically unwrapped in lax mode
        assertThat(pathResult(
                array(dbl(1.5e0), integer(2), decimal(BigDecimal.valueOf(-15, 1))),
                path(true, floor(contextVariable()))))
                .isEqualTo(sequence(new TypedValue(DOUBLE, 1e0), new TypedValue(INTEGER, 2L), new TypedValue(createDecimalType(2, 0), -2L)));

        // type mismatch
        assertThatThrownBy(() -> evaluate(
                integer(-5),
                path(true, floor(jsonVariable("null_parameter")))))
                .isInstanceOf(PathEvaluationException.class)
                .hasMessage("path evaluation failed: invalid item type. Expected: NUMBER, actual: NULL");
    }

    @Test
    public void testNumericMethodsAcceptNumberType()
    {
        // abs() preserves NumberType and BigDecimal magnitude
        assertThat(pathResult(
                JsonNull.JSON_NULL,
                path(true, abs(variable("number_parameter")))))
                .isEqualTo(singletonSequence(new TypedValue(
                        NumberType.NUMBER,
                        TrinoNumber.from(new BigDecimal("123456789012345678901234567890.5")))));

        // ceiling() and floor() round to integer scale 0
        assertThat(pathResult(
                JsonNull.JSON_NULL,
                path(true, ceiling(variable("number_parameter")))))
                .isEqualTo(singletonSequence(new TypedValue(
                        NumberType.NUMBER,
                        TrinoNumber.from(new BigDecimal("-123456789012345678901234567890")))));

        assertThat(pathResult(
                JsonNull.JSON_NULL,
                path(true, floor(variable("number_parameter")))))
                .isEqualTo(singletonSequence(new TypedValue(
                        NumberType.NUMBER,
                        TrinoNumber.from(new BigDecimal("-123456789012345678901234567891")))));

        // double() converts NumberType to DOUBLE (mantissa rounds to nearest representable value)
        assertThat(pathResult(
                JsonNull.JSON_NULL,
                path(true, toDouble(variable("number_parameter")))))
                .isEqualTo(singletonSequence(new TypedValue(DOUBLE, new BigDecimal("-123456789012345678901234567890.5").doubleValue())));

        // abs() of NaN stays NaN; abs() of -Infinity becomes +Infinity
        assertThat(pathResult(
                JsonNull.JSON_NULL,
                path(true, abs(variable("number_nan_parameter")))))
                .isEqualTo(singletonSequence(new TypedValue(
                        NumberType.NUMBER,
                        TrinoNumber.from(new TrinoNumber.NotANumber()))));

        assertThat(pathResult(
                JsonNull.JSON_NULL,
                path(true, abs(variable("number_neg_inf_parameter")))))
                .isEqualTo(singletonSequence(new TypedValue(
                        NumberType.NUMBER,
                        TrinoNumber.from(new TrinoNumber.Infinity(false)))));

        // double() on non-finite NumberType maps to the matching DOUBLE non-finite value
        assertThat(pathResult(
                JsonNull.JSON_NULL,
                path(true, toDouble(variable("number_neg_inf_parameter")))))
                .isEqualTo(singletonSequence(new TypedValue(DOUBLE, Double.NEGATIVE_INFINITY)));
    }

    @Test
    public void testKeyValueMethod()
    {
        assertThat(pathResult(
                object(member("key1", text("bound_value")), member("key2", JsonNull.JSON_NULL)),
                path(true, keyValue(contextVariable()))))
                .isEqualTo(sequence(
                        object(member("name", text("key1")),
                                                member("value", text("bound_value")),
                                                member("id", integer(0))),
                        object(member("name", text("key2")),
                                                member("value", JsonNull.JSON_NULL),
                                                member("id", integer(0)))));

        assertThat(pathResult(
                integer(-5),
                path(true, keyValue(jsonVariable("json_object_parameter")))))
                .isEqualTo(sequence(
                        object(member("name", text("key1")),
                                                member("value", text("bound_value")),
                                                member("id", integer(0))),
                        object(member("name", text("key2")),
                                                member("value", JsonNull.JSON_NULL),
                                                member("id", integer(0)))));

        // multiple input objects
        assertThat(pathResult(
                array(
                                object(member("key1", text("first")), member("key2", bool(true))),
                                object(member("key3", integer(1)), member("key4", JsonNull.JSON_NULL))),
                path(true, keyValue(wildcardArrayAccessor(contextVariable())))))
                .isEqualTo(sequence(
                        object(member("name", text("key1")),
                                                member("value", text("first")),
                                                member("id", integer(0))),
                        object(member("name", text("key2")),
                                                member("value", bool(true)),
                                                member("id", integer(0))),
                        object(member("name", text("key3")),
                                                member("value", integer(1)),
                                                member("id", integer(1))),
                        object(member("name", text("key4")),
                                                member("value", JsonNull.JSON_NULL),
                                                member("id", integer(1)))));

        // multiple objects -- array is automatically unwrapped in lax mode
        assertThat(pathResult(
                array(
                                object(member("key1", text("first")), member("key2", bool(true))),
                                object(member("key3", integer(1)), member("key4", JsonNull.JSON_NULL))),
                path(true, keyValue(wildcardArrayAccessor(contextVariable())))))
                .isEqualTo(sequence(
                        object(member("name", text("key1")),
                                                member("value", text("first")),
                                                member("id", integer(0))),
                        object(member("name", text("key2")),
                                                member("value", bool(true)),
                                                member("id", integer(0))),
                        object(member("name", text("key3")),
                                                member("value", integer(1)),
                                                member("id", integer(1))),
                        object(member("name", text("key4")),
                                                member("value", JsonNull.JSON_NULL),
                                                member("id", integer(1)))));

        // nested methods
        assertThat(pathResult(
                array(
                                object(member("key1", text("first")), member("key2", bool(true))),
                                object(member("key3", integer(42)))),
                path(true, keyValue(keyValue(wildcardArrayAccessor(contextVariable()))))))
                .isEqualTo(sequence(
                        // key1
                        object(member("name", text("name")),
                                                member("value", text("key1")),
                                                member("id", integer(2))),
                        object(member("name", text("value")),
                                                member("value", text("first")),
                                                member("id", integer(2))),
                        object(member("name", text("id")),
                                                member("value", integer(0)),
                                                member("id", integer(2))),
                        // key2
                        object(member("name", text("name")),
                                                member("value", text("key2")),
                                                member("id", integer(3))),
                        object(member("name", text("value")),
                                                member("value", bool(true)),
                                                member("id", integer(3))),
                        object(member("name", text("id")),
                                                member("value", integer(0)),
                                                member("id", integer(3))),
                        // key3
                        object(member("name", text("name")),
                                                member("value", text("key3")),
                                                member("id", integer(4))),
                        object(member("name", text("value")),
                                                member("value", integer(42)),
                                                member("id", integer(4))),
                        object(member("name", text("id")),
                                                member("value", integer(1)),
                                                member("id", integer(4)))));

        // type mismatch
        assertThatThrownBy(() -> evaluate(
                integer(-5),
                path(true, keyValue(jsonVariable("null_parameter")))))
                .isInstanceOf(PathEvaluationException.class)
                .hasMessage("path evaluation failed: invalid item type. Expected: OBJECT, actual: NULL");
    }

    @Test
    public void testMemberAccessor()
    {
        // wildcard accessor
        assertThat(pathResult(
                object(member("key1", text("bound_value")), member("key2", JsonNull.JSON_NULL)),
                path(true, wildcardMemberAccessor(contextVariable()))))
                .isEqualTo(sequence(text("bound_value"), JsonNull.JSON_NULL));

        assertThat(pathResult(
                integer(-5),
                path(true, memberAccessor(jsonVariable("json_object_parameter"), "key1"))))
                .isEqualTo(singletonSequence(text("bound_value")));

        // multiple input objects
        assertThat(pathResult(
                array(
                                object(member("key1", text("first")), member("key2", bool(true))),
                                object(member("key1", integer(1)), member("key2", JsonNull.JSON_NULL))),
                path(true, memberAccessor(wildcardArrayAccessor(contextVariable()), "key2"))))
                .isEqualTo(sequence(bool(true), JsonNull.JSON_NULL));

        // multiple input objects -- array is automatically unwrapped in lax mode
        assertThat(pathResult(
                array(
                                object(member("key1", text("first")), member("key2", bool(true))),
                                object(member("key1", integer(1)), member("key2", JsonNull.JSON_NULL))),
                path(true, memberAccessor(contextVariable(), "key2"))))
                .isEqualTo(sequence(bool(true), JsonNull.JSON_NULL));

        // key not found -- structural error is suppressed in lax mode
        assertThat(pathResult(
                object(member("key1", text("bound_value")), member("key2", JsonNull.JSON_NULL)),
                path(true, memberAccessor(contextVariable(), "wrong_key"))))
                .isEqualTo(emptySequence());

        // key not found -- strict mode
        assertThatThrownBy(() -> evaluate(
                object(member("key1", text("bound_value")), member("key2", JsonNull.JSON_NULL)),
                path(false, memberAccessor(contextVariable(), "wrong_key"))))
                .isInstanceOf(PathEvaluationException.class)
                .hasMessage("path evaluation failed: structural error: missing member 'wrong_key' in JSON object");

        // multiple input objects, key not found in one of them -- lax mode
        assertThat(pathResult(
                array(
                                object(member("key1", text("first")), member("key2", bool(true))),
                                object(member("key3", integer(1)), member("key4", JsonNull.JSON_NULL))),
                path(true, memberAccessor(wildcardArrayAccessor(contextVariable()), "key2"))))
                .isEqualTo(singletonSequence(bool(true)));

        // multiple input objects, key not found in one of them -- strict mode
        assertThatThrownBy(() -> evaluate(
                array(
                                object(member("key1", text("first")), member("key2", bool(true))),
                                object(member("key3", integer(1)), member("key4", JsonNull.JSON_NULL))),
                path(false, memberAccessor(wildcardArrayAccessor(contextVariable()), "key2"))))
                .isInstanceOf(PathEvaluationException.class)
                .hasMessage("path evaluation failed: structural error: missing member 'key2' in JSON object");

        // type mismatch
        assertThatThrownBy(() -> evaluate(
                integer(-5),
                path(true, keyValue(jsonVariable("null_parameter")))))
                .isInstanceOf(PathEvaluationException.class)
                .hasMessage("path evaluation failed: invalid item type. Expected: OBJECT, actual: NULL");
    }

    @Test
    public void testSizeMethod()
    {
        assertThat(pathResult(
                integer(-5),
                path(true, size(contextVariable()))))
                .isEqualTo(singletonSequence(new TypedValue(INTEGER, 1L)));

        assertThat(pathResult(
                integer(-5),
                path(true, size(variable("short_decimal_parameter")))))
                .isEqualTo(singletonSequence(new TypedValue(INTEGER, 1L)));

        assertThat(pathResult(
                integer(-5),
                path(true, size(jsonVariable("json_boolean_parameter")))))
                .isEqualTo(singletonSequence(new TypedValue(INTEGER, 1L)));

        assertThat(pathResult(
                JsonNull.JSON_NULL,
                path(true, size(contextVariable()))))
                .isEqualTo(singletonSequence(new TypedValue(INTEGER, 1L)));

        assertThat(pathResult(
                integer(-5),
                path(true, size(jsonVariable("json_object_parameter")))))
                .isEqualTo(singletonSequence(new TypedValue(INTEGER, 1L)));

        assertThat(pathResult(
                integer(-5),
                path(true, size(jsonVariable("json_array_parameter")))))
                .isEqualTo(singletonSequence(new TypedValue(INTEGER, 3L)));

        // multiple inputs
        assertThat(pathResult(
                array(dbl(1.5e0), array(bool(true), bool(false))),
                path(true, size(wildcardArrayAccessor(contextVariable())))))
                .isEqualTo(sequence(new TypedValue(INTEGER, 1L), new TypedValue(INTEGER, 2L)));

        // type mismatch
        assertThatThrownBy(() -> evaluate(
                integer(-5),
                path(false, size(contextVariable()))))
                .isInstanceOf(PathEvaluationException.class)
                .hasMessage("path evaluation failed: invalid item type. Expected: ARRAY, actual: NUMBER");
    }

    @Test
    public void testTypeMethod()
    {
        assertThat(pathResult(
                integer(-5),
                path(true, type(contextVariable()))))
                .isEqualTo(singletonSequence(new TypedValue(createVarcharType(27), utf8Slice("number"))));

        assertThat(pathResult(
                integer(-5),
                path(true, type(variable("string_parameter")))))
                .isEqualTo(singletonSequence(new TypedValue(createVarcharType(27), utf8Slice("string"))));

        assertThat(pathResult(
                integer(-5),
                path(true, type(jsonVariable("json_boolean_parameter")))))
                .isEqualTo(singletonSequence(new TypedValue(createVarcharType(27), utf8Slice("boolean"))));

        assertThat(pathResult(
                integer(-5),
                path(true, type(jsonVariable("json_array_parameter")))))
                .isEqualTo(singletonSequence(new TypedValue(createVarcharType(27), utf8Slice("array"))));

        assertThat(pathResult(
                integer(-5),
                path(true, type(jsonVariable("json_object_parameter")))))
                .isEqualTo(singletonSequence(new TypedValue(createVarcharType(27), utf8Slice("object"))));

        assertThat(pathResult(
                JsonNull.JSON_NULL,
                path(true, type(contextVariable()))))
                .isEqualTo(singletonSequence(new TypedValue(createVarcharType(27), utf8Slice("null"))));

        assertThat(pathResult(
                integer(-5),
                path(true, type(variable("date_parameter")))))
                .isEqualTo(singletonSequence(new TypedValue(createVarcharType(27), utf8Slice("date"))));

        assertThat(pathResult(
                integer(-5),
                path(true, type(variable("timestamp_parameter")))))
                .isEqualTo(singletonSequence(new TypedValue(createVarcharType(27), utf8Slice("timestamp without time zone"))));

        // multiple inputs
        assertThat(pathResult(
                array(dbl(1.5e0), array(bool(true), bool(false))),
                path(true, type(wildcardArrayAccessor(contextVariable())))))
                .isEqualTo(sequence(new TypedValue(createVarcharType(27), utf8Slice("number")), new TypedValue(createVarcharType(27), utf8Slice("array"))));
    }

    // JSON PREDICATE
    @Test
    public void testComparisonPredicate()
    {
        assertThat(predicateResult(
                dbl(1e0),
                bigint(1L),
                true,
                equal(contextVariable(), currentItem())))
                .isEqualTo(TRUE);

        assertThat(predicateResult(
                dbl(1e0),
                bigint(1L),
                true,
                notEqual(jsonVariable("json_number_parameter"), variable("double_parameter"))))
                .isEqualTo(TRUE);

        assertThat(predicateResult(
                dbl(1e0),
                bigint(1L),
                true,
                lessThan(literal(BOOLEAN, true), literal(BOOLEAN, false))))
                .isEqualTo(FALSE);

        assertThat(predicateResult(
                dbl(1e0),
                bigint(1L),
                true,
                greaterThan(literal(VARCHAR, utf8Slice("xyz")), literal(VARCHAR, utf8Slice("abc")))))
                .isEqualTo(TRUE);

        assertThat(predicateResult(
                dbl(1e0),
                bigint(1L),
                true,
                lessThanOrEqual(literal(DATE, 0L), variable("date_parameter"))))
                .isEqualTo(TRUE);

        assertThat(predicateResult(
                dbl(1e0),
                bigint(1L),
                true,
                greaterThanOrEqual(literal(BIGINT, 1L), literal(BIGINT, 2L))))
                .isEqualTo(FALSE);

        // uncomparable items -> result unknown
        assertThat(predicateResult(
                dbl(1e0),
                text("abc"),
                false,
                lessThan(contextVariable(), currentItem())))
                .isEqualTo(null);

        // nulls can be compared with every item
        assertThat(predicateResult(
                dbl(1e0),
                bigint(1L),
                true,
                equal(jsonNull(), jsonNull())))
                .isEqualTo(TRUE);

        assertThat(predicateResult(
                dbl(1e0),
                bigint(1L),
                true,
                lessThan(jsonNull(), currentItem())))
                .isEqualTo(FALSE);

        assertThat(predicateResult(
                dbl(1e0),
                bigint(1L),
                true,
                notEqual(jsonNull(), jsonVariable("json_object_parameter"))))
                .isEqualTo(TRUE);

        // array / object can only be compared with null. otherwise the result is unknown
        assertThat(predicateResult(
                dbl(1e0),
                bigint(1L),
                true,
                notEqual(jsonVariable("json_object_parameter"), jsonVariable("json_object_parameter"))))
                .isEqualTo(null);

        assertThat(predicateResult(
                dbl(1e0),
                bigint(1L),
                true,
                notEqual(jsonVariable("json_array_parameter"), jsonVariable("json_object_parameter"))))
                .isEqualTo(null);

        // array is automatically unwrapped in lax mode
        assertThat(predicateResult(
                array(integer(1)),
                bigint(1L),
                true,
                equal(contextVariable(), literal(BIGINT, 1L))))
                .isEqualTo(TRUE);

        // array is not unwrapped in strict mode
        assertThat(predicateResult(
                array(integer(1)),
                bigint(1L),
                false,
                equal(contextVariable(), literal(BIGINT, 1L))))
                .isEqualTo(null);

        // multiple items - first success or failure in lax mode
        assertThat(predicateResult(
                array(integer(1), integer(2)),
                array(integer(3), bool(true)),
                true,
                lessThan(contextVariable(), currentItem())))
                .isEqualTo(TRUE);

        assertThat(predicateResult(
                array(bool(true), integer(2)),
                array(integer(3), integer(1)),
                true,
                lessThan(contextVariable(), currentItem())))
                .isEqualTo(null);

        // null based equal in lax mode
        assertThat(predicateResult(
                array(integer(1), JsonNull.JSON_NULL),
                array(integer(3), JsonNull.JSON_NULL),
                true,
                equal(contextVariable(), currentItem())))
                .isEqualTo(TRUE);

        // null based not equal in lax mode
        assertThat(predicateResult(
                array(integer(1), JsonNull.JSON_NULL),
                array(integer(3), bool(true)),
                true,
                notEqual(contextVariable(), currentItem())))
                .isEqualTo(TRUE);

        // multiple items - fail if any comparison returns error in strict mode
        assertThat(predicateResult(
                array(integer(1), integer(2)),
                array(integer(3), bool(true)),
                false,
                lessThan(contextVariable(), currentItem())))
                .isEqualTo(null);

        // error while evaluating nested path (floor method called on a text value) -> result unknown
        assertThat(predicateResult(
                dbl(1e0),
                text("abc"),
                true,
                lessThan(contextVariable(), floor(currentItem()))))
                .isEqualTo(null);

        // left operand returns empty sequence -> result false
        assertThat(predicateResult(
                array(integer(1), integer(2)),
                array(integer(3), integer(4)),
                true,
                lessThan(arrayAccessor(contextVariable(), at(literal(BIGINT, 100L))), currentItem())))
                .isEqualTo(false);

        // right operand returns empty sequence -> result false
        assertThat(predicateResult(
                array(integer(1), integer(2)),
                array(integer(3), integer(4)),
                true,
                lessThan(contextVariable(), arrayAccessor(currentItem(), at(literal(BIGINT, 100L))))))
                .isEqualTo(false);
    }

    @Test
    public void testConjunctionPredicate()
    {
        assertThat(predicateResult(
                dbl(1e0),
                text("abc"),
                true,
                conjunction(
                        equal(literal(BIGINT, 1L), literal(BIGINT, 1L)), // true
                        equal(literal(BIGINT, 2L), literal(BIGINT, 2L))))) // true
                .isEqualTo(TRUE);

        assertThat(predicateResult(
                dbl(1e0),
                text("abc"),
                true,
                conjunction(
                        equal(literal(BIGINT, 1L), literal(BIGINT, 1L)), // true
                        equal(literal(BIGINT, 2L), literal(BOOLEAN, false))))) // unknown
                .isEqualTo(null);

        assertThat(predicateResult(
                dbl(1e0),
                text("abc"),
                true,
                conjunction(
                        equal(literal(BIGINT, 1L), literal(BOOLEAN, false)), // unknown
                        equal(literal(BIGINT, 2L), literal(BIGINT, 3L))))) // false
                .isEqualTo(FALSE);
    }

    @Test
    public void testDisjunctionPredicate()
    {
        assertThat(predicateResult(
                dbl(1e0),
                text("abc"),
                true,
                disjunction(
                        equal(literal(BIGINT, 1L), literal(BIGINT, 2L)), // false
                        equal(literal(BIGINT, 2L), literal(BIGINT, 2L))))) // true
                .isEqualTo(TRUE);

        assertThat(predicateResult(
                dbl(1e0),
                text("abc"),
                true,
                disjunction(
                        equal(literal(BIGINT, 1L), literal(BIGINT, 2L)), // false
                        equal(literal(BIGINT, 1L), literal(BOOLEAN, false))))) // unknown
                .isEqualTo(null);

        assertThat(predicateResult(
                dbl(1e0),
                text("abc"),
                true,
                disjunction(
                        equal(literal(BIGINT, 1L), literal(BIGINT, 2L)), // false
                        equal(literal(BIGINT, 2L), literal(BIGINT, 3L))))) // false
                .isEqualTo(FALSE);
    }

    @Test
    public void testExistsPredicate()
    {
        assertThat(predicateResult(
                dbl(1e0),
                text("abc"),
                true,
                exists(contextVariable())))
                .isEqualTo(TRUE);

        // member accessor with non-existent key returns empty sequence in lax mode
        assertThat(predicateResult(
                dbl(1e0),
                text("abc"),
                true,
                exists(memberAccessor(jsonVariable("json_object_parameter"), "wrong_key"))))
                .isEqualTo(FALSE);

        // member accessor with non-existent key returns error in strict mode
        assertThat(predicateResult(
                dbl(1e0),
                text("abc"),
                false,
                exists(memberAccessor(jsonVariable("json_object_parameter"), "wrong_key"))))
                .isEqualTo(null);
    }

    @Test
    public void testIsUnknownPredicate()
    {
        assertThat(predicateResult(
                dbl(1e0),
                bigint(1L),
                true,
                isUnknown(equal(literal(BIGINT, 1L), literal(BIGINT, 1L))))) // true
                .isEqualTo(FALSE);

        assertThat(predicateResult(
                dbl(1e0),
                bigint(1L),
                true,
                isUnknown(equal(literal(BIGINT, 1L), literal(BIGINT, 2L))))) // false
                .isEqualTo(FALSE);

        assertThat(predicateResult(
                dbl(1e0),
                bigint(1L),
                true,
                isUnknown(equal(literal(BIGINT, 1L), literal(BOOLEAN, true))))) // unknown
                .isEqualTo(TRUE);
    }

    @Test
    public void testNegationPredicate()
    {
        assertThat(predicateResult(
                dbl(1e0),
                text("abc"),
                true,
                negation(equal(literal(BIGINT, 1L), literal(BIGINT, 1L)))))
                .isEqualTo(FALSE);

        assertThat(predicateResult(
                dbl(1e0),
                text("abc"),
                true,
                negation(notEqual(literal(BIGINT, 1L), literal(BIGINT, 1L)))))
                .isEqualTo(TRUE);

        assertThat(predicateResult(
                dbl(1e0),
                text("abc"),
                true,
                negation(equal(literal(BIGINT, 1L), literal(BOOLEAN, false)))))
                .isEqualTo(null);
    }

    @Test
    public void testStartsWithPredicate()
    {
        assertThat(predicateResult(
                text("abcde"),
                text("abc"),
                true,
                startsWith(contextVariable(), currentItem())))
                .isEqualTo(TRUE);

        assertThat(predicateResult(
                text("abcde"),
                text("abc"),
                true,
                startsWith(jsonVariable("json_text_parameter"), literal(createCharType(4), utf8Slice("JSON")))))
                .isEqualTo(TRUE);

        assertThat(predicateResult(
                text("abcde"),
                text("abc"),
                true,
                startsWith(literal(VARCHAR, utf8Slice("XYZ")), variable("string_parameter"))))
                .isEqualTo(FALSE);

        // multiple inputs - returning true if any match is found
        assertThat(predicateResult(
                array(text("aBC"), text("abc"), text("Abc")),
                text("abc"),
                true,
                startsWith(wildcardArrayAccessor(contextVariable()), literal(createVarcharType(1), utf8Slice("A")))))
                .isEqualTo(TRUE);

        // multiple inputs - returning true if any match is found. array is automatically unwrapped in lax mode
        assertThat(predicateResult(
                array(text("aBC"), text("abc"), text("Abc")),
                text("abc"),
                true,
                startsWith(contextVariable(), literal(createVarcharType(1), utf8Slice("A")))))
                .isEqualTo(TRUE);

        // lax mode: true is returned on the first match, even if there is an uncomparable item
        assertThat(predicateResult(
                array(text("Abc"), JsonNull.JSON_NULL),
                text("abc"),
                true,
                startsWith(contextVariable(), literal(createVarcharType(1), utf8Slice("A")))))
                .isEqualTo(TRUE);

        // lax mode: unknown is returned because there is an uncomparable item, even if match is found first
        assertThat(predicateResult(
                array(text("Abc"), JsonNull.JSON_NULL),
                text("abc"),
                false,
                startsWith(contextVariable(), literal(createVarcharType(1), utf8Slice("A")))))
                .isEqualTo(null);

        // lax mode: unknown is returned because the uncomparable item is before the matching item
        assertThat(predicateResult(
                array(JsonNull.JSON_NULL, text("Abc")),
                text("abc"),
                true,
                startsWith(contextVariable(), literal(createVarcharType(1), utf8Slice("A")))))
                .isEqualTo(null);

        // error while evaluating the first operand (floor method called on a text value) -> result unknown
        assertThat(predicateResult(
                array(JsonNull.JSON_NULL, text("Abc")),
                text("abc"),
                true,
                startsWith(floor(literal(VARCHAR, utf8Slice("x"))), literal(VARCHAR, utf8Slice("A")))))
                .isEqualTo(null);

        // error while evaluating the second operand (floor method called on a text value) -> result unknown
        assertThat(predicateResult(
                array(JsonNull.JSON_NULL, text("Abc")),
                text("abc"),
                true,
                startsWith(literal(VARCHAR, utf8Slice("x")), floor(literal(VARCHAR, utf8Slice("A"))))))
                .isEqualTo(null);

        // the second operand returns multiple items -> result unknown
        assertThat(predicateResult(
                array(text("A"), text("B")),
                text("abc"),
                true,
                startsWith(literal(VARCHAR, utf8Slice("x")), wildcardArrayAccessor(contextVariable()))))
                .isEqualTo(null);

        // the second operand is not text -> result unknown
        assertThat(predicateResult(
                array(JsonNull.JSON_NULL, text("Abc")),
                text("abc"),
                true,
                startsWith(literal(VARCHAR, utf8Slice("x")), literal(BIGINT, 1L))))
                .isEqualTo(null);

        // the first operand returns empty sequence -> result false
        assertThat(predicateResult(
                array(JsonNull.JSON_NULL, text("Abc")),
                text("abc"),
                true,
                startsWith(arrayAccessor(contextVariable(), at(literal(BIGINT, 100L))), literal(VARCHAR, utf8Slice("A")))))
                .isEqualTo(FALSE);
    }

    @Test
    public void testLikeRegexPredicate()
    {
        assertThat(predicateResult(
                text("abcde"),
                text("abc"),
                true,
                likeRegex(contextVariable(), "^abc")))
                .isEqualTo(TRUE);

        assertThat(predicateResult(
                array(text("abc"), text("xyz")),
                text("abc"),
                true,
                likeRegex(contextVariable(), "z$")))
                .isEqualTo(TRUE);

        assertThat(predicateResult(
                integer(7),
                text("abc"),
                true,
                likeRegex(contextVariable(), "^abc")))
                .isEqualTo(null);

        assertThat(predicateResult(
                text("abcde"),
                text("abc"),
                true,
                likeRegex(contextVariable(), "[")))
                .isEqualTo(null);

        assertThat(predicateResult(
                array(text("abc"), text("xyz")),
                text("abc"),
                true,
                likeRegex(arrayAccessor(contextVariable(), at(literal(BIGINT, 100L))), "^abc")))
                .isEqualTo(FALSE);
    }

    @Test
    public void testFilter()
    {
        assertThat(pathResult(
                integer(-5),
                path(true, filter(literal(BIGINT, 5L), greaterThan(currentItem(), literal(BIGINT, 3L)))))) // true
                .isEqualTo(singletonSequence(new TypedValue(BIGINT, 5L)));

        assertThat(pathResult(
                integer(-5),
                path(true, filter(literal(BIGINT, 5L), lessThan(currentItem(), literal(BIGINT, 3L)))))) // false
                .isEqualTo(emptySequence());

        assertThat(pathResult(
                integer(-5),
                path(true, filter(literal(BIGINT, 5L), lessThan(currentItem(), literal(BOOLEAN, true)))))) // unknown
                .isEqualTo(emptySequence());

        // multiple input items
        assertThat(pathResult(
                array(dbl(1.5e0), integer(2), bigint(5), smallint((short) 10)),
                path(true, filter(wildcardArrayAccessor(contextVariable()), greaterThan(currentItem(), literal(BIGINT, 3L))))))
                .isEqualTo(sequence(bigint(5), smallint((short) 10)));

        // multiple input items -- array is automatically unwrapped in lax mode
        assertThat(pathResult(
                array(dbl(1.5e0), integer(2), bigint(5), smallint((short) 10)),
                path(true, filter(contextVariable(), greaterThan(currentItem(), literal(BIGINT, 3L))))))
                .isEqualTo(sequence(bigint(5), smallint((short) 10)));
    }

    @Test
    public void testCurrentItemVariable()
    {
        assertThatThrownBy(() -> evaluate(
                integer(-5),
                path(true, currentItem())))
                .isInstanceOf(PathEvaluationException.class)
                .hasMessage("path evaluation failed: accessing current filter item with no enclosing filter");
    }

    private static IrPathNode variable(String name)
    {
        return PathNodes.variable(PARAMETERS_ORDER.indexOf(name));
    }

    private static IrPathNode jsonVariable(String name)
    {
        return PathNodes.jsonVariable(PARAMETERS_ORDER.indexOf(name));
    }

    private static AssertProvider<? extends RecursiveComparisonAssert<?>> pathResult(JsonItem input, IrJsonPath path)
    {
        return () -> new RecursiveComparisonAssert<>(evaluate(input, path), COMPARISON_CONFIGURATION);
    }

    private static List<JsonItem> evaluate(JsonItem input, IrJsonPath path)
    {
        return createPathVisitor(input, path.isLax()).process(path.getRoot(), new PathEvaluationContext());
    }

    private static AssertProvider<? extends RecursiveComparisonAssert<?>> predicateResult(JsonItem input, JsonItem currentItem, boolean lax, IrPredicate predicate)
    {
        return () -> new RecursiveComparisonAssert<>(evaluatePredicate(input, currentItem, lax, predicate), COMPARISON_CONFIGURATION);
    }

    private static Boolean evaluatePredicate(JsonItem input, JsonItem currentItem, boolean lax, IrPredicate predicate)
    {
        return createPredicateVisitor(input, lax).process(predicate, new PathEvaluationContext().withCurrentItem(currentItem));
    }

    private static PathEvaluationVisitor createPathVisitor(JsonItem input, boolean lax)
    {
        return new PathEvaluationVisitor(
                lax,
                input,
                PARAMETERS.values().toArray(new JsonItem[0]),
                new JsonPathEvaluator.Invoker(testSessionBuilder().build().toConnectorSession(), createTestingFunctionManager()),
                new CachingResolver(createTestingMetadataManager()));
    }

    private static PathPredicateEvaluationVisitor createPredicateVisitor(JsonItem input, boolean lax)
    {
        return new PathPredicateEvaluationVisitor(
                lax,
                createPathVisitor(input, lax),
                new JsonPathEvaluator.Invoker(testSessionBuilder().build().toConnectorSession(), createTestingFunctionManager()),
                new CachingResolver(createTestingMetadataManager()));
    }

    private static List<JsonItem> sequence(JsonItem... items)
    {
        return ImmutableList.copyOf(items);
    }

    private static List<JsonItem> singletonSequence(JsonItem item)
    {
        return ImmutableList.of(item);
    }

    private static List<JsonItem> emptySequence()
    {
        return ImmutableList.of();
    }

    private static JsonPathParameter jsonParameter(JsonValue item)
    {
        return new JsonPathParameter(item);
    }

    private static JsonArray array(JsonValue... elements)
    {
        return new JsonArray(ImmutableList.copyOf(elements));
    }

    private static JsonObject object(JsonObjectMember... members)
    {
        return new JsonObject(ImmutableList.copyOf(members));
    }

    private static JsonObjectMember member(String key, JsonValue value)
    {
        return new JsonObjectMember(key, value);
    }

    private static TypedValue text(String value)
    {
        return new TypedValue(VARCHAR, utf8Slice(value));
    }

    private static TypedValue bool(boolean value)
    {
        return new TypedValue(BOOLEAN, value);
    }

    private static TypedValue integer(int value)
    {
        return new TypedValue(INTEGER, (long) value);
    }

    private static TypedValue bigint(long value)
    {
        return new TypedValue(BIGINT, value);
    }

    private static TypedValue smallint(short value)
    {
        return new TypedValue(SMALLINT, (long) value);
    }

    private static TypedValue dbl(double value)
    {
        return new TypedValue(DOUBLE, value);
    }

    private static TypedValue decimal(BigDecimal value)
    {
        int precision = value.precision();
        if (precision > MAX_PRECISION) {
            throw new IllegalArgumentException("decimal literal is too large for test conversion: " + value);
        }
        int scale = value.scale();
        DecimalType type = createDecimalType(precision, scale);
        Object encoded = type.isShort() ? encodeShortScaledValue(value, scale) : encodeScaledValue(value, scale);
        return TypedValue.fromValueAsObject(type, encoded);
    }
}
