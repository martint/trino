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
package io.trino.type;

import io.airlift.slice.Slice;
import io.trino.json.JsonArrayItem;
import io.trino.json.JsonItems;
import io.trino.json.JsonNull;
import io.trino.json.JsonObjectItem;
import io.trino.json.JsonObjectMember;
import io.trino.json.JsonValue;
import io.trino.json.JsonValueView;
import io.trino.json.ir.TypedValue;
import io.trino.spi.TrinoException;
import io.trino.spi.function.LiteralParameter;
import io.trino.spi.function.LiteralParameters;
import io.trino.spi.function.ScalarOperator;
import io.trino.spi.function.SqlNullable;
import io.trino.spi.function.SqlType;
import io.trino.spi.type.BigintType;
import io.trino.spi.type.BooleanType;
import io.trino.spi.type.CharType;
import io.trino.spi.type.DateType;
import io.trino.spi.type.DecimalType;
import io.trino.spi.type.DoubleType;
import io.trino.spi.type.Int128;
import io.trino.spi.type.IntegerType;
import io.trino.spi.type.LongTimestamp;
import io.trino.spi.type.LongTimestampWithTimeZone;
import io.trino.spi.type.RealType;
import io.trino.spi.type.SmallintType;
import io.trino.spi.type.StandardTypes;
import io.trino.spi.type.TimeType;
import io.trino.spi.type.TimeWithTimeZoneType;
import io.trino.spi.type.TimeZoneKey;
import io.trino.spi.type.TimestampType;
import io.trino.spi.type.TimestampWithTimeZoneType;
import io.trino.spi.type.TinyintType;
import io.trino.spi.type.Type;
import io.trino.spi.type.VarcharType;
import io.trino.spi.variant.Header;
import io.trino.spi.variant.Variant;
import io.trino.util.variant.VariantUtil;
import io.trino.util.variant.VariantWriter;

import java.math.BigDecimal;
import java.math.BigInteger;
import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

import static io.airlift.slice.Slices.utf8Slice;
import static io.trino.spi.StandardErrorCode.INVALID_CAST_ARGUMENT;
import static io.trino.spi.StandardErrorCode.INVALID_FUNCTION_ARGUMENT;
import static io.trino.spi.function.OperatorType.CAST;
import static io.trino.spi.function.OperatorType.SUBSCRIPT;
import static io.trino.spi.type.BooleanType.BOOLEAN;
import static io.trino.spi.type.DateTimeEncoding.unpackMillisUtc;
import static io.trino.spi.type.DateTimeEncoding.unpackZoneKey;
import static io.trino.spi.type.DateType.DATE;
import static io.trino.spi.type.DecimalType.createDecimalType;
import static io.trino.spi.type.Decimals.encodeScaledValue;
import static io.trino.spi.type.Decimals.encodeShortScaledValue;
import static io.trino.spi.type.DoubleType.DOUBLE;
import static io.trino.spi.type.IntegerType.INTEGER;
import static io.trino.spi.type.RealType.REAL;
import static io.trino.spi.type.SmallintType.SMALLINT;
import static io.trino.spi.type.TimeType.createTimeType;
import static io.trino.spi.type.TimeZoneKey.UTC_KEY;
import static io.trino.spi.type.TimestampType.createTimestampType;
import static io.trino.spi.type.TimestampWithTimeZoneType.createTimestampWithTimeZoneType;
import static io.trino.spi.type.TinyintType.TINYINT;
import static io.trino.spi.type.VarcharType.VARCHAR;
import static java.lang.Float.floatToRawIntBits;
import static java.lang.Float.intBitsToFloat;
import static java.lang.Math.addExact;
import static java.lang.Math.floorDiv;
import static java.lang.Math.floorMod;
import static java.lang.Math.multiplyExact;
import static java.lang.Math.toIntExact;
import static java.util.Locale.ENGLISH;

public final class VariantOperators
{
    private static final VariantWriter LEGACY_JSON_VARIANT_WRITER = VariantWriter.create(JsonType.JSON);

    private VariantOperators() {}

    @ScalarOperator(SUBSCRIPT)
    @SqlType(StandardTypes.VARIANT)
    public static Variant dereference(@SqlType(StandardTypes.VARIANT) Variant value, @SqlType(StandardTypes.BIGINT) long index)
    {
        if (value.basicType() != Header.BasicType.ARRAY) {
            throw new TrinoException(INVALID_FUNCTION_ARGUMENT, "VARIANT value is %s, not an array".formatted(variantTypeName(value)));
        }
        checkArrayIndex(index, value.getArrayLength());
        return value.getArrayElement(toIntExact(index) - 1);
    }

    private static void checkArrayIndex(long index, int arrayLength)
    {
        if (index == 0) {
            throw new TrinoException(INVALID_FUNCTION_ARGUMENT, "VARIANT array indices start at 1");
        }
        if (index < 0) {
            throw new TrinoException(INVALID_FUNCTION_ARGUMENT, "VARIANT array subscript is negative: " + index);
        }
        if (index > arrayLength) {
            throw new TrinoException(INVALID_FUNCTION_ARGUMENT, "VARIANT array subscript must be less than or equal to array length: %d > %d".formatted(index, arrayLength));
        }
    }

    @SqlNullable
    @ScalarOperator(SUBSCRIPT)
    @SqlType(StandardTypes.VARIANT)
    public static Variant dereference(@SqlType(StandardTypes.VARIANT) Variant value, @SqlType(StandardTypes.VARCHAR) Slice fieldName)
    {
        if (value.basicType() != Header.BasicType.OBJECT) {
            throw new TrinoException(INVALID_FUNCTION_ARGUMENT, "VARIANT value is %s, not an object".formatted(variantTypeName(value)));
        }
        return value.getObjectField(fieldName).orElse(null);
    }

    private static String variantTypeName(Variant value)
    {
        if (value == null) {
            return "null";
        }
        return switch (value.basicType()) {
            case PRIMITIVE -> value.primitiveType().name().toLowerCase(ENGLISH);
            case SHORT_STRING -> "string";
            case OBJECT, ARRAY -> value.basicType().name().toLowerCase(ENGLISH);
        };
    }

    @SqlNullable
    @ScalarOperator(CAST)
    @SqlType(StandardTypes.BOOLEAN)
    public static Boolean castToBoolean(@SqlType(StandardTypes.VARIANT) Variant value)
    {
        return VariantUtil.asBoolean(value);
    }

    @ScalarOperator(CAST)
    @SqlType(StandardTypes.VARIANT)
    public static Variant castFromBoolean(@SqlType(StandardTypes.BOOLEAN) boolean value)
    {
        return Variant.ofBoolean(value);
    }

    @SqlNullable
    @ScalarOperator(CAST)
    @SqlType(StandardTypes.TINYINT)
    public static Long castToTinyint(@SqlType(StandardTypes.VARIANT) Variant value)
    {
        return VariantUtil.asTinyint(value);
    }

    @ScalarOperator(CAST)
    @SqlType(StandardTypes.VARIANT)
    public static Variant castFromTinyint(@SqlType(StandardTypes.TINYINT) long value)
    {
        return Variant.ofByte((byte) value);
    }

    @SqlNullable
    @ScalarOperator(CAST)
    @SqlType(StandardTypes.SMALLINT)
    public static Long castToSmallint(@SqlType(StandardTypes.VARIANT) Variant value)
    {
        return VariantUtil.asSmallint(value);
    }

    @ScalarOperator(CAST)
    @SqlType(StandardTypes.VARIANT)
    public static Variant castFromSmallint(@SqlType(StandardTypes.SMALLINT) long value)
    {
        return Variant.ofShort((short) value);
    }

    @SqlNullable
    @ScalarOperator(CAST)
    @SqlType(StandardTypes.INTEGER)
    public static Long castToInteger(@SqlType(StandardTypes.VARIANT) Variant value)
    {
        return VariantUtil.asInteger(value);
    }

    @ScalarOperator(CAST)
    @SqlType(StandardTypes.VARIANT)
    public static Variant castFromInteger(@SqlType(StandardTypes.INTEGER) long value)
    {
        return Variant.ofInt((int) value);
    }

    @SqlNullable
    @ScalarOperator(CAST)
    @SqlType(StandardTypes.BIGINT)
    public static Long castToBigint(@SqlType(StandardTypes.VARIANT) Variant value)
    {
        return VariantUtil.asBigint(value);
    }

    @ScalarOperator(CAST)
    @SqlType(StandardTypes.VARIANT)
    public static Variant castFromBigint(@SqlType(StandardTypes.BIGINT) long value)
    {
        return Variant.ofLong(value);
    }

    @SqlNullable
    @ScalarOperator(CAST)
    @SqlType(StandardTypes.REAL)
    public static Long castToReal(@SqlType(StandardTypes.VARIANT) Variant value)
    {
        return VariantUtil.asReal(value);
    }

    @ScalarOperator(CAST)
    @SqlType(StandardTypes.VARIANT)
    public static Variant castFromReal(@SqlType(StandardTypes.REAL) long value)
    {
        float floatValue = intBitsToFloat((int) value);
        return Variant.ofFloat(floatValue);
    }

    @SqlNullable
    @ScalarOperator(CAST)
    @SqlType(StandardTypes.DOUBLE)
    public static Double castToDouble(@SqlType(StandardTypes.VARIANT) Variant value)
    {
        return VariantUtil.asDouble(value);
    }

    @ScalarOperator(CAST)
    @SqlType(StandardTypes.VARIANT)
    public static Variant castFromDouble(@SqlType(StandardTypes.DOUBLE) double value)
    {
        return Variant.ofDouble(value);
    }

    @SqlNullable
    @ScalarOperator(CAST)
    @SqlType(StandardTypes.VARCHAR)
    public static Slice castToVarchar(@SqlType(StandardTypes.VARIANT) Variant value)
    {
        return VariantUtil.asVarchar(value);
    }

    @ScalarOperator(CAST)
    @LiteralParameters("x")
    @SqlType(StandardTypes.VARIANT)
    public static Variant castFromVarchar(@SqlType("varchar(x)") Slice value)
    {
        return Variant.ofString(value);
    }

    @SqlNullable
    @ScalarOperator(CAST)
    @SqlType(StandardTypes.VARBINARY)
    public static Slice castToVarbinary(@SqlType(StandardTypes.VARIANT) Variant value)
    {
        return VariantUtil.asVarbinary(value);
    }

    @ScalarOperator(CAST)
    @SqlType(StandardTypes.VARIANT)
    public static Variant castFromVarbinary(@SqlType(StandardTypes.VARBINARY) Slice value)
    {
        return Variant.ofBinary(value);
    }

    @SqlNullable
    @ScalarOperator(CAST)
    @SqlType(StandardTypes.DATE)
    public static Long castToDate(@SqlType(StandardTypes.VARIANT) Variant value)
    {
        return VariantUtil.asDate(value);
    }

    @ScalarOperator(CAST)
    @SqlType(StandardTypes.VARIANT)
    public static Variant castFromDate(@SqlType(StandardTypes.DATE) long value)
    {
        return Variant.ofDate(toIntExact(value));
    }

    @SqlNullable
    @ScalarOperator(CAST)
    @SqlType(StandardTypes.UUID)
    public static Slice castToUuid(@SqlType(StandardTypes.VARIANT) Variant value)
    {
        return VariantUtil.asUuid(value);
    }

    @ScalarOperator(CAST)
    @SqlType(StandardTypes.VARIANT)
    public static Variant castFromUuid(@SqlType(StandardTypes.UUID) Slice value)
    {
        return Variant.ofUuid(value);
    }

    @SqlNullable
    @ScalarOperator(CAST)
    @SqlType(StandardTypes.JSON)
    public static Slice castToJson(@SqlType(StandardTypes.VARIANT) Variant value)
    {
        return JsonType.jsonValue(toJsonItem(value));
    }

    @ScalarOperator(CAST)
    @SqlType(StandardTypes.VARIANT)
    public static Variant castFromJson(@SqlType(StandardTypes.JSON) Slice value)
    {
        if (!JsonType.hasParsedItem(value)) {
            return LEGACY_JSON_VARIANT_WRITER.write(JsonType.jsonText(value));
        }
        try {
            return toVariant(JsonTypeEncoding.decodeView(value).orElseThrow());
        }
        catch (IllegalArgumentException e) {
            throw invalidJsonCast(e.getMessage(), e);
        }
    }

    private static JsonValue toJsonItem(Variant value)
    {
        return switch (value.basicType()) {
            case ARRAY -> new JsonArrayItem(value.arrayElements()
                    .map(VariantOperators::toJsonItem)
                    .toList());
            case OBJECT -> new JsonObjectItem(value.objectFields()
                    .map(field -> new JsonObjectMember(value.metadata().get(field.fieldId()).toStringUtf8(), toJsonItem(field.value())))
                    .toList());
            case SHORT_STRING -> new TypedValue(VARCHAR, value.getString());
            case PRIMITIVE -> primitiveToJsonItem(value);
        };
    }

    private static JsonValue primitiveToJsonItem(Variant value)
    {
        return switch (value.primitiveType()) {
            case NULL -> JsonNull.JSON_NULL;
            case BOOLEAN_TRUE -> new TypedValue(BOOLEAN, true);
            case BOOLEAN_FALSE -> new TypedValue(BOOLEAN, false);
            case INT8 -> new TypedValue(TINYINT, value.getByte());
            case INT16 -> new TypedValue(SMALLINT, value.getShort());
            case INT32 -> new TypedValue(INTEGER, (long) value.getInt());
            case INT64 -> new TypedValue(io.trino.spi.type.BigintType.BIGINT, value.getLong());
            case FLOAT -> new TypedValue(REAL, (long) floatToRawIntBits(value.getFloat()));
            case DOUBLE -> new TypedValue(DOUBLE, value.getDouble());
            case DECIMAL4, DECIMAL8, DECIMAL16 -> decimalToJsonItem(value.getDecimal());
            case DATE -> new TypedValue(DATE, (long) value.getDate());
            case TIME_NTZ_MICROS -> new TypedValue(createTimeType(6), multiplyExact(value.getTimeMicros(), 1_000_000L));
            case TIMESTAMP_NTZ_MICROS -> new TypedValue(createTimestampType(6), value.getTimestampMicros());
            case TIMESTAMP_NTZ_NANOS -> TypedValue.fromValueAsObject(createTimestampType(9), longTimestampFromNanos(value.getTimestampNanos()));
            case TIMESTAMP_UTC_MICROS -> TypedValue.fromValueAsObject(createTimestampWithTimeZoneType(6), longTimestampWithTimeZoneFromMicros(value.getTimestampMicros(), UTC_KEY));
            case TIMESTAMP_UTC_NANOS -> TypedValue.fromValueAsObject(createTimestampWithTimeZoneType(9), longTimestampWithTimeZoneFromNanos(value.getTimestampNanos(), UTC_KEY));
            case BINARY -> throw invalidVariantCast("Cannot cast VARIANT binary to JSON");
            case UUID -> throw invalidVariantCast("Cannot cast VARIANT uuid to JSON");
            case STRING -> new TypedValue(VARCHAR, value.getString());
        };
    }

    private static TypedValue decimalToJsonItem(BigDecimal decimal)
    {
        DecimalType type = createDecimalType(decimal.precision(), decimal.scale());
        Object encoded = type.isShort() ? encodeShortScaledValue(decimal, decimal.scale()) : encodeScaledValue(decimal, decimal.scale());
        return TypedValue.fromValueAsObject(type, encoded);
    }

    private static Variant toVariant(JsonValue item)
    {
        if (item == JsonNull.JSON_NULL) {
            return Variant.NULL_VALUE;
        }
        if (item instanceof JsonArrayItem arrayItem) {
            List<Variant> elements = new ArrayList<>(arrayItem.elements().size());
            for (JsonValue element : arrayItem.elements()) {
                elements.add(toVariant(element));
            }
            return Variant.ofArray(elements);
        }
        if (item instanceof JsonObjectItem objectItem) {
            Map<Slice, Variant> fields = new LinkedHashMap<>();
            for (JsonObjectMember member : objectItem.members()) {
                Slice fieldName = utf8Slice(member.key());
                if (fields.putIfAbsent(fieldName, toVariant(member.value())) != null) {
                    throw invalidJsonCast("Cannot cast JSON object with duplicate member keys to VARIANT");
                }
            }
            return Variant.ofObject(fields);
        }
        if (item instanceof TypedValue typedValue) {
            return typedValueToVariant(typedValue);
        }
        throw invalidJsonCast("Unsupported JSON value");
    }

    private static Variant toVariant(JsonValueView value)
    {
        return switch (value.kind()) {
            case JSON_ERROR -> throw invalidJsonCast("Unsupported JSON value");
            case NULL -> Variant.NULL_VALUE;
            case ARRAY -> {
                List<Variant> elements = new ArrayList<>(value.arraySize());
                value.forEachArrayElement(element -> elements.add(toVariant(element)));
                yield Variant.ofArray(elements);
            }
            case OBJECT -> {
                Map<Slice, Variant> fields = new LinkedHashMap<>();
                value.forEachObjectMember((key, memberValue) -> {
                    Slice fieldName = utf8Slice(key);
                    if (fields.putIfAbsent(fieldName, toVariant(memberValue)) != null) {
                        throw invalidJsonCast("Cannot cast JSON object with duplicate member keys to VARIANT");
                    }
                });
                yield Variant.ofObject(fields);
            }
            case TYPED_VALUE -> typedValueToVariant(value.typedValue());
        };
    }

    private static Variant typedValueToVariant(TypedValue value)
    {
        Type type = value.getType();
        return switch (type) {
            case BooleanType _ -> Variant.ofBoolean(value.getBooleanValue());
            case TinyintType _ -> Variant.ofByte((byte) value.getLongValue());
            case SmallintType _ -> Variant.ofShort((short) value.getLongValue());
            case IntegerType _ -> Variant.ofInt(toIntExact(value.getLongValue()));
            case BigintType _ -> Variant.ofLong(value.getLongValue());
            case RealType _ -> Variant.ofFloat(intBitsToFloat(toIntExact(value.getLongValue())));
            case DoubleType _ -> Variant.ofDouble(value.getDoubleValue());
            case DecimalType decimalType -> {
                BigInteger unscaledValue = decimalType.isShort() ?
                        BigInteger.valueOf(value.getLongValue()) :
                        ((Int128) value.getObjectValue()).toBigInteger();
                yield Variant.ofDecimal(new BigDecimal(unscaledValue, decimalType.getScale()));
            }
            case DateType _ -> Variant.ofDate(toIntExact(value.getLongValue()));
            case CharType _, VarcharType _ -> {
                Slice text = JsonItems.scalarText(value)
                        .orElseThrow(() -> invalidJsonCast("Cannot cast non-text JSON scalar to VARIANT string"));
                yield Variant.ofString(text);
            }
            case TimeType timeType -> {
                long picos = value.getLongValue();
                if (timeType.getPrecision() > 6 || (picos % 1_000_000L) != 0) {
                    throw invalidJsonCast("Cannot cast JSON time(%s) to VARIANT".formatted(timeType.getPrecision()));
                }
                yield Variant.ofTimeMicrosNtz(picos / 1_000_000L);
            }
            case TimeWithTimeZoneType _ -> throw invalidJsonCast("Cannot cast JSON time with time zone to VARIANT");
            case TimestampType timestampType -> timestampToVariant(timestampType, value.value());
            case TimestampWithTimeZoneType timestampWithTimeZoneType -> timestampWithTimeZoneToVariant(timestampWithTimeZoneType, value.value());
            default -> throw invalidJsonCast("Cannot cast JSON value of type %s to VARIANT".formatted(type.getDisplayName()));
        };
    }

    private static Variant timestampToVariant(TimestampType type, Object value)
    {
        if (type.getPrecision() <= 6) {
            return Variant.ofTimestampMicrosNtz((long) value);
        }

        LongTimestamp timestamp = (LongTimestamp) value;
        if (type.getPrecision() > 9 && (timestamp.getPicosOfMicro() % 1_000) != 0) {
            throw invalidJsonCast("Cannot cast JSON timestamp(%s) to VARIANT".formatted(type.getPrecision()));
        }

        long nanos = addExact(multiplyExact(timestamp.getEpochMicros(), 1_000L), timestamp.getPicosOfMicro() / 1_000L);
        return Variant.ofTimestampNanosNtz(nanos);
    }

    private static Variant timestampWithTimeZoneToVariant(TimestampWithTimeZoneType type, Object value)
    {
        if (type.getPrecision() <= 3) {
            long packed = (long) value;
            if (!unpackZoneKey(packed).equals(UTC_KEY)) {
                throw invalidJsonCast("Cannot cast JSON timestamp with time zone to VARIANT unless the value is in UTC");
            }
            return Variant.ofTimestampMicrosUtc(multiplyExact(unpackMillisUtc(packed), 1_000L));
        }

        LongTimestampWithTimeZone timestamp = (LongTimestampWithTimeZone) value;
        if (!TimeZoneKey.getTimeZoneKey(timestamp.getTimeZoneKey()).equals(UTC_KEY)) {
            throw invalidJsonCast("Cannot cast JSON timestamp with time zone to VARIANT unless the value is in UTC");
        }

        if (type.getPrecision() <= 6) {
            long micros = addExact(multiplyExact(timestamp.getEpochMillis(), 1_000L), timestamp.getPicosOfMilli() / 1_000_000L);
            return Variant.ofTimestampMicrosUtc(micros);
        }

        if (type.getPrecision() > 9 && (timestamp.getPicosOfMilli() % 1_000) != 0) {
            throw invalidJsonCast("Cannot cast JSON timestamp(%s) with time zone to VARIANT".formatted(type.getPrecision()));
        }

        long nanos = addExact(multiplyExact(timestamp.getEpochMillis(), 1_000_000L), timestamp.getPicosOfMilli() / 1_000L);
        return Variant.ofTimestampNanosUtc(nanos);
    }

    private static LongTimestamp longTimestampFromNanos(long epochNanos)
    {
        long epochMicros = floorDiv(epochNanos, 1_000L);
        int picosOfMicro = (int) (floorMod(epochNanos, 1_000L) * 1_000L);
        return new LongTimestamp(epochMicros, picosOfMicro);
    }

    private static LongTimestampWithTimeZone longTimestampWithTimeZoneFromMicros(long epochMicros, TimeZoneKey zoneKey)
    {
        long epochMillis = floorDiv(epochMicros, 1_000L);
        int picosOfMilli = (int) (floorMod(epochMicros, 1_000L) * 1_000_000L);
        return LongTimestampWithTimeZone.fromEpochMillisAndFraction(epochMillis, picosOfMilli, zoneKey);
    }

    private static LongTimestampWithTimeZone longTimestampWithTimeZoneFromNanos(long epochNanos, TimeZoneKey zoneKey)
    {
        long epochMillis = floorDiv(epochNanos, 1_000_000L);
        int picosOfMilli = (int) (floorMod(epochNanos, 1_000_000L) * 1_000L);
        return LongTimestampWithTimeZone.fromEpochMillisAndFraction(epochMillis, picosOfMilli, zoneKey);
    }

    private static TrinoException invalidJsonCast(String message)
    {
        return invalidJsonCast(message, null);
    }

    private static TrinoException invalidJsonCast(String message, Throwable cause)
    {
        return new TrinoException(INVALID_CAST_ARGUMENT, message, cause);
    }

    private static TrinoException invalidVariantCast(String message)
    {
        return new TrinoException(INVALID_CAST_ARGUMENT, message);
    }

    @ScalarOperator(CAST)
    public static final class VariantToTimeCast
    {
        private VariantToTimeCast() {}

        @LiteralParameters("p")
        @SqlNullable
        @SqlType("time(p)")
        public static Long castToTime(@LiteralParameter("p") long precision, @SqlType(StandardTypes.VARIANT) Variant value)
        {
            return VariantUtil.asTime(value, toIntExact(precision));
        }
    }

    @ScalarOperator(CAST)
    public static final class VariantFromTimeCast
    {
        private VariantFromTimeCast() {}

        @LiteralParameters("p")
        @SqlType(StandardTypes.VARIANT)
        public static Variant castFromTime(@LiteralParameter("p") long precision, @SqlType("time(p)") long epochPicos)
        {
            return Variant.ofTimeMicrosNtz(epochPicos / 1_000_000L);
        }
    }

    @ScalarOperator(CAST)
    public static final class VariantToTimestampCast
    {
        private VariantToTimestampCast() {}

        @LiteralParameters("p")
        @SqlNullable
        @SqlType("timestamp(p)")
        public static Long castToShortTimestamp(@LiteralParameter("p") long precision, @SqlType(StandardTypes.VARIANT) Variant value)
        {
            return VariantUtil.asShortTimestamp(value, toIntExact(precision));
        }

        @LiteralParameters("p")
        @SqlNullable
        @SqlType("timestamp(p)")
        public static LongTimestamp castToLongTimestamp(@LiteralParameter("p") long precision, @SqlType(StandardTypes.VARIANT) Variant value)
        {
            return VariantUtil.asLongTimestamp(value, toIntExact(precision));
        }
    }

    @ScalarOperator(CAST)
    public static final class VariantFromTimestampCast
    {
        private VariantFromTimestampCast() {}

        @LiteralParameters("p")
        @SqlType(StandardTypes.VARIANT)
        public static Variant castFromTimestamp(@LiteralParameter("p") long precision, @SqlType("timestamp(p)") long epochMicros)
        {
            return Variant.ofTimestampMicrosNtz(epochMicros);
        }

        @LiteralParameters("p")
        @SqlType(StandardTypes.VARIANT)
        public static Variant castFromTimestamp(@LiteralParameter("p") long precision, @SqlType("timestamp(p)") LongTimestamp timestamp)
        {
            long nanosFromMicros = multiplyExact(timestamp.getEpochMicros(), 1_000L);
            long extraNanos = timestamp.getPicosOfMicro() / 1_000; // 1000 ps = 1 ns
            long nanos = Math.addExact(nanosFromMicros, extraNanos);

            return Variant.ofTimestampNanosNtz(nanos);
        }
    }

    @ScalarOperator(CAST)
    public static final class VariantToTimestampWithTimeZoneCasts
    {
        private VariantToTimestampWithTimeZoneCasts() {}

        @LiteralParameters("p")
        @SqlNullable
        @SqlType("timestamp(p) with time zone")
        public static Long castToShortTimestampWithTimeZone(@LiteralParameter("p") long precision, @SqlType(StandardTypes.VARIANT) Variant variant)
        {
            return VariantUtil.asShortTimestampWithTimeZone(variant, toIntExact(precision));
        }

        @LiteralParameters("p")
        @SqlNullable
        @SqlType("timestamp(p) with time zone")
        public static LongTimestampWithTimeZone castToLongTimestampWithTimeZone(@LiteralParameter("p") long precision, @SqlType(StandardTypes.VARIANT) Variant variant)
        {
            return VariantUtil.asLongTimestampWithTimeZone(variant, toIntExact(precision));
        }
    }

    @ScalarOperator(CAST)
    public static final class VariantFromTimestampWithTimeZoneCasts
    {
        private VariantFromTimestampWithTimeZoneCasts() {}

        @LiteralParameters("p")
        @SqlType(StandardTypes.VARIANT)
        public static Variant castFromTimestampWithTimeZone(@LiteralParameter("p") long precision, @SqlType("timestamp(p) with time zone") long packedEpochMillis)
        {
            long epochMillis = unpackMillisUtc(packedEpochMillis);
            return Variant.ofTimestampMicrosUtc(multiplyExact(epochMillis, 1_000L));
        }

        @LiteralParameters("p")
        @SqlType(StandardTypes.VARIANT)
        public static Variant castFromTimestampWithTimeZone(@LiteralParameter("p") long precision, @SqlType("timestamp(p) with time zone") LongTimestampWithTimeZone timestamp)
        {
            if (precision <= 6) {
                long millisFromMillis = multiplyExact(timestamp.getEpochMillis(), 1000L);
                int extraMillis = timestamp.getPicosOfMilli() / 1_000_000;
                long epochMicros = Math.addExact(millisFromMillis, extraMillis);
                return Variant.ofTimestampMicrosUtc(epochMicros);
            }

            long nanosFromMillis = multiplyExact(timestamp.getEpochMillis(), 1_000_000L);
            int extraNanos = timestamp.getPicosOfMilli() / 1_000;
            long nanos = Math.addExact(nanosFromMillis, extraNanos);
            return Variant.ofTimestampNanosUtc(nanos);
        }
    }
}
