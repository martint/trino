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

import io.trino.parquet.ParquetEncoding;
import io.trino.parquet.PrimitiveField;
import io.trino.parquet.dictionary.Dictionary;
import io.trino.spi.type.Type;
import org.apache.parquet.column.values.ValuesReader;
import org.apache.parquet.schema.PrimitiveType;

import javax.annotation.Nullable;

import static com.google.common.base.Preconditions.checkArgument;
import static io.trino.parquet.ParquetEncoding.PLAIN_DICTIONARY;
import static io.trino.parquet.ParquetEncoding.RLE_DICTIONARY;
import static io.trino.parquet.ValuesType.VALUES;
import static io.trino.parquet.reader.decoders.ApacheParquetValueDecoder.BooleanApacheParquetValueDecoder;
import static io.trino.parquet.reader.decoders.ApacheParquetValueDecoder.ByteApacheParquetValueDecoder;
import static io.trino.parquet.reader.decoders.ApacheParquetValueDecoder.DoubleApacheParquetValueDecoder;
import static io.trino.parquet.reader.decoders.ApacheParquetValueDecoder.FloatApacheParquetValueDecoder;
import static io.trino.parquet.reader.decoders.ApacheParquetValueDecoder.IntApacheParquetValueDecoder;
import static io.trino.parquet.reader.decoders.ApacheParquetValueDecoder.IntToLongApacheParquetValueDecoder;
import static io.trino.parquet.reader.decoders.ApacheParquetValueDecoder.LongApacheParquetValueDecoder;
import static io.trino.parquet.reader.decoders.ApacheParquetValueDecoder.LongDecimalApacheParquetValueDecoder;
import static io.trino.parquet.reader.decoders.ApacheParquetValueDecoder.ShortApacheParquetValueDecoder;
import static io.trino.parquet.reader.decoders.ApacheParquetValueDecoder.ShortDecimalApacheParquetValueDecoder;
import static java.util.Objects.requireNonNull;

/**
 * This class provides static API for creating value decoders for given fields and encodings.
 * If no suitable decoder is found the Apache Parquet fallback is used.
 * Not all types are supported since this class is at this point used only by flat readers
 * <p>
 * This class is to replace most of the logic contained in ParquetEncoding enum
 */
public final class ValueDecoders
{
    private ValueDecoders() {}

    public static ValueDecoder<long[]> getDoubleDecoder(ParquetEncoding encoding, PrimitiveField field, @Nullable Dictionary dictionary)
    {
        return switch (encoding) {
            case PLAIN, PLAIN_DICTIONARY, RLE_DICTIONARY -> new DoubleApacheParquetValueDecoder(getApacheParquetReader(encoding, field, dictionary));
            default -> throw wrongEncoding(encoding, field);
        };
    }

    public static ValueDecoder<int[]> getRealDecoder(ParquetEncoding encoding, PrimitiveField field, @Nullable Dictionary dictionary)
    {
        return switch (encoding) {
            case PLAIN, PLAIN_DICTIONARY, RLE_DICTIONARY -> new FloatApacheParquetValueDecoder(getApacheParquetReader(encoding, field, dictionary));
            default -> throw wrongEncoding(encoding, field);
        };
    }

    public static ValueDecoder<long[]> getShortDecimalDecoder(ParquetEncoding encoding, PrimitiveField field, @Nullable Dictionary dictionary)
    {
        PrimitiveType primitiveType = field.getDescriptor().getPrimitiveType();
        return switch (primitiveType.getPrimitiveTypeName()) {
            case INT64 -> getLongDecoder(encoding, field, dictionary);
            case INT32 -> getIntToLongDecoder(encoding, field, dictionary);
            case FIXED_LEN_BYTE_ARRAY -> getFixedWidthShortDecimalDecoder(encoding, field, dictionary, field.getType(), primitiveType.getTypeLength());
            default -> throw wrongEncoding(encoding, field);
        };
    }

    public static ValueDecoder<long[]> getLongDecimalDecoder(ParquetEncoding encoding, PrimitiveField field, @Nullable Dictionary dictionary)
    {
        PrimitiveType primitiveType = field.getDescriptor().getPrimitiveType();
        return switch (primitiveType.getPrimitiveTypeName()) {
            case FIXED_LEN_BYTE_ARRAY -> getFixedWidthLongDecimalDecoder(encoding, field, dictionary);
            case BINARY -> getBinaryLongDecimalDecoder(encoding, field, dictionary);
            default -> throw wrongEncoding(encoding, field);
        };
    }

    public static ValueDecoder<long[]> getLongDecoder(ParquetEncoding encoding, PrimitiveField field, @Nullable Dictionary dictionary)
    {
        return switch (encoding) {
            case PLAIN, DELTA_BINARY_PACKED, RLE, BIT_PACKED, PLAIN_DICTIONARY, RLE_DICTIONARY ->
                    new LongApacheParquetValueDecoder(getApacheParquetReader(encoding, field, dictionary));
            default -> throw wrongEncoding(encoding, field);
        };
    }

    public static ValueDecoder<long[]> getIntToLongDecoder(ParquetEncoding encoding, PrimitiveField field, @Nullable Dictionary dictionary)
    {
        // We need to produce LongArrayBlock from the decoded integers for INT32 backed decimals
        return switch (encoding) {
            case PLAIN, DELTA_BINARY_PACKED, RLE, BIT_PACKED, PLAIN_DICTIONARY, RLE_DICTIONARY ->
                    new IntToLongApacheParquetValueDecoder(getApacheParquetReader(encoding, field, dictionary));
            default -> throw wrongEncoding(encoding, field);
        };
    }

    public static ValueDecoder<int[]> getIntDecoder(ParquetEncoding encoding, PrimitiveField field, @Nullable Dictionary dictionary)
    {
        return switch (encoding) {
            case PLAIN, DELTA_BINARY_PACKED, RLE, BIT_PACKED, PLAIN_DICTIONARY, RLE_DICTIONARY ->
                    new IntApacheParquetValueDecoder(getApacheParquetReader(encoding, field, dictionary));
            default -> throw wrongEncoding(encoding, field);
        };
    }

    public static ValueDecoder<byte[]> getByteDecoder(ParquetEncoding encoding, PrimitiveField field, @Nullable Dictionary dictionary)
    {
        return switch (encoding) {
            case PLAIN, DELTA_BINARY_PACKED, RLE, BIT_PACKED, PLAIN_DICTIONARY, RLE_DICTIONARY ->
                    new ByteApacheParquetValueDecoder(getApacheParquetReader(encoding, field, dictionary));
            default -> throw wrongEncoding(encoding, field);
        };
    }

    public static ValueDecoder<short[]> getShortDecoder(ParquetEncoding encoding, PrimitiveField field, @Nullable Dictionary dictionary)
    {
        return switch (encoding) {
            case PLAIN, DELTA_BINARY_PACKED, RLE, BIT_PACKED, PLAIN_DICTIONARY, RLE_DICTIONARY ->
                    new ShortApacheParquetValueDecoder(getApacheParquetReader(encoding, field, dictionary));
            default -> throw wrongEncoding(encoding, field);
        };
    }

    public static ValueDecoder<byte[]> getBooleanDecoder(ParquetEncoding encoding, PrimitiveField field, @Nullable Dictionary dictionary)
    {
        return switch (encoding) {
            case PLAIN, RLE, BIT_PACKED -> new BooleanApacheParquetValueDecoder(getApacheParquetReader(encoding, field, dictionary));
            default -> throw wrongEncoding(encoding, field);
        };
    }

    private static ValueDecoder<long[]> getFixedWidthLongDecimalDecoder(ParquetEncoding encoding, PrimitiveField field, @Nullable Dictionary dictionary)
    {
        return switch (encoding) {
            case PLAIN, DELTA_BYTE_ARRAY, PLAIN_DICTIONARY, RLE_DICTIONARY ->
                    new LongDecimalApacheParquetValueDecoder(getApacheParquetReader(encoding, field, dictionary));
            default -> throw wrongEncoding(encoding, field);
        };
    }

    private static ValueDecoder<long[]> getBinaryLongDecimalDecoder(ParquetEncoding encoding, PrimitiveField field, @Nullable Dictionary dictionary)
    {
        return switch (encoding) {
            case PLAIN, DELTA_LENGTH_BYTE_ARRAY, DELTA_BYTE_ARRAY, PLAIN_DICTIONARY, RLE_DICTIONARY ->
                    new LongDecimalApacheParquetValueDecoder(getApacheParquetReader(encoding, field, dictionary));
            default -> throw wrongEncoding(encoding, field);
        };
    }

    private static ValueDecoder<long[]> getFixedWidthShortDecimalDecoder(ParquetEncoding encoding, PrimitiveField field, @Nullable Dictionary dictionary, Type trinoType, int length)
    {
        checkArgument(length > 0 && length <= 16, "Expected column %s to have type length in range (1-16)", field.getDescriptor());
        return switch (encoding) {
            case PLAIN, DELTA_BYTE_ARRAY, PLAIN_DICTIONARY, RLE_DICTIONARY -> new ShortDecimalApacheParquetValueDecoder(
                    getApacheParquetReader(encoding, field, dictionary),
                    length,
                    trinoType);
            default -> throw wrongEncoding(encoding, field);
        };
    }

    private static ValuesReader getApacheParquetReader(ParquetEncoding encoding, PrimitiveField field, @Nullable Dictionary dictionary)
    {
        if (encoding == RLE_DICTIONARY || encoding == PLAIN_DICTIONARY) {
            return encoding.getDictionaryBasedValuesReader(field.getDescriptor(), VALUES, requireNonNull(dictionary, "dictionary is null"));
        }
        return encoding.getValuesReader(field.getDescriptor(), VALUES);
    }

    private static IllegalArgumentException wrongEncoding(ParquetEncoding encoding, PrimitiveField field)
    {
        return new IllegalArgumentException("Wrong encoding " + encoding + " for column type " + field.getDescriptor().getPrimitiveType().getPrimitiveTypeName());
    }
}
