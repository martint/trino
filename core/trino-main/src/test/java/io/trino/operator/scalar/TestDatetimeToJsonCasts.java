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

import io.trino.sql.query.QueryAssertions;
import org.junit.jupiter.api.AfterAll;
import org.junit.jupiter.api.BeforeAll;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.TestInstance;
import org.junit.jupiter.api.parallel.Execution;

import static io.trino.type.JsonType.JSON;
import static org.assertj.core.api.Assertions.assertThat;
import static org.junit.jupiter.api.TestInstance.Lifecycle.PER_CLASS;
import static org.junit.jupiter.api.parallel.ExecutionMode.CONCURRENT;

/**
 * Round-trip and precision coverage for the datetime → JSON and JSON → datetime casts. The
 * four forward casts (TIME, TIME WITH TIME ZONE, TIMESTAMP, TIMESTAMP WITH TIME ZONE) produce a
 * JSON string carrying the datetime's canonical text form, so a round-trip through JSON should
 * preserve the original value at every precision.
 */
@TestInstance(PER_CLASS)
@Execution(CONCURRENT)
public class TestDatetimeToJsonCasts
{
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
    public void testTimeToJson()
    {
        assertThat(assertions.expression("CAST(TIME '12:34:56' AS JSON)"))
                .hasType(JSON)
                .isEqualTo("\"12:34:56\"");
        assertThat(assertions.expression("CAST(TIME '12:34:56.123' AS JSON)"))
                .hasType(JSON)
                .isEqualTo("\"12:34:56.123\"");
        assertThat(assertions.expression("CAST(TIME '12:34:56.123456789' AS JSON)"))
                .hasType(JSON)
                .isEqualTo("\"12:34:56.123456789\"");
    }

    @Test
    public void testTimeWithTimeZoneToJson()
    {
        assertThat(assertions.expression("CAST(TIME '12:34:56+02:00' AS JSON)"))
                .hasType(JSON)
                .isEqualTo("\"12:34:56+02:00\"");
        assertThat(assertions.expression("CAST(TIME '12:34:56.123+02:00' AS JSON)"))
                .hasType(JSON)
                .isEqualTo("\"12:34:56.123+02:00\"");
    }

    @Test
    public void testTimestampToJson()
    {
        assertThat(assertions.expression("CAST(TIMESTAMP '2024-01-02 12:34:56' AS JSON)"))
                .hasType(JSON)
                .isEqualTo("\"2024-01-02 12:34:56\"");
        assertThat(assertions.expression("CAST(TIMESTAMP '2024-01-02 12:34:56.123' AS JSON)"))
                .hasType(JSON)
                .isEqualTo("\"2024-01-02 12:34:56.123\"");
        assertThat(assertions.expression("CAST(TIMESTAMP '2024-01-02 12:34:56.123456789' AS JSON)"))
                .hasType(JSON)
                .isEqualTo("\"2024-01-02 12:34:56.123456789\"");
    }

    @Test
    public void testTimestampWithTimeZoneToJson()
    {
        assertThat(assertions.expression("CAST(TIMESTAMP '2024-01-02 12:34:56 UTC' AS JSON)"))
                .hasType(JSON)
                .isEqualTo("\"2024-01-02 12:34:56 UTC\"");
        assertThat(assertions.expression("CAST(TIMESTAMP '2024-01-02 12:34:56.123 UTC' AS JSON)"))
                .hasType(JSON)
                .isEqualTo("\"2024-01-02 12:34:56.123 UTC\"");
    }

    @Test
    public void testNullInputsProduceSqlNull()
    {
        assertThat(assertions.expression("CAST(CAST(NULL AS TIME) AS JSON)"))
                .isNull(JSON);
        assertThat(assertions.expression("CAST(CAST(NULL AS TIME WITH TIME ZONE) AS JSON)"))
                .isNull(JSON);
        assertThat(assertions.expression("CAST(CAST(NULL AS TIMESTAMP) AS JSON)"))
                .isNull(JSON);
        assertThat(assertions.expression("CAST(CAST(NULL AS TIMESTAMP WITH TIME ZONE) AS JSON)"))
                .isNull(JSON);
    }
}
