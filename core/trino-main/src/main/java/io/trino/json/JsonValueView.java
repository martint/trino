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

    public static JsonValueView root(Slice payload)
    {
        requireNonNull(payload, "payload is null");
        Slice encoding = JsonItemEncoding.isEncoding(payload) ? payload : JsonItemEncoding.encode(parseText(payload));
        return new JsonValueView(encoding, JsonItemEncoding.rootItemOffset(encoding), encoding.length());
    }

    private static MaterializedJsonValue parseText(Slice text)
    {
        try {
            return JsonItems.parseJson(new java.io.InputStreamReader(text.getInput(), java.nio.charset.StandardCharsets.UTF_8));
        }
        catch (java.io.IOException | RuntimeException e) {
            throw new IllegalArgumentException("Invalid JSON text", e);
        }
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
            case ARRAY, ARRAY_INDEXED -> Kind.ARRAY;
            case OBJECT, OBJECT_INDEXED -> Kind.OBJECT;
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
        int childOffset = JsonItemEncoding.arrayItemsStart(encoding, offset);
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
        int childOffset = JsonItemEncoding.objectEntriesStart(encoding, offset);
        for (int index = 0; index < count; index++) {
            String key = JsonItemEncoding.readString(encoding, childOffset);
            childOffset = JsonItemEncoding.stringEndOffset(encoding, childOffset);
            int childEnd = JsonItemEncoding.itemEndOffset(encoding, childOffset);
            consumer.accept(key, new JsonValueView(encoding, childOffset, childEnd));
            childOffset = childEnd;
        }
    }

    /// Returns the array element at `index`, or throws if `index` is out of range. For
    /// {@link io.trino.json.JsonItemEncoding.ItemTag#ARRAY_INDEXED} payloads, this is O(1)
    /// — a direct lookup through the offsets table. For unindexed {@link
    /// io.trino.json.JsonItemEncoding.ItemTag#ARRAY} payloads, this is O(n) — a sequential
    /// walk to the requested index.
    public JsonValueView arrayElement(int index)
    {
        checkKind(Kind.ARRAY);
        int count = JsonItemEncoding.arraySize(encoding, offset);
        if (index < 0 || index >= count) {
            throw new IndexOutOfBoundsException("array index out of range: %d (size: %d)".formatted(index, count));
        }
        if (JsonItemEncoding.itemTag(encoding, offset) == JsonItemEncoding.ItemTag.ARRAY_INDEXED) {
            // offsets[count+1] makes element bounds branchless: start = items + offsets[i],
            // end = items + offsets[i+1]. The "+1" sentinel lives at offsets[count].
            int itemsStart = JsonItemEncoding.arrayItemsStart(encoding, offset);
            int offsetsTableStart = offset + Byte.BYTES + Integer.BYTES;
            int childOffset = itemsStart + encoding.getInt(offsetsTableStart + index * Integer.BYTES);
            int childEnd = itemsStart + encoding.getInt(offsetsTableStart + (index + 1) * Integer.BYTES);
            return new JsonValueView(encoding, childOffset, childEnd);
        }
        int childOffset = JsonItemEncoding.arrayItemsStart(encoding, offset);
        for (int current = 0; current < index; current++) {
            childOffset = JsonItemEncoding.itemEndOffset(encoding, childOffset);
        }
        return new JsonValueView(encoding, childOffset, JsonItemEncoding.itemEndOffset(encoding, childOffset));
    }

    /// Returns the value at the first member with the given `key`, or empty when no member
    /// matches. SQL/JSON object members may have duplicate keys; this method returns the
    /// first occurrence in insertion order. Use [#objectMembers] to visit all duplicates.
    /// For {@link io.trino.json.JsonItemEncoding.ItemTag#OBJECT_INDEXED} payloads, this is
    /// O(log n + d) — a binary search through the sort permutation, plus a linear scan over
    /// at most `d` adjacent duplicates of `key`. For unindexed {@link
    /// io.trino.json.JsonItemEncoding.ItemTag#OBJECT} payloads, this is O(n) — a sequential
    /// scan over all members.
    public Optional<JsonValueView> objectMember(String key)
    {
        requireNonNull(key, "key is null");
        checkKind(Kind.OBJECT);

        if (JsonItemEncoding.itemTag(encoding, offset) == JsonItemEncoding.ItemTag.OBJECT_INDEXED) {
            int firstSorted = findFirstSortedIndex(key);
            if (firstSorted < 0) {
                return Optional.empty();
            }
            int firstInsertion = JsonItemEncoding.objectIndexedSortPerm(encoding, offset, firstSorted);
            // For duplicate keys, return the entry with the smallest insertion-order index.
            int count = JsonItemEncoding.objectSize(encoding, offset);
            Slice targetBytes = io.airlift.slice.Slices.utf8Slice(key);
            for (int s = firstSorted + 1; s < count; s++) {
                int candidateIdx = JsonItemEncoding.objectIndexedSortPerm(encoding, offset, s);
                int candidateOffset = JsonItemEncoding.objectIndexedEntryOffset(encoding, offset, candidateIdx);
                if (readKeyBytes(encoding, candidateOffset).compareTo(targetBytes) != 0) {
                    break;
                }
                if (candidateIdx < firstInsertion) {
                    firstInsertion = candidateIdx;
                }
            }
            int entryOffset = JsonItemEncoding.objectIndexedEntryOffset(encoding, offset, firstInsertion);
            int valueOffset = JsonItemEncoding.stringEndOffset(encoding, entryOffset);
            int valueEnd = JsonItemEncoding.objectIndexedEntryEnd(encoding, offset, firstInsertion);
            return Optional.of(new JsonValueView(encoding, valueOffset, valueEnd));
        }

        int count = JsonItemEncoding.objectSize(encoding, offset);
        int childOffset = JsonItemEncoding.objectEntriesStart(encoding, offset);
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
    /// For {@link io.trino.json.JsonItemEncoding.ItemTag#OBJECT_INDEXED} payloads, this is
    /// O(log n + d) — a binary search through the sort permutation, plus a linear scan over
    /// at most `d` adjacent duplicates of `key`. For unindexed {@link
    /// io.trino.json.JsonItemEncoding.ItemTag#OBJECT} payloads, this is O(n) — a sequential
    /// scan over all members.
    public void objectMembers(String key, Consumer<JsonValueView> consumer)
    {
        requireNonNull(key, "key is null");
        requireNonNull(consumer, "consumer is null");
        checkKind(Kind.OBJECT);

        if (JsonItemEncoding.itemTag(encoding, offset) == JsonItemEncoding.ItemTag.OBJECT_INDEXED) {
            int firstSorted = findFirstSortedIndex(key);
            if (firstSorted < 0) {
                return;
            }
            int count = JsonItemEncoding.objectSize(encoding, offset);
            Slice targetBytes = io.airlift.slice.Slices.utf8Slice(key);
            int[] matchingIndices = new int[count - firstSorted];
            int matches = 0;
            matchingIndices[matches++] = JsonItemEncoding.objectIndexedSortPerm(encoding, offset, firstSorted);
            for (int s = firstSorted + 1; s < count; s++) {
                int candidateIdx = JsonItemEncoding.objectIndexedSortPerm(encoding, offset, s);
                int candidateOffset = JsonItemEncoding.objectIndexedEntryOffset(encoding, offset, candidateIdx);
                if (readKeyBytes(encoding, candidateOffset).compareTo(targetBytes) != 0) {
                    break;
                }
                matchingIndices[matches++] = candidateIdx;
            }
            // Emit duplicates in insertion order, regardless of where they sit in the sort permutation.
            java.util.Arrays.sort(matchingIndices, 0, matches);
            for (int i = 0; i < matches; i++) {
                int entryIndex = matchingIndices[i];
                int entryOffset = JsonItemEncoding.objectIndexedEntryOffset(encoding, offset, entryIndex);
                int valueOffset = JsonItemEncoding.stringEndOffset(encoding, entryOffset);
                int valueEnd = JsonItemEncoding.objectIndexedEntryEnd(encoding, offset, entryIndex);
                consumer.accept(new JsonValueView(encoding, valueOffset, valueEnd));
            }
            return;
        }

        int count = JsonItemEncoding.objectSize(encoding, offset);
        int childOffset = JsonItemEncoding.objectEntriesStart(encoding, offset);
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
        int childOffset = JsonItemEncoding.objectEntriesStart(encoding, offset);
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

    /// Lower-bound binary search over the OBJECT_INDEXED sort permutation. Returns the
    /// smallest sort position whose key compares equal to `key` (UTF-8 byte order), or -1
    /// when no member matches.
    private int findFirstSortedIndex(String key)
    {
        int count = JsonItemEncoding.objectSize(encoding, offset);
        Slice target = io.airlift.slice.Slices.utf8Slice(key);
        int lo = 0;
        int hi = count;
        while (lo < hi) {
            int mid = (lo + hi) >>> 1;
            int candidateIdx = JsonItemEncoding.objectIndexedSortPerm(encoding, offset, mid);
            int candidateOffset = JsonItemEncoding.objectIndexedEntryOffset(encoding, offset, candidateIdx);
            if (readKeyBytes(encoding, candidateOffset).compareTo(target) < 0) {
                lo = mid + 1;
            }
            else {
                hi = mid;
            }
        }
        if (lo >= count) {
            return -1;
        }
        int candidateIdx = JsonItemEncoding.objectIndexedSortPerm(encoding, offset, lo);
        int candidateOffset = JsonItemEncoding.objectIndexedEntryOffset(encoding, offset, candidateIdx);
        return readKeyBytes(encoding, candidateOffset).compareTo(target) == 0 ? lo : -1;
    }

    /// Returns the raw UTF-8 bytes of a length-prefixed string at `offset`, without
    /// constructing a `String`. Used to compare keys directly against UTF-8 query bytes
    /// during OBJECT_INDEXED lookups.
    private static Slice readKeyBytes(Slice encoding, int offset)
    {
        return encoding.slice(offset + Integer.BYTES, encoding.getInt(offset));
    }
}
