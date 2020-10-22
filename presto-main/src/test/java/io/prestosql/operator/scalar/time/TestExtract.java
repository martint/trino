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
package io.prestosql.operator.scalar.time;

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
        assertThat(assertions.expression("EXTRACT(HOUR FROM TIME '12:34:56')")).matches("BIGINT '12'");
        assertThat(assertions.expression("EXTRACT(HOUR FROM TIME '12:34:56.1')")).matches("BIGINT '12'");
        assertThat(assertions.expression("EXTRACT(HOUR FROM TIME '12:34:56.12')")).matches("BIGINT '12'");
        assertThat(assertions.expression("EXTRACT(HOUR FROM TIME '12:34:56.123')")).matches("BIGINT '12'");
        assertThat(assertions.expression("EXTRACT(HOUR FROM TIME '12:34:56.1234')")).matches("BIGINT '12'");
        assertThat(assertions.expression("EXTRACT(HOUR FROM TIME '12:34:56.12345')")).matches("BIGINT '12'");
        assertThat(assertions.expression("EXTRACT(HOUR FROM TIME '12:34:56.123456')")).matches("BIGINT '12'");
        assertThat(assertions.expression("EXTRACT(HOUR FROM TIME '12:34:56.1234567')")).matches("BIGINT '12'");
        assertThat(assertions.expression("EXTRACT(HOUR FROM TIME '12:34:56.12345678')")).matches("BIGINT '12'");
        assertThat(assertions.expression("EXTRACT(HOUR FROM TIME '12:34:56.123456789')")).matches("BIGINT '12'");
        assertThat(assertions.expression("EXTRACT(HOUR FROM TIME '12:34:56.1234567890')")).matches("BIGINT '12'");
        assertThat(assertions.expression("EXTRACT(HOUR FROM TIME '12:34:56.12345678901')")).matches("BIGINT '12'");
        assertThat(assertions.expression("EXTRACT(HOUR FROM TIME '12:34:56.123456789012')")).matches("BIGINT '12'");

        assertThat(assertions.expression("hour(TIME '12:34:56')")).matches("BIGINT '12'");
        assertThat(assertions.expression("hour(TIME '12:34:56.1')")).matches("BIGINT '12'");
        assertThat(assertions.expression("hour(TIME '12:34:56.12')")).matches("BIGINT '12'");
        assertThat(assertions.expression("hour(TIME '12:34:56.123')")).matches("BIGINT '12'");
        assertThat(assertions.expression("hour(TIME '12:34:56.1234')")).matches("BIGINT '12'");
        assertThat(assertions.expression("hour(TIME '12:34:56.12345')")).matches("BIGINT '12'");
        assertThat(assertions.expression("hour(TIME '12:34:56.123456')")).matches("BIGINT '12'");
        assertThat(assertions.expression("hour(TIME '12:34:56.1234567')")).matches("BIGINT '12'");
        assertThat(assertions.expression("hour(TIME '12:34:56.12345678')")).matches("BIGINT '12'");
        assertThat(assertions.expression("hour(TIME '12:34:56.123456789')")).matches("BIGINT '12'");
        assertThat(assertions.expression("hour(TIME '12:34:56.1234567890')")).matches("BIGINT '12'");
        assertThat(assertions.expression("hour(TIME '12:34:56.12345678901')")).matches("BIGINT '12'");
        assertThat(assertions.expression("hour(TIME '12:34:56.123456789012')")).matches("BIGINT '12'");
    }

    @Test
    public void testMinute()
    {
        assertThat(assertions.expression("EXTRACT(MINUTE FROM TIME '12:34:56')")).matches("BIGINT '34'");
        assertThat(assertions.expression("EXTRACT(MINUTE FROM TIME '12:34:56.1')")).matches("BIGINT '34'");
        assertThat(assertions.expression("EXTRACT(MINUTE FROM TIME '12:34:56.12')")).matches("BIGINT '34'");
        assertThat(assertions.expression("EXTRACT(MINUTE FROM TIME '12:34:56.123')")).matches("BIGINT '34'");
        assertThat(assertions.expression("EXTRACT(MINUTE FROM TIME '12:34:56.1234')")).matches("BIGINT '34'");
        assertThat(assertions.expression("EXTRACT(MINUTE FROM TIME '12:34:56.12345')")).matches("BIGINT '34'");
        assertThat(assertions.expression("EXTRACT(MINUTE FROM TIME '12:34:56.123456')")).matches("BIGINT '34'");
        assertThat(assertions.expression("EXTRACT(MINUTE FROM TIME '12:34:56.1234567')")).matches("BIGINT '34'");
        assertThat(assertions.expression("EXTRACT(MINUTE FROM TIME '12:34:56.12345678')")).matches("BIGINT '34'");
        assertThat(assertions.expression("EXTRACT(MINUTE FROM TIME '12:34:56.123456789')")).matches("BIGINT '34'");
        assertThat(assertions.expression("EXTRACT(MINUTE FROM TIME '12:34:56.1234567890')")).matches("BIGINT '34'");
        assertThat(assertions.expression("EXTRACT(MINUTE FROM TIME '12:34:56.12345678901')")).matches("BIGINT '34'");
        assertThat(assertions.expression("EXTRACT(MINUTE FROM TIME '12:34:56.123456789012')")).matches("BIGINT '34'");

        assertThat(assertions.expression("minute(TIME '12:34:56')")).matches("BIGINT '34'");
        assertThat(assertions.expression("minute(TIME '12:34:56.1')")).matches("BIGINT '34'");
        assertThat(assertions.expression("minute(TIME '12:34:56.12')")).matches("BIGINT '34'");
        assertThat(assertions.expression("minute(TIME '12:34:56.123')")).matches("BIGINT '34'");
        assertThat(assertions.expression("minute(TIME '12:34:56.1234')")).matches("BIGINT '34'");
        assertThat(assertions.expression("minute(TIME '12:34:56.12345')")).matches("BIGINT '34'");
        assertThat(assertions.expression("minute(TIME '12:34:56.123456')")).matches("BIGINT '34'");
        assertThat(assertions.expression("minute(TIME '12:34:56.1234567')")).matches("BIGINT '34'");
        assertThat(assertions.expression("minute(TIME '12:34:56.12345678')")).matches("BIGINT '34'");
        assertThat(assertions.expression("minute(TIME '12:34:56.123456789')")).matches("BIGINT '34'");
        assertThat(assertions.expression("minute(TIME '12:34:56.1234567890')")).matches("BIGINT '34'");
        assertThat(assertions.expression("minute(TIME '12:34:56.12345678901')")).matches("BIGINT '34'");
        assertThat(assertions.expression("minute(TIME '12:34:56.123456789012')")).matches("BIGINT '34'");
    }

    @Test
    public void testSecond()
    {
        assertThat(assertions.expression("EXTRACT(SECOND FROM TIME '12:34:56')")).matches("BIGINT '56'");
        assertThat(assertions.expression("EXTRACT(SECOND FROM TIME '12:34:56.1')")).matches("BIGINT '56'");
        assertThat(assertions.expression("EXTRACT(SECOND FROM TIME '12:34:56.12')")).matches("BIGINT '56'");
        assertThat(assertions.expression("EXTRACT(SECOND FROM TIME '12:34:56.123')")).matches("BIGINT '56'");
        assertThat(assertions.expression("EXTRACT(SECOND FROM TIME '12:34:56.1234')")).matches("BIGINT '56'");
        assertThat(assertions.expression("EXTRACT(SECOND FROM TIME '12:34:56.12345')")).matches("BIGINT '56'");
        assertThat(assertions.expression("EXTRACT(SECOND FROM TIME '12:34:56.123456')")).matches("BIGINT '56'");
        assertThat(assertions.expression("EXTRACT(SECOND FROM TIME '12:34:56.1234567')")).matches("BIGINT '56'");
        assertThat(assertions.expression("EXTRACT(SECOND FROM TIME '12:34:56.12345678')")).matches("BIGINT '56'");
        assertThat(assertions.expression("EXTRACT(SECOND FROM TIME '12:34:56.123456789')")).matches("BIGINT '56'");
        assertThat(assertions.expression("EXTRACT(SECOND FROM TIME '12:34:56.1234567890')")).matches("BIGINT '56'");
        assertThat(assertions.expression("EXTRACT(SECOND FROM TIME '12:34:56.12345678901')")).matches("BIGINT '56'");
        assertThat(assertions.expression("EXTRACT(SECOND FROM TIME '12:34:56.123456789012')")).matches("BIGINT '56'");

        assertThat(assertions.expression("second(TIME '12:34:56')")).matches("BIGINT '56'");
        assertThat(assertions.expression("second(TIME '12:34:56.1')")).matches("BIGINT '56'");
        assertThat(assertions.expression("second(TIME '12:34:56.12')")).matches("BIGINT '56'");
        assertThat(assertions.expression("second(TIME '12:34:56.123')")).matches("BIGINT '56'");
        assertThat(assertions.expression("second(TIME '12:34:56.1234')")).matches("BIGINT '56'");
        assertThat(assertions.expression("second(TIME '12:34:56.12345')")).matches("BIGINT '56'");
        assertThat(assertions.expression("second(TIME '12:34:56.123456')")).matches("BIGINT '56'");
        assertThat(assertions.expression("second(TIME '12:34:56.1234567')")).matches("BIGINT '56'");
        assertThat(assertions.expression("second(TIME '12:34:56.12345678')")).matches("BIGINT '56'");
        assertThat(assertions.expression("second(TIME '12:34:56.123456789')")).matches("BIGINT '56'");
        assertThat(assertions.expression("second(TIME '12:34:56.1234567890')")).matches("BIGINT '56'");
        assertThat(assertions.expression("second(TIME '12:34:56.12345678901')")).matches("BIGINT '56'");
        assertThat(assertions.expression("second(TIME '12:34:56.123456789012')")).matches("BIGINT '56'");
    }

    @Test
    public void testMillisecond()
    {
        assertThatThrownBy(() -> assertions.expression("EXTRACT(MILLISECOND FROM TIME '12:34:56')"))
                .isInstanceOf(ParsingException.class)
                .hasMessage("line 1:8: Invalid EXTRACT field: MILLISECOND");

        assertThat(assertions.expression("millisecond(TIME '12:34:56')")).matches("BIGINT '0'");
        assertThat(assertions.expression("millisecond(TIME '12:34:56.1')")).matches("BIGINT '100'");
        assertThat(assertions.expression("millisecond(TIME '12:34:56.12')")).matches("BIGINT '120'");
        assertThat(assertions.expression("millisecond(TIME '12:34:56.123')")).matches("BIGINT '123'");
        assertThat(assertions.expression("millisecond(TIME '12:34:56.1234')")).matches("BIGINT '123'");
        assertThat(assertions.expression("millisecond(TIME '12:34:56.12345')")).matches("BIGINT '123'");
        assertThat(assertions.expression("millisecond(TIME '12:34:56.123456')")).matches("BIGINT '123'");
        assertThat(assertions.expression("millisecond(TIME '12:34:56.1234567')")).matches("BIGINT '123'");
        assertThat(assertions.expression("millisecond(TIME '12:34:56.12345678')")).matches("BIGINT '123'");
        assertThat(assertions.expression("millisecond(TIME '12:34:56.123456789')")).matches("BIGINT '123'");
        assertThat(assertions.expression("millisecond(TIME '12:34:56.1234567890')")).matches("BIGINT '123'");
        assertThat(assertions.expression("millisecond(TIME '12:34:56.12345678901')")).matches("BIGINT '123'");
        assertThat(assertions.expression("millisecond(TIME '12:34:56.123456789012')")).matches("BIGINT '123'");
    }

    @Test
    public void testYear()
    {
        assertThatThrownBy(() -> assertions.expression("EXTRACT(YEAR FROM TIME '12:34:56')"))
                .isInstanceOf(PrestoException.class)
                .hasMessage("line 1:26: Cannot extract YEAR from time(0)");

        assertThatThrownBy(() -> assertions.expression("EXTRACT(YEAR FROM TIME '12:34:56.1')"))
                .isInstanceOf(PrestoException.class)
                .hasMessage("line 1:26: Cannot extract YEAR from time(1)");

        assertThatThrownBy(() -> assertions.expression("EXTRACT(YEAR FROM TIME '12:34:56.12')"))
                .isInstanceOf(PrestoException.class)
                .hasMessage("line 1:26: Cannot extract YEAR from time(2)");

        assertThatThrownBy(() -> assertions.expression("EXTRACT(YEAR FROM TIME '12:34:56.123')"))
                .isInstanceOf(PrestoException.class)
                .hasMessage("line 1:26: Cannot extract YEAR from time(3)");

        assertThatThrownBy(() -> assertions.expression("EXTRACT(YEAR FROM TIME '12:34:56.1234')"))
                .isInstanceOf(PrestoException.class)
                .hasMessage("line 1:26: Cannot extract YEAR from time(4)");

        assertThatThrownBy(() -> assertions.expression("EXTRACT(YEAR FROM TIME '12:34:56.12345')"))
                .isInstanceOf(PrestoException.class)
                .hasMessage("line 1:26: Cannot extract YEAR from time(5)");

        assertThatThrownBy(() -> assertions.expression("EXTRACT(YEAR FROM TIME '12:34:56.123456')"))
                .isInstanceOf(PrestoException.class)
                .hasMessage("line 1:26: Cannot extract YEAR from time(6)");

        assertThatThrownBy(() -> assertions.expression("EXTRACT(YEAR FROM TIME '12:34:56.1234567')"))
                .isInstanceOf(PrestoException.class)
                .hasMessage("line 1:26: Cannot extract YEAR from time(7)");

        assertThatThrownBy(() -> assertions.expression("EXTRACT(YEAR FROM TIME '12:34:56.12345678')"))
                .isInstanceOf(PrestoException.class)
                .hasMessage("line 1:26: Cannot extract YEAR from time(8)");

        assertThatThrownBy(() -> assertions.expression("EXTRACT(YEAR FROM TIME '12:34:56.123456789')"))
                .isInstanceOf(PrestoException.class)
                .hasMessage("line 1:26: Cannot extract YEAR from time(9)");

        assertThatThrownBy(() -> assertions.expression("EXTRACT(YEAR FROM TIME '12:34:56.1234567891')"))
                .isInstanceOf(PrestoException.class)
                .hasMessage("line 1:26: Cannot extract YEAR from time(10)");

        assertThatThrownBy(() -> assertions.expression("EXTRACT(YEAR FROM TIME '12:34:56.12345678912')"))
                .isInstanceOf(PrestoException.class)
                .hasMessage("line 1:26: Cannot extract YEAR from time(11)");

        assertThatThrownBy(() -> assertions.expression("EXTRACT(YEAR FROM TIME '12:34:56.123456789123')"))
                .isInstanceOf(PrestoException.class)
                .hasMessage("line 1:26: Cannot extract YEAR from time(12)");
    }

    @Test
    public void testMonth()
    {
        assertThatThrownBy(() -> assertions.expression("EXTRACT(MONTH FROM TIME '12:34:56')"))
                .isInstanceOf(PrestoException.class)
                .hasMessage("line 1:27: Cannot extract MONTH from time(0)");

        assertThatThrownBy(() -> assertions.expression("EXTRACT(MONTH FROM TIME '12:34:56.1')"))
                .isInstanceOf(PrestoException.class)
                .hasMessage("line 1:27: Cannot extract MONTH from time(1)");

        assertThatThrownBy(() -> assertions.expression("EXTRACT(MONTH FROM TIME '12:34:56.12')"))
                .isInstanceOf(PrestoException.class)
                .hasMessage("line 1:27: Cannot extract MONTH from time(2)");

        assertThatThrownBy(() -> assertions.expression("EXTRACT(MONTH FROM TIME '12:34:56.123')"))
                .isInstanceOf(PrestoException.class)
                .hasMessage("line 1:27: Cannot extract MONTH from time(3)");

        assertThatThrownBy(() -> assertions.expression("EXTRACT(MONTH FROM TIME '12:34:56.1234')"))
                .isInstanceOf(PrestoException.class)
                .hasMessage("line 1:27: Cannot extract MONTH from time(4)");

        assertThatThrownBy(() -> assertions.expression("EXTRACT(MONTH FROM TIME '12:34:56.12345')"))
                .isInstanceOf(PrestoException.class)
                .hasMessage("line 1:27: Cannot extract MONTH from time(5)");

        assertThatThrownBy(() -> assertions.expression("EXTRACT(MONTH FROM TIME '12:34:56.123456')"))
                .isInstanceOf(PrestoException.class)
                .hasMessage("line 1:27: Cannot extract MONTH from time(6)");

        assertThatThrownBy(() -> assertions.expression("EXTRACT(MONTH FROM TIME '12:34:56.1234567')"))
                .isInstanceOf(PrestoException.class)
                .hasMessage("line 1:27: Cannot extract MONTH from time(7)");

        assertThatThrownBy(() -> assertions.expression("EXTRACT(MONTH FROM TIME '12:34:56.12345678')"))
                .isInstanceOf(PrestoException.class)
                .hasMessage("line 1:27: Cannot extract MONTH from time(8)");

        assertThatThrownBy(() -> assertions.expression("EXTRACT(MONTH FROM TIME '12:34:56.123456789')"))
                .isInstanceOf(PrestoException.class)
                .hasMessage("line 1:27: Cannot extract MONTH from time(9)");

        assertThatThrownBy(() -> assertions.expression("EXTRACT(MONTH FROM TIME '12:34:56.1234567891')"))
                .isInstanceOf(PrestoException.class)
                .hasMessage("line 1:27: Cannot extract MONTH from time(10)");

        assertThatThrownBy(() -> assertions.expression("EXTRACT(MONTH FROM TIME '12:34:56.12345678912')"))
                .isInstanceOf(PrestoException.class)
                .hasMessage("line 1:27: Cannot extract MONTH from time(11)");

        assertThatThrownBy(() -> assertions.expression("EXTRACT(MONTH FROM TIME '12:34:56.123456789123')"))
                .isInstanceOf(PrestoException.class)
                .hasMessage("line 1:27: Cannot extract MONTH from time(12)");
    }

    @Test
    public void testDay()
    {
        assertThatThrownBy(() -> assertions.expression("EXTRACT(DAY FROM TIME '12:34:56')"))
                .isInstanceOf(PrestoException.class)
                .hasMessage("line 1:25: Cannot extract DAY from time(0)");

        assertThatThrownBy(() -> assertions.expression("EXTRACT(DAY FROM TIME '12:34:56.1')"))
                .isInstanceOf(PrestoException.class)
                .hasMessage("line 1:25: Cannot extract DAY from time(1)");

        assertThatThrownBy(() -> assertions.expression("EXTRACT(DAY FROM TIME '12:34:56.12')"))
                .isInstanceOf(PrestoException.class)
                .hasMessage("line 1:25: Cannot extract DAY from time(2)");

        assertThatThrownBy(() -> assertions.expression("EXTRACT(DAY FROM TIME '12:34:56.123')"))
                .isInstanceOf(PrestoException.class)
                .hasMessage("line 1:25: Cannot extract DAY from time(3)");

        assertThatThrownBy(() -> assertions.expression("EXTRACT(DAY FROM TIME '12:34:56.1234')"))
                .isInstanceOf(PrestoException.class)
                .hasMessage("line 1:25: Cannot extract DAY from time(4)");

        assertThatThrownBy(() -> assertions.expression("EXTRACT(DAY FROM TIME '12:34:56.12345')"))
                .isInstanceOf(PrestoException.class)
                .hasMessage("line 1:25: Cannot extract DAY from time(5)");

        assertThatThrownBy(() -> assertions.expression("EXTRACT(DAY FROM TIME '12:34:56.123456')"))
                .isInstanceOf(PrestoException.class)
                .hasMessage("line 1:25: Cannot extract DAY from time(6)");

        assertThatThrownBy(() -> assertions.expression("EXTRACT(DAY FROM TIME '12:34:56.1234567')"))
                .isInstanceOf(PrestoException.class)
                .hasMessage("line 1:25: Cannot extract DAY from time(7)");

        assertThatThrownBy(() -> assertions.expression("EXTRACT(DAY FROM TIME '12:34:56.12345678')"))
                .isInstanceOf(PrestoException.class)
                .hasMessage("line 1:25: Cannot extract DAY from time(8)");

        assertThatThrownBy(() -> assertions.expression("EXTRACT(DAY FROM TIME '12:34:56.123456789')"))
                .isInstanceOf(PrestoException.class)
                .hasMessage("line 1:25: Cannot extract DAY from time(9)");

        assertThatThrownBy(() -> assertions.expression("EXTRACT(DAY FROM TIME '12:34:56.1234567891')"))
                .isInstanceOf(PrestoException.class)
                .hasMessage("line 1:25: Cannot extract DAY from time(10)");

        assertThatThrownBy(() -> assertions.expression("EXTRACT(DAY FROM TIME '12:34:56.12345678912')"))
                .isInstanceOf(PrestoException.class)
                .hasMessage("line 1:25: Cannot extract DAY from time(11)");

        assertThatThrownBy(() -> assertions.expression("EXTRACT(DAY FROM TIME '12:34:56.123456789123')"))
                .isInstanceOf(PrestoException.class)
                .hasMessage("line 1:25: Cannot extract DAY from time(12)");
    }

    @Test
    public void testTimezoneHour()
    {
        assertThatThrownBy(() -> assertions.expression("EXTRACT(TIMEZONE_HOUR FROM TIME '12:34:56')"))
                .isInstanceOf(PrestoException.class)
                .hasMessage("line 1:35: Cannot extract TIMEZONE_HOUR from time(0)");

        assertThatThrownBy(() -> assertions.expression("EXTRACT(TIMEZONE_HOUR FROM TIME '12:34:56.1')"))
                .isInstanceOf(PrestoException.class)
                .hasMessage("line 1:35: Cannot extract TIMEZONE_HOUR from time(1)");

        assertThatThrownBy(() -> assertions.expression("EXTRACT(TIMEZONE_HOUR FROM TIME '12:34:56.12')"))
                .isInstanceOf(PrestoException.class)
                .hasMessage("line 1:35: Cannot extract TIMEZONE_HOUR from time(2)");

        assertThatThrownBy(() -> assertions.expression("EXTRACT(TIMEZONE_HOUR FROM TIME '12:34:56.123')"))
                .isInstanceOf(PrestoException.class)
                .hasMessage("line 1:35: Cannot extract TIMEZONE_HOUR from time(3)");

        assertThatThrownBy(() -> assertions.expression("EXTRACT(TIMEZONE_HOUR FROM TIME '12:34:56.1234')"))
                .isInstanceOf(PrestoException.class)
                .hasMessage("line 1:35: Cannot extract TIMEZONE_HOUR from time(4)");

        assertThatThrownBy(() -> assertions.expression("EXTRACT(TIMEZONE_HOUR FROM TIME '12:34:56.12345')"))
                .isInstanceOf(PrestoException.class)
                .hasMessage("line 1:35: Cannot extract TIMEZONE_HOUR from time(5)");

        assertThatThrownBy(() -> assertions.expression("EXTRACT(TIMEZONE_HOUR FROM TIME '12:34:56.123456')"))
                .isInstanceOf(PrestoException.class)
                .hasMessage("line 1:35: Cannot extract TIMEZONE_HOUR from time(6)");

        assertThatThrownBy(() -> assertions.expression("EXTRACT(TIMEZONE_HOUR FROM TIME '12:34:56.1234567')"))
                .isInstanceOf(PrestoException.class)
                .hasMessage("line 1:35: Cannot extract TIMEZONE_HOUR from time(7)");

        assertThatThrownBy(() -> assertions.expression("EXTRACT(TIMEZONE_HOUR FROM TIME '12:34:56.12345678')"))
                .isInstanceOf(PrestoException.class)
                .hasMessage("line 1:35: Cannot extract TIMEZONE_HOUR from time(8)");

        assertThatThrownBy(() -> assertions.expression("EXTRACT(TIMEZONE_HOUR FROM TIME '12:34:56.123456789')"))
                .isInstanceOf(PrestoException.class)
                .hasMessage("line 1:35: Cannot extract TIMEZONE_HOUR from time(9)");

        assertThatThrownBy(() -> assertions.expression("EXTRACT(TIMEZONE_HOUR FROM TIME '12:34:56.1234567891')"))
                .isInstanceOf(PrestoException.class)
                .hasMessage("line 1:35: Cannot extract TIMEZONE_HOUR from time(10)");

        assertThatThrownBy(() -> assertions.expression("EXTRACT(TIMEZONE_HOUR FROM TIME '12:34:56.12345678912')"))
                .isInstanceOf(PrestoException.class)
                .hasMessage("line 1:35: Cannot extract TIMEZONE_HOUR from time(11)");

        assertThatThrownBy(() -> assertions.expression("EXTRACT(TIMEZONE_HOUR FROM TIME '12:34:56.123456789123')"))
                .isInstanceOf(PrestoException.class)
                .hasMessage("line 1:35: Cannot extract TIMEZONE_HOUR from time(12)");
    }

    @Test
    public void testTimezoneMinute()
    {
        assertThatThrownBy(() -> assertions.expression("EXTRACT(TIMEZONE_MINUTE FROM TIME '12:34:56')"))
                .isInstanceOf(PrestoException.class)
                .hasMessage("line 1:37: Cannot extract TIMEZONE_MINUTE from time(0)");

        assertThatThrownBy(() -> assertions.expression("EXTRACT(TIMEZONE_MINUTE FROM TIME '12:34:56.1')"))
                .isInstanceOf(PrestoException.class)
                .hasMessage("line 1:37: Cannot extract TIMEZONE_MINUTE from time(1)");

        assertThatThrownBy(() -> assertions.expression("EXTRACT(TIMEZONE_MINUTE FROM TIME '12:34:56.12')"))
                .isInstanceOf(PrestoException.class)
                .hasMessage("line 1:37: Cannot extract TIMEZONE_MINUTE from time(2)");

        assertThatThrownBy(() -> assertions.expression("EXTRACT(TIMEZONE_MINUTE FROM TIME '12:34:56.123')"))
                .isInstanceOf(PrestoException.class)
                .hasMessage("line 1:37: Cannot extract TIMEZONE_MINUTE from time(3)");

        assertThatThrownBy(() -> assertions.expression("EXTRACT(TIMEZONE_MINUTE FROM TIME '12:34:56.1234')"))
                .isInstanceOf(PrestoException.class)
                .hasMessage("line 1:37: Cannot extract TIMEZONE_MINUTE from time(4)");

        assertThatThrownBy(() -> assertions.expression("EXTRACT(TIMEZONE_MINUTE FROM TIME '12:34:56.12345')"))
                .isInstanceOf(PrestoException.class)
                .hasMessage("line 1:37: Cannot extract TIMEZONE_MINUTE from time(5)");

        assertThatThrownBy(() -> assertions.expression("EXTRACT(TIMEZONE_MINUTE FROM TIME '12:34:56.123456')"))
                .isInstanceOf(PrestoException.class)
                .hasMessage("line 1:37: Cannot extract TIMEZONE_MINUTE from time(6)");

        assertThatThrownBy(() -> assertions.expression("EXTRACT(TIMEZONE_MINUTE FROM TIME '12:34:56.1234567')"))
                .isInstanceOf(PrestoException.class)
                .hasMessage("line 1:37: Cannot extract TIMEZONE_MINUTE from time(7)");

        assertThatThrownBy(() -> assertions.expression("EXTRACT(TIMEZONE_MINUTE FROM TIME '12:34:56.12345678')"))
                .isInstanceOf(PrestoException.class)
                .hasMessage("line 1:37: Cannot extract TIMEZONE_MINUTE from time(8)");

        assertThatThrownBy(() -> assertions.expression("EXTRACT(TIMEZONE_MINUTE FROM TIME '12:34:56.123456789')"))
                .isInstanceOf(PrestoException.class)
                .hasMessage("line 1:37: Cannot extract TIMEZONE_MINUTE from time(9)");

        assertThatThrownBy(() -> assertions.expression("EXTRACT(TIMEZONE_MINUTE FROM TIME '12:34:56.1234567891')"))
                .isInstanceOf(PrestoException.class)
                .hasMessage("line 1:37: Cannot extract TIMEZONE_MINUTE from time(10)");

        assertThatThrownBy(() -> assertions.expression("EXTRACT(TIMEZONE_MINUTE FROM TIME '12:34:56.12345678912')"))
                .isInstanceOf(PrestoException.class)
                .hasMessage("line 1:37: Cannot extract TIMEZONE_MINUTE from time(11)");

        assertThatThrownBy(() -> assertions.expression("EXTRACT(TIMEZONE_MINUTE FROM TIME '12:34:56.123456789123')"))
                .isInstanceOf(PrestoException.class)
                .hasMessage("line 1:37: Cannot extract TIMEZONE_MINUTE from time(12)");
    }
}
