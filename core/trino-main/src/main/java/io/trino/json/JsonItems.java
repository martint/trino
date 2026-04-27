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
import java.nio.charset.StandardCharsets;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;
import java.util.Optional;

import static io.airlift.slice.Slices.utf8Slice;
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
        if (item instanceof EncodedJsonItem encoded) {
            return encoded;
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
            Slice encoding = encodedItem.encoding();
            // Fast path: well-formed binary-encoded item. Detected by version byte so we don't
            // waste a full UTF-8 decode on the typical case.
            if (JsonItemEncoding.isEncoding(encoding)) {
                return JsonItemEncoding.decode(encoding);
            }
            // Legacy path: EncodedJsonItem may wrap raw JSON text (see
            // testMaterializeParsesLegacyTextualEncodedJsonItem). Parse it as JSON text.
            try {
                return parseJson(new InputStreamReader(encoding.getInput(), StandardCharsets.UTF_8));
            }
            catch (IOException e) {
                throw new JsonInputConversionException(e);
            }
        }
        return item;
    }

    public static MaterializedJsonValue materializeValue(JsonPathItem item)
    {
        JsonPathItem materialized = materialize(item);
        if (materialized instanceof MaterializedJsonValue value) {
            return value;
        }
        throw new IllegalArgumentException("Expected JSON value, but got %s".formatted(materialized.getClass().getSimpleName()));
    }

    public static MaterializedJsonValue asJsonValue(JsonPathItem item)
    {
        requireNonNull(item, "item is null");

        if (item instanceof MaterializedJsonValue value) {
            return value;
        }
        Optional<JsonValueView> view = JsonValueView.fromItem(item);
        if (view.isPresent()) {
            return view.get().materializeValue();
        }
        return materializeValue(item);
    }

    public static MaterializedJsonValue parseJson(Reader reader)
            throws IOException
    {
        requireNonNull(reader, "reader is null");

        try (JsonParser parser = JSON_FACTORY.createParser(reader)) {
            JsonToken token = parser.nextToken();
            if (token == null) {
                throw new JsonInputConversionException("unexpected end of JSON input");
            }
            MaterializedJsonValue item = parseItem(parser, token, 0);
            if (parser.nextToken() != null) {
                throw new JsonInputConversionException("trailing data after JSON item");
            }
            return item;
        }
    }

    // Cap recursion against deeply nested JSON text input to avoid StackOverflowError.
    private static final int MAX_PARSE_DEPTH = 1000;

    /// Parses JSON text and emits the typed-item binary encoding directly, without
    /// materializing an intermediate {@link MaterializedJsonValue} tree. ARRAY and OBJECT element counts
    /// are deferred and patched into the output once streaming completes.
    public static Slice parseJsonToEncoding(Reader reader)
            throws IOException
    {
        requireNonNull(reader, "reader is null");

        try (JsonParser parser = JSON_FACTORY.createParser(reader)) {
            JsonToken token = parser.nextToken();
            if (token == null) {
                throw new JsonInputConversionException("unexpected end of JSON input");
            }
            Slice result = encodeCurrentItem(parser);
            if (parser.nextToken() != null) {
                throw new JsonInputConversionException("trailing data after JSON item");
            }
            return result;
        }
    }

    /// Streams the JSON value at the parser's current token into the typed-item binary
    /// encoding. The parser must be positioned at the first token of the value; on return,
    /// it is positioned at the last token of the value (matching the JsonExtract.JsonExtractor
    /// invariant). The result is a complete, versioned encoding ready to be returned as a
    /// {@link io.trino.type.JsonType} payload.
    public static Slice encodeCurrentItem(JsonParser parser)
            throws IOException
    {
        DynamicSliceOutput output = new DynamicSliceOutput(64);
        JsonItemEncoding.appendVersion(output);
        PatchList patches = new PatchList();
        streamItem(parser, parser.currentToken(), output, patches, 0);
        Slice result = output.slice();
        patches.apply(result);
        return result;
    }

    private static void streamItem(JsonParser parser, JsonToken token, SliceOutput output, PatchList patches, int depth)
            throws IOException
    {
        if (depth >= MAX_PARSE_DEPTH) {
            throw new JsonInputConversionException("JSON nesting exceeds maximum depth of " + MAX_PARSE_DEPTH);
        }
        switch (token) {
            case VALUE_NULL -> JsonItemEncoding.appendJsonNullItem(output);
            case VALUE_TRUE -> JsonItemEncoding.appendBoolean(output, true);
            case VALUE_FALSE -> JsonItemEncoding.appendBoolean(output, false);
            case VALUE_STRING -> JsonItemEncoding.appendVarchar(output, utf8Slice(parser.getText()));
            case VALUE_NUMBER_INT -> streamInteger(parser, output);
            case VALUE_NUMBER_FLOAT -> streamFloat(parser, output);
            case START_ARRAY -> streamArray(parser, output, depth);
            case START_OBJECT -> streamObject(parser, output, patches, depth);
            default -> throw new JsonInputConversionException("unexpected JSON token: " + token);
        }
    }

    private static void streamArray(JsonParser parser, SliceOutput output, int depth)
            throws IOException
    {
        // Buffer items into a side output so the element count and per-element offsets are
        // known by the time we commit to ARRAY vs ARRAY_INDEXED. ARRAY_INDEXED matches the
        // typed-encoded path's threshold (count ≥ INDEXED_CONTAINER_THRESHOLD), giving O(1)
        // element lookup at decode time without forcing the streaming writer to make the
        // tag choice up front.
        DynamicSliceOutput items = new DynamicSliceOutput(64);
        List<Integer> offsets = new ArrayList<>();
        // ARRAY/ARRAY_INDEXED both write recursive items via a fresh PatchList because the
        // outer patches reference the main output, not the buffered side output.
        PatchList itemPatches = new PatchList();
        int count = 0;
        for (JsonToken next = parser.nextToken(); next != JsonToken.END_ARRAY; next = parser.nextToken()) {
            if (next == null) {
                throw new JsonInputConversionException("unexpected end of JSON array");
            }
            offsets.add(items.size());
            streamItem(parser, next, items, itemPatches, depth + 1);
            count++;
        }
        offsets.add(items.size());
        Slice itemBytes = items.slice();
        itemPatches.apply(itemBytes);

        if (count >= JsonItemEncoding.INDEXED_CONTAINER_THRESHOLD) {
            output.appendByte(JsonItemEncoding.ItemTag.ARRAY_INDEXED.encoded());
            output.appendInt(count);
            for (int o : offsets) {
                output.appendInt(o);
            }
        }
        else {
            output.appendByte(JsonItemEncoding.ItemTag.ARRAY.encoded());
            output.appendInt(count);
        }
        output.writeBytes(itemBytes);
    }

    private static void streamObject(JsonParser parser, SliceOutput output, PatchList patches, int depth)
            throws IOException
    {
        // Streaming objects always emit non-indexed OBJECT (unlike streamArray, which switches
        // to ARRAY_INDEXED at INDEXED_CONTAINER_THRESHOLD). OBJECT_INDEXED requires a sortPerm
        // header computed from sorted UTF-8 keys, which is incompatible with single-pass
        // streaming — keys aren't known until END_OBJECT. The materialized writer
        // (JsonItemEncoding#writeObjectIndexed) handles the sorted form when the value is
        // already in memory; text-parsed paths that need O(log n) member lookup go through
        // materialize() first.
        output.appendByte(JsonItemEncoding.ItemTag.OBJECT.encoded());
        int countOffset = output.size();
        output.appendInt(0);
        int count = 0;
        for (JsonToken next = parser.nextToken(); next != JsonToken.END_OBJECT; next = parser.nextToken()) {
            if (next == null) {
                throw new JsonInputConversionException("unexpected end of JSON object");
            }
            if (next != JsonToken.FIELD_NAME) {
                throw new JsonInputConversionException("expected object field name");
            }
            JsonItemEncoding.appendObjectKey(output, parser.currentName());
            JsonToken valueToken = parser.nextToken();
            if (valueToken == null) {
                throw new JsonInputConversionException("unexpected end of JSON object");
            }
            streamItem(parser, valueToken, output, patches, depth + 1);
            count++;
        }
        patches.add(countOffset, count);
    }

    private static void streamInteger(JsonParser parser, SliceOutput output)
            throws IOException
    {
        switch (parser.getNumberType()) {
            case INT -> JsonItemEncoding.appendInteger(output, parser.getIntValue());
            case LONG -> JsonItemEncoding.appendBigint(output, parser.getLongValue());
            case BIG_INTEGER -> streamBigInteger(parser.getBigIntegerValue(), output);
            default -> throw new JsonInputConversionException("unsupported JSON integer representation");
        }
    }

    private static void streamBigInteger(BigInteger value, SliceOutput output)
    {
        if (value.bitLength() < Integer.SIZE) {
            JsonItemEncoding.appendInteger(output, value.longValue());
            return;
        }
        if (value.bitLength() < Long.SIZE) {
            JsonItemEncoding.appendBigint(output, value.longValue());
            return;
        }
        streamBigDecimal(new BigDecimal(value), output);
    }

    private static void streamFloat(JsonParser parser, SliceOutput output)
            throws IOException
    {
        // Mirror parseDecimal: canonicalize to BigDecimal so 1, 1.0, 1e0 all collapse to the
        // same stored value while preserving significant digits.
        streamBigDecimal(parser.getDecimalValue(), output);
    }

    private static void streamBigDecimal(BigDecimal value, SliceOutput output)
    {
        if (value.scale() < 0) {
            value = value.setScale(0);
        }
        int scale = value.scale();
        int precision = Math.max(value.precision(), scale);
        if (precision > MAX_PRECISION) {
            // Fall back to NUMBER for values that don't fit DECIMAL(<=38).
            byte[] unscaledBytes = value.unscaledValue().toByteArray();
            output.appendByte(JsonItemEncoding.ItemTag.TYPED_VALUE.encoded());
            output.appendByte(JsonItemEncoding.TypeTag.NUMBER.encoded());
            output.appendByte((byte) 0); // NUMBER_FINITE
            output.appendInt(value.scale());
            output.appendInt(unscaledBytes.length);
            output.writeBytes(unscaledBytes);
            return;
        }
        DecimalType type = createDecimalType(precision, scale);
        if (type.isShort()) {
            JsonItemEncoding.appendShortDecimal(output, precision, scale, encodeShortScaledValue(value, scale));
        }
        else {
            JsonItemEncoding.appendLongDecimal(output, precision, scale, encodeScaledValue(value, scale));
        }
    }

    private static final class PatchList
    {
        private int[] data = new int[16];
        private int size;

        void add(int offset, int count)
        {
            if (size + 2 > data.length) {
                data = Arrays.copyOf(data, data.length * 2);
            }
            data[size++] = offset;
            data[size++] = count;
        }

        void apply(Slice slice)
        {
            for (int i = 0; i < size; i += 2) {
                slice.setInt(data[i], data[i + 1]);
            }
        }
    }

    private static MaterializedJsonValue parseItem(JsonParser parser, JsonToken token, int depth)
            throws IOException
    {
        if (depth >= MAX_PARSE_DEPTH) {
            throw new JsonInputConversionException("JSON nesting exceeds maximum depth of " + MAX_PARSE_DEPTH);
        }
        if (token == JsonToken.VALUE_NULL) {
            return JsonNull.JSON_NULL;
        }
        if (token == JsonToken.START_ARRAY) {
            List<MaterializedJsonValue> elements = new ArrayList<>();
            for (JsonToken next = parser.nextToken(); next != JsonToken.END_ARRAY; next = parser.nextToken()) {
                if (next == null) {
                    throw new JsonInputConversionException("unexpected end of JSON array");
                }
                elements.add(parseItem(parser, next, depth + 1));
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
                members.add(new JsonObjectMember(fieldName, parseItem(parser, valueToken, depth + 1)));
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

    public static Slice jsonText(JsonPathItem item)
    {
        try {
            SliceOutput output = new DynamicSliceOutput(64);
            try (JsonGenerator generator = createJsonGenerator(JSON_MAPPER, output)) {
                writeJson(generator, item, false, 0);
            }
            return output.slice();
        }
        catch (IOException e) {
            throw new JsonOutputConversionException(e);
        }
    }

    public static Slice surrogateJsonText(JsonPathItem item)
    {
        requireNonNull(item, "item is null");

        try {
            SliceOutput output = new DynamicSliceOutput(64);
            try (JsonGenerator generator = createJsonGenerator(JSON_MAPPER, output)) {
                writeJson(generator, item, true, 0);
            }
            return output.slice();
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

    static void writeJson(JsonGenerator generator, JsonPathItem item, boolean stringifyUnsupportedScalars, int depth)
            throws IOException
    {
        if (depth >= MAX_PARSE_DEPTH) {
            throw new JsonOutputConversionException("JSON nesting exceeds maximum depth of " + MAX_PARSE_DEPTH);
        }
        Optional<JsonValueView> view = JsonValueView.fromObject(item);
        if (view.isPresent()) {
            view.get().writeJson(generator, stringifyUnsupportedScalars);
            return;
        }
        if (item instanceof EncodedJsonItem) {
            item = materialize(item);
        }
        if (item == JsonNull.JSON_NULL) {
            generator.writeNull();
            return;
        }
        if (item instanceof JsonObjectItem objectItem) {
            generator.writeStartObject();
            for (JsonObjectMember member : objectItem.members()) {
                generator.writeFieldName(member.key());
                writeJson(generator, member.value(), stringifyUnsupportedScalars, depth + 1);
            }
            generator.writeEndObject();
            return;
        }
        if (item instanceof JsonArrayItem arrayItem) {
            generator.writeStartArray();
            for (MaterializedJsonValue element : arrayItem.elements()) {
                writeJson(generator, element, stringifyUnsupportedScalars, depth + 1);
            }
            generator.writeEndArray();
            return;
        }
        if (item instanceof TypedValue typedValue) {
            writeTypedValue(generator, typedValue, stringifyUnsupportedScalars);
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
        return parseBigDecimal(new BigDecimal(value));
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

    private static void writeTypedValue(JsonGenerator generator, TypedValue typedValue, boolean stringifyUnsupportedScalars)
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
            case DoubleType _ -> {
                double d = typedValue.getDoubleValue();
                if (Double.isFinite(d)) {
                    generator.writeNumber(formatDouble(d));
                }
                else {
                    generator.writeString(Double.toString(d));
                }
            }
            case RealType _ -> {
                float f = intBitsToFloat(toIntExact(typedValue.getLongValue()));
                if (Float.isFinite(f)) {
                    // new BigDecimal(float) upcasts the float to double first, exposing the
                    // binary approximation (3.14f → "3.140000104904175"). Float.toString avoids
                    // that and produces the shortest decimal that round-trips through Float.
                    generator.writeNumber(Float.toString(f));
                }
                else {
                    generator.writeString(Float.toString(f));
                }
            }
            case NumberType _ -> {
                TrinoNumber number = (TrinoNumber) typedValue.getObjectValue();
                if (!(number.toBigDecimal() instanceof TrinoNumber.BigDecimalValue(BigDecimal value))) {
                    throw new JsonOutputConversionException("Non-finite NUMBER value cannot be serialized to JSON text: " + number);
                }
                // Use BigDecimal.toString() (not toPlainString) so values like 1E+309 keep
                // scientific notation rather than expanding to ~309 zero digits.
                generator.writeNumber(value.toString());
            }
            default -> {
                if (stringifyUnsupportedScalars) {
                    generator.writeString(typedValueText(typedValue));
                    return;
                }
                throw new JsonOutputConversionException("SQL/JSON value of type " + type.getDisplayName() + " cannot be serialized to JSON text");
            }
        }
    }

    // Format a finite DOUBLE for JSON output. Uses Double.toString for plain decimal forms
    // (preserving "2.0" / "3.14"), but rewrites scientific notation to BigDecimal style with
    // trailing zeros stripped ("1.0E308" → "1E+308") so the JSON text is canonical across
    // source types.
    static String formatDouble(double d)
    {
        String text = Double.toString(d);
        if (text.indexOf('E') < 0) {
            return text;
        }
        return BigDecimal.valueOf(d).stripTrailingZeros().toString();
    }
}
