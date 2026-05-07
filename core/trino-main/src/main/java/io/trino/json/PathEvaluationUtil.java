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

import com.google.common.collect.ImmutableList;

import java.util.List;

public final class PathEvaluationUtil
{
    private PathEvaluationUtil() {}

    public static JsonItem normalize(JsonItem object)
    {
        if (object == null) {
            return null;
        }
        return JsonValueView.fromObject(object)
                .<JsonItem>map(view -> view)
                .orElseGet(() -> JsonItems.materialize(object));
    }

    public static List<JsonItem> unwrapArrays(List<JsonItem> sequence)
    {
        ImmutableList.Builder<JsonItem> outputSequence = ImmutableList.builder();
        for (JsonItem object : sequence) {
            JsonValueView.fromObject(object).ifPresentOrElse(view -> {
                if (view.isArray()) {
                    view.forEachArrayElement(outputSequence::add);
                }
                else {
                    outputSequence.add(object);
                }
            }, () -> {
                JsonItem normalized = normalize(object);
                if (normalized instanceof JsonArray array) {
                    array.elements().forEach(outputSequence::add);
                }
                else {
                    outputSequence.add(normalized);
                }
            });
        }
        return outputSequence.build();
    }
}
