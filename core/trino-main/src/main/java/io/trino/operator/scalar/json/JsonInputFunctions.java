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
package io.trino.operator.scalar.json;

import io.airlift.slice.Slice;
import io.trino.json.JsonItemEncoding;
import io.trino.json.JsonItems;
import io.trino.json.JsonValueView;
import io.trino.spi.function.ScalarFunction;
import io.trino.spi.function.SqlType;
import io.trino.spi.type.StandardTypes;

import java.io.IOException;
import java.io.InputStreamReader;
import java.io.Reader;

import static java.nio.charset.StandardCharsets.UTF_16LE;
import static java.nio.charset.StandardCharsets.UTF_32LE;
import static java.nio.charset.StandardCharsets.UTF_8;

/**
 * Read string input as JSON.
 * <p>
 * These functions are used by JSON_EXISTS, JSON_VALUE and JSON_QUERY functions
 * for parsing the JSON input arguments and applicable JSON path parameters.
 * <p>
 * If the error handling strategy of the enclosing JSON function is ERROR ON ERROR,
 * these input functions throw exception in case of parse error.
 * Otherwise, the parse error is suppressed, and a marker value JSON_ERROR
 * is returned, so that the enclosing function can handle the error accordingly
 * to its error handling strategy (e.g. return a default value).
 * <p>
 * A duplicate key in a JSON object does not cause error.
 * The resulting SQL/JSON item preserves all duplicate members.
 */
public final class JsonInputFunctions
{
    public static final String VARCHAR_TO_JSON = "$varchar_to_json";
    public static final String VARBINARY_TO_JSON = "$varbinary_to_json";
    public static final String VARBINARY_UTF8_TO_JSON = "$varbinary_utf8_to_json";
    public static final String VARBINARY_UTF16_TO_JSON = "$varbinary_utf16_to_json";
    public static final String VARBINARY_UTF32_TO_JSON = "$varbinary_utf32_to_json";

    private JsonInputFunctions() {}

    @ScalarFunction(value = VARCHAR_TO_JSON, hidden = true)
    @SqlType(StandardTypes.JSON_2016)
    public static Object varcharToJson(@SqlType(StandardTypes.VARCHAR) Slice inputExpression, @SqlType(StandardTypes.BOOLEAN) boolean failOnError)
    {
        Reader reader = new InputStreamReader(inputExpression.getInput(), UTF_8);
        return toJson(reader, failOnError);
    }

    @ScalarFunction(value = VARBINARY_TO_JSON, hidden = true)
    @SqlType(StandardTypes.JSON_2016)
    public static Object varbinaryToJson(@SqlType(StandardTypes.VARBINARY) Slice inputExpression, @SqlType(StandardTypes.BOOLEAN) boolean failOnError)
    {
        return varbinaryUtf8ToJson(inputExpression, failOnError);
    }

    @ScalarFunction(value = VARBINARY_UTF8_TO_JSON, hidden = true)
    @SqlType(StandardTypes.JSON_2016)
    public static Object varbinaryUtf8ToJson(@SqlType(StandardTypes.VARBINARY) Slice inputExpression, @SqlType(StandardTypes.BOOLEAN) boolean failOnError)
    {
        Reader reader = new InputStreamReader(inputExpression.getInput(), UTF_8);
        return toJson(reader, failOnError);
    }

    @ScalarFunction(value = VARBINARY_UTF16_TO_JSON, hidden = true)
    @SqlType(StandardTypes.JSON_2016)
    public static Object varbinaryUtf16ToJson(@SqlType(StandardTypes.VARBINARY) Slice inputExpression, @SqlType(StandardTypes.BOOLEAN) boolean failOnError)
    {
        Reader reader = new InputStreamReader(inputExpression.getInput(), UTF_16LE);
        return toJson(reader, failOnError);
    }

    @ScalarFunction(value = VARBINARY_UTF32_TO_JSON, hidden = true)
    @SqlType(StandardTypes.JSON_2016)
    public static Object varbinaryUtf32ToJson(@SqlType(StandardTypes.VARBINARY) Slice inputExpression, @SqlType(StandardTypes.BOOLEAN) boolean failOnError)
    {
        Reader reader = new InputStreamReader(inputExpression.getInput(), UTF_32LE);
        return toJson(reader, failOnError);
    }

    private static Object toJson(Reader reader, boolean failOnError)
    {
        try {
            return JsonValueView.root(JsonItemEncoding.encode(JsonItems.parseJson(reader)));
        }
        catch (RuntimeException | IOException e) {
            if (failOnError) {
                throw new JsonInputConversionException(e);
            }
            return JsonValueView.jsonError();
        }
    }
}
