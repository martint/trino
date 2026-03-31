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

import io.airlift.slice.Slice;
import io.trino.plugin.base.util.JsonTypeUtil;
import io.trino.spi.function.ScalarFunction;
import io.trino.spi.function.SqlType;

import static io.trino.spi.type.StandardTypes.JSON;
import static io.trino.type.JsonType.encodeCanonicalText;
import static io.trino.type.JsonType.hasParsedItem;
import static io.trino.type.JsonType.jsonText;

public final class JsonLegacySemanticsFunction
{
    public static final String NAME = "$json_legacy";

    private JsonLegacySemanticsFunction() {}

    @ScalarFunction(value = NAME, hidden = true)
    @SqlType(JSON)
    public static Slice canonicalize(@SqlType(JSON) Slice value)
    {
        if (!hasParsedItem(value)) {
            return value;
        }
        // Re-canonicalize through the legacy path so duplicate object keys collapse and
        // numeric formatting matches the historical text-based behavior. Store as
        // text-only so downstream comparisons fall back to canonical-text equality
        // rather than semantic equality.
        return encodeCanonicalText(JsonTypeUtil.jsonParse(jsonText(value)));
    }
}
