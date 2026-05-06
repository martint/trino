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
import io.trino.json.JsonItemSemantics;
import io.trino.json.JsonItems;
import io.trino.json.JsonValue;
import io.trino.spi.block.Block;
import io.trino.spi.block.BlockBuilder;
import io.trino.spi.block.ValueBlock;
import io.trino.spi.block.VariableWidthBlock;
import io.trino.spi.block.VariableWidthBlockBuilder;
import io.trino.spi.function.BlockIndex;
import io.trino.spi.function.BlockPosition;
import io.trino.spi.function.FlatFixed;
import io.trino.spi.function.FlatFixedOffset;
import io.trino.spi.function.FlatVariableOffset;
import io.trino.spi.function.FlatVariableWidth;
import io.trino.spi.function.ScalarOperator;
import io.trino.spi.type.AbstractVariableWidthType;
import io.trino.spi.type.JsonPayload;
import io.trino.spi.type.TypeOperatorDeclaration;
import io.trino.spi.type.TypeOperators;
import io.trino.spi.type.TypeSignature;

import java.io.IOException;
import java.io.InputStreamReader;
import java.io.Reader;

import static io.trino.spi.function.OperatorType.EQUAL;
import static io.trino.spi.function.OperatorType.READ_VALUE;
import static io.trino.spi.function.OperatorType.XX_HASH_64;
import static io.trino.spi.type.TypeOperatorDeclaration.extractOperatorDeclaration;
import static java.lang.invoke.MethodHandles.lookup;

/**
 * The stack representation for JSON objects must have the keys in natural sorted order.
 */
public class JsonType
        extends AbstractVariableWidthType
{
    public static final String NAME = "json";
    private static final TypeOperatorDeclaration TYPE_OPERATOR_DECLARATION = extractOperatorDeclaration(JsonType.class, lookup(), JsonPayload.class);
    private static final int SMALL_TEXT_LIMIT = 4096;

    public static final JsonType JSON = new JsonType();

    private JsonType()
    {
        super(new TypeSignature(NAME), JsonPayload.class);
    }

    @Override
    public Object getObject(Block block, int position)
    {
        if (block.isNull(position)) {
            return null;
        }
        return JsonPayload.of(getSlice(block, position));
    }

    @Override
    public void writeObject(BlockBuilder blockBuilder, Object value)
    {
        writeSlice(blockBuilder, ((JsonPayload) value).payload());
    }

    @Override
    public String getDisplayName()
    {
        return NAME;
    }

    @Override
    public boolean isComparable()
    {
        return true;
    }

    @Override
    public TypeOperatorDeclaration getTypeOperatorDeclaration(TypeOperators typeOperators)
    {
        return TYPE_OPERATOR_DECLARATION;
    }

    @Override
    public Object getObjectValue(Block block, int position)
    {
        if (block.isNull(position)) {
            return null;
        }

        return getSlice(block, position).toStringUtf8();
    }

    @Override
    public Slice getSlice(Block block, int position)
    {
        VariableWidthBlock valueBlock = (VariableWidthBlock) block.getUnderlyingValueBlock();
        int valuePosition = block.getUnderlyingValuePosition(position);
        return valueBlock.getSlice(valuePosition);
    }

    public void writeString(BlockBuilder blockBuilder, String value)
    {
        writeSlice(blockBuilder, Slices.utf8Slice(value));
    }

    @Override
    public void writeSlice(BlockBuilder blockBuilder, Slice value)
    {
        writeSlice(blockBuilder, value, 0, value.length());
    }

    @Override
    public void writeSlice(BlockBuilder blockBuilder, Slice value, int offset, int length)
    {
        ((VariableWidthBlockBuilder) blockBuilder).writeEntry(value, offset, length);
    }

    @ScalarOperator(READ_VALUE)
    private static JsonPayload readFlatToStack(
            @FlatFixed byte[] fixedSizeSlice,
            @FlatFixedOffset int fixedSizeOffset,
            @FlatVariableWidth byte[] variableSizeSlice,
            @FlatVariableOffset int variableSizeOffset)
    {
        return JsonPayload.of(Slices.wrappedBuffer(variableSizeSlice, variableSizeOffset, fixedSizeSlice.length - fixedSizeOffset));
    }

    @ScalarOperator(EQUAL)
    private static boolean equalOperator(JsonPayload left, JsonPayload right)
    {
        return slicesEqualOrSemanticallyEqual(left.payload(), right.payload());
    }

    @ScalarOperator(EQUAL)
    private static boolean equalOperator(@BlockPosition VariableWidthBlock leftBlock, @BlockIndex int leftPosition, @BlockPosition VariableWidthBlock rightBlock, @BlockIndex int rightPosition)
    {
        return slicesEqualOrSemanticallyEqual(leftBlock.getSlice(leftPosition), rightBlock.getSlice(rightPosition));
    }

    @ScalarOperator(EQUAL)
    private static boolean equalOperator(JsonPayload left, @BlockPosition VariableWidthBlock rightBlock, @BlockIndex int rightPosition)
    {
        return slicesEqualOrSemanticallyEqual(left.payload(), rightBlock.getSlice(rightPosition));
    }

    @ScalarOperator(EQUAL)
    private static boolean equalOperator(@BlockPosition VariableWidthBlock leftBlock, @BlockIndex int leftPosition, JsonPayload right)
    {
        return slicesEqualOrSemanticallyEqual(leftBlock.getSlice(leftPosition), right.payload());
    }

    private static boolean slicesEqualOrSemanticallyEqual(Slice left, Slice right)
    {
        if (left.equals(right)) {
            return true;
        }
        return JsonItemSemantics.equals(jsonItem(left), jsonItem(right));
    }

    @ScalarOperator(XX_HASH_64)
    private static long xxHash64Operator(JsonPayload value)
    {
        return JsonItemSemantics.hash(jsonItem(value.payload()));
    }

    @ScalarOperator(XX_HASH_64)
    private static long xxHash64Operator(@BlockPosition ValueBlock block, @BlockIndex int position)
    {
        VariableWidthBlock variableBlock = (VariableWidthBlock) block;
        return JsonItemSemantics.hash(jsonItem(variableBlock.getSlice(position)));
    }

    /// Renders the canonical JSON text of a {@link JsonType} payload.
    public static Slice jsonText(Slice value)
    {
        return value;
    }

    /// Decodes a {@link JsonType} payload to a materialized {@link JsonValue} by
    /// parsing it as JSON text.
    public static JsonValue jsonItem(Slice value)
    {
        try {
            return JsonItems.parseJson(textReader(value));
        }
        catch (IOException | RuntimeException e) {
            throw new IllegalArgumentException("Invalid JSON text", e);
        }
    }

    private static Reader textReader(Slice jsonText)
    {
        if (jsonText.length() < SMALL_TEXT_LIMIT) {
            return Reader.of(jsonText.toStringUtf8());
        }
        return new InputStreamReader(jsonText.getInput(), java.nio.charset.StandardCharsets.UTF_8);
    }

    /// Returns the input JSON text payload unchanged.
    public static Slice jsonValue(Slice jsonText)
    {
        return jsonText;
    }

    /// Encodes a materialized {@link JsonValue} as canonical JSON text.
    public static Slice jsonValue(JsonValue item)
    {
        return JsonItems.jsonText(item);
    }
}
