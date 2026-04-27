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

import io.trino.json.JsonItemSemantics;
import io.trino.json.JsonItems;
import io.trino.json.JsonPathItem;
import io.trino.json.JsonValueView;
import io.trino.json.MaterializedJsonValue;
import io.trino.sql.query.QueryAssertions;
import org.junit.jupiter.api.AfterAll;
import org.junit.jupiter.api.BeforeAll;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.TestInstance;
import org.junit.jupiter.api.parallel.Execution;

import java.io.IOException;
import java.io.Reader;
import java.io.UncheckedIOException;
import java.nio.charset.Charset;
import java.nio.charset.StandardCharsets;

import static com.google.common.io.BaseEncoding.base16;
import static io.trino.spi.StandardErrorCode.JSON_INPUT_CONVERSION_ERROR;
import static io.trino.testing.assertions.TrinoExceptionAssert.assertTrinoExceptionThrownBy;
import static io.trino.type.Json2016Type.JSON_2016;
import static java.nio.charset.StandardCharsets.UTF_16BE;
import static java.nio.charset.StandardCharsets.UTF_16LE;
import static java.nio.charset.StandardCharsets.UTF_8;
import static org.assertj.core.api.Assertions.assertThat;
import static org.junit.jupiter.api.TestInstance.Lifecycle.PER_CLASS;
import static org.junit.jupiter.api.parallel.ExecutionMode.CONCURRENT;

@TestInstance(PER_CLASS)
@Execution(CONCURRENT)
public class TestJsonInputFunctions
{
    private static final String INPUT = "{\"key1\" : 1e0, \"key2\" : true, \"key3\" : null}";
    private static final MaterializedJsonValue JSON_OBJECT = parseJsonValue(INPUT);
    private static final String ERROR_INPUT = "[...";

    private QueryAssertions assertions;

    @BeforeAll
    public void init()
    {
        assertions = new QueryAssertions();
    }

    @AfterAll
    public void teardown()
    {
        assertions.close();
        assertions = null;
    }

    @Test
    public void testVarcharToJson()
    {
        assertJsonValue("\"$varchar_to_json\"('[]', true)", parseJsonValue("[]"));

        assertJsonValue("\"$varchar_to_json\"('" + INPUT + "', true)", JSON_OBJECT);

        // with unsuppressed input conversion error
        assertTrinoExceptionThrownBy(assertions.expression("\"$varchar_to_json\"('" + ERROR_INPUT + "', true)")::evaluate)
                .hasErrorCode(JSON_INPUT_CONVERSION_ERROR)
                .hasMessage("conversion to JSON failed: ");

        // with input conversion error suppressed and converted to JSON_ERROR
        assertJsonError("\"$varchar_to_json\"('" + ERROR_INPUT + "', false)");
    }

    @Test
    public void testVarbinaryUtf8ToJson()
    {
        assertJsonValue("\"$varbinary_to_json\"(" + toVarbinary(INPUT, UTF_8) + ", true)", JSON_OBJECT);

        assertJsonValue("\"$varbinary_utf8_to_json\"(" + toVarbinary(INPUT, UTF_8) + ", true)", JSON_OBJECT);

        // wrong input encoding

        assertTrinoExceptionThrownBy(assertions.expression("\"$varbinary_utf8_to_json\"(" + toVarbinary(INPUT, UTF_16LE) + ", true)")::evaluate)
                .hasErrorCode(JSON_INPUT_CONVERSION_ERROR)
                .hasMessage("conversion to JSON failed: ");

        // wrong input encoding; conversion error suppressed and converted to JSON_ERROR
        assertJsonError("\"$varbinary_utf8_to_json\"(" + toVarbinary(INPUT, UTF_16LE) + ", false)");

        // correct encoding, incorrect input

        // with unsuppressed input conversion error
        assertTrinoExceptionThrownBy(assertions.expression("\"$varbinary_utf8_to_json\"(" + toVarbinary(ERROR_INPUT, UTF_8) + ", true)")::evaluate)
                .hasErrorCode(JSON_INPUT_CONVERSION_ERROR)
                .hasMessage("conversion to JSON failed: ");

        // with input conversion error suppressed and converted to JSON_ERROR
        assertJsonError("\"$varbinary_utf8_to_json\"(" + toVarbinary(ERROR_INPUT, UTF_8) + ", false)");
    }

    @Test
    public void testVarbinaryUtf16ToJson()
    {
        assertJsonValue("\"$varbinary_utf16_to_json\"(" + toVarbinary(INPUT, UTF_16LE) + ", true)", JSON_OBJECT);

        // wrong input encoding
        String varbinaryLiteral = toVarbinary(INPUT, UTF_16BE);

        assertTrinoExceptionThrownBy(assertions.expression("\"$varbinary_utf16_to_json\"(" + varbinaryLiteral + ", true)")::evaluate)
                .hasErrorCode(JSON_INPUT_CONVERSION_ERROR)
                .hasMessage("conversion to JSON failed: ");

        assertTrinoExceptionThrownBy(assertions.expression("\"$varbinary_utf16_to_json\"(" + toVarbinary(INPUT, UTF_8) + ", true)")::evaluate)
                .hasErrorCode(JSON_INPUT_CONVERSION_ERROR)
                .hasMessage("conversion to JSON failed: ");

        // wrong input encoding; conversion error suppressed and converted to JSON_ERROR
        assertJsonError("\"$varbinary_utf16_to_json\"(" + toVarbinary(INPUT, UTF_8) + ", false)");

        // correct encoding, incorrect input

        // with unsuppressed input conversion error
        assertTrinoExceptionThrownBy(assertions.expression("\"$varbinary_utf16_to_json\"(" + toVarbinary(ERROR_INPUT, UTF_16LE) + ", true)")::evaluate)
                .hasErrorCode(JSON_INPUT_CONVERSION_ERROR)
                .hasMessage("conversion to JSON failed: ");

        // with input conversion error suppressed and converted to JSON_ERROR
        assertJsonError("\"$varbinary_utf16_to_json\"(" + toVarbinary(ERROR_INPUT, UTF_16LE) + ", false)");
    }

    @Test
    public void testVarbinaryUtf32ToJson()
    {
        assertJsonValue("\"$varbinary_utf32_to_json\"(" + toVarbinary(INPUT, StandardCharsets.UTF_32LE) + ", true)", JSON_OBJECT);

        // wrong input encoding

        assertTrinoExceptionThrownBy(assertions.expression("\"$varbinary_utf32_to_json\"(" + toVarbinary(INPUT, StandardCharsets.UTF_32BE) + ", true)")::evaluate)
                .hasErrorCode(JSON_INPUT_CONVERSION_ERROR)
                .hasMessage("conversion to JSON failed: ");

        assertTrinoExceptionThrownBy(assertions.expression("\"$varbinary_utf32_to_json\"(" + toVarbinary(INPUT, UTF_8) + ", true)")::evaluate)
                .hasErrorCode(JSON_INPUT_CONVERSION_ERROR)
                .hasMessage("conversion to JSON failed: ");

        // wrong input encoding; conversion error suppressed and converted to JSON_ERROR
        assertJsonError("\"$varbinary_utf32_to_json\"(" + toVarbinary(INPUT, UTF_8) + ", false)");

        // correct encoding, incorrect input

        // with unsuppressed input conversion error
        assertTrinoExceptionThrownBy(assertions.expression("\"$varbinary_utf32_to_json\"(" + toVarbinary(ERROR_INPUT, StandardCharsets.UTF_32LE) + ", true)")::evaluate)
                .hasErrorCode(JSON_INPUT_CONVERSION_ERROR)
                .hasMessage("conversion to JSON failed: ");

        // with input conversion error suppressed and converted to JSON_ERROR
        assertJsonError("\"$varbinary_utf32_to_json\"(" + toVarbinary(ERROR_INPUT, StandardCharsets.UTF_32LE) + ", false)");
    }

    @Test
    public void testNullInput()
    {
        assertThat(assertions.expression("\"$varchar_to_json\"(null, true)"))
                .isNull(JSON_2016);
    }

    @Test
    public void testJsonToJson()
    {
        assertJsonValue("\"$json_to_json\"(JSON '" + INPUT.replace("'", "''") + "', true)", JSON_OBJECT);
    }

    @Test
    public void testDuplicateObjectKeys()
    {
        // A duplicate key does not cause error. The resulting object preserves all members with that key.
        assertJsonValue("\"$varchar_to_json\"('{\"key\" : 1, \"key\" : 2}', true)", parseJsonValue("{\"key\" : 1, \"key\" : 2}"));
    }

    private void assertJsonValue(String expression, MaterializedJsonValue expected)
    {
        assertThat(assertions.expression(expression))
                .hasType(JSON_2016)
                .satisfies(actual -> {
                    assertThat(actual).isInstanceOf(JsonPathItem.class);
                    assertThat(JsonItemSemantics.equals((JsonPathItem) actual, expected)).isTrue();
                });
    }

    private void assertJsonError(String expression)
    {
        assertThat(assertions.expression(expression))
                .hasType(JSON_2016)
                .satisfies(actual -> assertThat(JsonValueView.isJsonError(actual)).isTrue());
    }

    private static MaterializedJsonValue parseJsonValue(String json)
    {
        try {
            return JsonItems.parseJson(Reader.of(json));
        }
        catch (IOException e) {
            throw new UncheckedIOException(e);
        }
    }

    private static String toVarbinary(String value, Charset encoding)
    {
        return "X'" + base16().encode(value.getBytes(encoding)) + "'";
    }
}
