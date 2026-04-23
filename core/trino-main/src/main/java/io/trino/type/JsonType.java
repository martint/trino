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
import io.trino.json.JsonItemEncoding;
import io.trino.json.JsonItemSemantics;
import io.trino.json.JsonItems;
import io.trino.json.JsonValue;
import io.trino.json.JsonValueView;
import io.trino.spi.block.Block;
import io.trino.spi.block.BlockBuilder;
import io.trino.spi.block.BlockBuilderStatus;
import io.trino.spi.block.JsonBlock;
import io.trino.spi.block.JsonBlockBuilder;
import io.trino.spi.block.PageBuilderStatus;
import io.trino.spi.function.BlockIndex;
import io.trino.spi.function.BlockPosition;
import io.trino.spi.function.FlatFixed;
import io.trino.spi.function.FlatFixedOffset;
import io.trino.spi.function.FlatVariableOffset;
import io.trino.spi.function.FlatVariableWidth;
import io.trino.spi.function.ScalarOperator;
import io.trino.spi.type.AbstractType;
import io.trino.spi.type.TypeOperatorDeclaration;
import io.trino.spi.type.TypeOperators;
import io.trino.spi.type.TypeSignature;
import io.trino.spi.type.VariableWidthType;

import java.io.IOException;
import java.io.InputStreamReader;
import java.lang.invoke.MethodHandles;
import java.lang.invoke.VarHandle;
import java.nio.ByteOrder;
import java.nio.charset.StandardCharsets;

import static io.airlift.slice.Slices.wrappedBuffer;
import static io.trino.spi.function.OperatorType.EQUAL;
import static io.trino.spi.function.OperatorType.READ_VALUE;
import static io.trino.spi.function.OperatorType.XX_HASH_64;
import static io.trino.spi.type.TypeOperatorDeclaration.extractOperatorDeclaration;
import static java.lang.Math.min;
import static java.lang.invoke.MethodHandles.lookup;

public class JsonType
        extends AbstractType
        implements VariableWidthType
{
    public static final String NAME = "json";
    private static final TypeOperatorDeclaration TYPE_OPERATOR_DECLARATION = extractOperatorDeclaration(JsonType.class, lookup(), Slice.class);
    private static final VarHandle INT_BE_HANDLE = MethodHandles.byteArrayViewVarHandle(int[].class, ByteOrder.BIG_ENDIAN);
    private static final int MAX_SHORT_FLAT_LENGTH = 3;
    private static final int EXPECTED_BYTES_PER_ENTRY = 32;

    public static final JsonType JSON = new JsonType();

    private JsonType()
    {
        super(new TypeSignature(NAME), Slice.class, JsonBlock.class);
    }

    @Override
    public String getDisplayName()
    {
        return NAME;
    }

    @Override
    public JsonBlockBuilder createBlockBuilder(BlockBuilderStatus blockBuilderStatus, int expectedEntries, int expectedBytesPerEntry)
    {
        int maxBlockSizeInBytes;
        if (blockBuilderStatus == null) {
            maxBlockSizeInBytes = PageBuilderStatus.DEFAULT_MAX_PAGE_SIZE_IN_BYTES;
        }
        else {
            maxBlockSizeInBytes = blockBuilderStatus.getMaxPageSizeInBytes();
        }

        int expectedBytes = (int) min((long) expectedEntries * expectedBytesPerEntry, maxBlockSizeInBytes);
        return new JsonBlockBuilder(
                blockBuilderStatus,
                expectedBytesPerEntry == 0 ? expectedEntries : min(expectedEntries, maxBlockSizeInBytes / expectedBytesPerEntry),
                expectedBytes);
    }

    @Override
    public JsonBlockBuilder createBlockBuilder(BlockBuilderStatus blockBuilderStatus, int expectedEntries)
    {
        return createBlockBuilder(blockBuilderStatus, expectedEntries, EXPECTED_BYTES_PER_ENTRY);
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

        JsonBlock valueBlock = (JsonBlock) block.getUnderlyingValueBlock();
        int valuePosition = block.getUnderlyingValuePosition(position);
        Slice payload = valueBlock.getParsedItemSlice(valuePosition);
        return JsonItems.jsonText(JsonItemEncoding.decode(payload)).toStringUtf8();
    }

    @Override
    public Slice getSlice(Block block, int position)
    {
        JsonBlock valueBlock = (JsonBlock) block.getUnderlyingValueBlock();
        int valuePosition = block.getUnderlyingValuePosition(position);
        return valueBlock.getParsedItemSlice(valuePosition);
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
        Slice payload = value.slice(offset, length);
        if (!JsonItemEncoding.isEncoding(payload)) {
            payload = jsonValue(payload);
        }
        ((JsonBlockBuilder) blockBuilder).writeEntry(payload);
    }

    @Override
    public int getFlatFixedSize()
    {
        return Integer.BYTES;
    }

    @Override
    public boolean isFlatVariableWidth()
    {
        return true;
    }

    @Override
    public int getFlatVariableWidthSize(Block block, int position)
    {
        if (block.isNull(position)) {
            return 0;
        }

        JsonBlock jsonBlock = (JsonBlock) block.getUnderlyingValueBlock();
        int valuePosition = block.getUnderlyingValuePosition(position);
        return jsonBlock.getParsedItemSlice(valuePosition).length();
    }

    @Override
    public int getFlatVariableWidthLength(byte[] fixedSizeSlice, int fixedSizeOffset)
    {
        int length = readVariableWidthLength(fixedSizeSlice, fixedSizeOffset);
        if (length <= MAX_SHORT_FLAT_LENGTH) {
            return 0;
        }
        return length;
    }

    static int readVariableWidthLength(byte[] fixedSizeSlice, int fixedSizeOffset)
    {
        int length = (int) INT_BE_HANDLE.get(fixedSizeSlice, fixedSizeOffset);
        if (length < 0) {
            int shortLength = fixedSizeSlice[fixedSizeOffset] & 0x7F;
            if (shortLength > MAX_SHORT_FLAT_LENGTH) {
                throw new IllegalArgumentException("Invalid short variable width length: " + shortLength);
            }
            return shortLength;
        }
        return length;
    }

    static void writeFlatVariableLength(int length, byte[] fixedSizeSlice, int fixedSizeOffset)
    {
        if (length < 0) {
            throw new IllegalArgumentException("Invalid variable width length: " + length);
        }
        if (length <= MAX_SHORT_FLAT_LENGTH) {
            fixedSizeSlice[fixedSizeOffset] = (byte) (length | 0x80);
        }
        else {
            INT_BE_HANDLE.set(fixedSizeSlice, fixedSizeOffset, length);
        }
    }

    @ScalarOperator(READ_VALUE)
    private static Slice readFlatToStack(
            @FlatFixed byte[] fixedSizeSlice,
            @FlatFixedOffset int fixedSizeOffset,
            @FlatVariableWidth byte[] variableSizeSlice,
            @FlatVariableOffset int variableSizeOffset)
    {
        return getFlatPayload(fixedSizeSlice, fixedSizeOffset, variableSizeSlice, variableSizeOffset);
    }

    @ScalarOperator(READ_VALUE)
    private static void readFlatToBlock(
            @FlatFixed byte[] fixedSizeSlice,
            @FlatFixedOffset int fixedSizeOffset,
            @FlatVariableWidth byte[] variableSizeSlice,
            @FlatVariableOffset int variableSizeOffset,
            BlockBuilder blockBuilder)
    {
        ((JsonBlockBuilder) blockBuilder).writeEntry(getFlatPayload(fixedSizeSlice, fixedSizeOffset, variableSizeSlice, variableSizeOffset));
    }

    @ScalarOperator(READ_VALUE)
    private static void writeFlatFromStack(
            Slice value,
            @FlatFixed byte[] fixedSizeSlice,
            @FlatFixedOffset int fixedSizeOffset,
            @FlatVariableWidth byte[] variableSizeSlice,
            @FlatVariableOffset int variableSizeOffset)
    {
        Slice payload = JsonItemEncoding.isEncoding(value) ? value : jsonValue(value);
        writeFlatPayload(payload, fixedSizeSlice, fixedSizeOffset, variableSizeSlice, variableSizeOffset);
    }

    @ScalarOperator(READ_VALUE)
    private static void writeFlatFromBlock(
            @BlockPosition JsonBlock block,
            @BlockIndex int position,
            @FlatFixed byte[] fixedSizeSlice,
            @FlatFixedOffset int fixedSizeOffset,
            @FlatVariableWidth byte[] variableSizeSlice,
            @FlatVariableOffset int variableSizeOffset)
    {
        writeFlatPayload(block.getParsedItemSlice(position), fixedSizeSlice, fixedSizeOffset, variableSizeSlice, variableSizeOffset);
    }

    @ScalarOperator(EQUAL)
    private static boolean equalOperator(Slice left, Slice right)
    {
        return JsonItemSemantics.equals(JsonValueView.root(left), JsonValueView.root(right));
    }

    @ScalarOperator(EQUAL)
    private static boolean equalOperator(@BlockPosition JsonBlock leftBlock, @BlockIndex int leftPosition, @BlockPosition JsonBlock rightBlock, @BlockIndex int rightPosition)
    {
        return JsonItemSemantics.equals(
                JsonValueView.root(leftBlock.getParsedItemSlice(leftPosition)),
                JsonValueView.root(rightBlock.getParsedItemSlice(rightPosition)));
    }

    @ScalarOperator(EQUAL)
    private static boolean equalOperator(Slice left, @BlockPosition JsonBlock rightBlock, @BlockIndex int rightPosition)
    {
        return JsonItemSemantics.equals(JsonValueView.root(left), JsonValueView.root(rightBlock.getParsedItemSlice(rightPosition)));
    }

    @ScalarOperator(EQUAL)
    private static boolean equalOperator(@BlockPosition JsonBlock leftBlock, @BlockIndex int leftPosition, Slice right)
    {
        return JsonItemSemantics.equals(JsonValueView.root(leftBlock.getParsedItemSlice(leftPosition)), JsonValueView.root(right));
    }

    @ScalarOperator(EQUAL)
    private static boolean equalOperator(
            @FlatFixed byte[] leftFixedSizeSlice,
            @FlatFixedOffset int leftFixedSizeOffset,
            @FlatVariableWidth byte[] leftVariableSizeSlice,
            @FlatVariableOffset int leftVariableSizeOffset,
            @FlatFixed byte[] rightFixedSizeSlice,
            @FlatFixedOffset int rightFixedSizeOffset,
            @FlatVariableWidth byte[] rightVariableSizeSlice,
            @FlatVariableOffset int rightVariableSizeOffset)
    {
        return JsonItemSemantics.equals(
                JsonValueView.root(getFlatPayload(leftFixedSizeSlice, leftFixedSizeOffset, leftVariableSizeSlice, leftVariableSizeOffset)),
                JsonValueView.root(getFlatPayload(rightFixedSizeSlice, rightFixedSizeOffset, rightVariableSizeSlice, rightVariableSizeOffset)));
    }

    @ScalarOperator(EQUAL)
    private static boolean equalOperator(
            @FlatFixed byte[] leftFixedSizeSlice,
            @FlatFixedOffset int leftFixedSizeOffset,
            @FlatVariableWidth byte[] leftVariableSizeSlice,
            @FlatVariableOffset int leftVariableSizeOffset,
            @BlockPosition JsonBlock rightBlock,
            @BlockIndex int rightPosition)
    {
        return JsonItemSemantics.equals(
                JsonValueView.root(getFlatPayload(leftFixedSizeSlice, leftFixedSizeOffset, leftVariableSizeSlice, leftVariableSizeOffset)),
                JsonValueView.root(rightBlock.getParsedItemSlice(rightPosition)));
    }

    @ScalarOperator(EQUAL)
    private static boolean equalOperator(
            @BlockPosition JsonBlock leftBlock,
            @BlockIndex int leftPosition,
            @FlatFixed byte[] rightFixedSizeSlice,
            @FlatFixedOffset int rightFixedSizeOffset,
            @FlatVariableWidth byte[] rightVariableSizeSlice,
            @FlatVariableOffset int rightVariableSizeOffset)
    {
        return JsonItemSemantics.equals(
                JsonValueView.root(leftBlock.getParsedItemSlice(leftPosition)),
                JsonValueView.root(getFlatPayload(rightFixedSizeSlice, rightFixedSizeOffset, rightVariableSizeSlice, rightVariableSizeOffset)));
    }

    @ScalarOperator(XX_HASH_64)
    private static long xxHash64Operator(Slice value)
    {
        return JsonItemSemantics.hash(JsonValueView.root(value));
    }

    @ScalarOperator(XX_HASH_64)
    private static long xxHash64Operator(@BlockPosition JsonBlock block, @BlockIndex int position)
    {
        return JsonItemSemantics.hash(JsonValueView.root(block.getParsedItemSlice(position)));
    }

    @ScalarOperator(XX_HASH_64)
    private static long xxHash64Operator(
            @FlatFixed byte[] fixedSizeSlice,
            @FlatFixedOffset int fixedSizeOffset,
            @FlatVariableWidth byte[] variableSizeSlice,
            @FlatVariableOffset int variableSizeOffset)
    {
        return JsonItemSemantics.hash(JsonValueView.root(getFlatPayload(fixedSizeSlice, fixedSizeOffset, variableSizeSlice, variableSizeOffset)));
    }

    /// Renders the canonical JSON text of a stored {@link JsonType} payload.
    public static Slice jsonText(Slice value)
    {
        return JsonItems.jsonText(JsonItemEncoding.decode(value));
    }

    /// Decodes a stored {@link JsonType} payload back to a materialized {@link JsonValue}.
    public static JsonValue jsonItem(Slice value)
    {
        return JsonItemEncoding.decodeValue(value);
    }

    /// Encodes raw JSON text as a {@link JsonType} payload.
    ///
    /// Throws {@link IllegalArgumentException} if the text is not valid JSON or cannot
    /// be represented in the typed SQL/JSON item model.
    public static Slice jsonValue(Slice jsonText)
    {
        try {
            JsonValue item = JsonItems.parseJson(new InputStreamReader(jsonText.getInput(), StandardCharsets.UTF_8));
            return JsonItemEncoding.encode(item);
        }
        catch (IOException | RuntimeException e) {
            throw new IllegalArgumentException("Invalid JSON text", e);
        }
    }

    /// Encodes a materialized {@link JsonValue} as a {@link JsonType} payload.
    public static Slice jsonValue(JsonValue item)
    {
        return JsonItemEncoding.encode(item);
    }

    private static Slice getFlatPayload(byte[] fixedSizeSlice, int fixedSizeOffset, byte[] variableSizeSlice, int variableSizeOffset)
    {
        int length = readVariableWidthLength(fixedSizeSlice, fixedSizeOffset);
        byte[] bytes;
        int offset;
        if (length <= MAX_SHORT_FLAT_LENGTH) {
            bytes = fixedSizeSlice;
            offset = fixedSizeOffset + 1;
        }
        else {
            bytes = variableSizeSlice;
            offset = variableSizeOffset;
        }
        return wrappedBuffer(bytes, offset, length);
    }

    private static void writeFlatPayload(Slice payload, byte[] fixedSizeSlice, int fixedSizeOffset, byte[] variableSizeSlice, int variableSizeOffset)
    {
        int length = payload.length();
        writeFlatVariableLength(length, fixedSizeSlice, fixedSizeOffset);
        byte[] bytes;
        int offset;
        if (length <= MAX_SHORT_FLAT_LENGTH) {
            bytes = fixedSizeSlice;
            offset = fixedSizeOffset + 1;
        }
        else {
            bytes = variableSizeSlice;
            offset = variableSizeOffset;
        }
        payload.getBytes(0, bytes, offset, length);
    }
}
