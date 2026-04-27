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
import io.trino.spi.block.Block;
import io.trino.spi.block.BlockBuilder;
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
import io.trino.spi.type.JsonValue;
import io.trino.spi.type.TypeOperatorDeclaration;
import io.trino.spi.type.TypeOperators;
import io.trino.spi.type.TypeSignature;

import java.lang.invoke.MethodHandles;
import java.lang.invoke.VarHandle;
import java.nio.ByteOrder;

import static io.airlift.slice.Slices.wrappedBuffer;
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
    private static final int MAX_SHORT_FLAT_LENGTH = 3;
    private static final VarHandle INT_BE_HANDLE = MethodHandles.byteArrayViewVarHandle(int[].class, ByteOrder.BIG_ENDIAN);
    private static final TypeOperatorDeclaration TYPE_OPERATOR_DECLARATION = extractOperatorDeclaration(JsonType.class, lookup(), JsonValue.class);

    public static final JsonType JSON = new JsonType();

    private JsonType()
    {
        super(new TypeSignature(NAME), JsonValue.class);
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
    public Object getObject(Block block, int position)
    {
        if (block.isNull(position)) {
            return null;
        }
        return JsonValue.of(getSlice(block, position));
    }

    @Override
    public void writeObject(BlockBuilder blockBuilder, Object value)
    {
        writeSlice(blockBuilder, ((JsonValue) value).payload());
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
    private static JsonValue readFlatToStack(
            @FlatFixed byte[] fixedSizeSlice,
            @FlatFixedOffset int fixedSizeOffset,
            @FlatVariableWidth byte[] variableSizeSlice,
            @FlatVariableOffset int variableSizeOffset)
    {
        return JsonValue.of(getFlatSlice(fixedSizeSlice, fixedSizeOffset, variableSizeSlice, variableSizeOffset));
    }

    @ScalarOperator(READ_VALUE)
    private static void readFlatToBlock(
            @FlatFixed byte[] fixedSizeSlice,
            @FlatFixedOffset int fixedSizeOffset,
            @FlatVariableWidth byte[] variableSizeSlice,
            @FlatVariableOffset int variableSizeOffset,
            BlockBuilder blockBuilder)
    {
        ((VariableWidthBlockBuilder) blockBuilder).writeEntry(getFlatSlice(fixedSizeSlice, fixedSizeOffset, variableSizeSlice, variableSizeOffset));
    }

    @ScalarOperator(READ_VALUE)
    private static void writeFlatFromStack(
            JsonValue value,
            @FlatFixed byte[] fixedSizeSlice,
            @FlatFixedOffset int fixedSizeOffset,
            @FlatVariableWidth byte[] variableSizeSlice,
            @FlatVariableOffset int variableSizeOffset)
    {
        Slice payload = value.payload();
        int length = payload.length();
        writeFlatLength(length, fixedSizeSlice, fixedSizeOffset);
        if (length <= MAX_SHORT_FLAT_LENGTH) {
            payload.getBytes(0, fixedSizeSlice, fixedSizeOffset + 1, length);
        }
        else {
            payload.getBytes(0, variableSizeSlice, variableSizeOffset, length);
        }
    }

    @ScalarOperator(READ_VALUE)
    private static void writeFlatFromBlock(
            @BlockPosition VariableWidthBlock block,
            @BlockIndex int position,
            @FlatFixed byte[] fixedSizeSlice,
            @FlatFixedOffset int fixedSizeOffset,
            @FlatVariableWidth byte[] variableSizeSlice,
            @FlatVariableOffset int variableSizeOffset)
    {
        Slice rawSlice = block.getRawSlice();
        int rawSliceOffset = block.getRawSliceOffset(position);
        int length = block.getSliceLength(position);

        writeFlatLength(length, fixedSizeSlice, fixedSizeOffset);
        if (length <= MAX_SHORT_FLAT_LENGTH) {
            rawSlice.getBytes(rawSliceOffset, fixedSizeSlice, fixedSizeOffset + 1, length);
        }
        else {
            rawSlice.getBytes(rawSliceOffset, variableSizeSlice, variableSizeOffset, length);
        }
    }

    @ScalarOperator(EQUAL)
    private static boolean equalOperator(JsonValue left, JsonValue right)
    {
        return left.payload().equals(right.payload());
    }

    @ScalarOperator(EQUAL)
    private static boolean equalOperator(@BlockPosition VariableWidthBlock leftBlock, @BlockIndex int leftPosition, @BlockPosition VariableWidthBlock rightBlock, @BlockIndex int rightPosition)
    {
        Slice leftRawSlice = leftBlock.getRawSlice();
        int leftRawSliceOffset = leftBlock.getRawSliceOffset(leftPosition);
        int leftLength = leftBlock.getSliceLength(leftPosition);

        Slice rightRawSlice = rightBlock.getRawSlice();
        int rightRawSliceOffset = rightBlock.getRawSliceOffset(rightPosition);
        int rightLength = rightBlock.getSliceLength(rightPosition);

        return leftRawSlice.equals(leftRawSliceOffset, leftLength, rightRawSlice, rightRawSliceOffset, rightLength);
    }

    @ScalarOperator(EQUAL)
    private static boolean equalOperator(JsonValue left, @BlockPosition VariableWidthBlock rightBlock, @BlockIndex int rightPosition)
    {
        return equalOperator(rightBlock, rightPosition, left);
    }

    @ScalarOperator(EQUAL)
    private static boolean equalOperator(@BlockPosition VariableWidthBlock leftBlock, @BlockIndex int leftPosition, JsonValue right)
    {
        Slice leftRawSlice = leftBlock.getRawSlice();
        int leftRawSliceOffset = leftBlock.getRawSliceOffset(leftPosition);
        int leftLength = leftBlock.getSliceLength(leftPosition);

        Slice rightPayload = right.payload();
        return leftRawSlice.equals(leftRawSliceOffset, leftLength, rightPayload, 0, rightPayload.length());
    }

    @ScalarOperator(XX_HASH_64)
    private static long xxHash64Operator(JsonValue value)
    {
        return XxHash64.hash(value.payload());
    }

    @ScalarOperator(XX_HASH_64)
    private static long xxHash64Operator(@BlockPosition VariableWidthBlock block, @BlockIndex int position)
    {
        return XxHash64.hash(block.getRawSlice(), block.getRawSliceOffset(position), block.getSliceLength(position));
    }

    private static Slice getFlatSlice(
            byte[] fixedSizeSlice,
            int fixedSizeOffset,
            byte[] variableSizeSlice,
            int variableSizeOffset)
    {
        int length = readFlatLength(fixedSizeSlice, fixedSizeOffset);
        if (length <= MAX_SHORT_FLAT_LENGTH) {
            return wrappedBuffer(fixedSizeSlice, fixedSizeOffset + 1, length);
        }
        return wrappedBuffer(variableSizeSlice, variableSizeOffset, length);
    }

    private static int readFlatLength(byte[] fixedSizeSlice, int fixedSizeOffset)
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

    private static void writeFlatLength(int length, byte[] fixedSizeSlice, int fixedSizeOffset)
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
}
