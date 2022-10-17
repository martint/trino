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
package io.trino.parquet.reader.decoders;

import io.airlift.slice.Slice;
import io.airlift.slice.Slices;
import io.trino.parquet.reader.SimpleSliceInputStream;
import io.trino.parquet.reader.flat.BinaryBuffer;
import io.trino.spi.type.CharType;
import io.trino.spi.type.Chars;
import io.trino.spi.type.Int128;
import io.trino.spi.type.Type;
import io.trino.spi.type.VarcharType;
import io.trino.spi.type.Varchars;
import org.apache.parquet.bytes.ByteBufferInputStream;
import org.apache.parquet.column.values.ValuesReader;

import java.io.IOException;
import java.io.UncheckedIOException;
import java.lang.invoke.MethodHandles;
import java.lang.invoke.VarHandle;
import java.nio.ByteBuffer;
import java.nio.ByteOrder;

import static io.trino.parquet.ParquetReaderUtils.castToByte;
import static io.trino.parquet.ParquetReaderUtils.toByteExact;
import static io.trino.parquet.ParquetReaderUtils.toShortExact;
import static io.trino.parquet.ParquetTypeUtils.checkBytesFitInShortDecimal;
import static io.trino.parquet.ParquetTypeUtils.getShortDecimalValue;
import static java.util.Objects.requireNonNull;

/**
 * This is a set of proxy value decoders that use a delegated value reader from apache lib.
 */
public abstract class ApacheParquetValueDecoder<T>
        implements ValueDecoder<T>
{
    protected final ValuesReader delegate;

    public ApacheParquetValueDecoder(ValuesReader delegate)
    {
        this.delegate = requireNonNull(delegate, "delegate is null");
    }

    @Override
    public void init(SimpleSliceInputStream input)
    {
        byte[] buffer = input.readBytes();
        try {
            delegate.initFromPage(0, ByteBufferInputStream.wrap(ByteBuffer.wrap(buffer, 0, buffer.length)));
        }
        catch (IOException e) {
            throw new UncheckedIOException(e);
        }
    }

    @Override
    public void skip(int n)
    {
        delegate.skip(n);
    }

    public static final class IntApacheParquetValueDecoder
            extends ApacheParquetValueDecoder<int[]>
    {
        public IntApacheParquetValueDecoder(ValuesReader delegate)
        {
            super(delegate);
        }

        @Override
        public void read(int[] values, int offset, int length)
        {
            for (int i = offset; i < offset + length; i++) {
                values[i] = delegate.readInteger();
            }
        }
    }

    public static final class ShortApacheParquetValueDecoder
            extends ApacheParquetValueDecoder<short[]>
    {
        public ShortApacheParquetValueDecoder(ValuesReader delegate)
        {
            super(delegate);
        }

        @Override
        public void read(short[] values, int offset, int length)
        {
            for (int i = offset; i < offset + length; i++) {
                values[i] = toShortExact(delegate.readInteger());
            }
        }
    }

    public static final class ByteApacheParquetValueDecoder
            extends ApacheParquetValueDecoder<byte[]>
    {
        public ByteApacheParquetValueDecoder(ValuesReader delegate)
        {
            super(delegate);
        }

        @Override
        public void read(byte[] values, int offset, int length)
        {
            for (int i = offset; i < offset + length; i++) {
                values[i] = toByteExact(delegate.readInteger());
            }
        }
    }

    public static final class IntToLongApacheParquetValueDecoder
            extends ApacheParquetValueDecoder<long[]>
    {
        public IntToLongApacheParquetValueDecoder(ValuesReader delegate)
        {
            super(delegate);
        }

        @Override
        public void read(long[] values, int offset, int length)
        {
            for (int i = offset; i < offset + length; i++) {
                values[i] = delegate.readInteger();
            }
        }
    }

    public static final class LongApacheParquetValueDecoder
            extends ApacheParquetValueDecoder<long[]>
    {
        public LongApacheParquetValueDecoder(ValuesReader delegate)
        {
            super(delegate);
        }

        @Override
        public void read(long[] values, int offset, int length)
        {
            for (int i = offset; i < offset + length; i++) {
                values[i] = delegate.readLong();
            }
        }
    }

    public static final class DoubleApacheParquetValueDecoder
            extends ApacheParquetValueDecoder<long[]>
    {
        public DoubleApacheParquetValueDecoder(ValuesReader delegate)
        {
            super(delegate);
        }

        @Override
        public void read(long[] values, int offset, int length)
        {
            for (int i = offset; i < offset + length; i++) {
                values[i] = Double.doubleToLongBits(delegate.readDouble());
            }
        }
    }

    public static final class FloatApacheParquetValueDecoder
            extends ApacheParquetValueDecoder<int[]>
    {
        public FloatApacheParquetValueDecoder(ValuesReader delegate)
        {
            super(delegate);
        }

        @Override
        public void read(int[] values, int offset, int length)
        {
            for (int i = offset; i < offset + length; i++) {
                values[i] = Float.floatToIntBits(delegate.readFloat());
            }
        }
    }

    public static final class BooleanApacheParquetValueDecoder
            extends ApacheParquetValueDecoder<byte[]>
    {
        public BooleanApacheParquetValueDecoder(ValuesReader delegate)
        {
            super(delegate);
        }

        @Override
        public void init(SimpleSliceInputStream input)
        {
            byte[] buffer = input.readBytes();
            try {
                // Deprecated PLAIN boolean decoder from Apache lib is the only one that actually
                // uses the valueCount argument to allocate memory so we simulate it here.
                int valueCount = buffer.length * Byte.SIZE;
                delegate.initFromPage(valueCount, ByteBufferInputStream.wrap(ByteBuffer.wrap(buffer, 0, buffer.length)));
            }
            catch (IOException e) {
                throw new UncheckedIOException(e);
            }
        }

        @Override
        public void read(byte[] values, int offset, int length)
        {
            for (int i = offset; i < offset + length; i++) {
                values[i] = castToByte(delegate.readBoolean());
            }
        }
    }

    public static final class ShortDecimalApacheParquetValueDecoder
            extends ApacheParquetValueDecoder<long[]>
    {
        private final int typeLength;
        private final Type trinoType;

        public ShortDecimalApacheParquetValueDecoder(ValuesReader delegate, int typeLength, Type trinoType)
        {
            super(delegate);
            this.typeLength = typeLength;
            this.trinoType = requireNonNull(trinoType, "trinoType is null");
        }

        @Override
        public void read(long[] values, int offset, int length)
        {
            int bytesOffset = 0;
            int bytesLength = typeLength;
            if (typeLength > Long.BYTES) {
                bytesOffset = typeLength - Long.BYTES;
                bytesLength = Long.BYTES;
            }
            for (int i = offset; i < offset + length; i++) {
                byte[] bytes = delegate.readBytes().getBytes();
                checkBytesFitInShortDecimal(bytes, 0, bytesOffset, trinoType, typeLength);
                values[i] = getShortDecimalValue(bytes, bytesOffset, bytesLength);
            }
        }
    }

    public static final class LongDecimalApacheParquetValueDecoder
            extends ApacheParquetValueDecoder<long[]>
    {
        public LongDecimalApacheParquetValueDecoder(ValuesReader delegate)
        {
            super(delegate);
        }

        @Override
        public void read(long[] values, int offset, int length)
        {
            int endOffset = (offset + length) * 2;
            for (int currentOutputOffset = offset * 2; currentOutputOffset < endOffset; currentOutputOffset += 2) {
                Int128 value = Int128.fromBigEndian(delegate.readBytes().getBytes());
                values[currentOutputOffset] = value.getHigh();
                values[currentOutputOffset + 1] = value.getLow();
            }
        }
    }

    public static final class UuidApacheParquetValueDecoder
            extends ApacheParquetValueDecoder<long[]>
    {
        private static final VarHandle LONG_ARRAY_HANDLE = MethodHandles.byteArrayViewVarHandle(long[].class, ByteOrder.LITTLE_ENDIAN);

        public UuidApacheParquetValueDecoder(ValuesReader delegate)
        {
            super(delegate);
        }

        @Override
        public void read(long[] values, int offset, int length)
        {
            int endOffset = (offset + length) * 2;
            for (int currentOutputOffset = offset * 2; currentOutputOffset < endOffset; currentOutputOffset += 2) {
                byte[] data = delegate.readBytes().getBytes();
                values[currentOutputOffset] = (long) LONG_ARRAY_HANDLE.get(data, 0);
                values[currentOutputOffset + 1] = (long) LONG_ARRAY_HANDLE.get(data, Long.BYTES);
            }
        }
    }

    public static final class BinaryApacheParquetValueDecoder
            extends ApacheParquetValueDecoder<BinaryBuffer>
    {
        private final Type trinoType;

        public BinaryApacheParquetValueDecoder(ValuesReader delegate, Type trinoType)
        {
            super(delegate);
            this.trinoType = requireNonNull(trinoType, "trinoType is null");
        }

        @Override
        public void read(BinaryBuffer values, int offsetsIndex, int length)
        {
            // A dedicated loop for every case bring significant performance benefit
            if (trinoType instanceof VarcharType && !((VarcharType) trinoType).isUnbounded()) {
                for (int i = 0; i < length; i++) {
                    byte[] value = delegate.readBytes().getBytes();
                    Slice slice = Varchars.truncateToLength(Slices.wrappedBuffer(value), trinoType);

                    values.add(slice, i + offsetsIndex);
                }
            }
            else if (trinoType instanceof CharType) {
                for (int i = 0; i < length; i++) {
                    byte[] value = delegate.readBytes().getBytes();
                    Slice slice = Chars.truncateToLengthAndTrimSpaces(Slices.wrappedBuffer(value), trinoType);

                    values.add(slice, i + offsetsIndex);
                }
            }
            else {
                for (int i = 0; i < length; i++) {
                    byte[] value = delegate.readBytes().getBytes();

                    values.add(value, i + offsetsIndex);
                }
            }
        }
    }
}
