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

import com.fasterxml.jackson.core.JsonGenerator;
import io.airlift.slice.Slice;
import io.trino.json.ir.TypedValue;

import java.io.IOException;
import java.util.Optional;
import java.util.function.BiConsumer;
import java.util.function.Consumer;

import static io.trino.json.JsonInputErrorNode.JSON_ERROR;
import static java.util.Objects.requireNonNull;

/// A lightweight view over a binary-encoded SQL/JSON item.
///
/// This lets hot-path JSON operators inspect arrays, objects, nulls, typed scalars, and the
/// [JSON_ERROR][JsonInputErrorNode#JSON_ERROR] sentinel directly from the physical representation
/// without materializing a [JsonItem] tree.
public final class JsonValueView
        implements JsonPathItem
{
    private static final Slice JSON_ERROR_ENCODING = JsonItemEncoding.encode(JSON_ERROR);

    public enum Kind
    {
        JSON_ERROR,
        NULL,
        ARRAY,
        OBJECT,
        TYPED_VALUE,
    }

    private final Slice encoding;
    private final int offset;
    private final int end;

    public static Optional<JsonValueView> fromObject(JsonPathItem item)
    {
        if (item instanceof JsonValueView view) {
            return Optional.of(view);
        }
        if (item instanceof EncodedJsonItem encodedItem && JsonItemEncoding.isEncoding(encodedItem.encoding())) {
            return Optional.of(root(encodedItem.encoding()));
        }
        return Optional.empty();
    }

    public static Optional<JsonValueView> fromItem(JsonPathItem item)
    {
        if (item instanceof JsonValueView view) {
            return Optional.of(view);
        }
        return Optional.empty();
    }

    public static boolean isJsonError(Object object)
    {
        if (object == JSON_ERROR) {
            return true;
        }
        return object instanceof JsonPathItem item
                && fromObject(item)
                        .map(view -> view.kind() == Kind.JSON_ERROR)
                        .orElse(false);
    }

    public static JsonValueView jsonError()
    {
        return root(JSON_ERROR_ENCODING);
    }

    public static JsonValueView root(Slice encoding)
    {
        requireNonNull(encoding, "encoding is null");
        return new JsonValueView(encoding, JsonItemEncoding.rootItemOffset(encoding), encoding.length());
    }

    JsonValueView(Slice encoding, int offset, int end)
    {
        this.encoding = requireNonNull(encoding, "encoding is null");
        this.offset = offset;
        this.end = end;
    }

    public Kind kind()
    {
        return switch (JsonItemEncoding.itemTag(encoding, offset)) {
            case JSON_ERROR -> Kind.JSON_ERROR;
            case JSON_NULL -> Kind.NULL;
            case ARRAY -> Kind.ARRAY;
            case OBJECT -> Kind.OBJECT;
            case TYPED_VALUE -> Kind.TYPED_VALUE;
        };
    }

    public boolean isArray()
    {
        return kind() == Kind.ARRAY;
    }

    public boolean isObject()
    {
        return kind() == Kind.OBJECT;
    }

    public boolean isTypedValue()
    {
        return kind() == Kind.TYPED_VALUE;
    }

    public int arraySize()
    {
        checkKind(Kind.ARRAY);
        return JsonItemEncoding.arraySize(encoding, offset);
    }

    public void forEachArrayElement(Consumer<JsonValueView> consumer)
    {
        requireNonNull(consumer, "consumer is null");
        checkKind(Kind.ARRAY);

        int count = JsonItemEncoding.arraySize(encoding, offset);
        int childOffset = offset + Byte.BYTES + Integer.BYTES;
        for (int index = 0; index < count; index++) {
            int childEnd = JsonItemEncoding.itemEndOffset(encoding, childOffset);
            consumer.accept(new JsonValueView(encoding, childOffset, childEnd));
            childOffset = childEnd;
        }
    }

    public void forEachObjectMember(BiConsumer<String, JsonValueView> consumer)
    {
        requireNonNull(consumer, "consumer is null");
        checkKind(Kind.OBJECT);

        int count = JsonItemEncoding.objectSize(encoding, offset);
        int childOffset = offset + Byte.BYTES + Integer.BYTES;
        for (int index = 0; index < count; index++) {
            String key = JsonItemEncoding.readString(encoding, childOffset);
            childOffset = JsonItemEncoding.stringEndOffset(encoding, childOffset);
            int childEnd = JsonItemEncoding.itemEndOffset(encoding, childOffset);
            consumer.accept(key, new JsonValueView(encoding, childOffset, childEnd));
            childOffset = childEnd;
        }
    }

    /// Returns the array element at `index`, or throws if `index` is out of range.
    /// Future indexed-array variants will dispatch here for O(1) lookup; today this walks
    /// the elements sequentially.
    public JsonValueView arrayElement(int index)
    {
        checkKind(Kind.ARRAY);
        int count = JsonItemEncoding.arraySize(encoding, offset);
        if (index < 0 || index >= count) {
            throw new IndexOutOfBoundsException("array index out of range: %d (size: %d)".formatted(index, count));
        }
        int childOffset = offset + Byte.BYTES + Integer.BYTES;
        for (int current = 0; current < index; current++) {
            childOffset = JsonItemEncoding.itemEndOffset(encoding, childOffset);
        }
        return new JsonValueView(encoding, childOffset, JsonItemEncoding.itemEndOffset(encoding, childOffset));
    }

    /// Returns the value at the first member with the given `key`, or empty when no member
    /// matches. SQL/JSON object members may have duplicate keys; this method returns the
    /// first occurrence in insertion order. Use [#objectMembers] to visit all duplicates.
    /// Future indexed-object variants will dispatch here for O(log n) lookup; today this
    /// walks the members sequentially.
    public Optional<JsonValueView> objectMember(String key)
    {
        requireNonNull(key, "key is null");
        checkKind(Kind.OBJECT);

        int count = JsonItemEncoding.objectSize(encoding, offset);
        int childOffset = offset + Byte.BYTES + Integer.BYTES;
        for (int index = 0; index < count; index++) {
            String memberKey = JsonItemEncoding.readString(encoding, childOffset);
            int valueOffset = JsonItemEncoding.stringEndOffset(encoding, childOffset);
            int childEnd = JsonItemEncoding.itemEndOffset(encoding, valueOffset);
            if (memberKey.equals(key)) {
                return Optional.of(new JsonValueView(encoding, valueOffset, childEnd));
            }
            childOffset = childEnd;
        }
        return Optional.empty();
    }

    /// Visits every member whose key equals `key`, in insertion order. Duplicates (allowed
    /// under `WITHOUT UNIQUE KEYS`) all surface to the consumer.
    ///
    /// Future indexed-object variants will dispatch here using the OBJECT_INDEXED sortPerm
    /// for O(log n) lookup of the first match plus a linear scan over adjacent duplicates;
    /// today this walks members sequentially.
    public void objectMembers(String key, Consumer<JsonValueView> consumer)
    {
        requireNonNull(key, "key is null");
        requireNonNull(consumer, "consumer is null");
        checkKind(Kind.OBJECT);

        int count = JsonItemEncoding.objectSize(encoding, offset);
        int childOffset = offset + Byte.BYTES + Integer.BYTES;
        for (int index = 0; index < count; index++) {
            String memberKey = JsonItemEncoding.readString(encoding, childOffset);
            int valueOffset = JsonItemEncoding.stringEndOffset(encoding, childOffset);
            int childEnd = JsonItemEncoding.itemEndOffset(encoding, valueOffset);
            if (memberKey.equals(key)) {
                consumer.accept(new JsonValueView(encoding, valueOffset, childEnd));
            }
            childOffset = childEnd;
        }
    }

    /// Returns the keys of this object in insertion order. Duplicate keys (allowed under
    /// `WITHOUT UNIQUE KEYS`) appear once per occurrence.
    public Iterable<String> objectKeys()
    {
        checkKind(Kind.OBJECT);
        int count = JsonItemEncoding.objectSize(encoding, offset);
        java.util.List<String> keys = new java.util.ArrayList<>(count);
        int childOffset = offset + Byte.BYTES + Integer.BYTES;
        for (int index = 0; index < count; index++) {
            keys.add(JsonItemEncoding.readString(encoding, childOffset));
            childOffset = JsonItemEncoding.stringEndOffset(encoding, childOffset);
            childOffset = JsonItemEncoding.itemEndOffset(encoding, childOffset);
        }
        return keys;
    }

    public TypedValue typedValue()
    {
        checkKind(Kind.TYPED_VALUE);
        return JsonItemEncoding.readTypedValue(encoding, offset);
    }

    public JsonPathItem materialize()
    {
        return JsonItemEncoding.decodeItem(encoding, offset, end);
    }

    public MaterializedJsonValue materializeValue()
    {
        return JsonItemEncoding.decodeValue(encoding, offset, end);
    }

    public Optional<Slice> scalarText()
    {
        return JsonItemEncoding.scalarText(encoding, offset, end);
    }

    public void writeJson(JsonGenerator generator, boolean stringifyUnsupportedScalars)
            throws IOException
    {
        JsonItemEncoding.writeJson(encoding, offset, end, generator, stringifyUnsupportedScalars);
    }

    public Slice copyEncoding()
    {
        return JsonItemEncoding.copyItemEncoding(encoding, offset, end);
    }

    private void checkKind(Kind expected)
    {
        if (kind() != expected) {
            throw new IllegalStateException("Expected %s, but was %s".formatted(expected, kind()));
        }
    }
}
