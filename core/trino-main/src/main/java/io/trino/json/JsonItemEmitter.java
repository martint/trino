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

import io.airlift.slice.Slice;
import io.airlift.slice.SliceOutput;
import io.trino.json.JsonItemEncoding.ItemTag;
import io.trino.json.JsonItemEncoding.TypeTag;
import io.trino.spi.TrinoException;
import io.trino.spi.block.Block;
import io.trino.spi.block.SqlMap;
import io.trino.spi.block.SqlRow;
import io.trino.spi.type.ArrayType;
import io.trino.spi.type.BigintType;
import io.trino.spi.type.BooleanType;
import io.trino.spi.type.CharType;
import io.trino.spi.type.DateType;
import io.trino.spi.type.DecimalType;
import io.trino.spi.type.Decimals;
import io.trino.spi.type.DoubleType;
import io.trino.spi.type.Int128;
import io.trino.spi.type.IntegerType;
import io.trino.spi.type.LongTimeWithTimeZone;
import io.trino.spi.type.LongTimestamp;
import io.trino.spi.type.LongTimestampWithTimeZone;
import io.trino.spi.type.MapType;
import io.trino.spi.type.NumberType;
import io.trino.spi.type.RealType;
import io.trino.spi.type.RowType;
import io.trino.spi.type.SmallintType;
import io.trino.spi.type.TimeType;
import io.trino.spi.type.TimeWithTimeZoneType;
import io.trino.spi.type.TimestampType;
import io.trino.spi.type.TimestampWithTimeZoneType;
import io.trino.spi.type.TinyintType;
import io.trino.spi.type.TrinoNumber;
import io.trino.spi.type.Type;
import io.trino.spi.type.VarcharType;
import io.trino.type.JsonType;
import io.trino.type.UnknownType;

import java.math.BigDecimal;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;
import java.util.TreeMap;

import static io.trino.json.JsonItemEncoding.appendArrayItemHeader;
import static io.trino.json.JsonItemEncoding.appendJsonNullItem;
import static io.trino.json.JsonItemEncoding.appendNestedItem;
import static io.trino.json.JsonItemEncoding.appendObjectItemHeader;
import static io.trino.json.JsonItemEncoding.appendObjectKey;
import static io.trino.spi.StandardErrorCode.INVALID_FUNCTION_ARGUMENT;
import static io.trino.spi.type.BigintType.BIGINT;
import static io.trino.spi.type.BooleanType.BOOLEAN;
import static io.trino.spi.type.DateType.DATE;
import static io.trino.spi.type.DoubleType.DOUBLE;
import static io.trino.spi.type.IntegerType.INTEGER;
import static io.trino.spi.type.NumberType.NUMBER;
import static io.trino.spi.type.RealType.REAL;
import static io.trino.spi.type.SmallintType.SMALLINT;
import static io.trino.spi.type.TinyintType.TINYINT;
import static java.lang.Double.doubleToRawLongBits;
import static java.lang.Float.floatToRawIntBits;
import static java.lang.String.format;
import static java.util.Objects.requireNonNull;

/// Writes a value at (Block, position) directly into the typed-item JSON binary encoding.
///
/// Used by the `CAST(map/array/row AS JSON)` paths to skip the Jackson text round-trip:
/// instead of generating canonical JSON text and re-parsing it into the typed encoding,
/// emitters write the binary form directly.
public interface JsonItemEmitter
{
    /// Writes a single item starting at the current cursor of `output`. If the value at
    /// `(block, position)` is null, writes a `JSON_NULL` item. Otherwise writes the
    /// type-specific representation.
    void emit(SliceOutput output, Block block, int position);

    /// Provides the canonical text form of a key value, used for object keys when emitting
    /// `CAST(map AS JSON)`. The text form drives sorting (so map output is in sorted-key order).
    interface KeyExtractor
    {
        String getKey(Block block, int position);
    }

    static JsonItemEmitter create(Type type)
    {
        requireNonNull(type, "type is null");
        if (type instanceof UnknownType) {
            return UNKNOWN;
        }
        if (type instanceof BooleanType) {
            return BOOLEAN_EMITTER;
        }
        if (type instanceof BigintType) {
            return new LongEmitter(TypeTag.BIGINT, BIGINT);
        }
        if (type instanceof IntegerType) {
            return INTEGER_EMITTER;
        }
        if (type instanceof SmallintType) {
            return SMALLINT_EMITTER;
        }
        if (type instanceof TinyintType) {
            return TINYINT_EMITTER;
        }
        if (type instanceof RealType) {
            return REAL_EMITTER;
        }
        if (type instanceof DoubleType) {
            return DOUBLE_EMITTER;
        }
        if (type instanceof DecimalType decimalType) {
            return decimalType.isShort()
                    ? new ShortDecimalEmitter(decimalType)
                    : new LongDecimalEmitter(decimalType);
        }
        if (type instanceof NumberType) {
            return NUMBER_EMITTER;
        }
        if (type instanceof VarcharType varcharType) {
            return new VarcharEmitter(varcharType);
        }
        if (type instanceof CharType charType) {
            return new CharEmitter(charType);
        }
        if (type instanceof JsonType) {
            return JSON_EMITTER;
        }
        if (type instanceof DateType) {
            return DATE_EMITTER;
        }
        if (type instanceof TimeType timeType) {
            return new TimeEmitter(timeType);
        }
        if (type instanceof TimeWithTimeZoneType timeWithTimeZoneType) {
            return new TimeWithTimeZoneEmitter(timeWithTimeZoneType);
        }
        if (type instanceof TimestampType timestampType) {
            return new TimestampEmitter(timestampType);
        }
        if (type instanceof TimestampWithTimeZoneType timestampWithTimeZoneType) {
            return new TimestampWithTimeZoneEmitter(timestampWithTimeZoneType);
        }
        if (type instanceof ArrayType arrayType) {
            return new ArrayEmitter(arrayType, create(arrayType.getElementType()));
        }
        if (type instanceof MapType mapType) {
            return new MapEmitter(mapType, KeyExtractors.create(mapType.getKeyType()), create(mapType.getValueType()));
        }
        if (type instanceof RowType rowType) {
            List<JsonItemEmitter> fieldEmitters = new ArrayList<>(rowType.getFields().size());
            for (RowType.Field field : rowType.getFields()) {
                fieldEmitters.add(create(field.getType()));
            }
            return new RowEmitter(rowType, fieldEmitters);
        }
        throw new TrinoException(INVALID_FUNCTION_ARGUMENT, format("Unsupported type: %s", type));
    }

    JsonItemEmitter UNKNOWN = (output, _, _) -> appendJsonNullItem(output);

    JsonItemEmitter BOOLEAN_EMITTER = (output, block, position) -> {
        if (block.isNull(position)) {
            appendJsonNullItem(output);
            return;
        }
        output.appendByte(ItemTag.TYPED_VALUE.encoded());
        output.appendByte(TypeTag.BOOLEAN.encoded());
        output.appendByte(BOOLEAN.getBoolean(block, position) ? 1 : 0);
    };

    JsonItemEmitter INTEGER_EMITTER = (output, block, position) -> {
        if (block.isNull(position)) {
            appendJsonNullItem(output);
            return;
        }
        output.appendByte(ItemTag.TYPED_VALUE.encoded());
        output.appendByte(TypeTag.INTEGER.encoded());
        output.appendInt(INTEGER.getInt(block, position));
    };

    JsonItemEmitter SMALLINT_EMITTER = (output, block, position) -> {
        if (block.isNull(position)) {
            appendJsonNullItem(output);
            return;
        }
        output.appendByte(ItemTag.TYPED_VALUE.encoded());
        output.appendByte(TypeTag.SMALLINT.encoded());
        output.appendShort(SMALLINT.getShort(block, position));
    };

    JsonItemEmitter TINYINT_EMITTER = (output, block, position) -> {
        if (block.isNull(position)) {
            appendJsonNullItem(output);
            return;
        }
        output.appendByte(ItemTag.TYPED_VALUE.encoded());
        output.appendByte(TypeTag.TINYINT.encoded());
        output.appendByte(TINYINT.getByte(block, position));
    };

    JsonItemEmitter REAL_EMITTER = (output, block, position) -> {
        if (block.isNull(position)) {
            appendJsonNullItem(output);
            return;
        }
        output.appendByte(ItemTag.TYPED_VALUE.encoded());
        output.appendByte(TypeTag.REAL.encoded());
        output.appendInt(floatToRawIntBits(REAL.getFloat(block, position)));
    };

    JsonItemEmitter DOUBLE_EMITTER = (output, block, position) -> {
        if (block.isNull(position)) {
            appendJsonNullItem(output);
            return;
        }
        output.appendByte(ItemTag.TYPED_VALUE.encoded());
        output.appendByte(TypeTag.DOUBLE.encoded());
        output.appendLong(doubleToRawLongBits(DOUBLE.getDouble(block, position)));
    };

    JsonItemEmitter DATE_EMITTER = (output, block, position) -> {
        if (block.isNull(position)) {
            appendJsonNullItem(output);
            return;
        }
        output.appendByte(ItemTag.TYPED_VALUE.encoded());
        output.appendByte(TypeTag.DATE.encoded());
        output.appendLong(DATE.getInt(block, position));
    };

    JsonItemEmitter NUMBER_EMITTER = (output, block, position) -> {
        if (block.isNull(position)) {
            appendJsonNullItem(output);
            return;
        }
        TrinoNumber number = (TrinoNumber) NUMBER.getObject(block, position);
        switch (number.toBigDecimal()) {
            case TrinoNumber.NotANumber() -> emitVarchar(output, "NaN");
            case TrinoNumber.Infinity(boolean negative) -> emitVarchar(output, negative ? "-Infinity" : "+Infinity");
            case TrinoNumber.BigDecimalValue(BigDecimal decimal) -> {
                byte[] unscaledBytes = decimal.unscaledValue().toByteArray();
                output.appendByte(ItemTag.TYPED_VALUE.encoded());
                output.appendByte(TypeTag.NUMBER.encoded());
                output.appendByte((byte) 0); // NUMBER_FINITE
                output.appendInt(decimal.scale());
                output.appendInt(unscaledBytes.length);
                output.writeBytes(unscaledBytes);
            }
        }
    };

    private static void emitVarchar(SliceOutput output, String text)
    {
        Slice bytes = io.airlift.slice.Slices.utf8Slice(text);
        output.appendByte(ItemTag.TYPED_VALUE.encoded());
        output.appendByte(TypeTag.VARCHAR.encoded());
        output.appendInt(bytes.length());
        output.writeBytes(bytes);
    }

    JsonItemEmitter JSON_EMITTER = (output, block, position) -> {
        if (block.isNull(position)) {
            appendJsonNullItem(output);
            return;
        }
        Slice payload = JsonType.JSON.getSlice(block, position);
        appendNestedItem(output, payload);
    };

    final class LongEmitter
            implements JsonItemEmitter
    {
        private final TypeTag tag;
        private final Type type;

        LongEmitter(TypeTag tag, Type type)
        {
            this.tag = tag;
            this.type = type;
        }

        @Override
        public void emit(SliceOutput output, Block block, int position)
        {
            if (block.isNull(position)) {
                appendJsonNullItem(output);
                return;
            }
            output.appendByte(ItemTag.TYPED_VALUE.encoded());
            output.appendByte(tag.encoded());
            output.appendLong(type.getLong(block, position));
        }
    }

    final class ShortDecimalEmitter
            implements JsonItemEmitter
    {
        private final DecimalType type;

        ShortDecimalEmitter(DecimalType type)
        {
            this.type = type;
        }

        @Override
        public void emit(SliceOutput output, Block block, int position)
        {
            if (block.isNull(position)) {
                appendJsonNullItem(output);
                return;
            }
            output.appendByte(ItemTag.TYPED_VALUE.encoded());
            output.appendByte(TypeTag.DECIMAL.encoded());
            output.appendInt(type.getPrecision());
            output.appendInt(type.getScale());
            output.appendByte(0);
            output.appendLong(type.getLong(block, position));
        }
    }

    final class LongDecimalEmitter
            implements JsonItemEmitter
    {
        private final DecimalType type;

        LongDecimalEmitter(DecimalType type)
        {
            this.type = type;
        }

        @Override
        public void emit(SliceOutput output, Block block, int position)
        {
            if (block.isNull(position)) {
                appendJsonNullItem(output);
                return;
            }
            output.appendByte(ItemTag.TYPED_VALUE.encoded());
            output.appendByte(TypeTag.DECIMAL.encoded());
            output.appendInt(type.getPrecision());
            output.appendInt(type.getScale());
            output.appendByte(1);
            Int128 value = (Int128) type.getObject(block, position);
            output.writeBytes(value.toBigEndianBytes());
        }
    }

    final class VarcharEmitter
            implements JsonItemEmitter
    {
        private final VarcharType type;

        VarcharEmitter(VarcharType type)
        {
            this.type = type;
        }

        @Override
        public void emit(SliceOutput output, Block block, int position)
        {
            if (block.isNull(position)) {
                appendJsonNullItem(output);
                return;
            }
            // JSON strings are unbounded VARCHAR — match the encoding in JsonItemEncoding.writeTypedValue.
            Slice value = type.getSlice(block, position);
            output.appendByte(ItemTag.TYPED_VALUE.encoded());
            output.appendByte(TypeTag.VARCHAR.encoded());
            output.appendInt(value.length());
            output.writeBytes(value);
        }
    }

    final class CharEmitter
            implements JsonItemEmitter
    {
        private final CharType type;

        CharEmitter(CharType type)
        {
            this.type = type;
        }

        @Override
        public void emit(SliceOutput output, Block block, int position)
        {
            if (block.isNull(position)) {
                appendJsonNullItem(output);
                return;
            }
            Slice value = type.getSlice(block, position);
            output.appendByte(ItemTag.TYPED_VALUE.encoded());
            output.appendByte(TypeTag.CHAR.encoded());
            output.appendInt(type.getLength());
            output.appendInt(value.length());
            output.writeBytes(value);
        }
    }

    final class TimeEmitter
            implements JsonItemEmitter
    {
        private final TimeType type;

        TimeEmitter(TimeType type)
        {
            this.type = type;
        }

        @Override
        public void emit(SliceOutput output, Block block, int position)
        {
            if (block.isNull(position)) {
                appendJsonNullItem(output);
                return;
            }
            output.appendByte(ItemTag.TYPED_VALUE.encoded());
            output.appendByte(TypeTag.TIME.encoded());
            output.appendInt(type.getPrecision());
            output.appendLong(type.getLong(block, position));
        }
    }

    final class TimeWithTimeZoneEmitter
            implements JsonItemEmitter
    {
        private final TimeWithTimeZoneType type;

        TimeWithTimeZoneEmitter(TimeWithTimeZoneType type)
        {
            this.type = type;
        }

        @Override
        public void emit(SliceOutput output, Block block, int position)
        {
            if (block.isNull(position)) {
                appendJsonNullItem(output);
                return;
            }
            output.appendByte(ItemTag.TYPED_VALUE.encoded());
            output.appendByte(TypeTag.TIME_WITH_TIME_ZONE.encoded());
            output.appendInt(type.getPrecision());
            if (type.isShort()) {
                output.appendByte(0);
                output.appendLong(type.getLong(block, position));
            }
            else {
                output.appendByte(1);
                LongTimeWithTimeZone value = (LongTimeWithTimeZone) type.getObject(block, position);
                output.appendLong(value.getPicoseconds());
                output.appendInt(value.getOffsetMinutes());
            }
        }
    }

    final class TimestampEmitter
            implements JsonItemEmitter
    {
        private final TimestampType type;

        TimestampEmitter(TimestampType type)
        {
            this.type = type;
        }

        @Override
        public void emit(SliceOutput output, Block block, int position)
        {
            if (block.isNull(position)) {
                appendJsonNullItem(output);
                return;
            }
            output.appendByte(ItemTag.TYPED_VALUE.encoded());
            output.appendByte(TypeTag.TIMESTAMP.encoded());
            output.appendInt(type.getPrecision());
            if (type.isShort()) {
                output.appendByte(0);
                output.appendLong(type.getLong(block, position));
            }
            else {
                output.appendByte(1);
                LongTimestamp value = (LongTimestamp) type.getObject(block, position);
                output.appendLong(value.getEpochMicros());
                output.appendInt(value.getPicosOfMicro());
            }
        }
    }

    final class TimestampWithTimeZoneEmitter
            implements JsonItemEmitter
    {
        private final TimestampWithTimeZoneType type;

        TimestampWithTimeZoneEmitter(TimestampWithTimeZoneType type)
        {
            this.type = type;
        }

        @Override
        public void emit(SliceOutput output, Block block, int position)
        {
            if (block.isNull(position)) {
                appendJsonNullItem(output);
                return;
            }
            output.appendByte(ItemTag.TYPED_VALUE.encoded());
            output.appendByte(TypeTag.TIMESTAMP_WITH_TIME_ZONE.encoded());
            output.appendInt(type.getPrecision());
            if (type.isShort()) {
                output.appendByte(0);
                output.appendLong(type.getLong(block, position));
            }
            else {
                output.appendByte(1);
                LongTimestampWithTimeZone value = (LongTimestampWithTimeZone) type.getObject(block, position);
                output.appendLong(value.getEpochMillis());
                output.appendInt(value.getPicosOfMilli());
                output.appendShort(value.getTimeZoneKey());
            }
        }
    }

    final class ArrayEmitter
            implements JsonItemEmitter
    {
        private final ArrayType type;
        private final JsonItemEmitter elementEmitter;

        ArrayEmitter(ArrayType type, JsonItemEmitter elementEmitter)
        {
            this.type = type;
            this.elementEmitter = elementEmitter;
        }

        @Override
        public void emit(SliceOutput output, Block block, int position)
        {
            if (block.isNull(position)) {
                appendJsonNullItem(output);
                return;
            }
            Block arrayBlock = type.getObject(block, position);
            int count = arrayBlock.getPositionCount();
            if (count >= JsonItemEncoding.INDEXED_CONTAINER_THRESHOLD) {
                // Buffer items so we can write the offsets table before them.
                io.airlift.slice.DynamicSliceOutput items = new io.airlift.slice.DynamicSliceOutput(count * 8);
                int[] offsets = new int[count + 1];
                for (int i = 0; i < count; i++) {
                    offsets[i] = items.size();
                    elementEmitter.emit(items, arrayBlock, i);
                }
                offsets[count] = items.size();

                output.appendByte(JsonItemEncoding.ItemTag.ARRAY_INDEXED.encoded());
                output.appendInt(count);
                for (int o : offsets) {
                    output.appendInt(o);
                }
                output.writeBytes(items.slice());
            }
            else {
                appendArrayItemHeader(output, count);
                for (int i = 0; i < count; i++) {
                    elementEmitter.emit(output, arrayBlock, i);
                }
            }
        }
    }

    final class MapEmitter
            implements JsonItemEmitter
    {
        private final MapType type;
        private final KeyExtractor keyExtractor;
        private final JsonItemEmitter valueEmitter;

        MapEmitter(MapType type, KeyExtractor keyExtractor, JsonItemEmitter valueEmitter)
        {
            this.type = type;
            this.keyExtractor = keyExtractor;
            this.valueEmitter = valueEmitter;
        }

        @Override
        public void emit(SliceOutput output, Block block, int position)
        {
            if (block.isNull(position)) {
                appendJsonNullItem(output);
                return;
            }
            SqlMap sqlMap = type.getObject(block, position);
            int rawOffset = sqlMap.getRawOffset();
            Block rawKeyBlock = sqlMap.getRawKeyBlock();
            Block rawValueBlock = sqlMap.getRawValueBlock();

            // Sort by string key to produce canonical key order — matches the existing
            // text-emitting cast.
            Map<String, Integer> orderedKeyToValuePosition = new TreeMap<>();
            for (int i = 0; i < sqlMap.getSize(); i++) {
                String key = keyExtractor.getKey(rawKeyBlock, rawOffset + i);
                orderedKeyToValuePosition.put(key, i);
            }
            int count = orderedKeyToValuePosition.size();
            if (count >= JsonItemEncoding.INDEXED_CONTAINER_THRESHOLD && count <= JsonItemEncoding.MAX_OBJECT_INDEXED_COUNT) {
                // Buffer entries to compute offsets. Entries are already in lexicographic
                // key order (TreeMap), so sortPerm is the identity permutation.
                io.airlift.slice.DynamicSliceOutput entries = new io.airlift.slice.DynamicSliceOutput(count * 16);
                int[] offsets = new int[count + 1];
                int idx = 0;
                for (Map.Entry<String, Integer> entry : orderedKeyToValuePosition.entrySet()) {
                    offsets[idx] = entries.size();
                    appendObjectKey(entries, entry.getKey());
                    valueEmitter.emit(entries, rawValueBlock, rawOffset + entry.getValue());
                    idx++;
                }
                offsets[count] = entries.size();

                output.appendByte(JsonItemEncoding.ItemTag.OBJECT_INDEXED.encoded());
                output.appendInt(count);
                for (int i = 0; i < count; i++) {
                    output.appendShort(i);
                }
                for (int o : offsets) {
                    output.appendInt(o);
                }
                output.writeBytes(entries.slice());
            }
            else {
                appendObjectItemHeader(output, count);
                for (Map.Entry<String, Integer> entry : orderedKeyToValuePosition.entrySet()) {
                    appendObjectKey(output, entry.getKey());
                    valueEmitter.emit(output, rawValueBlock, rawOffset + entry.getValue());
                }
            }
        }
    }

    final class RowEmitter
            implements JsonItemEmitter
    {
        private final RowType type;
        private final List<JsonItemEmitter> fieldEmitters;
        private final List<String> fieldNames;

        RowEmitter(RowType type, List<JsonItemEmitter> fieldEmitters)
        {
            this.type = type;
            this.fieldEmitters = fieldEmitters;
            List<String> names = new ArrayList<>(type.getFields().size());
            for (RowType.Field field : type.getFields()) {
                names.add(field.getName().orElse(""));
            }
            this.fieldNames = names;
        }

        @Override
        public void emit(SliceOutput output, Block block, int position)
        {
            if (block.isNull(position)) {
                appendJsonNullItem(output);
                return;
            }
            SqlRow sqlRow = type.getObject(block, position);
            int rawIndex = sqlRow.getRawIndex();
            int fieldCount = sqlRow.getFieldCount();
            if (fieldCount >= JsonItemEncoding.INDEXED_CONTAINER_THRESHOLD && fieldCount <= JsonItemEncoding.MAX_OBJECT_INDEXED_COUNT) {
                // Row fields are emitted in declaration order (insertion order); compute the
                // sort permutation by lex byte order on field names so binary-search lookups
                // on the resulting OBJECT_INDEXED payload work.
                io.airlift.slice.DynamicSliceOutput entries = new io.airlift.slice.DynamicSliceOutput(fieldCount * 16);
                int[] offsets = new int[fieldCount + 1];
                Slice[] keyBytes = new Slice[fieldCount];
                for (int i = 0; i < fieldCount; i++) {
                    offsets[i] = entries.size();
                    String name = fieldNames.get(i);
                    keyBytes[i] = io.airlift.slice.Slices.utf8Slice(name);
                    appendObjectKey(entries, name);
                    fieldEmitters.get(i).emit(entries, sqlRow.getRawFieldBlock(i), rawIndex);
                }
                offsets[fieldCount] = entries.size();

                Integer[] perm = new Integer[fieldCount];
                for (int i = 0; i < fieldCount; i++) {
                    perm[i] = i;
                }
                java.util.Arrays.sort(perm, (a, b) -> keyBytes[a].compareTo(keyBytes[b]));

                output.appendByte(JsonItemEncoding.ItemTag.OBJECT_INDEXED.encoded());
                output.appendInt(fieldCount);
                for (Integer p : perm) {
                    output.appendShort(p);
                }
                for (int o : offsets) {
                    output.appendInt(o);
                }
                output.writeBytes(entries.slice());
                return;
            }
            appendObjectItemHeader(output, fieldCount);
            for (int i = 0; i < fieldCount; i++) {
                appendObjectKey(output, fieldNames.get(i));
                fieldEmitters.get(i).emit(output, sqlRow.getRawFieldBlock(i), rawIndex);
            }
        }
    }

    /// Map-key text extraction for `CAST(map AS JSON)`. Mirrors {@code JsonUtil.ObjectKeyProvider}
    /// but lives in the same package as the emitter to avoid a cross-package dependency.
    final class KeyExtractors
    {
        private KeyExtractors() {}

        public static KeyExtractor create(Type keyType)
        {
            if (keyType instanceof UnknownType) {
                return (_, _) -> null;
            }
            if (keyType instanceof BooleanType) {
                return (block, position) -> BOOLEAN.getBoolean(block, position) ? "true" : "false";
            }
            if (keyType instanceof TinyintType) {
                return (block, position) -> String.valueOf(TINYINT.getByte(block, position));
            }
            if (keyType instanceof SmallintType) {
                return (block, position) -> String.valueOf(SMALLINT.getShort(block, position));
            }
            if (keyType instanceof IntegerType) {
                return (block, position) -> String.valueOf(INTEGER.getInt(block, position));
            }
            if (keyType instanceof BigintType) {
                return (block, position) -> String.valueOf(BIGINT.getLong(block, position));
            }
            if (keyType instanceof RealType) {
                return (block, position) -> String.valueOf(REAL.getFloat(block, position));
            }
            if (keyType instanceof DoubleType) {
                return (block, position) -> String.valueOf(DOUBLE.getDouble(block, position));
            }
            if (keyType instanceof DecimalType decimalType) {
                if (decimalType.isShort()) {
                    return (block, position) -> Decimals.toString(decimalType.getLong(block, position), decimalType.getScale());
                }
                return (block, position) -> Decimals.toString(
                        ((Int128) decimalType.getObject(block, position)).toBigInteger(),
                        decimalType.getScale());
            }
            if (keyType instanceof VarcharType varcharType) {
                return (block, position) -> varcharType.getSlice(block, position).toStringUtf8();
            }
            if (keyType instanceof CharType charType) {
                // CHAR(n) is logically PAD SPACE: trailing spaces are not significant. Trim
                // them so the JSON object key reflects the user's content rather than the
                // storage padding (e.g. CHAR(5) 'ab' becomes key "ab", not "ab   "). This
                // also keeps CHAR-keyed and VARCHAR-keyed maps producing the same JSON shape
                // for the same logical key.
                return (block, position) -> io.trino.spi.type.Chars.trimTrailingSpaces(charType.getSlice(block, position)).toStringUtf8();
            }
            throw new TrinoException(INVALID_FUNCTION_ARGUMENT, format("Unsupported map key type for cast to JSON: %s", keyType));
        }
    }
}
