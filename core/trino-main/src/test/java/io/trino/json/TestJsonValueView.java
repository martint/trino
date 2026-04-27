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
import io.trino.json.ir.TypedValue;
import org.junit.jupiter.api.Test;

import java.io.IOException;
import java.io.Reader;
import java.util.ArrayList;
import java.util.List;
import java.util.Optional;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;

public class TestJsonValueView
{
    @Test
    public void testArrayElementReturnsValueAtIndex()
            throws IOException
    {
        JsonValueView view = encodeAndView("[10, 20, 30, 40]");

        assertThat(scalarLong(view.arrayElement(0))).isEqualTo(10L);
        assertThat(scalarLong(view.arrayElement(1))).isEqualTo(20L);
        assertThat(scalarLong(view.arrayElement(3))).isEqualTo(40L);
    }

    @Test
    public void testArrayElementOutOfBoundsThrows()
            throws IOException
    {
        JsonValueView view = encodeAndView("[1, 2, 3]");

        assertThatThrownBy(() -> view.arrayElement(-1))
                .isInstanceOf(IndexOutOfBoundsException.class);
        assertThatThrownBy(() -> view.arrayElement(3))
                .isInstanceOf(IndexOutOfBoundsException.class);
    }

    @Test
    public void testArrayElementOnNonArrayThrows()
            throws IOException
    {
        JsonValueView view = encodeAndView("{\"a\": 1}");

        assertThatThrownBy(() -> view.arrayElement(0))
                .isInstanceOf(IllegalStateException.class);
    }

    @Test
    public void testObjectMemberReturnsValueByKey()
            throws IOException
    {
        JsonValueView view = encodeAndView("{\"a\": 1, \"b\": 2, \"c\": 3}");

        assertThat(view.objectMember("a")).map(TestJsonValueView::scalarLong).contains(1L);
        assertThat(view.objectMember("b")).map(TestJsonValueView::scalarLong).contains(2L);
        assertThat(view.objectMember("c")).map(TestJsonValueView::scalarLong).contains(3L);
    }

    @Test
    public void testObjectMemberMissingReturnsEmpty()
            throws IOException
    {
        JsonValueView view = encodeAndView("{\"a\": 1}");

        assertThat(view.objectMember("missing")).isEmpty();
    }

    @Test
    public void testObjectMemberWithDuplicateKeyReturnsFirst()
            throws IOException
    {
        // SQL/JSON allows duplicate keys (WITHOUT UNIQUE KEYS); objectMember returns the
        // first occurrence in insertion order.
        JsonValueView view = encodeAndView("{\"a\": 1, \"a\": 2}");

        assertThat(view.objectMember("a")).map(TestJsonValueView::scalarLong).contains(1L);
    }

    @Test
    public void testObjectMemberOnNonObjectThrows()
            throws IOException
    {
        JsonValueView view = encodeAndView("[1, 2]");

        assertThatThrownBy(() -> view.objectMember("a"))
                .isInstanceOf(IllegalStateException.class);
    }

    @Test
    public void testObjectKeysInInsertionOrder()
            throws IOException
    {
        JsonValueView view = encodeAndView("{\"b\": 1, \"a\": 2, \"c\": 3}");

        List<String> keys = new ArrayList<>();
        view.objectKeys().forEach(keys::add);
        assertThat(keys).containsExactly("b", "a", "c");
    }

    @Test
    public void testObjectKeysIncludesDuplicates()
            throws IOException
    {
        JsonValueView view = encodeAndView("{\"a\": 1, \"a\": 2, \"b\": 3}");

        List<String> keys = new ArrayList<>();
        view.objectKeys().forEach(keys::add);
        assertThat(keys).containsExactly("a", "a", "b");
    }

    @Test
    public void testObjectKeysOnNonObjectThrows()
            throws IOException
    {
        JsonValueView view = encodeAndView("[1, 2]");

        assertThatThrownBy(view::objectKeys)
                .isInstanceOf(IllegalStateException.class);
    }

    private static JsonValueView encodeAndView(String json)
            throws IOException
    {
        Slice encoded = JsonItemEncoding.encode(JsonItems.parseJson(Reader.of(json)));
        return JsonValueView.root(encoded);
    }

    private static Long scalarLong(JsonValueView view)
    {
        if (view.isTypedValue()) {
            TypedValue value = view.typedValue();
            return value.getLongValue();
        }
        throw new IllegalStateException("not a typed scalar: " + view.kind());
    }

    private static Long scalarLong(Optional<JsonValueView> view)
    {
        return view.map(TestJsonValueView::scalarLong).orElseThrow();
    }
}
