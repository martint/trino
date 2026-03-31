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
package io.trino.operator.scalar;

import com.google.common.collect.ImmutableList;
import io.airlift.slice.Slice;
import io.trino.json.JsonNull;
import io.trino.json.JsonValue;
import io.trino.json.ir.TypedValue;
import io.trino.metadata.SqlScalarFunction;
import io.trino.spi.function.BoundSignature;
import io.trino.spi.function.FunctionMetadata;
import io.trino.spi.function.Signature;
import io.trino.spi.type.BigintType;
import io.trino.spi.type.BooleanType;
import io.trino.spi.type.CharType;
import io.trino.spi.type.DateType;
import io.trino.spi.type.DecimalType;
import io.trino.spi.type.DoubleType;
import io.trino.spi.type.IntegerType;
import io.trino.spi.type.RealType;
import io.trino.spi.type.SmallintType;
import io.trino.spi.type.TimeType;
import io.trino.spi.type.TimeWithTimeZoneType;
import io.trino.spi.type.TimestampType;
import io.trino.spi.type.TimestampWithTimeZoneType;
import io.trino.spi.type.TinyintType;
import io.trino.spi.type.Type;
import io.trino.spi.type.TypeSignature;
import io.trino.spi.type.VarcharType;
import io.trino.type.UnknownType;

import java.lang.invoke.MethodHandle;

import static com.google.common.primitives.Primitives.wrap;
import static io.trino.spi.StandardErrorCode.INVALID_FUNCTION_ARGUMENT;
import static io.trino.spi.function.InvocationConvention.InvocationArgumentConvention.BOXED_NULLABLE;
import static io.trino.spi.function.InvocationConvention.InvocationReturnConvention.FAIL_ON_NULL;
import static io.trino.type.JsonType.JSON;
import static io.trino.type.JsonType.jsonValue;
import static io.trino.util.Failures.checkCondition;
import static io.trino.util.Reflection.methodHandle;
import static java.lang.invoke.MethodType.methodType;

public class JsonScalarFunction
        extends SqlScalarFunction
{
    public static final JsonScalarFunction JSON_SCALAR_FUNCTION = new JsonScalarFunction();

    private static final MethodHandle METHOD_HANDLE = methodHandle(JsonScalarFunction.class, "jsonScalar", Type.class, Object.class);

    private JsonScalarFunction()
    {
        super(FunctionMetadata.scalarBuilder("json_scalar")
                .signature(Signature.builder()
                        .typeVariable("T")
                        .returnType(JSON)
                        .argumentType(new TypeSignature("T"))
                        .build())
                .argumentNullability(true)
                .description("Constructs a JSON scalar from an SQL value")
                .build());
    }

    @Override
    protected SpecializedSqlScalarFunction specialize(BoundSignature boundSignature)
    {
        Type type = boundSignature.getArgumentType(0);
        checkCondition(canConstructJsonScalar(type), INVALID_FUNCTION_ARGUMENT, "Cannot construct a JSON scalar from %s", type.getDisplayName());

        MethodHandle methodHandle = METHOD_HANDLE.bindTo(type);
        methodHandle = methodHandle.asType(methodType(Slice.class, wrap(type.getJavaType())));

        return new ChoicesSpecializedSqlScalarFunction(
                boundSignature,
                FAIL_ON_NULL,
                ImmutableList.of(BOXED_NULLABLE),
                methodHandle);
    }

    public static Slice jsonScalar(Type type, Object value)
    {
        JsonValue item = value == null ? JsonNull.JSON_NULL : TypedValue.fromValueAsObject(type, value);
        return jsonValue(item);
    }

    private static boolean canConstructJsonScalar(Type type)
    {
        return type instanceof UnknownType ||
                type instanceof BooleanType ||
                type instanceof TinyintType ||
                type instanceof SmallintType ||
                type instanceof IntegerType ||
                type instanceof BigintType ||
                type instanceof RealType ||
                type instanceof DoubleType ||
                type instanceof DecimalType ||
                type instanceof VarcharType ||
                type instanceof CharType ||
                type instanceof DateType ||
                type instanceof TimeType ||
                type instanceof TimeWithTimeZoneType ||
                type instanceof TimestampType ||
                type instanceof TimestampWithTimeZoneType;
    }
}
