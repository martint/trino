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
package io.prestosql.operator.scalar.timetz;

import io.prestosql.spi.PrestoException;
import io.prestosql.sql.parser.ParsingException;
import io.prestosql.sql.query.QueryAssertions;
import org.testng.annotations.AfterClass;
import org.testng.annotations.BeforeClass;
import org.testng.annotations.Test;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;

public class TestExtract
{
    protected QueryAssertions assertions;

    @BeforeClass
    public void init()
    {
        assertions = new QueryAssertions();
    }

    @AfterClass(alwaysRun = true)
    public void teardown()
    {
        assertions.close();
        assertions = null;
    }

    @Test
    public void testHour()
    {
        assertThat(assertions.expression("EXTRACT(HOUR FROM TIME '12:34:56+08:35')")).matches("BIGINT '12'");
        assertThat(assertions.expression("EXTRACT(HOUR FROM TIME '12:34:56.1+08:35')")).matches("BIGINT '12'");
        assertThat(assertions.expression("EXTRACT(HOUR FROM TIME '12:34:56.12+08:35')")).matches("BIGINT '12'");
        assertThat(assertions.expression("EXTRACT(HOUR FROM TIME '12:34:56.123+08:35')")).matches("BIGINT '12'");
        assertThat(assertions.expression("EXTRACT(HOUR FROM TIME '12:34:56.1234+08:35')")).matches("BIGINT '12'");
        assertThat(assertions.expression("EXTRACT(HOUR FROM TIME '12:34:56.12345+08:35')")).matches("BIGINT '12'");
        assertThat(assertions.expression("EXTRACT(HOUR FROM TIME '12:34:56.123456+08:35')")).matches("BIGINT '12'");
        assertThat(assertions.expression("EXTRACT(HOUR FROM TIME '12:34:56.1234567+08:35')")).matches("BIGINT '12'");
        assertThat(assertions.expression("EXTRACT(HOUR FROM TIME '12:34:56.12345678+08:35')")).matches("BIGINT '12'");
        assertThat(assertions.expression("EXTRACT(HOUR FROM TIME '12:34:56.123456789+08:35')")).matches("BIGINT '12'");
        assertThat(assertions.expression("EXTRACT(HOUR FROM TIME '12:34:56.1234567890+08:35')")).matches("BIGINT '12'");
        assertThat(assertions.expression("EXTRACT(HOUR FROM TIME '12:34:56.12345678901+08:35')")).matches("BIGINT '12'");
        assertThat(assertions.expression("EXTRACT(HOUR FROM TIME '12:34:56.123456789012+08:35')")).matches("BIGINT '12'");

        assertThat(assertions.expression("hour(TIME '12:34:56+08:35')")).matches("BIGINT '12'");
        assertThat(assertions.expression("hour(TIME '12:34:56.1+08:35')")).matches("BIGINT '12'");
        assertThat(assertions.expression("hour(TIME '12:34:56.12+08:35')")).matches("BIGINT '12'");
        assertThat(assertions.expression("hour(TIME '12:34:56.123+08:35')")).matches("BIGINT '12'");
        assertThat(assertions.expression("hour(TIME '12:34:56.1234+08:35')")).matches("BIGINT '12'");
        assertThat(assertions.expression("hour(TIME '12:34:56.12345+08:35')")).matches("BIGINT '12'");
        assertThat(assertions.expression("hour(TIME '12:34:56.123456+08:35')")).matches("BIGINT '12'");
        assertThat(assertions.expression("hour(TIME '12:34:56.1234567+08:35')")).matches("BIGINT '12'");
        assertThat(assertions.expression("hour(TIME '12:34:56.12345678+08:35')")).matches("BIGINT '12'");
        assertThat(assertions.expression("hour(TIME '12:34:56.123456789+08:35')")).matches("BIGINT '12'");
        assertThat(assertions.expression("hour(TIME '12:34:56.1234567890+08:35')")).matches("BIGINT '12'");
        assertThat(assertions.expression("hour(TIME '12:34:56.12345678901+08:35')")).matches("BIGINT '12'");
        assertThat(assertions.expression("hour(TIME '12:34:56.123456789012+08:35')")).matches("BIGINT '12'");
    }

    @Test
    public void testMinute()
    {
        assertThat(assertions.expression("EXTRACT(MINUTE FROM TIME '12:34:56+08:35')")).matches("BIGINT '34'");
        assertThat(assertions.expression("EXTRACT(MINUTE FROM TIME '12:34:56.1+08:35')")).matches("BIGINT '34'");
        assertThat(assertions.expression("EXTRACT(MINUTE FROM TIME '12:34:56.12+08:35')")).matches("BIGINT '34'");
        assertThat(assertions.expression("EXTRACT(MINUTE FROM TIME '12:34:56.123+08:35')")).matches("BIGINT '34'");
        assertThat(assertions.expression("EXTRACT(MINUTE FROM TIME '12:34:56.1234+08:35')")).matches("BIGINT '34'");
        assertThat(assertions.expression("EXTRACT(MINUTE FROM TIME '12:34:56.12345+08:35')")).matches("BIGINT '34'");
        assertThat(assertions.expression("EXTRACT(MINUTE FROM TIME '12:34:56.123456+08:35')")).matches("BIGINT '34'");
        assertThat(assertions.expression("EXTRACT(MINUTE FROM TIME '12:34:56.1234567+08:35')")).matches("BIGINT '34'");
        assertThat(assertions.expression("EXTRACT(MINUTE FROM TIME '12:34:56.12345678+08:35')")).matches("BIGINT '34'");
        assertThat(assertions.expression("EXTRACT(MINUTE FROM TIME '12:34:56.123456789+08:35')")).matches("BIGINT '34'");
        assertThat(assertions.expression("EXTRACT(MINUTE FROM TIME '12:34:56.1234567890+08:35')")).matches("BIGINT '34'");
        assertThat(assertions.expression("EXTRACT(MINUTE FROM TIME '12:34:56.12345678901+08:35')")).matches("BIGINT '34'");
        assertThat(assertions.expression("EXTRACT(MINUTE FROM TIME '12:34:56.123456789012+08:35')")).matches("BIGINT '34'");

        assertThat(assertions.expression("minute(TIME '12:34:56+08:35')")).matches("BIGINT '34'");
        assertThat(assertions.expression("minute(TIME '12:34:56.1+08:35')")).matches("BIGINT '34'");
        assertThat(assertions.expression("minute(TIME '12:34:56.12+08:35')")).matches("BIGINT '34'");
        assertThat(assertions.expression("minute(TIME '12:34:56.123+08:35')")).matches("BIGINT '34'");
        assertThat(assertions.expression("minute(TIME '12:34:56.1234+08:35')")).matches("BIGINT '34'");
        assertThat(assertions.expression("minute(TIME '12:34:56.12345+08:35')")).matches("BIGINT '34'");
        assertThat(assertions.expression("minute(TIME '12:34:56.123456+08:35')")).matches("BIGINT '34'");
        assertThat(assertions.expression("minute(TIME '12:34:56.1234567+08:35')")).matches("BIGINT '34'");
        assertThat(assertions.expression("minute(TIME '12:34:56.12345678+08:35')")).matches("BIGINT '34'");
        assertThat(assertions.expression("minute(TIME '12:34:56.123456789+08:35')")).matches("BIGINT '34'");
        assertThat(assertions.expression("minute(TIME '12:34:56.1234567890+08:35')")).matches("BIGINT '34'");
        assertThat(assertions.expression("minute(TIME '12:34:56.12345678901+08:35')")).matches("BIGINT '34'");
        assertThat(assertions.expression("minute(TIME '12:34:56.123456789012+08:35')")).matches("BIGINT '34'");
    }

    @Test
    public void testSecond()
    {
        assertThat(assertions.expression("EXTRACT(SECOND FROM TIME '12:34:56+08:35')")).matches("BIGINT '56'");
        assertThat(assertions.expression("EXTRACT(SECOND FROM TIME '12:34:56.1+08:35')")).matches("BIGINT '56'");
        assertThat(assertions.expression("EXTRACT(SECOND FROM TIME '12:34:56.12+08:35')")).matches("BIGINT '56'");
        assertThat(assertions.expression("EXTRACT(SECOND FROM TIME '12:34:56.123+08:35')")).matches("BIGINT '56'");
        assertThat(assertions.expression("EXTRACT(SECOND FROM TIME '12:34:56.1234+08:35')")).matches("BIGINT '56'");
        assertThat(assertions.expression("EXTRACT(SECOND FROM TIME '12:34:56.12345+08:35')")).matches("BIGINT '56'");
        assertThat(assertions.expression("EXTRACT(SECOND FROM TIME '12:34:56.123456+08:35')")).matches("BIGINT '56'");
        assertThat(assertions.expression("EXTRACT(SECOND FROM TIME '12:34:56.1234567+08:35')")).matches("BIGINT '56'");
        assertThat(assertions.expression("EXTRACT(SECOND FROM TIME '12:34:56.12345678+08:35')")).matches("BIGINT '56'");
        assertThat(assertions.expression("EXTRACT(SECOND FROM TIME '12:34:56.123456789+08:35')")).matches("BIGINT '56'");
        assertThat(assertions.expression("EXTRACT(SECOND FROM TIME '12:34:56.1234567890+08:35')")).matches("BIGINT '56'");
        assertThat(assertions.expression("EXTRACT(SECOND FROM TIME '12:34:56.12345678901+08:35')")).matches("BIGINT '56'");
        assertThat(assertions.expression("EXTRACT(SECOND FROM TIME '12:34:56.123456789012+08:35')")).matches("BIGINT '56'");

        assertThat(assertions.expression("second(TIME '12:34:56+08:35')")).matches("BIGINT '56'");
        assertThat(assertions.expression("second(TIME '12:34:56.1+08:35')")).matches("BIGINT '56'");
        assertThat(assertions.expression("second(TIME '12:34:56.12+08:35')")).matches("BIGINT '56'");
        assertThat(assertions.expression("second(TIME '12:34:56.123+08:35')")).matches("BIGINT '56'");
        assertThat(assertions.expression("second(TIME '12:34:56.1234+08:35')")).matches("BIGINT '56'");
        assertThat(assertions.expression("second(TIME '12:34:56.12345+08:35')")).matches("BIGINT '56'");
        assertThat(assertions.expression("second(TIME '12:34:56.123456+08:35')")).matches("BIGINT '56'");
        assertThat(assertions.expression("second(TIME '12:34:56.1234567+08:35')")).matches("BIGINT '56'");
        assertThat(assertions.expression("second(TIME '12:34:56.12345678+08:35')")).matches("BIGINT '56'");
        assertThat(assertions.expression("second(TIME '12:34:56.123456789+08:35')")).matches("BIGINT '56'");
        assertThat(assertions.expression("second(TIME '12:34:56.1234567890+08:35')")).matches("BIGINT '56'");
        assertThat(assertions.expression("second(TIME '12:34:56.12345678901+08:35')")).matches("BIGINT '56'");
        assertThat(assertions.expression("second(TIME '12:34:56.123456789012+08:35')")).matches("BIGINT '56'");
    }

    @Test
    public void testMillisecond()
    {
        assertThatThrownBy(() -> assertions.expression("EXTRACT(MILLISECOND FROM TIME '12:34:56+08:35')"))
                .isInstanceOf(ParsingException.class)
                .hasMessage("line 1:8: Invalid EXTRACT field: MILLISECOND");

        assertThat(assertions.expression("millisecond(TIME '12:34:56+08:35')")).matches("BIGINT '0'");
        assertThat(assertions.expression("millisecond(TIME '12:34:56.1+08:35')")).matches("BIGINT '100'");
        assertThat(assertions.expression("millisecond(TIME '12:34:56.12+08:35')")).matches("BIGINT '120'");
        assertThat(assertions.expression("millisecond(TIME '12:34:56.123+08:35')")).matches("BIGINT '123'");
        assertThat(assertions.expression("millisecond(TIME '12:34:56.1234+08:35')")).matches("BIGINT '123'");
        assertThat(assertions.expression("millisecond(TIME '12:34:56.12345+08:35')")).matches("BIGINT '123'");
        assertThat(assertions.expression("millisecond(TIME '12:34:56.123456+08:35')")).matches("BIGINT '123'");
        assertThat(assertions.expression("millisecond(TIME '12:34:56.1234567+08:35')")).matches("BIGINT '123'");
        assertThat(assertions.expression("millisecond(TIME '12:34:56.12345678+08:35')")).matches("BIGINT '123'");
        assertThat(assertions.expression("millisecond(TIME '12:34:56.123456789+08:35')")).matches("BIGINT '123'");
        assertThat(assertions.expression("millisecond(TIME '12:34:56.1234567890+08:35')")).matches("BIGINT '123'");
        assertThat(assertions.expression("millisecond(TIME '12:34:56.12345678901+08:35')")).matches("BIGINT '123'");
        assertThat(assertions.expression("millisecond(TIME '12:34:56.123456789012+08:35')")).matches("BIGINT '123'");
    }

    @Test
    public void testTimeZoneHour()
    {
        assertThat(assertions.expression("EXTRACT(TIMEZONE_HOUR FROM TIME '12:34:56+08:35')")).matches("BIGINT '8'");
        assertThat(assertions.expression("EXTRACT(TIMEZONE_HOUR FROM TIME '12:34:56.1+08:35')")).matches("BIGINT '8'");
        assertThat(assertions.expression("EXTRACT(TIMEZONE_HOUR FROM TIME '12:34:56.12+08:35')")).matches("BIGINT '8'");
        assertThat(assertions.expression("EXTRACT(TIMEZONE_HOUR FROM TIME '12:34:56.123+08:35')")).matches("BIGINT '8'");
        assertThat(assertions.expression("EXTRACT(TIMEZONE_HOUR FROM TIME '12:34:56.1234+08:35')")).matches("BIGINT '8'");
        assertThat(assertions.expression("EXTRACT(TIMEZONE_HOUR FROM TIME '12:34:56.12345+08:35')")).matches("BIGINT '8'");
        assertThat(assertions.expression("EXTRACT(TIMEZONE_HOUR FROM TIME '12:34:56.123456+08:35')")).matches("BIGINT '8'");
        assertThat(assertions.expression("EXTRACT(TIMEZONE_HOUR FROM TIME '12:34:56.1234567+08:35')")).matches("BIGINT '8'");
        assertThat(assertions.expression("EXTRACT(TIMEZONE_HOUR FROM TIME '12:34:56.12345678+08:35')")).matches("BIGINT '8'");
        assertThat(assertions.expression("EXTRACT(TIMEZONE_HOUR FROM TIME '12:34:56.123456789+08:35')")).matches("BIGINT '8'");
        assertThat(assertions.expression("EXTRACT(TIMEZONE_HOUR FROM TIME '12:34:56.1234567890+08:35')")).matches("BIGINT '8'");
        assertThat(assertions.expression("EXTRACT(TIMEZONE_HOUR FROM TIME '12:34:56.12345678901+08:35')")).matches("BIGINT '8'");
        assertThat(assertions.expression("EXTRACT(TIMEZONE_HOUR FROM TIME '12:34:56.123456789012+08:35')")).matches("BIGINT '8'");

        assertThat(assertions.expression("timezone_hour(TIME '12:34:56+08:35')")).matches("BIGINT '8'");
        assertThat(assertions.expression("timezone_hour(TIME '12:34:56.1+08:35')")).matches("BIGINT '8'");
        assertThat(assertions.expression("timezone_hour(TIME '12:34:56.12+08:35')")).matches("BIGINT '8'");
        assertThat(assertions.expression("timezone_hour(TIME '12:34:56.123+08:35')")).matches("BIGINT '8'");
        assertThat(assertions.expression("timezone_hour(TIME '12:34:56.1234+08:35')")).matches("BIGINT '8'");
        assertThat(assertions.expression("timezone_hour(TIME '12:34:56.12345+08:35')")).matches("BIGINT '8'");
        assertThat(assertions.expression("timezone_hour(TIME '12:34:56.123456+08:35')")).matches("BIGINT '8'");
        assertThat(assertions.expression("timezone_hour(TIME '12:34:56.1234567+08:35')")).matches("BIGINT '8'");
        assertThat(assertions.expression("timezone_hour(TIME '12:34:56.12345678+08:35')")).matches("BIGINT '8'");
        assertThat(assertions.expression("timezone_hour(TIME '12:34:56.123456789+08:35')")).matches("BIGINT '8'");
        assertThat(assertions.expression("timezone_hour(TIME '12:34:56.1234567890+08:35')")).matches("BIGINT '8'");
        assertThat(assertions.expression("timezone_hour(TIME '12:34:56.12345678901+08:35')")).matches("BIGINT '8'");
        assertThat(assertions.expression("timezone_hour(TIME '12:34:56.123456789012+08:35')")).matches("BIGINT '8'");
    }

    @Test
    public void testTimeZoneMinute()
    {
        assertThat(assertions.expression("EXTRACT(TIMEZONE_MINUTE FROM TIME '12:34:56+08:35')")).matches("BIGINT '35'");
        assertThat(assertions.expression("EXTRACT(TIMEZONE_MINUTE FROM TIME '12:34:56.1+08:35')")).matches("BIGINT '35'");
        assertThat(assertions.expression("EXTRACT(TIMEZONE_MINUTE FROM TIME '12:34:56.12+08:35')")).matches("BIGINT '35'");
        assertThat(assertions.expression("EXTRACT(TIMEZONE_MINUTE FROM TIME '12:34:56.123+08:35')")).matches("BIGINT '35'");
        assertThat(assertions.expression("EXTRACT(TIMEZONE_MINUTE FROM TIME '12:34:56.1234+08:35')")).matches("BIGINT '35'");
        assertThat(assertions.expression("EXTRACT(TIMEZONE_MINUTE FROM TIME '12:34:56.12345+08:35')")).matches("BIGINT '35'");
        assertThat(assertions.expression("EXTRACT(TIMEZONE_MINUTE FROM TIME '12:34:56.123456+08:35')")).matches("BIGINT '35'");
        assertThat(assertions.expression("EXTRACT(TIMEZONE_MINUTE FROM TIME '12:34:56.1234567+08:35')")).matches("BIGINT '35'");
        assertThat(assertions.expression("EXTRACT(TIMEZONE_MINUTE FROM TIME '12:34:56.12345678+08:35')")).matches("BIGINT '35'");
        assertThat(assertions.expression("EXTRACT(TIMEZONE_MINUTE FROM TIME '12:34:56.123456789+08:35')")).matches("BIGINT '35'");
        assertThat(assertions.expression("EXTRACT(TIMEZONE_MINUTE FROM TIME '12:34:56.1234567890+08:35')")).matches("BIGINT '35'");
        assertThat(assertions.expression("EXTRACT(TIMEZONE_MINUTE FROM TIME '12:34:56.12345678901+08:35')")).matches("BIGINT '35'");
        assertThat(assertions.expression("EXTRACT(TIMEZONE_MINUTE FROM TIME '12:34:56.123456789012+08:35')")).matches("BIGINT '35'");

        assertThat(assertions.expression("timezone_minute(TIME '12:34:56+08:35')")).matches("BIGINT '35'");
        assertThat(assertions.expression("timezone_minute(TIME '12:34:56.1+08:35')")).matches("BIGINT '35'");
        assertThat(assertions.expression("timezone_minute(TIME '12:34:56.12+08:35')")).matches("BIGINT '35'");
        assertThat(assertions.expression("timezone_minute(TIME '12:34:56.123+08:35')")).matches("BIGINT '35'");
        assertThat(assertions.expression("timezone_minute(TIME '12:34:56.1234+08:35')")).matches("BIGINT '35'");
        assertThat(assertions.expression("timezone_minute(TIME '12:34:56.12345+08:35')")).matches("BIGINT '35'");
        assertThat(assertions.expression("timezone_minute(TIME '12:34:56.123456+08:35')")).matches("BIGINT '35'");
        assertThat(assertions.expression("timezone_minute(TIME '12:34:56.1234567+08:35')")).matches("BIGINT '35'");
        assertThat(assertions.expression("timezone_minute(TIME '12:34:56.12345678+08:35')")).matches("BIGINT '35'");
        assertThat(assertions.expression("timezone_minute(TIME '12:34:56.123456789+08:35')")).matches("BIGINT '35'");
        assertThat(assertions.expression("timezone_minute(TIME '12:34:56.1234567890+08:35')")).matches("BIGINT '35'");
        assertThat(assertions.expression("timezone_minute(TIME '12:34:56.12345678901+08:35')")).matches("BIGINT '35'");
        assertThat(assertions.expression("timezone_minute(TIME '12:34:56.123456789012+08:35')")).matches("BIGINT '35'");
    }

    @Test
    public void testYear()
    {
        assertThatThrownBy(() -> assertions.expression("EXTRACT(YEAR FROM TIME '12:34:56+08:35')"))
                .isInstanceOf(PrestoException.class)
                .hasMessage("line 1:26: Cannot extract YEAR from time(0) with time zone");

        assertThatThrownBy(() -> assertions.expression("EXTRACT(YEAR FROM TIME '12:34:56.1+08:35')"))
                .isInstanceOf(PrestoException.class)
                .hasMessage("line 1:26: Cannot extract YEAR from time(1) with time zone");

        assertThatThrownBy(() -> assertions.expression("EXTRACT(YEAR FROM TIME '12:34:56.12+08:35')"))
                .isInstanceOf(PrestoException.class)
                .hasMessage("line 1:26: Cannot extract YEAR from time(2) with time zone");

        assertThatThrownBy(() -> assertions.expression("EXTRACT(YEAR FROM TIME '12:34:56.123+08:35')"))
                .isInstanceOf(PrestoException.class)
                .hasMessage("line 1:26: Cannot extract YEAR from time(3) with time zone");

        assertThatThrownBy(() -> assertions.expression("EXTRACT(YEAR FROM TIME '12:34:56.1234+08:35')"))
                .isInstanceOf(PrestoException.class)
                .hasMessage("line 1:26: Cannot extract YEAR from time(4) with time zone");

        assertThatThrownBy(() -> assertions.expression("EXTRACT(YEAR FROM TIME '12:34:56.12345+08:35')"))
                .isInstanceOf(PrestoException.class)
                .hasMessage("line 1:26: Cannot extract YEAR from time(5) with time zone");

        assertThatThrownBy(() -> assertions.expression("EXTRACT(YEAR FROM TIME '12:34:56.123456+08:35')"))
                .isInstanceOf(PrestoException.class)
                .hasMessage("line 1:26: Cannot extract YEAR from time(6) with time zone");

        assertThatThrownBy(() -> assertions.expression("EXTRACT(YEAR FROM TIME '12:34:56.1234567+08:35')"))
                .isInstanceOf(PrestoException.class)
                .hasMessage("line 1:26: Cannot extract YEAR from time(7) with time zone");

        assertThatThrownBy(() -> assertions.expression("EXTRACT(YEAR FROM TIME '12:34:56.12345678+08:35')"))
                .isInstanceOf(PrestoException.class)
                .hasMessage("line 1:26: Cannot extract YEAR from time(8) with time zone");

        assertThatThrownBy(() -> assertions.expression("EXTRACT(YEAR FROM TIME '12:34:56.123456789+08:35')"))
                .isInstanceOf(PrestoException.class)
                .hasMessage("line 1:26: Cannot extract YEAR from time(9) with time zone");

        assertThatThrownBy(() -> assertions.expression("EXTRACT(YEAR FROM TIME '12:34:56.1234567891+08:35')"))
                .isInstanceOf(PrestoException.class)
                .hasMessage("line 1:26: Cannot extract YEAR from time(10) with time zone");

        assertThatThrownBy(() -> assertions.expression("EXTRACT(YEAR FROM TIME '12:34:56.12345678912+08:35')"))
                .isInstanceOf(PrestoException.class)
                .hasMessage("line 1:26: Cannot extract YEAR from time(11) with time zone");

        assertThatThrownBy(() -> assertions.expression("EXTRACT(YEAR FROM TIME '12:34:56.123456789123+08:35')"))
                .isInstanceOf(PrestoException.class)
                .hasMessage("line 1:26: Cannot extract YEAR from time(12) with time zone");
    }

    @Test
    public void testMonth()
    {
        assertThatThrownBy(() -> assertions.expression("EXTRACT(MONTH FROM TIME '12:34:56+08:35')"))
                .isInstanceOf(PrestoException.class)
                .hasMessage("line 1:27: Cannot extract MONTH from time(0) with time zone");

        assertThatThrownBy(() -> assertions.expression("EXTRACT(MONTH FROM TIME '12:34:56.1+08:35')"))
                .isInstanceOf(PrestoException.class)
                .hasMessage("line 1:27: Cannot extract MONTH from time(1) with time zone");

        assertThatThrownBy(() -> assertions.expression("EXTRACT(MONTH FROM TIME '12:34:56.12+08:35')"))
                .isInstanceOf(PrestoException.class)
                .hasMessage("line 1:27: Cannot extract MONTH from time(2) with time zone");

        assertThatThrownBy(() -> assertions.expression("EXTRACT(MONTH FROM TIME '12:34:56.123+08:35')"))
                .isInstanceOf(PrestoException.class)
                .hasMessage("line 1:27: Cannot extract MONTH from time(3) with time zone");

        assertThatThrownBy(() -> assertions.expression("EXTRACT(MONTH FROM TIME '12:34:56.1234+08:35')"))
                .isInstanceOf(PrestoException.class)
                .hasMessage("line 1:27: Cannot extract MONTH from time(4) with time zone");

        assertThatThrownBy(() -> assertions.expression("EXTRACT(MONTH FROM TIME '12:34:56.12345+08:35')"))
                .isInstanceOf(PrestoException.class)
                .hasMessage("line 1:27: Cannot extract MONTH from time(5) with time zone");

        assertThatThrownBy(() -> assertions.expression("EXTRACT(MONTH FROM TIME '12:34:56.123456+08:35')"))
                .isInstanceOf(PrestoException.class)
                .hasMessage("line 1:27: Cannot extract MONTH from time(6) with time zone");

        assertThatThrownBy(() -> assertions.expression("EXTRACT(MONTH FROM TIME '12:34:56.1234567+08:35')"))
                .isInstanceOf(PrestoException.class)
                .hasMessage("line 1:27: Cannot extract MONTH from time(7) with time zone");

        assertThatThrownBy(() -> assertions.expression("EXTRACT(MONTH FROM TIME '12:34:56.12345678+08:35')"))
                .isInstanceOf(PrestoException.class)
                .hasMessage("line 1:27: Cannot extract MONTH from time(8) with time zone");

        assertThatThrownBy(() -> assertions.expression("EXTRACT(MONTH FROM TIME '12:34:56.123456789+08:35')"))
                .isInstanceOf(PrestoException.class)
                .hasMessage("line 1:27: Cannot extract MONTH from time(9) with time zone");

        assertThatThrownBy(() -> assertions.expression("EXTRACT(MONTH FROM TIME '12:34:56.1234567891+08:35')"))
                .isInstanceOf(PrestoException.class)
                .hasMessage("line 1:27: Cannot extract MONTH from time(10) with time zone");

        assertThatThrownBy(() -> assertions.expression("EXTRACT(MONTH FROM TIME '12:34:56.12345678912+08:35')"))
                .isInstanceOf(PrestoException.class)
                .hasMessage("line 1:27: Cannot extract MONTH from time(11) with time zone");

        assertThatThrownBy(() -> assertions.expression("EXTRACT(MONTH FROM TIME '12:34:56.123456789123+08:35')"))
                .isInstanceOf(PrestoException.class)
                .hasMessage("line 1:27: Cannot extract MONTH from time(12) with time zone");
    }

    @Test
    public void testDay()
    {
        assertThatThrownBy(() -> assertions.expression("EXTRACT(DAY FROM TIME '12:34:56+08:35')"))
                .isInstanceOf(PrestoException.class)
                .hasMessage("line 1:25: Cannot extract DAY from time(0) with time zone");

        assertThatThrownBy(() -> assertions.expression("EXTRACT(DAY FROM TIME '12:34:56.1+08:35')"))
                .isInstanceOf(PrestoException.class)
                .hasMessage("line 1:25: Cannot extract DAY from time(1) with time zone");

        assertThatThrownBy(() -> assertions.expression("EXTRACT(DAY FROM TIME '12:34:56.12+08:35')"))
                .isInstanceOf(PrestoException.class)
                .hasMessage("line 1:25: Cannot extract DAY from time(2) with time zone");

        assertThatThrownBy(() -> assertions.expression("EXTRACT(DAY FROM TIME '12:34:56.123+08:35')"))
                .isInstanceOf(PrestoException.class)
                .hasMessage("line 1:25: Cannot extract DAY from time(3) with time zone");

        assertThatThrownBy(() -> assertions.expression("EXTRACT(DAY FROM TIME '12:34:56.1234+08:35')"))
                .isInstanceOf(PrestoException.class)
                .hasMessage("line 1:25: Cannot extract DAY from time(4) with time zone");

        assertThatThrownBy(() -> assertions.expression("EXTRACT(DAY FROM TIME '12:34:56.12345+08:35')"))
                .isInstanceOf(PrestoException.class)
                .hasMessage("line 1:25: Cannot extract DAY from time(5) with time zone");

        assertThatThrownBy(() -> assertions.expression("EXTRACT(DAY FROM TIME '12:34:56.123456+08:35')"))
                .isInstanceOf(PrestoException.class)
                .hasMessage("line 1:25: Cannot extract DAY from time(6) with time zone");

        assertThatThrownBy(() -> assertions.expression("EXTRACT(DAY FROM TIME '12:34:56.1234567+08:35')"))
                .isInstanceOf(PrestoException.class)
                .hasMessage("line 1:25: Cannot extract DAY from time(7) with time zone");

        assertThatThrownBy(() -> assertions.expression("EXTRACT(DAY FROM TIME '12:34:56.12345678+08:35')"))
                .isInstanceOf(PrestoException.class)
                .hasMessage("line 1:25: Cannot extract DAY from time(8) with time zone");

        assertThatThrownBy(() -> assertions.expression("EXTRACT(DAY FROM TIME '12:34:56.123456789+08:35')"))
                .isInstanceOf(PrestoException.class)
                .hasMessage("line 1:25: Cannot extract DAY from time(9) with time zone");

        assertThatThrownBy(() -> assertions.expression("EXTRACT(DAY FROM TIME '12:34:56.1234567891+08:35')"))
                .isInstanceOf(PrestoException.class)
                .hasMessage("line 1:25: Cannot extract DAY from time(10) with time zone");

        assertThatThrownBy(() -> assertions.expression("EXTRACT(DAY FROM TIME '12:34:56.12345678912+08:35')"))
                .isInstanceOf(PrestoException.class)
                .hasMessage("line 1:25: Cannot extract DAY from time(11) with time zone");

        assertThatThrownBy(() -> assertions.expression("EXTRACT(DAY FROM TIME '12:34:56.123456789123+08:35')"))
                .isInstanceOf(PrestoException.class)
                .hasMessage("line 1:25: Cannot extract DAY from time(12) with time zone");
    }
}
