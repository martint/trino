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

import com.google.common.collect.ImmutableList;
import com.google.common.collect.Iterables;
import io.airlift.slice.Slice;
import io.trino.json.CachingResolver.ResolvedOperatorAndCoercions;
import io.trino.json.JsonPathEvaluator.Invoker;
import io.trino.json.ir.IrAbsMethod;
import io.trino.json.ir.IrArithmeticBinary;
import io.trino.json.ir.IrArithmeticUnary;
import io.trino.json.ir.IrArrayAccessor;
import io.trino.json.ir.IrCeilingMethod;
import io.trino.json.ir.IrConstantJsonSequence;
import io.trino.json.ir.IrContextVariable;
import io.trino.json.ir.IrDatetimeMethod;
import io.trino.json.ir.IrDescendantMemberAccessor;
import io.trino.json.ir.IrDoubleMethod;
import io.trino.json.ir.IrFilter;
import io.trino.json.ir.IrFloorMethod;
import io.trino.json.ir.IrJsonNull;
import io.trino.json.ir.IrJsonPathVisitor;
import io.trino.json.ir.IrKeyValueMethod;
import io.trino.json.ir.IrLastIndexVariable;
import io.trino.json.ir.IrLiteral;
import io.trino.json.ir.IrMemberAccessor;
import io.trino.json.ir.IrNamedJsonVariable;
import io.trino.json.ir.IrNamedValueVariable;
import io.trino.json.ir.IrPathNode;
import io.trino.json.ir.IrPredicateCurrentItemVariable;
import io.trino.json.ir.IrSizeMethod;
import io.trino.json.ir.IrTypeMethod;
import io.trino.json.ir.TypedValue;
import io.trino.spi.function.OperatorType;
import io.trino.spi.type.CharType;
import io.trino.spi.type.DecimalConversions;
import io.trino.spi.type.DecimalType;
import io.trino.spi.type.Int128;
import io.trino.spi.type.Int128Math;
import io.trino.spi.type.TimeType;
import io.trino.spi.type.TimeWithTimeZoneType;
import io.trino.spi.type.TimestampType;
import io.trino.spi.type.TimestampWithTimeZoneType;
import io.trino.spi.type.Type;
import io.trino.spi.type.VarcharType;
import io.trino.type.BigintOperators;
import io.trino.type.DecimalCasts;
import io.trino.type.DecimalOperators;
import io.trino.type.DoubleOperators;
import io.trino.type.IntegerOperators;
import io.trino.type.RealOperators;
import io.trino.type.SmallintOperators;
import io.trino.type.TinyintOperators;
import io.trino.type.VarcharOperators;

import java.util.List;
import java.util.Optional;

import static com.google.common.base.Preconditions.checkState;
import static com.google.common.collect.ImmutableList.toImmutableList;
import static com.google.common.collect.Iterables.getOnlyElement;
import static io.airlift.slice.Slices.utf8Slice;
import static io.trino.json.CachingResolver.ResolvedOperatorAndCoercions.RESOLUTION_ERROR;
import static io.trino.json.JsonEmptySequenceNode.EMPTY_SEQUENCE;
import static io.trino.json.PathEvaluationException.itemTypeError;
import static io.trino.json.PathEvaluationException.structuralError;
import static io.trino.json.PathEvaluationUtil.normalize;
import static io.trino.json.PathEvaluationUtil.unwrapArrays;
import static io.trino.json.ir.IrArithmeticUnary.Sign.PLUS;
import static io.trino.operator.scalar.MathFunctions.Ceiling.ceilingLong;
import static io.trino.operator.scalar.MathFunctions.Ceiling.ceilingLongShort;
import static io.trino.operator.scalar.MathFunctions.Ceiling.ceilingShort;
import static io.trino.operator.scalar.MathFunctions.Floor.floorLong;
import static io.trino.operator.scalar.MathFunctions.Floor.floorLongShort;
import static io.trino.operator.scalar.MathFunctions.Floor.floorShort;
import static io.trino.operator.scalar.MathFunctions.abs;
import static io.trino.operator.scalar.MathFunctions.absInteger;
import static io.trino.operator.scalar.MathFunctions.absSmallint;
import static io.trino.operator.scalar.MathFunctions.absTinyint;
import static io.trino.operator.scalar.MathFunctions.ceilingReal;
import static io.trino.operator.scalar.MathFunctions.floorReal;
import static io.trino.spi.type.BigintType.BIGINT;
import static io.trino.spi.type.BooleanType.BOOLEAN;
import static io.trino.spi.type.Chars.padSpaces;
import static io.trino.spi.type.DateType.DATE;
import static io.trino.spi.type.Decimals.longTenToNth;
import static io.trino.spi.type.DoubleType.DOUBLE;
import static io.trino.spi.type.IntegerType.INTEGER;
import static io.trino.spi.type.RealType.REAL;
import static io.trino.spi.type.SmallintType.SMALLINT;
import static io.trino.spi.type.TimeType.createTimeType;
import static io.trino.spi.type.TimeWithTimeZoneType.createTimeWithTimeZoneType;
import static io.trino.spi.type.TimestampType.createTimestampType;
import static io.trino.spi.type.TimestampWithTimeZoneType.createTimestampWithTimeZoneType;
import static io.trino.spi.type.TinyintType.TINYINT;
import static io.trino.spi.type.VarcharType.VARCHAR;
import static io.trino.type.DateTimes.extractTimePrecision;
import static io.trino.type.DateTimes.extractTimestampPrecision;
import static io.trino.type.DateTimes.parseTime;
import static io.trino.type.DateTimes.parseTimeWithTimeZone;
import static io.trino.type.DateTimes.parseTimestamp;
import static io.trino.type.DateTimes.parseTimestampWithTimeZone;
import static io.trino.type.DateTimes.timeHasTimeZone;
import static io.trino.type.DateTimes.timestampHasTimeZone;
import static io.trino.type.DecimalCasts.longDecimalToDouble;
import static io.trino.type.DecimalCasts.shortDecimalToDouble;
import static io.trino.util.DateTimeUtils.parseDate;
import static java.lang.Float.floatToRawIntBits;
import static java.lang.Float.intBitsToFloat;
import static java.lang.String.format;
import static java.util.Objects.requireNonNull;

class PathEvaluationVisitor
        extends IrJsonPathVisitor<List<JsonPathItem>, PathEvaluationContext>
{
    private final boolean lax;
    private final JsonPathItem input;
    private final JsonPathItem[] parameters;
    private final PathPredicateEvaluationVisitor predicateVisitor;
    private final Invoker invoker;
    private final CachingResolver resolver;
    private int objectId;

    public PathEvaluationVisitor(boolean lax, JsonPathItem input, JsonPathItem[] parameters, Invoker invoker, CachingResolver resolver)
    {
        this.lax = lax;
        this.input = requireNonNull(input, "input is null");
        this.parameters = requireNonNull(parameters, "parameters is null");
        this.invoker = requireNonNull(invoker, "invoker is null");
        this.resolver = requireNonNull(resolver, "resolver is null");
        this.predicateVisitor = new PathPredicateEvaluationVisitor(lax, this, invoker, resolver);
    }

    @Override
    protected List<JsonPathItem> visitIrPathNode(IrPathNode node, PathEvaluationContext context)
    {
        throw new UnsupportedOperationException("JSON path evaluating visitor not implemented for " + node.getClass().getSimpleName());
    }

    @Override
    protected List<JsonPathItem> visitIrAbsMethod(IrAbsMethod node, PathEvaluationContext context)
    {
        List<JsonPathItem> sequence = process(node.base(), context);

        if (lax) {
            sequence = unwrapArrays(sequence);
        }

        ImmutableList.Builder<JsonPathItem> outputSequence = ImmutableList.builder();
        for (JsonPathItem object : sequence) {
            TypedValue value = getNumericTypedValue(object);
            outputSequence.add(getAbsoluteValue(value));
        }

        return outputSequence.build();
    }

    private static TypedValue getAbsoluteValue(TypedValue typedValue)
    {
        Type type = typedValue.getType();

        if (type.equals(BIGINT)) {
            long value = typedValue.getLongValue();
            if (value >= 0) {
                return typedValue;
            }
            long absValue;
            try {
                absValue = abs(value);
            }
            catch (Exception e) {
                throw new PathEvaluationException(e);
            }
            return new TypedValue(type, absValue);
        }
        if (type.equals(INTEGER)) {
            long value = typedValue.getLongValue();
            if (value >= 0) {
                return typedValue;
            }
            long absValue;
            try {
                absValue = absInteger(value);
            }
            catch (Exception e) {
                throw new PathEvaluationException(e);
            }
            return new TypedValue(type, absValue);
        }
        if (type.equals(SMALLINT)) {
            long value = typedValue.getLongValue();
            if (value >= 0) {
                return typedValue;
            }
            long absValue;
            try {
                absValue = absSmallint(value);
            }
            catch (Exception e) {
                throw new PathEvaluationException(e);
            }
            return new TypedValue(type, absValue);
        }
        if (type.equals(TINYINT)) {
            long value = typedValue.getLongValue();
            if (value >= 0) {
                return typedValue;
            }
            long absValue;
            try {
                absValue = absTinyint(value);
            }
            catch (Exception e) {
                throw new PathEvaluationException(e);
            }
            return new TypedValue(type, absValue);
        }
        if (type.equals(DOUBLE)) {
            double value = typedValue.getDoubleValue();
            if (value >= 0) {
                return typedValue;
            }
            return new TypedValue(type, abs(value));
        }
        if (type.equals(REAL)) {
            float value = intBitsToFloat((int) typedValue.getLongValue());
            if (value > 0) {
                return typedValue;
            }
            return new TypedValue(type, floatToRawIntBits(Math.abs(value)));
        }
        if (type instanceof DecimalType decimalType) {
            if (decimalType.isShort()) {
                long value = typedValue.getLongValue();
                if (value > 0) {
                    return typedValue;
                }
                return new TypedValue(type, -value);
            }
            Int128 value = (Int128) typedValue.getObjectValue();
            if (value.isNegative()) {
                Int128 result;
                try {
                    result = DecimalOperators.Negation.negate((Int128) typedValue.getObjectValue());
                }
                catch (Exception e) {
                    throw new PathEvaluationException(e);
                }
                return new TypedValue(type, result);
            }
            return typedValue;
        }

        throw itemTypeError("NUMBER", type.getDisplayName());
    }

    @Override
    protected List<JsonPathItem> visitIrArithmeticBinary(IrArithmeticBinary node, PathEvaluationContext context)
    {
        List<JsonPathItem> leftSequence = process(node.left(), context);
        List<JsonPathItem> rightSequence = process(node.right(), context);

        if (lax) {
            leftSequence = unwrapArrays(leftSequence);
            rightSequence = unwrapArrays(rightSequence);
        }

        if (leftSequence.size() != 1 || rightSequence.size() != 1) {
            throw new PathEvaluationException("arithmetic binary expression requires singleton operands");
        }

        JsonPathItem leftObject = getOnlyElement(leftSequence);
        TypedValue left = getTypedValue(leftObject);

        JsonPathItem rightObject = getOnlyElement(rightSequence);
        TypedValue right = getTypedValue(rightObject);

        ResolvedOperatorAndCoercions operators = resolver.getOperators(node, OperatorType.valueOf(node.operator().name()), left.getType(), right.getType());
        if (operators == RESOLUTION_ERROR) {
            throw new PathEvaluationException(format("invalid operand types to %s operator (%s, %s)", node.operator().name(), left.getType(), right.getType()));
        }

        Object leftInput = left.value();
        if (operators.getLeftCoercion().isPresent()) {
            try {
                leftInput = invoker.invoke(operators.getLeftCoercion().get(), ImmutableList.of(leftInput));
            }
            catch (RuntimeException e) {
                throw new PathEvaluationException(e);
            }
        }

        Object rightInput = right.value();
        if (operators.getRightCoercion().isPresent()) {
            try {
                rightInput = invoker.invoke(operators.getRightCoercion().get(), ImmutableList.of(rightInput));
            }
            catch (RuntimeException e) {
                throw new PathEvaluationException(e);
            }
        }

        Object result;
        try {
            result = invoker.invoke(operators.getOperator(), ImmutableList.of(leftInput, rightInput));
        }
        catch (RuntimeException e) {
            throw new PathEvaluationException(e);
        }

        return ImmutableList.of(TypedValue.fromValueAsObject(operators.getOperator().signature().getReturnType(), result));
    }

    @Override
    protected List<JsonPathItem> visitIrArithmeticUnary(IrArithmeticUnary node, PathEvaluationContext context)
    {
        List<JsonPathItem> sequence = process(node.base(), context);

        if (lax) {
            sequence = unwrapArrays(sequence);
        }

        ImmutableList.Builder<JsonPathItem> outputSequence = ImmutableList.builder();
        for (JsonPathItem object : sequence) {
            TypedValue value = getNumericTypedValue(object);
            if (node.sign() == PLUS) {
                outputSequence.add(value);
            }
            else {
                outputSequence.add(negate(value));
            }
        }

        return outputSequence.build();
    }

    private static TypedValue negate(TypedValue typedValue)
    {
        Type type = typedValue.getType();

        if (type.equals(BIGINT)) {
            long negatedValue;
            try {
                negatedValue = BigintOperators.negate(typedValue.getLongValue());
            }
            catch (Exception e) {
                throw new PathEvaluationException(e);
            }
            return new TypedValue(type, negatedValue);
        }
        if (type.equals(INTEGER)) {
            long negatedValue;
            try {
                negatedValue = IntegerOperators.negate(typedValue.getLongValue());
            }
            catch (Exception e) {
                throw new PathEvaluationException(e);
            }
            return new TypedValue(type, negatedValue);
        }
        if (type.equals(SMALLINT)) {
            long negatedValue;
            try {
                negatedValue = SmallintOperators.negate(typedValue.getLongValue());
            }
            catch (Exception e) {
                throw new PathEvaluationException(e);
            }
            return new TypedValue(type, negatedValue);
        }
        if (type.equals(TINYINT)) {
            long negatedValue;
            try {
                negatedValue = TinyintOperators.negate(typedValue.getLongValue());
            }
            catch (Exception e) {
                throw new PathEvaluationException(e);
            }
            return new TypedValue(type, negatedValue);
        }
        if (type.equals(DOUBLE)) {
            return new TypedValue(type, -typedValue.getDoubleValue());
        }
        if (type.equals(REAL)) {
            return new TypedValue(type, RealOperators.negate(typedValue.getLongValue()));
        }
        if (type instanceof DecimalType decimalType) {
            if (decimalType.isShort()) {
                return new TypedValue(type, -typedValue.getLongValue());
            }
            Int128 negatedValue;
            try {
                negatedValue = DecimalOperators.Negation.negate((Int128) typedValue.getObjectValue());
            }
            catch (Exception e) {
                throw new PathEvaluationException(e);
            }
            return new TypedValue(type, negatedValue);
        }

        throw new IllegalStateException("unexpected type" + type.getDisplayName());
    }

    @Override
    protected List<JsonPathItem> visitIrArrayAccessor(IrArrayAccessor node, PathEvaluationContext context)
    {
        List<JsonPathItem> sequence = process(node.base(), context);

        ImmutableList.Builder<JsonPathItem> outputSequence = ImmutableList.builder();
        for (JsonPathItem object : sequence) {
            object = normalize(object);
            List<JsonPathItem> elements;
            Optional<JsonValueView> view = JsonValueView.fromObject(object);
            if (view.isPresent() && view.orElseThrow().isArray()) {
                ImmutableList.Builder<JsonPathItem> elementsBuilder = ImmutableList.builder();
                view.orElseThrow().forEachArrayElement(elementsBuilder::add);
                elements = elementsBuilder.build();
            }
            else if (object instanceof JsonArrayItem arrayItem) {
                elements = arrayItem.elements().stream().map(JsonPathItem.class::cast).collect(toImmutableList());
            }
            else if (lax) {
                elements = ImmutableList.of(object);
            }
            else {
                throw itemTypeError("ARRAY", itemTypeName(object));
            }

            // handle wildcard accessor
            if (node.subscripts().isEmpty()) {
                outputSequence.addAll(elements);
                continue;
            }

            if (elements.isEmpty()) {
                if (!lax) {
                    throw structuralError("invalid array subscript for empty array");
                }
                // for lax mode, the result is empty sequence
                continue;
            }

            PathEvaluationContext arrayContext = context.withLast(elements.size() - 1);
            for (IrArrayAccessor.Subscript subscript : node.subscripts()) {
                List<JsonPathItem> from = process(subscript.from(), arrayContext);
                Optional<List<JsonPathItem>> to = subscript.to().map(path -> process(path, arrayContext));
                if (from.size() != 1) {
                    throw new PathEvaluationException("array subscript 'from' value must be singleton numeric");
                }
                if (to.isPresent() && to.get().size() != 1) {
                    throw new PathEvaluationException("array subscript 'to' value must be singleton numeric");
                }
                long fromIndex = asArrayIndex(getOnlyElement(from));
                long toIndex = to
                        .map(Iterables::getOnlyElement)
                        .map(PathEvaluationVisitor::asArrayIndex)
                        .orElse(fromIndex);

                if (!lax && (fromIndex < 0 || fromIndex >= elements.size() || toIndex < 0 || toIndex >= elements.size() || fromIndex > toIndex)) {
                    throw structuralError("invalid array subscript: [%s, %s] for array of size %s", fromIndex, toIndex, elements.size());
                }

                if (fromIndex <= toIndex) {
                    long start = Math.max(fromIndex, 0L);
                    long end = Math.min(toIndex, elements.size() - 1L);
                    for (long i = start; i <= end; i++) {
                        outputSequence.add(elements.get((int) i));
                    }
                }
            }
        }

        return outputSequence.build();
    }

    private static long asArrayIndex(JsonPathItem object)
    {
        TypedValue value = getNumericTypedValue(object);
        Type type = value.getType();
        if (type.equals(BIGINT) || type.equals(INTEGER) || type.equals(SMALLINT) || type.equals(TINYINT)) {
            return value.getLongValue();
        }
        if (type.equals(DOUBLE)) {
            try {
                return DoubleOperators.castToLong(value.getDoubleValue());
            }
            catch (Exception e) {
                throw new PathEvaluationException(e);
            }
        }
        if (type.equals(REAL)) {
            try {
                return RealOperators.castToLong(value.getLongValue());
            }
            catch (Exception e) {
                throw new PathEvaluationException(e);
            }
        }
        if (type instanceof DecimalType decimalType) {
            int precision = decimalType.getPrecision();
            int scale = decimalType.getScale();
            if (decimalType.isShort()) {
                long tenToScale = longTenToNth(DecimalConversions.intScale(scale));
                return DecimalCasts.shortDecimalToBigint(value.getLongValue(), precision, scale, tenToScale);
            }
            Int128 tenToScale = Int128Math.powerOfTen(DecimalConversions.intScale(scale));
            try {
                return DecimalCasts.longDecimalToBigint((Int128) value.getObjectValue(), precision, scale, tenToScale);
            }
            catch (Exception e) {
                throw new PathEvaluationException(e);
            }
        }

        throw itemTypeError("NUMBER", type.getDisplayName());
    }

    @Override
    protected List<JsonPathItem> visitIrCeilingMethod(IrCeilingMethod node, PathEvaluationContext context)
    {
        List<JsonPathItem> sequence = process(node.base(), context);

        if (lax) {
            sequence = unwrapArrays(sequence);
        }

        ImmutableList.Builder<JsonPathItem> outputSequence = ImmutableList.builder();
        for (JsonPathItem object : sequence) {
            TypedValue value = getNumericTypedValue(object);
            outputSequence.add(getCeiling(value));
        }

        return outputSequence.build();
    }

    private static TypedValue getCeiling(TypedValue typedValue)
    {
        Type type = typedValue.getType();

        if (type.equals(BIGINT) || type.equals(INTEGER) || type.equals(SMALLINT) || type.equals(TINYINT)) {
            return typedValue;
        }
        if (type.equals(DOUBLE)) {
            return new TypedValue(type, Math.ceil(typedValue.getDoubleValue()));
        }
        if (type.equals(REAL)) {
            return new TypedValue(type, ceilingReal(typedValue.getLongValue()));
        }
        if (type instanceof DecimalType decimalType) {
            int scale = decimalType.getScale();
            DecimalType resultType = DecimalType.createDecimalType(decimalType.getPrecision() - scale + Math.min(scale, 1), 0);
            if (decimalType.isShort()) {
                return new TypedValue(resultType, ceilingShort(scale, typedValue.getLongValue()));
            }
            if (resultType.isShort()) {
                try {
                    return new TypedValue(resultType, ceilingLongShort(scale, (Int128) typedValue.getObjectValue()));
                }
                catch (Exception e) {
                    throw new PathEvaluationException(e);
                }
            }
            try {
                return new TypedValue(resultType, ceilingLong(scale, (Int128) typedValue.getObjectValue()));
            }
            catch (Exception e) {
                throw new PathEvaluationException(e);
            }
        }

        throw itemTypeError("NUMBER", type.getDisplayName());
    }

    @Override
    protected List<JsonPathItem> visitIrConstantJsonSequence(IrConstantJsonSequence node, PathEvaluationContext context)
    {
        return node.sequence().stream()
                .map(JsonPathItem.class::cast)
                .collect(toImmutableList());
    }

    @Override
    protected List<JsonPathItem> visitIrContextVariable(IrContextVariable node, PathEvaluationContext context)
    {
        return ImmutableList.of(input);
    }

    @Override
    protected List<JsonPathItem> visitIrDatetimeMethod(IrDatetimeMethod node, PathEvaluationContext context)
    {
        List<JsonPathItem> sequence = process(node.base(), context);

        if (lax) {
            sequence = unwrapArrays(sequence);
        }

        ImmutableList.Builder<JsonPathItem> outputSequence = ImmutableList.builder();
        for (JsonPathItem object : sequence) {
            TypedValue value = getTextTypedValue(object)
                    .orElseThrow(() -> itemTypeError("TEXT", itemTypeName(object)));
            outputSequence.add(getDatetime(value));
        }

        return outputSequence.build();
    }

    private static TypedValue getDatetime(TypedValue typedValue)
    {
        String value = getText(typedValue);

        try {
            return new TypedValue(DATE, (long) parseDate(value));
        }
        catch (RuntimeException ignored) {
        }

        try {
            int precision = extractTimePrecision(value);
            if (timeHasTimeZone(value)) {
                return TypedValue.fromValueAsObject(createTimeWithTimeZoneType(precision), parseTimeWithTimeZone(precision, value));
            }
            return new TypedValue(createTimeType(precision), parseTime(value));
        }
        catch (RuntimeException ignored) {
        }

        try {
            int precision = extractTimestampPrecision(value);
            if (timestampHasTimeZone(value)) {
                return TypedValue.fromValueAsObject(createTimestampWithTimeZoneType(precision), parseTimestampWithTimeZone(precision, value));
            }
            return TypedValue.fromValueAsObject(createTimestampType(precision), parseTimestamp(precision, value));
        }
        catch (RuntimeException ignored) {
        }

        throw new PathEvaluationException("invalid datetime item");
    }

    private static String getText(TypedValue typedValue)
    {
        return switch (typedValue.getType()) {
            case CharType charType -> padSpaces((Slice) typedValue.getObjectValue(), charType).toStringUtf8();
            case VarcharType _ -> ((Slice) typedValue.getObjectValue()).toStringUtf8();
            default -> throw itemTypeError("TEXT", typedValue.getType().getDisplayName());
        };
    }

    @Override
    protected List<JsonPathItem> visitIrDescendantMemberAccessor(IrDescendantMemberAccessor node, PathEvaluationContext context)
    {
        List<JsonPathItem> sequence = process(node.base(), context);

        ImmutableList.Builder<JsonPathItem> builder = ImmutableList.builder();
        for (JsonPathItem object : sequence) {
            descendants(object, node.key(), builder);
        }

        return builder.build();
    }

    private void descendants(JsonPathItem object, String key, ImmutableList.Builder<JsonPathItem> builder)
    {
        Optional<JsonValueView> view = JsonValueView.fromItem(object);
        if (view.isPresent()) {
            JsonValueView jsonView = view.orElseThrow();
            if (jsonView.isObject()) {
                jsonView.forEachObjectMember((memberKey, memberValue) -> {
                    if (memberKey.equals(key)) {
                        builder.add(memberValue);
                    }
                });
                jsonView.forEachObjectMember((memberKey, memberValue) -> descendants(memberValue, key, builder));
            }
            if (jsonView.isArray()) {
                jsonView.forEachArrayElement(element -> descendants(element, key, builder));
            }
            return;
        }

        JsonPathItem normalized = normalize(object);
        if (normalized instanceof JsonObjectItem jsonObject) {
            // prefix order: visit the enclosing object first
            for (JsonObjectMember member : jsonObject.members()) {
                if (member.key().equals(key)) {
                    builder.add(member.value());
                }
            }
            // recurse into child nodes
            for (JsonObjectMember member : jsonObject.members()) {
                descendants(member.value(), key, builder);
            }
        }
        if (normalized instanceof JsonArrayItem jsonArray) {
            for (JsonValue element : jsonArray.elements()) {
                descendants(element, key, builder);
            }
        }
    }

    @Override
    protected List<JsonPathItem> visitIrDoubleMethod(IrDoubleMethod node, PathEvaluationContext context)
    {
        List<JsonPathItem> sequence = process(node.base(), context);

        if (lax) {
            sequence = unwrapArrays(sequence);
        }

        ImmutableList.Builder<JsonPathItem> outputSequence = ImmutableList.builder();
        for (JsonPathItem object : sequence) {
            TypedValue value = tryGetNumericTypedValue(object)
                    .orElseGet(() -> getTextTypedValue(object)
                            .orElseThrow(() -> itemTypeError("NUMBER or TEXT", itemTypeName(object))));
            outputSequence.add(getDouble(value));
        }

        return outputSequence.build();
    }

    private static TypedValue getDouble(TypedValue typedValue)
    {
        Type type = typedValue.getType();

        if (type.equals(BIGINT) || type.equals(INTEGER) || type.equals(SMALLINT) || type.equals(TINYINT)) {
            return new TypedValue(DOUBLE, (double) typedValue.getLongValue());
        }
        if (type.equals(DOUBLE)) {
            return typedValue;
        }
        if (type.equals(REAL)) {
            return new TypedValue(DOUBLE, RealOperators.castToDouble(typedValue.getLongValue()));
        }
        if (type instanceof DecimalType decimalType) {
            int precision = decimalType.getPrecision();
            int scale = decimalType.getScale();
            if (decimalType.isShort()) {
                long tenToScale = longTenToNth(DecimalConversions.intScale(scale));
                return new TypedValue(DOUBLE, shortDecimalToDouble(typedValue.getLongValue(), precision, scale, tenToScale));
            }
            Int128 tenToScale = Int128Math.powerOfTen(DecimalConversions.intScale(scale));
            return new TypedValue(DOUBLE, longDecimalToDouble((Int128) typedValue.getObjectValue(), precision, scale, tenToScale));
        }
        if (type instanceof VarcharType || type instanceof CharType) {
            try {
                return new TypedValue(DOUBLE, VarcharOperators.castToDouble((Slice) typedValue.getObjectValue()));
            }
            catch (Exception e) {
                throw new PathEvaluationException(e);
            }
        }

        throw itemTypeError("NUMBER or TEXT", type.getDisplayName());
    }

    @Override
    protected List<JsonPathItem> visitIrFilter(IrFilter node, PathEvaluationContext context)
    {
        List<JsonPathItem> sequence = process(node.base(), context);

        if (lax) {
            sequence = unwrapArrays(sequence);
        }

        ImmutableList.Builder<JsonPathItem> outputSequence = ImmutableList.builder();
        for (JsonPathItem object : sequence) {
            PathEvaluationContext currentItemContext = context.withCurrentItem(object);
            Boolean result = predicateVisitor.process(node.predicate(), currentItemContext);
            if (Boolean.TRUE.equals(result)) {
                outputSequence.add(object);
            }
        }

        return outputSequence.build();
    }

    @Override
    protected List<JsonPathItem> visitIrFloorMethod(IrFloorMethod node, PathEvaluationContext context)
    {
        List<JsonPathItem> sequence = process(node.base(), context);

        if (lax) {
            sequence = unwrapArrays(sequence);
        }

        ImmutableList.Builder<JsonPathItem> outputSequence = ImmutableList.builder();
        for (JsonPathItem object : sequence) {
            TypedValue value = getNumericTypedValue(object);
            outputSequence.add(getFloor(value));
        }

        return outputSequence.build();
    }

    private static TypedValue getFloor(TypedValue typedValue)
    {
        Type type = typedValue.getType();

        if (type.equals(BIGINT) || type.equals(INTEGER) || type.equals(SMALLINT) || type.equals(TINYINT)) {
            return typedValue;
        }
        if (type.equals(DOUBLE)) {
            return new TypedValue(type, Math.floor(typedValue.getDoubleValue()));
        }
        if (type.equals(REAL)) {
            return new TypedValue(type, floorReal(typedValue.getLongValue()));
        }
        if (type instanceof DecimalType decimalType) {
            int scale = decimalType.getScale();
            DecimalType resultType = DecimalType.createDecimalType(decimalType.getPrecision() - scale + Math.min(scale, 1), 0);
            if (decimalType.isShort()) {
                return new TypedValue(resultType, floorShort(scale, typedValue.getLongValue()));
            }
            if (resultType.isShort()) {
                try {
                    return new TypedValue(resultType, floorLongShort(scale, (Int128) typedValue.getObjectValue()));
                }
                catch (Exception e) {
                    throw new PathEvaluationException(e);
                }
            }
            try {
                return new TypedValue(resultType, floorLong(scale, (Int128) typedValue.getObjectValue()));
            }
            catch (Exception e) {
                throw new PathEvaluationException(e);
            }
        }

        throw itemTypeError("NUMBER", type.getDisplayName());
    }

    @Override
    protected List<JsonPathItem> visitIrJsonNull(IrJsonNull node, PathEvaluationContext context)
    {
        return ImmutableList.of(JsonNull.JSON_NULL);
    }

    @Override
    protected List<JsonPathItem> visitIrKeyValueMethod(IrKeyValueMethod node, PathEvaluationContext context)
    {
        List<JsonPathItem> sequence = process(node.base(), context);

        if (lax) {
            sequence = unwrapArrays(sequence);
        }

        ImmutableList.Builder<JsonPathItem> outputSequence = ImmutableList.builder();
        for (JsonPathItem object : sequence) {
            Optional<JsonValueView> view = JsonValueView.fromObject(object);
            if (view.isPresent() && view.orElseThrow().isObject()) {
                JsonValueView jsonView = view.orElseThrow();
                jsonView.forEachObjectMember((memberKey, memberValue) -> outputSequence.add(new JsonObjectItem(ImmutableList.of(
                        new JsonObjectMember("name", new TypedValue(VARCHAR, utf8Slice(memberKey))),
                        new JsonObjectMember("value", memberValue.materializeValue()),
                        new JsonObjectMember("id", new TypedValue(INTEGER, (long) objectId))))));
                objectId++;
                continue;
            }

            JsonPathItem normalized = normalize(object);
            if (!(normalized instanceof JsonObjectItem jsonObject)) {
                throw itemTypeError("OBJECT", itemTypeName(normalized));
            }

            jsonObject.members().forEach(
                    member -> outputSequence.add(new JsonObjectItem(ImmutableList.of(
                            new JsonObjectMember("name", new TypedValue(VARCHAR, utf8Slice(member.key()))),
                            new JsonObjectMember("value", member.value()),
                            new JsonObjectMember("id", new TypedValue(INTEGER, (long) objectId))))));
            objectId++;
        }

        return outputSequence.build();
    }

    @Override
    protected List<JsonPathItem> visitIrLastIndexVariable(IrLastIndexVariable node, PathEvaluationContext context)
    {
        return ImmutableList.of(context.getLast());
    }

    @Override
    protected List<JsonPathItem> visitIrLiteral(IrLiteral node, PathEvaluationContext context)
    {
        return ImmutableList.of(TypedValue.fromValueAsObject(node.type().orElseThrow(), node.value()));
    }

    @Override
    protected List<JsonPathItem> visitIrMemberAccessor(IrMemberAccessor node, PathEvaluationContext context)
    {
        List<JsonPathItem> sequence = process(node.base(), context);

        if (lax) {
            sequence = unwrapArrays(sequence);
        }

        ImmutableList.Builder<JsonPathItem> outputSequence = ImmutableList.builder();
        for (JsonPathItem object : sequence) {
            Optional<JsonValueView> view = JsonValueView.fromObject(object);
            if (view.isPresent()) {
                JsonValueView jsonView = view.orElseThrow();
                if (!lax && !jsonView.isObject()) {
                    throw itemTypeError("OBJECT", itemTypeName(object));
                }
                if (jsonView.isObject()) {
                    if (node.key().isEmpty()) {
                        jsonView.forEachObjectMember((memberKey, memberValue) -> outputSequence.add(memberValue));
                    }
                    else {
                        String key = node.key().orElseThrow();
                        ImmutableList.Builder<JsonPathItem> matches = ImmutableList.builder();
                        jsonView.forEachObjectMember((memberKey, memberValue) -> {
                            if (memberKey.equals(key)) {
                                matches.add(memberValue);
                            }
                        });
                        List<JsonPathItem> values = matches.build();
                        outputSequence.addAll(values);
                        if (values.isEmpty() && !lax) {
                            throw structuralError("missing member '%s' in JSON object", key);
                        }
                    }
                }
                continue;
            }

            JsonPathItem normalized = normalize(object);
            if (!lax) {
                if (!(normalized instanceof JsonObjectItem)) {
                    throw itemTypeError("OBJECT", itemTypeName(normalized));
                }
            }

            if (normalized instanceof JsonObjectItem jsonObject) {
                // handle wildcard member accessor
                if (node.key().isEmpty()) {
                    for (JsonObjectMember member : jsonObject.members()) {
                        outputSequence.add(member.value());
                    }
                }
                else {
                    boolean found = false;
                    String key = node.key().get();
                    for (JsonObjectMember member : jsonObject.members()) {
                        if (member.key().equals(key)) {
                            outputSequence.add(member.value());
                            found = true;
                        }
                    }
                    if (!found) {
                        if (!lax) {
                            throw structuralError("missing member '%s' in JSON object", key);
                        }
                    }
                }
            }
        }

        return outputSequence.build();
    }

    @Override
    protected List<JsonPathItem> visitIrNamedJsonVariable(IrNamedJsonVariable node, PathEvaluationContext context)
    {
        JsonPathItem value = parameters[node.index()];
        checkState(value != null, "missing value for parameter");
        checkState(value.equals(EMPTY_SEQUENCE) || value == JsonNull.JSON_NULL || value instanceof JsonPathParameter, "expected JSON, got SQL value");

        if (value.equals(EMPTY_SEQUENCE)) {
            return ImmutableList.of();
        }
        if (value == JsonNull.JSON_NULL) {
            return ImmutableList.of(value);
        }
        return ImmutableList.of(((JsonPathParameter) value).item());
    }

    @Override
    protected List<JsonPathItem> visitIrNamedValueVariable(IrNamedValueVariable node, PathEvaluationContext context)
    {
        JsonPathItem value = parameters[node.index()];
        checkState(value != null, "missing value for parameter");
        checkState(value instanceof TypedValue || value == JsonNull.JSON_NULL, "expected SQL value or JSON null, got non-null JSON");

        return ImmutableList.of(value);
    }

    @Override
    protected List<JsonPathItem> visitIrPredicateCurrentItemVariable(IrPredicateCurrentItemVariable node, PathEvaluationContext context)
    {
        return ImmutableList.of(context.getCurrentItem());
    }

    @Override
    protected List<JsonPathItem> visitIrSizeMethod(IrSizeMethod node, PathEvaluationContext context)
    {
        List<JsonPathItem> sequence = process(node.base(), context);

        ImmutableList.Builder<JsonPathItem> outputSequence = ImmutableList.builder();
        for (JsonPathItem object : sequence) {
            Optional<JsonValueView> view = JsonValueView.fromObject(object);
            if (view.isPresent() && view.orElseThrow().isArray()) {
                outputSequence.add(new TypedValue(INTEGER, (long) view.orElseThrow().arraySize()));
            }
            else if (object instanceof JsonArrayItem jsonArray) {
                outputSequence.add(new TypedValue(INTEGER, (long) jsonArray.elements().size()));
            }
            else if (lax) {
                outputSequence.add(new TypedValue(INTEGER, 1));
            }
            else {
                throw itemTypeError("ARRAY", itemTypeName(object));
            }
        }

        return outputSequence.build();
    }

    @Override
    protected List<JsonPathItem> visitIrTypeMethod(IrTypeMethod node, PathEvaluationContext context)
    {
        List<JsonPathItem> sequence = process(node.base(), context);

        Type resultType = node.type().orElseThrow();
        ImmutableList.Builder<JsonPathItem> outputSequence = ImmutableList.builder();

        // In case when a new type is supported in JSON path, it might be necessary to update the
        // constant JsonPathAnalyzer.TYPE_METHOD_RESULT_TYPE, which determines the resultType.
        // Today it is only enough to fit the longest of the result strings below.
        for (JsonPathItem object : sequence) {
            Optional<JsonValueView> view = JsonValueView.fromObject(object);
            if (view.isPresent()) {
                JsonValueView jsonView = view.orElseThrow();
                switch (jsonView.kind()) {
                    case NULL -> outputSequence.add(new TypedValue(resultType, utf8Slice("null")));
                    case ARRAY -> outputSequence.add(new TypedValue(resultType, utf8Slice("array")));
                    case OBJECT -> outputSequence.add(new TypedValue(resultType, utf8Slice("object")));
                    case TYPED_VALUE -> outputSequence.add(typeResult(resultType, jsonView.typedValue().getType()));
                    case JSON_ERROR -> throw new IllegalStateException("JSON error item in path result");
                }
            }
            else {
                object = normalize(object);
                if (object == JsonNull.JSON_NULL) {
                    outputSequence.add(new TypedValue(resultType, utf8Slice("null")));
                }
                else if (object instanceof JsonArrayItem) {
                    outputSequence.add(new TypedValue(resultType, utf8Slice("array")));
                }
                else if (object instanceof JsonObjectItem) {
                    outputSequence.add(new TypedValue(resultType, utf8Slice("object")));
                }
                else {
                    outputSequence.add(typeResult(resultType, ((TypedValue) object).getType()));
                }
            }
        }

        return outputSequence.build();
    }

    private static Optional<TypedValue> tryGetNumericTypedValue(JsonPathItem object)
    {
        Optional<JsonValueView> view = JsonValueView.fromItem(object);
        if (view.isPresent() && view.orElseThrow().isTypedValue()) {
            TypedValue typedValue = view.orElseThrow().typedValue();
            Type type = typedValue.getType();
            if (type.equals(BIGINT) || type.equals(INTEGER) || type.equals(SMALLINT) || type.equals(TINYINT) || type.equals(DOUBLE) || type.equals(REAL) || type instanceof DecimalType) {
                return Optional.of(typedValue);
            }
            return Optional.empty();
        }

        object = normalize(object);
        if (!(object instanceof TypedValue typedValue)) {
            return Optional.empty();
        }
        Type type = typedValue.getType();
        if (type.equals(BIGINT) || type.equals(INTEGER) || type.equals(SMALLINT) || type.equals(TINYINT) || type.equals(DOUBLE) || type.equals(REAL) || type instanceof DecimalType) {
            return Optional.of(typedValue);
        }
        return Optional.empty();
    }

    private static TypedValue getNumericTypedValue(JsonPathItem object)
    {
        return tryGetNumericTypedValue(object)
                .orElseThrow(() -> itemTypeError("NUMBER", itemTypeName(object)));
    }

    private static Optional<TypedValue> getTextTypedValue(JsonPathItem object)
    {
        Optional<JsonValueView> view = JsonValueView.fromItem(object);
        if (view.isPresent() && view.orElseThrow().isTypedValue()) {
            TypedValue typedValue = view.orElseThrow().typedValue();
            Type type = typedValue.getType();
            if (type instanceof VarcharType || type instanceof CharType) {
                return Optional.of(typedValue);
            }
            return Optional.empty();
        }

        object = normalize(object);
        if (!(object instanceof TypedValue typedValue)) {
            return Optional.empty();
        }
        Type type = typedValue.getType();
        if (type instanceof VarcharType || type instanceof CharType) {
            return Optional.of(typedValue);
        }
        return Optional.empty();
    }

    private static TypedValue getTypedValue(JsonPathItem object)
    {
        Optional<JsonValueView> view = JsonValueView.fromItem(object);
        if (view.isPresent() && view.orElseThrow().isTypedValue()) {
            return view.orElseThrow().typedValue();
        }

        object = normalize(object);
        if (object instanceof TypedValue typedValue) {
            return typedValue;
        }
        throw itemTypeError("NUMBER", itemTypeName(object));
    }

    private static String itemTypeName(JsonPathItem object)
    {
        Optional<JsonValueView> view = JsonValueView.fromItem(object);
        if (view.isPresent()) {
            return switch (view.orElseThrow().kind()) {
                case NULL -> "NULL";
                case ARRAY -> "ARRAY";
                case OBJECT -> "OBJECT";
                case TYPED_VALUE -> itemTypeName(view.orElseThrow().typedValue());
                case JSON_ERROR -> "ERROR";
            };
        }

        object = normalize(object);
        if (object == JsonNull.JSON_NULL) {
            return "NULL";
        }
        if (object instanceof JsonArrayItem) {
            return "ARRAY";
        }
        if (object instanceof JsonObjectItem) {
            return "OBJECT";
        }
        if (object instanceof TypedValue typedValue) {
            Type type = typedValue.getType();
            if (type.equals(BIGINT) || type.equals(INTEGER) || type.equals(SMALLINT) || type.equals(TINYINT) || type.equals(DOUBLE) || type.equals(REAL) || type instanceof DecimalType) {
                return "NUMBER";
            }
            if (type instanceof VarcharType || type instanceof CharType) {
                return "STRING";
            }
            if (type.equals(BOOLEAN)) {
                return "BOOLEAN";
            }
            if (type.equals(DATE)) {
                return "DATE";
            }
            if (type instanceof TimeType) {
                return "TIME";
            }
            if (type instanceof TimeWithTimeZoneType) {
                return "TIME WITH TIME ZONE";
            }
            if (type instanceof TimestampType) {
                return "TIMESTAMP";
            }
            if (type instanceof TimestampWithTimeZoneType) {
                return "TIMESTAMP WITH TIME ZONE";
            }
            return type.getDisplayName();
        }
        return object.getClass().getSimpleName();
    }

    private static String itemTypeName(TypedValue typedValue)
    {
        Type type = typedValue.getType();
        if (type.equals(BIGINT) || type.equals(INTEGER) || type.equals(SMALLINT) || type.equals(TINYINT) || type.equals(DOUBLE) || type.equals(REAL) || type instanceof DecimalType) {
            return "NUMBER";
        }
        if (type instanceof VarcharType || type instanceof CharType) {
            return "STRING";
        }
        if (type.equals(BOOLEAN)) {
            return "BOOLEAN";
        }
        if (type.equals(DATE)) {
            return "DATE";
        }
        if (type instanceof TimeType) {
            return "TIME";
        }
        if (type instanceof TimeWithTimeZoneType) {
            return "TIME WITH TIME ZONE";
        }
        if (type instanceof TimestampType) {
            return "TIMESTAMP";
        }
        if (type instanceof TimestampWithTimeZoneType) {
            return "TIMESTAMP WITH TIME ZONE";
        }
        return type.getDisplayName();
    }

    private static TypedValue typeResult(Type resultType, Type type)
    {
        if (type.equals(BIGINT) || type.equals(INTEGER) || type.equals(SMALLINT) || type.equals(TINYINT) || type.equals(DOUBLE) || type.equals(REAL) || type instanceof DecimalType) {
            return new TypedValue(resultType, utf8Slice("number"));
        }
        if (type instanceof VarcharType || type instanceof CharType) {
            return new TypedValue(resultType, utf8Slice("string"));
        }
        if (type.equals(BOOLEAN)) {
            return new TypedValue(resultType, utf8Slice("boolean"));
        }
        if (type.equals(DATE)) {
            return new TypedValue(resultType, utf8Slice("date"));
        }
        if (type instanceof TimeType) {
            return new TypedValue(resultType, utf8Slice("time without time zone"));
        }
        if (type instanceof TimeWithTimeZoneType) {
            return new TypedValue(resultType, utf8Slice("time with time zone"));
        }
        if (type instanceof TimestampType) {
            return new TypedValue(resultType, utf8Slice("timestamp without time zone"));
        }
        if (type instanceof TimestampWithTimeZoneType) {
            return new TypedValue(resultType, utf8Slice("timestamp with time zone"));
        }
        return new TypedValue(resultType, utf8Slice(type.getDisplayName()));
    }
}
