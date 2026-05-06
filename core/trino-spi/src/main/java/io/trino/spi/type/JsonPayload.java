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
package io.trino.spi.type;

import io.airlift.slice.Slice;

import static java.util.Objects.requireNonNull;

/**
 * Opaque byte payload of a SQL JSON value — either the typed-item binary encoding or raw
 * JSON text. Wraps a {@link Slice} so the SQL JSON type has a distinct Java identity (vs.
 * plain {@code Slice}) and to provide a non-breaking extension point for encoding-related
 * metadata that isn't part of the wire bytes themselves.
 *
 * <p><b>Equality and hashCode</b> use byte equality of the payload. Semantic JSON equality
 * (cross-type numeric coercion, PAD SPACE strings, multiset object members, etc.) lives in
 * the SQL JSON type's {@code EQUAL} operator and is not exposed via {@code Object.equals}.
 *
 * @since 482
 */
public final class JsonPayload
{
    private final Slice payload;

    /**
     * Wraps the given payload as a {@link JsonPayload}. The payload may be raw JSON text or a
     * typed-item binary encoding produced by the engine; downstream consumers detect the
     * form by inspecting the leading version byte.
     */
    public static JsonPayload of(Slice payload)
    {
        return new JsonPayload(payload);
    }

    private JsonPayload(Slice payload)
    {
        this.payload = requireNonNull(payload, "payload is null");
    }

    public Slice payload()
    {
        return payload;
    }

    @Override
    public boolean equals(Object other)
    {
        return other instanceof JsonPayload that && payload.equals(that.payload);
    }

    @Override
    public int hashCode()
    {
        return payload.hashCode();
    }

    @Override
    public String toString()
    {
        return "JsonPayload{" + payload.length() + " bytes}";
    }
}
