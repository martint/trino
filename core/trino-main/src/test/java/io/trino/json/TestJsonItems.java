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
import io.trino.spi.type.DoubleType;
import io.trino.spi.type.NumberType;
import io.trino.spi.type.RealType;
import io.trino.spi.type.TrinoNumber;
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

    @Test
    public void testParseJsonPreservesNumberOutsideDecimalRange()
    {
        assertThat(parseJson("100000000000000000000000000000000000000000000000000"))
                .isInstanceOf(TypedValue.class);
    }

    @Test
    public void testJsonTextStringifiesNonFiniteNumber()
    {
        TypedValue nan = new TypedValue(NumberType.NUMBER, TrinoNumber.from(new TrinoNumber.NotANumber()));
        assertThat(JsonItems.jsonText(nan).toStringUtf8()).isEqualTo("\"NaN\"");

        TypedValue positiveInfinity = new TypedValue(NumberType.NUMBER, TrinoNumber.from(new TrinoNumber.Infinity(false)));
        assertThat(JsonItems.jsonText(positiveInfinity).toStringUtf8()).isEqualTo("\"+Infinity\"");

        TypedValue negativeInfinity = new TypedValue(NumberType.NUMBER, TrinoNumber.from(new TrinoNumber.Infinity(true)));
        assertThat(JsonItems.jsonText(negativeInfinity).toStringUtf8()).isEqualTo("\"-Infinity\"");
    }

    @Test
    public void testJsonItemSemanticsCanonicalizesZero()
    {
        // SQL/JSON numeric equality compares on canonical decimal value, so 0, 0.0, and 0e0
        // collapse to the same parsed item even though their textual forms differ.
        JsonValue zero = parseJson("0");
        JsonValue zeroPoint = parseJson("0.0");
        JsonValue zeroExp = parseJson("0e0");

        assertThat(JsonItemSemantics.equals(zero, zeroPoint)).isTrue();
        assertThat(JsonItemSemantics.equals(zero, zeroExp)).isTrue();
        assertThat(JsonItemSemantics.equals(zeroPoint, zeroExp)).isTrue();
        assertThat(JsonItemSemantics.hash(zero)).isEqualTo(JsonItemSemantics.hash(zeroPoint));
        assertThat(JsonItemSemantics.hash(zero)).isEqualTo(JsonItemSemantics.hash(zeroExp));

        JsonValue one = parseJson("1");
        JsonValue onePoint = parseJson("1.0");
        JsonValue oneExp = parseJson("1e0");
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
        TypedValue doubleNaN = new TypedValue(DoubleType.DOUBLE, Double.NaN);
        TypedValue realNaN = new TypedValue(RealType.REAL, (long) Float.floatToRawIntBits(Float.NaN));
        TypedValue numberNaN = new TypedValue(NumberType.NUMBER, TrinoNumber.from(new TrinoNumber.NotANumber()));

        assertThat(JsonItemSemantics.equals(doubleNaN, realNaN)).isTrue();
        assertThat(JsonItemSemantics.equals(doubleNaN, numberNaN)).isTrue();
        assertThat(JsonItemSemantics.equals(realNaN, numberNaN)).isTrue();
        assertThat(JsonItemSemantics.hash(doubleNaN)).isEqualTo(JsonItemSemantics.hash(realNaN));
        assertThat(JsonItemSemantics.hash(doubleNaN)).isEqualTo(JsonItemSemantics.hash(numberNaN));

        TypedValue doublePosInf = new TypedValue(DoubleType.DOUBLE, Double.POSITIVE_INFINITY);
        TypedValue realPosInf = new TypedValue(RealType.REAL, (long) Float.floatToRawIntBits(Float.POSITIVE_INFINITY));
        TypedValue numberPosInf = new TypedValue(NumberType.NUMBER, TrinoNumber.from(new TrinoNumber.Infinity(false)));
        assertThat(JsonItemSemantics.equals(doublePosInf, realPosInf)).isTrue();
        assertThat(JsonItemSemantics.equals(doublePosInf, numberPosInf)).isTrue();

        TypedValue doubleNegInf = new TypedValue(DoubleType.DOUBLE, Double.NEGATIVE_INFINITY);
        TypedValue realNegInf = new TypedValue(RealType.REAL, (long) Float.floatToRawIntBits(Float.NEGATIVE_INFINITY));
        TypedValue numberNegInf = new TypedValue(NumberType.NUMBER, TrinoNumber.from(new TrinoNumber.Infinity(true)));
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
