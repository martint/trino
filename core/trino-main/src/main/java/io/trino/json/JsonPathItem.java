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
/// - [materialized SQL/JSON items][JsonItem]
/// - execution sentinels such as the empty sequence
/// - parameter wrappers
/// - view-backed or encoded wrappers that avoid eager materialization
public sealed interface JsonPathItem
        permits EncodedJsonItem, JsonEmptySequenceNode, JsonItem, JsonPathParameter, JsonValueView
{
}
