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
import io.trino.spi.function.ScalarFunction;
import io.trino.spi.function.SqlType;
import io.trino.spi.variant.Variant;
import io.trino.type.JsonType;
import io.trino.util.variant.VariantUtil;
import io.trino.util.variant.VariantWriter;

import static io.trino.spi.type.StandardTypes.JSON;
import static io.trino.spi.type.StandardTypes.VARIANT;
import static io.trino.type.JsonType.legacyJsonValue;

public final class JsonVariantLegacyCasts
{
    public static final String JSON_TO_VARIANT = "$json_to_variant_legacy";
    public static final String VARIANT_TO_JSON = "$variant_to_json_legacy";

    private static final VariantWriter JSON_VARIANT_WRITER = VariantWriter.create(JsonType.JSON);

    private JsonVariantLegacyCasts() {}

    @ScalarFunction(value = JSON_TO_VARIANT, hidden = true)
    @SqlType(VARIANT)
    public static Variant jsonToVariant(@SqlType(JSON) Slice value)
    {
        return JSON_VARIANT_WRITER.write(JsonType.jsonText(value));
    }

    @ScalarFunction(value = VARIANT_TO_JSON, hidden = true)
    @SqlType(JSON)
    public static Slice variantToJson(@SqlType(VARIANT) Variant value)
    {
        return legacyJsonValue(VariantUtil.asJson(value));
    }
}
