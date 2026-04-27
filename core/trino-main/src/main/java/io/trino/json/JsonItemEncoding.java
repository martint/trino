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
package io.trino.json;

import com.fasterxml.jackson.core.JsonGenerator;
import io.airlift.slice.DynamicSliceOutput;
import io.airlift.slice.Slice;
import io.airlift.slice.SliceInput;
import io.airlift.slice.SliceOutput;
import io.trino.json.ir.TypedValue;
import io.trino.operator.scalar.json.JsonOutputConversionException;
import io.trino.spi.type.BigintType;
import io.trino.spi.type.BooleanType;
import io.trino.spi.type.CharType;
import io.trino.spi.type.Chars;
import io.trino.spi.type.DateType;
import io.trino.spi.type.DecimalType;
import io.trino.spi.type.DoubleType;
import io.trino.spi.type.Int128;
import io.trino.spi.type.IntegerType;
import io.trino.spi.type.LongTimeWithTimeZone;
import io.trino.spi.type.LongTimestamp;
import io.trino.spi.type.LongTimestampWithTimeZone;
import io.trino.spi.type.NumberType;
import io.trino.spi.type.RealType;
import io.trino.spi.type.SmallintType;
import io.trino.spi.type.TimeType;
import io.trino.spi.type.TimeWithTimeZoneType;
import io.trino.spi.type.TimestampType;
import io.trino.spi.type.TimestampWithTimeZoneType;
import io.trino.spi.type.TinyintType;
import io.trino.spi.type.TrinoNumber;
import io.trino.spi.type.Type;
import io.trino.spi.type.VarcharType;

import java.io.IOException;
import java.math.BigDecimal;
import java.math.BigInteger;
import java.util.ArrayList;
import java.util.List;
import java.util.Optional;

import static io.airlift.slice.Slices.utf8Slice;
import static io.trino.json.JsonInputErrorNode.JSON_ERROR;
import static io.trino.spi.type.BigintType.BIGINT;
import static io.trino.spi.type.BooleanType.BOOLEAN;
import static io.trino.spi.type.CharType.createCharType;
import static io.trino.spi.type.DateType.DATE;
import static io.trino.spi.type.DecimalType.createDecimalType;
import static io.trino.spi.type.DoubleType.DOUBLE;
import static io.trino.spi.type.IntegerType.INTEGER;
import static io.trino.spi.type.RealType.REAL;
import static io.trino.spi.type.SmallintType.SMALLINT;
import static io.trino.spi.type.TimeType.createTimeType;
import static io.trino.spi.type.TimeWithTimeZoneType.createTimeWithTimeZoneType;
import static io.trino.spi.type.TimestampType.createTimestampType;
import static io.trino.spi.type.TimestampWithTimeZoneType.createTimestampWithTimeZoneType;
import static io.trino.spi.type.TinyintType.TINYINT;
import static io.trino.spi.type.VarcharType.createUnboundedVarcharType;
import static java.lang.Double.doubleToRawLongBits;
import static java.lang.Double.longBitsToDouble;
import static java.lang.Float.intBitsToFloat;
import static java.lang.Math.toIntExact;

public final class JsonItemEncoding
{
    // Version byte chosen from the 0xF0..0xFF range so it cannot be the first byte of valid
    // UTF-8 JSON text (which can only be ASCII for JSON structural bytes) and so it cannot be
    // confused with any ItemTag or TypeTag value. This closes the §3.2.1 ambiguity where
    // VERSION_1 = 1 collided with ItemTag.JSON_ERROR.encoded() = 1.
    private static final byte VERSION_1 = (byte) 0xF3;

    // NumberType encoding kind discriminator (follows TypeTag.NUMBER byte). Trino's NUMBER
    // type extends BigDecimal with non-finite sentinels (NaN, +Infinity, -Infinity) that JSON
    // text cannot represent; we still encode them in the binary form so round-trips through
    // path-engine intermediaries (e.g. abs(), arithmetic) preserve the value.
    private static final byte NUMBER_FINITE = 0;
    private static final byte NUMBER_NAN = 1;
    private static final byte NUMBER_POSITIVE_INFINITY = 2;
    private static final byte NUMBER_NEGATIVE_INFINITY = 3;

    enum ItemTag
    {
        JSON_ERROR(1),
        JSON_NULL(2),
        ARRAY(3),
        OBJECT(4),
        TYPED_VALUE(5);

        private final byte encoded;

        ItemTag(int encoded)
        {
            this.encoded = (byte) encoded;
        }

        public byte encoded()
        {
            return encoded;
        }

        public static ItemTag fromEncoded(byte encoded)
        {
            return switch (encoded) {
                case 1 -> JSON_ERROR;
                case 2 -> JSON_NULL;
                case 3 -> ARRAY;
                case 4 -> OBJECT;
                case 5 -> TYPED_VALUE;
                default -> throw new IllegalArgumentException("Unsupported SQL/JSON item tag");
            };
        }
    }

    enum TypeTag
    {
        BOOLEAN(1),
        VARCHAR(2),
        CHAR(3),
        BIGINT(4),
        INTEGER(5),
        SMALLINT(6),
        TINYINT(7),
        DOUBLE(8),
        REAL(9),
        DECIMAL(10),
        DATE(11),
        TIME(12),
        TIME_WITH_TIME_ZONE(13),
        TIMESTAMP(14),
        TIMESTAMP_WITH_TIME_ZONE(15),
        NUMBER(16);

        private final byte encoded;

        TypeTag(int encoded)
        {
            this.encoded = (byte) encoded;
        }

        public byte encoded()
        {
            return encoded;
        }

        public static TypeTag fromEncoded(byte encoded)
        {
            return switch (encoded) {
                case 1 -> BOOLEAN;
                case 2 -> VARCHAR;
                case 3 -> CHAR;
                case 4 -> BIGINT;
                case 5 -> INTEGER;
                case 6 -> SMALLINT;
                case 7 -> TINYINT;
                case 8 -> DOUBLE;
                case 9 -> REAL;
                case 10 -> DECIMAL;
                case 11 -> DATE;
                case 12 -> TIME;
                case 13 -> TIME_WITH_TIME_ZONE;
                case 14 -> TIMESTAMP;
                case 15 -> TIMESTAMP_WITH_TIME_ZONE;
                case 16 -> NUMBER;
                default -> throw new IllegalArgumentException("Unsupported SQL/JSON typed value tag");
            };
        }
    }

    private JsonItemEncoding() {}

    /// Encodes an SQL/JSON item as a versioned binary slice.
    public static Slice encode(JsonPathItem item)
    {
        SliceOutput output = new DynamicSliceOutput(128);
        output.appendByte(VERSION_1);
        writeItem(output, item);
        return output.slice();
    }

    /// Writes the encoding version byte. Use at the start of a fresh {@link SliceOutput} when
    /// composing a typed JSON encoding directly without the {@link #encode} entry point.
    public static void appendVersion(SliceOutput output)
    {
        output.appendByte(VERSION);
    }

    /// Writes a JSON_NULL item (one byte: the JSON_NULL item tag).
    public static void appendJsonNullItem(SliceOutput output)
    {
        output.appendByte(ItemTag.JSON_NULL.encoded());
    }

    /// Writes the header of an ARRAY item: ARRAY tag + int32 element count. The caller is
    /// responsible for writing exactly `count` items afterward.
    public static void appendArrayItemHeader(SliceOutput output, int count)
    {
        validateCount(count);
        output.appendByte(ItemTag.ARRAY.encoded());
        output.appendInt(count);
    }

    /// Writes the header of an OBJECT item: OBJECT tag + int32 member count. The caller is
    /// responsible for writing exactly `count` (key, item) pairs afterward via
    /// {@link #appendObjectKey} followed by an item.
    public static void appendObjectItemHeader(SliceOutput output, int count)
    {
        validateCount(count);
        output.appendByte(ItemTag.OBJECT.encoded());
        output.appendInt(count);
    }

    /// Writes the header of an ARRAY item with a deferred element count: ARRAY tag + 4 reserved
    /// bytes the caller must patch later via {@link Slice#setInt(int, int)} on the final slice
    /// (e.g. once streaming completes and the buffer no longer grows). Returns the offset of
    /// the placeholder.
    public static int appendArrayItemPlaceholder(SliceOutput output)
    {
        output.appendByte(ItemTag.ARRAY.encoded());
        int offset = output.size();
        output.appendInt(0);
        return offset;
    }

    /// Same as {@link #appendArrayItemPlaceholder} but for OBJECT items.
    public static int appendObjectItemPlaceholder(SliceOutput output)
    {
        output.appendByte(ItemTag.OBJECT.encoded());
        int offset = output.size();
        output.appendInt(0);
        return offset;
    }

    /// Writes an object member key as a length-prefixed UTF-8 string.
    public static void appendObjectKey(SliceOutput output, String key)
    {
        writeSlice(output, utf8Slice(key));
    }

    /// Writes a TYPED_VALUE item for a primitive `BIGINT`.
    public static void appendBigint(SliceOutput output, long value)
    {
        output.appendByte(ItemTag.TYPED_VALUE.encoded());
        output.appendByte(TypeTag.BIGINT.encoded());
        output.appendLong(value);
    }

    /// Writes a TYPED_VALUE item for a primitive `INTEGER`. Throws if `value` doesn't fit.
    public static void appendInteger(SliceOutput output, long value)
    {
        output.appendByte(ItemTag.TYPED_VALUE.encoded());
        output.appendByte(TypeTag.INTEGER.encoded());
        output.appendInt(toIntExact(value));
    }

    /// Writes a TYPED_VALUE item for a primitive `SMALLINT`. Throws if `value` doesn't fit.
    public static void appendSmallint(SliceOutput output, long value)
    {
        short shortValue = (short) value;
        if (shortValue != value) {
            throw new IllegalArgumentException("SMALLINT value out of range: " + value);
        }
        output.appendByte(ItemTag.TYPED_VALUE.encoded());
        output.appendByte(TypeTag.SMALLINT.encoded());
        output.appendShort(shortValue);
    }

    /// Writes a TYPED_VALUE item for a primitive `TINYINT`. Throws if `value` doesn't fit.
    public static void appendTinyint(SliceOutput output, long value)
    {
        byte byteValue = (byte) value;
        if (byteValue != value) {
            throw new IllegalArgumentException("TINYINT value out of range: " + value);
        }
        output.appendByte(ItemTag.TYPED_VALUE.encoded());
        output.appendByte(TypeTag.TINYINT.encoded());
        output.appendByte(byteValue);
    }

    /// Writes a TYPED_VALUE item for a primitive `DOUBLE`.
    public static void appendDouble(SliceOutput output, double value)
    {
        output.appendByte(ItemTag.TYPED_VALUE.encoded());
        output.appendByte(TypeTag.DOUBLE.encoded());
        output.appendLong(doubleToRawLongBits(value));
    }

    /// Writes a TYPED_VALUE item for a primitive `REAL`. Takes the raw IEEE 754 bit pattern
    /// (Trino's stack representation for REAL).
    public static void appendRealBits(SliceOutput output, int bits)
    {
        output.appendByte(ItemTag.TYPED_VALUE.encoded());
        output.appendByte(TypeTag.REAL.encoded());
        output.appendInt(bits);
    }

    /// Writes a TYPED_VALUE item for a primitive `BOOLEAN`.
    public static void appendBoolean(SliceOutput output, boolean value)
    {
        output.appendByte(ItemTag.TYPED_VALUE.encoded());
        output.appendByte(TypeTag.BOOLEAN.encoded());
        output.appendByte(value ? 1 : 0);
    }

    /// Writes a TYPED_VALUE item for an unbounded `VARCHAR` (which is how JSON strings are
    /// always encoded — JSON has no string-length bound).
    public static void appendVarchar(SliceOutput output, Slice value)
    {
        output.appendByte(ItemTag.TYPED_VALUE.encoded());
        output.appendByte(TypeTag.VARCHAR.encoded());
        output.appendInt(value.length());
        output.writeBytes(value);
    }

    /// Writes a TYPED_VALUE item for a `DATE` (epoch days as a long).
    public static void appendDate(SliceOutput output, long value)
    {
        output.appendByte(ItemTag.TYPED_VALUE.encoded());
        output.appendByte(TypeTag.DATE.encoded());
        output.appendLong(value);
    }

    /// Writes a TYPED_VALUE item for a `DECIMAL(precision, scale)` whose value fits in `long`.
    public static void appendShortDecimal(SliceOutput output, int precision, int scale, long value)
    {
        output.appendByte(ItemTag.TYPED_VALUE.encoded());
        output.appendByte(TypeTag.DECIMAL.encoded());
        output.appendInt(precision);
        output.appendInt(scale);
        output.appendByte(0);
        output.appendLong(value);
    }

    /// Writes a TYPED_VALUE item for a long-form `DECIMAL(precision, scale)` ({@link Int128}).
    public static void appendLongDecimal(SliceOutput output, int precision, int scale, Int128 value)
    {
        output.appendByte(ItemTag.TYPED_VALUE.encoded());
        output.appendByte(TypeTag.DECIMAL.encoded());
        output.appendInt(precision);
        output.appendInt(scale);
        output.appendByte(1);
        output.writeBytes(value.toBigEndianBytes());
    }

    /// Writes a TYPED_VALUE item for a `TIME(precision)` whose value fits in `long`.
    public static void appendShortTime(SliceOutput output, int precision, long value)
    {
        output.appendByte(ItemTag.TYPED_VALUE.encoded());
        output.appendByte(TypeTag.TIME.encoded());
        output.appendInt(precision);
        output.appendLong(value);
    }

    /// Writes a TYPED_VALUE item for a short `TIMESTAMP(precision)` (epoch micros as a long).
    public static void appendShortTimestamp(SliceOutput output, int precision, long epochMicros)
    {
        output.appendByte(ItemTag.TYPED_VALUE.encoded());
        output.appendByte(TypeTag.TIMESTAMP.encoded());
        output.appendInt(precision);
        output.appendByte(0);
        output.appendLong(epochMicros);
    }

    /// Writes a TYPED_VALUE item for a long `TIMESTAMP(precision)`.
    public static void appendLongTimestamp(SliceOutput output, int precision, LongTimestamp value)
    {
        output.appendByte(ItemTag.TYPED_VALUE.encoded());
        output.appendByte(TypeTag.TIMESTAMP.encoded());
        output.appendInt(precision);
        output.appendByte(1);
        output.appendLong(value.getEpochMicros());
        output.appendInt(value.getPicosOfMicro());
    }

    /// Writes a TYPED_VALUE item for a short `TIME(precision) WITH TIME ZONE`.
    public static void appendShortTimeWithTimeZone(SliceOutput output, int precision, long packed)
    {
        output.appendByte(ItemTag.TYPED_VALUE.encoded());
        output.appendByte(TypeTag.TIME_WITH_TIME_ZONE.encoded());
        output.appendInt(precision);
        output.appendByte(0);
        output.appendLong(packed);
    }

    /// Writes a TYPED_VALUE item for a long `TIME(precision) WITH TIME ZONE`.
    public static void appendLongTimeWithTimeZone(SliceOutput output, int precision, LongTimeWithTimeZone value)
    {
        output.appendByte(ItemTag.TYPED_VALUE.encoded());
        output.appendByte(TypeTag.TIME_WITH_TIME_ZONE.encoded());
        output.appendInt(precision);
        output.appendByte(1);
        output.appendLong(value.getPicoseconds());
        output.appendInt(value.getOffsetMinutes());
    }

    /// Writes a TYPED_VALUE item for a short `TIMESTAMP(precision) WITH TIME ZONE`.
    public static void appendShortTimestampWithTimeZone(SliceOutput output, int precision, long packed)
    {
        output.appendByte(ItemTag.TYPED_VALUE.encoded());
        output.appendByte(TypeTag.TIMESTAMP_WITH_TIME_ZONE.encoded());
        output.appendInt(precision);
        output.appendByte(0);
        output.appendLong(packed);
    }

    /// Writes a TYPED_VALUE item for a long `TIMESTAMP(precision) WITH TIME ZONE`.
    public static void appendLongTimestampWithTimeZone(SliceOutput output, int precision, LongTimestampWithTimeZone value)
    {
        output.appendByte(ItemTag.TYPED_VALUE.encoded());
        output.appendByte(TypeTag.TIMESTAMP_WITH_TIME_ZONE.encoded());
        output.appendInt(precision);
        output.appendByte(1);
        output.appendLong(value.getEpochMillis());
        output.appendInt(value.getPicosOfMilli());
        output.appendShort(value.getTimeZoneKey());
    }

    /// Writes a TYPED_VALUE item for a `NUMBER`. NaN and Infinity values are emitted as JSON
    /// strings (matching how `json_format` represents non-finite numbers).
    public static void appendNumber(SliceOutput output, TrinoNumber value)
    {
        switch (value.toBigDecimal()) {
            case TrinoNumber.NotANumber() -> appendVarchar(output, utf8Slice("NaN"));
            case TrinoNumber.Infinity(boolean negative) -> appendVarchar(output, utf8Slice(negative ? "-Infinity" : "+Infinity"));
            case TrinoNumber.BigDecimalValue(BigDecimal decimal) -> {
                byte[] unscaledBytes = decimal.unscaledValue().toByteArray();
                output.appendByte(ItemTag.TYPED_VALUE.encoded());
                output.appendByte(TypeTag.NUMBER.encoded());
                output.appendByte(NUMBER_FINITE);
                output.appendInt(decimal.scale());
                output.appendInt(unscaledBytes.length);
                output.writeBytes(unscaledBytes);
            }
        }
    }

    /// Embeds a nested {@link io.trino.type.JsonType} payload as an item. Accepts either the
    /// typed-item encoding (in which case the inner item bytes are copied) or raw JSON text
    /// (which is parsed and re-emitted). Throws if the payload is the JSON_ERROR sentinel.
    public static void appendNestedItem(SliceOutput output, Slice payload)
    {
        if (isEncoding(payload)) {
            if (isJsonError(payload)) {
                throw new IllegalArgumentException("JSON_ERROR sentinel cannot be written as a JSON value");
            }
            output.writeBytes(payload, 1, payload.length() - 1);
            return;
        }
        // Raw JSON text — parse and emit. Rare in CAST-to-JSON paths (only when a column of
        // JsonType is a member of a map/array/row being cast).
        try {
            writeItem(output, JsonItems.parseJson(new java.io.InputStreamReader(payload.getInput(), java.nio.charset.StandardCharsets.UTF_8)), 0);
        }
        catch (IOException e) {
            throw new IllegalArgumentException("Invalid JSON text", e);
        }
    }

    /// Decodes a binary-encoded SQL/JSON item produced by [#encode].
    public static JsonPathItem decode(Slice slice)
    {
        SliceInput input = slice.getInput();
        byte version = input.readByte();
        if (version != VERSION_1) {
            throw new IllegalArgumentException("Unsupported SQL/JSON item encoding version: " + version);
        }
        JsonPathItem item = readItem(input);
        if (input.available() > 0) {
            throw new IllegalArgumentException("Trailing data after SQL/JSON item");
        }
        return item;
    }

    /// Decodes a binary-encoded SQL/JSON value.
    ///
    /// Fails if the encoding represents a non-value item such as an error sentinel.
    public static MaterializedJsonValue decodeValue(Slice slice)
    {
        JsonPathItem item = decode(slice);
        if (item instanceof MaterializedJsonValue value) {
            return value;
        }
        throw new IllegalArgumentException("Expected SQL/JSON value");
    }

    /// Returns `true` if the slice starts with the current SQL/JSON item encoding version marker.
    public static boolean isEncoding(Slice slice)
    {
        return slice.length() > 0 && slice.getByte(0) == VERSION_1;
    }

    static int rootItemOffset(Slice slice)
    {
        if (!isEncoding(slice)) {
            throw new IllegalArgumentException("Unsupported SQL/JSON item encoding version: " + (slice.length() == 0 ? "<empty>" : slice.getByte(0)));
        }
        return 1;
    }

    /// Returns `true` if the slice is the canonical encoding of the `JSON_ERROR` sentinel.
    public static boolean isJsonError(Slice slice)
    {
        return slice.length() == 2 && slice.getByte(0) == VERSION_1 && slice.getByte(1) == ItemTag.JSON_ERROR.encoded();
    }

    /// Writes a binary-encoded SQL/JSON item to a JSON generator as JSON text.
    public static void writeJson(Slice slice, JsonGenerator generator)
            throws IOException
    {
        writeJson(slice, generator, false);
    }

    /// Writes a binary-encoded SQL/JSON item to a JSON generator as JSON text.
    ///
    /// When `stringifyUnsupportedScalars` is `true`, scalar types that have no native JSON
    /// representation (e.g. datetime) are rendered as JSON strings instead of raising an error.
    public static void writeJson(Slice slice, JsonGenerator generator, boolean stringifyUnsupportedScalars)
            throws IOException
    {
        SliceInput input = slice.getInput();
        byte version = input.readByte();
        if (version != VERSION_1) {
            throw new IllegalArgumentException("Unsupported SQL/JSON item encoding version: " + version);
        }
        writeJson(input, generator, stringifyUnsupportedScalars);
        if (input.available() > 0) {
            throw new IllegalArgumentException("Trailing data after SQL/JSON item");
        }
    }

    static void writeJson(Slice slice, int itemOffset, int endOffset, JsonGenerator generator, boolean stringifyUnsupportedScalars)
            throws IOException
    {
        SliceInput input = slice.slice(itemOffset, endOffset - itemOffset).getInput();
        writeJson(input, generator, stringifyUnsupportedScalars);
        if (input.available() > 0) {
            throw new IllegalArgumentException("Trailing data after SQL/JSON item");
        }
    }

    /// Returns the textual form of an encoded SQL/JSON scalar, if the item is a scalar of a type
    /// whose JSON representation is a string (VARCHAR, CHAR). Returns empty for objects, arrays,
    /// null, and non-string scalars.
    public static Optional<Slice> scalarText(Slice slice)
    {
        SliceInput input = slice.getInput();
        byte version = input.readByte();
        if (version != VERSION_1) {
            throw new IllegalArgumentException("Unsupported SQL/JSON item encoding version: " + version);
        }

        ItemTag itemTag = ItemTag.fromEncoded(input.readByte());
        if (itemTag != ItemTag.TYPED_VALUE) {
            return Optional.empty();
        }

        Optional<Slice> result = readScalarText(input);
        if (input.available() > 0) {
            throw new IllegalArgumentException("Trailing data after SQL/JSON item");
        }
        return result;
    }

    static Optional<Slice> scalarText(Slice slice, int itemOffset, int endOffset)
    {
        if (itemTag(slice, itemOffset) != ItemTag.TYPED_VALUE) {
            return Optional.empty();
        }

        SliceInput input = slice.slice(itemOffset + Byte.BYTES, endOffset - itemOffset - Byte.BYTES).getInput();
        Optional<Slice> result = readScalarText(input);
        if (input.available() > 0) {
            throw new IllegalArgumentException("Trailing data after SQL/JSON item");
        }
        return result;
    }

    static ItemTag itemTag(Slice slice, int offset)
    {
        return ItemTag.fromEncoded(slice.getByte(offset));
    }

    static int arraySize(Slice slice, int offset)
    {
        if (itemTag(slice, offset) != ItemTag.ARRAY) {
            throw new IllegalArgumentException("Expected ARRAY item");
        }
        return slice.getInt(offset + Byte.BYTES);
    }

    static int objectSize(Slice slice, int offset)
    {
        if (itemTag(slice, offset) != ItemTag.OBJECT) {
            throw new IllegalArgumentException("Expected OBJECT item");
        }
        return slice.getInt(offset + Byte.BYTES);
    }

    static int stringEndOffset(Slice slice, int offset)
    {
        return offset + Integer.BYTES + slice.getInt(offset);
    }

    static String readString(Slice slice, int offset)
    {
        return slice.slice(offset + Integer.BYTES, slice.getInt(offset)).toStringUtf8();
    }

    static int itemEndOffset(Slice slice, int offset)
    {
        return switch (itemTag(slice, offset)) {
            case JSON_ERROR, JSON_NULL -> offset + Byte.BYTES;
            case ARRAY -> arrayEndOffset(slice, offset);
            case OBJECT -> objectEndOffset(slice, offset);
            case TYPED_VALUE -> typedValueEndOffset(slice, offset + Byte.BYTES);
        };
    }

    static TypedValue readTypedValue(Slice slice, int itemOffset)
    {
        SliceInput input = slice.slice(itemOffset, slice.length() - itemOffset).getInput();
        if (ItemTag.fromEncoded(input.readByte()) != ItemTag.TYPED_VALUE) {
            throw new IllegalArgumentException("Expected TYPED_VALUE item");
        }
        return readTypedValue(input);
    }

    static JsonPathItem decodeItem(Slice slice, int itemOffset, int endOffset)
    {
        SliceInput input = slice.slice(itemOffset, endOffset - itemOffset).getInput();
        JsonPathItem item = readItem(input);
        if (input.available() > 0) {
            throw new IllegalArgumentException("Trailing data after SQL/JSON item");
        }
        return item;
    }

    static MaterializedJsonValue decodeValue(Slice slice, int itemOffset, int endOffset)
    {
        JsonPathItem item = decodeItem(slice, itemOffset, endOffset);
        if (item instanceof MaterializedJsonValue value) {
            return value;
        }
        throw new IllegalArgumentException("Expected SQL/JSON value");
    }

    static Slice copyItemEncoding(Slice slice, int itemOffset, int endOffset)
    {
        SliceOutput output = new DynamicSliceOutput(endOffset - itemOffset + 1);
        output.appendByte(VERSION_1);
        output.writeBytes(slice, itemOffset, endOffset - itemOffset);
        return output.slice();
    }

    private static void writeItem(SliceOutput output, JsonPathItem item)
    {
        if (item == JSON_ERROR) {
            output.appendByte(ItemTag.JSON_ERROR.encoded());
            return;
        }
        if (item == JsonNull.JSON_NULL) {
            output.appendByte(ItemTag.JSON_NULL.encoded());
            return;
        }
        if (item instanceof EncodedJsonItem encoded) {
            Slice encoding = encoded.encoding();
            if (encoding.length() > 1 && encoding.getByte(0) == VERSION_1) {
                byte innerTag = encoding.getByte(1);
                if (innerTag == ItemTag.JSON_ERROR.encoded()) {
                    throw new IllegalArgumentException("JSON_ERROR sentinel cannot be written as a JSON value");
                }
                output.writeBytes(encoding, 1, encoding.length() - 1);
                return;
            }
            writeItem(output, JsonItems.materialize(encoded));
            return;
        }
        if (item instanceof JsonArrayItem arrayItem) {
            output.appendByte(ItemTag.ARRAY.encoded());
            output.appendInt(arrayItem.elements().size());
            for (MaterializedJsonValue element : arrayItem.elements()) {
                writeItem(output, element);
            }
            return;
        }
        if (item instanceof JsonObjectItem objectItem) {
            output.appendByte(ItemTag.OBJECT.encoded());
            output.appendInt(objectItem.members().size());
            for (JsonObjectMember member : objectItem.members()) {
                writeSlice(output, utf8Slice(member.key()));
                writeItem(output, member.value());
            }
            return;
        }
        if (item instanceof TypedValue typedValue) {
            output.appendByte(ItemTag.TYPED_VALUE.encoded());
            writeTypedValue(output, typedValue);
            return;
        }
        throw new IllegalArgumentException("Unsupported SQL/JSON item: " + item.getClass().getSimpleName());
    }

    private static JsonPathItem readItem(SliceInput input)
    {
        return switch (ItemTag.fromEncoded(input.readByte())) {
            case JSON_ERROR -> JSON_ERROR;
            case JSON_NULL -> JsonNull.JSON_NULL;
            case ARRAY -> readArray(input);
            case OBJECT -> readObject(input);
            case TYPED_VALUE -> readTypedValue(input);
        };
    }

    private static void writeJson(SliceInput input, JsonGenerator generator, boolean stringifyUnsupportedScalars)
            throws IOException
    {
        switch (ItemTag.fromEncoded(input.readByte())) {
            case JSON_ERROR -> throw new JsonOutputConversionException("JSON item cannot be represented as JSON");
            case JSON_NULL -> generator.writeNull();
            case ARRAY -> writeArrayJson(input, generator, stringifyUnsupportedScalars);
            case OBJECT -> writeObjectJson(input, generator, stringifyUnsupportedScalars);
            case TYPED_VALUE -> writeTypedValueJson(input, generator, stringifyUnsupportedScalars);
        }
    }

    private static void writeArrayJson(SliceInput input, JsonGenerator generator, boolean stringifyUnsupportedScalars)
            throws IOException
    {
        int count = input.readInt();
        generator.writeStartArray();
        for (int i = 0; i < count; i++) {
            writeJson(input, generator, stringifyUnsupportedScalars);
        }
        generator.writeEndArray();
    }

    private static void writeObjectJson(SliceInput input, JsonGenerator generator, boolean stringifyUnsupportedScalars)
            throws IOException
    {
        int count = input.readInt();
        generator.writeStartObject();
        for (int i = 0; i < count; i++) {
            generator.writeFieldName(readSlice(input).toStringUtf8());
            writeJson(input, generator, stringifyUnsupportedScalars);
        }
        generator.writeEndObject();
    }

    private static void writeTypedValueJson(SliceInput input, JsonGenerator generator, boolean stringifyUnsupportedScalars)
            throws IOException
    {
        TypeTag typeTag = TypeTag.fromEncoded(input.readByte());
        switch (typeTag) {
            case BOOLEAN -> generator.writeBoolean(input.readByte() != 0);
            case VARCHAR -> generator.writeString(readSlice(input).toStringUtf8());
            case CHAR -> {
                CharType type = createCharType(input.readInt());
                generator.writeString(Chars.padSpaces(readSlice(input), type).toStringUtf8());
            }
            case BIGINT, INTEGER, SMALLINT, TINYINT -> generator.writeNumber(input.readLong());
            case DOUBLE -> {
                double d = longBitsToDouble(input.readLong());
                if (Double.isFinite(d)) {
                    generator.writeNumber(JsonItems.formatDouble(d));
                }
                else {
                    generator.writeString(Double.toString(d));
                }
            }
            case REAL -> {
                float f = intBitsToFloat(toIntExact(input.readLong()));
                if (Float.isFinite(f)) {
                    // Float.toString rather than BigDecimal.valueOf(float) — the latter upcasts
                    // to double first and exposes the binary approximation.
                    generator.writeNumber(Float.toString(f));
                }
                else {
                    generator.writeString(Float.toString(f));
                }
            }
            case DECIMAL -> writeDecimalJson(input, generator);
            case DATE, TIME, TIME_WITH_TIME_ZONE, TIMESTAMP, TIMESTAMP_WITH_TIME_ZONE -> {
                TypedValue typedValue = readTypedValue(input, typeTag);
                if (stringifyUnsupportedScalars) {
                    generator.writeString(JsonItems.typedValueText(typedValue));
                    break;
                }
                throw new JsonOutputConversionException("SQL/JSON value of type " + typedValue.getType().getDisplayName() + " cannot be serialized to JSON text");
            }
            case NUMBER -> {
                byte kind = input.readByte();
                switch (kind) {
                    case NUMBER_FINITE -> {
                        int scale = input.readInt();
                        int unscaledLength = input.readInt();
                        BigInteger unscaled = new BigInteger(input.readSlice(unscaledLength).getBytes());
                        generator.writeNumber(new BigDecimal(unscaled, scale));
                    }
                    case NUMBER_NAN, NUMBER_POSITIVE_INFINITY, NUMBER_NEGATIVE_INFINITY -> {
                        String label = switch (kind) {
                            case NUMBER_NAN -> "NaN";
                            case NUMBER_POSITIVE_INFINITY -> "+Infinity";
                            case NUMBER_NEGATIVE_INFINITY -> "-Infinity";
                            default -> throw new IllegalStateException();
                        };
                        throw new JsonOutputConversionException("Non-finite NUMBER value cannot be serialized to JSON text: " + label);
                    }
                    default -> throw new IllegalArgumentException("Unknown NUMBER encoding kind: " + kind);
                }
            }
        }
    }

    private static void writeDecimalJson(SliceInput input, JsonGenerator generator)
            throws IOException
    {
        DecimalType type = createDecimalType(input.readInt(), input.readInt());
        boolean longDecimal = input.readByte() != 0;
        BigInteger unscaledValue;
        if (!longDecimal) {
            unscaledValue = BigInteger.valueOf(input.readLong());
        }
        else {
            unscaledValue = Int128.fromBigEndian(input.readSlice(Int128.SIZE).getBytes()).toBigInteger();
        }
        // Emit the plain string so trailing zeros (e.g. DECIMAL(6,2) value 1234.50) survive
        // Jackson's BigDecimal stringification, which otherwise strips them in some configurations.
        generator.writeNumber(new BigDecimal(unscaledValue, type.getScale()).toPlainString());
    }

    private static Optional<Slice> readScalarText(SliceInput input)
    {
        return switch (TypeTag.fromEncoded(input.readByte())) {
            case VARCHAR -> Optional.of(readSlice(input));
            case CHAR -> {
                CharType type = createCharType(input.readInt());
                yield Optional.of(Chars.padSpaces(readSlice(input), type));
            }
            case BOOLEAN, BIGINT, INTEGER, SMALLINT, TINYINT, DOUBLE, REAL, DECIMAL,
                    DATE, TIME, TIME_WITH_TIME_ZONE, TIMESTAMP, TIMESTAMP_WITH_TIME_ZONE, NUMBER -> Optional.empty();
        };
    }

    private static JsonArrayItem readArray(SliceInput input)
    {
        int count = input.readInt();
        List<MaterializedJsonValue> elements = new ArrayList<>(count);
        for (int i = 0; i < count; i++) {
            elements.add(readValue(input));
        }
        return new JsonArrayItem(elements);
    }

    private static JsonObjectItem readObject(SliceInput input)
    {
        int count = input.readInt();
        List<JsonObjectMember> members = new ArrayList<>(count);
        for (int i = 0; i < count; i++) {
            members.add(new JsonObjectMember(readSlice(input).toStringUtf8(), readValue(input)));
        }
        return new JsonObjectItem(members);
    }

    private static MaterializedJsonValue readValue(SliceInput input)
    {
        JsonPathItem item = readItem(input);
        if (item instanceof MaterializedJsonValue value) {
            return value;
        }
        throw new IllegalArgumentException("Expected SQL/JSON value");
    }

    private static void writeTypedValue(SliceOutput output, TypedValue typedValue)
    {
        Type type = typedValue.getType();
        switch (type) {
            case BooleanType _ -> {
                output.appendByte(TypeTag.BOOLEAN.encoded());
                output.appendByte(typedValue.getBooleanValue() ? 1 : 0);
            }
            case VarcharType _ -> {
                // JSON strings don't carry a SQL-level length bound, so always encode as unbounded VARCHAR.
                // This ensures a JSON value's string type is canonical regardless of how it was created.
                output.appendByte(TypeTag.VARCHAR.encoded());
                writeSlice(output, (Slice) typedValue.getObjectValue());
            }
            case CharType charType -> {
                output.appendByte(TypeTag.CHAR.encoded());
                output.appendInt(charType.getLength());
                writeSlice(output, (Slice) typedValue.getObjectValue());
            }
            case BigintType _ -> {
                output.appendByte(TypeTag.BIGINT.encoded());
                output.appendLong(typedValue.getLongValue());
            }
            case IntegerType _ -> {
                output.appendByte(TypeTag.INTEGER.encoded());
                output.appendLong(typedValue.getLongValue());
            }
            case SmallintType _ -> {
                output.appendByte(TypeTag.SMALLINT.encoded());
                output.appendLong(typedValue.getLongValue());
            }
            case TinyintType _ -> {
                output.appendByte(TypeTag.TINYINT.encoded());
                output.appendLong(typedValue.getLongValue());
            }
            case DoubleType _ -> {
                output.appendByte(TypeTag.DOUBLE.encoded());
                output.appendLong(doubleToRawLongBits(typedValue.getDoubleValue()));
            }
            case RealType _ -> {
                output.appendByte(TypeTag.REAL.encoded());
                output.appendLong(typedValue.getLongValue());
            }
            case DecimalType decimalType -> {
                output.appendByte(TypeTag.DECIMAL.encoded());
                output.appendInt(decimalType.getPrecision());
                output.appendInt(decimalType.getScale());
                output.appendByte(decimalType.isShort() ? 0 : 1);
                if (decimalType.isShort()) {
                    output.appendLong(typedValue.getLongValue());
                }
                else {
                    output.writeBytes(((Int128) typedValue.getObjectValue()).toBigEndianBytes());
                }
            }
            case DateType _ -> {
                output.appendByte(TypeTag.DATE.encoded());
                output.appendLong(typedValue.getLongValue());
            }
            case TimeType timeType -> {
                output.appendByte(TypeTag.TIME.encoded());
                output.appendInt(timeType.getPrecision());
                output.appendLong(typedValue.getLongValue());
            }
            case TimeWithTimeZoneType timeWithTimeZoneType -> {
                output.appendByte(TypeTag.TIME_WITH_TIME_ZONE.encoded());
                output.appendInt(timeWithTimeZoneType.getPrecision());
                output.appendByte(timeWithTimeZoneType.isShort() ? 0 : 1);
                if (timeWithTimeZoneType.isShort()) {
                    output.appendLong(typedValue.getLongValue());
                }
                else {
                    LongTimeWithTimeZone value = (LongTimeWithTimeZone) typedValue.getObjectValue();
                    output.appendLong(value.getPicoseconds());
                    output.appendInt(value.getOffsetMinutes());
                }
            }
            case TimestampType timestampType -> {
                output.appendByte(TypeTag.TIMESTAMP.encoded());
                output.appendInt(timestampType.getPrecision());
                output.appendByte(timestampType.isShort() ? 0 : 1);
                if (timestampType.isShort()) {
                    output.appendLong(typedValue.getLongValue());
                }
                else {
                    LongTimestamp value = (LongTimestamp) typedValue.getObjectValue();
                    output.appendLong(value.getEpochMicros());
                    output.appendInt(value.getPicosOfMicro());
                }
            }
            case TimestampWithTimeZoneType timestampWithTimeZoneType -> {
                output.appendByte(TypeTag.TIMESTAMP_WITH_TIME_ZONE.encoded());
                output.appendInt(timestampWithTimeZoneType.getPrecision());
                output.appendByte(timestampWithTimeZoneType.isShort() ? 0 : 1);
                if (timestampWithTimeZoneType.isShort()) {
                    output.appendLong(typedValue.getLongValue());
                }
                else {
                    LongTimestampWithTimeZone value = (LongTimestampWithTimeZone) typedValue.getObjectValue();
                    output.appendLong(value.getEpochMillis());
                    output.appendInt(value.getPicosOfMilli());
                    output.appendShort(value.getTimeZoneKey());
                }
            }
            case NumberType _ -> {
                TrinoNumber number = (TrinoNumber) typedValue.getObjectValue();
                output.appendByte(TypeTag.NUMBER.encoded());
                switch (number.toBigDecimal()) {
                    case TrinoNumber.BigDecimalValue(BigDecimal decimal) -> {
                        byte[] unscaledBytes = decimal.unscaledValue().toByteArray();
                        output.appendByte(NUMBER_FINITE);
                        output.appendInt(decimal.scale());
                        output.appendInt(unscaledBytes.length);
                        output.writeBytes(unscaledBytes);
                    }
                    case TrinoNumber.Infinity(boolean negative) -> output.appendByte(negative ? NUMBER_NEGATIVE_INFINITY : NUMBER_POSITIVE_INFINITY);
                    case TrinoNumber.NotANumber _ -> output.appendByte(NUMBER_NAN);
                }
            }
            default -> throw new IllegalArgumentException("Unsupported SQL/JSON typed value: " + type.getDisplayName());
        }
    }

    private static TypedValue readTypedValue(SliceInput input)
    {
        return readTypedValue(input, TypeTag.fromEncoded(input.readByte()));
    }

    private static TypedValue readTypedValue(SliceInput input, TypeTag typeTag)
    {
        return switch (typeTag) {
            case BOOLEAN -> new TypedValue(BOOLEAN, input.readByte() != 0);
            case VARCHAR -> new TypedValue(createUnboundedVarcharType(), readSlice(input));
            case CHAR -> new TypedValue(createCharType(input.readInt()), readSlice(input));
            case BIGINT -> new TypedValue(BIGINT, input.readLong());
            case INTEGER -> new TypedValue(INTEGER, input.readLong());
            case SMALLINT -> new TypedValue(SMALLINT, input.readLong());
            case TINYINT -> new TypedValue(TINYINT, input.readLong());
            case DOUBLE -> new TypedValue(DOUBLE, longBitsToDouble(input.readLong()));
            case REAL -> new TypedValue(REAL, input.readLong());
            case DECIMAL -> {
                DecimalType type = createDecimalType(input.readInt(), input.readInt());
                boolean longDecimal = input.readByte() != 0;
                yield longDecimal
                        ? new TypedValue(type, Int128.fromBigEndian(input.readSlice(Int128.SIZE).getBytes()))
                        : new TypedValue(type, input.readLong());
            }
            case DATE -> new TypedValue(DATE, input.readLong());
            case TIME -> new TypedValue(createTimeType(input.readInt()), input.readLong());
            case TIME_WITH_TIME_ZONE -> {
                TimeWithTimeZoneType type = createTimeWithTimeZoneType(input.readInt());
                boolean longTime = input.readByte() != 0;
                yield longTime
                        ? new TypedValue(type, new LongTimeWithTimeZone(input.readLong(), input.readInt()))
                        : new TypedValue(type, input.readLong());
            }
            case TIMESTAMP -> {
                TimestampType type = createTimestampType(input.readInt());
                boolean longTimestamp = input.readByte() != 0;
                yield longTimestamp
                        ? new TypedValue(type, new LongTimestamp(input.readLong(), input.readInt()))
                        : new TypedValue(type, input.readLong());
            }
            case TIMESTAMP_WITH_TIME_ZONE -> {
                TimestampWithTimeZoneType type = createTimestampWithTimeZoneType(input.readInt());
                boolean longTimestamp = input.readByte() != 0;
                yield longTimestamp
                        ? new TypedValue(type, LongTimestampWithTimeZone.fromEpochMillisAndFraction(input.readLong(), input.readInt(), input.readShort()))
                        : new TypedValue(type, input.readLong());
            }
            case NUMBER -> {
                byte kind = input.readByte();
                yield switch (kind) {
                    case NUMBER_FINITE -> {
                        int scale = input.readInt();
                        int unscaledLength = input.readInt();
                        BigInteger unscaled = new BigInteger(input.readSlice(unscaledLength).getBytes());
                        yield new TypedValue(NumberType.NUMBER, TrinoNumber.from(new BigDecimal(unscaled, scale)));
                    }
                    case NUMBER_POSITIVE_INFINITY -> new TypedValue(NumberType.NUMBER, TrinoNumber.from(new TrinoNumber.Infinity(false)));
                    case NUMBER_NEGATIVE_INFINITY -> new TypedValue(NumberType.NUMBER, TrinoNumber.from(new TrinoNumber.Infinity(true)));
                    case NUMBER_NAN -> new TypedValue(NumberType.NUMBER, TrinoNumber.from(new TrinoNumber.NotANumber()));
                    default -> throw new IllegalArgumentException("Unknown NUMBER encoding kind: " + kind);
                };
            }
        };
    }

    private static void writeSlice(SliceOutput output, Slice value)
    {
        output.appendInt(value.length());
        output.writeBytes(value);
    }

    private static Slice readSlice(SliceInput input)
    {
        return input.readSlice(input.readInt());
    }

    private static int arrayEndOffset(Slice slice, int offset)
    {
        int count = arraySize(slice, offset);
        int currentOffset = offset + Byte.BYTES + Integer.BYTES;
        for (int index = 0; index < count; index++) {
            currentOffset = itemEndOffset(slice, currentOffset);
        }
        return currentOffset;
    }

    private static int objectEndOffset(Slice slice, int offset)
    {
        int count = objectSize(slice, offset);
        int currentOffset = offset + Byte.BYTES + Integer.BYTES;
        for (int index = 0; index < count; index++) {
            currentOffset = stringEndOffset(slice, currentOffset);
            currentOffset = itemEndOffset(slice, currentOffset);
        }
        return currentOffset;
    }

    private static int typedValueEndOffset(Slice slice, int offset)
    {
        return switch (TypeTag.fromEncoded(slice.getByte(offset))) {
            case BOOLEAN -> offset + Byte.BYTES + Byte.BYTES;
            case VARCHAR -> stringEndOffset(slice, offset + Byte.BYTES);
            case CHAR -> stringEndOffset(slice, offset + Byte.BYTES + Integer.BYTES);
            case BIGINT, INTEGER, SMALLINT, TINYINT, DOUBLE, REAL -> offset + Byte.BYTES + Long.BYTES;
            case DECIMAL -> decimalEndOffset(slice, offset + Byte.BYTES);
            case DATE -> offset + Byte.BYTES + Long.BYTES;
            case TIME -> offset + Byte.BYTES + Integer.BYTES + Long.BYTES;
            case TIME_WITH_TIME_ZONE -> timeWithTimeZoneEndOffset(slice, offset + Byte.BYTES);
            case TIMESTAMP -> timestampEndOffset(slice, offset + Byte.BYTES);
            case TIMESTAMP_WITH_TIME_ZONE -> timestampWithTimeZoneEndOffset(slice, offset + Byte.BYTES);
            case NUMBER -> numberEndOffset(slice, offset + Byte.BYTES);
        };
    }

    private static int numberEndOffset(Slice slice, int offset)
    {
        byte kind = slice.getByte(offset);
        offset += Byte.BYTES;
        if (kind != NUMBER_FINITE) {
            return offset;
        }
        offset += Integer.BYTES; // scale
        int unscaledLength = slice.getInt(offset);
        return offset + Integer.BYTES + unscaledLength;
    }

    private static int decimalEndOffset(Slice slice, int offset)
    {
        offset += Integer.BYTES; // precision
        offset += Integer.BYTES; // scale
        boolean longDecimal = slice.getByte(offset) != 0;
        offset += Byte.BYTES;
        return offset + (longDecimal ? Int128.SIZE : Long.BYTES);
    }

    private static int timeWithTimeZoneEndOffset(Slice slice, int offset)
    {
        offset += Integer.BYTES; // precision
        boolean longTime = slice.getByte(offset) != 0;
        offset += Byte.BYTES;
        return offset + (longTime ? Long.BYTES + Integer.BYTES : Long.BYTES);
    }

    private static int timestampEndOffset(Slice slice, int offset)
    {
        offset += Integer.BYTES; // precision
        boolean longTimestamp = slice.getByte(offset) != 0;
        offset += Byte.BYTES;
        return offset + (longTimestamp ? Long.BYTES + Integer.BYTES : Long.BYTES);
    }

    private static int timestampWithTimeZoneEndOffset(Slice slice, int offset)
    {
        offset += Integer.BYTES; // precision
        boolean longTimestamp = slice.getByte(offset) != 0;
        offset += Byte.BYTES;
        return offset + (longTimestamp ? Long.BYTES + Integer.BYTES + Short.BYTES : Long.BYTES);
    }
}
