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
import io.trino.json.JsonInputError;
import io.trino.json.JsonItem;
import io.trino.json.JsonItems;
import io.trino.spi.block.Block;
import io.trino.spi.block.BlockBuilder;
import io.trino.spi.block.VariableWidthBlock;
import io.trino.spi.block.VariableWidthBlockBuilder;
import io.trino.spi.type.AbstractVariableWidthType;
import io.trino.spi.type.TypeSignature;

import java.io.IOException;
import java.io.Reader;

import static io.trino.json.JsonInputError.JSON_ERROR;

public class Json2016Type
        extends AbstractVariableWidthType
{
    public static final String NAME = "json2016";
    public static final Json2016Type JSON_2016 = new Json2016Type();

    // Single-byte sentinel that cannot appear at the start of valid UTF-8.
    private static final byte JSON_ERROR_MARKER = (byte) 0xFF;
    private static final Slice JSON_ERROR_SENTINEL = Slices.wrappedBuffer(new byte[] {JSON_ERROR_MARKER});

    public Json2016Type()
    {
        super(new TypeSignature(NAME), Object.class);
    }

    @Override
    public String getDisplayName()
    {
        return NAME;
    }

    @Override
    public Object getObjectValue(Block block, int position)
    {
        Object object = getObject(block, position);
        if (object == null) {
            return null;
        }
        if (object instanceof JsonInputError) {
            return JSON_ERROR;
        }
        return object;
    }

    @Override
    public Object getObject(Block block, int position)
    {
        if (block.isNull(position)) {
            return null;
        }

        VariableWidthBlock valueBlock = (VariableWidthBlock) block.getUnderlyingValueBlock();
        Slice slice = valueBlock.getSlice(block.getUnderlyingValuePosition(position));
        if (slice.length() == 1 && slice.getByte(0) == JSON_ERROR_MARKER) {
            return JSON_ERROR;
        }
        try {
            return JsonItems.parseJson(Reader.of(slice.toStringUtf8()));
        }
        catch (IOException e) {
            throw new IllegalStateException("Invalid JSON text in JSON2016 column", e);
        }
    }

    @Override
    public void writeObject(BlockBuilder blockBuilder, Object value)
    {
        Slice payload = switch (value) {
            case JsonInputError _ -> JSON_ERROR_SENTINEL;
            case JsonItem item -> JsonItems.jsonText(JsonItems.asJsonValue(item));
            default -> throw new IllegalArgumentException("Unsupported JSON2016 value type: " + value.getClass().getName());
        };
        ((VariableWidthBlockBuilder) blockBuilder).writeEntry(payload);
    }
}
