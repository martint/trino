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
import io.airlift.json.JsonMapperProvider;
import io.airlift.slice.DynamicSliceOutput;
import io.airlift.slice.Slice;
import io.airlift.slice.SliceOutput;
import io.trino.operator.scalar.json.JsonInputConversionException;
import io.trino.operator.scalar.json.JsonOutputConversionException;
import io.trino.operator.scalar.time.TimeOperators;
import io.trino.operator.scalar.timestamp.TimestampToVarcharCast;
import io.trino.operator.scalar.timestamptz.TimestampWithTimeZoneToVarcharCast;
import io.trino.operator.scalar.timetz.TimeWithTimeZoneToVarcharCast;
import io.trino.plugin.base.util.JsonUtils;
import io.trino.spi.type.BigintType;
import io.trino.spi.type.BooleanType;
import io.trino.spi.type.CharType;
import io.trino.spi.type.DateType;
import io.trino.spi.type.DecimalType;
import io.trino.spi.type.DoubleType;
import io.trino.spi.type.Int128;
import io.trino.spi.type.IntegerType;
import io.trino.spi.type.LongTimeWithTimeZone;
import io.trino.spi.type.LongTimestamp;
import io.trino.spi.type.LongTimestampWithTimeZone;
import io.trino.spi.type.NumberType;
import io.trino.spi.type.RealType;
import io.trino.spi.type.SmallintType;
import io.trino.spi.type.TimeType;
import io.trino.spi.type.TimeWithTimeZoneType;
import io.trino.spi.type.TimestampType;
import io.trino.spi.type.TimestampWithTimeZoneType;
import io.trino.spi.type.TinyintType;
import io.trino.spi.type.TrinoNumber;
import io.trino.spi.type.Type;
import io.trino.spi.type.VarcharType;
import io.trino.type.DateOperators;

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
import static io.trino.spi.type.VarcharType.VARCHAR;
import static io.trino.util.JsonUtil.createJsonGenerator;
import static java.lang.Float.intBitsToFloat;
import static java.lang.Math.toIntExact;
import static java.util.Objects.requireNonNull;

public final class JsonItems
{
    private static final JsonFactory JSON_FACTORY = jsonFactory();
    private static final JsonMapper JSON_MAPPER = new JsonMapperProvider(JsonUtils.jsonFactoryBuilder()
            // prevent characters outside the BMP (e.g. emoji) from being split into surrogate-pair escapes
            .enable(JsonWriteFeature.COMBINE_UNICODE_SURROGATES_IN_UTF8)
            .build())
            .get();

    private JsonItems() {}

    public static EncodedJsonItem encoded(JsonItem item)
    {
        requireNonNull(item, "item is null");
        if (item instanceof EncodedJsonItem encoded) {
            return encoded;
        }
        return new EncodedJsonItem(JsonItemEncoding.encode(item));
    }

    public static JsonItem materialize(JsonItem item)
    {
        requireNonNull(item, "item is null");
        return switch (item) {
            case JsonValueView view -> view.materialize();
            // Fast path: well-formed binary-encoded item. Detected by version byte so we don't
            // waste a full UTF-8 decode on the typical case.
            case EncodedJsonItem(Slice encoding) when JsonItemEncoding.isEncoding(encoding) ->
                    JsonItemEncoding.decode(encoding);
            // Legacy path: EncodedJsonItem may wrap raw JSON text (see
            // testMaterializeParsesLegacyTextualEncodedJsonItem). Parse it as JSON text.
            case EncodedJsonItem(Slice encoding) -> {
                try {
                    yield parseJson(new InputStreamReader(encoding.getInput(), StandardCharsets.UTF_8));
                }
                catch (IOException e) {
                    throw new JsonInputConversionException(e);
                }
            }
            default -> item;
        };
    }

    /// Returns the [JsonValue] form of `item`, materializing encoded representations as
    /// needed. Short-circuits when `item` is already a `JsonValue` or wraps a view, so
    /// well-formed inputs avoid unnecessary copying. Throws if `item` is not a value
    /// (i.e. it's a sentinel like [JsonInputError]).
    public static JsonValue asJsonValue(JsonItem item)
    {
        requireNonNull(item, "item is null");
        if (item instanceof JsonValue value) {
            return value;
        }
        Optional<JsonValueView> view = JsonValueView.fromItem(item);
        if (view.isPresent()) {
            return view.get().materializeValue();
        }
        if (materialize(item) instanceof JsonValue value) {
            return value;
        }
        throw new IllegalArgumentException("Expected JSON value, but got %s".formatted(item.getClass().getSimpleName()));
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
            JsonValue item = parseItem(parser, token, 0);
            if (parser.nextToken() != null) {
                throw new JsonInputConversionException("trailing data after JSON item");
            }
            return item;
        }
    }

    /// Parses the JSON value at the parser's current token into a [JsonValue]. The parser
    /// must be positioned at the first token of the value; on return, it is positioned at
    /// the last token of the value (matching Jackson's `JsonDeserializer.deserialize` contract).
    public static JsonValue parseValue(JsonParser parser)
            throws IOException
    {
        return parseItem(parser, parser.currentToken(), 0);
    }

    // Cap recursion against deeply nested JSON text input to avoid StackOverflowError.
    private static final int MAX_PARSE_DEPTH = 1000;

    /// Parses JSON text and emits the typed-item binary encoding directly, without
    /// materializing an intermediate [JsonValue] tree. ARRAY and OBJECT element counts
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
    /// [io.trino.type.JsonType] payload.
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
        // to ARRAY_INDEXED at INDEXED_CONTAINER_THRESHOLD). OBJECT_INDEXED requires a sorting
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

    private static JsonValue parseItem(JsonParser parser, JsonToken token, int depth)
            throws IOException
    {
        if (depth >= MAX_PARSE_DEPTH) {
            throw new JsonInputConversionException("JSON nesting exceeds maximum depth of " + MAX_PARSE_DEPTH);
        }
        return switch (token) {
            case VALUE_NULL -> JsonNull.JSON_NULL;
            case VALUE_TRUE -> new TypedValue(BOOLEAN, true);
            case VALUE_FALSE -> new TypedValue(BOOLEAN, false);
            case VALUE_STRING -> new TypedValue(VARCHAR, utf8Slice(parser.getText()));
            case VALUE_NUMBER_INT -> parseInteger(parser);
            case VALUE_NUMBER_FLOAT -> parseDecimal(parser);
            case START_ARRAY -> parseArray(parser, depth);
            case START_OBJECT -> parseObject(parser, depth);
            default -> throw new JsonInputConversionException("unexpected JSON token: " + token);
        };
    }

    private static JsonArray parseArray(JsonParser parser, int depth)
            throws IOException
    {
        List<JsonValue> elements = new ArrayList<>();
        for (JsonToken next = parser.nextToken(); next != JsonToken.END_ARRAY; next = parser.nextToken()) {
            if (next == null) {
                throw new JsonInputConversionException("unexpected end of JSON array");
            }
            elements.add(parseItem(parser, next, depth + 1));
        }
        return new JsonArray(elements);
    }

    private static JsonObject parseObject(JsonParser parser, int depth)
            throws IOException
    {
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
        return new JsonObject(members);
    }

    public static boolean canBeRepresentedAsJson(Type type)
    {
        return type instanceof BooleanType
                || type instanceof CharType
                || type instanceof VarcharType
                || type instanceof BigintType
                || type instanceof IntegerType
                || type instanceof SmallintType
                || type instanceof TinyintType
                || type instanceof DecimalType
                || type instanceof DoubleType
                || type instanceof RealType;
    }

    public static Slice jsonText(JsonItem item)
    {
        requireNonNull(item, "item is null");

        try {
            SliceOutput output = new DynamicSliceOutput(64);
            try (JsonGenerator generator = createJsonGenerator(JSON_MAPPER, output)) {
                writeJson(generator, item, 0);
            }
            return output.slice();
        }
        catch (IOException e) {
            throw new JsonOutputConversionException(e);
        }
    }

    public static Optional<Slice> scalarText(JsonItem item)
    {
        Optional<JsonValueView> view = JsonValueView.fromObject(item);
        if (view.isPresent()) {
            return view.get().scalarText();
        }
        return switch (materialize(item)) {
            case TypedValue(CharType type, Slice value) -> Optional.of(padSpaces(value, type));
            case TypedValue(VarcharType _, Slice value) -> Optional.of(value);
            default -> Optional.empty();
        };
    }

    /// Returns the canonical SQL CAST-to-VARCHAR text of a [TypedValue]. Used by
    /// [#writeJson] to render non-JSON-native scalars (datetime, timestamp-with-time-zone,
    /// etc.) as JSON strings.
    ///
    /// SQL:2023 §9.43 leaves the serialization shape implementation-dependent, but
    /// requires that re-parsing the result via §9.42 yields an SQL/JSON item equivalent
    /// to the original. §9.42 only produces null, boolean, number, string, array, and
    /// object — so a DATE rendered as `"1970-01-02"` parses back as a string, not a
    /// DATE. Trino accepts this asymmetry rather than raising
    /// `data exception — invalid JSON text (22032)` on every datetime in path output.
    static String typedValueText(TypedValue typedValue)
    {
        Type type = typedValue.getType();
        return switch (type) {
            case CharType _, VarcharType _ -> scalarText(typedValue)
                    .orElseThrow(() -> new IllegalArgumentException("Typed JSON item is not textual: " + type))
                    .toStringUtf8();
            case DateType _ -> DateOperators.castToVarchar(Integer.MAX_VALUE, typedValue.getLongValue()).toStringUtf8();
            case TimeType timeType -> TimeOperators.castToVarchar(Integer.MAX_VALUE, timeType.getPrecision(), typedValue.getLongValue()).toStringUtf8();
            case TimeWithTimeZoneType timeWithTimeZoneType -> {
                int precision = timeWithTimeZoneType.getPrecision();
                yield (timeWithTimeZoneType.isShort()
                        ? TimeWithTimeZoneToVarcharCast.cast(precision, typedValue.getLongValue())
                        : TimeWithTimeZoneToVarcharCast.cast(precision, (LongTimeWithTimeZone) typedValue.value()))
                        .toStringUtf8();
            }
            case TimestampType timestampType -> {
                int precision = timestampType.getPrecision();
                yield (timestampType.isShort()
                        ? TimestampToVarcharCast.cast(precision, typedValue.getLongValue())
                        : TimestampToVarcharCast.cast(precision, (LongTimestamp) typedValue.value()))
                        .toStringUtf8();
            }
            case TimestampWithTimeZoneType timestampWithTimeZoneType -> {
                int precision = timestampWithTimeZoneType.getPrecision();
                yield (timestampWithTimeZoneType.isShort()
                        ? TimestampWithTimeZoneToVarcharCast.cast(precision, typedValue.getLongValue())
                        : TimestampWithTimeZoneToVarcharCast.cast(precision, (LongTimestampWithTimeZone) typedValue.value()))
                        .toStringUtf8();
            }
            default -> throw new IllegalArgumentException("Unsupported type for JSON text rendering: " + type.getDisplayName());
        };
    }

    static void writeJson(JsonGenerator generator, JsonItem item, int depth)
            throws IOException
    {
        if (depth >= MAX_PARSE_DEPTH) {
            throw new JsonOutputConversionException("JSON nesting exceeds maximum depth of " + MAX_PARSE_DEPTH);
        }
        Optional<JsonValueView> view = JsonValueView.fromObject(item);
        if (view.isPresent()) {
            view.get().writeJson(generator);
            return;
        }
        if (item instanceof EncodedJsonItem) {
            item = materialize(item);
        }
        switch (item) {
            case JsonNull _ -> generator.writeNull();
            case JsonObject(List<JsonObjectMember> members) -> {
                generator.writeStartObject();
                for (JsonObjectMember member : members) {
                    generator.writeFieldName(member.key());
                    writeJson(generator, member.value(), depth + 1);
                }
                generator.writeEndObject();
            }
            case JsonArray(List<JsonValue> elements) -> {
                generator.writeStartArray();
                for (JsonValue element : elements) {
                    writeJson(generator, element, depth + 1);
                }
                generator.writeEndArray();
            }
            case TypedValue typedValue -> writeTypedValue(generator, typedValue);
            default -> throw new JsonOutputConversionException("unsupported SQL/JSON item type: " + item.getClass().getSimpleName());
        }
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
            case DoubleType _ -> {
                double value = typedValue.getDoubleValue();
                if (Double.isFinite(value)) {
                    generator.writeNumber(formatDouble(value));
                }
                else {
                    generator.writeString(Double.toString(value));
                }
            }
            case RealType _ -> {
                float value = intBitsToFloat(toIntExact(typedValue.getLongValue()));
                if (Float.isFinite(value)) {
                    // new BigDecimal(float) upcasts the float to double first, exposing the
                    // binary approximation (3.14f → "3.140000104904175"). Float.toString avoids
                    // that and produces the shortest decimal that round-trips through Float.
                    generator.writeNumber(Float.toString(value));
                }
                else {
                    generator.writeString(Float.toString(value));
                }
            }
            case NumberType _ -> {
                TrinoNumber number = (TrinoNumber) typedValue.getObjectValue();
                switch (number.toBigDecimal()) {
                    // Use BigDecimal.toString() (not toPlainString) so values like 1E+309 keep
                    // scientific notation rather than expanding to ~309 zero digits.
                    case TrinoNumber.BigDecimalValue(BigDecimal value) -> generator.writeNumber(value.toString());
                    case TrinoNumber.NotANumber _ -> generator.writeString("NaN");
                    case TrinoNumber.Infinity(boolean negative) -> generator.writeString(negative ? "-Infinity" : "+Infinity");
                }
            }
            default -> generator.writeString(typedValueText(typedValue));
        }
    }

    // Format a finite DOUBLE for JSON output. Uses Double.toString for plain decimal forms
    // (preserving "2.0" / "3.14"), but rewrites scientific notation to BigDecimal style with
    // trailing zeros stripped ("1.0E308" → "1E+308") so the JSON text is canonical across
    // source types.
    static String formatDouble(double value)
    {
        String text = Double.toString(value);
        if (text.indexOf('E') < 0) {
            return text;
        }
        return BigDecimal.valueOf(value).stripTrailingZeros().toString();
    }
}
