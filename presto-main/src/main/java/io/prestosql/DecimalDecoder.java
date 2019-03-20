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
package io.prestosql;

import io.airlift.slice.Slice;
import io.airlift.slice.Slices;

import java.util.ArrayList;
import java.util.Iterator;
import java.util.List;
import java.util.concurrent.ThreadLocalRandom;

public class DecimalDecoder
{
    private static final long LONG_MASK = 0x80_80_80_80_80_80_80_80L;
    private static final int INT_MASK = 0x80_80_80_80;

    private Slice block; // reference to current (decoded) data block. Can be either a reference to the buffer or to current chunk
    private int blockOffset; // position within current data block

    private final Iterator<Slice> chunks;
    private int limit;

    public DecimalDecoder(List<Slice> chunks)
    {
        this.chunks = chunks.iterator();
    }

    // result must have at least batchSize * 2 capacity
    public long[] decode(long[] result, int batchSize)
    {
        int count = 0;

        while (count < batchSize) {
            if (block == null) {
                advance();
            }

            while (blockOffset <= limit - 20) { // we'll read 2 longs + 1 int
                long low = 0;
                long middle = 0;
                int high = 0;

                // low bits
                long current = block.getLong(blockOffset);
                int zeros = Long.numberOfTrailingZeros(~current & LONG_MASK);
                int end = (zeros + 1) / 8;
                blockOffset += end;

                boolean negative = (current & 1) == 1;

                low = (current & 0x7F_00_00_00_00_00_00_00L) >>> 7;
                low |= (current & 0x7F_00_00_00_00_00_00L) >>> 6;
                low |= (current & 0x7F_00_00_00_00_00L) >>> 5;
                low |= (current & 0x7F_00_00_00_00L) >>> 4;
                low |= (current & 0x7F_00_00_00) >>> 3;
                low |= (current & 0x7F_00_00) >>> 2;
                low |= (current & 0x7F_00) >>> 1;
                low |= (current & 0x7F) >>> 0;

                low = low & ((1L << (end * 7)) - 1);

                // middle bits
                if (zeros == 64) {
                    current = block.getLong(blockOffset);
                    zeros = Long.numberOfTrailingZeros(~current & LONG_MASK);
                    end = (zeros + 1) / 8;
                    blockOffset += end;

                    middle = (current & 0x7F_00_00_00_00_00_00_00L) >>> 7;
                    middle |= (current & 0x7F_00_00_00_00_00_00L) >>> 6;
                    middle |= (current & 0x7F_00_00_00_00_00L) >>> 5;
                    middle |= (current & 0x7F_00_00_00_00L) >>> 4;
                    middle |= (current & 0x7F_00_00_00) >>> 3;
                    middle |= (current & 0x7F_00_00) >>> 2;
                    middle |= (current & 0x7F_00) >>> 1;
                    middle |= (current & 0x7F) >>> 0;

                    middle = middle & ((1L << (end * 7)) - 1);

                    // high bits
                    if (zeros == 64) {
                        int last = block.getInt(blockOffset);
                        zeros = Integer.numberOfTrailingZeros(~last & INT_MASK);
                        end = (zeros + 1) / 8;

                        blockOffset += end;

                        high = (last & 0x7F_00_00) >>> 2;
                        high |= (last & 0x7F_00) >>> 1;
                        high |= (last & 0x7F) >>> 0;

                        high = high & ((1 << (end * 7)) - 1);

                        if (end == 4 || high > 0xFF_FF) { // only 127 - (55 + 56) = 16 bits allowed in high
                            throw new RuntimeException("overflow");
                        }
                    }
                }

                emit(result, count, low, middle, high, negative);
                count++;

                if (count == batchSize) {
                    return result;
                }
            }

            // handle the tail of the current block
            count = decodeTail(result, count);
        }

        return result;
    }

    private void emit(long[] result, int offset, long low, long middle, long high, boolean negative)
    {
        long lower = (low >>> 1) | (middle << 55); // drop the sign bit from low
        long upper = (middle >>> 9) | (high << 47);

        if (negative) {
            if (lower == 0xFFFFFFFFFFFFFFFFL) {
                lower = 0;
                upper += 1;
            }
            else {
                lower += 1;
            }
        }

        result[2 * offset] = lower;
        result[2 * offset + 1] = upper;
    }

    private int decodeTail(long[] result, int count)
    {
        boolean negative = false;
        long low = 0;
        long middle = 0;
        int high = 0;

        long value = 0;
        boolean last = false;

        int offset = 0;
        while (true) {
            value = block.getByte(blockOffset);
            blockOffset++;

            if (offset == 0) {
                negative = (value & 1) == 1;
                low |= (value & 0x7F);
            }
            else if (offset < 8) {
                low |= (value & 0x7F) << (offset * 7);
            }
            else if (offset < 16) {
                middle |= (value & 0x7F) << ((offset - 8) * 7);
            }
            else if (offset < 19) {
                high |= (value & 0x7F) << ((offset - 16) * 7);
            }
            else {
                throw new RuntimeException("overflow");
            }

            offset++;

            if ((value & 0x80) == 0) {
                if (high > 0xFF_FF) { // only 127 - (55 + 56) = 16 bits allowed in high
                    throw new RuntimeException("overflow");
                }

                emit(result, count, low, middle, high, negative);
                count++;

                low = 0;
                middle = 0;
                high = 0;
                offset = 0;

                if (blockOffset == limit) {
                    // the last value aligns with the end of the block, so just
                    // reset the block and loop around to optimized decoding
                    block = null;
                    blockOffset = 0;
                    break;
                }

                if (last) {
                    break;
                }
            }
            else if (blockOffset == limit) {
                last = true;
                advance();
            }
        }
        return count;
    }

    private void advance()
    {
        // TODO if no more chunks => error
        blockOffset = 0;
        block = chunks.next();
        limit = block.length();
    }

    public static void main(String[] args)
    {
        int CHUNKS = 1;
        int ITEMS_PER_CHUNK = 3000;

        int totalItems = 0;

        // prepare test data
        List<Slice> chunks = new ArrayList<>();

        for (int chunk = 0; chunk < CHUNKS; chunk++) {
            byte[] data = new byte[19 * ITEMS_PER_CHUNK];
            int offset = 0;

            int split = 0;
            totalItems += ITEMS_PER_CHUNK;
            for (int item = 0; item < ITEMS_PER_CHUNK; item++) {
                int bits = ThreadLocalRandom.current().nextInt(1, 128);

                offset = encode(data, offset, bits);

                if (item == ITEMS_PER_CHUNK / 2) {
                    split = offset - 1;
                }
            }

//            chunks.add(Slices.wrappedBuffer(data, 0, offset));
            // so that some values straddle the chunks
            chunks.add(Slices.wrappedBuffer(data, 0, split));
            chunks.add(Slices.wrappedBuffer(data, split, offset - split));
        }

        // decode
        DecimalDecoder decoder = new DecimalDecoder(chunks);
        long[] result = new long[totalItems * 2];
        try {
            decoder.decode(result, totalItems);
            int breakpoint = 1;
        }
        catch (Exception e) {
            e.printStackTrace();
            // for breakpoint + debuging
            new DecimalDecoder(chunks).decode(result, totalItems);
        }
    }

    public static int encode(byte[] data, int offset, int bits)
    {
        while (bits >= 7) {
            data[offset++] = (byte) 0x80;
            bits -= 7;
        }
        data[offset++] = (byte) (1 << bits);

        return offset;
    }
}
