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
import org.junit.jupiter.api.Test;

import java.io.IOException;
import java.io.Reader;
import java.io.UncheckedIOException;
import java.util.List;

import static io.airlift.slice.Slices.utf8Slice;
import static io.trino.spi.type.BooleanType.BOOLEAN;
import static io.trino.spi.type.CharType.createCharType;
import static io.trino.spi.type.DecimalType.createDecimalType;
import static io.trino.spi.type.IntegerType.INTEGER;
import static io.trino.spi.type.VarcharType.VARCHAR;
import static org.assertj.core.api.Assertions.assertThat;

public class TestJsonItems
{
    @Test
    public void testParseJsonPreservesDuplicateMembers()
    {
        assertThat(parseJson("{\"key\":1,\"key\":2,\"nested\":[true,null,\"abc\",1.2]}"))
                .isEqualTo(new JsonObject(List.of(
                        new JsonObjectMember("key", new TypedValue(INTEGER, 1L)),
                        new JsonObjectMember("key", new TypedValue(INTEGER, 2L)),
                        new JsonObjectMember("nested", new JsonArray(List.of(
                                new TypedValue(BOOLEAN, true),
                                JsonNull.JSON_NULL,
                                new TypedValue(VARCHAR, utf8Slice("abc")),
                                new TypedValue(createDecimalType(2, 1), 12L)))))));
    }

    @Test
    public void testJsonTextSerializesSupportedValues()
    {
        JsonValue item = new JsonArray(List.of(
                new TypedValue(BOOLEAN, true),
                new TypedValue(createCharType(4), utf8Slice("x")),
                new TypedValue(INTEGER, 7L),
                new TypedValue(createDecimalType(3, 1), 125L)));

        assertThat(JsonItems.jsonText(item).toStringUtf8())
                .isEqualTo("[true,\"x   \",7,12.5]");
    }

    @Test
    public void testScalarText()
    {
        assertThat(JsonItems.scalarText(new TypedValue(createCharType(4), utf8Slice("x"))))
                .map(Slice::toStringUtf8)
                .contains("x   ");

        assertThat(JsonItems.scalarText(new TypedValue(VARCHAR, utf8Slice("abc"))))
                .map(Slice::toStringUtf8)
                .contains("abc");

        assertThat(JsonItems.scalarText(JsonNull.JSON_NULL)).isEmpty();
    }

    private static JsonValue parseJson(String json)
    {
        try {
            return JsonItems.parseJson(Reader.of(json));
        }
        catch (IOException e) {
            throw new UncheckedIOException(e);
        }
    }
}
