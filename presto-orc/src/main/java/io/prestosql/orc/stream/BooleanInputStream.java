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
package io.prestosql.orc.stream;

import io.prestosql.orc.checkpoint.BooleanStreamCheckpoint;
import io.prestosql.spi.block.BlockBuilder;
import io.prestosql.spi.type.Type;

import java.io.IOException;

import static com.google.common.base.Preconditions.checkState;

@SuppressWarnings("NarrowingCompoundAssignment")
public class BooleanInputStream
        implements ValueInputStream<BooleanStreamCheckpoint>
{
    private static final int HIGH_BIT_MASK = 0b1000_0000;
    private final ByteInputStream byteStream;
    private byte data;
    private int bitsInData;

    public BooleanInputStream(OrcInputStream byteStream)
    {
        this.byteStream = new ByteInputStream(byteStream);
    }

    private void readByte()
            throws IOException
    {
        checkState(bitsInData == 0);
        data = byteStream.next();
        bitsInData = 8;
    }

    public boolean nextBoolean()
            throws IOException
    {
        return nextBit() != 0;
    }

    public int nextBit()
            throws IOException
    {
        // read more data if necessary
        if (bitsInData == 0) {
            readByte();
        }

        // read bit
        int result = (data & HIGH_BIT_MASK) >>> 7;

        // mark bit consumed
        data <<= 1;
        bitsInData--;

        return result;
    }

    @Override
    public Class<BooleanStreamCheckpoint> getCheckpointType()
    {
        return BooleanStreamCheckpoint.class;
    }

    @Override
    public void seekToCheckpoint(BooleanStreamCheckpoint checkpoint)
            throws IOException
    {
        byteStream.seekToCheckpoint(checkpoint.getByteStreamCheckpoint());
        bitsInData = 0;
        skip(checkpoint.getOffset());
    }

    @Override
    public void skip(long items)
            throws IOException
    {
        if (bitsInData >= items) {
            data <<= items;
            bitsInData -= items;
        }
        else {
            items -= bitsInData;
            bitsInData = 0;

            byteStream.skip(items >>> 3);
            items &= 0b111;

            if (items != 0) {
                readByte();
                data <<= items;
                bitsInData -= items;
            }
        }
    }

    public int countBitsSet(int items)
            throws IOException
    {
        int count = 0;

        // count buffered data
        if (items > bitsInData && bitsInData > 0) {
            count += bitCount(data);
            items -= bitsInData;
            bitsInData = 0;
        }

        // count whole bytes
        while (items > 8) {
            count += bitCount(byteStream.next());
            items -= 8;
        }

        // count remaining bits
        for (int i = 0; i < items; i++) {
            count += nextBit();
        }

        return count;
    }

    /**
     * Sets the vector element to 1 if the bit is set.
     */
    public int getSetBits(int batchSize, byte[] vector)
            throws IOException
    {
        int count = 0;
        for (int i = 0; i < batchSize; i++) {
            int bit = nextBit();
            vector[i] = (byte) bit;
            count += bit;
        }
        return count;
    }

    public byte[] getSetBits(int batchSize)
            throws IOException
    {
        byte[] vector = new byte[batchSize];

        if (bitsInData != 0) {
            for (int i = 0; i < batchSize; i++) {
                vector[i] = (byte) nextBit();
            }
        }
        else {
            int offset = 0;
            while (offset < batchSize - 7) {
                byte value = byteStream.next();
                vector[offset + 0] = (byte) ((value & 0b10000000) >>> 7);
                vector[offset + 1] = (byte) ((value & 0b01000000) >>> 6);
                vector[offset + 2] = (byte) ((value & 0b00100000) >>> 5);
                vector[offset + 3] = (byte) ((value & 0b00010000) >>> 4);
                vector[offset + 4] = (byte) ((value & 0b00001000) >>> 3);
                vector[offset + 5] = (byte) ((value & 0b00000100) >>> 2);
                vector[offset + 6] = (byte) ((value & 0b00000010) >>> 1);
                vector[offset + 7] = (byte) ((value & 0b00000001) >>> 0);
                offset += 8;
            }

            int remaining = batchSize - offset;
            if (remaining > 0) {
                byte value = byteStream.next();

                int tmp = value >>> (8 - remaining);
                switch (remaining) {
                    case 7:
                        vector[offset++] = (byte) ((tmp & 64) >>> 6);
                    case 6:
                        vector[offset++] = (byte) ((tmp & 32) >>> 5);
                    case 5:
                        vector[offset++] = (byte) ((tmp & 16) >>> 4);
                    case 4:
                        vector[offset++] = (byte) ((tmp & 8) >>> 3);
                    case 3:
                        vector[offset++] = (byte) ((tmp & 4) >>> 2);
                    case 2:
                        vector[offset++] = (byte) ((tmp & 2) >>> 1);
                    case 1:
                        vector[offset++] = (byte) ((tmp & 1) >>> 0);
                }

                data = (byte) (value << remaining);
                bitsInData = 8 - remaining;
            }
        }

        return vector;
    }

    /**
     * Sets the vector element to 1 if the bit is set, skipping the null values.
     */
    public int getSetBits(int batchSize, byte[] vector, boolean[] isNull)
            throws IOException
    {
        int count = 0;
        for (int i = 0; i < batchSize; i++) {
            if (!isNull[i]) {
                int bit = nextBit();
                vector[i] = (byte) bit;
                count += bit;
            }
        }
        return count;
    }

    public byte[] getSetBits(int batchSize, boolean[] isNull)
            throws IOException
    {
        byte[] vector = new byte[batchSize];
        for (int i = 0; i < batchSize; i++) {
            if (!isNull[i]) {
                vector[i] = (byte) nextBit();
            }
        }
        return vector;
    }

    /**
     * Sets the vector element to true if the bit is set.
     */
    public void getSetBits(Type type, int batchSize, BlockBuilder builder)
            throws IOException
    {
        for (int i = 0; i < batchSize; i++) {
            type.writeBoolean(builder, nextBoolean());
        }
    }

    /**
     * Sets the vector element to true if the bit is not set.
     */
    public int getUnsetBits(int batchSize, boolean[] vector)
            throws IOException
    {
        return getUnsetBits(batchSize, vector, 0);
    }

    /**
     * Sets the vector element to true for the batchSize number of elements starting at offset
     * if the bit is not set.
     */
    private int getUnsetBits(int batchSize, boolean[] vector, int offset)
            throws IOException
    {
        int count = 0;
        for (int i = offset; i < batchSize + offset; i++) {
            int bit = nextBit() ^ 0b1;
            vector[i] = bit != 0;
            count += bit;
        }
        return count;
    }

    /**
     * Return the number of unset bits
     */
    public int getUnsetBits(int batchSize)
            throws IOException
    {
        int count = 0;
        for (int i = 0; i < batchSize; i++) {
            count += nextBit() ^ 0b1;
        }
        return count;
    }

    private static int bitCount(byte data)
    {
        return Integer.bitCount(data & 0xFF);
    }
}
