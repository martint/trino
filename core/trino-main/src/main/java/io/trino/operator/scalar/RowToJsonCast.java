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
import io.trino.annotation.UsedByGeneratedCode;
import io.trino.json.JsonItemEmitter;
import io.trino.metadata.SqlScalarFunction;
import io.trino.spi.block.SqlRow;
import io.trino.spi.function.BoundSignature;
import io.trino.spi.function.FunctionMetadata;
import io.trino.spi.function.Signature;
import io.trino.spi.function.TypeVariableConstraint;
import io.trino.spi.type.JsonValue;
import io.trino.spi.type.RowType;
import io.trino.spi.type.TypeSignature;

import java.lang.invoke.MethodHandle;
import java.util.ArrayList;
import java.util.List;

import static io.trino.json.JsonItemEncoding.INDEXED_CONTAINER_THRESHOLD;
import static io.trino.json.JsonItemEncoding.ItemTag.OBJECT;
import static io.trino.json.JsonItemEncoding.ItemTag.OBJECT_INDEXED;
import static io.trino.json.JsonItemEncoding.MAX_OBJECT_INDEXED_COUNT;
import static io.trino.json.JsonItemEncoding.appendObjectKey;
import static io.trino.json.JsonItemEncoding.appendVersion;
import static io.trino.spi.function.InvocationConvention.InvocationArgumentConvention.NEVER_NULL;
import static io.trino.spi.function.InvocationConvention.InvocationReturnConvention.FAIL_ON_NULL;
import static io.trino.spi.function.OperatorType.CAST;
import static io.trino.type.JsonType.JSON;
import static io.trino.util.Reflection.methodHandle;

public class RowToJsonCast
        extends SqlScalarFunction
{
    public static final RowToJsonCast ROW_TO_JSON = new RowToJsonCast();

    private static final MethodHandle METHOD_HANDLE = methodHandle(RowToJsonCast.class, "toJsonObject", List.class, List.class, SqlRow.class);

    private RowToJsonCast()
    {
        super(FunctionMetadata.operatorBuilder(CAST)
                .signature(Signature.builder()
                        .typeVariableConstraint(
                                // this is technically a recursive constraint for cast, but TypeRegistry.canCast has explicit handling for row to json cast
                                TypeVariableConstraint.builder("T")
                                        .rowType()
                                        .build())
                        .returnType(JSON)
                        .argumentType(new TypeSignature("T"))
                        .build())
                .build());
    }

    @Override
    protected SpecializedSqlScalarFunction specialize(BoundSignature boundSignature)
    {
        RowType type = (RowType) boundSignature.getArgumentType(0);

        List<RowType.Field> fields = type.getFields();
        List<JsonItemEmitter> fieldEmitters = new ArrayList<>(fields.size());
        List<String> fieldNames = new ArrayList<>(fields.size());
        for (RowType.Field field : fields) {
            fieldNames.add(field.getName().orElse(""));
            fieldEmitters.add(JsonItemEmitter.create(field.getType()));
        }
        MethodHandle methodHandle = METHOD_HANDLE.bindTo(fieldNames).bindTo(fieldEmitters);

        return new ChoicesSpecializedSqlScalarFunction(
                boundSignature,
                FAIL_ON_NULL,
                ImmutableList.of(NEVER_NULL),
                methodHandle);
    }

    @UsedByGeneratedCode
    public static JsonValue toJsonObject(List<String> fieldNames, List<JsonItemEmitter> fieldEmitters, SqlRow sqlRow)
    {
        int rawIndex = sqlRow.getRawIndex();
        int fieldCount = sqlRow.getFieldCount();
        SliceOutput output = new DynamicSliceOutput(40);
        appendVersion(output);
        if (fieldCount >= INDEXED_CONTAINER_THRESHOLD && fieldCount <= MAX_OBJECT_INDEXED_COUNT) {
            // Buffer entries so we can emit count + sortPerm + offsets header up front.
            DynamicSliceOutput entries = new DynamicSliceOutput(fieldCount * 16);
            io.airlift.slice.Slice[] keyBytes = new io.airlift.slice.Slice[fieldCount];
            int[] offsets = new int[fieldCount + 1];
            for (int i = 0; i < fieldCount; i++) {
                offsets[i] = entries.size();
                io.airlift.slice.Slice key = io.airlift.slice.Slices.utf8Slice(fieldNames.get(i));
                keyBytes[i] = key;
                appendObjectKey(entries, fieldNames.get(i));
                fieldEmitters.get(i).emit(entries, sqlRow.getRawFieldBlock(i), rawIndex);
            }
            offsets[fieldCount] = entries.size();

            Integer[] perm = new Integer[fieldCount];
            for (int i = 0; i < fieldCount; i++) {
                perm[i] = i;
            }
            java.util.Arrays.sort(perm, (a, b) -> keyBytes[a].compareTo(keyBytes[b]));

            output.appendByte(OBJECT_INDEXED.encoded());
            output.appendInt(fieldCount);
            for (Integer p : perm) {
                output.appendShort(p);
            }
            for (int o : offsets) {
                output.appendInt(o);
            }
            output.writeBytes(entries.slice());
        }
        else {
            output.appendByte(OBJECT.encoded());
            output.appendInt(fieldCount);
            for (int i = 0; i < fieldCount; i++) {
                appendObjectKey(output, fieldNames.get(i));
                fieldEmitters.get(i).emit(output, sqlRow.getRawFieldBlock(i), rawIndex);
            }
        }
        return JsonValue.of(output.slice());
    }
}
