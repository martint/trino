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
package io.trino.type;

import com.fasterxml.jackson.core.JsonGenerator;
import com.fasterxml.jackson.core.JsonParser;
import com.fasterxml.jackson.core.json.JsonWriteFeature;
import com.fasterxml.jackson.databind.json.JsonMapper;
import io.airlift.slice.DynamicSliceOutput;
import io.airlift.slice.Slice;
import io.airlift.slice.SliceOutput;
import io.airlift.slice.Slices;
import io.trino.json.JsonItemEncoding;
import io.trino.json.JsonItems;
import io.trino.json.JsonValue;
import io.trino.json.JsonValueView;
import io.trino.plugin.base.util.JsonUtils;

import java.io.IOException;
import java.io.InputStreamReader;
import java.util.Optional;

import static io.airlift.slice.Slices.EMPTY_SLICE;
import static io.trino.util.JsonUtil.createJsonGenerator;
import static java.nio.charset.StandardCharsets.UTF_8;
import static java.util.Objects.requireNonNull;

final class JsonTypeEncoding
{
    private static final byte TEXT_ONLY_VERSION = 2;

    private JsonTypeEncoding() {}

    public static Slice encode(Slice jsonText)
    {
        requireNonNull(jsonText, "jsonText is null");

        return encodeParsedItem(jsonText);
    }

    public static Slice encode(JsonValue item)
    {
        requireNonNull(item, "item is null");

        return JsonItemEncoding.encode(item);
    }

    public static Slice decodeText(Slice encoded)
    {
        if (JsonItemEncoding.isEncoding(encoded)) {
            return renderText(encoded);
        }
        if (!isEncodedValue(encoded)) {
            return encoded;
        }
        int textLength = getTextLength(encoded);
        return encoded.slice(Byte.BYTES + Integer.BYTES, textLength);
    }

    public static JsonValue decodeItem(Slice encoded)
    {
        if (JsonItemEncoding.isEncoding(encoded)) {
            return JsonItemEncoding.decodeValue(encoded);
        }
        if (!isEncodedValue(encoded)) {
            return parseJsonText(encoded);
        }
        int textLength = getTextLength(encoded);
        int itemOffset = Byte.BYTES + Integer.BYTES + textLength;
        if (itemOffset == encoded.length()) {
            return parseJsonText(decodeText(encoded));
        }
        return JsonItemEncoding.decodeValue(encoded.slice(itemOffset, encoded.length() - itemOffset));
    }

    public static Optional<JsonValueView> decodeView(Slice encoded)
    {
        if (JsonItemEncoding.isEncoding(encoded)) {
            return Optional.of(JsonValueView.root(encoded));
        }
        if (!hasParsedItem(encoded)) {
            return Optional.empty();
        }

        return Optional.of(JsonValueView.root(parsedItemEncoding(encoded)));
    }

    public static Slice parsedItemEncoding(Slice encoded)
    {
        if (JsonItemEncoding.isEncoding(encoded)) {
            return encoded;
        }
        if (!hasParsedItem(encoded)) {
            throw new IllegalArgumentException("JSON type value does not contain a parsed SQL/JSON item");
        }

        int textLength = getTextLength(encoded);
        int itemOffset = Byte.BYTES + Integer.BYTES + textLength;
        return encoded.slice(itemOffset, encoded.length() - itemOffset);
    }

    public static boolean hasParsedItem(Slice encoded)
    {
        if (JsonItemEncoding.isEncoding(encoded)) {
            return true;
        }
        if (!isEncodedValue(encoded)) {
            return false;
        }
        int textLength = getTextLength(encoded);
        int itemOffset = Byte.BYTES + Integer.BYTES + textLength;
        return itemOffset < encoded.length();
    }

    public static Slice encodeLegacy(Slice jsonText)
    {
        Slice itemEncoding = tryEncodeItem(jsonText);
        if (itemEncoding.length() != 0) {
            return itemEncoding;
        }
        return encodeRawText(jsonText);
    }

    public static Slice stripParsedItem(Slice encoded)
    {
        return encodeRawText(decodeText(encoded));
    }

    public static Slice encodeRawTextForLegacy(Slice jsonText)
    {
        return encodeRawText(jsonText);
    }

    private static int getTextLength(Slice encoded)
    {
        requireNonNull(encoded, "encoded is null");

        byte version = encoded.getByte(0);
        if (version != TEXT_ONLY_VERSION) {
            throw new IllegalArgumentException("Unsupported JSON type encoding version: " + version);
        }
        int textLength = encoded.getInt(Byte.BYTES);
        int expectedMinimumLength = Byte.BYTES + Integer.BYTES + textLength;
        if (encoded.length() < expectedMinimumLength) {
            throw new IllegalArgumentException("Truncated JSON type encoding");
        }
        return textLength;
    }

    static boolean isEncodedValue(Slice encoded)
    {
        requireNonNull(encoded, "encoded is null");

        if (JsonItemEncoding.isEncoding(encoded)) {
            return true;
        }
        if (encoded.length() < Byte.BYTES + Integer.BYTES) {
            return false;
        }
        if (encoded.getByte(0) != TEXT_ONLY_VERSION) {
            return false;
        }

        int textLength = encoded.getInt(Byte.BYTES);
        int expectedMinimumLength = Byte.BYTES + Integer.BYTES + textLength;
        return textLength >= 0 && expectedMinimumLength <= encoded.length();
    }

    private static Slice tryEncodeItem(Slice jsonText)
    {
        try {
            JsonValue item = JsonItems.parseJson(new InputStreamReader(jsonText.getInput(), UTF_8));
            return JsonItemEncoding.encode(item);
        }
        catch (IOException | RuntimeException e) {
            return EMPTY_SLICE;
        }
    }

    private static Slice encodeParsedItem(Slice jsonText)
    {
        Slice itemEncoding = tryEncodeItem(jsonText);
        if (itemEncoding.length() != 0) {
            return itemEncoding;
        }
        // Text that Jackson accepts but the typed-item model cannot faithfully represent
        // (for example, numbers beyond DECIMAL precision that become infinity) is kept
        // as text so downstream consumers can still round-trip through the original literal.
        if (isStructurallyValidJson(jsonText)) {
            return encodeRawText(jsonText);
        }
        throw new IllegalArgumentException("Invalid JSON text");
    }

    private static boolean isStructurallyValidJson(Slice jsonText)
    {
        try (JsonParser parser = new JsonMapper().createParser(new InputStreamReader(jsonText.getInput(), UTF_8))) {
            if (parser.nextToken() == null) {
                return false;
            }
            parser.skipChildren();
            return parser.nextToken() == null;
        }
        catch (IOException e) {
            return false;
        }
    }

    private static Slice encodeRawText(Slice jsonText)
    {
        Slice encoded = Slices.allocate(Byte.BYTES + Integer.BYTES + jsonText.length());
        encoded.setByte(0, TEXT_ONLY_VERSION);
        encoded.setInt(Byte.BYTES, jsonText.length());
        encoded.setBytes(Byte.BYTES + Integer.BYTES, jsonText);
        return encoded;
    }

    private static Slice renderText(Slice itemEncoding)
    {
        try {
            return renderJsonText(itemEncoding, false);
        }
        catch (RuntimeException e) {
            return renderJsonText(itemEncoding, true);
        }
    }

    private static JsonValue parseJsonText(Slice jsonText)
    {
        try {
            return JsonItems.parseJson(new InputStreamReader(jsonText.getInput(), UTF_8));
        }
        catch (IOException | RuntimeException e) {
            throw new IllegalArgumentException("Invalid JSON text", e);
        }
    }

    private static Slice renderJsonText(Slice itemEncoding, boolean stringifyUnsupportedScalars)
    {
        try {
            SliceOutput output = new DynamicSliceOutput(64);
            try (JsonGenerator generator = createJsonGenerator(JSON_RENDER_MAPPER, output)) {
                JsonItemEncoding.writeJson(itemEncoding, generator, stringifyUnsupportedScalars);
            }
            return output.slice();
        }
        catch (IOException e) {
            throw new IllegalArgumentException("Failed to render JSON text", e);
        }
    }

    private static final JsonMapper JSON_RENDER_MAPPER = new JsonMapper(JsonUtils.jsonFactoryBuilder()
            // prevent characters outside the BMP (e.g. emoji) from being split into surrogate-pair escapes
            .enable(JsonWriteFeature.COMBINE_UNICODE_SURROGATES_IN_UTF8)
            .build());
}
