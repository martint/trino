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
import io.airlift.slice.Slices;
import io.trino.json.JsonArrayItem;
import io.trino.json.JsonNull;
import io.trino.json.JsonObjectItem;
import io.trino.json.JsonObjectMember;
import io.trino.json.JsonValue;
import io.trino.json.ir.TypedValue;
import io.trino.spi.block.BlockBuilder;
import io.trino.spi.block.JsonBlock;
import io.trino.spi.block.ValueBlock;
import org.junit.jupiter.api.Test;

import java.util.List;

import static io.trino.spi.type.IntegerType.INTEGER;
import static io.trino.spi.type.VarcharType.VARCHAR;
import static io.trino.type.JsonType.JSON;
import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;

public class TestJsonType
        extends AbstractTestType
{
    public TestJsonType()
    {
        super(JSON, JsonValue.class, createTestBlock());
    }

    public static ValueBlock createTestBlock()
    {
        BlockBuilder blockBuilder = JSON.createBlockBuilder(null, 1);
        Slice slice = Slices.utf8Slice("{\"x\":1, \"y\":2}");
        JSON.writeSlice(blockBuilder, slice);
        return blockBuilder.buildValueBlock();
    }

    @Override
    protected Object getGreaterValue(Object value)
    {
        return null;
    }

    @Override
    protected Object getNonNullValue()
    {
        return Slices.utf8Slice("null");
    }

    @Test
    public void testRange()
    {
        assertThat(type.getRange())
                .isEmpty();
    }

    @Test
    public void testPreviousValue()
    {
        assertThatThrownBy(() -> type.getPreviousValue(getSampleValue()))
                .isInstanceOf(IllegalStateException.class)
                .hasMessage("Type is not orderable: " + type);
    }

    @Test
    public void testNextValue()
    {
        assertThatThrownBy(() -> type.getNextValue(getSampleValue()))
                .isInstanceOf(IllegalStateException.class)
                .hasMessage("Type is not orderable: " + type);
    }

    @Test
    public void testBinaryBlockStorageRendersTextLazily()
    {
        ValueBlock block = createTestBlock();
        JsonBlock rawBlock = (JsonBlock) block.getUnderlyingValueBlock();

        Slice jsonText = JsonType.jsonText(JSON.getSlice(block, 0));
        assertThat(jsonText.toStringUtf8()).isEqualTo("{\"x\":1,\"y\":2}");
        assertThat(rawBlock.getParsedItemSlice(block.getUnderlyingValuePosition(0))).isNotNull();
        assertThat(JSON.getObjectValue(block, 0))
                .isEqualTo(new JsonObjectItem(List.of(
                        new JsonObjectMember("x", new TypedValue(INTEGER, 1L)),
                        new JsonObjectMember("y", new TypedValue(INTEGER, 2L)))));
    }

    @Test
    public void testLegacyMalformedJsonStorage()
    {
        BlockBuilder blockBuilder = JSON.createBlockBuilder(null, 1);
        Slice malformedJson = Slices.utf8Slice("jhfa");

        JSON.writeSlice(blockBuilder, JsonType.legacyJsonValue(malformedJson));

        ValueBlock block = blockBuilder.buildValueBlock();
        Slice value = JSON.getSlice(block, 0);

        assertThat(JsonType.hasParsedItem(value)).isFalse();
        assertThat(JsonType.jsonText(value)).isEqualTo(malformedJson);
        // Malformed JSON can't be represented as a typed item; getObjectValue falls back to the raw text.
        assertThat(JSON.getObjectValue(block, 0)).isEqualTo("jhfa");
    }

    @Test
    public void testGetObjectValueReturnsMaterializedJsonValue()
    {
        BlockBuilder blockBuilder = JSON.createBlockBuilder(null, 1);
        JSON.writeSlice(blockBuilder, Slices.utf8Slice("{\"x\":[1,null,\"abc\"]}"));

        ValueBlock block = blockBuilder.buildValueBlock();

        assertThat(JSON.getObjectValue(block, 0))
                .isEqualTo(new JsonObjectItem(List.of(
                        new JsonObjectMember("x", new JsonArrayItem(List.of(
                                new TypedValue(INTEGER, 1L),
                                JsonNull.JSON_NULL,
                                new TypedValue(VARCHAR, Slices.utf8Slice("abc"))))))));
    }

    @Test
    public void testJsonItemParsesRawJsonTextDirectly()
    {
        assertThat(JsonType.jsonItem(Slices.utf8Slice("{\"x\":1}")))
                .isEqualTo(new JsonObjectItem(List.of(
                        new JsonObjectMember("x", new TypedValue(INTEGER, 1L)))));
    }
}
