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

import io.airlift.slice.SliceInput;
import io.airlift.slice.SliceOutput;

import static io.trino.spi.block.EncoderUtil.decodeNullBitsScalar;
import static io.trino.spi.block.EncoderUtil.decodeNullBitsVectorized;
import static io.trino.spi.block.EncoderUtil.encodeNullsAsBitsScalar;
import static io.trino.spi.block.EncoderUtil.encodeNullsAsBitsVectorized;

public class JsonBlockEncoding
        implements BlockEncoding
{
    public static final String NAME = "JSON";

    // Wire-format version; written as the first byte of each encoded block. Readers reject
    // unknown versions so forward-compatible schema changes can be made by bumping this value.
    private static final byte VERSION_1 = 1;

    private final boolean vectorizeNullBitPacking;

    public JsonBlockEncoding(boolean vectorizeNullBitPacking)
    {
        this.vectorizeNullBitPacking = vectorizeNullBitPacking;
    }

    @Override
    public String getName()
    {
        return NAME;
    }

    @Override
    public Class<? extends Block> getBlockClass()
    {
        return JsonBlock.class;
    }

    @Override
    public void writeBlock(BlockEncodingSerde blockEncodingSerde, SliceOutput sliceOutput, Block block)
    {
        JsonBlock jsonBlock = (JsonBlock) block;

        sliceOutput.appendByte(VERSION_1);
        sliceOutput.appendInt(jsonBlock.getPositionCount());

        blockEncodingSerde.writeBlock(sliceOutput, jsonBlock.getParsedItem());

        if (vectorizeNullBitPacking) {
            encodeNullsAsBitsVectorized(sliceOutput, jsonBlock.getRawIsNull(), jsonBlock.getOffsetBase(), jsonBlock.getPositionCount());
        }
        else {
            encodeNullsAsBitsScalar(sliceOutput, jsonBlock.getRawIsNull(), jsonBlock.getOffsetBase(), jsonBlock.getPositionCount());
        }
    }

    @Override
    public Block readBlock(BlockEncodingSerde blockEncodingSerde, SliceInput sliceInput)
    {
        byte version = sliceInput.readByte();
        if (version != VERSION_1) {
            throw new IllegalArgumentException("Unsupported JSON block encoding version: " + version);
        }
        int positionCount = sliceInput.readInt();

        Block parsedItemBlock = blockEncodingSerde.readBlock(sliceInput);

        boolean[] jsonIsNull;
        if (vectorizeNullBitPacking) {
            jsonIsNull = decodeNullBitsVectorized(sliceInput, positionCount).orElse(null);
        }
        else {
            jsonIsNull = decodeNullBitsScalar(sliceInput, positionCount).orElse(null);
        }

        return JsonBlock.createInternal(0, positionCount, jsonIsNull, parsedItemBlock);
    }
}
