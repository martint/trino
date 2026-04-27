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

import com.fasterxml.jackson.core.JsonParser;
import com.fasterxml.jackson.databind.DeserializationContext;
import com.fasterxml.jackson.databind.deser.std.StdDeserializer;

import java.io.IOException;

public final class JsonValueDeserializer
        extends StdDeserializer<JsonValue>
{
    public JsonValueDeserializer()
    {
        super(JsonValue.class);
    }

    @Override
    public JsonValue deserialize(JsonParser parser, DeserializationContext context)
            throws IOException
    {
        return JsonItems.parseValue(parser);
    }

    @Override
    public JsonValue getNullValue(DeserializationContext context)
    {
        // Without this override, Jackson maps a JSON `null` to Java null and never invokes
        // `deserialize`, so a list element like `[null]` would slot Java null into the
        // collection. SQL/JSON treats null as a first-class value (`JsonNull.JSON_NULL`).
        return JsonNull.JSON_NULL;
    }
}
