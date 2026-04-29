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
import io.trino.spi.type.CharType;
import io.trino.spi.type.DecimalType;
import io.trino.spi.type.Int128;
import io.trino.spi.type.NumberType;
import io.trino.spi.type.TrinoNumber;
import io.trino.spi.type.Type;
import io.trino.spi.type.VarcharType;

import java.math.BigDecimal;
import java.math.BigInteger;
import java.security.SecureRandom;
import java.util.ArrayDeque;
import java.util.ArrayList;
import java.util.Iterator;
import java.util.List;
import java.util.Optional;
import java.util.TreeMap;

import static io.trino.spi.type.BigintType.BIGINT;
import static io.trino.spi.type.BooleanType.BOOLEAN;
import static io.trino.spi.type.DoubleType.DOUBLE;
import static io.trino.spi.type.IntegerType.INTEGER;
import static io.trino.spi.type.RealType.REAL;
import static io.trino.spi.type.SmallintType.SMALLINT;
import static io.trino.spi.type.TinyintType.TINYINT;
import static java.lang.Float.intBitsToFloat;
import static java.lang.Math.toIntExact;

public final class JsonItemSemantics
{
    private static final long HASH_JSON_NULL = 0x2F31D517A1EF3F69L;
    private static final long HASH_ARRAY = 0x76AC0743F1813A6BL;
    private static final long HASH_OBJECT = 0x0FBC1AC93D7D74D1L;
    private static final long HASH_STRING = 0x55F7D3FA17A2D42CL;
    private static final long HASH_BOOLEAN = 0x39FC4E4FA6B11D59L;
    private static final long HASH_NUMBER = 0x5F8E1D7C42B4C6A5L;
    private static final long HASH_NUMBER_NAN = 0x1AF73BC1C99F9A5EL;
    private static final long HASH_NUMBER_POSITIVE_INFINITY = 0x6D38C05B30CD5D40L;
    private static final long HASH_NUMBER_NEGATIVE_INFINITY = 0x2A8FA4D5C56DC2D7L;
    private static final long HASH_OTHER_TYPED = 0x2CF56817E19C55BDL;

    // Per-process random salt: frustrates adversarial-key HashMap collisions.
    // Deliberately unpredictable across JVM instances.
    private static final long STRING_HASH_SALT = new SecureRandom().nextLong();

    private JsonItemSemantics() {}

    public static boolean equals(JsonPathItem left, JsonPathItem right)
    {
        if (left == right) {
            return true;
        }
        Optional<JsonValueView> leftView = view(left);
        Optional<JsonValueView> rightView = view(right);
        if (leftView.isPresent() && rightView.isPresent()) {
            return equals(leftView.get(), rightView.get());
        }
        if (left == JsonNull.JSON_NULL || right == JsonNull.JSON_NULL) {
            return left == JsonNull.JSON_NULL && right == JsonNull.JSON_NULL;
        }
        if (left instanceof JsonArrayItem leftArray && right instanceof JsonArrayItem rightArray) {
            List<MaterializedJsonValue> leftElements = leftArray.elements();
            List<MaterializedJsonValue> rightElements = rightArray.elements();
            if (leftElements.size() != rightElements.size()) {
                return false;
            }
            for (int i = 0; i < leftElements.size(); i++) {
                if (!equals(leftElements.get(i), rightElements.get(i))) {
                    return false;
                }
            }
            return true;
        }
        if (left instanceof JsonObjectItem leftObject && right instanceof JsonObjectItem rightObject) {
            return objectEquals(leftObject.members(), rightObject.members());
        }
        if (left instanceof TypedValue leftTyped && right instanceof TypedValue rightTyped) {
            return typedEquals(leftTyped, rightTyped);
        }
        return false;
    }

    public static long hash(JsonPathItem item)
    {
        Optional<JsonValueView> view = view(item);
        if (view.isPresent()) {
            return hash(view.get());
        }
        if (item == JsonNull.JSON_NULL) {
            return HASH_JSON_NULL;
        }
        if (item instanceof JsonArrayItem arrayItem) {
            long hash = HASH_ARRAY;
            for (MaterializedJsonValue element : arrayItem.elements()) {
                hash = mix(hash, hash(element));
            }
            return mix(hash, arrayItem.elements().size());
        }
        if (item instanceof JsonObjectItem objectItem) {
            long sum = 0;
            long xor = 0;
            for (JsonObjectMember member : objectItem.members()) {
                long memberHash = mix(saltedStringHash(member.key()), hash(member.value()));
                sum += memberHash;
                xor ^= Long.rotateLeft(memberHash, 17);
            }
            return mix(mix(HASH_OBJECT, objectItem.members().size()), mix(sum, xor));
        }
        if (item instanceof TypedValue typedValue) {
            return typedHash(typedValue);
        }
        throw new IllegalArgumentException("Unsupported SQL/JSON item: " + item.getClass().getSimpleName());
    }

    public static boolean equals(JsonValueView left, JsonValueView right)
    {
        if (left == right) {
            return true;
        }
        if (left.kind() != right.kind()) {
            if (left.isTypedValue() && right.isTypedValue()) {
                return typedEquals(left.typedValue(), right.typedValue());
            }
            return false;
        }

        return switch (left.kind()) {
            case JSON_ERROR -> false;
            case NULL -> true;
            case ARRAY -> arrayEquals(left, right);
            case OBJECT -> viewObjectEquals(left, right);
            case TYPED_VALUE -> typedEquals(left.typedValue(), right.typedValue());
        };
    }

    public static long hash(JsonValueView value)
    {
        return switch (value.kind()) {
            case JSON_ERROR -> throw new IllegalArgumentException("Unsupported SQL/JSON item: JSON error");
            case NULL -> HASH_JSON_NULL;
            case ARRAY -> arrayHash(value);
            case OBJECT -> objectHash(value);
            case TYPED_VALUE -> typedHash(value.typedValue());
        };
    }

    private static boolean objectEquals(List<JsonObjectMember> left, List<JsonObjectMember> right)
    {
        if (left.size() != right.size()) {
            return false;
        }

        // Use TreeMap (O(log n) lookup with String.compareTo ordering) rather than HashMap.
        // HashMap is vulnerable to adversarial-key collision attacks via Java's well-known
        // String.hashCode(). TreeMap is key-ordering-based and immune.
        TreeMap<String, ArrayDeque<MaterializedJsonValue>> leftByKey = new TreeMap<>();
        for (JsonObjectMember leftMember : left) {
            leftByKey.computeIfAbsent(leftMember.key(), _ -> new ArrayDeque<>())
                    .add(leftMember.value());
        }
        for (JsonObjectMember rightMember : right) {
            ArrayDeque<MaterializedJsonValue> bucket = leftByKey.get(rightMember.key());
            if (bucket == null) {
                return false;
            }
            // Match against the first bucket element; if values are unequal, fall back to
            // multiset matching to tolerate duplicate keys mapping to different values.
            Iterator<MaterializedJsonValue> iter = bucket.iterator();
            boolean matched = false;
            while (iter.hasNext()) {
                if (equals(iter.next(), rightMember.value())) {
                    iter.remove();
                    matched = true;
                    break;
                }
            }
            if (!matched) {
                return false;
            }
            if (bucket.isEmpty()) {
                leftByKey.remove(rightMember.key());
            }
        }
        return leftByKey.isEmpty();
    }

    private static boolean arrayEquals(JsonValueView left, JsonValueView right)
    {
        if (left.arraySize() != right.arraySize()) {
            return false;
        }
        // Short-circuit on first mismatch via parallel traversal; materializing both sides
        // would waste allocations on early-mismatch inputs.
        ArrayList<JsonValueView> leftElements = new ArrayList<>(left.arraySize());
        left.forEachArrayElement(leftElements::add);
        int[] index = {0};
        boolean[] equal = {true};
        right.forEachArrayElement(rightElement -> {
            if (equal[0] && !equals(leftElements.get(index[0]++), rightElement)) {
                equal[0] = false;
            }
        });
        return equal[0];
    }

    private static long arrayHash(JsonValueView array)
    {
        long hash = HASH_ARRAY;
        long[] count = {0};
        long[] running = {hash};
        array.forEachArrayElement(element -> {
            running[0] = mix(running[0], hash(element));
            count[0]++;
        });
        return mix(running[0], count[0]);
    }

    private static long objectHash(JsonValueView object)
    {
        long[] sum = {0};
        long[] xor = {0};
        long[] count = {0};
        object.forEachObjectMember((key, value) -> {
            long memberHash = mix(saltedStringHash(key), hash(value));
            sum[0] += memberHash;
            xor[0] ^= Long.rotateLeft(memberHash, 17);
            count[0]++;
        });
        return mix(mix(HASH_OBJECT, count[0]), mix(sum[0], xor[0]));
    }

    private static boolean viewObjectEquals(JsonValueView left, JsonValueView right)
    {
        TreeMap<String, ArrayDeque<JsonValueView>> leftByKey = new TreeMap<>();
        left.forEachObjectMember((key, value) ->
                leftByKey.computeIfAbsent(key, _ -> new ArrayDeque<>()).add(value));

        boolean[] equal = {true};
        int[] matchedCount = {0};
        right.forEachObjectMember((key, rightValue) -> {
            if (!equal[0]) {
                return;
            }
            ArrayDeque<JsonValueView> bucket = leftByKey.get(key);
            if (bucket == null) {
                equal[0] = false;
                return;
            }
            Iterator<JsonValueView> iter = bucket.iterator();
            boolean matched = false;
            while (iter.hasNext()) {
                if (equals(iter.next(), rightValue)) {
                    iter.remove();
                    matched = true;
                    matchedCount[0]++;
                    break;
                }
            }
            if (!matched) {
                equal[0] = false;
                return;
            }
            if (bucket.isEmpty()) {
                leftByKey.remove(key);
            }
        });
        return equal[0] && leftByKey.isEmpty();
    }

    private static boolean typedEquals(TypedValue left, TypedValue right)
    {
        if (isNumeric(left.getType()) && isNumeric(right.getType())) {
            // Per SQL:2023 §8.2 GR 10, SQL/JSON scalar numbers compare by SQL number
            // rules across types. Canonicalize both sides through stripTrailingZeros
            // for equals/hash consistency; compareTo alone would diverge from
            // stripTrailingZeros().hashCode().
            BigDecimal leftNumber = asBigDecimal(left);
            BigDecimal rightNumber = asBigDecimal(right);
            if (leftNumber == null || rightNumber == null) {
                // Non-finite numbers (NaN, +/-Infinity): compare by kind only so that
                // REAL and DOUBLE representations of the same non-finite value compare
                // equal. Two NaNs compare equal here, matching Trino's general convention
                // for DOUBLE/REAL hashing and bucketing (and diverging from the SQL
                // numeric rule where NaN != NaN); the release notes call this out.
                return nonFiniteKind(left) == nonFiniteKind(right);
            }
            return leftNumber.compareTo(rightNumber) == 0;
        }
        if (isString(left.getType()) && isString(right.getType())) {
            // Per SQL:2023 §8.2 GR 10 with PAD SPACE collation (the default for SQL/JSON
            // character-string items), trailing spaces are not significant for equality.
            // Strip them so CHAR(n) and VARCHAR values with the same non-trailing content
            // compare equal regardless of storage width.
            return trimTrailingSpaces(scalarText(left)).equals(trimTrailingSpaces(scalarText(right)));
        }
        if (left.getType().equals(BOOLEAN) && right.getType().equals(BOOLEAN)) {
            return left.getBooleanValue() == right.getBooleanValue();
        }
        return left.equals(right);
    }

    private static long typedHash(TypedValue value)
    {
        Type type = value.getType();
        if (isNumeric(type)) {
            BigDecimal numericValue = asBigDecimal(value);
            if (numericValue == null) {
                // Non-finite: hash only by kind so REAL +Inf and DOUBLE +Inf (which typedEquals
                // treats as equal) land in the same bucket. Two NaNs hash identically.
                return nonFiniteKindHash(value);
            }
            return mix(HASH_NUMBER, numericValue.stripTrailingZeros().hashCode());
        }
        if (isString(type)) {
            // Hash the trimmed text so PAD-SPACE-equal values (CHAR vs VARCHAR, CHAR(n) vs
            // CHAR(m)) bucket together — consistent with typedEquals.
            return mix(HASH_STRING, saltedStringHash(trimTrailingSpaces(scalarText(value)).toStringUtf8()));
        }
        if (type.equals(BOOLEAN)) {
            return mix(HASH_BOOLEAN, value.getBooleanValue() ? 1 : 0);
        }
        return mix(HASH_OTHER_TYPED, value.hashCode());
    }

    private static int nonFiniteKind(TypedValue value)
    {
        Type type = value.getType();
        if (type.equals(DOUBLE)) {
            double d = value.getDoubleValue();
            if (Double.isNaN(d)) {
                return 1;
            }
            if (d == Double.POSITIVE_INFINITY) {
                return 2;
            }
            if (d == Double.NEGATIVE_INFINITY) {
                return 3;
            }
        }
        if (type.equals(REAL)) {
            float f = intBitsToFloat(toIntExact(value.getLongValue()));
            if (Float.isNaN(f)) {
                return 1;
            }
            if (f == Float.POSITIVE_INFINITY) {
                return 2;
            }
            if (f == Float.NEGATIVE_INFINITY) {
                return 3;
            }
        }
        if (type instanceof NumberType) {
            TrinoNumber number = (TrinoNumber) value.getObjectValue();
            return switch (number.toBigDecimal()) {
                case TrinoNumber.NotANumber _ -> 1;
                case TrinoNumber.Infinity(boolean negative) -> negative ? 3 : 2;
                case TrinoNumber.BigDecimalValue _ -> 0;
            };
        }
        return 0;
    }

    private static long nonFiniteKindHash(TypedValue value)
    {
        return switch (nonFiniteKind(value)) {
            case 1 -> HASH_NUMBER_NAN;
            case 2 -> HASH_NUMBER_POSITIVE_INFINITY;
            case 3 -> HASH_NUMBER_NEGATIVE_INFINITY;
            default -> HASH_OTHER_TYPED;
        };
    }

    private static boolean isNumeric(Type type)
    {
        return type.equals(BIGINT) ||
                type.equals(INTEGER) ||
                type.equals(SMALLINT) ||
                type.equals(TINYINT) ||
                type.equals(DOUBLE) ||
                type.equals(REAL) ||
                type instanceof DecimalType ||
                type instanceof NumberType;
    }

    private static boolean isString(Type type)
    {
        return type instanceof VarcharType || type instanceof CharType;
    }

    private static Slice scalarText(TypedValue value)
    {
        return JsonItems.scalarText(value)
                .orElseThrow(() -> new IllegalArgumentException("Typed JSON item is not a string: " + value.getType()));
    }

    private static Slice trimTrailingSpaces(Slice value)
    {
        int length = value.length();
        while (length > 0 && value.getByte(length - 1) == ' ') {
            length--;
        }
        return length == value.length() ? value : value.slice(0, length);
    }

    private static BigDecimal asBigDecimal(TypedValue value)
    {
        Type type = value.getType();
        if (type.equals(BIGINT) || type.equals(INTEGER) || type.equals(SMALLINT) || type.equals(TINYINT)) {
            return BigDecimal.valueOf(value.getLongValue());
        }
        if (type instanceof DecimalType decimalType) {
            BigInteger unscaledValue = decimalType.isShort() ?
                    BigInteger.valueOf(value.getLongValue()) :
                    ((Int128) value.getObjectValue()).toBigInteger();
            return new BigDecimal(unscaledValue, decimalType.getScale());
        }
        if (type.equals(DOUBLE)) {
            double number = value.getDoubleValue();
            if (!Double.isFinite(number)) {
                return null;
            }
            return BigDecimal.valueOf(number);
        }
        if (type.equals(REAL)) {
            float number = intBitsToFloat(toIntExact(value.getLongValue()));
            if (!Float.isFinite(number)) {
                return null;
            }
            return BigDecimal.valueOf(number);
        }
        if (type instanceof NumberType) {
            TrinoNumber number = (TrinoNumber) value.getObjectValue();
            if (number.toBigDecimal() instanceof TrinoNumber.BigDecimalValue(BigDecimal decimal)) {
                return decimal;
            }
            return null;
        }
        throw new IllegalArgumentException("Typed JSON item is not numeric: " + type);
    }

    private static long saltedStringHash(String value)
    {
        // FNV-1a-style mix seeded with the per-process salt. Enough to make HashMap-based
        // collision attacks impractical across process restarts; not cryptographic.
        long h = STRING_HASH_SALT ^ 0xCBF29CE484222325L;
        int length = value.length();
        for (int i = 0; i < length; i++) {
            h ^= value.charAt(i);
            h *= 0x100000001B3L;
        }
        return h;
    }

    private static long mix(long left, long right)
    {
        long hash = left ^ Long.rotateLeft(right, 23);
        hash *= 0x9E3779B97F4A7C15L;
        return hash;
    }

    private static Optional<JsonValueView> view(JsonPathItem item)
    {
        return JsonValueView.fromObject(item)
                .or(() -> {
                    if (item == JsonNull.JSON_NULL || item instanceof MaterializedJsonValue) {
                        return Optional.of(JsonValueView.root(JsonItemEncoding.encode(item)));
                    }
                    return Optional.empty();
                });
    }
}
