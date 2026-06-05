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
package io.trino.metadata;

import com.google.common.collect.ImmutableList;
import com.google.common.collect.ImmutableSet;
import io.trino.spi.function.Signature;
import io.trino.spi.function.TypeVariableConstraint;
import io.trino.spi.type.ArrayType;
import io.trino.spi.type.FunctionType;
import io.trino.spi.type.NumericExpression;
import io.trino.spi.type.RowType;
import io.trino.spi.type.Type;
import io.trino.spi.type.TypeDescriptor;
import io.trino.spi.type.TypeTemplate;
import io.trino.spi.type.TypeTemplates;
import io.trino.sql.analyzer.TypeDescriptorProvider;
import org.assertj.core.api.Assertions;
import org.junit.jupiter.api.Test;

import java.util.List;
import java.util.Optional;

import static io.trino.metadata.SignatureBinder.applyBoundVariables;
import static io.trino.spi.type.BigintType.BIGINT;
import static io.trino.spi.type.BooleanType.BOOLEAN;
import static io.trino.spi.type.DecimalType.createDecimalType;
import static io.trino.spi.type.DoubleType.DOUBLE;
import static io.trino.spi.type.HyperLogLogType.HYPER_LOG_LOG;
import static io.trino.spi.type.IntegerType.INTEGER;
import static io.trino.spi.type.SmallintType.SMALLINT;
import static io.trino.spi.type.TimestampType.TIMESTAMP_MILLIS;
import static io.trino.spi.type.TinyintType.TINYINT;
import static io.trino.spi.type.TypeDescriptor.arrayType;
import static io.trino.spi.type.TypeDescriptor.functionType;
import static io.trino.spi.type.TypeDescriptor.mapType;
import static io.trino.spi.type.TypeDescriptor.rowType;
import static io.trino.spi.type.TypeParameter.anonymousField;
import static io.trino.spi.type.TypeTemplates.numericType;
import static io.trino.spi.type.TypeTemplates.numericVariable;
import static io.trino.spi.type.VarbinaryType.VARBINARY;
import static io.trino.spi.type.VarcharType.VARCHAR;
import static io.trino.spi.type.VarcharType.createVarcharType;
import static io.trino.sql.analyzer.TypeDescriptorProvider.fromTypes;
import static io.trino.sql.analyzer.TypeDescriptorTranslator.parseTypeDescriptor;
import static io.trino.sql.analyzer.TypeDescriptorTranslator.parseTypeTemplate;
import static io.trino.sql.planner.TestingPlannerContext.PLANNER_CONTEXT;
import static io.trino.type.JsonType.JSON;
import static io.trino.type.UnknownType.UNKNOWN;
import static java.lang.String.format;
import static java.util.Objects.requireNonNull;
import static org.assertj.core.api.Assertions.assertThatThrownBy;

public class TestSignatureBinder
{
    private static final VariableBindings NO_BOUND_VARIABLES = new BindingsBuilder().build();

    @Test
    public void testBindLiteralForDecimal()
    {
        TypeTemplate leftType = numericType("decimal", numericVariable("p1"), numericVariable("s1"));
        TypeTemplate rightType = numericType("decimal", numericVariable("p2"), numericVariable("s2"));

        Signature function = functionSignature()
                .returnType(BOOLEAN)
                .argumentType(leftType)
                .argumentType(rightType)
                .build();

        assertThat(function)
                .boundTo(createDecimalType(2, 1), createDecimalType(1, 0))
                .produces(new BindingsBuilder()
                        .setLongVariable("p1", 2L)
                        .setLongVariable("s1", 1L)
                        .setLongVariable("p2", 1L)
                        .setLongVariable("s2", 0L)
                        .build());
    }

    @Test
    public void testBindPartialDecimal()
    {
        Signature function = functionSignature()
                .returnType(BOOLEAN)
                .argumentType(numericType("decimal", new NumericExpression.Literal(4), numericVariable("s")))
                .build();

        assertThat(function)
                .boundTo(createDecimalType(2, 1))
                .withCoercion()
                .produces(new BindingsBuilder()
                        .setLongVariable("s", 1L)
                        .build());

        function = functionSignature()
                .returnType(BOOLEAN)
                .argumentType(numericType("decimal", numericVariable("p"), new NumericExpression.Literal(1)))
                .build();

        assertThat(function)
                .boundTo(createDecimalType(2, 0))
                .withCoercion()
                .produces(new BindingsBuilder()
                        .setLongVariable("p", 3L)
                        .build());

        assertThat(function)
                .boundTo(createDecimalType(2, 1))
                .produces(new BindingsBuilder()
                        .setLongVariable("p", 2L)
                        .build());

        assertThat(function)
                .boundTo(BIGINT)
                .withCoercion()
                .produces(new BindingsBuilder()
                        .setLongVariable("p", 20L)
                        .build());
    }

    @Test
    public void testBindLiteralForVarchar()
    {
        TypeTemplate leftType = numericType("varchar", numericVariable("x"));
        TypeTemplate rightType = numericType("varchar", numericVariable("y"));

        Signature function = functionSignature()
                .returnType(BOOLEAN)
                .argumentType(leftType)
                .argumentType(rightType)
                .build();

        assertThat(function)
                .boundTo(createVarcharType(42), createVarcharType(44))
                .produces(new BindingsBuilder()
                        .setLongVariable("x", 42L)
                        .setLongVariable("y", 44L)
                        .build());

        assertThat(function)
                .boundTo(UNKNOWN, createVarcharType(44))
                .withCoercion()
                .produces(new BindingsBuilder()
                        .setLongVariable("x", 0L)
                        .setLongVariable("y", 44L)
                        .build());
    }

    @Test
    public void testBindLiteralForRepeatedVarcharWithReturn()
    {
        TypeTemplate leftType = numericType("varchar", numericVariable("x"));
        TypeTemplate rightType = numericType("varchar", numericVariable("x"));

        Signature function = functionSignature()
                .returnType(BOOLEAN)
                .argumentType(leftType)
                .argumentType(rightType)
                .build();

        assertThat(function)
                .boundTo(createVarcharType(44), createVarcharType(44))
                .produces(new BindingsBuilder()
                        .setLongVariable("x", 44L)
                        .build());
        assertThat(function)
                .boundTo(createVarcharType(44), createVarcharType(42))
                .withCoercion()
                .produces(new BindingsBuilder()
                        .setLongVariable("x", 44L)
                        .build());
        assertThat(function)
                .boundTo(createVarcharType(42), createVarcharType(44))
                .withCoercion()
                .produces(new BindingsBuilder()
                        .setLongVariable("x", 44L)
                        .build());
        assertThat(function)
                .boundTo(UNKNOWN, createVarcharType(44))
                .withCoercion()
                .produces(new BindingsBuilder()
                        .setLongVariable("x", 44L)
                        .build());
    }

    @Test
    public void testBindLiteralForRepeatedDecimal()
    {
        TypeTemplate leftType = numericType("decimal", numericVariable("p"), numericVariable("s"));
        TypeTemplate rightType = numericType("decimal", numericVariable("p"), numericVariable("s"));

        Signature function = functionSignature()
                .returnType(BOOLEAN)
                .argumentType(leftType)
                .argumentType(rightType)
                .build();

        assertThat(function)
                .boundTo(createDecimalType(10, 5), createDecimalType(10, 5))
                .produces(new BindingsBuilder()
                        .setLongVariable("p", 10L)
                        .setLongVariable("s", 5L)
                        .build());
        assertThat(function)
                .boundTo(createDecimalType(10, 8), createDecimalType(9, 8))
                .withCoercion()
                .produces(new BindingsBuilder()
                        .setLongVariable("p", 10L)
                        .setLongVariable("s", 8L)
                        .build());
        assertThat(function)
                .boundTo(createDecimalType(10, 2), createDecimalType(10, 8))
                .withCoercion()
                .produces(new BindingsBuilder()
                        .setLongVariable("p", 16L)
                        .setLongVariable("s", 8L)
                        .build());
        assertThat(function)
                .boundTo(UNKNOWN, createDecimalType(10, 5))
                .withCoercion()
                .produces(new BindingsBuilder()
                        .setLongVariable("p", 10L)
                        .setLongVariable("s", 5L)
                        .build());
    }

    @Test
    public void testBindLiteralForRepeatedVarchar()
    {
        TypeTemplate leftType = numericType("varchar", numericVariable("x"));
        TypeTemplate rightType = numericType("varchar", numericVariable("x"));
        TypeTemplate returnType = numericType("varchar", numericVariable("x"));

        Signature function = functionSignature()
                .returnType(returnType)
                .argumentType(leftType)
                .argumentType(rightType)
                .build();

        assertThat(function)
                .withCoercion()
                .boundTo(ImmutableList.of(createVarcharType(3), createVarcharType(5)), createVarcharType(5))
                .produces(new BindingsBuilder()
                        .setLongVariable("x", 5L)
                        .build());

        assertThat(function)
                .withCoercion()
                .boundTo(ImmutableList.of(createVarcharType(3), createVarcharType(5)), createVarcharType(6))
                .produces(new BindingsBuilder()
                        .setLongVariable("x", 6L)
                        .build());
    }

    @Test
    public void testBindUnknown()
    {
        Signature function = functionSignature()
                .returnType(BOOLEAN)
                .argumentType(numericType("varchar", numericVariable("x")))
                .build();

        assertThat(function)
                .boundTo(UNKNOWN)
                .fails();

        assertThat(function)
                .boundTo(UNKNOWN)
                .withCoercion()
                .succeeds();
    }

    @Test
    public void testBindMixedLiteralAndTypeVariables()
    {
        Signature function = functionSignature()
                .returnType(BOOLEAN)
                .typeVariable("T")
                .argumentType(arrayType(new TypeDescriptor("T")))
                .argumentType(TypeTemplates.arrayType(numericType("decimal", numericVariable("p"), numericVariable("s"))))
                .build();

        assertThat(function)
                .boundTo(new ArrayType(createDecimalType(2, 1)), new ArrayType(createDecimalType(3, 1)))
                .withCoercion()
                .produces(new BindingsBuilder()
                        .setTypeVariable("T", createDecimalType(2, 1))
                        .setLongVariable("p", 3L)
                        .setLongVariable("s", 1L)
                        .build());
    }

    @Test
    public void testBindDifferentLiteralParameters()
    {
        TypeTemplate argType = numericType("decimal", numericVariable("p"), numericVariable("s"));

        Signature function = functionSignature()
                .returnType(BOOLEAN)
                .argumentType(argType)
                .argumentType(argType)
                .build();

        assertThat(function)
                .boundTo(createDecimalType(2, 1), createDecimalType(3, 1))
                .fails();
    }

    @Test
    public void testNoVariableReuseAcrossTypes()
    {
        TypeTemplate leftType = numericType("decimal", numericVariable("p1"), numericVariable("s"));
        TypeTemplate rightType = numericType("decimal", numericVariable("p2"), numericVariable("s"));

        Signature function = functionSignature()
                .returnType(BOOLEAN)
                .argumentType(leftType)
                .argumentType(rightType)
                .build();

        assertThatThrownBy(() -> assertThat(function)
                .boundTo(createDecimalType(2, 1), createDecimalType(3, 1))
                .produces(NO_BOUND_VARIABLES))
                .isInstanceOf(UnsupportedOperationException.class)
                .hasMessage("Literal parameters may not be shared across different types");
    }

    @Test
    public void testBindUnknownToDecimal()
    {
        Signature function = functionSignature()
                .returnType(BOOLEAN)
                .argumentType(numericType("decimal", numericVariable("p"), numericVariable("s")))
                .build();

        assertThat(function)
                .boundTo(UNKNOWN)
                .withCoercion()
                .produces(new BindingsBuilder()
                        .setLongVariable("p", 1L)
                        .setLongVariable("s", 0L)
                        .build());
    }

    @Test
    public void testBindUnknownToConcreteArray()
    {
        Signature function = functionSignature()
                .returnType(BOOLEAN)
                .argumentType(arrayType(BOOLEAN.getTypeSignature()))
                .build();

        assertThat(function)
                .boundTo(UNKNOWN)
                .withCoercion()
                .succeeds();
    }

    @Test
    public void testBindTypeVariablesBasedOnTheSecondArgument()
    {
        Signature function = functionSignature()
                .returnType(new TypeDescriptor("T"))
                .argumentType(arrayType(new TypeDescriptor("T")))
                .argumentType(new TypeDescriptor("T"))
                .typeVariable("T")
                .build();

        assertThat(function)
                .boundTo(UNKNOWN, createDecimalType(2, 1))
                .withCoercion()
                .produces(new BindingsBuilder()
                        .setTypeVariable("T", createDecimalType(2, 1))
                        .build());
    }

    @Test
    public void testBindParametricTypeParameterToUnknown()
    {
        Signature function = functionSignature()
                .returnType(new TypeDescriptor("T"))
                .argumentType(arrayType(new TypeDescriptor("T")))
                .typeVariable("T")
                .build();

        assertThat(function)
                .boundTo(UNKNOWN)
                .fails();

        assertThat(function)
                .withCoercion()
                .boundTo(UNKNOWN)
                .succeeds();
    }

    @Test
    public void testBindUnknownToTypeParameter()
    {
        Signature function = functionSignature()
                .returnType(new TypeDescriptor("T"))
                .argumentType(new TypeDescriptor("T"))
                .typeVariable("T")
                .build();

        assertThat(function)
                .boundTo(UNKNOWN)
                .withCoercion()
                .produces(new BindingsBuilder()
                        .setTypeVariable("T", UNKNOWN)
                        .build());
    }

    @Test
    public void testBindDoubleToBigint()
    {
        Signature function = functionSignature()
                .returnType(BOOLEAN)
                .argumentType(DOUBLE)
                .argumentType(DOUBLE)
                .build();

        assertThat(function)
                .boundTo(DOUBLE, BIGINT)
                .withCoercion()
                .succeeds();
    }

    @Test
    public void testBindVarcharTemplateStyle()
    {
        Signature function = functionSignature()
                .returnType(new TypeDescriptor("T2"))
                .argumentType(new TypeDescriptor("T1"))
                .comparableTypeParameter("T1")
                .comparableTypeParameter("T2")
                .build();

        assertThat(function)
                .boundTo(ImmutableList.of(createVarcharType(42)), createVarcharType(1))
                .produces(new BindingsBuilder()
                        .setTypeVariable("T1", createVarcharType(42))
                        .setTypeVariable("T2", createVarcharType(1))
                        .build());
    }

    @Test
    public void testBindVarchar()
    {
        Signature function = functionSignature()
                .returnType(createVarcharType(42).getTypeSignature())
                .argumentType(createVarcharType(42).getTypeSignature())
                .build();

        assertThat(function)
                .boundTo(ImmutableList.of(createVarcharType(1)), createVarcharType(1))
                .fails();

        assertThat(function)
                .boundTo(ImmutableList.of(createVarcharType(1)), createVarcharType(1))
                .withCoercion()
                .fails();

        assertThat(function)
                .boundTo(ImmutableList.of(createVarcharType(1)), createVarcharType(42))
                .withCoercion()
                .succeeds();

        assertThat(function)
                .boundTo(ImmutableList.of(createVarcharType(44)), createVarcharType(44))
                .withCoercion()
                .fails();
    }

    @Test
    public void testBindUnparametrizedVarchar()
    {
        Signature function = functionSignature()
                .returnType(BOOLEAN)
                .argumentType(numericType("varchar", numericVariable("x")))
                .build();

        assertThat(function)
                .boundTo(VARCHAR)
                .produces(new BindingsBuilder()
                        .setLongVariable("x", (long) Integer.MAX_VALUE)
                        .build());
    }

    @Test
    public void testBindToUnparametrizedVarcharIsImpossible()
    {
        Signature function = functionSignature()
                .returnType(BOOLEAN)
                .argumentType(VARCHAR)
                .build();

        assertThat(function)
                .boundTo(createVarcharType(3))
                .withCoercion()
                .succeeds();

        assertThat(function)
                .boundTo(UNKNOWN)
                .withCoercion()
                .succeeds();
    }

    @Test
    public void testUnknownToVariantIsCastableToWithoutRecursion()
    {
        // This forces SignatureBinder to evaluate EXPLICIT_COERCION_TO via canCast(actualType, variant).
        Signature function = functionSignature()
                .returnType(BOOLEAN)
                .argumentType(new TypeDescriptor("T"))
                .typeVariableConstraint(TypeVariableConstraint.builder("T")
                        .castableTo(TypeTemplates.fromTypeDescriptor(new TypeDescriptor("variant")))
                        .build())
                .build();

        assertThat(function)
                .boundTo(UNKNOWN)
                .withCoercion()
                .succeeds();
    }

    @Test
    public void testBasic()
    {
        Signature function = functionSignature()
                .typeVariable("T")
                .returnType(new TypeDescriptor("T"))
                .argumentType(new TypeDescriptor("T"))
                .build();

        assertThat(function)
                .boundTo(BIGINT)
                .produces(new BindingsBuilder()
                        .setTypeVariable("T", BIGINT)
                        .build());

        assertThat(function)
                .boundTo(VARCHAR)
                .produces(new BindingsBuilder()
                        .setTypeVariable("T", VARCHAR)
                        .build());

        assertThat(function)
                .boundTo(VARCHAR, BIGINT)
                .fails();

        assertThat(function)
                .boundTo(new ArrayType(BIGINT))
                .produces(new BindingsBuilder()
                        .setTypeVariable("T", new ArrayType(BIGINT))
                        .build());
    }

    @Test
    public void testMismatchedArgumentCount()
    {
        Signature function = functionSignature()
                .returnType(BOOLEAN)
                .argumentType(BIGINT)
                .argumentType(BIGINT)
                .build();

        assertThat(function)
                .boundTo(BIGINT, BIGINT, BIGINT)
                .fails();

        assertThat(function)
                .boundTo(BIGINT)
                .fails();
    }

    @Test
    public void testNonParametric()
    {
        Signature function = functionSignature()
                .returnType(BOOLEAN)
                .argumentType(BIGINT)
                .build();

        assertThat(function)
                .boundTo(BIGINT)
                .succeeds();

        assertThat(function)
                .boundTo(VARCHAR)
                .withCoercion()
                .fails();

        assertThat(function)
                .boundTo(VARCHAR, BIGINT)
                .withCoercion()
                .fails();

        assertThat(function)
                .boundTo(new ArrayType(BIGINT))
                .withCoercion()
                .fails();
    }

    @Test
    public void testArray()
    {
        Signature getFunction = functionSignature()
                .returnType(new TypeDescriptor("T"))
                .argumentType(arrayType(new TypeDescriptor("T")))
                .typeVariable("T")
                .build();

        assertThat(getFunction)
                .boundTo(new ArrayType(BIGINT))
                .produces(new BindingsBuilder()
                        .setTypeVariable("T", BIGINT)
                        .build());

        assertThat(getFunction)
                .boundTo(BIGINT)
                .withCoercion()
                .fails();

        assertThat(getFunction)
                .boundTo(RowType.anonymous(ImmutableList.of(BIGINT)))
                .withCoercion()
                .fails();

        Signature containsFunction = functionSignature()
                .returnType(new TypeDescriptor("T"))
                .argumentType(arrayType(new TypeDescriptor("T")))
                .argumentType(new TypeDescriptor("T"))
                .comparableTypeParameter("T")
                .build();

        assertThat(containsFunction)
                .boundTo(new ArrayType(BIGINT), BIGINT)
                .produces(new BindingsBuilder()
                        .setTypeVariable("T", BIGINT)
                        .build());

        assertThat(containsFunction)
                .boundTo(new ArrayType(BIGINT), VARCHAR)
                .withCoercion()
                .fails();

        assertThat(containsFunction)
                .boundTo(new ArrayType(HYPER_LOG_LOG), HYPER_LOG_LOG)
                .withCoercion()
                .fails();

        Signature castFunction = functionSignature()
                .returnType(arrayType(new TypeDescriptor("T2")))
                .argumentType(arrayType(new TypeDescriptor("T1")))
                .argumentType(arrayType(new TypeDescriptor("T2")))
                .typeVariable("T1")
                .typeVariable("T2")
                .build();

        assertThat(castFunction)
                .boundTo(new ArrayType(UNKNOWN), new ArrayType(createDecimalType(2, 1)))
                .withCoercion()
                .produces(new BindingsBuilder()
                        .setTypeVariable("T1", UNKNOWN)
                        .setTypeVariable("T2", createDecimalType(2, 1))
                        .build());

        Signature fooFunction = functionSignature()
                .returnType(new TypeDescriptor("T"))
                .argumentType(arrayType(new TypeDescriptor("T")))
                .argumentType(arrayType(new TypeDescriptor("T")))
                .typeVariable("T")
                .build();

        assertThat(fooFunction)
                .boundTo(new ArrayType(BIGINT), new ArrayType(BIGINT))
                .produces(new BindingsBuilder()
                        .setTypeVariable("T", BIGINT)
                        .build());

        assertThat(fooFunction)
                .boundTo(new ArrayType(BIGINT), new ArrayType(VARCHAR))
                .withCoercion()
                .fails();
    }

    @Test
    public void testMap()
    {
        Signature getValueFunction = functionSignature()
                .returnType(new TypeDescriptor("V"))
                .argumentType(mapType(new TypeDescriptor("K"), new TypeDescriptor("V")))
                .argumentType(new TypeDescriptor("K"))
                .typeVariable("K")
                .typeVariable("V")
                .build();

        assertThat(getValueFunction)
                .boundTo(type(mapType(BIGINT.getTypeSignature(), VARCHAR.getTypeSignature())), BIGINT)
                .produces(new BindingsBuilder()
                        .setTypeVariable("K", BIGINT)
                        .setTypeVariable("V", VARCHAR)
                        .build());

        assertThat(getValueFunction)
                .boundTo(type(mapType(BIGINT.getTypeSignature(), VARCHAR.getTypeSignature())), VARCHAR)
                .withCoercion()
                .fails();
    }

    @Test
    public void testRow()
    {
        Signature function = functionSignature()
                .returnType(BOOLEAN)
                .argumentType(rowType(List.of(anonymousField(INTEGER.getTypeSignature()))))
                .build();

        assertThat(function)
                .boundTo(RowType.anonymous(ImmutableList.of(TINYINT)))
                .withCoercion()
                .produces(NO_BOUND_VARIABLES);
        assertThat(function)
                .boundTo(RowType.anonymous(ImmutableList.of(INTEGER)))
                .withCoercion()
                .produces(NO_BOUND_VARIABLES);
        assertThat(function)
                .boundTo(RowType.anonymous(ImmutableList.of(BIGINT)))
                .withCoercion()
                .fails();

        Signature biFunction = functionSignature()
                .returnType(BOOLEAN)
                .argumentType(rowType(List.of(anonymousField(new TypeDescriptor("T")))))
                .argumentType(rowType(List.of(anonymousField(new TypeDescriptor("T")))))
                .typeVariable("T")
                .build();

        assertThat(biFunction)
                .boundTo(RowType.anonymous(ImmutableList.of(INTEGER)), RowType.anonymous(ImmutableList.of(BIGINT)))
                .withCoercion()
                .produces(new BindingsBuilder()
                        .setTypeVariable("T", BIGINT)
                        .build());
        assertThat(biFunction)
                .boundTo(RowType.anonymous(ImmutableList.of(INTEGER)), RowType.anonymous(ImmutableList.of(BIGINT)))
                .withCoercion()
                .produces(new BindingsBuilder()
                        .setTypeVariable("T", BIGINT)
                        .build());
    }

    @Test
    public void testVariadic()
    {
        Signature rowVariadicBoundFunction = functionSignature()
                .returnType(BIGINT)
                .argumentType(new TypeDescriptor("T"))
                .rowTypeParameter("T")
                .build();

        assertThat(rowVariadicBoundFunction)
                .boundTo(RowType.anonymous(ImmutableList.of(BIGINT, BIGINT)))
                .produces(new BindingsBuilder()
                        .setTypeVariable("T", RowType.anonymous(ImmutableList.of(BIGINT, BIGINT)))
                        .build());

        assertThat(rowVariadicBoundFunction)
                .boundTo(new ArrayType(BIGINT))
                .fails();

        assertThat(rowVariadicBoundFunction)
                .boundTo(new ArrayType(BIGINT))
                .withCoercion()
                .fails();
    }

    @Test
    public void testBindUnknownToVariadic()
    {
        Signature rowFunction = functionSignature()
                .returnType(BOOLEAN)
                .argumentType(new TypeDescriptor("T"))
                .argumentType(new TypeDescriptor("T"))
                .rowTypeParameter("T")
                .build();

        assertThat(rowFunction)
                .boundTo(UNKNOWN, RowType.from(ImmutableList.of(RowType.field("a", BIGINT))))
                .withCoercion()
                .produces(new BindingsBuilder()
                        .setTypeVariable("T", RowType.from(ImmutableList.of(RowType.field("a", BIGINT))))
                        .build());
    }

    @Test
    public void testVarArgs()
    {
        Signature variableArityFunction = functionSignature()
                .returnType(BOOLEAN)
                .argumentType(new TypeDescriptor("T"))
                .typeVariable("T")
                .variableArity()
                .build();

        assertThat(variableArityFunction)
                .boundTo(BIGINT)
                .produces(new BindingsBuilder()
                        .setTypeVariable("T", BIGINT)
                        .build());

        assertThat(variableArityFunction)
                .boundTo(VARCHAR)
                .produces(new BindingsBuilder()
                        .setTypeVariable("T", VARCHAR)
                        .build());

        assertThat(variableArityFunction)
                .boundTo(BIGINT, BIGINT)
                .produces(new BindingsBuilder()
                        .setTypeVariable("T", BIGINT)
                        .build());

        assertThat(variableArityFunction)
                .boundTo(BIGINT, VARCHAR)
                .withCoercion()
                .fails();
    }

    @Test
    public void testCoercion()
    {
        Signature function = functionSignature()
                .returnType(BOOLEAN)
                .argumentType(new TypeDescriptor("T"))
                .argumentType(DOUBLE)
                .typeVariable("T")
                .build();

        assertThat(function)
                .boundTo(DOUBLE, DOUBLE)
                .withCoercion()
                .produces(new BindingsBuilder()
                        .setTypeVariable("T", DOUBLE)
                        .build());

        assertThat(function)
                .boundTo(BIGINT, BIGINT)
                .withCoercion()
                .produces(new BindingsBuilder()
                        .setTypeVariable("T", BIGINT)
                        .build());

        assertThat(function)
                .boundTo(VARCHAR, BIGINT)
                .withCoercion()
                .produces(new BindingsBuilder()
                        .setTypeVariable("T", VARCHAR)
                        .build());

        assertThat(function)
                .boundTo(BIGINT, VARCHAR)
                .withCoercion()
                .fails();
    }

    @Test
    public void testUnknownCoercion()
    {
        Signature foo = functionSignature()
                .returnType(BOOLEAN)
                .argumentType(new TypeDescriptor("T"))
                .argumentType(new TypeDescriptor("T"))
                .typeVariable("T")
                .build();

        assertThat(foo)
                .boundTo(UNKNOWN, UNKNOWN)
                .produces(new BindingsBuilder()
                        .setTypeVariable("T", UNKNOWN)
                        .build());

        assertThat(foo)
                .boundTo(UNKNOWN, BIGINT)
                .withCoercion()
                .produces(new BindingsBuilder()
                        .setTypeVariable("T", BIGINT)
                        .build());

        assertThat(foo)
                .boundTo(VARCHAR, BIGINT)
                .withCoercion()
                .fails();

        Signature bar = functionSignature()
                .returnType(BOOLEAN)
                .argumentType(new TypeDescriptor("T"))
                .argumentType(new TypeDescriptor("T"))
                .comparableTypeParameter("T")
                .build();

        assertThat(bar)
                .boundTo(UNKNOWN, BIGINT)
                .withCoercion()
                .produces(new BindingsBuilder()
                        .setTypeVariable("T", BIGINT)
                        .build());

        assertThat(bar)
                .boundTo(VARCHAR, BIGINT)
                .withCoercion()
                .fails();

        assertThat(bar)
                .boundTo(HYPER_LOG_LOG, HYPER_LOG_LOG)
                .withCoercion()
                .fails();
    }

    @Test
    public void testFunction()
    {
        Signature simple = functionSignature()
                .returnType(BOOLEAN)
                .argumentType(functionType(INTEGER.getTypeSignature(), INTEGER.getTypeSignature()))
                .build();

        assertThat(simple)
                .boundTo(INTEGER)
                .fails();
        assertThat(simple)
                .boundTo(new FunctionType(ImmutableList.of(INTEGER), INTEGER))
                .succeeds();
        // TODO: Support coercion of return type of lambda
        assertThat(simple)
                .boundTo(new FunctionType(ImmutableList.of(INTEGER), SMALLINT))
                .withCoercion()
                .fails();
        assertThat(simple)
                .boundTo(new FunctionType(ImmutableList.of(INTEGER), BIGINT))
                .withCoercion()
                .fails();

        Signature applyTwice = functionSignature()
                .returnType(new TypeDescriptor("V"))
                .argumentType(new TypeDescriptor("T"))
                .argumentType(functionType(new TypeDescriptor("T"), new TypeDescriptor("U")))
                .argumentType(functionType(new TypeDescriptor("U"), new TypeDescriptor("V")))
                .typeVariable("T")
                .typeVariable("U")
                .typeVariable("V")
                .build();
        assertThat(applyTwice)
                .boundTo(INTEGER, INTEGER, INTEGER)
                .fails();
        assertThat(applyTwice)
                .boundTo(INTEGER, new FunctionType(ImmutableList.of(INTEGER), VARCHAR), new FunctionType(ImmutableList.of(VARCHAR), DOUBLE))
                .produces(new BindingsBuilder()
                        .setTypeVariable("T", INTEGER)
                        .setTypeVariable("U", VARCHAR)
                        .setTypeVariable("V", DOUBLE)
                        .build());
        assertThat(applyTwice)
                .boundTo(
                        INTEGER,
                        new TypeDescriptorProvider(_ -> new FunctionType(ImmutableList.of(INTEGER), VARCHAR).getTypeSignature()),
                        new TypeDescriptorProvider(_ -> new FunctionType(ImmutableList.of(VARCHAR), DOUBLE).getTypeSignature()))
                .produces(new BindingsBuilder()
                        .setTypeVariable("T", INTEGER)
                        .setTypeVariable("U", VARCHAR)
                        .setTypeVariable("V", DOUBLE)
                        .build());
        assertThat(applyTwice)
                .boundTo(
                        // pass function argument to non-function position of a function
                        new TypeDescriptorProvider(_ -> new FunctionType(ImmutableList.of(INTEGER), VARCHAR).getTypeSignature()),
                        new TypeDescriptorProvider(_ -> new FunctionType(ImmutableList.of(INTEGER), VARCHAR).getTypeSignature()),
                        new TypeDescriptorProvider(_ -> new FunctionType(ImmutableList.of(VARCHAR), DOUBLE).getTypeSignature()))
                .fails();
        assertThat(applyTwice)
                .boundTo(
                        new TypeDescriptorProvider(_ -> new FunctionType(ImmutableList.of(INTEGER), VARCHAR).getTypeSignature()),
                        // pass non-function argument to function position of a function
                        INTEGER,
                        new TypeDescriptorProvider(_ -> new FunctionType(ImmutableList.of(VARCHAR), DOUBLE).getTypeSignature()))
                .fails();

        Signature flatMap = functionSignature()
                .returnType(arrayType(new TypeDescriptor("T")))
                .argumentType(arrayType(new TypeDescriptor("T")))
                .argumentType(functionType(new TypeDescriptor("T"), arrayType(new TypeDescriptor("T"))))
                .typeVariable("T")
                .build();
        assertThat(flatMap)
                .boundTo(new ArrayType(INTEGER), new FunctionType(ImmutableList.of(INTEGER), new ArrayType(INTEGER)))
                .produces(new BindingsBuilder()
                        .setTypeVariable("T", INTEGER)
                        .build());

        Signature varargApply = functionSignature()
                .returnType(new TypeDescriptor("T"))
                .argumentType(new TypeDescriptor("T"))
                .argumentType(functionType(new TypeDescriptor("T"), new TypeDescriptor("T")))
                .typeVariable("T")
                .variableArity()
                .build();
        assertThat(varargApply)
                .boundTo(INTEGER, new FunctionType(ImmutableList.of(INTEGER), INTEGER), new FunctionType(ImmutableList.of(INTEGER), INTEGER), new FunctionType(ImmutableList.of(INTEGER), INTEGER))
                .produces(new BindingsBuilder()
                        .setTypeVariable("T", INTEGER)
                        .build());
        assertThat(varargApply)
                .boundTo(INTEGER, new FunctionType(ImmutableList.of(INTEGER), INTEGER), new FunctionType(ImmutableList.of(INTEGER), DOUBLE), new FunctionType(ImmutableList.of(DOUBLE), DOUBLE))
                .fails();

        Signature loop = functionSignature()
                .returnType(new TypeDescriptor("T"))
                .argumentType(new TypeDescriptor("T"))
                .argumentType(functionType(new TypeDescriptor("T"), new TypeDescriptor("T")))
                .typeVariable("T")
                .build();
        assertThat(loop)
                .boundTo(INTEGER, new TypeDescriptorProvider(paramTypes -> new FunctionType(paramTypes, BIGINT).getTypeSignature()))
                .fails();
        assertThat(loop)
                .boundTo(INTEGER, new TypeDescriptorProvider(paramTypes -> new FunctionType(paramTypes, BIGINT).getTypeSignature()))
                .withCoercion()
                .produces(new BindingsBuilder()
                        .setTypeVariable("T", BIGINT)
                        .build());
        // TODO: Support coercion of return type of lambda
        assertThat(loop)
                .withCoercion()
                .boundTo(INTEGER, new TypeDescriptorProvider(paramTypes -> new FunctionType(paramTypes, SMALLINT).getTypeSignature()))
                .fails();

        // TODO: Support coercion of return type of lambda
        // Without coercion support for return type of lambda, the return type of lambda must be `varchar(x)` to avoid need for coercions.
        Signature varcharApply = functionSignature()
                .returnType(VARCHAR)
                .argumentType(VARCHAR)
                .argumentType(TypeTemplates.functionType(TypeTemplates.fromTypeDescriptor(VARCHAR.getTypeSignature()), numericType("varchar", numericVariable("x"))))
                .build();
        assertThat(varcharApply)
                .withCoercion()
                .boundTo(createVarcharType(10), new TypeDescriptorProvider(paramTypes -> new FunctionType(paramTypes, createVarcharType(1)).getTypeSignature()))
                .succeeds();

        Signature sortByKey = functionSignature()
                .returnType(arrayType(new TypeDescriptor("T")))
                .argumentType(arrayType(new TypeDescriptor("T")))
                .argumentType(functionType(new TypeDescriptor("T"), new TypeDescriptor("E")))
                .typeVariable("T")
                .orderableTypeParameter("E")
                .build();
        assertThat(sortByKey)
                .boundTo(new ArrayType(INTEGER), new TypeDescriptorProvider(paramTypes -> new FunctionType(paramTypes, VARCHAR).getTypeSignature()))
                .produces(new BindingsBuilder()
                        .setTypeVariable("T", INTEGER)
                        .setTypeVariable("E", VARCHAR)
                        .build());
    }

    @Test
    public void testCanCoerceTo()
    {
        Signature arrayJoin = functionSignature()
                .returnType(VARCHAR)
                .argumentType(arrayType(new TypeDescriptor("E")))
                .castableToTypeParameter("E", VARCHAR.getTypeSignature())
                .build();
        assertThat(arrayJoin)
                .boundTo(new ArrayType(INTEGER))
                .produces(new BindingsBuilder()
                        .setTypeVariable("E", INTEGER)
                        .build());
        assertThat(arrayJoin)
                .boundTo(new ArrayType(VARBINARY))
                .fails();

        Signature castArray = functionSignature()
                .returnType(arrayType(new TypeDescriptor("T")))
                .argumentType(arrayType(new TypeDescriptor("F")))
                .typeVariable("T")
                .castableToTypeParameter("F", new TypeDescriptor("T"))
                .build();
        assertThat(castArray)
                .boundTo(ImmutableList.of(new ArrayType(INTEGER)), new ArrayType(VARCHAR))
                .produces(new BindingsBuilder()
                        .setTypeVariable("F", INTEGER)
                        .setTypeVariable("T", VARCHAR)
                        .build());
        assertThat(castArray)
                .boundTo(new ArrayType(INTEGER), new ArrayType(TIMESTAMP_MILLIS))
                .fails();

        Signature multiCast = functionSignature()
                .returnType(VARCHAR)
                .argumentType(arrayType(new TypeDescriptor("E")))
                .typeVariableConstraint(TypeVariableConstraint.builder("E")
                        .castableTo(VARCHAR)
                        .castableTo(INTEGER)
                        .build())
                .build();
        assertThat(multiCast)
                .boundTo(new ArrayType(TINYINT))
                .produces(new BindingsBuilder()
                        .setTypeVariable("E", TINYINT)
                        .build());
        assertThat(multiCast)
                .boundTo(new ArrayType(TIMESTAMP_MILLIS))
                .fails();
    }

    @Test
    public void testCanCoerceFrom()
    {
        Signature arrayJoin = functionSignature()
                .returnType(BOOLEAN)
                .argumentType(arrayType(new TypeDescriptor("E")))
                .argumentType(JSON.getTypeSignature())
                .castableFromTypeParameter("E", JSON.getTypeSignature())
                .build();
        assertThat(arrayJoin)
                .boundTo(new ArrayType(INTEGER), JSON)
                .produces(new BindingsBuilder()
                        .setTypeVariable("E", INTEGER)
                        .build());
        assertThat(arrayJoin)
                .boundTo(new ArrayType(VARBINARY))
                .fails();

        Signature multiCast = functionSignature()
                .returnType(BOOLEAN)
                .argumentType(arrayType(new TypeDescriptor("E")))
                .argumentType(JSON)
                .typeVariableConstraint(TypeVariableConstraint.builder("E")
                        .castableFrom(VARCHAR)
                        .castableFrom(JSON)
                        .build())
                .build();
        assertThat(multiCast)
                .boundTo(new ArrayType(TINYINT), JSON)
                .produces(new BindingsBuilder()
                        .setTypeVariable("E", TINYINT)
                        .build());
        assertThat(multiCast)
                .boundTo(new ArrayType(TIMESTAMP_MILLIS), JSON)
                .fails();
    }

    @Test
    public void testRowIsCastableToVariantWhenFieldsAreCastable()
    {
        Signature function = functionSignature()
                .returnType(BOOLEAN)
                .argumentType(new TypeDescriptor("T"))
                .typeVariableConstraint(TypeVariableConstraint.builder("T")
                        .rowType()
                        .castableTo(TypeTemplates.fromTypeDescriptor(parseTypeDescriptor("variant")))
                        .build())
                .build();

        assertThat(function)
                .boundTo(RowType.anonymous(ImmutableList.of(BIGINT, DOUBLE)))
                .withCoercion()
                .succeeds();
    }

    @Test
    public void testRowIsNotCastableToArbitraryTypeWithoutRecursiveOperator()
    {
        Signature function = functionSignature()
                .returnType(BOOLEAN)
                .argumentType(new TypeDescriptor("T"))
                .typeVariableConstraint(TypeVariableConstraint.builder("T")
                        .rowType()
                        .castableTo(TypeTemplates.fromTypeDescriptor(TIMESTAMP_MILLIS.getTypeSignature()))
                        .build())
                .build();

        assertThat(function)
                .boundTo(RowType.anonymous(ImmutableList.of(BIGINT, DOUBLE)))
                .withCoercion()
                .fails();
    }

    @Test
    public void testVariantIsCastableToRowWhenVariantIsCastableToEachField()
    {
        Signature function = functionSignature()
                .returnType(BOOLEAN)
                .argumentType(new TypeDescriptor("T"))
                .typeVariableConstraint(TypeVariableConstraint.builder("T")
                        .rowType()
                        .castableFrom(TypeTemplates.fromTypeDescriptor(parseTypeDescriptor("json")))
                        .build())
                .build();

        assertThat(function)
                .boundTo(RowType.anonymous(ImmutableList.of(BIGINT, DOUBLE)))
                .withCoercion()
                .succeeds();
    }

    @Test
    public void testBindParameters()
    {
        VariableBindings boundVariables = new BindingsBuilder()
                .setTypeVariable("T1", DOUBLE)
                .setTypeVariable("T2", BIGINT)
                .setTypeVariable("T3", createDecimalType(5, 3))
                .setLongVariable("p", 1L)
                .setLongVariable("s", 2L)
                .build();

        assertThat("bigint", boundVariables, "bigint");
        assertThat("T1", boundVariables, "double");
        assertThat("T2", boundVariables, "bigint");
        assertThat("array(T1)", boundVariables, "array(double)");
        assertThat("array(T3)", boundVariables, "array(decimal(5,3))");
        assertThat("map(T1,T2)", boundVariables, "map(double,bigint)");
        assertThat("bla(T1,42,T2)", boundVariables, "bla(double,42,bigint)");
        assertThat("varchar(p)", boundVariables, "varchar(1)");
        assertThat("char(p)", boundVariables, "char(1)");
        assertThat("decimal(p,s)", boundVariables, "decimal(1,2)");
        assertThat("array(decimal(p,s))", boundVariables, "array(decimal(1,2))");
    }

    private static void assertThat(String typeSignature, VariableBindings typeVariables, String expectedTypeSignature)
    {
        TypeTemplate template = parseTypeTemplate(typeSignature, typeVariables.getTypeVariables().keySet(), ImmutableSet.of("p", "s"));
        Assertions.assertThat(applyBoundVariables(template, typeVariables).toString()).isEqualTo(expectedTypeSignature);
    }

    private static Signature.Builder functionSignature()
    {
        return Signature.builder();
    }

    private Type type(TypeDescriptor signature)
    {
        return requireNonNull(PLANNER_CONTEXT.getTypeManager().getType(signature));
    }

    private BindSignatureAssertion assertThat(Signature function)
    {
        return new BindSignatureAssertion(function);
    }

    private static class BindSignatureAssertion
    {
        private final Signature function;
        private List<TypeDescriptorProvider> argumentTypes;
        private Type returnType;
        private boolean allowCoercion;

        private BindSignatureAssertion(Signature function)
        {
            this.function = function;
        }

        public BindSignatureAssertion withCoercion()
        {
            allowCoercion = true;
            return this;
        }

        public BindSignatureAssertion boundTo(Object... arguments)
        {
            ImmutableList.Builder<TypeDescriptorProvider> builder = ImmutableList.builder();
            for (Object argument : arguments) {
                if (argument instanceof Type type) {
                    builder.add(new TypeDescriptorProvider(type.getTypeSignature()));
                    continue;
                }
                if (argument instanceof TypeDescriptorProvider typeSignatureProvider) {
                    builder.add(typeSignatureProvider);
                    continue;
                }
                throw new IllegalArgumentException(format("argument is of type %s. It should be Type or TypeSignatureProvider", argument.getClass()));
            }
            this.argumentTypes = builder.build();
            return this;
        }

        public BindSignatureAssertion boundTo(List<Type> arguments, Type returnType)
        {
            this.argumentTypes = fromTypes(arguments);
            this.returnType = returnType;
            return this;
        }

        public BindSignatureAssertion succeeds()
        {
            Assertions.assertThat(bindVariables()).isPresent();
            return this;
        }

        public BindSignatureAssertion fails()
        {
            Assertions.assertThat(bindVariables()).isEmpty();
            return this;
        }

        public BindSignatureAssertion produces(VariableBindings expected)
        {
            Optional<VariableBindings> actual = bindVariables();
            Assertions.assertThat(actual).isPresent();
            Assertions.assertThat(actual.get()).isEqualTo(expected);
            return this;
        }

        private Optional<VariableBindings> bindVariables()
        {
            Assertions.assertThat(argumentTypes).isNotNull();
            SignatureBinder signatureBinder = new SignatureBinder(PLANNER_CONTEXT.getMetadata(), PLANNER_CONTEXT.getTypeManager(), function, allowCoercion);
            if (returnType == null) {
                return signatureBinder.bindVariables(argumentTypes);
            }
            return signatureBinder.bindVariables(argumentTypes, returnType.getTypeSignature());
        }
    }
}
