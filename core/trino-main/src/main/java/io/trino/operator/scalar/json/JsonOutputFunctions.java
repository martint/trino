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

import com.fasterxml.jackson.core.JsonEncoding;
import io.airlift.slice.Slice;
import io.airlift.slice.Slices;
import io.trino.json.JsonArrayItem;
import io.trino.json.JsonItems;
import io.trino.json.JsonObjectItem;
import io.trino.spi.function.ScalarFunction;
import io.trino.spi.function.SqlNullable;
import io.trino.spi.function.SqlType;
import io.trino.spi.type.StandardTypes;

import java.nio.charset.Charset;
import java.nio.charset.StandardCharsets;

import static io.trino.sql.tree.JsonQuery.EmptyOrErrorBehavior.EMPTY_ARRAY;
import static io.trino.sql.tree.JsonQuery.EmptyOrErrorBehavior.EMPTY_OBJECT;
import static io.trino.sql.tree.JsonQuery.EmptyOrErrorBehavior.ERROR;
import static io.trino.sql.tree.JsonQuery.EmptyOrErrorBehavior.NULL;
import static java.util.Objects.requireNonNull;

/**
 * Format JSON as binary or character string, using given encoding.
 * <p>
 * These functions are used to format the output of JSON_QUERY function.
 * In case of error during JSON formatting, the error handling
 * strategy of the enclosing JSON_QUERY function is applied.
 * <p>
 * Additionally, the options KEEP / OMIT QUOTES [ON SCALAR STRING]
 * are respected when formatting the output.
 */
public final class JsonOutputFunctions
{
    public static final String JSON_TO_VARCHAR = "$json_to_varchar";
    public static final String JSON_TO_VARBINARY = "$json_to_varbinary";
    public static final String JSON_TO_VARBINARY_UTF8 = "$json_to_varbinary_utf8";
    public static final String JSON_TO_VARBINARY_UTF16 = "$json_to_varbinary_utf16";
    public static final String JSON_TO_VARBINARY_UTF32 = "$json_to_varbinary_utf32";

    private static final EncodingSpecificConstants UTF_8 = new EncodingSpecificConstants(
            JsonEncoding.UTF8,
            StandardCharsets.UTF_8,
            JsonItems.jsonText(new JsonArrayItem(java.util.List.of())),
            JsonItems.jsonText(new JsonObjectItem(java.util.List.of())));
    private static final EncodingSpecificConstants UTF_16 = new EncodingSpecificConstants(
            JsonEncoding.UTF16_LE,
            StandardCharsets.UTF_16LE,
            Slices.copiedBuffer("[]", StandardCharsets.UTF_16LE),
            Slices.copiedBuffer("{}", StandardCharsets.UTF_16LE));
    private static final EncodingSpecificConstants UTF_32 = new EncodingSpecificConstants(
            JsonEncoding.UTF32_LE,
            StandardCharsets.UTF_32LE,
            Slices.copiedBuffer("[]", StandardCharsets.UTF_32LE),
            Slices.copiedBuffer("{}", StandardCharsets.UTF_32LE));

    private JsonOutputFunctions() {}

    @SqlNullable
    @ScalarFunction(value = JSON_TO_VARCHAR, hidden = true)
    @SqlType(StandardTypes.VARCHAR)
    public static Slice jsonToVarchar(@SqlType(StandardTypes.JSON_2016) Object jsonExpression, @SqlType(StandardTypes.TINYINT) long errorBehavior, @SqlType(StandardTypes.BOOLEAN) boolean omitQuotes)
    {
        return serialize(jsonExpression, UTF_8, errorBehavior, omitQuotes);
    }

    @SqlNullable
    @ScalarFunction(value = JSON_TO_VARBINARY, hidden = true)
    @SqlType(StandardTypes.VARBINARY)
    public static Slice jsonToVarbinary(@SqlType(StandardTypes.JSON_2016) Object jsonExpression, @SqlType(StandardTypes.TINYINT) long errorBehavior, @SqlType(StandardTypes.BOOLEAN) boolean omitQuotes)
    {
        return jsonToVarbinaryUtf8(jsonExpression, errorBehavior, omitQuotes);
    }

    @SqlNullable
    @ScalarFunction(value = JSON_TO_VARBINARY_UTF8, hidden = true)
    @SqlType(StandardTypes.VARBINARY)
    public static Slice jsonToVarbinaryUtf8(@SqlType(StandardTypes.JSON_2016) Object jsonExpression, @SqlType(StandardTypes.TINYINT) long errorBehavior, @SqlType(StandardTypes.BOOLEAN) boolean omitQuotes)
    {
        return serialize(jsonExpression, UTF_8, errorBehavior, omitQuotes);
    }

    @SqlNullable
    @ScalarFunction(value = JSON_TO_VARBINARY_UTF16, hidden = true)
    @SqlType(StandardTypes.VARBINARY)
    public static Slice jsonToVarbinaryUtf16(@SqlType(StandardTypes.JSON_2016) Object jsonExpression, @SqlType(StandardTypes.TINYINT) long errorBehavior, @SqlType(StandardTypes.BOOLEAN) boolean omitQuotes)
    {
        return serialize(jsonExpression, UTF_16, errorBehavior, omitQuotes);
    }

    @SqlNullable
    @ScalarFunction(value = JSON_TO_VARBINARY_UTF32, hidden = true)
    @SqlType(StandardTypes.VARBINARY)
    public static Slice jsonToVarbinaryUtf32(@SqlType(StandardTypes.JSON_2016) Object jsonExpression, @SqlType(StandardTypes.TINYINT) long errorBehavior, @SqlType(StandardTypes.BOOLEAN) boolean omitQuotes)
    {
        return serialize(jsonExpression, UTF_32, errorBehavior, omitQuotes);
    }

    private static Slice serialize(Object json, EncodingSpecificConstants constants, long errorBehavior, boolean omitQuotes)
    {
        if (omitQuotes) {
            java.util.Optional<Slice> scalarText = JsonItems.scalarText(json);
            if (scalarText.isPresent()) {
                return Slices.copiedBuffer(scalarText.get().toStringUtf8(), constants.charset);
            }
        }
        try {
            Slice utf8Json = JsonItems.jsonText(json);
            if (constants.charset.equals(StandardCharsets.UTF_8)) {
                return utf8Json;
            }
            return Slices.copiedBuffer(utf8Json.toStringUtf8(), constants.charset);
        }
        catch (RuntimeException e) {
            if (errorBehavior == NULL.ordinal()) {
                return null;
            }
            if (errorBehavior == ERROR.ordinal()) {
                throw new JsonOutputConversionException(e);
            }
            if (errorBehavior == EMPTY_ARRAY.ordinal()) {
                return constants.emptyArray;
            }
            if (errorBehavior == EMPTY_OBJECT.ordinal()) {
                return constants.emptyObject;
            }
            throw new IllegalStateException("unexpected behavior");
        }
    }

    private static class EncodingSpecificConstants
    {
        private final JsonEncoding jsonEncoding;
        private final Charset charset;
        private final Slice emptyArray;
        private final Slice emptyObject;

        public EncodingSpecificConstants(JsonEncoding jsonEncoding, Charset charset, Slice emptyArray, Slice emptyObject)
        {
            this.jsonEncoding = requireNonNull(jsonEncoding, "jsonEncoding is null");
            this.charset = requireNonNull(charset, "charset is null");
            this.emptyArray = requireNonNull(emptyArray, "emptyArray is null");
            this.emptyObject = requireNonNull(emptyObject, "emptyObject is null");
        }
    }
}
