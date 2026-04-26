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

import io.airlift.slice.Slice;

import static java.util.Objects.requireNonNull;

/// A [JsonItem] backed by a standalone binary SQL/JSON encoding.
///
/// This wrapper keeps encoded values on the fast path without materializing them into the
/// [JsonValue] tree.
///
/// Equality and hashing follow the default record contract — byte-identity on the
/// underlying [Slice]. For SQL/JSON equivalence (cross-type numeric, PAD SPACE strings,
/// multiset object members), use [JsonItemSemantics#equals(JsonItem, JsonItem)].
public record EncodedJsonItem(Slice encoding)
        implements JsonItem
{
    public EncodedJsonItem
    {
        requireNonNull(encoding, "encoding is null");
    }

    @Override
    public String toString()
    {
        try {
            return JsonItems.jsonText(this).toStringUtf8();
        }
        catch (RuntimeException ignored) {
            return JsonItems.materialize(this).toString();
        }
    }
}
