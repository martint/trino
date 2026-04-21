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
import com.fasterxml.jackson.core.json.JsonWriteFeature;
import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.json.JsonMapper;
import io.airlift.slice.DynamicSliceOutput;
import io.airlift.slice.Slice;
import io.airlift.slice.SliceOutput;
import io.trino.json.ir.TypedValue;
import io.trino.operator.scalar.json.JsonInputConversionException;
import io.trino.operator.scalar.json.JsonOutputConversionException;
import io.trino.plugin.base.util.JsonUtils;
import io.trino.spi.block.BlockBuilder;
import io.trino.spi.type.BigintType;
import io.trino.spi.type.BooleanType;
import io.trino.spi.type.CharType;
import io.trino.spi.type.DecimalType;
import io.trino.spi.type.DoubleType;
import io.trino.spi.type.Int128;
import io.trino.spi.type.IntegerType;
import io.trino.spi.type.NumberType;
import io.trino.spi.type.RealType;
import io.trino.spi.type.SmallintType;
import io.trino.spi.type.TinyintType;
import io.trino.spi.type.TrinoNumber;
import io.trino.spi.type.Type;
import io.trino.spi.type.VarcharType;

import java.io.IOException;
import java.io.InputStreamReader;
import java.io.Reader;
import java.math.BigDecimal;
import java.math.BigInteger;
import java.util.ArrayList;
import java.util.List;
import java.util.Optional;

import static io.airlift.slice.Slices.utf8Slice;
import static io.trino.json.JsonInputErrorNode.JSON_ERROR;
import static io.trino.json.ir.SqlJsonLiteralConverter.getTypedValue;
import static io.trino.plugin.base.util.JsonUtils.jsonFactory;
import static io.trino.spi.type.BigintType.BIGINT;
import static io.trino.spi.type.BooleanType.BOOLEAN;
import static io.trino.spi.type.Chars.padSpaces;
import static io.trino.spi.type.DecimalType.createDecimalType;
import static io.trino.spi.type.Decimals.MAX_PRECISION;
import static io.trino.spi.type.Decimals.encodeScaledValue;
import static io.trino.spi.type.Decimals.encodeShortScaledValue;
import static io.trino.spi.type.IntegerType.INTEGER;
import static io.trino.spi.type.TypeUtils.writeNativeValue;
import static io.trino.spi.type.VarcharType.VARCHAR;
import static io.trino.util.JsonUtil.createJsonGenerator;
import static java.lang.Float.intBitsToFloat;
import static java.lang.Math.toIntExact;
import static java.nio.charset.StandardCharsets.UTF_8;
import static java.util.Objects.requireNonNull;

public final class JsonItems
{
    private static final JsonFactory JSON_FACTORY = jsonFactory();
    private static final JsonMapper JSON_MAPPER = new JsonMapper(JsonUtils.jsonFactoryBuilder()
            // prevent characters outside the BMP (e.g. emoji) from being split into surrogate-pair escapes
            .enable(JsonWriteFeature.COMBINE_UNICODE_SURROGATES_IN_UTF8)
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

        return switch (token) {
            case VALUE_TRUE -> new TypedValue(BOOLEAN, true);
            case VALUE_FALSE -> new TypedValue(BOOLEAN, false);
            case VALUE_STRING -> new TypedValue(VARCHAR, utf8Slice(parser.getText()));
            case VALUE_NUMBER_INT -> parseInteger(parser);
            case VALUE_NUMBER_FLOAT -> parseDecimal(parser);
            default -> throw new JsonInputConversionException("unexpected JSON token: " + token);
        };
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
            Type type = typedValue.getType();
            if (type instanceof CharType charType) {
                return Optional.of(utf8Slice(padSpaces((Slice) typedValue.getObjectValue(), charType).toStringUtf8()));
            }
            if (type instanceof VarcharType) {
                return Optional.of((Slice) typedValue.getObjectValue());
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
            writeTypedValue(generator, typedValue);
            return;
        }

        throw new JsonOutputConversionException("unsupported SQL/JSON item type: " + item.getClass().getSimpleName());
    }

    private static TypedValue parseInteger(JsonParser parser)
            throws IOException
    {
        return switch (parser.getNumberType()) {
            case INT -> new TypedValue(INTEGER, (long) parser.getIntValue());
            case LONG -> new TypedValue(BIGINT, parser.getLongValue());
            case BIG_INTEGER -> parseBigInteger(parser.getBigIntegerValue());
            default -> throw new JsonInputConversionException("unsupported JSON integer representation");
        };
    }

    private static TypedValue parseBigInteger(BigInteger value)
    {
        if (value.bitLength() < Integer.SIZE) {
            return new TypedValue(INTEGER, value.longValue());
        }
        if (value.bitLength() < Long.SIZE) {
            return new TypedValue(BIGINT, value.longValue());
        }
        throw new JsonInputConversionException("value too big");
    }

    private static TypedValue parseDecimal(JsonParser parser)
            throws IOException
    {
        // JSON numbers are canonicalized: 1, 1.0, 1e0 all map to the same stored value.
        // Significant digits are preserved (no rounding, no truncation); only cosmetic
        // trailing zeros / exponent notation collapses.
        return parseBigDecimal(parser.getDecimalValue());
    }

    private static TypedValue parseBigDecimal(BigDecimal value)
    {
        // Preserve every significant digit the input supplied, including trailing zeros in
        // decimal notation ("1.20" stays (120, 2), "0.000" stays (0, 3)). Jackson already
        // collapses scientific notation without a fractional part ("1e0" → (1, 0)), so we
        // don't need to normalize further.
        if (value.scale() < 0) {
            // e.g. BigInteger-backed "10000000000" parses to scale=-10; rescale so the
            // value fits a DECIMAL(precision, 0).
            value = value.setScale(0);
        }
        int scale = value.scale();
        // BigDecimal.precision is always >= 1, even for zero; DECIMAL requires precision >= scale.
        int precision = Math.max(value.precision(), scale);
        if (precision > MAX_PRECISION) {
            // Fall back to the arbitrary-precision NUMBER type for values that don't fit DECIMAL(<=38).
            return new TypedValue(NumberType.NUMBER, TrinoNumber.from(value));
        }
        DecimalType type = createDecimalType(precision, scale);
        Object encoded = type.isShort() ? encodeShortScaledValue(value, scale) : encodeScaledValue(value, scale);
        return TypedValue.fromValueAsObject(type, encoded);
    }

    private static void writeTypedValue(JsonGenerator generator, TypedValue typedValue)
            throws IOException
    {
        Type type = typedValue.getType();
        switch (type) {
            case BooleanType _ -> generator.writeBoolean(typedValue.getBooleanValue());
            case CharType charType -> generator.writeString(padSpaces((Slice) typedValue.getObjectValue(), charType).toStringUtf8());
            case VarcharType _ -> generator.writeString(((Slice) typedValue.getObjectValue()).toStringUtf8());
            case BigintType _, IntegerType _, SmallintType _, TinyintType _ -> generator.writeNumber(typedValue.getLongValue());
            case DecimalType decimalType -> {
                BigInteger unscaledValue = decimalType.isShort() ?
                        BigInteger.valueOf(typedValue.getLongValue()) :
                        ((Int128) typedValue.getObjectValue()).toBigInteger();
                // Emit the plain string so trailing zeros (e.g. DECIMAL(2,1) value 1.0) survive.
                generator.writeNumber(new BigDecimal(unscaledValue, decimalType.getScale()).toPlainString());
            }
            case DoubleType _ -> generator.writeNumber(typedValue.getDoubleValue());
            case RealType _ -> generator.writeNumber(intBitsToFloat(toIntExact(typedValue.getLongValue())));
            case NumberType _ -> generator.writeNumber(((TrinoNumber) typedValue.getObjectValue()).toString());
            default -> throw new JsonOutputConversionException("SQL value cannot be represented as JSON");
        }
    }
}
