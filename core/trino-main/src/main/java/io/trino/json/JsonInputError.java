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

/// Sentinel representing a suppressed JSON input conversion failure.
///
/// This is a materialized marker used by the SQL/JSON runtime to preserve malformed-input state
/// across evaluation when the semantics require the error to be carried rather than thrown.
public record JsonInputError()
        implements JsonItem
{
    public static final JsonInputError JSON_ERROR = new JsonInputError();

    /// Whether the given value represents a suppressed JSON input error.
    /// Recognizes both this materialized sentinel and any encoded representation
    /// (an [EncodedJsonItem] or [JsonValueView] whose payload is the JSON_ERROR encoding).
    public static boolean matches(Object object)
    {
        if (object instanceof JsonInputError) {
            return true;
        }
        return object instanceof JsonItem item
                && JsonValueView.fromObject(item)
                        .map(view -> view.kind() == JsonValueView.Kind.JSON_ERROR)
                        .orElse(false);
    }
}
