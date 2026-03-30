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

import com.fasterxml.jackson.core.JsonFactory;
import com.fasterxml.jackson.core.JsonGenerator;
import com.fasterxml.jackson.core.JsonParser;
import com.fasterxml.jackson.core.JsonToken;
import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.json.JsonMapper;
import com.fasterxml.jackson.databind.node.BigIntegerNode;
import com.fasterxml.jackson.databind.node.BooleanNode;
import com.fasterxml.jackson.databind.node.DecimalNode;
import com.fasterxml.jackson.databind.node.DoubleNode;
import com.fasterxml.jackson.databind.node.FloatNode;
import com.fasterxml.jackson.databind.node.IntNode;
import com.fasterxml.jackson.databind.node.LongNode;
import com.fasterxml.jackson.databind.node.TextNode;
import io.airlift.slice.DynamicSliceOutput;
import io.airlift.slice.Slice;
import io.airlift.slice.SliceOutput;
import io.trino.json.ir.TypedValue;
import io.trino.operator.scalar.json.JsonInputConversionException;
import io.trino.operator.scalar.json.JsonOutputConversionException;
import io.trino.spi.block.BlockBuilder;
import io.trino.spi.type.CharType;
import io.trino.spi.type.Type;
import io.trino.spi.type.VarcharType;

import java.io.IOException;
import java.io.InputStreamReader;
import java.io.Reader;
import java.util.ArrayList;
import java.util.List;
import java.util.Optional;

import static io.airlift.slice.Slices.utf8Slice;
import static io.trino.json.JsonInputErrorNode.JSON_ERROR;
import static io.trino.json.ir.SqlJsonLiteralConverter.getJsonNode;
import static io.trino.json.ir.SqlJsonLiteralConverter.getTypedValue;
import static io.trino.plugin.base.util.JsonUtils.jsonFactory;
import static io.trino.spi.type.TypeUtils.writeNativeValue;
import static io.trino.util.JsonUtil.createJsonGenerator;
import static java.nio.charset.StandardCharsets.UTF_8;
import static java.util.Objects.requireNonNull;

public final class JsonItems
{
    private static final JsonFactory JSON_FACTORY = jsonFactory();
    private static final JsonMapper JSON_MAPPER = new JsonMapper(io.trino.plugin.base.util.JsonUtils.jsonFactoryBuilder()
            // prevent characters outside the BMP (e.g. emoji) from being split into surrogate-pair escapes
            .enable(com.fasterxml.jackson.core.json.JsonWriteFeature.COMBINE_UNICODE_SURROGATES_IN_UTF8)
            .build());

    private JsonItems() {}

    public static EncodedJsonItem encoded(JsonPathItem item)
    {
        requireNonNull(item, "item is null");
        if (item instanceof EncodedJsonItem) {
            return (EncodedJsonItem) item;
        }
        return new EncodedJsonItem(JsonItemEncoding.encode(item));
    }

    public static JsonPathItem materialize(JsonPathItem item)
    {
        requireNonNull(item, "item is null");
        Optional<JsonValueView> view = JsonValueView.fromObject(item);
        if (view.isPresent()) {
            return view.get().materialize();
        }
        if (item instanceof EncodedJsonItem encodedItem) {
            String jsonText = encodedItem.encoding().toStringUtf8();
            if (jsonText.equals(JSON_ERROR.toString())) {
                return JSON_ERROR;
            }
            try {
                return parseJson(new InputStreamReader(encodedItem.encoding().getInput(), UTF_8));
            }
            catch (IOException e) {
                throw new JsonInputConversionException(e);
            }
        }
        return item;
    }

    public static JsonValue materializeValue(JsonPathItem item)
    {
        JsonPathItem materialized = materialize(item);
        if (materialized instanceof JsonValue value) {
            return value;
        }
        throw new IllegalArgumentException("Expected JSON value, but got %s".formatted(materialized.getClass().getSimpleName()));
    }

    public static JsonValue asJsonValue(Object object)
    {
        requireNonNull(object, "object is null");

        if (object instanceof JsonValue value) {
            return value;
        }
        Optional<JsonValueView> view = JsonValueView.fromObject(object);
        if (view.isPresent()) {
            return view.get().materializeValue();
        }
        if (object instanceof JsonPathItem item) {
            return materializeValue(item);
        }
        throw new IllegalArgumentException("Expected JSON value, but got %s".formatted(object.getClass().getSimpleName()));
    }

    public static JsonValue parseJson(Reader reader)
            throws IOException
    {
        requireNonNull(reader, "reader is null");

        try (JsonParser parser = JSON_FACTORY.createParser(reader)) {
            JsonToken token = parser.nextToken();
            if (token == null) {
                throw new JsonInputConversionException("unexpected end of JSON input");
            }
            JsonValue item = parseItem(parser, token);
            if (parser.nextToken() != null) {
                throw new JsonInputConversionException("trailing data after JSON item");
            }
            return item;
        }
    }

    private static JsonValue parseItem(JsonParser parser, JsonToken token)
            throws IOException
    {
        if (token == JsonToken.VALUE_NULL) {
            return JsonNull.JSON_NULL;
        }
        if (token == JsonToken.START_ARRAY) {
            List<JsonValue> elements = new ArrayList<>();
            for (JsonToken next = parser.nextToken(); next != JsonToken.END_ARRAY; next = parser.nextToken()) {
                if (next == null) {
                    throw new JsonInputConversionException("unexpected end of JSON array");
                }
                elements.add(parseItem(parser, next));
            }
            return new JsonArrayItem(elements);
        }
        if (token == JsonToken.START_OBJECT) {
            List<JsonObjectMember> members = new ArrayList<>();
            for (JsonToken next = parser.nextToken(); next != JsonToken.END_OBJECT; next = parser.nextToken()) {
                if (next == null) {
                    throw new JsonInputConversionException("unexpected end of JSON object");
                }
                if (next != JsonToken.FIELD_NAME) {
                    throw new JsonInputConversionException("expected object field name");
                }
                String fieldName = parser.currentName();
                JsonToken valueToken = parser.nextToken();
                if (valueToken == null) {
                    throw new JsonInputConversionException("unexpected end of JSON object");
                }
                members.add(new JsonObjectMember(fieldName, parseItem(parser, valueToken)));
            }
            return new JsonObjectItem(members);
        }

        JsonNode scalar = switch (token) {
            case VALUE_TRUE -> BooleanNode.TRUE;
            case VALUE_FALSE -> BooleanNode.FALSE;
            case VALUE_STRING -> TextNode.valueOf(parser.getText());
            case VALUE_NUMBER_INT -> switch (parser.getNumberType()) {
                case INT -> IntNode.valueOf(parser.getIntValue());
                case LONG -> LongNode.valueOf(parser.getLongValue());
                case BIG_INTEGER -> BigIntegerNode.valueOf(parser.getBigIntegerValue());
                default -> throw new JsonInputConversionException("unsupported JSON integer representation");
            };
            case VALUE_NUMBER_FLOAT -> switch (parser.getNumberType()) {
                case FLOAT -> FloatNode.valueOf(parser.getFloatValue());
                case DOUBLE -> DoubleNode.valueOf(parser.getDoubleValue());
                case BIG_DECIMAL -> DecimalNode.valueOf(parser.getDecimalValue());
                default -> throw new JsonInputConversionException("unsupported JSON number representation");
            };
            default -> throw new JsonInputConversionException("unexpected JSON token: " + token);
        };
        Optional<TypedValue> typedValue = getTypedValue(scalar);
        if (typedValue.isEmpty()) {
            throw new JsonInputConversionException("JSON item cannot be converted to SQL/JSON scalar");
        }
        return typedValue.get();
    }

    public static JsonValue fromJsonNode(JsonNode jsonNode)
    {
        requireNonNull(jsonNode, "jsonNode is null");

        if (jsonNode.isNull()) {
            return JsonNull.JSON_NULL;
        }
        Optional<TypedValue> typedValue = getTypedValue(jsonNode);
        if (typedValue.isPresent()) {
            return typedValue.get();
        }
        if (jsonNode.isArray()) {
            List<JsonValue> elements = new ArrayList<>();
            jsonNode.elements().forEachRemaining(element -> elements.add(fromJsonNode(element)));
            return new JsonArrayItem(elements);
        }
        if (jsonNode.isObject()) {
            List<JsonObjectMember> members = new ArrayList<>();
            jsonNode.properties().forEach(field -> members.add(new JsonObjectMember(field.getKey(), fromJsonNode(field.getValue()))));
            return new JsonObjectItem(members);
        }
        throw new JsonOutputConversionException("JSON item cannot be converted to SQL/JSON item");
    }

    public static JsonNode toJsonNode(JsonPathItem item)
    {
        requireNonNull(item, "item is null");

        item = materialize(item);
        if (item instanceof JsonNode jsonNode) {
            return jsonNode;
        }
        if (item instanceof JsonValue value) {
            return toJsonNode(value);
        }
        throw new IllegalArgumentException("Expected JSON value, but got " + item.getClass().getSimpleName());
    }

    public static Slice jsonText(JsonPathItem item)
    {
        try {
            SliceOutput output = new DynamicSliceOutput(64);
            try (JsonGenerator generator = createJsonGenerator(JSON_MAPPER, output)) {
                if (item instanceof EncodedJsonItem encodedItem && JsonItemEncoding.isEncoding(encodedItem.encoding())) {
                    JsonItemEncoding.writeJson(encodedItem.encoding(), generator);
                }
                else {
                    item = materialize(item);
                    if (!(item instanceof JsonValue value)) {
                        throw new JsonOutputConversionException("unsupported SQL/JSON item type: " + item.getClass().getSimpleName());
                    }
                    writeJson(generator, value);
                }
            }
            return output.slice();
        }
        catch (IOException e) {
            throw new JsonOutputConversionException(e);
        }
    }

    public static Slice jsonText(Object object)
    {
        requireNonNull(object, "object is null");
        if (object instanceof JsonPathItem item) {
            return jsonText(item);
        }
        Optional<JsonValueView> view = JsonValueView.fromObject(object);
        if (view.isPresent()) {
            return jsonText(view.get());
        }
        throw new IllegalArgumentException("Expected JSON item, but got %s".formatted(object.getClass().getSimpleName()));
    }

    public static JsonNode toJsonNode(JsonValue item)
    {
        try {
            return JSON_MAPPER.readTree(jsonText(item).getInput());
        }
        catch (IOException e) {
            throw new JsonOutputConversionException(e);
        }
    }

    public static Optional<Slice> scalarText(JsonPathItem item)
    {
        Optional<JsonValueView> view = JsonValueView.fromObject(item);
        if (view.isPresent()) {
            return view.get().scalarText();
        }
        item = materialize(item);
        if (item instanceof TypedValue typedValue) {
            Optional<JsonNode> jsonNode = getJsonNode(typedValue);
            if (jsonNode.isPresent() && jsonNode.get().isTextual()) {
                return Optional.of(utf8Slice(jsonNode.get().textValue()));
            }
        }
        return Optional.empty();
    }

    public static Optional<Slice> scalarText(Object object)
    {
        requireNonNull(object, "object is null");
        if (object instanceof JsonPathItem item) {
            return scalarText(item);
        }
        Optional<JsonValueView> view = JsonValueView.fromObject(object);
        if (view.isPresent()) {
            return view.get().scalarText();
        }
        return Optional.empty();
    }

    static String typedValueText(TypedValue typedValue)
    {
        Type type = typedValue.getType();
        if (type instanceof CharType || type instanceof VarcharType) {
            return scalarText(typedValue)
                    .orElseThrow(() -> new IllegalArgumentException("Typed JSON item is not textual: " + type))
                    .toStringUtf8();
        }

        BlockBuilder blockBuilder = type.createBlockBuilder(null, 1);
        writeNativeValue(type, blockBuilder, typedValue.getValueAsObject());
        Object objectValue = type.getObjectValue(blockBuilder.build(), 0);
        return requireNonNull(objectValue, "objectValue is null").toString();
    }

    private static void writeJson(JsonGenerator generator, JsonValue item)
            throws IOException
    {
        if (item == JsonNull.JSON_NULL) {
            generator.writeNull();
            return;
        }
        if (item instanceof JsonObjectItem objectItem) {
            generator.writeStartObject();
            for (JsonObjectMember member : objectItem.members()) {
                generator.writeFieldName(member.key());
                writeJson(generator, member.value());
            }
            generator.writeEndObject();
            return;
        }
        if (item instanceof JsonArrayItem arrayItem) {
            generator.writeStartArray();
            for (JsonValue element : arrayItem.elements()) {
                writeJson(generator, element);
            }
            generator.writeEndArray();
            return;
        }
        if (item instanceof TypedValue typedValue) {
            JsonNode jsonNode = getJsonNode(typedValue)
                    .orElseThrow(() -> new JsonOutputConversionException("SQL value cannot be represented as JSON"));
            generator.writeTree(jsonNode);
            return;
        }

        throw new JsonOutputConversionException("unsupported SQL/JSON item type: " + item.getClass().getSimpleName());
    }
}
