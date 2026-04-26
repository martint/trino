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
import io.airlift.slice.DynamicSliceOutput;
import io.airlift.slice.SliceOutput;
import io.trino.json.JsonItemEmitter;
import io.trino.metadata.SqlScalarFunction;
import io.trino.spi.block.Block;
import io.trino.spi.function.BoundSignature;
import io.trino.spi.function.FunctionMetadata;
import io.trino.spi.function.Signature;
import io.trino.spi.type.ArrayType;
import io.trino.spi.type.JsonValue;
import io.trino.spi.type.TypeSignature;

import java.lang.invoke.MethodHandle;

import static io.trino.json.JsonItemEncoding.INDEXED_CONTAINER_THRESHOLD;
import static io.trino.json.JsonItemEncoding.ItemTag.ARRAY;
import static io.trino.json.JsonItemEncoding.ItemTag.ARRAY_INDEXED;
import static io.trino.json.JsonItemEncoding.appendVersion;
import static io.trino.spi.StandardErrorCode.INVALID_CAST_ARGUMENT;
import static io.trino.spi.function.InvocationConvention.InvocationArgumentConvention.NEVER_NULL;
import static io.trino.spi.function.InvocationConvention.InvocationReturnConvention.FAIL_ON_NULL;
import static io.trino.spi.function.OperatorType.CAST;
import static io.trino.spi.type.TypeSignature.arrayType;
import static io.trino.type.JsonType.JSON;
import static io.trino.util.Failures.checkCondition;
import static io.trino.util.JsonUtil.canCastToJson;
import static io.trino.util.Reflection.methodHandle;

public class ArrayToJsonCast
        extends SqlScalarFunction
{
    public static final ArrayToJsonCast ARRAY_TO_JSON = new ArrayToJsonCast();

    private static final MethodHandle METHOD_HANDLE = methodHandle(ArrayToJsonCast.class, "toJson", JsonItemEmitter.class, Block.class);

    private ArrayToJsonCast()
    {
        super(FunctionMetadata.operatorBuilder(CAST)
                .signature(Signature.builder()
                        .castableToTypeParameter("T", JSON.getTypeSignature())
                        .returnType(JSON)
                        .argumentType(arrayType(new TypeSignature("T")))
                        .build())
                .build());
    }

    @Override
    protected SpecializedSqlScalarFunction specialize(BoundSignature boundSignature)
    {
        ArrayType arrayType = (ArrayType) boundSignature.getArgumentTypes().get(0);
        checkCondition(canCastToJson(arrayType), INVALID_CAST_ARGUMENT, "Cannot cast %s to JSON", arrayType);

        JsonItemEmitter elementEmitter = JsonItemEmitter.create(arrayType.getElementType());
        MethodHandle methodHandle = METHOD_HANDLE.bindTo(elementEmitter);
        return new ChoicesSpecializedSqlScalarFunction(
                boundSignature,
                FAIL_ON_NULL,
                ImmutableList.of(NEVER_NULL),
                methodHandle);
    }

    public static JsonValue toJson(JsonItemEmitter elementEmitter, Block block)
    {
        SliceOutput output = new DynamicSliceOutput(40);
        appendVersion(output);
        int count = block.getPositionCount();
        // Match the typed-encoded ARRAY emitter: emit ARRAY_INDEXED for count ≥ threshold so
        // the resulting JsonType payload supports O(1) element lookup at decode time.
        if (count >= INDEXED_CONTAINER_THRESHOLD) {
            DynamicSliceOutput items = new DynamicSliceOutput(count * 8);
            int[] offsets = new int[count + 1];
            for (int i = 0; i < count; i++) {
                offsets[i] = items.size();
                elementEmitter.emit(items, block, i);
            }
            offsets[count] = items.size();
            output.appendByte(ARRAY_INDEXED.encoded());
            output.appendInt(count);
            for (int o : offsets) {
                output.appendInt(o);
            }
            output.writeBytes(items.slice());
        }
        else {
            output.appendByte(ARRAY.encoded());
            output.appendInt(count);
            for (int i = 0; i < count; i++) {
                elementEmitter.emit(output, block, i);
            }
        }
        return JsonValue.of(output.slice());
    }
}
