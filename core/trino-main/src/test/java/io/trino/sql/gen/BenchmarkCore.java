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
package io.trino.sql.gen;

import com.google.common.collect.ImmutableList;
import io.trino.spi.PageBuilder;
import io.trino.spi.block.Block;
import org.openjdk.jmh.annotations.CompilerControl;

import java.util.Arrays;

import static io.trino.spi.type.BigintType.BIGINT;

public class BenchmarkCore
{
    @CompilerControl(CompilerControl.Mode.DONT_INLINE)
    public static Object row_Block_NoNull_NoTrampoline_PageBuilder(Block discount, Block quantity, Block extendedPrice, int positions)
    {
        PageBuilder result = new PageBuilder(positions, ImmutableList.of(BIGINT));
        for (int i = 0; i < positions; i++) {
            boolean matches = discount.getLong(i, 0) >= 5
                    & discount.getLong(i, 0) <= 7
                    & quantity.getLong(i, 0) < 24;

            if (matches) {
                long value = extendedPrice.getLong(i, 0) * discount.getLong(i, 0);
                result.declarePosition();
                BIGINT.writeLong(result.getBlockBuilder(0), value);
            }
        }

        return result.build();
    }

    @CompilerControl(CompilerControl.Mode.DONT_INLINE)
    public static Object row_Block_NoNull_PageBuilder(Block discount, Block quantity, Block extendedPrice, int positions)
    {
        PageBuilder result = new PageBuilder(positions, ImmutableList.of(BIGINT));
        for (int i = 0; i < positions; i++) {
            boolean matches = BIGINT.getLong(discount, i) >= 5
                    & BIGINT.getLong(discount, i) <= 7
                    & BIGINT.getLong(quantity, i) < 24;

            if (matches) {
                long value = BIGINT.getLong(extendedPrice, i) * BIGINT.getLong(discount, i);
                result.declarePosition();
                BIGINT.writeLong(result.getBlockBuilder(0), value);
            }
        }

        return result.build();
    }

    @CompilerControl(CompilerControl.Mode.DONT_INLINE)
    public static Object row_Block_NoNull_CompactArray(Block discount, Block quantity, Block extendedPrice, int positions)
    {
        long[] result = new long[positions];

        int output = 0;
        for (int position = 0; position < positions; position++) {
            boolean matches = BIGINT.getLong(discount, position) >= 5
                    & BIGINT.getLong(discount, position) <= 7
                    & BIGINT.getLong(quantity, position) < 24;

            if (matches) {
                long value = BIGINT.getLong(extendedPrice, position) * BIGINT.getLong(discount, position);
                result[output] = value;
                output++;
            }
        }

        return new Object[] {result, output};
    }

    @CompilerControl(CompilerControl.Mode.DONT_INLINE)
    public static Object row_Array_NoNull_Array(long[] discount, long[] quantity, long[] extendedPrice, int positions)
    {
        long[] result = new long[positions];
        boolean[] mask = new boolean[positions];

        for (int i = 0; i < positions; i++) {
            boolean matches = discount[i] >= 5
                    & discount[i] <= 7
                    & quantity[i] < 24;

            result[i] = matches ? extendedPrice[i] * discount[i] : 0;
            mask[i] = matches;
        }

        return new Object[] {result, mask};
    }

    @CompilerControl(CompilerControl.Mode.DONT_INLINE)
    public static Object row_Array_NoNull_CompactArray(long[] discount, long[] quantity, long[] extendedPrice, int positions)
    {
        long[] result = new long[positions];

        int output = 0;
        for (int i = 0; i < positions; i++) {
            boolean matches = discount[i] >= 5
                    & discount[i] <= 7
                    & quantity[i] < 24;

            if (matches) {
                long value = extendedPrice[i] * discount[i];
                result[output] = value;
                output++;
            }
        }

        return new Object[] {result, output};
    }

    @CompilerControl(CompilerControl.Mode.DONT_INLINE)
    public static Object columnar_Array_Fused_NoNull_Array(long[] discount, long[] quantity, long[] extendedPrice, int positions)
    {
        long[] result = new long[positions];
        boolean[] mask = new boolean[positions];

        Arrays.fill(mask, true);
        for (int i = 0; i < positions; i++) {
            mask[i] &= discount[i] >= 5 & discount[i] <= 7;
        }
        for (int i = 0; i < positions; i++) {
            mask[i] &= quantity[i] < 24;
        }

        for (int i = 0; i < positions; i++) {
            result[i] = mask[i] ? discount[i] * extendedPrice[i] : 0;
        }

        return new Object[] {result, mask};
    }

    @CompilerControl(CompilerControl.Mode.DONT_INLINE)
    public static Object columnar_Array_Fused_NoNull_CompactArray(long[] discount, long[] quantity, long[] extendedPrice, int positions, boolean[] tempMask)
    {
        long[] result = new long[positions];

        Arrays.fill(tempMask, true);
        for (int i = 0; i < positions; i++) {
            tempMask[i] &= discount[i] >= 5 & discount[i] <= 7;
        }
        for (int i = 0; i < positions; i++) {
            tempMask[i] &= quantity[i] < 24;
        }

        int output = 0;
        for (int i = 0; i < positions; i++) {
            if (tempMask[i]) {
                result[output] = discount[i] * extendedPrice[i];
                output++;
            }
        }

        return new Object[] {result, output};
    }

    @CompilerControl(CompilerControl.Mode.DONT_INLINE)
    public static Object columnar_Array_NoNull_CompactArray(long[] discount, long[] quantity, long[] extendedPrice, int positions, boolean[] tempMask)
    {
        long[] result = new long[positions];

        Arrays.fill(tempMask, true);
        for (int i = 0; i < positions; i++) {
            tempMask[i] &= discount[i] >= 5;
        }
        for (int i = 0; i < positions; i++) {
            tempMask[i] &= discount[i] <= 7;
        }
        for (int i = 0; i < positions; i++) {
            tempMask[i] &= quantity[i] < 24;
        }

        int output = 0;
        for (int i = 0; i < positions; i++) {
            if (tempMask[i]) {
                long value = discount[i] * extendedPrice[i];
                result[output] = value;
                output++;
            }
        }

        return new Object[] {result, output};
    }

    @CompilerControl(CompilerControl.Mode.DONT_INLINE)
    public static Object columnar_Block_NoNull_CompactArray(Block discount, Block quantity, Block extendedPrice, int positions, boolean[] tempMask)
    {
        long[] result = new long[positions];

        Arrays.fill(tempMask, true);
        for (int i = 0; i < positions; i++) {
            tempMask[i] &= BIGINT.getLong(discount, i) >= 5;
        }
        for (int i = 0; i < positions; i++) {
            tempMask[i] &= BIGINT.getLong(discount, i) <= 7;
        }
        for (int i = 0; i < positions; i++) {
            tempMask[i] &= BIGINT.getLong(quantity, i) < 24;
        }

        int output = 0;
        for (int i = 0; i < positions; i++) {
            if (tempMask[i]) {
                result[output] = BIGINT.getLong(discount, i) * BIGINT.getLong(extendedPrice, i);
                output++;
            }
        }

        return new Object[] {result, output};
    }

    @CompilerControl(CompilerControl.Mode.DONT_INLINE)
    public static Object columnarHybrid_NoNull_CompactArray(Block discountBlock, Block quantityBlock, Block extendedPriceBlock, int positions, boolean[] tempMask)
    {
        long[] result = new long[positions];

        for (int i = 0; i < positions; i++) {
            tempMask[i] = BIGINT.getLong(discountBlock, i) >= 5
                    & BIGINT.getLong(discountBlock, i) <= 7
                    & BIGINT.getLong(quantityBlock, i) < 24;
        }

        int output = 0;
        for (int i = 0; i < positions; i++) {
            if (tempMask[i]) {
                result[output] = BIGINT.getLong(discountBlock, i) * BIGINT.getLong(extendedPriceBlock, i);
                output++;
            }
        }

        return new Object[] {result, output};
    }

    @CompilerControl(CompilerControl.Mode.DONT_INLINE)
    public static Object columnarHybrid_Block_NoNull_NoTrampoline_CompactArray(Block discountBlock, Block quantityBlock, Block extendedPriceBlock, int positions, boolean[] tempMask)
    {
        long[] result = new long[positions];

        for (int i = 0; i < positions; i++) {
            tempMask[i] = discountBlock.getLong(i, 0) >= 5
                    & discountBlock.getLong(i, 0) <= 7
                    & quantityBlock.getLong(i, 0) < 24;
        }

        int output = 0;
        for (int i = 0; i < positions; i++) {
            if (tempMask[i]) {
                result[output] = discountBlock.getLong(i, 0) * extendedPriceBlock.getLong(i, 0);
                output++;
            }
        }

        return new Object[] {result, output};
    }

    @CompilerControl(CompilerControl.Mode.DONT_INLINE)
    public static Object columnarHybrid_Block_NoNull_PageBuilder(Block discountBlock, Block quantityBlock, Block extendedPriceBlock, int positions, boolean[] tempMask)
    {
        PageBuilder result = new PageBuilder(positions, ImmutableList.of(BIGINT));
        for (int i = 0; i < positions; i++) {
            tempMask[i] = BIGINT.getLong(discountBlock, i) >= 5
                    & BIGINT.getLong(discountBlock, i) <= 7
                    & BIGINT.getLong(quantityBlock, i) < 24;
        }

        for (int i = 0; i < positions; i++) {
            if (tempMask[i]) {
                long value = BIGINT.getLong(discountBlock, i) * BIGINT.getLong(extendedPriceBlock, i);
                result.declarePosition();
                BIGINT.writeLong(result.getBlockBuilder(0), value);
            }
        }

        return result.build();
    }
}
