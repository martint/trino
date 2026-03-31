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
package io.trino.client;

import java.util.Arrays;
import java.util.Optional;

import static java.util.Objects.requireNonNull;

public final class JsonValue
{
    private final String jsonText;
    private final byte[] typedItemEncoding;

    private JsonValue(String jsonText, byte[] typedItemEncoding)
    {
        this.jsonText = requireNonNull(jsonText, "jsonText is null");
        this.typedItemEncoding = typedItemEncoding == null ? null : typedItemEncoding.clone();
    }

    public static JsonValue fromJsonText(String jsonText)
    {
        return new JsonValue(jsonText, null);
    }

    public static JsonValue fromJsonText(String jsonText, byte[] typedItemEncoding)
    {
        return new JsonValue(jsonText, requireNonNull(typedItemEncoding, "typedItemEncoding is null"));
    }

    public String jsonText()
    {
        return jsonText;
    }

    public Optional<byte[]> typedItemEncoding()
    {
        return typedItemEncoding == null ? Optional.empty() : Optional.of(typedItemEncoding.clone());
    }

    @Override
    public String toString()
    {
        return jsonText;
    }

    @Override
    public boolean equals(Object obj)
    {
        if (this == obj) {
            return true;
        }
        if (!(obj instanceof JsonValue)) {
            return false;
        }
        JsonValue other = (JsonValue) obj;
        return jsonText.equals(other.jsonText) && Arrays.equals(typedItemEncoding, other.typedItemEncoding);
    }

    @Override
    public int hashCode()
    {
        return 31 * jsonText.hashCode() + Arrays.hashCode(typedItemEncoding);
    }
}
