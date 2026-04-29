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
import io.trino.metadata.SqlScalarFunction;
import io.trino.spi.function.BoundSignature;
import io.trino.spi.function.FunctionMetadata;
import io.trino.spi.function.Signature;
import io.trino.spi.type.ArrayType;
import io.trino.spi.type.TypeSignature;
import io.trino.util.JsonUtil.BlockBuilderAppender;

import java.lang.invoke.MethodHandle;

import static com.google.common.base.Preconditions.checkArgument;
import static io.trino.spi.StandardErrorCode.INVALID_CAST_ARGUMENT;
import static io.trino.spi.function.InvocationConvention.InvocationArgumentConvention.NEVER_NULL;
import static io.trino.spi.function.InvocationConvention.InvocationReturnConvention.NULLABLE_RETURN;
import static io.trino.spi.type.TypeParameter.typeVariable;
import static io.trino.spi.type.TypeSignature.arrayType;
import static io.trino.util.Failures.checkCondition;
import static io.trino.util.JsonUtil.canCastFromJson;
import static io.trino.util.Reflection.methodHandle;

public final class JsonStringToArrayCast
        extends SqlScalarFunction
{
    public static final JsonStringToArrayCast JSON_STRING_TO_ARRAY = new JsonStringToArrayCast();
    public static final String JSON_STRING_TO_ARRAY_NAME = "$internal$json_string_to_array_cast";
    private static final MethodHandle METHOD_HANDLE = methodHandle(JsonToArrayCast.class, "toArrayFromText", ArrayType.class, BlockBuilderAppender.class, Slice.class);

    private JsonStringToArrayCast()
    {
        super(FunctionMetadata.scalarBuilder(JSON_STRING_TO_ARRAY_NAME)
                .signature(Signature.builder()
                        .typeVariable("T")
                        .longVariable("N")
                        .returnType(arrayType(new TypeSignature("T")))
                        .argumentType(new TypeSignature("varchar", typeVariable("N")))
                        .build())
                .nullable()
                .hidden()
                .noDescription()
                .build());
    }

    @Override
    protected SpecializedSqlScalarFunction specialize(BoundSignature boundSignature)
    {
        checkArgument(boundSignature.getArity() == 1, "Expected arity to be 1");
        ArrayType arrayType = (ArrayType) boundSignature.getReturnType();
        checkCondition(canCastFromJson(arrayType), INVALID_CAST_ARGUMENT, "Cannot cast JSON to %s", arrayType);

        BlockBuilderAppender arrayAppender = BlockBuilderAppender.createBlockBuilderAppender(arrayType);
        MethodHandle methodHandle = METHOD_HANDLE.bindTo(arrayType).bindTo(arrayAppender);
        return new ChoicesSpecializedSqlScalarFunction(
                boundSignature,
                NULLABLE_RETURN,
                ImmutableList.of(NEVER_NULL),
                methodHandle);
    }
}
