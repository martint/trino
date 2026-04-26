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
package io.trino.operator.scalar.timestamp;

import io.airlift.slice.Slice;
import io.airlift.slice.Slices;
import io.trino.json.JsonItem;
import io.trino.json.JsonItemEncoding;
import io.trino.json.JsonNull;
import io.trino.json.TypedValue;
import io.trino.spi.TrinoException;
import io.trino.spi.function.LiteralParameter;
import io.trino.spi.function.LiteralParameters;
import io.trino.spi.function.ScalarOperator;
import io.trino.spi.function.SqlNullable;
import io.trino.spi.function.SqlType;
import io.trino.spi.type.CharType;
import io.trino.spi.type.JsonPayload;
import io.trino.spi.type.LongTimestamp;
import io.trino.spi.type.TimestampType;
import io.trino.spi.type.Type;
import io.trino.spi.type.VarcharType;

import static io.trino.spi.StandardErrorCode.INVALID_CAST_ARGUMENT;
import static io.trino.spi.function.OperatorType.CAST;
import static io.trino.spi.type.Chars.padSpaces;
import static io.trino.spi.type.StandardTypes.JSON;
import static io.trino.type.DateTimes.formatTimestamp;
import static java.lang.String.format;
import static java.time.ZoneOffset.UTC;

@ScalarOperator(CAST)
public final class JsonToTimestampCast
{
    private JsonToTimestampCast() {}

    @SqlNullable
    @LiteralParameters("p")
    @SqlType("timestamp(p)")
    public static Long castToShort(@LiteralParameter("p") long precision, @SqlType(JSON) JsonPayload json)
    {
        Slice text = textFromJson(json);
        return text == null ? null : VarcharToTimestampCast.castToShort(precision, text);
    }

    @SqlNullable
    @LiteralParameters("p")
    @SqlType("timestamp(p)")
    public static LongTimestamp castToLong(@LiteralParameter("p") long precision, @SqlType(JSON) JsonPayload json)
    {
        Slice text = textFromJson(json);
        return text == null ? null : VarcharToTimestampCast.castToLong(precision, text);
    }

    private static Slice textFromJson(JsonPayload json)
    {
        JsonItem item = JsonItemEncoding.decode(json.payload());
        if (item == JsonNull.JSON_NULL) {
            return null;
        }
        if (!(item instanceof TypedValue typed)) {
            throw new TrinoException(INVALID_CAST_ARGUMENT, "Cannot cast JSON value to timestamp");
        }
        Type type = typed.getType();
        return switch (type) {
            case VarcharType _ -> (Slice) typed.getObjectValue();
            case CharType charType -> Slices.utf8Slice(padSpaces((Slice) typed.getObjectValue(), charType).toStringUtf8());
            case TimestampType timestampType -> {
                String formatted = timestampType.isShort()
                        ? formatTimestamp(timestampType.getPrecision(), typed.getLongValue(), 0, UTC)
                        : formatLongTimestamp(timestampType.getPrecision(), (LongTimestamp) typed.getObjectValue());
                yield Slices.utf8Slice(formatted);
            }
            default -> throw new TrinoException(INVALID_CAST_ARGUMENT, format("Cannot cast SQL/JSON value of type %s to timestamp", type));
        };
    }

    private static String formatLongTimestamp(int precision, LongTimestamp value)
    {
        return formatTimestamp(precision, value.getEpochMicros(), value.getPicosOfMicro(), UTC);
    }
}
