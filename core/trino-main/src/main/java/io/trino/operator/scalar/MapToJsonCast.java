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
import io.trino.json.JsonItemEmitter.KeyExtractor;
import io.trino.metadata.SqlScalarFunction;
import io.trino.spi.block.Block;
import io.trino.spi.block.SqlMap;
import io.trino.spi.function.BoundSignature;
import io.trino.spi.function.FunctionMetadata;
import io.trino.spi.function.Signature;
import io.trino.spi.type.JsonValue;
import io.trino.spi.type.MapType;
import io.trino.spi.type.TypeSignature;

import java.lang.invoke.MethodHandle;
import java.util.Map;
import java.util.Map.Entry;
import java.util.TreeMap;

import static io.trino.json.JsonItemEncoding.INDEXED_CONTAINER_THRESHOLD;
import static io.trino.json.JsonItemEncoding.ItemTag.OBJECT;
import static io.trino.json.JsonItemEncoding.ItemTag.OBJECT_INDEXED;
import static io.trino.json.JsonItemEncoding.MAX_OBJECT_INDEXED_COUNT;
import static io.trino.json.JsonItemEncoding.appendObjectKey;
import static io.trino.json.JsonItemEncoding.appendVersion;
import static io.trino.spi.StandardErrorCode.INVALID_CAST_ARGUMENT;
import static io.trino.spi.function.InvocationConvention.InvocationArgumentConvention.NEVER_NULL;
import static io.trino.spi.function.InvocationConvention.InvocationReturnConvention.FAIL_ON_NULL;
import static io.trino.spi.function.OperatorType.CAST;
import static io.trino.spi.type.TypeSignature.mapType;
import static io.trino.spi.type.VarcharType.VARCHAR;
import static io.trino.type.JsonType.JSON;
import static io.trino.util.Failures.checkCondition;
import static io.trino.util.JsonUtil.canCastToJson;
import static io.trino.util.Reflection.methodHandle;

public class MapToJsonCast
        extends SqlScalarFunction
{
    public static final MapToJsonCast MAP_TO_JSON = new MapToJsonCast();
    private static final MethodHandle METHOD_HANDLE = methodHandle(MapToJsonCast.class, "toJson", KeyExtractor.class, JsonItemEmitter.class, SqlMap.class);

    private MapToJsonCast()
    {
        super(FunctionMetadata.operatorBuilder(CAST)
                .signature(Signature.builder()
                        .castableToTypeParameter("K", VARCHAR.getTypeSignature())
                        .castableToTypeParameter("V", JSON.getTypeSignature())
                        .returnType(JSON)
                        .argumentType(mapType(new TypeSignature("K"), new TypeSignature("V")))
                        .build())
                .build());
    }

    @Override
    public SpecializedSqlScalarFunction specialize(BoundSignature boundSignature)
    {
        MapType mapType = (MapType) boundSignature.getArgumentType(0);
        checkCondition(canCastToJson(mapType), INVALID_CAST_ARGUMENT, "Cannot cast %s to JSON", mapType);

        KeyExtractor keyExtractor = JsonItemEmitter.KeyExtractors.create(mapType.getKeyType());
        JsonItemEmitter valueEmitter = JsonItemEmitter.create(mapType.getValueType());
        MethodHandle methodHandle = METHOD_HANDLE.bindTo(keyExtractor).bindTo(valueEmitter);
        return new ChoicesSpecializedSqlScalarFunction(
                boundSignature,
                FAIL_ON_NULL,
                ImmutableList.of(NEVER_NULL),
                methodHandle);
    }

    @UsedByGeneratedCode
    public static JsonValue toJson(KeyExtractor keyExtractor, JsonItemEmitter valueEmitter, SqlMap map)
    {
        int rawOffset = map.getRawOffset();
        Block rawKeyBlock = map.getRawKeyBlock();
        Block rawValueBlock = map.getRawValueBlock();
        int size = map.getSize();

        // Sort by string key for canonical output ordering.
        Map<String, Integer> orderedKeyToValuePosition = new TreeMap<>();
        for (int i = 0; i < size; i++) {
            orderedKeyToValuePosition.put(keyExtractor.getKey(rawKeyBlock, rawOffset + i), i);
        }

        SliceOutput output = new DynamicSliceOutput(40);
        appendVersion(output);
        int count = orderedKeyToValuePosition.size();
        if (count >= INDEXED_CONTAINER_THRESHOLD && count <= MAX_OBJECT_INDEXED_COUNT) {
            DynamicSliceOutput entries = new DynamicSliceOutput(count * 16);
            io.airlift.slice.Slice[] keyBytes = new io.airlift.slice.Slice[count];
            int[] offsets = new int[count + 1];
            int i = 0;
            for (Entry<String, Integer> entry : orderedKeyToValuePosition.entrySet()) {
                offsets[i] = entries.size();
                keyBytes[i] = io.airlift.slice.Slices.utf8Slice(entry.getKey());
                appendObjectKey(entries, entry.getKey());
                valueEmitter.emit(entries, rawValueBlock, rawOffset + entry.getValue());
                i++;
            }
            offsets[count] = entries.size();

            // Map entries are already sorted by key in TreeMap, so the sort permutation is
            // the identity — but encode it explicitly so the OBJECT_INDEXED format is uniform.
            output.appendByte(OBJECT_INDEXED.encoded());
            output.appendInt(count);
            for (int p = 0; p < count; p++) {
                output.appendShort(p);
            }
            for (int o : offsets) {
                output.appendInt(o);
            }
            output.writeBytes(entries.slice());
        }
        else {
            output.appendByte(OBJECT.encoded());
            output.appendInt(count);
            for (Entry<String, Integer> entry : orderedKeyToValuePosition.entrySet()) {
                appendObjectKey(output, entry.getKey());
                valueEmitter.emit(output, rawValueBlock, rawOffset + entry.getValue());
            }
        }
        return JsonValue.of(output.slice());
    }
}
