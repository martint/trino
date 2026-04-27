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

import static java.util.Objects.requireNonNull;

/// Wrapper for a JSON path parameter value.
///
/// Path parameters are represented distinctly from ordinary input items so the evaluator can keep
/// track of parameter-originated values without widening the materialized value hierarchy.
public record JsonPathParameter(JsonValue item)
        implements JsonItem
{
    public JsonPathParameter
    {
        requireNonNull(item, "item is null");
    }
}
