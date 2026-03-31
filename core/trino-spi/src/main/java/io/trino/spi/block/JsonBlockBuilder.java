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
package io.trino.spi.block;

import io.airlift.slice.Slice;
import jakarta.annotation.Nullable;

import java.util.Arrays;

import static io.airlift.slice.SizeOf.instanceSize;
import static io.airlift.slice.SizeOf.sizeOf;
import static java.util.Objects.checkIndex;
import static java.util.Objects.requireNonNull;

public class JsonBlockBuilder
        implements BlockBuilder
{
    private static final int INSTANCE_SIZE = instanceSize(JsonBlockBuilder.class);
    private static final int JSON_ENTRY_SIZE = Integer.BYTES + Byte.BYTES;
    private static final JsonBlock NULL_VALUE_BLOCK = JsonBlock.createInternal(
            0,
            1,
            new boolean[] {true},
            VariableWidthBlockBuilder.NULL_VALUE_BLOCK);

    @Nullable
    private final BlockBuilderStatus blockBuilderStatus;

    private int positionCount;
    private boolean[] jsonIsNull;
    private final VariableWidthBlockBuilder parsedItemBlockBuilder;

    private boolean hasNullJson;
    private boolean hasNonNullJson;

    public JsonBlockBuilder(BlockBuilderStatus blockBuilderStatus, int expectedEntries)
    {
        this(blockBuilderStatus, expectedEntries, expectedEntries * 32);
    }

    public JsonBlockBuilder(BlockBuilderStatus blockBuilderStatus, int expectedEntries, int expectedParsedItemBytes)
    {
        this(
                blockBuilderStatus,
                new VariableWidthBlockBuilder(blockBuilderStatus, expectedEntries, expectedParsedItemBytes),
                new boolean[expectedEntries]);
    }

    private JsonBlockBuilder(
            @Nullable BlockBuilderStatus blockBuilderStatus,
            VariableWidthBlockBuilder parsedItemBlockBuilder,
            boolean[] jsonIsNull)
    {
        this.blockBuilderStatus = blockBuilderStatus;
        this.positionCount = 0;
        this.jsonIsNull = requireNonNull(jsonIsNull, "jsonIsNull is null");
        this.parsedItemBlockBuilder = requireNonNull(parsedItemBlockBuilder, "parsedItemBlockBuilder is null");
    }

    @Override
    public int getPositionCount()
    {
        return positionCount;
    }

    @Override
    public long getSizeInBytes()
    {
        long sizeInBytes = JSON_ENTRY_SIZE * (long) positionCount;
        sizeInBytes += parsedItemBlockBuilder.getSizeInBytes();
        return sizeInBytes;
    }

    @Override
    public long getRetainedSizeInBytes()
    {
        long size = INSTANCE_SIZE + sizeOf(jsonIsNull);
        size += parsedItemBlockBuilder.getRetainedSizeInBytes();
        if (blockBuilderStatus != null) {
            size += BlockBuilderStatus.INSTANCE_SIZE;
        }
        return size;
    }

    public void writeEntry(Slice parsedItem)
    {
        parsedItemBlockBuilder.writeEntry(parsedItem);
        entryAdded(false);
    }

    @Override
    public void append(ValueBlock block, int position)
    {
        JsonBlock jsonBlock = (JsonBlock) block;
        if (block.isNull(position)) {
            appendNull();
            return;
        }

        Block rawParsedItemBlock = jsonBlock.getRawParsedItem();
        int startOffset = jsonBlock.getOffsetBase();

        appendToField(rawParsedItemBlock, startOffset + position, parsedItemBlockBuilder);
        entryAdded(false);
    }

    private static void appendToField(Block fieldBlock, int position, BlockBuilder fieldBlockBuilder)
    {
        switch (fieldBlock) {
            case RunLengthEncodedBlock rleBlock -> fieldBlockBuilder.append(rleBlock.getValue(), 0);
            case DictionaryBlock dictionaryBlock -> fieldBlockBuilder.append(dictionaryBlock.getDictionary(), dictionaryBlock.getId(position));
            case ValueBlock valueBlock -> fieldBlockBuilder.append(valueBlock, position);
        }
    }

    @Override
    public void appendRange(ValueBlock block, int offset, int length)
    {
        if (length == 0) {
            return;
        }

        JsonBlock jsonBlock = (JsonBlock) block;
        ensureCapacity(positionCount + length);

        Block rawParsedItemBlock = jsonBlock.getRawParsedItem();
        int startOffset = jsonBlock.getOffsetBase();

        appendRangeToField(rawParsedItemBlock, startOffset + offset, length, parsedItemBlockBuilder);

        boolean[] rawJsonIsNull = jsonBlock.getRawIsNull();
        if (rawJsonIsNull != null) {
            for (int i = 0; i < length; i++) {
                boolean isNull = rawJsonIsNull[startOffset + offset + i];
                hasNullJson |= isNull;
                hasNonNullJson |= !isNull;
                if (hasNullJson & hasNonNullJson) {
                    System.arraycopy(rawJsonIsNull, startOffset + offset + i, jsonIsNull, positionCount + i, length - i);
                    break;
                }
                else {
                    jsonIsNull[positionCount + i] = isNull;
                }
            }
        }
        else {
            Arrays.fill(jsonIsNull, positionCount, positionCount + length, false);
            hasNonNullJson = true;
        }
        positionCount += length;

        if (blockBuilderStatus != null) {
            blockBuilderStatus.addBytes(JSON_ENTRY_SIZE * length);
        }
    }

    private static void appendRangeToField(Block fieldBlock, int offset, int length, BlockBuilder fieldBlockBuilder)
    {
        switch (fieldBlock) {
            case RunLengthEncodedBlock rleBlock -> fieldBlockBuilder.appendRepeated(rleBlock.getValue(), 0, length);
            case DictionaryBlock dictionaryBlock -> {
                int[] rawIds = dictionaryBlock.getRawIds();
                int rawIdsOffset = dictionaryBlock.getRawIdsOffset();
                fieldBlockBuilder.appendPositions(dictionaryBlock.getDictionary(), rawIds, rawIdsOffset + offset, length);
            }
            case ValueBlock valueBlock -> fieldBlockBuilder.appendRange(valueBlock, offset, length);
        }
    }

    @Override
    public void appendRepeated(ValueBlock block, int position, int count)
    {
        if (count == 0) {
            return;
        }

        JsonBlock jsonBlock = (JsonBlock) block;
        ensureCapacity(positionCount + count);

        Block rawParsedItemBlock = jsonBlock.getRawParsedItem();
        int startOffset = jsonBlock.getOffsetBase();

        appendRepeatedToField(rawParsedItemBlock, startOffset + position, count, parsedItemBlockBuilder);

        if (jsonBlock.isNull(position)) {
            Arrays.fill(jsonIsNull, positionCount, positionCount + count, true);
            hasNullJson = true;
        }
        else {
            Arrays.fill(jsonIsNull, positionCount, positionCount + count, false);
            hasNonNullJson = true;
        }

        positionCount += count;

        if (blockBuilderStatus != null) {
            blockBuilderStatus.addBytes(JSON_ENTRY_SIZE * count);
        }
    }

    private static void appendRepeatedToField(Block fieldBlock, int position, int count, BlockBuilder fieldBlockBuilder)
    {
        switch (fieldBlock) {
            case RunLengthEncodedBlock rleBlock -> fieldBlockBuilder.appendRepeated(rleBlock.getValue(), 0, count);
            case DictionaryBlock dictionaryBlock -> fieldBlockBuilder.appendRepeated(dictionaryBlock.getDictionary(), dictionaryBlock.getId(position), count);
            case ValueBlock valueBlock -> fieldBlockBuilder.appendRepeated(valueBlock, position, count);
        }
    }

    @Override
    public void appendPositions(ValueBlock block, int[] positions, int offset, int length)
    {
        if (length == 0) {
            return;
        }

        JsonBlock jsonBlock = (JsonBlock) block;
        ensureCapacity(positionCount + length);

        Block rawParsedItemBlock = jsonBlock.getRawParsedItem();
        int startOffset = jsonBlock.getOffsetBase();

        if (startOffset == 0) {
            appendPositionsToField(rawParsedItemBlock, positions, offset, length, parsedItemBlockBuilder);
        }
        else {
            int[] adjustedPositions = new int[length];
            for (int i = offset; i < offset + length; i++) {
                adjustedPositions[i - offset] = startOffset + positions[i];
            }

            appendPositionsToField(rawParsedItemBlock, adjustedPositions, 0, length, parsedItemBlockBuilder);
        }

        boolean[] rawJsonIsNull = jsonBlock.getRawIsNull();
        if (rawJsonIsNull != null) {
            for (int i = 0; i < length; i++) {
                if (rawJsonIsNull[startOffset + positions[offset + i]]) {
                    jsonIsNull[positionCount + i] = true;
                    hasNullJson = true;
                }
                else {
                    jsonIsNull[positionCount + i] = false;
                    hasNonNullJson = true;
                }
            }
        }
        else {
            Arrays.fill(jsonIsNull, positionCount, positionCount + length, false);
            hasNonNullJson = true;
        }
        positionCount += length;

        if (blockBuilderStatus != null) {
            blockBuilderStatus.addBytes(JSON_ENTRY_SIZE * length);
        }
    }

    private static void appendPositionsToField(Block fieldBlock, int[] positions, int offset, int length, BlockBuilder fieldBlockBuilder)
    {
        switch (fieldBlock) {
            case RunLengthEncodedBlock rleBlock -> fieldBlockBuilder.appendRepeated(rleBlock.getValue(), 0, length);
            case DictionaryBlock dictionaryBlock -> {
                int[] newPositions = new int[length];
                for (int i = 0; i < newPositions.length; i++) {
                    newPositions[i] = dictionaryBlock.getId(positions[offset + i]);
                }
                fieldBlockBuilder.appendPositions(dictionaryBlock.getDictionary(), newPositions, 0, length);
            }
            case ValueBlock valueBlock -> fieldBlockBuilder.appendPositions(valueBlock, positions, offset, length);
        }
    }

    @Override
    public BlockBuilder appendNull()
    {
        parsedItemBlockBuilder.appendNull();
        entryAdded(true);
        return this;
    }

    @Override
    public void resetTo(int position)
    {
        checkIndex(position, positionCount + 1);
        positionCount = position;
        parsedItemBlockBuilder.resetTo(position);

        if (position == 0) {
            hasNullJson = false;
            hasNonNullJson = false;
            return;
        }

        hasNullJson = false;
        hasNonNullJson = false;
        for (int index = 0; index < position; index++) {
            hasNullJson |= jsonIsNull[index];
            hasNonNullJson |= !jsonIsNull[index];
        }
    }

    private void entryAdded(boolean isNull)
    {
        ensureCapacity(positionCount + 1);

        jsonIsNull[positionCount] = isNull;
        hasNullJson |= isNull;
        hasNonNullJson |= !isNull;
        positionCount++;

        if (blockBuilderStatus != null) {
            blockBuilderStatus.addBytes(JSON_ENTRY_SIZE);
        }
    }

    @Override
    public Block build()
    {
        if (!hasNonNullJson) {
            return RunLengthEncodedBlock.create(NULL_VALUE_BLOCK, positionCount);
        }
        return buildValueBlock();
    }

    @Override
    public JsonBlock buildValueBlock()
    {
        Block parsedItemBlock = parsedItemBlockBuilder.buildValueBlock();
        return JsonBlock.createInternal(0, positionCount, hasNullJson ? jsonIsNull : null, parsedItemBlock);
    }

    private void ensureCapacity(int capacity)
    {
        if (jsonIsNull.length >= capacity) {
            return;
        }

        int newSize = BlockUtil.calculateNewArraySize(jsonIsNull.length, capacity);
        jsonIsNull = Arrays.copyOf(jsonIsNull, newSize);
    }

    @Override
    public String toString()
    {
        return "JsonBlockBuilder{parsedItemBlockBuilder=%s}".formatted(parsedItemBlockBuilder);
    }

    @Override
    public BlockBuilder newBlockBuilderLike(int expectedEntries, BlockBuilderStatus blockBuilderStatus)
    {
        return new JsonBlockBuilder(
                blockBuilderStatus,
                (VariableWidthBlockBuilder) parsedItemBlockBuilder.newBlockBuilderLike(blockBuilderStatus),
                new boolean[expectedEntries]);
    }
}
