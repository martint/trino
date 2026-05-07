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
import io.trino.json.JsonObject;
import io.trino.json.JsonObjectMember;
import io.trino.json.TypedValue;
import io.trino.spi.block.BlockBuilder;
import io.trino.spi.block.JsonBlock;
import io.trino.spi.block.ValueBlock;
import io.trino.spi.type.JsonPayload;
import io.trino.spi.type.TypeUtils;
import org.junit.jupiter.api.Test;

import java.util.List;

import static io.trino.spi.type.IntegerType.INTEGER;
import static io.trino.type.JsonType.JSON;
import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;

public class TestJsonType
        extends AbstractTestType
{
    public TestJsonType()
    {
        super(JSON, String.class, createTestBlock());
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
        return JsonPayload.of(JsonType.jsonValue(Slices.utf8Slice("null")));
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

        // Lazy parse: original text is preserved verbatim (no canonicalization on read).
        Slice jsonText = JsonType.jsonText(JSON.getSlice(block, 0));
        assertThat(jsonText.toStringUtf8()).isEqualTo("{\"x\":1, \"y\":2}");
        assertThat(rawBlock.getParsedItemSlice(block.getUnderlyingValuePosition(0))).isNotNull();
        assertThat(JSON.getObjectValue(block, 0)).isEqualTo("{\"x\":1, \"y\":2}");
    }

    @Test
    public void testMalformedJsonIsRejectedOnFirstRead()
    {
        // Lazy parse: writing malformed text succeeds; the parse error surfaces on the first
        // read that needs the typed structure.
        BlockBuilder blockBuilder = JSON.createBlockBuilder(null, 1);
        JSON.writeSlice(blockBuilder, Slices.utf8Slice("jhfa"));
        ValueBlock block = blockBuilder.buildValueBlock();
        assertThatThrownBy(() -> JsonType.jsonItem(JSON.getSlice(block, 0)))
                .isInstanceOf(IllegalArgumentException.class)
                .hasMessageContaining("Invalid JSON text");
    }

    @Test
    public void testGetObjectValueReturnsTextRepresentation()
    {
        BlockBuilder blockBuilder = JSON.createBlockBuilder(null, 1);
        JSON.writeSlice(blockBuilder, Slices.utf8Slice("{\"x\":[1,null,\"abc\"]}"));

        ValueBlock block = blockBuilder.buildValueBlock();

        assertThat(JSON.getObjectValue(block, 0)).isEqualTo("{\"x\":[1,null,\"abc\"]}");
    }

    @Test
    public void testJsonItemDecodesStoredPayload()
    {
        Slice encoded = JsonType.jsonValue(Slices.utf8Slice("{\"x\":1}"));
        assertThat(JsonType.jsonItem(encoded))
                .isEqualTo(new JsonObject(List.of(
                        new JsonObjectMember("x", new TypedValue(INTEGER, 1L)))));
    }

    @Test
    public void testWriteNativeValueAcceptsJsonValue()
    {
        // Connector write paths (JdbcPageSink, JsonTypeUtil.jsonText, DeltaLake transactions
        // table) call writeNativeValue(JSON, ...). Since JsonType.getJavaType() == JsonPayload.class,
        // the value must be a JsonPayload.
        Slice payload = JsonType.jsonValue(Slices.utf8Slice("{\"x\":1}"));
        BlockBuilder blockBuilder = JSON.createBlockBuilder(null, 1);
        TypeUtils.writeNativeValue(JSON, blockBuilder, JsonPayload.of(payload));
        assertThat(JSON.getObjectValue(blockBuilder.build(), 0)).isEqualTo("{\"x\":1}");
    }
}
