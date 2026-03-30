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

import io.trino.json.ir.TypedValue;
import org.junit.jupiter.api.Test;

import static io.trino.spi.type.DateType.DATE;
import static io.trino.spi.type.TimeWithTimeZoneType.createTimeWithTimeZoneType;
import static io.trino.spi.type.TimestampType.createTimestampType;
import static io.trino.spi.type.TimestampWithTimeZoneType.createTimestampWithTimeZoneType;
import static io.trino.type.DateTimes.parseTimeWithTimeZone;
import static io.trino.type.DateTimes.parseTimestamp;
import static io.trino.type.DateTimes.parseTimestampWithTimeZone;
import static io.trino.util.DateTimeUtils.parseDate;
import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;

public class TestJsonDateTimeTemplate
{
    @Test
    public void testTypeInference()
    {
        assertThat(JsonDateTimeTemplate.parse("YYYY-MM-DD").getType()).isEqualTo(DATE);
        assertThat(JsonDateTimeTemplate.parse("HH24:MI:SS.FF3TZH:TZM").getType()).isEqualTo(createTimeWithTimeZoneType(3));
        assertThat(JsonDateTimeTemplate.parse("YYYY-MM-DD HH24:MI:SS.FF3").getType()).isEqualTo(createTimestampType(3));
        assertThat(JsonDateTimeTemplate.parse("YYYY-MM-DD HH24:MI:SS.FF3 TZH:TZM").getType()).isEqualTo(createTimestampWithTimeZoneType(3));
    }

    @Test
    public void testParseValue()
    {
        TypedValue date = JsonDateTimeTemplate.parse("YYYY-MM-DD").parseValue("2024-01-02");
        assertThat(date).isEqualTo(new TypedValue(DATE, (long) parseDate("2024-01-02")));

        TypedValue timeWithTimeZone = JsonDateTimeTemplate.parse("HH24:MI:SS.FF3TZH:TZM").parseValue("12:34:56.789+05:30");
        assertThat(timeWithTimeZone).isEqualTo(TypedValue.fromValueAsObject(createTimeWithTimeZoneType(3), parseTimeWithTimeZone(3, "12:34:56.789 +05:30")));

        TypedValue timestamp = JsonDateTimeTemplate.parse("YYYY-MM-DD HH24:MI:SS.FF3").parseValue("2024-01-02 12:34:56.789");
        assertThat(timestamp).isEqualTo(TypedValue.fromValueAsObject(createTimestampType(3), parseTimestamp(3, "2024-01-02 12:34:56.789")));

        TypedValue timestampWithTimeZone = JsonDateTimeTemplate.parse("YYYY-MM-DD HH24:MI:SS.FF3 TZH:TZM").parseValue("2024-01-02 12:34:56.789 +05:30");
        assertThat(timestampWithTimeZone).isEqualTo(TypedValue.fromValueAsObject(createTimestampWithTimeZoneType(3), parseTimestampWithTimeZone(3, "2024-01-02 12:34:56.789 +05:30")));
    }

    @Test
    public void testInvalidTemplates()
    {
        assertThatThrownBy(() -> JsonDateTimeTemplate.parse("YYYYRR"))
                .isInstanceOf(IllegalArgumentException.class)
                .hasMessage("datetime() format template cannot contain both year and rounded year fields");

        assertThatThrownBy(() -> JsonDateTimeTemplate.parse("HH24A.M."))
                .isInstanceOf(IllegalArgumentException.class)
                .hasMessage("datetime() format template with HH24 cannot contain HH, HH12, A.M. or P.M.");

        assertThatThrownBy(() -> JsonDateTimeTemplate.parse("TZM"))
                .isInstanceOf(IllegalArgumentException.class)
                .hasMessage("datetime() format template with TZM requires TZH");
    }

    @Test
    public void testQuotedLiteralTemplate()
    {
        // Double-quoted literal text in the template must match verbatim during parsing.
        TypedValue timestamp = JsonDateTimeTemplate.parse("YYYY-MM-DD\"T\"HH24:MI:SS.FF3")
                .parseValue("2024-01-02T12:34:56.789");
        assertThat(timestamp).isEqualTo(TypedValue.fromValueAsObject(createTimestampType(3), parseTimestamp(3, "2024-01-02 12:34:56.789")));

        // Mismatched literal text raises a diagnostic with position information.
        assertThatThrownBy(() -> JsonDateTimeTemplate.parse("YYYY-MM-DD\"T\"HH24")
                .parseValue("2024-01-02X12:34:56"))
                .isInstanceOf(IllegalArgumentException.class)
                .hasMessageContaining("expected literal 'T'");
    }

    @Test
    public void testFF10To12Precision()
    {
        // FF10..FF12 map to TIMESTAMP precisions above 9, matching Trino's max precision of 12.
        assertThat(JsonDateTimeTemplate.parse("YYYY-MM-DD HH24:MI:SS.FF12").getType())
                .isEqualTo(createTimestampType(12));

        TypedValue ts = JsonDateTimeTemplate.parse("YYYY-MM-DD HH24:MI:SS.FF12")
                .parseValue("2024-01-02 12:34:56.123456789012");
        assertThat(ts).isEqualTo(TypedValue.fromValueAsObject(createTimestampType(12), parseTimestamp(12, "2024-01-02 12:34:56.123456789012")));
    }

    @Test
    public void testAmPmCaseInsensitive()
    {
        // A.M. / P.M. comparisons use case-insensitive matching.
        TypedValue lower = JsonDateTimeTemplate.parse("YYYY-MM-DD HH12:MI:SS a.m.")
                .parseValue("2024-01-02 10:11:12 p.m.");
        assertThat(lower).isEqualTo(TypedValue.fromValueAsObject(createTimestampType(0), parseTimestamp(0, "2024-01-02 22:11:12")));
    }

    @Test
    public void testEmptyTemplateRejected()
    {
        assertThatThrownBy(() -> JsonDateTimeTemplate.parse(""))
                .isInstanceOf(IllegalArgumentException.class)
                .hasMessageContaining("empty");
    }

    @Test
    public void testInvalidCharacterCarriesPosition()
    {
        // Invalid template characters include their position in the diagnostic.
        assertThatThrownBy(() -> JsonDateTimeTemplate.parse("YYYY@MM"))
                .isInstanceOf(IllegalArgumentException.class)
                .hasMessageContaining("position 4");
    }
}
