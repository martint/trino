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
import io.trino.spi.type.Type;
import io.trino.spi.type.VarcharType;

import java.math.BigDecimal;
import java.math.BigInteger;
import java.util.ArrayList;
import java.util.List;
import java.util.Optional;

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
    private static final long HASH_JSON_NULL = 0x2f31d517a1ef3f69L;
    private static final long HASH_ARRAY = 0x76ac0743f1813a6bL;
    private static final long HASH_OBJECT = 0x0fbc1ac93d7d74d1L;
    private static final long HASH_STRING = 0x55f7d3fa17a2d42cL;
    private static final long HASH_BOOLEAN = 0x39fc4e4fa6b11d59L;
    private static final long HASH_NUMBER = 0x5f8e1d7c42b4c6a5L;
    private static final long HASH_OTHER_TYPED = 0x2cf56817e19c55bdL;

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
            List<JsonValue> leftElements = leftArray.elements();
            List<JsonValue> rightElements = rightArray.elements();
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
            for (JsonValue element : arrayItem.elements()) {
                hash = mix(hash, hash(element));
            }
            return mix(hash, arrayItem.elements().size());
        }
        if (item instanceof JsonObjectItem objectItem) {
            long sum = 0;
            long xor = 0;
            for (JsonObjectMember member : objectItem.members()) {
                long memberHash = mix(member.key().hashCode(), hash(member.value()));
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
            case OBJECT -> viewObjectEquals(objectMembers(left), objectMembers(right));
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

        boolean[] matched = new boolean[right.size()];
        for (JsonObjectMember leftMember : left) {
            boolean found = false;
            for (int i = 0; i < right.size(); i++) {
                if (matched[i]) {
                    continue;
                }
                JsonObjectMember rightMember = right.get(i);
                if (leftMember.key().equals(rightMember.key()) && equals(leftMember.value(), rightMember.value())) {
                    matched[i] = true;
                    found = true;
                    break;
                }
            }
            if (!found) {
                return false;
            }
        }
        return true;
    }

    private static boolean arrayEquals(JsonValueView left, JsonValueView right)
    {
        if (left.arraySize() != right.arraySize()) {
            return false;
        }

        List<JsonValueView> leftElements = new ArrayList<>(left.arraySize());
        left.forEachArrayElement(leftElements::add);

        List<JsonValueView> rightElements = new ArrayList<>(right.arraySize());
        right.forEachArrayElement(rightElements::add);

        for (int i = 0; i < leftElements.size(); i++) {
            if (!equals(leftElements.get(i), rightElements.get(i))) {
                return false;
            }
        }
        return true;
    }

    private static long arrayHash(JsonValueView array)
    {
        long hash = HASH_ARRAY;
        List<JsonValueView> elements = new ArrayList<>(array.arraySize());
        array.forEachArrayElement(elements::add);
        for (JsonValueView element : elements) {
            hash = mix(hash, hash(element));
        }
        return mix(hash, elements.size());
    }

    private static long objectHash(JsonValueView object)
    {
        long sum = 0;
        long xor = 0;
        List<ViewMember> members = objectMembers(object);
        for (ViewMember member : members) {
            long memberHash = mix(member.key().hashCode(), hash(member.value()));
            sum += memberHash;
            xor ^= Long.rotateLeft(memberHash, 17);
        }
        return mix(mix(HASH_OBJECT, members.size()), mix(sum, xor));
    }

    private static List<ViewMember> objectMembers(JsonValueView object)
    {
        List<ViewMember> members = new ArrayList<>();
        object.forEachObjectMember((key, value) -> members.add(new ViewMember(key, value)));
        return members;
    }

    private static boolean viewObjectEquals(List<ViewMember> left, List<ViewMember> right)
    {
        if (left.size() != right.size()) {
            return false;
        }

        boolean[] matched = new boolean[right.size()];
        for (ViewMember leftMember : left) {
            boolean found = false;
            for (int i = 0; i < right.size(); i++) {
                if (matched[i]) {
                    continue;
                }
                ViewMember rightMember = right.get(i);
                if (leftMember.key().equals(rightMember.key()) && equals(leftMember.value(), rightMember.value())) {
                    matched[i] = true;
                    found = true;
                    break;
                }
            }
            if (!found) {
                return false;
            }
        }
        return true;
    }

    private static boolean typedEquals(TypedValue left, TypedValue right)
    {
        if (isNumeric(left.getType()) && isNumeric(right.getType())) {
            BigDecimal leftNumber = asBigDecimal(left);
            BigDecimal rightNumber = asBigDecimal(right);
            if (leftNumber == null || rightNumber == null) {
                return left.equals(right);
            }
            return leftNumber.compareTo(rightNumber) == 0;
        }
        if (isString(left.getType()) && isString(right.getType())) {
            return scalarText(left).equals(scalarText(right));
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
                return mix(HASH_OTHER_TYPED, value.hashCode());
            }
            return mix(HASH_NUMBER, numericValue.stripTrailingZeros().hashCode());
        }
        if (isString(type)) {
            return mix(HASH_STRING, scalarText(value).hashCode());
        }
        if (type.equals(BOOLEAN)) {
            return mix(HASH_BOOLEAN, value.getBooleanValue() ? 1 : 0);
        }
        return mix(HASH_OTHER_TYPED, value.hashCode());
    }

    private static boolean isNumeric(Type type)
    {
        return type.equals(BIGINT) ||
                type.equals(INTEGER) ||
                type.equals(SMALLINT) ||
                type.equals(TINYINT) ||
                type.equals(DOUBLE) ||
                type.equals(REAL) ||
                type instanceof DecimalType;
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
        throw new IllegalArgumentException("Typed JSON item is not numeric: " + type);
    }

    private static long mix(long left, long right)
    {
        long hash = left ^ Long.rotateLeft(right, 23);
        hash *= 0x9e3779b97f4a7c15L;
        return hash;
    }

    private static Optional<JsonValueView> view(JsonPathItem item)
    {
        return JsonValueView.fromObject(item)
                .or(() -> {
                    if (item == JsonNull.JSON_NULL || item instanceof JsonValue) {
                        return Optional.of(JsonValueView.root(JsonItemEncoding.encode(item)));
                    }
                    return Optional.empty();
                });
    }

    private record ViewMember(String key, JsonValueView value) {}
}
