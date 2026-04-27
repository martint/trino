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
 * The Java-level representation of a SQL JSON value.
 *
 * <p>A JsonValue carries an opaque byte payload — either the typed-item binary encoding or
 * raw JSON text. The wrapper exists to give the SQL JSON type a distinct Java identity
 * (vs. plain {@code Slice}) and as a future extension point: additional fields may be added
 * later in a non-breaking way to support encoding extensions that aren't part of the wire
 * bytes themselves.
 *
 * <p><b>Equality and hashCode</b> use byte equality of the payload. Semantic JSON equality
 * (cross-type numeric coercion, PAD SPACE strings, multiset object members, etc.) lives in
 * the SQL JSON type's {@code EQUAL} operator and is not exposed via {@code Object.equals}.
 *
 * @since 482
 */
public final class JsonValue
{
    private final Slice payload;

    /**
     * Wraps the given payload as a {@link JsonValue}. The payload may be raw JSON text or a
     * typed-item binary encoding produced by the engine; downstream consumers detect the
     * form by inspecting the leading version byte.
     */
    public static JsonValue of(Slice payload)
    {
        return new JsonValue(payload);
    }

    private JsonValue(Slice payload)
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
        return other instanceof JsonValue that && payload.equals(that.payload);
    }

    @Override
    public int hashCode()
    {
        return payload.hashCode();
    }

    @Override
    public String toString()
    {
        return "JsonValue{" + payload.length() + " bytes}";
    }
}
