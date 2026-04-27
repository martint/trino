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
import java.io.InputStreamReader;
import java.math.BigDecimal;
import java.math.BigInteger;
import java.nio.charset.StandardCharsets;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;
import java.util.Optional;

import static com.google.common.base.Preconditions.checkArgument;
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

/// Binary encoding for SQL/JSON items.
///
/// Wire format:
/// ```
///   encoding         := version (1 byte) item
///   item             := itemTag (1 byte) item-body
///   array            := ARRAY int32-count item*
///   array-indexed    := ARRAY_INDEXED int32-count int32-offsets[count+1] item*
///   object           := OBJECT int32-count (string item)*
///   object-indexed   := OBJECT_INDEXED int32-count uint16-sortPerm[count]
///                       int32-offsets[count+1] (string item)*
///   typed            := TYPED_VALUE typeTag (1 byte) type-body
///   typed-number     := TYPED_VALUE NUMBER kind-byte number-body
///                       (kind: FINITE | NAN | POSITIVE_INFINITY | NEGATIVE_INFINITY;
///                        number-body: present only for FINITE)
///   string           := int32-length UTF-8 bytes
/// ```
///
/// The version byte (`VERSION = 0xF3`) is chosen from the `0xF0..0xFF` range so it cannot
/// collide with any UTF-8 leading byte that could start a valid JSON document, allowing a
/// single byte to disambiguate between this encoding and raw JSON text in shared
/// `Slice`-typed payloads.
///
/// `ARRAY_INDEXED` and `OBJECT_INDEXED` are alternate forms emitted only when a container
/// has at least [#INDEXED_CONTAINER_THRESHOLD] entries; below the threshold the offsets
/// table is pure overhead. `OBJECT_INDEXED` additionally caps at
/// [#MAX_OBJECT_INDEXED_COUNT] entries (uint16 sort-permutation slots) and falls back to
/// plain `OBJECT` above that. The indexed forms support O(1) element access (array) and
/// O(log n) keyed lookup (object), while preserving insertion order for iteration.
///
/// Encoding depth is capped at [#MAX_DEPTH] to guard against pathologically nested input.
///
/// Endianness: numeric fixed-width fields (int, long, double bit-pattern, variable-width
/// length prefixes) are written little-endian via [SliceOutput] / [SliceInput]. The one
/// exception is [Int128], which is serialized via its canonical big-endian byte form to
/// match the layout used elsewhere in the SPI for decimal values.
public final class JsonItemEncoding
{
    // Version byte chosen from the 0xF0..0xFF range so it cannot be the first byte of valid
    // UTF-8 JSON text (which can only be ASCII for JSON structural bytes) and so it cannot
    // collide with any ItemTag or TypeTag value.
    static final byte VERSION = (byte) 0xF3;
    // Guard against pathologically deep input encodings; matches Jackson's default nesting limit.
    private static final int MAX_DEPTH = 1000;

    /// Containers with at least this many entries are emitted in indexed form
    /// ([ItemTag#ARRAY_INDEXED]). Below this threshold the offsets table
    /// is pure overhead — linear scan is competitive with binary search /
    /// random access for small entry counts and the offsets table dominates
    /// the encoded size.
    public static final int INDEXED_CONTAINER_THRESHOLD = 8;

    /// Maximum entry count that fits in a [ItemTag#OBJECT_INDEXED] sort permutation
    /// (uint16 entries). Objects with more entries fall back to [ItemTag#OBJECT].
    public static final int MAX_OBJECT_INDEXED_COUNT = 0xFFFF;

    // NumberType encoding kind discriminator (follows TypeTag.NUMBER byte). Trino's NUMBER
    // type extends BigDecimal with non-finite sentinels (NaN, +Infinity, -Infinity) that JSON
    // text cannot represent; we still encode them in the binary form so round-trips through
    // path-engine intermediaries (e.g. abs(), arithmetic) preserve the value.
    private static final byte NUMBER_FINITE = 0;
    private static final byte NUMBER_NAN = 1;
    private static final byte NUMBER_POSITIVE_INFINITY = 2;
    private static final byte NUMBER_NEGATIVE_INFINITY = 3;

    public enum ItemTag
    {
        JSON_ERROR(1),
        JSON_NULL(2),
        ARRAY(3),
        OBJECT(4),
        TYPED_VALUE(5),
        /// Same logical kind as [#ARRAY] but with an offset table for O(1) element access.
        /// Layout: tag(1) + count(int32) + offsets[count+1](int32 each) + items*.
        /// `offsets[0] = 0`; `offsets[count]` = total items size. Element `i` occupies
        /// `[items_start + offsets[i], items_start + offsets[i+1])`.
        ARRAY_INDEXED(6),
        /// Same logical kind as [#OBJECT] but with a sort permutation and offsets table
        /// for O(log n) member lookup by key. Entries stay in insertion order so json_format
        /// and forEachObjectMember preserve input order.
        ///
        /// Layout: `tag(1) + count(int32) + sortPerm[count](uint16 each) +
        /// offsets[count+1](int32 each) + (keyLen + keyBytes + item)*count`.
        /// `sortPerm[i]` = the entry index whose key sorts to position `i` (lex byte order).
        /// `offsets[0]` = 0; `offsets[count]` = entries section size.
        OBJECT_INDEXED(7);

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
                case 6 -> ARRAY_INDEXED;
                case 7 -> OBJECT_INDEXED;
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
        appendVersion(output);
        writeItem(output, item, 0);
        return output.slice();
    }

    /// Writes the encoding version byte. Use at the start of a fresh [SliceOutput] when
    /// composing a typed JSON encoding directly without the [#encode] entry point.
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
    static void appendArrayItemHeader(SliceOutput output, int count)
    {
        output.appendByte(ItemTag.ARRAY.encoded());
        output.appendInt(count);
    }

    /// Writes the header of an OBJECT item: OBJECT tag + int32 member count. The caller is
    /// responsible for writing exactly `count` (key, item) pairs afterward via
    /// [#appendObjectKey] followed by an item.
    public static void appendObjectItemHeader(SliceOutput output, int count)
    {
        output.appendByte(ItemTag.OBJECT.encoded());
        output.appendInt(count);
    }

    /// Writes the header of an ARRAY item with a deferred element count: ARRAY tag + 4 reserved
    /// bytes the caller must patch later via [Slice#setInt(int, int)] on the final slice
    /// (e.g. once streaming completes and the buffer no longer grows). Returns the offset of
    /// the placeholder.
    public static int appendArrayItemPlaceholder(SliceOutput output)
    {
        output.appendByte(ItemTag.ARRAY.encoded());
        int offset = output.size();
        output.appendInt(0);
        return offset;
    }

    /// Same as [#appendArrayItemPlaceholder] but for OBJECT items.
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
    static void appendInteger(SliceOutput output, long value)
    {
        output.appendByte(ItemTag.TYPED_VALUE.encoded());
        output.appendByte(TypeTag.INTEGER.encoded());
        output.appendInt(toIntExact(value));
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

    /// Writes a TYPED_VALUE item for a long-form `DECIMAL(precision, scale)` ([Int128]).
    public static void appendLongDecimal(SliceOutput output, int precision, int scale, Int128 value)
    {
        output.appendByte(ItemTag.TYPED_VALUE.encoded());
        output.appendByte(TypeTag.DECIMAL.encoded());
        output.appendInt(precision);
        output.appendInt(scale);
        output.appendByte(1);
        output.writeBytes(value.toBigEndianBytes());
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

    /// Embeds a nested [io.trino.type.JsonType] payload as an item. Accepts either the
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
            writeItem(output, JsonItems.parseJson(new InputStreamReader(payload.getInput(), StandardCharsets.UTF_8)), 0);
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
        if (version != VERSION) {
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
        return slice.length() > 0 && slice.getByte(0) == VERSION;
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
        return slice.length() == 2 && slice.getByte(0) == VERSION && slice.getByte(1) == ItemTag.JSON_ERROR.encoded();
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
        if (version != VERSION) {
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
        if (version != VERSION) {
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
        ItemTag tag = itemTag(slice, offset);
        if (tag != ItemTag.ARRAY && tag != ItemTag.ARRAY_INDEXED) {
            throw new IllegalArgumentException("Expected ARRAY item");
        }
        int count = slice.getInt(offset + Byte.BYTES);
        validateCount(count);
        return count;
    }

    /// Returns the byte offset of the first element of an ARRAY-shaped item (either
    /// [ItemTag#ARRAY] or [ItemTag#ARRAY_INDEXED]). The result is the start of
    /// the items section — past the count field and (if indexed) past the offsets table.
    static int arrayItemsStart(Slice slice, int offset)
    {
        ItemTag tag = itemTag(slice, offset);
        return switch (tag) {
            case ARRAY -> offset + Byte.BYTES + Integer.BYTES;
            case ARRAY_INDEXED -> {
                int count = slice.getInt(offset + Byte.BYTES);
                yield offset + Byte.BYTES + Integer.BYTES + (count + 1) * Integer.BYTES;
            }
            default -> throw new IllegalArgumentException("Expected ARRAY item");
        };
    }

    /// For an [ItemTag#ARRAY_INDEXED] item, returns the absolute byte offset of the
    /// element at `index`. The caller must ensure `0 <= index < arraySize(...)`.
    static int arrayIndexedElementOffset(Slice slice, int offset, int index)
    {
        // offsets[i] follows: tag(1) + count(4) + i*4
        int offsetsTableStart = offset + Byte.BYTES + Integer.BYTES;
        int count = slice.getInt(offset + Byte.BYTES);
        return offset + Byte.BYTES + Integer.BYTES + (count + 1) * Integer.BYTES
                + slice.getInt(offsetsTableStart + index * Integer.BYTES);
    }

    static int objectSize(Slice slice, int offset)
    {
        ItemTag tag = itemTag(slice, offset);
        if (tag != ItemTag.OBJECT && tag != ItemTag.OBJECT_INDEXED) {
            throw new IllegalArgumentException("Expected OBJECT item");
        }
        int count = slice.getInt(offset + Byte.BYTES);
        validateCount(count);
        return count;
    }

    /// Returns the byte offset of the first entry of an OBJECT-shaped item (either
    /// [ItemTag#OBJECT] or [ItemTag#OBJECT_INDEXED]). The result is past the
    /// count field and (if indexed) past the sort permutation and offsets table.
    static int objectEntriesStart(Slice slice, int offset)
    {
        ItemTag tag = itemTag(slice, offset);
        return switch (tag) {
            case OBJECT -> offset + Byte.BYTES + Integer.BYTES;
            case OBJECT_INDEXED -> {
                int count = slice.getInt(offset + Byte.BYTES);
                int afterCount = offset + Byte.BYTES + Integer.BYTES;
                int afterPerm = afterCount + count * Short.BYTES;
                int afterOffsets = afterPerm + (count + 1) * Integer.BYTES;
                yield afterOffsets;
            }
            default -> throw new IllegalArgumentException("Expected OBJECT item");
        };
    }

    /// For an [ItemTag#OBJECT_INDEXED] item, returns the entry index of the key
    /// at sort position `sortedIndex`. The caller must ensure `0 <= sortedIndex < count`.
    static int objectIndexedSortPerm(Slice slice, int offset, int sortedIndex)
    {
        int permStart = offset + Byte.BYTES + Integer.BYTES;
        return slice.getShort(permStart + sortedIndex * Short.BYTES) & 0xFFFF;
    }

    /// For an [ItemTag#OBJECT_INDEXED] item, returns the absolute byte offset of the
    /// entry (key+value pair) at insertion-order index `entryIndex`.
    static int objectIndexedEntryOffset(Slice slice, int offset, int entryIndex)
    {
        int count = slice.getInt(offset + Byte.BYTES);
        int permStart = offset + Byte.BYTES + Integer.BYTES;
        int offsetsStart = permStart + count * Short.BYTES;
        int entriesStart = offsetsStart + (count + 1) * Integer.BYTES;
        return entriesStart + slice.getInt(offsetsStart + entryIndex * Integer.BYTES);
    }

    /// For an [ItemTag#OBJECT_INDEXED] item, returns the byte offset where the entry
    /// at insertion-order index `entryIndex` ends.
    static int objectIndexedEntryEnd(Slice slice, int offset, int entryIndex)
    {
        int count = slice.getInt(offset + Byte.BYTES);
        int permStart = offset + Byte.BYTES + Integer.BYTES;
        int offsetsStart = permStart + count * Short.BYTES;
        int entriesStart = offsetsStart + (count + 1) * Integer.BYTES;
        return entriesStart + slice.getInt(offsetsStart + (entryIndex + 1) * Integer.BYTES);
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
            case ARRAY_INDEXED -> arrayIndexedEndOffset(slice, offset);
            case OBJECT -> objectEndOffset(slice, offset);
            case OBJECT_INDEXED -> objectIndexedEndOffset(slice, offset);
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
        output.appendByte(VERSION);
        output.writeBytes(slice, itemOffset, endOffset - itemOffset);
        return output.slice();
    }

    private static void writeItem(SliceOutput output, JsonPathItem item, int depth)
    {
        if (depth > MAX_DEPTH) {
            throw new IllegalArgumentException("JSON item nesting exceeds maximum depth of " + MAX_DEPTH);
        }
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
            if (encoding.length() > 1 && encoding.getByte(0) == VERSION) {
                byte innerTag = encoding.getByte(1);
                if (innerTag == ItemTag.JSON_ERROR.encoded()) {
                    throw new IllegalArgumentException("JSON_ERROR sentinel cannot be written as a JSON value");
                }
                output.writeBytes(encoding, 1, encoding.length() - 1);
                return;
            }
            writeItem(output, JsonItems.materialize(encoded), depth);
            return;
        }
        if (item instanceof JsonArrayItem arrayItem) {
            List<MaterializedJsonValue> elements = arrayItem.elements();
            int count = elements.size();
            if (count >= INDEXED_CONTAINER_THRESHOLD) {
                // Buffer items so we know their sizes before writing the offsets table. The
                // alternative — writing items inline and patching offsets afterward — would
                // require setInt on the output's underlying slice, fragile if the buffer
                // grows mid-write.
                DynamicSliceOutput items = new DynamicSliceOutput(count * 8);
                int[] offsets = new int[count + 1];
                for (int i = 0; i < count; i++) {
                    offsets[i] = items.size();
                    writeItem(items, elements.get(i), depth + 1);
                }
                offsets[count] = items.size();

                output.appendByte(ItemTag.ARRAY_INDEXED.encoded());
                output.appendInt(count);
                for (int o : offsets) {
                    output.appendInt(o);
                }
                output.writeBytes(items.slice());
            }
            else {
                output.appendByte(ItemTag.ARRAY.encoded());
                output.appendInt(count);
                for (MaterializedJsonValue element : elements) {
                    writeItem(output, element, depth + 1);
                }
            }
            return;
        }
        if (item instanceof JsonObjectItem objectItem) {
            List<JsonObjectMember> members = objectItem.members();
            int count = members.size();
            if (count >= INDEXED_CONTAINER_THRESHOLD && count <= MAX_OBJECT_INDEXED_COUNT) {
                writeObjectIndexed(output, members, depth);
            }
            else {
                output.appendByte(ItemTag.OBJECT.encoded());
                output.appendInt(count);
                for (JsonObjectMember member : members) {
                    writeSlice(output, utf8Slice(member.key()));
                    writeItem(output, member.value(), depth + 1);
                }
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
        return readItem(input, 0);
    }

    private static JsonPathItem readItem(SliceInput input, int depth)
    {
        if (depth > MAX_DEPTH) {
            throw new IllegalArgumentException("JSON item nesting exceeds maximum depth of " + MAX_DEPTH);
        }
        return switch (ItemTag.fromEncoded(input.readByte())) {
            case JSON_ERROR -> JSON_ERROR;
            case JSON_NULL -> JsonNull.JSON_NULL;
            case ARRAY -> readArray(input, depth + 1);
            case ARRAY_INDEXED -> readArrayIndexed(input, depth + 1);
            case OBJECT -> readObject(input, depth + 1);
            case OBJECT_INDEXED -> readObjectIndexed(input, depth + 1);
            case TYPED_VALUE -> readTypedValue(input);
        };
    }

    private static void writeJson(SliceInput input, JsonGenerator generator, boolean stringifyUnsupportedScalars)
            throws IOException
    {
        writeJson(input, generator, stringifyUnsupportedScalars, 0);
    }

    private static void writeJson(SliceInput input, JsonGenerator generator, boolean stringifyUnsupportedScalars, int depth)
            throws IOException
    {
        if (depth > MAX_DEPTH) {
            throw new JsonOutputConversionException(new IllegalArgumentException("JSON item nesting exceeds maximum depth of " + MAX_DEPTH));
        }
        switch (ItemTag.fromEncoded(input.readByte())) {
            case JSON_ERROR -> throw new JsonOutputConversionException("JSON item cannot be represented as JSON");
            case JSON_NULL -> generator.writeNull();
            case ARRAY -> writeArrayJson(input, generator, stringifyUnsupportedScalars, depth + 1);
            case ARRAY_INDEXED -> writeArrayIndexedJson(input, generator, stringifyUnsupportedScalars, depth + 1);
            case OBJECT -> writeObjectJson(input, generator, stringifyUnsupportedScalars, depth + 1);
            case OBJECT_INDEXED -> writeObjectIndexedJson(input, generator, stringifyUnsupportedScalars, depth + 1);
            case TYPED_VALUE -> writeTypedValueJson(input, generator, stringifyUnsupportedScalars);
        }
    }

    private static void writeArrayJson(SliceInput input, JsonGenerator generator, boolean stringifyUnsupportedScalars, int depth)
            throws IOException
    {
        int count = input.readInt();
        // Each element is at least 1 byte (item tag); guards truncated input.
        validateContainerCount(count, input, 1);
        generator.writeStartArray();
        for (int i = 0; i < count; i++) {
            writeJson(input, generator, stringifyUnsupportedScalars, depth);
        }
        generator.writeEndArray();
    }

    private static void writeArrayIndexedJson(SliceInput input, JsonGenerator generator, boolean stringifyUnsupportedScalars, int depth)
            throws IOException
    {
        int count = input.readInt();
        if (count > MAX_OBJECT_INDEXED_COUNT) {
            throw new IllegalArgumentException("SQL/JSON ARRAY_INDEXED count exceeds maximum: " + count);
        }
        // Each indexed array element costs (Integer.BYTES offset entry) + ≥1 item byte.
        validateContainerCount(count, input, Integer.BYTES + 1);
        // Skip the offsets table — we walk items in sequence, no random access needed.
        input.skip((long) (count + 1) * Integer.BYTES);
        generator.writeStartArray();
        for (int i = 0; i < count; i++) {
            writeJson(input, generator, stringifyUnsupportedScalars, depth);
        }
        generator.writeEndArray();
    }

    private static void writeObjectIndexedJson(SliceInput input, JsonGenerator generator, boolean stringifyUnsupportedScalars, int depth)
            throws IOException
    {
        int count = input.readInt();
        if (count > MAX_OBJECT_INDEXED_COUNT) {
            throw new IllegalArgumentException("SQL/JSON OBJECT_INDEXED count exceeds maximum: " + count);
        }
        // Each indexed object entry costs sortPerm short + offset int + ≥1 byte (key + item).
        validateContainerCount(count, input, Short.BYTES + Integer.BYTES + 1);
        // Skip sortPerm + offsets — entries are walked in insertion order.
        input.skip(count * Short.BYTES + (count + 1) * Integer.BYTES);
        generator.writeStartObject();
        for (int i = 0; i < count; i++) {
            generator.writeFieldName(readSlice(input).toStringUtf8());
            writeJson(input, generator, stringifyUnsupportedScalars, depth);
        }
        generator.writeEndObject();
    }

    private static void writeObjectJson(SliceInput input, JsonGenerator generator, boolean stringifyUnsupportedScalars, int depth)
            throws IOException
    {
        int count = input.readInt();
        // Each member is at least: 4-byte key length + 0 key bytes + 1-byte item tag.
        validateContainerCount(count, input, Integer.BYTES + 1);
        generator.writeStartObject();
        for (int i = 0; i < count; i++) {
            generator.writeFieldName(readSlice(input).toStringUtf8());
            writeJson(input, generator, stringifyUnsupportedScalars, depth);
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
            case BIGINT -> generator.writeNumber(input.readLong());
            case INTEGER -> generator.writeNumber(input.readInt());
            case SMALLINT -> generator.writeNumber(input.readShort());
            case TINYINT -> generator.writeNumber(input.readByte());
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
                float f = intBitsToFloat(input.readInt());
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

    private static JsonArrayItem readArray(SliceInput input, int depth)
    {
        int count = input.readInt();
        validateCount(count);
        List<MaterializedJsonValue> elements = new ArrayList<>(count);
        for (int i = 0; i < count; i++) {
            elements.add(readValue(input, depth));
        }
        return new JsonArrayItem(elements);
    }

    private static JsonArrayItem readArrayIndexed(SliceInput input, int depth)
    {
        int count = input.readInt();
        validateCount(count);
        // Skip offsets table — sequential read doesn't use it.
        input.skip((long) (count + 1) * Integer.BYTES);
        List<MaterializedJsonValue> elements = new ArrayList<>(count);
        for (int i = 0; i < count; i++) {
            elements.add(readValue(input, depth));
        }
        return new JsonArrayItem(elements);
    }

    private static void writeObjectIndexed(SliceOutput output, List<JsonObjectMember> members, int depth)
    {
        int count = members.size();

        // Buffer entries into a temp output so we can compute their offsets and write the
        // header (count + sortPerm + offsets) before the entry bytes.
        DynamicSliceOutput entries = new DynamicSliceOutput(count * 16);
        Slice[] keyBytes = new Slice[count];
        int[] offsets = new int[count + 1];
        for (int i = 0; i < count; i++) {
            offsets[i] = entries.size();
            JsonObjectMember member = members.get(i);
            Slice key = utf8Slice(member.key());
            keyBytes[i] = key;
            writeSlice(entries, key);
            writeItem(entries, member.value(), depth + 1);
        }
        offsets[count] = entries.size();

        // Build the sort permutation: sortPerm[i] is the entry index whose key is i-th in
        // lexicographic UTF-8 byte order. Keys are compared as raw bytes (Slice.compareTo)
        // so reads can probe with the same byte-level comparison.
        Integer[] perm = new Integer[count];
        for (int i = 0; i < count; i++) {
            perm[i] = i;
        }
        Arrays.sort(perm, (a, b) -> keyBytes[a].compareTo(keyBytes[b]));

        output.appendByte(ItemTag.OBJECT_INDEXED.encoded());
        output.appendInt(count);
        for (Integer p : perm) {
            // sortPerm entries are stored as uint16; OBJECT_INDEXED is gated on
            // count <= MAX_OBJECT_INDEXED_COUNT (= 0xFFFF) at the call site, so this is
            // a sanity check on the invariant.
            checkArgument(p >= 0 && p <= 0xFFFF, "sortPerm entry out of uint16 range: %s", p);
            output.appendShort(p);
        }
        for (int o : offsets) {
            output.appendInt(o);
        }
        output.writeBytes(entries.slice());
    }

    private static JsonObjectItem readObject(SliceInput input, int depth)
    {
        int count = input.readInt();
        validateCount(count);
        List<JsonObjectMember> members = new ArrayList<>(count);
        for (int i = 0; i < count; i++) {
            members.add(new JsonObjectMember(readSlice(input).toStringUtf8(), readValue(input, depth)));
        }
        return new JsonObjectItem(members);
    }

    private static JsonObjectItem readObjectIndexed(SliceInput input, int depth)
    {
        int count = input.readInt();
        validateCount(count);
        // Skip sortPerm + offsets — sequential read produces the entries in insertion order.
        input.skip(count * Short.BYTES + (count + 1) * Integer.BYTES);
        List<JsonObjectMember> members = new ArrayList<>(count);
        for (int i = 0; i < count; i++) {
            members.add(new JsonObjectMember(readSlice(input).toStringUtf8(), readValue(input, depth)));
        }
        return new JsonObjectItem(members);
    }

    private static MaterializedJsonValue readValue(SliceInput input, int depth)
    {
        JsonPathItem item = readItem(input, depth);
        if (item instanceof MaterializedJsonValue value) {
            return value;
        }
        throw new IllegalArgumentException("Expected SQL/JSON value");
    }

    private static void validateCount(int count)
    {
        if (count < 0) {
            throw new IllegalArgumentException("Negative SQL/JSON container count: " + count);
        }
    }

    /// Decoder-side count check: same lower bound as `validateCount`, plus a sanity check
    /// against the remaining slice length so that a corrupted or truncated payload doesn't
    /// drive a multi-million-iteration loop or an oversized `skip` before the decoder fails
    /// at the next read.
    private static void validateContainerCount(int count, SliceInput input, int minBytesPerEntry)
    {
        validateCount(count);
        long minBytesNeeded = (long) count * minBytesPerEntry;
        if (minBytesNeeded > input.available()) {
            throw new IllegalArgumentException("SQL/JSON container count exceeds remaining payload: " + count);
        }
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
                output.appendInt(toIntExact(typedValue.getLongValue()));
            }
            case SmallintType _ -> {
                output.appendByte(TypeTag.SMALLINT.encoded());
                short shortValue = (short) typedValue.getLongValue();
                if (shortValue != typedValue.getLongValue()) {
                    throw new IllegalArgumentException("SMALLINT value out of range: " + typedValue.getLongValue());
                }
                output.appendShort(shortValue);
            }
            case TinyintType _ -> {
                output.appendByte(TypeTag.TINYINT.encoded());
                byte byteValue = (byte) typedValue.getLongValue();
                if (byteValue != typedValue.getLongValue()) {
                    throw new IllegalArgumentException("TINYINT value out of range: " + typedValue.getLongValue());
                }
                output.appendByte(byteValue);
            }
            case DoubleType _ -> {
                output.appendByte(TypeTag.DOUBLE.encoded());
                output.appendLong(doubleToRawLongBits(typedValue.getDoubleValue()));
            }
            case RealType _ -> {
                output.appendByte(TypeTag.REAL.encoded());
                output.appendInt(toIntExact(typedValue.getLongValue()));
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
            case INTEGER -> new TypedValue(INTEGER, (long) input.readInt());
            case SMALLINT -> new TypedValue(SMALLINT, (long) input.readShort());
            case TINYINT -> new TypedValue(TINYINT, (long) input.readByte());
            case DOUBLE -> new TypedValue(DOUBLE, longBitsToDouble(input.readLong()));
            case REAL -> new TypedValue(REAL, (long) input.readInt());
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
        int length = input.readInt();
        if (length < 0 || length > input.available()) {
            throw new IllegalArgumentException("Invalid SQL/JSON slice length: " + length);
        }
        return input.readSlice(length);
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

    /// O(1) end-offset for [ItemTag#ARRAY_INDEXED]: the items section ends at
    /// items_start + offsets[count]. No walk needed.
    private static int arrayIndexedEndOffset(Slice slice, int offset)
    {
        int count = slice.getInt(offset + Byte.BYTES);
        validateCount(count);
        // offsets[count] = total items size; lives at offset + 1(tag) + 4(count) + count*4
        int offsetsTableStart = offset + Byte.BYTES + Integer.BYTES;
        int itemsSize = slice.getInt(offsetsTableStart + count * Integer.BYTES);
        return offsetsTableStart + (count + 1) * Integer.BYTES + itemsSize;
    }

    /// O(1) end-offset for [ItemTag#OBJECT_INDEXED]: the entries section ends at
    /// entries_start + offsets[count].
    private static int objectIndexedEndOffset(Slice slice, int offset)
    {
        int count = slice.getInt(offset + Byte.BYTES);
        validateCount(count);
        int permEnd = offset + Byte.BYTES + Integer.BYTES + count * Short.BYTES;
        int entriesSize = slice.getInt(permEnd + count * Integer.BYTES);
        return permEnd + (count + 1) * Integer.BYTES + entriesSize;
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
            case BIGINT, DOUBLE -> offset + Byte.BYTES + Long.BYTES;
            case INTEGER, REAL -> offset + Byte.BYTES + Integer.BYTES;
            case SMALLINT -> offset + Byte.BYTES + Short.BYTES;
            case TINYINT -> offset + Byte.BYTES + Byte.BYTES;
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
