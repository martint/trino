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

import com.fasterxml.jackson.core.JsonGenerator;
import com.fasterxml.jackson.databind.SerializerProvider;
import com.fasterxml.jackson.databind.ser.std.StdSerializer;

import java.io.IOException;
import java.util.Base64;

/// Serializes a [JsonValue] as a base64-encoded [JsonItemEncoding] payload. The binary form
/// preserves the source SQL type (e.g. CHAR(5) vs VARCHAR, DATE vs TIMESTAMP) that JSON text
/// would erase, so values round-trip exactly through serialization.
public final class JsonValueSerializer
        extends StdSerializer<JsonValue>
{
    public JsonValueSerializer()
    {
        super(JsonValue.class);
    }

    @Override
    public void serialize(JsonValue value, JsonGenerator generator, SerializerProvider provider)
            throws IOException
    {
        generator.writeString(Base64.getEncoder().encodeToString(JsonItemEncoding.encode(value).getBytes()));
    }
}
