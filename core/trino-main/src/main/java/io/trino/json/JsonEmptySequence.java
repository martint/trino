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

/// Sentinel representing an empty path result sequence.
///
/// This is not a SQL/JSON value itself. It exists only so the path runtime can carry an explicit
/// `"no items produced"` marker through evaluation.
public record JsonEmptySequence()
        implements JsonItem
{
    public static final JsonEmptySequence EMPTY_SEQUENCE = new JsonEmptySequence();
}
