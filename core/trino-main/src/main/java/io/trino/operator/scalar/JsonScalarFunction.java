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
package io.trino.operator.scalar;

import io.airlift.slice.Slice;
import io.trino.json.JsonItemEncoding;
import io.trino.json.JsonNull;
import io.trino.json.ir.TypedValue;
import io.trino.spi.function.Description;
import io.trino.spi.function.LiteralParameter;
import io.trino.spi.function.LiteralParameters;
import io.trino.spi.function.ScalarFunction;
import io.trino.spi.function.SqlNullable;
import io.trino.spi.function.SqlType;
import io.trino.spi.type.Int128;
import io.trino.spi.type.JsonValue;
import io.trino.spi.type.LongTimeWithTimeZone;
import io.trino.spi.type.LongTimestamp;
import io.trino.spi.type.LongTimestampWithTimeZone;
import io.trino.spi.type.StandardTypes;
import io.trino.spi.type.Type;

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
import static io.trino.spi.type.VarcharType.VARCHAR;

@Description("Constructs a JSON scalar from an SQL value")
public final class JsonScalarFunction
{
    private static final JsonValue JSON_NULL = JsonValue.of(JsonItemEncoding.encode(JsonNull.JSON_NULL));

    private JsonScalarFunction() {}

    private static JsonValue encode(Type type, Object value)
    {
        if (value == null) {
            return JSON_NULL;
        }
        return JsonValue.of(JsonItemEncoding.encode(new TypedValue(type, value)));
    }

    @ScalarFunction("json_scalar")
    @SqlType(StandardTypes.JSON)
    public static JsonValue fromUnknown(@SqlNullable @SqlType("unknown") Boolean value)
    {
        return JSON_NULL;
    }

    @ScalarFunction("json_scalar")
    @SqlType(StandardTypes.JSON)
    public static JsonValue fromBoolean(@SqlNullable @SqlType(StandardTypes.BOOLEAN) Boolean value)
    {
        return encode(BOOLEAN, value);
    }

    @ScalarFunction("json_scalar")
    @SqlType(StandardTypes.JSON)
    public static JsonValue fromTinyint(@SqlNullable @SqlType(StandardTypes.TINYINT) Long value)
    {
        return encode(TINYINT, value);
    }

    @ScalarFunction("json_scalar")
    @SqlType(StandardTypes.JSON)
    public static JsonValue fromSmallint(@SqlNullable @SqlType(StandardTypes.SMALLINT) Long value)
    {
        return encode(SMALLINT, value);
    }

    @ScalarFunction("json_scalar")
    @SqlType(StandardTypes.JSON)
    public static JsonValue fromInteger(@SqlNullable @SqlType(StandardTypes.INTEGER) Long value)
    {
        return encode(INTEGER, value);
    }

    @ScalarFunction("json_scalar")
    @SqlType(StandardTypes.JSON)
    public static JsonValue fromBigint(@SqlNullable @SqlType(StandardTypes.BIGINT) Long value)
    {
        return encode(BIGINT, value);
    }

    @ScalarFunction("json_scalar")
    @SqlType(StandardTypes.JSON)
    public static JsonValue fromReal(@SqlNullable @SqlType(StandardTypes.REAL) Long value)
    {
        return encode(REAL, value);
    }

    @ScalarFunction("json_scalar")
    @SqlType(StandardTypes.JSON)
    public static JsonValue fromDouble(@SqlNullable @SqlType(StandardTypes.DOUBLE) Double value)
    {
        return encode(DOUBLE, value);
    }

    @ScalarFunction("json_scalar")
    @LiteralParameters("x")
    @SqlType(StandardTypes.JSON)
    public static JsonValue fromVarchar(@SqlNullable @SqlType("varchar(x)") Slice value)
    {
        return encode(VARCHAR, value);
    }

    @ScalarFunction("json_scalar")
    @LiteralParameters("x")
    @SqlType(StandardTypes.JSON)
    public static JsonValue fromChar(
            @LiteralParameter("x") long length,
            @SqlNullable @SqlType("char(x)") Slice value)
    {
        return encode(createCharType((int) length), value);
    }

    @ScalarFunction("json_scalar")
    @SqlType(StandardTypes.JSON)
    public static JsonValue fromDate(@SqlNullable @SqlType(StandardTypes.DATE) Long value)
    {
        return encode(DATE, value);
    }

    @ScalarFunction("json_scalar")
    @LiteralParameters("p")
    @SqlType(StandardTypes.JSON)
    public static JsonValue fromTime(
            @LiteralParameter("p") long precision,
            @SqlNullable @SqlType("time(p)") Long value)
    {
        return encode(createTimeType((int) precision), value);
    }

    @ScalarFunction("json_scalar")
    @Description("Constructs a JSON scalar from a decimal value")
    public static final class FromDecimal
    {
        private FromDecimal() {}

        @LiteralParameters({"p", "s"})
        @SqlType(StandardTypes.JSON)
        public static JsonValue fromShort(
                @LiteralParameter("p") long precision,
                @LiteralParameter("s") long scale,
                @SqlNullable @SqlType("decimal(p, s)") Long value)
        {
            return encode(createDecimalType((int) precision, (int) scale), value);
        }

        @LiteralParameters({"p", "s"})
        @SqlType(StandardTypes.JSON)
        public static JsonValue fromLong(
                @LiteralParameter("p") long precision,
                @LiteralParameter("s") long scale,
                @SqlNullable @SqlType("decimal(p, s)") Int128 value)
        {
            return encode(createDecimalType((int) precision, (int) scale), value);
        }
    }

    @ScalarFunction("json_scalar")
    @Description("Constructs a JSON scalar from a time-with-time-zone value")
    public static final class FromTimeWithTimeZone
    {
        private FromTimeWithTimeZone() {}

        @LiteralParameters("p")
        @SqlType(StandardTypes.JSON)
        public static JsonValue fromShort(
                @LiteralParameter("p") long precision,
                @SqlNullable @SqlType("time(p) with time zone") Long value)
        {
            return encode(createTimeWithTimeZoneType((int) precision), value);
        }

        @LiteralParameters("p")
        @SqlType(StandardTypes.JSON)
        public static JsonValue fromLong(
                @LiteralParameter("p") long precision,
                @SqlNullable @SqlType("time(p) with time zone") LongTimeWithTimeZone value)
        {
            return encode(createTimeWithTimeZoneType((int) precision), value);
        }
    }

    @ScalarFunction("json_scalar")
    @Description("Constructs a JSON scalar from a timestamp value")
    public static final class FromTimestamp
    {
        private FromTimestamp() {}

        @LiteralParameters("p")
        @SqlType(StandardTypes.JSON)
        public static JsonValue fromShort(
                @LiteralParameter("p") long precision,
                @SqlNullable @SqlType("timestamp(p)") Long value)
        {
            return encode(createTimestampType((int) precision), value);
        }

        @LiteralParameters("p")
        @SqlType(StandardTypes.JSON)
        public static JsonValue fromLong(
                @LiteralParameter("p") long precision,
                @SqlNullable @SqlType("timestamp(p)") LongTimestamp value)
        {
            return encode(createTimestampType((int) precision), value);
        }
    }

    @ScalarFunction("json_scalar")
    @Description("Constructs a JSON scalar from a timestamp-with-time-zone value")
    public static final class FromTimestampWithTimeZone
    {
        private FromTimestampWithTimeZone() {}

        @LiteralParameters("p")
        @SqlType(StandardTypes.JSON)
        public static JsonValue fromShort(
                @LiteralParameter("p") long precision,
                @SqlNullable @SqlType("timestamp(p) with time zone") Long value)
        {
            return encode(createTimestampWithTimeZoneType((int) precision), value);
        }

        @LiteralParameters("p")
        @SqlType(StandardTypes.JSON)
        public static JsonValue fromLong(
                @LiteralParameter("p") long precision,
                @SqlNullable @SqlType("timestamp(p) with time zone") LongTimestampWithTimeZone value)
        {
            return encode(createTimestampWithTimeZoneType((int) precision), value);
        }
    }
}
