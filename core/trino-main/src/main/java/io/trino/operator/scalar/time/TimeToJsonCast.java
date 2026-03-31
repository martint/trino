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

import io.airlift.slice.Slice;
import io.trino.spi.function.LiteralParameter;
import io.trino.spi.function.LiteralParameters;
import io.trino.spi.function.ScalarOperator;
import io.trino.spi.function.SqlType;

import static io.trino.spi.function.OperatorType.CAST;
import static io.trino.spi.type.StandardTypes.JSON;
import static io.trino.spi.type.TimeType.MAX_PRECISION;
import static io.trino.util.JsonUtil.createJsonString;

@ScalarOperator(CAST)
public final class TimeToJsonCast
{
    private TimeToJsonCast() {}

    @LiteralParameters("p")
    @SqlType(JSON)
    public static Slice cast(@LiteralParameter("p") long precision, @SqlType("time(p)") long value)
    {
        return createJsonString(TimeOperators.castToVarchar(MAX_PRECISION + 9L, precision, value).toStringUtf8());
    }
}
