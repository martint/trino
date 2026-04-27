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
import io.trino.spi.type.IntegerType;
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
    public void testArrayElementOnIndexedArray()
    {
        // Force the indexed form by materializing a 10-element array (>= threshold of 8) and
        // encoding it via JsonItemEncoding (which emits ARRAY_INDEXED for materialized
        // JsonArrayItems above the threshold).
        List<MaterializedJsonValue> elements = new ArrayList<>();
        for (int i = 0; i < 10; i++) {
            elements.add(new TypedValue(IntegerType.INTEGER, i * 100L));
        }
        Slice encoded = JsonItemEncoding.encode(new JsonArrayItem(elements));
        JsonValueView view = JsonValueView.root(encoded);

        // Confirm we got the indexed form.
        assertThat(JsonItemEncoding.itemTag(encoded, 1)).isEqualTo(JsonItemEncoding.ItemTag.ARRAY_INDEXED);

        // Verify O(1) random access produces correct values.
        assertThat(view.arraySize()).isEqualTo(10);
        assertThat(scalarLong(view.arrayElement(0))).isEqualTo(0L);
        assertThat(scalarLong(view.arrayElement(5))).isEqualTo(500L);
        assertThat(scalarLong(view.arrayElement(9))).isEqualTo(900L);

        // Sequential walk also works on the indexed form.
        List<Long> walked = new ArrayList<>();
        view.forEachArrayElement(element -> walked.add(scalarLong(element)));
        assertThat(walked).containsExactly(0L, 100L, 200L, 300L, 400L, 500L, 600L, 700L, 800L, 900L);
    }

    @Test
    public void testObjectMemberOnIndexedObjectFindsValueByKey()
    {
        // Build an OBJECT_INDEXED via the materialized-tree encoder. The encoder emits the
        // indexed form for objects with >= 8 entries.
        List<JsonObjectMember> members = new ArrayList<>();
        members.add(new JsonObjectMember("zebra", new TypedValue(IntegerType.INTEGER, 1L)));
        members.add(new JsonObjectMember("apple", new TypedValue(IntegerType.INTEGER, 2L)));
        members.add(new JsonObjectMember("monkey", new TypedValue(IntegerType.INTEGER, 3L)));
        members.add(new JsonObjectMember("banana", new TypedValue(IntegerType.INTEGER, 4L)));
        members.add(new JsonObjectMember("cherry", new TypedValue(IntegerType.INTEGER, 5L)));
        members.add(new JsonObjectMember("date", new TypedValue(IntegerType.INTEGER, 6L)));
        members.add(new JsonObjectMember("elderberry", new TypedValue(IntegerType.INTEGER, 7L)));
        members.add(new JsonObjectMember("fig", new TypedValue(IntegerType.INTEGER, 8L)));
        Slice encoded = JsonItemEncoding.encode(new JsonObjectItem(members));
        JsonValueView view = JsonValueView.root(encoded);

        assertThat(JsonItemEncoding.itemTag(encoded, 1)).isEqualTo(JsonItemEncoding.ItemTag.OBJECT_INDEXED);

        // Each lookup goes through binary search on the sort permutation.
        assertThat(view.objectMember("apple")).map(TestJsonValueView::scalarLong).contains(2L);
        assertThat(view.objectMember("zebra")).map(TestJsonValueView::scalarLong).contains(1L);
        assertThat(view.objectMember("monkey")).map(TestJsonValueView::scalarLong).contains(3L);
        assertThat(view.objectMember("fig")).map(TestJsonValueView::scalarLong).contains(8L);
        assertThat(view.objectMember("date")).map(TestJsonValueView::scalarLong).contains(6L);

        // Missing keys return empty regardless of placement.
        assertThat(view.objectMember("aardvark")).isEmpty();   // before all keys lex-wise
        assertThat(view.objectMember("zucchini")).isEmpty();   // after all keys lex-wise
        assertThat(view.objectMember("kiwi")).isEmpty();       // mid-range, no match
    }

    @Test
    public void testForEachObjectMemberPreservesInsertionOrderOnIndexedObject()
    {
        // The indexed form must walk in INSERTION order, not sort order, so json_format and
        // round-trip text reproduce the producer's intent (e.g. JSON_OBJECT clause order).
        List<JsonObjectMember> members = new ArrayList<>();
        String[] keys = {"zebra", "apple", "monkey", "banana", "cherry", "date", "elderberry", "fig"};
        for (int i = 0; i < keys.length; i++) {
            members.add(new JsonObjectMember(keys[i], new TypedValue(IntegerType.INTEGER, (long) i)));
        }
        Slice encoded = JsonItemEncoding.encode(new JsonObjectItem(members));
        JsonValueView view = JsonValueView.root(encoded);
        assertThat(JsonItemEncoding.itemTag(encoded, 1)).isEqualTo(JsonItemEncoding.ItemTag.OBJECT_INDEXED);

        List<String> walked = new ArrayList<>();
        view.forEachObjectMember((k, _) -> walked.add(k));
        assertThat(walked).containsExactly(keys);

        // objectKeys() preserves insertion order too.
        List<String> seenKeys = new ArrayList<>();
        view.objectKeys().forEach(seenKeys::add);
        assertThat(seenKeys).containsExactly(keys);
    }

    @Test
    public void testObjectMembersWithDuplicateKeysOnIndexedObject()
    {
        // SQL/JSON allows duplicate keys (WITHOUT UNIQUE KEYS). objectMembers must visit
        // every match in INSERTION order — even when the indexed form's binary search
        // visits them in sort order internally.
        List<JsonObjectMember> members = new ArrayList<>();
        members.add(new JsonObjectMember("a", new TypedValue(IntegerType.INTEGER, 1L)));
        members.add(new JsonObjectMember("b", new TypedValue(IntegerType.INTEGER, 2L)));
        members.add(new JsonObjectMember("a", new TypedValue(IntegerType.INTEGER, 3L))); // dup
        members.add(new JsonObjectMember("c", new TypedValue(IntegerType.INTEGER, 4L)));
        members.add(new JsonObjectMember("d", new TypedValue(IntegerType.INTEGER, 5L)));
        members.add(new JsonObjectMember("a", new TypedValue(IntegerType.INTEGER, 6L))); // dup
        members.add(new JsonObjectMember("e", new TypedValue(IntegerType.INTEGER, 7L)));
        members.add(new JsonObjectMember("f", new TypedValue(IntegerType.INTEGER, 8L)));
        Slice encoded = JsonItemEncoding.encode(new JsonObjectItem(members));
        JsonValueView view = JsonValueView.root(encoded);
        assertThat(JsonItemEncoding.itemTag(encoded, 1)).isEqualTo(JsonItemEncoding.ItemTag.OBJECT_INDEXED);

        List<Long> matches = new ArrayList<>();
        view.objectMembers("a", v -> matches.add(scalarLong(v)));
        // Insertion order: a=1, then a=3, then a=6.
        assertThat(matches).containsExactly(1L, 3L, 6L);

        // objectMember returns the first occurrence in insertion order.
        assertThat(view.objectMember("a")).map(TestJsonValueView::scalarLong).contains(1L);
    }

    @Test
    public void testIndexedObjectRoundTripsToCanonicalText()
            throws IOException
    {
        // JSON_OBJECT-style insertion order survives a round-trip through OBJECT_INDEXED.
        String json = "{\"z\":1,\"a\":2,\"m\":3,\"b\":4,\"c\":5,\"d\":6,\"e\":7,\"f\":8}";
        Slice fromText = JsonItems.parseJsonToEncoding(Reader.of(json));
        // The streaming parser still emits non-indexed; re-encode the materialized form to
        // exercise the indexed path.
        JsonPathItem materialized = JsonItemEncoding.decode(fromText);
        Slice indexed = JsonItemEncoding.encode(materialized);
        assertThat(JsonItemEncoding.itemTag(indexed, 1)).isEqualTo(JsonItemEncoding.ItemTag.OBJECT_INDEXED);

        Slice text = JsonItems.jsonText(JsonItemEncoding.decode(indexed));
        assertThat(text.toStringUtf8()).isEqualTo(json);
    }

    @Test
    public void testIndexedArrayRoundTripsToCanonicalText()
            throws IOException
    {
        // Round-trip large array → indexed form → text. The text should match input.
        String json = "[0,1,2,3,4,5,6,7,8,9,10]";
        Slice encoded = JsonItems.parseJsonToEncoding(Reader.of(json));
        // The streaming parser emits ARRAY_INDEXED once the element count reaches the
        // INDEXED_CONTAINER_THRESHOLD (=8), matching the typed-encoded path.
        assertThat(JsonItemEncoding.itemTag(encoded, 1)).isEqualTo(JsonItemEncoding.ItemTag.ARRAY_INDEXED);

        // Re-encode the materialized form to confirm round-trip stability.
        JsonPathItem materialized = JsonItemEncoding.decode(encoded);
        Slice indexed = JsonItemEncoding.encode(materialized);
        assertThat(JsonItemEncoding.itemTag(indexed, 1)).isEqualTo(JsonItemEncoding.ItemTag.ARRAY_INDEXED);

        // Text round-trip on the indexed form must match the original input.
        Slice text = JsonItems.jsonText(JsonItemEncoding.decode(indexed));
        assertThat(text.toStringUtf8()).isEqualTo(json);
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
