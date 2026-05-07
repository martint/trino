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

import com.fasterxml.jackson.core.JsonGenerator;
import com.fasterxml.jackson.databind.json.JsonMapper;
import io.airlift.slice.DynamicSliceOutput;
import io.airlift.slice.Slice;
import io.airlift.slice.SliceOutput;
import io.trino.json.JsonItemEmitter;
import io.trino.json.JsonItemEmitter.KeyExtractor;
import io.trino.spi.block.Block;
import io.trino.spi.block.MapBlockBuilder;
import io.trino.spi.block.SqlMap;
import io.trino.spi.type.MapType;
import io.trino.spi.type.TypeOperators;
import io.trino.type.JsonType;
import io.trino.util.JsonUtil.JsonGeneratorWriter;
import io.trino.util.JsonUtil.ObjectKeyProvider;
import org.junit.jupiter.api.Test;

import java.nio.file.Files;
import java.nio.file.Path;
import java.util.Map;
import java.util.TreeMap;

import static io.trino.json.JsonItemEncoding.appendObjectItemHeader;
import static io.trino.json.JsonItemEncoding.appendObjectKey;
import static io.trino.json.JsonItemEncoding.appendVersion;
import static io.trino.spi.type.BigintType.BIGINT;
import static io.trino.spi.type.VarcharType.VARCHAR;
import static io.trino.util.JsonUtil.createJsonFactory;
import static io.trino.util.JsonUtil.createJsonGenerator;

public class BenchCastMapToJson
{
    private static final JsonMapper JSON_MAPPER = new JsonMapper(createJsonFactory());

    @Test
    public void measure()
            throws Exception
    {
        int positions = 10_000;
        TypeOperators ops = new TypeOperators();
        MapType mapType = new MapType(VARCHAR, BIGINT, ops);
        MapBlockBuilder mb = mapType.createBlockBuilder(null, positions);
        for (int position = 0; position < positions; position++) {
            mb.buildEntry((keyBuilder, valueBuilder) -> {
                for (int i = 0; i < 8; i++) {
                    VARCHAR.writeString(keyBuilder, "key" + i);
                    BIGINT.writeLong(valueBuilder, i * 1234567L);
                }
            });
        }
        Block block = mb.build();

        ObjectKeyProvider keyProvider = ObjectKeyProvider.createObjectKeyProvider(VARCHAR);
        JsonGeneratorWriter valueWriter = JsonGeneratorWriter.createJsonGeneratorWriter(BIGINT);
        KeyExtractor keyExtractor = JsonItemEmitter.KeyExtractors.create(VARCHAR);
        JsonItemEmitter valueEmitter = JsonItemEmitter.create(BIGINT);

        Runnable oldPath = () -> {
            for (int position = 0; position < positions; position++) {
                SqlMap map = mapType.getObject(block, position);
                Slice text = jacksonPath(keyProvider, valueWriter, map);
                // Mirror what JsonType.writeSlice did pre-prototype: parse + encode.
                JsonType.jsonValue(text);
            }
        };
        Runnable newPath = () -> {
            for (int position = 0; position < positions; position++) {
                SqlMap map = mapType.getObject(block, position);
                directEmit(keyExtractor, valueEmitter, map);
            }
        };

        double oldNs = measureNs(oldPath, positions);
        double newNs = measureNs(newPath, positions);
        Files.writeString(
                Path.of("/tmp/bench-cast-map.txt"),
                String.format("CAST(map(varchar,bigint, 8 entries) AS JSON):%n  Jackson + jsonValue (old): %7.1f ns/row%n  Direct emitter      (new): %7.1f ns/row%n  speedup: %.1fx%n", oldNs, newNs, oldNs / newNs));
    }

    private static double measureNs(Runnable work, int positionsPerInvocation)
    {
        for (int i = 0; i < 10; i++) {
            work.run();
        }
        int iterations = 30;
        long start = System.nanoTime();
        for (int i = 0; i < iterations; i++) {
            work.run();
        }
        long elapsed = System.nanoTime() - start;
        return (double) elapsed / iterations / positionsPerInvocation;
    }

    private static Slice jacksonPath(ObjectKeyProvider provider, JsonGeneratorWriter writer, SqlMap map)
    {
        try {
            int rawOffset = map.getRawOffset();
            Block rawKeyBlock = map.getRawKeyBlock();
            Block rawValueBlock = map.getRawValueBlock();
            Map<String, Integer> orderedKeyToValuePosition = new TreeMap<>();
            for (int i = 0; i < map.getSize(); i++) {
                orderedKeyToValuePosition.put(provider.getObjectKey(rawKeyBlock, rawOffset + i), i);
            }
            SliceOutput output = new DynamicSliceOutput(40);
            try (JsonGenerator jsonGenerator = createJsonGenerator(JSON_MAPPER, output)) {
                jsonGenerator.writeStartObject();
                for (Map.Entry<String, Integer> entry : orderedKeyToValuePosition.entrySet()) {
                    jsonGenerator.writeFieldName(entry.getKey());
                    writer.writeJsonValue(jsonGenerator, rawValueBlock, rawOffset + entry.getValue());
                }
                jsonGenerator.writeEndObject();
            }
            return output.slice();
        }
        catch (Exception e) {
            throw new RuntimeException(e);
        }
    }

    private static Slice directEmit(KeyExtractor keyExtractor, JsonItemEmitter valueEmitter, SqlMap map)
    {
        int rawOffset = map.getRawOffset();
        Block rawKeyBlock = map.getRawKeyBlock();
        Block rawValueBlock = map.getRawValueBlock();
        int size = map.getSize();
        Map<String, Integer> orderedKeyToValuePosition = new TreeMap<>();
        for (int i = 0; i < size; i++) {
            orderedKeyToValuePosition.put(keyExtractor.getKey(rawKeyBlock, rawOffset + i), i);
        }
        SliceOutput output = new DynamicSliceOutput(40);
        appendVersion(output);
        appendObjectItemHeader(output, orderedKeyToValuePosition.size());
        for (Map.Entry<String, Integer> entry : orderedKeyToValuePosition.entrySet()) {
            appendObjectKey(output, entry.getKey());
            valueEmitter.emit(output, rawValueBlock, rawOffset + entry.getValue());
        }
        return output.slice();
    }
}
