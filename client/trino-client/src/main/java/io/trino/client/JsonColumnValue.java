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

import java.io.Serializable;
import java.util.Arrays;
import java.util.Optional;

import static java.util.Objects.requireNonNull;

/**
 * Client-side representation of a Trino {@code JSON} column value. Carries the canonical
 * JSON text along with an optional binary-encoded typed SQL/JSON item payload, which preserves
 * information (e.g. original SQL types of scalar members) that a text-only round-trip would lose.
 *
 * <p>Returned from {@code ResultSet#getObject(col, JsonColumnValue.class)} when the
 * {@link ClientCapabilities#JSON_PARSED_ITEM_ENCODING} capability is negotiated.
 *
 * <p>The binary encoding format is a server-side implementation detail and is not stable
 * across Trino versions. Callers must not persist it; prefer {@link #jsonText()} for storage.
 */
public final class JsonColumnValue
        implements Serializable
{
    private static final long serialVersionUID = 1L;

    private final String jsonText;
    private final byte[] typedItemEncoding;

    private JsonColumnValue(String jsonText, byte[] typedItemEncoding)
    {
        this.jsonText = requireNonNull(jsonText, "jsonText is null");
        this.typedItemEncoding = typedItemEncoding == null ? null : typedItemEncoding.clone();
    }

    public static JsonColumnValue fromJsonText(String jsonText)
    {
        return new JsonColumnValue(jsonText, null);
    }

    public static JsonColumnValue fromJsonText(String jsonText, byte[] typedItemEncoding)
    {
        return new JsonColumnValue(jsonText, requireNonNull(typedItemEncoding, "typedItemEncoding is null"));
    }

    public String jsonText()
    {
        return jsonText;
    }

    public boolean hasTypedItemEncoding()
    {
        return typedItemEncoding != null;
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
        if (!(obj instanceof JsonColumnValue)) {
            return false;
        }
        JsonColumnValue other = (JsonColumnValue) obj;
        return jsonText.equals(other.jsonText) && Arrays.equals(typedItemEncoding, other.typedItemEncoding);
    }

    @Override
    public int hashCode()
    {
        return 31 * jsonText.hashCode() + Arrays.hashCode(typedItemEncoding);
    }
}
