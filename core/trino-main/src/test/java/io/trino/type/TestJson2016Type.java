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
package io.trino.type;

import io.airlift.slice.Slice;
import io.trino.json.JsonArrayItem;
import io.trino.json.JsonItems;
import io.trino.json.JsonValue;
import io.trino.json.JsonValueView;
import io.trino.json.ir.TypedValue;
import io.trino.spi.block.Block;
import io.trino.spi.block.BlockBuilder;
import io.trino.spi.block.VariableWidthBlock;
import io.trino.spi.type.LongTimeWithTimeZone;
import io.trino.spi.type.LongTimestamp;
import io.trino.spi.type.LongTimestampWithTimeZone;
import org.junit.jupiter.api.Test;

import java.io.IOException;
import java.io.Reader;
import java.io.UncheckedIOException;
import java.util.List;

import static io.trino.json.JsonInputErrorNode.JSON_ERROR;
import static io.trino.spi.type.DateType.DATE;
import static io.trino.spi.type.IntegerType.INTEGER;
import static io.trino.spi.type.TimeType.createTimeType;
import static io.trino.spi.type.TimeWithTimeZoneType.createTimeWithTimeZoneType;
import static io.trino.spi.type.TimestampType.createTimestampType;
import static io.trino.spi.type.TimestampWithTimeZoneType.createTimestampWithTimeZoneType;
import static io.trino.type.Json2016Type.JSON_2016;
import static org.assertj.core.api.Assertions.assertThat;

class TestJson2016Type
{
    @Test
    void testBinaryStorageRoundTrip()
    {
        JsonValue duplicateObject = parseJson("{\"key\":1,\"key\":2}");
        JsonValue temporalArray = new JsonArrayItem(List.of(
                new TypedValue(DATE, 7L),
                new TypedValue(createTimeType(12), 123_456_789_012L),
                new TypedValue(createTimeWithTimeZoneType(12), new LongTimeWithTimeZone(456_789_012_345L, -480)),
                new TypedValue(createTimestampType(9), new LongTimestamp(999_888_777L, 123_456)),
                new TypedValue(createTimestampWithTimeZoneType(12), LongTimestampWithTimeZone.fromEpochMillisAndFraction(555_444_333L, 987_654_321, (short) 0))));

        BlockBuilder blockBuilder = JSON_2016.createBlockBuilder(null, 4);
        JSON_2016.writeObject(blockBuilder, duplicateObject);
        JSON_2016.writeObject(blockBuilder, temporalArray);
        JSON_2016.writeObject(blockBuilder, JSON_ERROR);
        blockBuilder.appendNull();
        Block block = blockBuilder.buildValueBlock();

        assertThat(JsonItems.asJsonValue(JSON_2016.getObject(block, 0))).isEqualTo(JsonItems.asJsonValue(duplicateObject));
        assertThat(JsonItems.asJsonValue(JSON_2016.getObject(block, 1))).isEqualTo(JsonItems.asJsonValue(temporalArray));
        assertThat(JsonValueView.isJsonError(JSON_2016.getObject(block, 2))).isTrue();
        assertThat(JSON_2016.getObject(block, 3)).isNull();

        VariableWidthBlock valueBlock = (VariableWidthBlock) block.getUnderlyingValueBlock();
        int firstPosition = block.getUnderlyingValuePosition(0);
        Slice payload = valueBlock.getSlice(firstPosition);
        assertThat(payload).isNotEqualTo(JsonItems.jsonText(duplicateObject));

        Block region = block.copyRegion(1, 2);
        assertThat(JsonItems.asJsonValue(JSON_2016.getObject(region, 0))).isEqualTo(JsonItems.asJsonValue(temporalArray));
        assertThat(JsonValueView.isJsonError(JSON_2016.getObject(region, 1))).isTrue();
    }

    @Test
    void testNumericTypeWidthsSurviveRoundTrip()
    {
        JsonValue item = new JsonArrayItem(List.of(
                new TypedValue(INTEGER, 1L),
                parseValue("1000000000000"),
                parseValue("1.25")));

        BlockBuilder blockBuilder = JSON_2016.createBlockBuilder(null, 1);
        JSON_2016.writeObject(blockBuilder, item);
        Block block = blockBuilder.buildValueBlock();

        assertThat(JsonItems.asJsonValue(JSON_2016.getObject(block, 0))).isEqualTo(item);
    }

    @Test
    void testWriteObjectAcceptsJsonValueView()
    {
        JsonValue item = parseJson("{\"key\":[1,2,3]}");

        BlockBuilder sourceBuilder = JSON_2016.createBlockBuilder(null, 1);
        JSON_2016.writeObject(sourceBuilder, item);
        Block sourceBlock = sourceBuilder.buildValueBlock();
        JsonValueView view = JsonValueView.fromObject(JSON_2016.getObject(sourceBlock, 0)).orElseThrow();

        BlockBuilder targetBuilder = JSON_2016.createBlockBuilder(null, 1);
        JSON_2016.writeObject(targetBuilder, view);
        Block targetBlock = targetBuilder.buildValueBlock();

        assertThat(JsonItems.asJsonValue(JSON_2016.getObject(targetBlock, 0))).isEqualTo(JsonItems.asJsonValue(item));
    }

    @Test
    void testJsonValueViewRecognizesJsonErrorRepresentations()
    {
        assertThat(JsonValueView.isJsonError(JSON_ERROR)).isTrue();

        BlockBuilder blockBuilder = JSON_2016.createBlockBuilder(null, 1);
        JSON_2016.writeObject(blockBuilder, JSON_ERROR);
        Block block = blockBuilder.buildValueBlock();

        assertThat(JsonValueView.isJsonError(JSON_2016.getObject(block, 0))).isTrue();
    }

    @Test
    void testGetObjectValueReturnsMaterializedItem()
    {
        BlockBuilder blockBuilder = JSON_2016.createBlockBuilder(null, 3);
        JSON_2016.writeObject(blockBuilder, parseJson("{\"x\":[1,null,\"abc\"]}"));
        JSON_2016.writeObject(blockBuilder, JSON_ERROR);
        blockBuilder.appendNull();

        Block block = blockBuilder.buildValueBlock();

        assertThat(JSON_2016.getObjectValue(block, 0)).isEqualTo(parseValue("{\"x\":[1,null,\"abc\"]}"));
        assertThat(JSON_2016.getObjectValue(block, 1)).isEqualTo(JSON_ERROR);
        assertThat(JSON_2016.getObjectValue(block, 2)).isNull();
    }

    private static JsonValue parseJson(String json)
    {
        try {
            return JsonItems.parseJson(Reader.of(json));
        }
        catch (IOException e) {
            throw new UncheckedIOException(e);
        }
    }

    private static JsonValue parseValue(String json)
    {
        JsonValue item = parseJson(json);
        return JsonItems.materializeValue(item);
    }
}
