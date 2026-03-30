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
import io.trino.json.ir.TypedValue;
import org.junit.jupiter.api.Test;

import java.io.IOException;
import java.io.Reader;
import java.io.UncheckedIOException;
import java.util.List;

import static io.airlift.slice.Slices.utf8Slice;
import static io.trino.spi.type.BooleanType.BOOLEAN;
import static io.trino.spi.type.CharType.createCharType;
import static io.trino.spi.type.DateType.DATE;
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
                .isEqualTo(new JsonObjectItem(List.of(
                        new JsonObjectMember("key", new TypedValue(INTEGER, 1L)),
                        new JsonObjectMember("key", new TypedValue(INTEGER, 2L)),
                        new JsonObjectMember("nested", new JsonArrayItem(List.of(
                                new TypedValue(BOOLEAN, true),
                                JsonNull.JSON_NULL,
                                new TypedValue(VARCHAR, utf8Slice("abc")),
                                new TypedValue(createDecimalType(2, 1), 12L)))))));
    }

    @Test
    public void testJsonTextSerializesSupportedValues()
    {
        JsonValue item = new JsonArrayItem(List.of(
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

    @Test
    public void testJsonValueViewScalarText()
    {
        JsonValueView view = JsonValueView.fromObject(new EncodedJsonItem(JsonItemEncoding.encode(new TypedValue(VARCHAR, utf8Slice("abc")))))
                .orElseThrow();

        assertThat(view.scalarText())
                .map(Slice::toStringUtf8)
                .contains("abc");
    }

    @Test
    public void testParseJsonPreservesNumberOutsideDecimalRange()
    {
        // Values outside DECIMAL(<=38) fall back to NUMBER, preserving arbitrary precision.
        assertThat(parseJson("100000000000000000000000000000000000000000000000000"))
                .isInstanceOf(TypedValue.class);
    }

    @Test
    public void testSurrogateJsonTextStringifiesEncodedDatetimeValue()
    {
        JsonPathItem item = new EncodedJsonItem(JsonItemEncoding.encode(new TypedValue(DATE, 1L)));

        assertThat(JsonItems.surrogateJsonText(item).toStringUtf8()).isEqualTo("\"1970-01-02\"");
    }

    @Test
    public void testAsJsonValueAcceptsEncodedJsonItem()
    {
        JsonValue value = JsonItems.asJsonValue(new EncodedJsonItem(JsonItemEncoding.encode(parseJson("[1, 2, 3]"))));

        assertThat(value).isEqualTo(new JsonArrayItem(List.of(
                new TypedValue(INTEGER, 1L),
                new TypedValue(INTEGER, 2L),
                new TypedValue(INTEGER, 3L))));
    }

    @Test
    public void testJsonTextAcceptsEncodedJsonItem()
    {
        String value = JsonItems.jsonText(new EncodedJsonItem(JsonItemEncoding.encode(parseJson("{\"a\":[1,null]}")))).toStringUtf8();

        assertThat(value).isEqualTo("{\"a\":[1,null]}");
    }

    @Test
    public void testMaterializeParsesLegacyTextualEncodedJsonItem()
    {
        JsonPathItem item = JsonItems.materialize(new EncodedJsonItem(utf8Slice("{\"a\":1}")));

        assertThat(item).isEqualTo(new JsonObjectItem(List.of(
                new JsonObjectMember("a", new TypedValue(INTEGER, 1L)))));
    }

    @Test
    public void testJsonItemSemanticsMatchesEncodedAndMaterializedValues()
    {
        JsonValue materialized = parseJson("{\"a\":[1,2],\"b\":\"x\"}");
        JsonPathItem encoded = new EncodedJsonItem(JsonItemEncoding.encode(materialized));

        assertThat(JsonItemSemantics.equals(materialized, encoded)).isTrue();
        assertThat(JsonItemSemantics.equals(encoded, materialized)).isTrue();
        assertThat(JsonItemSemantics.hash(materialized)).isEqualTo(JsonItemSemantics.hash(encoded));
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
