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
package io.trino.parquet.reader.flat;

import io.trino.parquet.PrimitiveField;
import io.trino.parquet.reader.decoders.ValueDecoder.ValueDecodersProvider;
import io.trino.spi.block.Block;
import io.trino.spi.block.Int128ArrayBlock;

import java.util.Optional;

public class Int128FlatColumnReader
        extends FlatColumnReader<long[]>
{
    public Int128FlatColumnReader(PrimitiveField field, ValueDecodersProvider<long[]> decodersProvider)
    {
        super(field, decodersProvider);
    }

    @Override
    protected long[] createBuffer(int size)
    {
        return new long[size * 2];
    }

    @Override
    protected Block createNonNullBlock(int size, long[] values)
    {
        return new Int128ArrayBlock(size, Optional.empty(), values);
    }

    @Override
    protected Block createNullableBlock(int size, boolean[] nulls, long[] values)
    {
        return new Int128ArrayBlock(size, Optional.of(nulls), values);
    }

    @Override
    protected void copyValue(long[] source, int sourceIndex, long[] destination, int destinationIndex)
    {
        destination[destinationIndex * 2] = source[sourceIndex * 2];
        destination[(destinationIndex * 2) + 1] = source[(sourceIndex * 2) + 1];
    }
}
