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

import com.fasterxml.jackson.core.JsonParser;
import com.fasterxml.jackson.databind.json.JsonMapper;
import io.airlift.slice.Slice;
import io.trino.spi.TrinoException;
import io.trino.spi.function.LiteralParameter;
import io.trino.spi.function.LiteralParameters;
import io.trino.spi.function.ScalarOperator;
import io.trino.spi.function.SqlNullable;
import io.trino.spi.function.SqlType;
import io.trino.spi.type.LongTimestamp;
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
public final class JsonToTimestampCast
{
    private static final JsonMapper JSON_MAPPER = new JsonMapper(createJsonFactory());

    private JsonToTimestampCast() {}

    @SqlNullable
    @LiteralParameters("p")
    @SqlType("timestamp(p)")
    public static Long castToShort(@LiteralParameter("p") long precision, @SqlType(JSON) Slice json)
    {
        try (JsonParser parser = createJsonParser(JSON_MAPPER, json)) {
            parser.nextToken();
            Slice result = currentTokenAsVarchar(parser);
            checkCondition(parser.nextToken() == null, INVALID_CAST_ARGUMENT, "Cannot cast input json to TIMESTAMP");
            return (result == null) ? null : VarcharToTimestampCast.castToShort(precision, result);
        }
        catch (IOException | JsonCastException e) {
            throw new TrinoException(INVALID_CAST_ARGUMENT, format("Cannot cast '%s' to timestamp(%s)", json.toStringUtf8(), precision), e);
        }
    }

    @SqlNullable
    @LiteralParameters("p")
    @SqlType("timestamp(p)")
    public static LongTimestamp castToLong(@LiteralParameter("p") long precision, @SqlType(JSON) Slice json)
    {
        try (JsonParser parser = createJsonParser(JSON_MAPPER, json)) {
            parser.nextToken();
            Slice result = currentTokenAsVarchar(parser);
            checkCondition(parser.nextToken() == null, INVALID_CAST_ARGUMENT, "Cannot cast input json to TIMESTAMP");
            return (result == null) ? null : VarcharToTimestampCast.castToLong(precision, result);
        }
        catch (IOException | JsonCastException e) {
            throw new TrinoException(INVALID_CAST_ARGUMENT, format("Cannot cast '%s' to timestamp(%s)", json.toStringUtf8(), precision), e);
        }
    }
}
