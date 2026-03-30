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

    public static Optional<JsonValueView> fromObject(Object object)
    {
        if (object instanceof JsonValueView view) {
            return Optional.of(view);
        }
        if (object instanceof EncodedJsonItem encodedItem && JsonItemEncoding.isEncoding(encodedItem.encoding())) {
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
        return fromObject(object)
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

    public TypedValue typedValue()
    {
        checkKind(Kind.TYPED_VALUE);
        return JsonItemEncoding.readTypedValue(encoding, offset);
    }

    public JsonPathItem materialize()
    {
        return JsonItemEncoding.decodeItem(encoding, offset, end);
    }

    public JsonValue materializeValue()
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
