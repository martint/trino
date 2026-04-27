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

/// A carrier value that can appear in JSON path evaluation.
///
/// This includes:
/// - [SQL/JSON values][JsonValue] (materialized as a tree of Java objects)
/// - the [JsonInputError] sentinel for suppressed input-conversion failures
/// - execution sentinels such as the empty sequence
/// - parameter wrappers
public sealed interface JsonItem
        permits JsonEmptySequence, JsonInputError, JsonPathParameter, JsonValue
{
}
