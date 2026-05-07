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
package io.trino.operator.scalar.time;

import io.trino.json.JsonItemEncoding;
import io.trino.json.TypedValue;
import io.trino.spi.function.LiteralParameter;
import io.trino.spi.function.LiteralParameters;
import io.trino.spi.function.ScalarOperator;
import io.trino.spi.function.SqlType;
import io.trino.spi.type.JsonPayload;

import static io.trino.spi.function.OperatorType.CAST;
import static io.trino.spi.type.StandardTypes.JSON;
import static io.trino.spi.type.TimeType.createTimeType;

@ScalarOperator(CAST)
public final class TimeToJsonCast
{
    private TimeToJsonCast() {}

    @LiteralParameters("p")
    @SqlType(JSON)
    public static JsonPayload cast(@LiteralParameter("p") long precision, @SqlType("time(p)") long value)
    {
        return JsonPayload.of(JsonItemEncoding.encode(new TypedValue(createTimeType((int) precision), value)));
    }
}
