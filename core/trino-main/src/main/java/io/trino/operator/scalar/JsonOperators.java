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

import com.fasterxml.jackson.core.JsonParser;
import com.fasterxml.jackson.databind.json.JsonMapper;
import io.airlift.slice.DynamicSliceOutput;
import io.airlift.slice.Slice;
import io.airlift.slice.SliceOutput;
import io.airlift.slice.Slices;
import io.trino.json.JsonItem;
import io.trino.json.JsonItemEncoding;
import io.trino.json.JsonNull;
import io.trino.json.TypedValue;
import io.trino.operator.scalar.time.TimeOperators;
import io.trino.spi.TrinoException;
import io.trino.spi.function.LiteralParameter;
import io.trino.spi.function.LiteralParameters;
import io.trino.spi.function.ScalarOperator;
import io.trino.spi.function.SqlNullable;
import io.trino.spi.function.SqlType;
import io.trino.spi.type.CharType;
import io.trino.spi.type.DateType;
import io.trino.spi.type.JsonPayload;
import io.trino.spi.type.TimeType;
import io.trino.spi.type.TrinoNumber;
import io.trino.spi.type.Type;
import io.trino.spi.type.VarcharType;
import io.trino.type.DateOperators;
import io.trino.type.JsonType;
import io.trino.util.JsonCastException;

import java.io.IOException;

import static io.airlift.slice.SliceUtf8.countCodePoints;
import static io.trino.json.JsonItemEncoding.appendBigint;
import static io.trino.json.JsonItemEncoding.appendBoolean;
import static io.trino.json.JsonItemEncoding.appendDate;
import static io.trino.json.JsonItemEncoding.appendDouble;
import static io.trino.json.JsonItemEncoding.appendNumber;
import static io.trino.json.JsonItemEncoding.appendRealBits;
import static io.trino.json.JsonItemEncoding.appendVarchar;
import static io.trino.json.JsonItemEncoding.appendVersion;
import static io.trino.spi.StandardErrorCode.INVALID_CAST_ARGUMENT;
import static io.trino.spi.StandardErrorCode.NUMERIC_VALUE_OUT_OF_RANGE;
import static io.trino.spi.function.OperatorType.CAST;
import static io.trino.spi.type.Chars.padSpaces;
import static io.trino.spi.type.StandardTypes.BIGINT;
import static io.trino.spi.type.StandardTypes.BOOLEAN;
import static io.trino.spi.type.StandardTypes.DATE;
import static io.trino.spi.type.StandardTypes.DOUBLE;
import static io.trino.spi.type.StandardTypes.INTEGER;
import static io.trino.spi.type.StandardTypes.JSON;
import static io.trino.spi.type.StandardTypes.NUMBER;
import static io.trino.spi.type.StandardTypes.REAL;
import static io.trino.spi.type.StandardTypes.SMALLINT;
import static io.trino.spi.type.StandardTypes.TINYINT;
import static io.trino.util.Failures.checkCondition;
import static io.trino.util.JsonUtil.createJsonFactory;
import static io.trino.util.JsonUtil.createJsonParser;
import static io.trino.util.JsonUtil.currentTokenAsBigint;
import static io.trino.util.JsonUtil.currentTokenAsBoolean;
import static io.trino.util.JsonUtil.currentTokenAsDouble;
import static io.trino.util.JsonUtil.currentTokenAsInteger;
import static io.trino.util.JsonUtil.currentTokenAsNumber;
import static io.trino.util.JsonUtil.currentTokenAsReal;
import static io.trino.util.JsonUtil.currentTokenAsSmallint;
import static io.trino.util.JsonUtil.currentTokenAsTinyint;
import static io.trino.util.JsonUtil.currentTokenAsVarchar;
import static java.lang.String.format;

public final class JsonOperators
{
    private static final JsonMapper JSON_MAPPER = new JsonMapper(createJsonFactory());

    private JsonOperators() {}

    @ScalarOperator(CAST)
    @SqlNullable
    @LiteralParameters("x")
    @SqlType("varchar(x)")
    public static Slice castToVarchar(@LiteralParameter("x") long x, @SqlType(JSON) JsonPayload json)
    {
        Slice payload = json.payload();
        try (JsonParser parser = createJsonParser(JSON_MAPPER, payload)) {
            parser.nextToken();
            Slice result = currentTokenAsVarchar(parser);
            checkCondition(parser.nextToken() == null, INVALID_CAST_ARGUMENT, "Cannot cast input json to VARCHAR"); // check no trailing token
            if (result == null || countCodePoints(result) <= x) {
                return result;
            }
        }
        catch (IOException | JsonCastException e) {
            throw new TrinoException(INVALID_CAST_ARGUMENT, format("Cannot cast '%s' to varchar(%s)", JsonType.jsonText(payload).toStringUtf8(), x), e);
        }
        throw new TrinoException(INVALID_CAST_ARGUMENT, format("Cannot cast '%s' to varchar(%s)", JsonType.jsonText(payload).toStringUtf8(), x));
    }

    @ScalarOperator(CAST)
    @SqlNullable
    @SqlType(BIGINT)
    public static Long castToBigint(@SqlType(JSON) JsonPayload json)
    {
        Slice payload = json.payload();
        try (JsonParser parser = createJsonParser(JSON_MAPPER, payload)) {
            parser.nextToken();
            Long result = currentTokenAsBigint(parser);
            checkCondition(parser.nextToken() == null, INVALID_CAST_ARGUMENT, "Cannot cast input json to BIGINT"); // check no trailing token
            return result;
        }
        catch (IOException | JsonCastException e) {
            throw new TrinoException(INVALID_CAST_ARGUMENT, format("Cannot cast '%s' to %s", JsonType.jsonText(payload).toStringUtf8(), BIGINT), e);
        }
    }

    @ScalarOperator(CAST)
    @SqlNullable
    @SqlType(INTEGER)
    public static Long castToInteger(@SqlType(JSON) JsonPayload json)
    {
        Slice payload = json.payload();
        try (JsonParser parser = createJsonParser(JSON_MAPPER, payload)) {
            parser.nextToken();
            Long result = currentTokenAsInteger(parser);
            checkCondition(parser.nextToken() == null, INVALID_CAST_ARGUMENT, "Cannot cast input json to INTEGER"); // check no trailing token
            return result;
        }
        catch (TrinoException e) {
            if (e.getErrorCode().equals(NUMERIC_VALUE_OUT_OF_RANGE.toErrorCode())) {
                throw new TrinoException(INVALID_CAST_ARGUMENT, format("Cannot cast '%s' to %s", JsonType.jsonText(payload).toStringUtf8(), INTEGER), e.getCause());
            }
            throw e;
        }
        catch (ArithmeticException | IOException | JsonCastException e) {
            throw new TrinoException(INVALID_CAST_ARGUMENT, format("Cannot cast '%s' to %s", JsonType.jsonText(payload).toStringUtf8(), INTEGER), e);
        }
    }

    @ScalarOperator(CAST)
    @SqlNullable
    @SqlType(SMALLINT)
    public static Long castToSmallint(@SqlType(JSON) JsonPayload json)
    {
        Slice payload = json.payload();
        try (JsonParser parser = createJsonParser(JSON_MAPPER, payload)) {
            parser.nextToken();
            Long result = currentTokenAsSmallint(parser);
            checkCondition(parser.nextToken() == null, INVALID_CAST_ARGUMENT, "Cannot cast input json to SMALLINT"); // check no trailing token
            return result;
        }
        catch (TrinoException e) {
            if (e.getErrorCode().equals(NUMERIC_VALUE_OUT_OF_RANGE.toErrorCode())) {
                throw new TrinoException(INVALID_CAST_ARGUMENT, format("Cannot cast '%s' to %s", JsonType.jsonText(payload).toStringUtf8(), INTEGER), e.getCause());
            }
            throw e;
        }
        catch (IllegalArgumentException | IOException | JsonCastException e) {
            throw new TrinoException(INVALID_CAST_ARGUMENT, format("Cannot cast '%s' to %s", JsonType.jsonText(payload).toStringUtf8(), SMALLINT), e);
        }
    }

    @ScalarOperator(CAST)
    @SqlNullable
    @SqlType(TINYINT)
    public static Long castToTinyint(@SqlType(JSON) JsonPayload json)
    {
        Slice payload = json.payload();
        try (JsonParser parser = createJsonParser(JSON_MAPPER, payload)) {
            parser.nextToken();
            Long result = currentTokenAsTinyint(parser);
            checkCondition(parser.nextToken() == null, INVALID_CAST_ARGUMENT, "Cannot cast input json to TINYINT"); // check no trailing token
            return result;
        }
        catch (TrinoException e) {
            if (e.getErrorCode().equals(NUMERIC_VALUE_OUT_OF_RANGE.toErrorCode())) {
                throw new TrinoException(INVALID_CAST_ARGUMENT, format("Cannot cast '%s' to %s", JsonType.jsonText(payload).toStringUtf8(), INTEGER), e.getCause());
            }
            throw e;
        }
        catch (IllegalArgumentException | IOException | JsonCastException e) {
            throw new TrinoException(INVALID_CAST_ARGUMENT, format("Cannot cast '%s' to %s", JsonType.jsonText(payload).toStringUtf8(), TINYINT), e);
        }
    }

    @ScalarOperator(CAST)
    @SqlNullable
    @SqlType(DOUBLE)
    public static Double castToDouble(@SqlType(JSON) JsonPayload json)
    {
        Slice payload = json.payload();
        try (JsonParser parser = createJsonParser(JSON_MAPPER, payload)) {
            parser.nextToken();
            Double result = currentTokenAsDouble(parser);
            checkCondition(parser.nextToken() == null, INVALID_CAST_ARGUMENT, "Cannot cast input json to DOUBLE"); // check no trailing token
            return result;
        }
        catch (IOException | JsonCastException e) {
            throw new TrinoException(INVALID_CAST_ARGUMENT, format("Cannot cast '%s' to %s", JsonType.jsonText(payload).toStringUtf8(), DOUBLE), e);
        }
    }

    @ScalarOperator(CAST)
    @SqlNullable
    @SqlType(REAL)
    public static Long castToReal(@SqlType(JSON) JsonPayload json)
    {
        Slice payload = json.payload();
        try (JsonParser parser = createJsonParser(JSON_MAPPER, payload)) {
            parser.nextToken();
            Long result = currentTokenAsReal(parser);
            checkCondition(parser.nextToken() == null, INVALID_CAST_ARGUMENT, "Cannot cast input json to REAL"); // check no trailing token
            return result;
        }
        catch (IOException | JsonCastException e) {
            throw new TrinoException(INVALID_CAST_ARGUMENT, format("Cannot cast '%s' to %s", JsonType.jsonText(payload).toStringUtf8(), REAL), e);
        }
    }

    @ScalarOperator(CAST)
    @SqlNullable
    @SqlType(NUMBER)
    public static TrinoNumber castToNumber(@SqlType(JSON) JsonPayload json)
    {
        Slice payload = json.payload();
        try (JsonParser parser = createJsonParser(JSON_MAPPER, payload)) {
            parser.nextToken();
            TrinoNumber result = currentTokenAsNumber(parser);
            checkCondition(parser.nextToken() == null, INVALID_CAST_ARGUMENT, "Cannot cast input json to NUMBER"); // check no trailing token
            return result;
        }
        catch (IOException | JsonCastException e) {
            throw new TrinoException(INVALID_CAST_ARGUMENT, format("Cannot cast '%s' to %s", payload.toStringUtf8(), NUMBER), e);
        }
    }

    @ScalarOperator(CAST)
    @SqlNullable
    @SqlType(BOOLEAN)
    public static Boolean castToBoolean(@SqlType(JSON) JsonPayload json)
    {
        Slice payload = json.payload();
        try (JsonParser parser = createJsonParser(JSON_MAPPER, payload)) {
            parser.nextToken();
            Boolean result = currentTokenAsBoolean(parser);
            checkCondition(parser.nextToken() == null, INVALID_CAST_ARGUMENT, "Cannot cast input json to BOOLEAN"); // check no trailing token
            return result;
        }
        catch (IOException | JsonCastException e) {
            throw new TrinoException(INVALID_CAST_ARGUMENT, format("Cannot cast '%s' to %s", JsonType.jsonText(payload).toStringUtf8(), BOOLEAN), e);
        }
    }

    @ScalarOperator(CAST)
    @SqlNullable
    @SqlType(DATE)
    public static Long castToDate(@SqlType(JSON) JsonPayload json)
    {
        JsonItem item = JsonItemEncoding.decode(json.payload());
        if (item == JsonNull.JSON_NULL) {
            return null;
        }
        if (!(item instanceof TypedValue typed)) {
            throw new TrinoException(INVALID_CAST_ARGUMENT, "Cannot cast JSON value to date");
        }
        Type type = typed.getType();
        return switch (type) {
            case DateType _ -> typed.getLongValue();
            case VarcharType _ -> DateOperators.castFromVarchar((Slice) typed.getObjectValue());
            case CharType charType -> DateOperators.castFromVarchar(Slices.utf8Slice(padSpaces((Slice) typed.getObjectValue(), charType).toStringUtf8()));
            default -> throw new TrinoException(INVALID_CAST_ARGUMENT, format("Cannot cast SQL/JSON value of type %s to date", type));
        };
    }

    @ScalarOperator(CAST)
    @SqlNullable
    @LiteralParameters("p")
    @SqlType("time(p)")
    public static Long castToTime(@LiteralParameter("p") long precision, @SqlType(JSON) JsonPayload json)
    {
        JsonItem item = JsonItemEncoding.decode(json.payload());
        if (item == JsonNull.JSON_NULL) {
            return null;
        }
        if (!(item instanceof TypedValue typed)) {
            throw new TrinoException(INVALID_CAST_ARGUMENT, "Cannot cast JSON value to time");
        }
        Type type = typed.getType();
        return switch (type) {
            // Re-format to canonical text and re-parse so any precision adjustment goes through the
            // single source of truth (TimeOperators.castFromVarchar). The "+ 9" budgets the buffer
            // for the longest canonical TIME(MAX_PRECISION) text form: "HH:MM:SS." (9 chars) plus
            // up to MAX_PRECISION fractional digits.
            case TimeType timeType -> TimeOperators.castFromVarchar(precision, TimeOperators.castToVarchar(TimeType.MAX_PRECISION + 9L, timeType.getPrecision(), typed.getLongValue()));
            case VarcharType _ -> TimeOperators.castFromVarchar(precision, (Slice) typed.getObjectValue());
            case CharType charType -> TimeOperators.castFromVarchar(precision, Slices.utf8Slice(padSpaces((Slice) typed.getObjectValue(), charType).toStringUtf8()));
            default -> throw new TrinoException(INVALID_CAST_ARGUMENT, format("Cannot cast SQL/JSON value of type %s to time(%s)", type, precision));
        };
    }

    @ScalarOperator(CAST)
    @LiteralParameters("x")
    @SqlType(JSON)
    public static JsonPayload castFromVarchar(@SqlType("varchar(x)") Slice value)
    {
        SliceOutput output = new DynamicSliceOutput(value.length() + 7);
        appendVersion(output);
        appendVarchar(output, value);
        return JsonPayload.of(output.slice());
    }

    @ScalarOperator(CAST)
    @SqlType(JSON)
    public static JsonPayload castFromTinyInt(@SqlType(TINYINT) long value)
    {
        SliceOutput output = new DynamicSliceOutput(4);
        appendVersion(output);
        appendBigint(output, value);
        return JsonPayload.of(output.slice());
    }

    @ScalarOperator(CAST)
    @SqlType(JSON)
    public static JsonPayload castFromSmallInt(@SqlType(SMALLINT) long value)
    {
        SliceOutput output = new DynamicSliceOutput(8);
        appendVersion(output);
        appendBigint(output, value);
        return JsonPayload.of(output.slice());
    }

    @ScalarOperator(CAST)
    @SqlType(JSON)
    public static JsonPayload castFromInteger(@SqlType(INTEGER) long value)
    {
        SliceOutput output = new DynamicSliceOutput(12);
        appendVersion(output);
        appendBigint(output, value);
        return JsonPayload.of(output.slice());
    }

    @ScalarOperator(CAST)
    @SqlType(JSON)
    public static JsonPayload castFromBigint(@SqlType(BIGINT) long value)
    {
        SliceOutput output = new DynamicSliceOutput(20);
        appendVersion(output);
        appendBigint(output, value);
        return JsonPayload.of(output.slice());
    }

    @ScalarOperator(CAST)
    @SqlType(JSON)
    public static JsonPayload castFromDouble(@SqlType(DOUBLE) double value)
    {
        SliceOutput output = new DynamicSliceOutput(11);
        appendVersion(output);
        appendDouble(output, value);
        return JsonPayload.of(output.slice());
    }

    @ScalarOperator(CAST)
    @SqlType(JSON)
    public static JsonPayload castFromReal(@SqlType(REAL) long value)
    {
        SliceOutput output = new DynamicSliceOutput(7);
        appendVersion(output);
        appendRealBits(output, (int) value);
        return JsonPayload.of(output.slice());
    }

    @ScalarOperator(CAST)
    @SqlType(JSON)
    public static JsonPayload castFromNumber(@SqlType(NUMBER) TrinoNumber value)
    {
        SliceOutput output = new DynamicSliceOutput(32);
        appendVersion(output);
        appendNumber(output, value);
        return JsonPayload.of(output.slice());
    }

    @ScalarOperator(CAST)
    @SqlType(JSON)
    public static JsonPayload castFromBoolean(@SqlType(BOOLEAN) boolean value)
    {
        SliceOutput output = new DynamicSliceOutput(4);
        appendVersion(output);
        appendBoolean(output, value);
        return JsonPayload.of(output.slice());
    }

    @ScalarOperator(CAST)
    @SqlType(JSON)
    public static JsonPayload castFromDate(@SqlType(DATE) long value)
    {
        SliceOutput output = new DynamicSliceOutput(11);
        appendVersion(output);
        appendDate(output, value);
        return JsonPayload.of(output.slice());
    }
}
