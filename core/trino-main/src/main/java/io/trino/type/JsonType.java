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
import io.airlift.slice.XxHash64;
import io.trino.json.JsonItemSemantics;
import io.trino.json.JsonItems;
import io.trino.json.JsonValue;
import io.trino.json.JsonValueView;
import io.trino.plugin.base.util.JsonTypeUtil;
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
        return JsonTypeEncoding.decodeText(payload).toStringUtf8();
    }

    @Override
    public Slice getSlice(Block block, int position)
    {
        JsonBlock valueBlock = (JsonBlock) block.getUnderlyingValueBlock();
        int valuePosition = block.getUnderlyingValuePosition(position);
        return getPayload(valueBlock, valuePosition);
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
        Slice jsonValue = value.slice(offset, length);
        Slice encoded = JsonTypeEncoding.isEncodedValue(jsonValue) ? jsonValue : JsonTypeEncoding.encode(jsonValue);
        ((JsonBlockBuilder) blockBuilder).writeEntry(storagePayload(encoded));
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
        Slice parsedItem = jsonBlock.getParsedItemSlice(valuePosition);
        return parsedItem.length();
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
        Slice payload = getFlatPayload(fixedSizeSlice, fixedSizeOffset, variableSizeSlice, variableSizeOffset);
        ((JsonBlockBuilder) blockBuilder).writeEntry(storagePayload(payload));
    }

    @ScalarOperator(READ_VALUE)
    private static void writeFlatFromStack(
            Slice value,
            @FlatFixed byte[] fixedSizeSlice,
            @FlatFixedOffset int fixedSizeOffset,
            @FlatVariableWidth byte[] variableSizeSlice,
            @FlatVariableOffset int variableSizeOffset)
    {
        Slice payload = JsonTypeEncoding.isEncodedValue(value) ? value : JsonTypeEncoding.encode(value);
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
        Slice payload = getPayload(block, position);
        writeFlatPayload(payload, fixedSizeSlice, fixedSizeOffset, variableSizeSlice, variableSizeOffset);
    }

    @ScalarOperator(EQUAL)
    private static boolean equalOperator(Slice left, Slice right)
    {
        return jsonEquals(left, right);
    }

    @ScalarOperator(EQUAL)
    private static boolean equalOperator(@BlockPosition JsonBlock leftBlock, @BlockIndex int leftPosition, @BlockPosition JsonBlock rightBlock, @BlockIndex int rightPosition)
    {
        return jsonEquals(leftBlock, leftPosition, rightBlock, rightPosition);
    }

    @ScalarOperator(EQUAL)
    private static boolean equalOperator(Slice left, @BlockPosition JsonBlock rightBlock, @BlockIndex int rightPosition)
    {
        return jsonEqualsEncoded(payloadForComparison(left), rightBlock.getParsedItemSlice(rightPosition));
    }

    @ScalarOperator(EQUAL)
    private static boolean equalOperator(@BlockPosition JsonBlock leftBlock, @BlockIndex int leftPosition, Slice right)
    {
        return jsonEqualsEncoded(leftBlock.getParsedItemSlice(leftPosition), payloadForComparison(right));
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
        return jsonEqualsEncoded(
                payloadForComparison(getFlatPayload(leftFixedSizeSlice, leftFixedSizeOffset, leftVariableSizeSlice, leftVariableSizeOffset)),
                payloadForComparison(getFlatPayload(rightFixedSizeSlice, rightFixedSizeOffset, rightVariableSizeSlice, rightVariableSizeOffset)));
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
        Slice left = getFlatPayload(leftFixedSizeSlice, leftFixedSizeOffset, leftVariableSizeSlice, leftVariableSizeOffset);
        return jsonEqualsEncoded(payloadForComparison(left), rightBlock.getParsedItemSlice(rightPosition));
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
        Slice right = getFlatPayload(rightFixedSizeSlice, rightFixedSizeOffset, rightVariableSizeSlice, rightVariableSizeOffset);
        return jsonEqualsEncoded(leftBlock.getParsedItemSlice(leftPosition), payloadForComparison(right));
    }

    @ScalarOperator(XX_HASH_64)
    private static long xxHash64Operator(Slice value)
    {
        return jsonHash(value);
    }

    @ScalarOperator(XX_HASH_64)
    private static long xxHash64Operator(@BlockPosition JsonBlock block, @BlockIndex int position)
    {
        return jsonHashEncoded(block.getParsedItemSlice(position));
    }

    @ScalarOperator(XX_HASH_64)
    private static long xxHash64Operator(
            @FlatFixed byte[] fixedSizeSlice,
            @FlatFixedOffset int fixedSizeOffset,
            @FlatVariableWidth byte[] variableSizeSlice,
            @FlatVariableOffset int variableSizeOffset)
    {
        return jsonHash(getFlatPayload(fixedSizeSlice, fixedSizeOffset, variableSizeSlice, variableSizeOffset));
    }

    public static Slice jsonText(Slice value)
    {
        return JsonTypeEncoding.decodeText(value);
    }

    public static JsonValue jsonItem(Slice value)
    {
        return JsonTypeEncoding.decodeItem(value);
    }

    public static boolean hasParsedItem(Slice value)
    {
        return JsonTypeEncoding.hasParsedItem(value);
    }

    public static Slice jsonValue(Slice jsonText)
    {
        return JsonTypeEncoding.isEncodedValue(jsonText) ? jsonText : JsonTypeEncoding.encode(jsonText);
    }

    public static Slice jsonValue(JsonValue item)
    {
        return JsonTypeEncoding.encode(item);
    }

    public static Slice legacyJsonValue(Slice jsonText)
    {
        return JsonTypeEncoding.encodeLegacy(jsonText);
    }

    public static Slice standardJsonValue(Slice jsonText)
    {
        try {
            JsonValue item = JsonItems.parseJson(new InputStreamReader(jsonText.getInput(), StandardCharsets.UTF_8));
            return standardJsonValue(item);
        }
        catch (IOException | RuntimeException e) {
            try {
                return legacyJsonValue(JsonTypeUtil.jsonParse(jsonText));
            }
            catch (RuntimeException ignored) {
            }
            throw new IllegalArgumentException("Invalid JSON text", e);
        }
    }

    public static Slice standardJsonValue(JsonValue item)
    {
        return jsonValue(item);
    }

    public static Slice stripParsedItem(Slice value)
    {
        return JsonTypeEncoding.stripParsedItem(value);
    }

    public static Slice encodeCanonicalText(Slice canonicalJsonText)
    {
        return JsonTypeEncoding.encodeRawTextForLegacy(canonicalJsonText);
    }

    public static Slice parsedItemEncoding(Slice value)
    {
        return JsonTypeEncoding.parsedItemEncoding(value);
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

    private static Slice getPayload(JsonBlock block, int position)
    {
        return block.getParsedItemSlice(position);
    }

    private static boolean jsonEquals(JsonBlock leftBlock, int leftPosition, JsonBlock rightBlock, int rightPosition)
    {
        return jsonEqualsEncoded(leftBlock.getParsedItemSlice(leftPosition), rightBlock.getParsedItemSlice(rightPosition));
    }

    private static boolean jsonEquals(Slice left, Slice right)
    {
        if (!JsonTypeEncoding.hasParsedItem(left) || !JsonTypeEncoding.hasParsedItem(right)) {
            return JsonTypeEncoding.decodeText(left).equals(JsonTypeEncoding.decodeText(right));
        }
        return jsonEqualsEncoded(payloadForComparison(left), payloadForComparison(right));
    }

    private static boolean jsonEqualsEncoded(Slice leftParsedItem, Slice rightParsedItem)
    {
        if (!JsonTypeEncoding.hasParsedItem(leftParsedItem) || !JsonTypeEncoding.hasParsedItem(rightParsedItem)) {
            return JsonTypeEncoding.decodeText(leftParsedItem).equals(JsonTypeEncoding.decodeText(rightParsedItem));
        }
        return JsonItemSemantics.equals(JsonValueView.root(leftParsedItem), JsonValueView.root(rightParsedItem));
    }

    private static long jsonHash(Slice value)
    {
        if (!JsonTypeEncoding.hasParsedItem(value)) {
            return XxHash64.hash(JsonTypeEncoding.decodeText(value));
        }
        return jsonHashEncoded(parsedItemEncoding(value));
    }

    private static long jsonHashEncoded(Slice parsedItem)
    {
        if (!JsonTypeEncoding.hasParsedItem(parsedItem)) {
            return XxHash64.hash(JsonTypeEncoding.decodeText(parsedItem));
        }
        return JsonItemSemantics.hash(JsonValueView.root(parsedItem));
    }

    private static Slice storagePayload(Slice value)
    {
        if (JsonTypeEncoding.hasParsedItem(value)) {
            return parsedItemEncoding(value);
        }
        return value;
    }

    private static Slice payloadForComparison(Slice value)
    {
        return JsonTypeEncoding.hasParsedItem(value) ? parsedItemEncoding(value) : value;
    }
}
