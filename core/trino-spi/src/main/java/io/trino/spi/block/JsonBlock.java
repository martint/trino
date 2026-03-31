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

import java.util.Optional;
import java.util.function.ObjLongConsumer;

import static io.airlift.slice.SizeOf.instanceSize;
import static io.airlift.slice.SizeOf.sizeOf;
import static io.trino.spi.block.BlockUtil.checkArrayRange;
import static io.trino.spi.block.BlockUtil.checkReadablePosition;
import static io.trino.spi.block.BlockUtil.checkValidRegion;
import static io.trino.spi.block.BlockUtil.compactArray;
import static java.util.Objects.requireNonNull;

public final class JsonBlock
        implements ValueBlock
{
    private static final int INSTANCE_SIZE = instanceSize(JsonBlock.class);

    private final int startOffset;
    private final int positionCount;
    @Nullable
    private final boolean[] isNull;
    /**
     * Parsed-item block has the same position count as this JSON block. The parsed-item field value of a null JSON
     * must be null.
     */
    private final Block parsedItem;

    private volatile long sizeInBytes = -1;
    private volatile long retainedSizeInBytes = -1;

    public static JsonBlock create(int positionCount, Block parsedItem, Optional<boolean[]> isNullOptional)
    {
        if (isNullOptional.isPresent()) {
            boolean[] isNull = isNullOptional.get();
            checkArrayRange(isNull, 0, positionCount);
            verifyPositionsAreNull(parsedItem, isNull, positionCount, "Parsed-item");
        }

        return createInternal(0, positionCount, isNullOptional.orElse(null), parsedItem);
    }

    private static void verifyPositionsAreNull(Block block, boolean[] isNull, int positionCount, String name)
    {
        for (int position = 0; position < positionCount; position++) {
            if (isNull[position] && !block.isNull(position)) {
                throw new IllegalArgumentException("%s for null JSON must be null: position %d".formatted(name, position));
            }
        }
    }

    static JsonBlock createInternal(int startOffset, int positionCount, @Nullable boolean[] isNull, Block parsedItem)
    {
        return new JsonBlock(startOffset, positionCount, isNull, parsedItem);
    }

    private JsonBlock(int startOffset, int positionCount, @Nullable boolean[] isNull, Block parsedItem)
    {
        if (startOffset < 0) {
            throw new IllegalArgumentException("startOffset is negative");
        }
        if (positionCount < 0) {
            throw new IllegalArgumentException("positionCount is negative");
        }
        if (isNull != null && isNull.length - startOffset < positionCount) {
            throw new IllegalArgumentException("isNull length is less than positionCount");
        }
        requireNonNull(parsedItem, "parsedItem is null");
        if (parsedItem.getPositionCount() - startOffset < positionCount) {
            throw new IllegalArgumentException("fieldBlock length is less than positionCount");
        }

        this.startOffset = startOffset;
        this.positionCount = positionCount;
        this.isNull = positionCount == 0 ? null : isNull;
        this.parsedItem = parsedItem;
    }

    public Block getParsedItem()
    {
        if ((startOffset == 0) && (parsedItem.getPositionCount() == positionCount)) {
            return parsedItem;
        }
        return parsedItem.getRegion(startOffset, positionCount);
    }

    public int getRawOffset()
    {
        return startOffset;
    }

    public Block getRawParsedItem()
    {
        return parsedItem;
    }

    public int getOffsetBase()
    {
        return startOffset;
    }

    @Nullable
    public boolean[] getRawIsNull()
    {
        return isNull;
    }

    @Nullable
    public Slice getParsedItemSlice(int position)
    {
        checkReadablePosition(this, position);
        if (parsedItem.isNull(startOffset + position)) {
            return null;
        }
        return getSlice(parsedItem, startOffset + position);
    }

    private static Slice getSlice(Block block, int position)
    {
        VariableWidthBlock valueBlock = (VariableWidthBlock) block.getUnderlyingValueBlock();
        int valuePosition = block.getUnderlyingValuePosition(position);
        return valueBlock.getSlice(valuePosition);
    }

    @Override
    public boolean mayHaveNull()
    {
        return isNull != null;
    }

    @Override
    public boolean hasNull()
    {
        if (isNull == null) {
            return false;
        }
        for (int i = 0; i < positionCount; i++) {
            if (isNull[startOffset + i]) {
                return true;
            }
        }
        return false;
    }

    @Override
    public int getPositionCount()
    {
        return positionCount;
    }

    @Override
    public long getSizeInBytes()
    {
        if (sizeInBytes >= 0) {
            return sizeInBytes;
        }

        long sizeInBytes = Byte.BYTES * (long) positionCount;
        sizeInBytes += parsedItem.getRegionSizeInBytes(startOffset, positionCount);
        this.sizeInBytes = sizeInBytes;
        return sizeInBytes;
    }

    @Override
    public long getRetainedSizeInBytes()
    {
        long retainedSizeInBytes = this.retainedSizeInBytes;
        if (retainedSizeInBytes < 0) {
            retainedSizeInBytes = INSTANCE_SIZE + sizeOf(isNull);
            retainedSizeInBytes += parsedItem.getRetainedSizeInBytes();
            this.retainedSizeInBytes = retainedSizeInBytes;
        }
        return retainedSizeInBytes;
    }

    @Override
    public void retainedBytesForEachPart(ObjLongConsumer<Object> consumer)
    {
        consumer.accept(parsedItem, parsedItem.getRetainedSizeInBytes());
        if (isNull != null) {
            consumer.accept(isNull, sizeOf(isNull));
        }
        consumer.accept(this, INSTANCE_SIZE);
    }

    @Override
    public String toString()
    {
        return "JsonBlock{startOffset=%d, positionCount=%d}".formatted(startOffset, positionCount);
    }

    @Override
    public JsonBlock copyWithAppendedNull()
    {
        boolean[] newIsNull = new boolean[positionCount + 1];
        if (isNull != null) {
            checkArrayRange(isNull, startOffset, positionCount);
            System.arraycopy(isNull, startOffset, newIsNull, 0, positionCount);
        }
        newIsNull[positionCount] = true;

        Block newParsedItem = getParsedItem().copyWithAppendedNull();
        return new JsonBlock(0, positionCount + 1, newIsNull, newParsedItem);
    }

    @Override
    public JsonBlock copyPositions(int[] positions, int offset, int length)
    {
        checkArrayRange(positions, offset, length);

        Block newParsedItem = copyBlockPositions(positions, offset, length, parsedItem, startOffset, positionCount);

        boolean[] newIsNull = null;
        if (isNull != null) {
            boolean hasNull = false;
            newIsNull = new boolean[length];
            for (int i = 0; i < length; i++) {
                boolean isNull = this.isNull[startOffset + positions[offset + i]];
                newIsNull[i] = isNull;
                hasNull |= isNull;
            }
            if (!hasNull) {
                newIsNull = null;
            }
        }

        return new JsonBlock(0, length, newIsNull, newParsedItem);
    }

    private static Block copyBlockPositions(int[] positions, int offset, int length, Block block, int blockOffset, int blockLength)
    {
        if (blockOffset != 0) {
            block = block.getRegion(blockOffset, blockLength);
        }
        return block.copyPositions(positions, offset, length);
    }

    @Override
    public JsonBlock getRegion(int positionOffset, int length)
    {
        checkValidRegion(positionCount, positionOffset, length);
        return new JsonBlock(startOffset + positionOffset, length, isNull, parsedItem);
    }

    @Override
    public long getRegionSizeInBytes(int position, int length)
    {
        checkValidRegion(positionCount, position, length);

        long regionSizeInBytes = Byte.BYTES * (long) length;
        regionSizeInBytes += parsedItem.getRegionSizeInBytes(startOffset + position, length);
        return regionSizeInBytes;
    }

    @Override
    public JsonBlock copyRegion(int positionOffset, int length)
    {
        checkValidRegion(positionCount, positionOffset, length);

        Block newParsedItem = parsedItem.copyRegion(startOffset + positionOffset, length);

        boolean[] newIsNull = isNull == null ? null : compactArray(isNull, startOffset + positionOffset, length);
        if (startOffset == 0 && newIsNull == isNull && parsedItem == newParsedItem) {
            return this;
        }
        return new JsonBlock(0, length, newIsNull, newParsedItem);
    }

    @Override
    public JsonBlock getSingleValueBlock(int position)
    {
        checkReadablePosition(this, position);

        Block newParsedItem = parsedItem.getSingleValueBlock(startOffset + position);
        boolean[] newIsNull = isNull(position) ? new boolean[] {true} : null;
        return new JsonBlock(0, 1, newIsNull, newParsedItem);
    }

    @Override
    public long getEstimatedDataSizeForStats(int position)
    {
        checkReadablePosition(this, position);

        if (isNull(position)) {
            return 0;
        }

        return parsedItem.getEstimatedDataSizeForStats(startOffset + position);
    }

    @Override
    public boolean isNull(int position)
    {
        if (!mayHaveNull()) {
            return false;
        }
        checkReadablePosition(this, position);
        return isNull[startOffset + position];
    }

    @Override
    public JsonBlock getUnderlyingValueBlock()
    {
        return this;
    }

    @Override
    public Optional<ByteArrayBlock> getNulls()
    {
        return BlockUtil.getNulls(isNull, startOffset, positionCount);
    }
}
