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
import io.trino.json.JsonInputErrorNode;
import io.trino.json.JsonItemEncoding;
import io.trino.json.JsonItemSemantics;
import io.trino.json.JsonItems;
import io.trino.json.JsonValueView;
import io.trino.json.MaterializedJsonValue;
import io.trino.spi.block.Block;
import io.trino.spi.block.BlockBuilder;
import io.trino.spi.block.BlockBuilderStatus;
import io.trino.spi.block.JsonBlock;
import io.trino.spi.block.JsonBlockBuilder;
import io.trino.spi.block.PageBuilderStatus;
import io.trino.spi.block.ValueBlock;
import io.trino.spi.block.VariableWidthBlock;
import io.trino.spi.function.BlockIndex;
import io.trino.spi.function.BlockPosition;
import io.trino.spi.function.FlatFixed;
import io.trino.spi.function.FlatFixedOffset;
import io.trino.spi.function.FlatVariableOffset;
import io.trino.spi.function.FlatVariableWidth;
import io.trino.spi.function.ScalarOperator;
import io.trino.spi.type.AbstractType;
import io.trino.spi.type.JsonValue;
import io.trino.spi.type.TypeOperatorDeclaration;
import io.trino.spi.type.TypeOperators;
import io.trino.spi.type.TypeSignature;
import io.trino.spi.type.VariableWidthType;

import java.io.IOException;
import java.io.InputStreamReader;
import java.io.Reader;
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
    private static final TypeOperatorDeclaration TYPE_OPERATOR_DECLARATION = extractOperatorDeclaration(JsonType.class, lookup(), JsonValue.class);
    private static final VarHandle INT_BE_HANDLE = MethodHandles.byteArrayViewVarHandle(int[].class, ByteOrder.BIG_ENDIAN);
    private static final int MAX_SHORT_FLAT_LENGTH = 3;
    private static final int EXPECTED_BYTES_PER_ENTRY = 32;

    public static final JsonType JSON = new JsonType();

    private JsonType()
    {
        super(new TypeSignature(NAME), JsonValue.class, JsonBlock.class);
    }

    /// JSON columns may arrive in two physical forms:
    /// - {@link JsonBlock} — produced internally by the path engine and
    ///   {@link JsonBlockBuilder}; carries the typed-item encoding plus a lazy parse cache.
    /// - {@link VariableWidthBlock} — produced by connector readers (Parquet, ORC, JDBC, …)
    ///   that don't know about JsonBlock; carries raw JSON text.
    ///
    /// Returning the abstract supertype lets {@link io.trino.operator.PageValidations} accept
    /// either form without per-connector adjustments. Accessor methods below normalize the
    /// two forms by extracting the payload {@link Slice} (raw text or typed encoding); the
    /// downstream JSON code handles either via {@link JsonItemEncoding#isEncoding(Slice)}.
    @Override
    public Class<? extends ValueBlock> getValueBlockType()
    {
        return ValueBlock.class;
    }

    @Override
    public Object getObject(Block block, int position)
    {
        if (block.isNull(position)) {
            return null;
        }
        return JsonValue.of(payloadSlice(block, position));
    }

    @Override
    public void writeObject(BlockBuilder blockBuilder, Object value)
    {
        writeSlice(blockBuilder, ((JsonValue) value).payload());
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

        Slice payload = payloadSlice(block, position);
        if (JsonItemEncoding.isJsonError(payload)) {
            return JsonInputErrorNode.JSON_ERROR;
        }
        // Use the surrogate-text path so typed scalars without a native JSON representation
        // (datetimes, etc.) render as quoted text rather than failing. Raw text payloads
        // (lazy-parse path) bypass decode entirely.
        return jsonText(payload).toStringUtf8();
    }

    @Override
    public Slice getSlice(Block block, int position)
    {
        return payloadSlice(block, position);
    }

    /// Reads the JSON payload bytes at the given position from either physical block form.
    /// Returns the typed-item encoding for {@link JsonBlock}, or the raw JSON text for
    /// {@link VariableWidthBlock} (the form produced by connector readers).
    private static Slice payloadSlice(Block block, int position)
    {
        ValueBlock valueBlock = block.getUnderlyingValueBlock();
        int valuePosition = block.getUnderlyingValuePosition(position);
        return payloadSlice(valueBlock, valuePosition);
    }

    private static Slice payloadSlice(ValueBlock valueBlock, int position)
    {
        if (valueBlock instanceof JsonBlock jsonBlock) {
            return jsonBlock.getParsedItemSlice(position);
        }
        if (valueBlock instanceof VariableWidthBlock variableWidthBlock) {
            if (variableWidthBlock.isNull(position)) {
                return null;
            }
            return variableWidthBlock.getSlice(position);
        }
        throw new IllegalArgumentException("Unsupported JSON value block: " + valueBlock.getClass().getName());
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
        // Raw JSON text is stored verbatim; the typed-item encoding is only materialized when
        // an operator (path engine, equality, hash, getObjectValue with non-textable scalars)
        // actually inspects the structure.
        ((JsonBlockBuilder) blockBuilder).writeEntry(value.slice(offset, length));
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
        return payloadSlice(block, position).length();
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
    private static JsonValue readFlatToStack(
            @FlatFixed byte[] fixedSizeSlice,
            @FlatFixedOffset int fixedSizeOffset,
            @FlatVariableWidth byte[] variableSizeSlice,
            @FlatVariableOffset int variableSizeOffset)
    {
        return JsonValue.of(getFlatPayload(fixedSizeSlice, fixedSizeOffset, variableSizeSlice, variableSizeOffset));
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
            JsonValue value,
            @FlatFixed byte[] fixedSizeSlice,
            @FlatFixedOffset int fixedSizeOffset,
            @FlatVariableWidth byte[] variableSizeSlice,
            @FlatVariableOffset int variableSizeOffset)
    {
        // Lazy-parse: store payload bytes as-is regardless of form (raw text or typed encoding).
        writeFlatPayload(value.payload(), fixedSizeSlice, fixedSizeOffset, variableSizeSlice, variableSizeOffset);
    }

    @ScalarOperator(READ_VALUE)
    private static void writeFlatFromBlock(
            @BlockPosition ValueBlock block,
            @BlockIndex int position,
            @FlatFixed byte[] fixedSizeSlice,
            @FlatFixedOffset int fixedSizeOffset,
            @FlatVariableWidth byte[] variableSizeSlice,
            @FlatVariableOffset int variableSizeOffset)
    {
        writeFlatPayload(payloadSlice(block, position), fixedSizeSlice, fixedSizeOffset, variableSizeSlice, variableSizeOffset);
    }

    @ScalarOperator(EQUAL)
    private static boolean equalOperator(JsonValue left, JsonValue right)
    {
        return slicesEqualOrSemanticallyEqual(left.payload(), right.payload());
    }

    @ScalarOperator(EQUAL)
    private static boolean equalOperator(@BlockPosition ValueBlock leftBlock, @BlockIndex int leftPosition, @BlockPosition ValueBlock rightBlock, @BlockIndex int rightPosition)
    {
        return slicesEqualOrSemanticallyEqual(
                payloadSlice(leftBlock, leftPosition),
                payloadSlice(rightBlock, rightPosition));
    }

    @ScalarOperator(EQUAL)
    private static boolean equalOperator(JsonValue left, @BlockPosition ValueBlock rightBlock, @BlockIndex int rightPosition)
    {
        return slicesEqualOrSemanticallyEqual(left.payload(), payloadSlice(rightBlock, rightPosition));
    }

    @ScalarOperator(EQUAL)
    private static boolean equalOperator(@BlockPosition ValueBlock leftBlock, @BlockIndex int leftPosition, JsonValue right)
    {
        return slicesEqualOrSemanticallyEqual(payloadSlice(leftBlock, leftPosition), right.payload());
    }

    private static boolean slicesEqualOrSemanticallyEqual(Slice left, Slice right)
    {
        // Byte-equal payloads are always semantically equal — same canonical text or same
        // typed encoding. Common case for column-vs-constant filters when the connector's
        // serialization matches the constant's.
        if (left.equals(right)) {
            return true;
        }
        return JsonItemSemantics.equals(JsonValueView.root(left), JsonValueView.root(right));
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
        return slicesEqualOrSemanticallyEqual(
                getFlatPayload(leftFixedSizeSlice, leftFixedSizeOffset, leftVariableSizeSlice, leftVariableSizeOffset),
                getFlatPayload(rightFixedSizeSlice, rightFixedSizeOffset, rightVariableSizeSlice, rightVariableSizeOffset));
    }

    @ScalarOperator(EQUAL)
    private static boolean equalOperator(
            @FlatFixed byte[] leftFixedSizeSlice,
            @FlatFixedOffset int leftFixedSizeOffset,
            @FlatVariableWidth byte[] leftVariableSizeSlice,
            @FlatVariableOffset int leftVariableSizeOffset,
            @BlockPosition ValueBlock rightBlock,
            @BlockIndex int rightPosition)
    {
        return slicesEqualOrSemanticallyEqual(
                getFlatPayload(leftFixedSizeSlice, leftFixedSizeOffset, leftVariableSizeSlice, leftVariableSizeOffset),
                payloadSlice(rightBlock, rightPosition));
    }

    @ScalarOperator(EQUAL)
    private static boolean equalOperator(
            @BlockPosition ValueBlock leftBlock,
            @BlockIndex int leftPosition,
            @FlatFixed byte[] rightFixedSizeSlice,
            @FlatFixedOffset int rightFixedSizeOffset,
            @FlatVariableWidth byte[] rightVariableSizeSlice,
            @FlatVariableOffset int rightVariableSizeOffset)
    {
        return slicesEqualOrSemanticallyEqual(
                payloadSlice(leftBlock, leftPosition),
                getFlatPayload(rightFixedSizeSlice, rightFixedSizeOffset, rightVariableSizeSlice, rightVariableSizeOffset));
    }

    @ScalarOperator(XX_HASH_64)
    private static long xxHash64Operator(JsonValue value)
    {
        return JsonItemSemantics.hash(JsonValueView.root(value.payload()));
    }

    @ScalarOperator(XX_HASH_64)
    private static long xxHash64Operator(@BlockPosition ValueBlock block, @BlockIndex int position)
    {
        return JsonItemSemantics.hash(JsonValueView.root(payloadSlice(block, position)));
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

    /// Renders the canonical JSON text of a {@link JsonType} payload. Accepts either the
    /// typed-item encoding produced by {@link #jsonValue} or raw JSON text. Typed scalars
    /// without a native JSON representation (datetimes, etc.) render as quoted text using
    /// their canonical SQL form.
    public static Slice jsonText(Slice value)
    {
        if (JsonItemEncoding.isEncoding(value)) {
            return JsonItems.surrogateJsonText(JsonItemEncoding.decode(value));
        }
        return value;
    }

    /// Decodes a {@link JsonType} payload to a materialized {@link MaterializedJsonValue}. Accepts
    /// either the typed-item encoding or raw JSON text (parsed on demand).
    public static MaterializedJsonValue jsonItem(Slice value)
    {
        if (JsonItemEncoding.isEncoding(value)) {
            return JsonItemEncoding.decodeValue(value);
        }
        return jsonValueFromText(value);
    }

    private static MaterializedJsonValue jsonValueFromText(Slice jsonText)
    {
        try {
            return JsonItems.parseJson(textReader(jsonText));
        }
        catch (IOException | RuntimeException e) {
            throw new IllegalArgumentException("Invalid JSON text", e);
        }
    }

    private static Reader textReader(Slice jsonText)
    {
        // For short inputs, StringReader avoids the 8 KB internal buffer InputStreamReader
        // allocates, which otherwise dominates parse time for typical JSON values.
        if (jsonText.length() < SMALL_TEXT_LIMIT) {
            return Reader.of(jsonText.toStringUtf8());
        }
        return new InputStreamReader(jsonText.getInput(), StandardCharsets.UTF_8);
    }

    private static final int SMALL_TEXT_LIMIT = 4096;

    /// Encodes raw JSON text as a {@link JsonType} payload. If the input is already an
    /// encoded payload, it is returned unchanged. Throws {@link IllegalArgumentException}
    /// if the text is not valid JSON or cannot be represented in the typed SQL/JSON item
    /// model.
    public static Slice jsonValue(Slice jsonText)
    {
        if (JsonItemEncoding.isEncoding(jsonText)) {
            return jsonText;
        }
        try {
            return JsonItems.parseJsonToEncoding(textReader(jsonText));
        }
        catch (IOException | RuntimeException e) {
            throw new IllegalArgumentException("Invalid JSON text", e);
        }
    }

    /// Encodes a materialized {@link MaterializedJsonValue} as a {@link JsonType} payload.
    public static Slice jsonValue(MaterializedJsonValue item)
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
