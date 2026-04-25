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
public final class JsonEmptySequenceNode
        implements JsonPathItem
{
    public static final JsonEmptySequenceNode EMPTY_SEQUENCE = new JsonEmptySequenceNode();

    private JsonEmptySequenceNode() {}

    @Override
    public String toString()
    {
        return "EMPTY_SEQUENCE";
    }

    @Override
    public boolean equals(Object o)
    {
        return o == this;
    }

    @Override
    public int hashCode()
    {
        return getClass().hashCode();
    }
}
