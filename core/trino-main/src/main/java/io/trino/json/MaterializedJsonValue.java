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

/// A materialized SQL/JSON value. Unlike execution-only sentinels and storage wrappers, this
/// represents an actual SQL/JSON value.
///
/// Equality and hashing across the [JsonPathItem] hierarchy follow the default
/// Java contract — structural equality on records and identity on enums and views. For
/// SQL/JSON equivalence (cross-type numeric, PAD SPACE strings, multiset object members,
/// non-finite-by-kind), use [JsonItemSemantics#equals(JsonPathItem, JsonPathItem)] and
/// [JsonItemSemantics#hash(JsonPathItem)]. Java equality is intentionally not overridden
/// to keep collection bucketing predictable; callers must not rely on Java equality to
/// deduplicate across representations (e.g. mixing an [EncodedJsonItem] with the same
/// value as a materialized [JsonArrayItem] in a `HashSet`).
public non-sealed interface MaterializedJsonValue
        extends JsonItem
{
}
