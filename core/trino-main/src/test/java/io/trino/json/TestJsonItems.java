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
import io.trino.operator.scalar.json.JsonInputConversionException;
import io.trino.operator.scalar.json.JsonOutputConversionException;
import io.trino.spi.type.NumberType;
import io.trino.spi.type.TrinoNumber;
import org.junit.jupiter.api.Test;

import java.io.IOException;
import java.io.Reader;
import java.io.UncheckedIOException;
import java.math.BigDecimal;
import java.util.List;

import static io.airlift.slice.Slices.utf8Slice;
import static io.trino.spi.type.BooleanType.BOOLEAN;
import static io.trino.spi.type.CharType.createCharType;
import static io.trino.spi.type.DecimalType.createDecimalType;
import static io.trino.spi.type.IntegerType.INTEGER;
import static io.trino.spi.type.VarcharType.VARCHAR;
import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;

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
        MaterializedJsonValue item = new JsonArrayItem(List.of(
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
    public void testParseJsonRejectsTooLargeNumber()
    {
        assertThatThrownBy(() -> parseJson("1000000000000000000000000000000000000"))
                .isInstanceOf(JsonInputConversionException.class)
                .hasMessage("conversion to JSON failed: value too big");
    }

    @Test
    public void testAsJsonValueAcceptsEncodedJsonItem()
    {
        MaterializedJsonValue value = JsonItems.asJsonValue(new EncodedJsonItem(JsonItemEncoding.encode(parseJson("[1, 2, 3]"))));

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
    public void testNumberTypeEncodingRoundTripsFiniteAndNonFinite()
    {
        TypedValue finite = new TypedValue(NumberType.NUMBER, TrinoNumber.from(new BigDecimal("12345.6789")));
        TypedValue nan = new TypedValue(NumberType.NUMBER, TrinoNumber.from(new TrinoNumber.NotANumber()));
        TypedValue positiveInfinity = new TypedValue(NumberType.NUMBER, TrinoNumber.from(new TrinoNumber.Infinity(false)));
        TypedValue negativeInfinity = new TypedValue(NumberType.NUMBER, TrinoNumber.from(new TrinoNumber.Infinity(true)));

        for (TypedValue value : List.of(finite, nan, positiveInfinity, negativeInfinity)) {
            Slice encoded = JsonItemEncoding.encode(value);
            assertThat(JsonItemEncoding.decodeValue(encoded)).isEqualTo(value);
        }
    }

    @Test
    public void testJsonTextRejectsNonFiniteNumber()
    {
        TypedValue nan = new TypedValue(NumberType.NUMBER, TrinoNumber.from(new TrinoNumber.NotANumber()));
        assertThatThrownBy(() -> JsonItems.jsonText(nan))
                .isInstanceOf(JsonOutputConversionException.class)
                .hasMessageContaining("Non-finite NUMBER");

        TypedValue positiveInfinity = new TypedValue(NumberType.NUMBER, TrinoNumber.from(new TrinoNumber.Infinity(false)));
        assertThatThrownBy(() -> JsonItems.jsonText(new EncodedJsonItem(JsonItemEncoding.encode(positiveInfinity))))
                .isInstanceOf(JsonOutputConversionException.class)
                .hasMessageContaining("Non-finite NUMBER");
    }

    @Test
    public void testJsonItemSemanticsMatchesEncodedAndMaterializedValues()
    {
        MaterializedJsonValue materialized = parseJson("{\"a\":[1,2],\"b\":\"x\"}");
        JsonPathItem encoded = new EncodedJsonItem(JsonItemEncoding.encode(materialized));

        assertThat(JsonItemSemantics.equals(materialized, encoded)).isTrue();
        assertThat(JsonItemSemantics.equals(encoded, materialized)).isTrue();
        assertThat(JsonItemSemantics.hash(materialized)).isEqualTo(JsonItemSemantics.hash(encoded));
    }

    @Test
    public void testJsonItemSemanticsCanonicalizesZero()
    {
        // SQL/JSON numeric equality compares on canonical decimal value, so 0, 0.0, and 0e0
        // collapse to the same parsed item even though their textual forms differ.
        MaterializedJsonValue zero = parseJson("0");
        MaterializedJsonValue zeroPoint = parseJson("0.0");
        MaterializedJsonValue zeroExp = parseJson("0e0");

        assertThat(JsonItemSemantics.equals(zero, zeroPoint)).isTrue();
        assertThat(JsonItemSemantics.equals(zero, zeroExp)).isTrue();
        assertThat(JsonItemSemantics.equals(zeroPoint, zeroExp)).isTrue();
        assertThat(JsonItemSemantics.hash(zero)).isEqualTo(JsonItemSemantics.hash(zeroPoint));
        assertThat(JsonItemSemantics.hash(zero)).isEqualTo(JsonItemSemantics.hash(zeroExp));

        // 1, 1.0, 1e0 all collapse the same way.
        MaterializedJsonValue one = parseJson("1");
        MaterializedJsonValue onePoint = parseJson("1.0");
        MaterializedJsonValue oneExp = parseJson("1e0");
        assertThat(JsonItemSemantics.equals(one, onePoint)).isTrue();
        assertThat(JsonItemSemantics.equals(one, oneExp)).isTrue();
        assertThat(JsonItemSemantics.hash(one)).isEqualTo(JsonItemSemantics.hash(onePoint));
        assertThat(JsonItemSemantics.hash(one)).isEqualTo(JsonItemSemantics.hash(oneExp));
    }

    @Test
    public void testJsonItemSemanticsNonFiniteEqualityAcrossKinds()
    {
        // Non-finite REAL, DOUBLE, and NumberType compare equal by kind: NaN==NaN,
        // +Inf==+Inf, -Inf==-Inf, regardless of which numeric type carries the sentinel.
        TypedValue doubleNaN = new TypedValue(io.trino.spi.type.DoubleType.DOUBLE, Double.NaN);
        TypedValue realNaN = new TypedValue(io.trino.spi.type.RealType.REAL, (long) Float.floatToRawIntBits(Float.NaN));
        TypedValue numberNaN = new TypedValue(io.trino.spi.type.NumberType.NUMBER, io.trino.spi.type.TrinoNumber.from(new io.trino.spi.type.TrinoNumber.NotANumber()));

        assertThat(JsonItemSemantics.equals(doubleNaN, realNaN)).isTrue();
        assertThat(JsonItemSemantics.equals(doubleNaN, numberNaN)).isTrue();
        assertThat(JsonItemSemantics.equals(realNaN, numberNaN)).isTrue();
        assertThat(JsonItemSemantics.hash(doubleNaN)).isEqualTo(JsonItemSemantics.hash(realNaN));
        assertThat(JsonItemSemantics.hash(doubleNaN)).isEqualTo(JsonItemSemantics.hash(numberNaN));

        TypedValue doublePosInf = new TypedValue(io.trino.spi.type.DoubleType.DOUBLE, Double.POSITIVE_INFINITY);
        TypedValue realPosInf = new TypedValue(io.trino.spi.type.RealType.REAL, (long) Float.floatToRawIntBits(Float.POSITIVE_INFINITY));
        TypedValue numberPosInf = new TypedValue(io.trino.spi.type.NumberType.NUMBER, io.trino.spi.type.TrinoNumber.from(new io.trino.spi.type.TrinoNumber.Infinity(false)));
        assertThat(JsonItemSemantics.equals(doublePosInf, realPosInf)).isTrue();
        assertThat(JsonItemSemantics.equals(doublePosInf, numberPosInf)).isTrue();

        TypedValue doubleNegInf = new TypedValue(io.trino.spi.type.DoubleType.DOUBLE, Double.NEGATIVE_INFINITY);
        TypedValue realNegInf = new TypedValue(io.trino.spi.type.RealType.REAL, (long) Float.floatToRawIntBits(Float.NEGATIVE_INFINITY));
        TypedValue numberNegInf = new TypedValue(io.trino.spi.type.NumberType.NUMBER, io.trino.spi.type.TrinoNumber.from(new io.trino.spi.type.TrinoNumber.Infinity(true)));
        assertThat(JsonItemSemantics.equals(doubleNegInf, realNegInf)).isTrue();
        assertThat(JsonItemSemantics.equals(doubleNegInf, numberNegInf)).isTrue();

        // +Inf and -Inf are distinct kinds.
        assertThat(JsonItemSemantics.equals(doublePosInf, doubleNegInf)).isFalse();
        // NaN and +Inf are distinct kinds.
        assertThat(JsonItemSemantics.equals(doubleNaN, doublePosInf)).isFalse();
    }

    @Test
    public void testJsonItemSemanticsCharVarcharPadSpace()
    {
        // SQL/JSON character comparison uses PAD SPACE collation: trailing spaces are
        // not significant, so CHAR(5) "ab" and VARCHAR "ab" compare equal regardless
        // of how the storage type pads the value.
        TypedValue varcharShort = new TypedValue(VARCHAR, utf8Slice("ab"));
        TypedValue varcharPadded = new TypedValue(VARCHAR, utf8Slice("ab   "));
        TypedValue charShort = new TypedValue(createCharType(2), utf8Slice("ab"));
        TypedValue charPadded5 = new TypedValue(createCharType(5), utf8Slice("ab"));

        assertThat(JsonItemSemantics.equals(varcharShort, charShort)).isTrue();
        assertThat(JsonItemSemantics.equals(varcharShort, charPadded5)).isTrue();
        assertThat(JsonItemSemantics.equals(varcharPadded, charPadded5)).isTrue();
        assertThat(JsonItemSemantics.equals(varcharPadded, charShort)).isTrue();
        assertThat(JsonItemSemantics.hash(varcharShort)).isEqualTo(JsonItemSemantics.hash(charShort));
        assertThat(JsonItemSemantics.hash(varcharShort)).isEqualTo(JsonItemSemantics.hash(charPadded5));
        assertThat(JsonItemSemantics.hash(varcharShort)).isEqualTo(JsonItemSemantics.hash(varcharPadded));
    }

    @Test
    public void testIndexedArrayEncodingRoundTrip()
    {
        // Arrays of size >= INDEXED_CONTAINER_THRESHOLD (=8) are emitted in ARRAY_INDEXED
        // form; the round-trip through encode/decode/encode must be a fixed point.
        MaterializedJsonValue array = parseJson("[0,1,2,3,4,5,6,7,8,9,10]");
        Slice encoded1 = JsonItemEncoding.encode(array);
        MaterializedJsonValue decoded = JsonItemEncoding.decodeValue(encoded1);
        Slice encoded2 = JsonItemEncoding.encode(decoded);
        assertThat(encoded1).isEqualTo(encoded2);
    }

    @Test
    public void testIndexedObjectEncodingRoundTrip()
    {
        // Objects of size >= INDEXED_CONTAINER_THRESHOLD (=8) are emitted in OBJECT_INDEXED
        // form; round-trip through encode/decode/encode must be a fixed point and preserve
        // insertion order regardless of the sort permutation header.
        MaterializedJsonValue object = parseJson("{\"z\":1,\"a\":2,\"m\":3,\"b\":4,\"c\":5,\"d\":6,\"e\":7,\"f\":8}");
        Slice encoded1 = JsonItemEncoding.encode(object);
        MaterializedJsonValue decoded = JsonItemEncoding.decodeValue(encoded1);
        Slice encoded2 = JsonItemEncoding.encode(decoded);
        assertThat(encoded1).isEqualTo(encoded2);
        // Insertion order survives the round-trip.
        assertThat(JsonItems.jsonText(decoded).toStringUtf8())
                .isEqualTo("{\"z\":1,\"a\":2,\"m\":3,\"b\":4,\"c\":5,\"d\":6,\"e\":7,\"f\":8}");
    }

    private static MaterializedJsonValue parseJson(String json)
    {
        try {
            return JsonItems.parseJson(Reader.of(json));
        }
        catch (IOException e) {
            throw new UncheckedIOException(e);
        }
    }
}
