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
package io.trino.operator.scalar.timetz;

import com.fasterxml.jackson.core.JsonParser;
import com.fasterxml.jackson.databind.json.JsonMapper;
import io.airlift.slice.Slice;
import io.trino.spi.TrinoException;
import io.trino.spi.connector.ConnectorSession;
import io.trino.spi.function.LiteralParameter;
import io.trino.spi.function.LiteralParameters;
import io.trino.spi.function.ScalarOperator;
import io.trino.spi.function.SqlNullable;
import io.trino.spi.function.SqlType;
import io.trino.spi.type.LongTimeWithTimeZone;
import io.trino.util.JsonCastException;

import java.io.IOException;

import static io.trino.spi.StandardErrorCode.INVALID_CAST_ARGUMENT;
import static io.trino.spi.function.OperatorType.CAST;
import static io.trino.spi.type.StandardTypes.JSON;
import static io.trino.util.Failures.checkCondition;
import static io.trino.util.JsonUtil.createJsonFactory;
import static io.trino.util.JsonUtil.createJsonParser;
import static io.trino.util.JsonUtil.currentTokenAsVarchar;
import static java.lang.String.format;

@ScalarOperator(CAST)
public final class JsonToTimeWithTimeZoneCast
{
    private static final JsonMapper JSON_MAPPER = new JsonMapper(createJsonFactory());

    private JsonToTimeWithTimeZoneCast() {}

    @SqlNullable
    @LiteralParameters("p")
    @SqlType("time(p) with time zone")
    public static Long castToShort(@LiteralParameter("p") long precision, ConnectorSession session, @SqlType(JSON) Slice json)
    {
        try (JsonParser parser = createJsonParser(JSON_MAPPER, json)) {
            parser.nextToken();
            Slice result = currentTokenAsVarchar(parser);
            checkCondition(parser.nextToken() == null, INVALID_CAST_ARGUMENT, "Cannot cast input json to TIME WITH TIME ZONE");
            return (result == null) ? null : VarcharToTimeWithTimeZoneCast.castToShort(precision, session, result);
        }
        catch (IOException | JsonCastException e) {
            throw new TrinoException(INVALID_CAST_ARGUMENT, format("Cannot cast '%s' to time(%s) with time zone", json.toStringUtf8(), precision), e);
        }
    }

    @SqlNullable
    @LiteralParameters("p")
    @SqlType("time(p) with time zone")
    public static LongTimeWithTimeZone castToLong(@LiteralParameter("p") long precision, ConnectorSession session, @SqlType(JSON) Slice json)
    {
        try (JsonParser parser = createJsonParser(JSON_MAPPER, json)) {
            parser.nextToken();
            Slice result = currentTokenAsVarchar(parser);
            checkCondition(parser.nextToken() == null, INVALID_CAST_ARGUMENT, "Cannot cast input json to TIME WITH TIME ZONE");
            return (result == null) ? null : VarcharToTimeWithTimeZoneCast.castToLong(precision, session, result);
        }
        catch (IOException | JsonCastException e) {
            throw new TrinoException(INVALID_CAST_ARGUMENT, format("Cannot cast '%s' to time(%s) with time zone", json.toStringUtf8(), precision), e);
        }
    }
}
