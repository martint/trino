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
import com.google.common.collect.Range;
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
import io.trino.spi.function.OperatorType;
import io.trino.spi.type.BigintType;
import io.trino.spi.type.BooleanType;
import io.trino.spi.type.CharType;
import io.trino.spi.type.DateType;
import io.trino.spi.type.DecimalConversions;
import io.trino.spi.type.DecimalType;
import io.trino.spi.type.DoubleType;
import io.trino.spi.type.Int128;
import io.trino.spi.type.Int128Math;
import io.trino.spi.type.IntegerType;
import io.trino.spi.type.RealType;
import io.trino.spi.type.SmallintType;
import io.trino.spi.type.TimeType;
import io.trino.spi.type.TimeWithTimeZoneType;
import io.trino.spi.type.TimestampType;
import io.trino.spi.type.TimestampWithTimeZoneType;
import io.trino.spi.type.TinyintType;
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
import static io.trino.json.PathEvaluationException.itemTypeError;
import static io.trino.json.PathEvaluationException.structuralError;
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
import static io.trino.spi.type.Decimals.longTenToNth;
import static io.trino.spi.type.DoubleType.DOUBLE;
import static io.trino.spi.type.IntegerType.INTEGER;
import static io.trino.spi.type.RealType.REAL;
import static io.trino.spi.type.SmallintType.SMALLINT;
import static io.trino.spi.type.TinyintType.TINYINT;
import static io.trino.spi.type.VarcharType.VARCHAR;
import static io.trino.type.DecimalCasts.longDecimalToDouble;
import static io.trino.type.DecimalCasts.shortDecimalToDouble;
import static java.lang.Float.floatToRawIntBits;
import static java.lang.Float.intBitsToFloat;
import static java.lang.String.format;
import static java.util.Objects.requireNonNull;

class PathEvaluationVisitor
        extends IrJsonPathVisitor<List<JsonItem>, PathEvaluationContext>
{
    private final boolean lax;
    private final JsonItem input;
    private final JsonItem[] parameters;
    private final PathPredicateEvaluationVisitor predicateVisitor;
    private final Invoker invoker;
    private final CachingResolver resolver;
    private int objectId;

    public PathEvaluationVisitor(boolean lax, JsonItem input, JsonItem[] parameters, Invoker invoker, CachingResolver resolver)
    {
        this.lax = lax;
        this.input = requireNonNull(input, "input is null");
        this.parameters = requireNonNull(parameters, "parameters is null");
        this.invoker = requireNonNull(invoker, "invoker is null");
        this.resolver = requireNonNull(resolver, "resolver is null");
        this.predicateVisitor = new PathPredicateEvaluationVisitor(lax, this, invoker, resolver);
    }

    @Override
    protected List<JsonItem> visitIrPathNode(IrPathNode node, PathEvaluationContext context)
    {
        throw new UnsupportedOperationException("JSON path evaluating visitor not implemented for " + node.getClass().getSimpleName());
    }

    @Override
    protected List<JsonItem> visitIrAbsMethod(IrAbsMethod node, PathEvaluationContext context)
    {
        List<JsonItem> sequence = process(node.base(), context);

        if (lax) {
            sequence = unwrapArrays(sequence);
        }

        ImmutableList.Builder<JsonItem> outputSequence = ImmutableList.builder();
        for (JsonItem object : sequence) {
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
    protected List<JsonItem> visitIrArithmeticBinary(IrArithmeticBinary node, PathEvaluationContext context)
    {
        List<JsonItem> leftSequence = process(node.left(), context);
        List<JsonItem> rightSequence = process(node.right(), context);

        if (lax) {
            leftSequence = unwrapArrays(leftSequence);
            rightSequence = unwrapArrays(rightSequence);
        }

        if (leftSequence.size() != 1 || rightSequence.size() != 1) {
            throw new PathEvaluationException("arithmetic binary expression requires singleton operands");
        }

        TypedValue left = requireScalar(getOnlyElement(leftSequence));
        TypedValue right = requireScalar(getOnlyElement(rightSequence));

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
    protected List<JsonItem> visitIrArithmeticUnary(IrArithmeticUnary node, PathEvaluationContext context)
    {
        List<JsonItem> sequence = process(node.base(), context);

        if (lax) {
            sequence = unwrapArrays(sequence);
        }

        ImmutableList.Builder<JsonItem> outputSequence = ImmutableList.builder();
        for (JsonItem object : sequence) {
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
    protected List<JsonItem> visitIrArrayAccessor(IrArrayAccessor node, PathEvaluationContext context)
    {
        List<JsonItem> sequence = process(node.base(), context);

        ImmutableList.Builder<JsonItem> outputSequence = ImmutableList.builder();
        for (JsonItem item : sequence) {
            List<JsonItem> elements;
            if (item instanceof JsonArray array) {
                elements = array.elements().stream()
                        .map(JsonItem.class::cast)
                        .collect(toImmutableList());
            }
            else if (lax) {
                elements = ImmutableList.of(item);
            }
            else {
                throw itemTypeError("ARRAY", itemTypeName(item));
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
                List<JsonItem> from = process(subscript.from(), arrayContext);
                Optional<List<JsonItem>> to = subscript.to().map(path -> process(path, arrayContext));
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
                    Range<Long> allElementsRange = Range.closed(0L, (long) elements.size() - 1);
                    Range<Long> subscriptRange = Range.closed(fromIndex, toIndex);
                    if (subscriptRange.isConnected(allElementsRange)) { // cannot intersect ranges which are not connected...
                        Range<Long> resultRange = subscriptRange.intersection(allElementsRange);
                        if (!resultRange.isEmpty()) {
                            for (long i = resultRange.lowerEndpoint(); i <= resultRange.upperEndpoint(); i++) {
                                outputSequence.add(elements.get((int) i));
                            }
                        }
                    }
                }
            }
        }

        return outputSequence.build();
    }

    private static long asArrayIndex(JsonItem object)
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
    protected List<JsonItem> visitIrCeilingMethod(IrCeilingMethod node, PathEvaluationContext context)
    {
        List<JsonItem> sequence = process(node.base(), context);

        if (lax) {
            sequence = unwrapArrays(sequence);
        }

        ImmutableList.Builder<JsonItem> outputSequence = ImmutableList.builder();
        for (JsonItem object : sequence) {
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
    protected List<JsonItem> visitIrConstantJsonSequence(IrConstantJsonSequence node, PathEvaluationContext context)
    {
        return node.sequence().stream()
                .map(JsonItem.class::cast)
                .collect(toImmutableList());
    }

    @Override
    protected List<JsonItem> visitIrContextVariable(IrContextVariable node, PathEvaluationContext context)
    {
        return ImmutableList.of(input);
    }

    @Override
    protected List<JsonItem> visitIrDatetimeMethod(IrDatetimeMethod node, PathEvaluationContext context) // TODO
    {
        throw new UnsupportedOperationException("date method is not yet supported");
    }

    @Override
    protected List<JsonItem> visitIrDescendantMemberAccessor(IrDescendantMemberAccessor node, PathEvaluationContext context)
    {
        List<JsonItem> sequence = process(node.base(), context);

        ImmutableList.Builder<JsonItem> builder = ImmutableList.builder();
        sequence.stream()
                .forEach(item -> descendants(item, node.key(), builder, 0));

        return builder.build();
    }

    // Cap recursion against a deeply nested input so $..key can't overflow the call stack.
    private static final int MAX_DESCENDANTS_DEPTH = 1000;

    private void descendants(JsonItem item, String key, ImmutableList.Builder<JsonItem> builder, int depth)
    {
        if (depth >= MAX_DESCENDANTS_DEPTH) {
            throw new PathEvaluationException("JSON nesting exceeds maximum depth of " + MAX_DESCENDANTS_DEPTH);
        }
        if (item instanceof JsonObject object) {
            // prefix order: visit the enclosing object first
            for (JsonObjectMember member : object.members()) {
                if (member.key().equals(key)) {
                    builder.add(member.value());
                }
            }
            // recurse into child nodes
            for (JsonObjectMember member : object.members()) {
                descendants(member.value(), key, builder, depth + 1);
            }
        }
        if (item instanceof JsonArray array) {
            for (JsonValue element : array.elements()) {
                descendants(element, key, builder, depth + 1);
            }
        }
    }

    @Override
    protected List<JsonItem> visitIrDoubleMethod(IrDoubleMethod node, PathEvaluationContext context)
    {
        List<JsonItem> sequence = process(node.base(), context);

        if (lax) {
            sequence = unwrapArrays(sequence);
        }

        ImmutableList.Builder<JsonItem> outputSequence = ImmutableList.builder();
        for (JsonItem object : sequence) {
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
    protected List<JsonItem> visitIrFilter(IrFilter node, PathEvaluationContext context)
    {
        List<JsonItem> sequence = process(node.base(), context);

        if (lax) {
            sequence = unwrapArrays(sequence);
        }

        ImmutableList.Builder<JsonItem> outputSequence = ImmutableList.builder();
        for (JsonItem object : sequence) {
            PathEvaluationContext currentItemContext = context.withCurrentItem(object);
            Boolean result = predicateVisitor.process(node.predicate(), currentItemContext);
            if (Boolean.TRUE.equals(result)) {
                outputSequence.add(object);
            }
        }

        return outputSequence.build();
    }

    @Override
    protected List<JsonItem> visitIrFloorMethod(IrFloorMethod node, PathEvaluationContext context)
    {
        List<JsonItem> sequence = process(node.base(), context);

        if (lax) {
            sequence = unwrapArrays(sequence);
        }

        ImmutableList.Builder<JsonItem> outputSequence = ImmutableList.builder();
        for (JsonItem object : sequence) {
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
    protected List<JsonItem> visitIrJsonNull(IrJsonNull node, PathEvaluationContext context)
    {
        return ImmutableList.of(JsonNull.JSON_NULL);
    }

    @Override
    protected List<JsonItem> visitIrKeyValueMethod(IrKeyValueMethod node, PathEvaluationContext context)
    {
        List<JsonItem> sequence = process(node.base(), context);

        if (lax) {
            sequence = unwrapArrays(sequence);
        }

        ImmutableList.Builder<JsonItem> outputSequence = ImmutableList.builder();
        for (JsonItem object : sequence) {
            if (!(object instanceof JsonObject jsonObject)) {
                throw itemTypeError("OBJECT", itemTypeName(object));
            }

            jsonObject.members().forEach(
                    member -> outputSequence.add(new JsonObject(ImmutableList.of(
                            new JsonObjectMember("name", new TypedValue(VARCHAR, utf8Slice(member.key()))),
                            new JsonObjectMember("value", member.value()),
                            new JsonObjectMember("id", new TypedValue(INTEGER, (long) objectId))))));
            objectId++;
        }

        return outputSequence.build();
    }

    @Override
    protected List<JsonItem> visitIrLastIndexVariable(IrLastIndexVariable node, PathEvaluationContext context)
    {
        return ImmutableList.of(context.getLast());
    }

    @Override
    protected List<JsonItem> visitIrLiteral(IrLiteral node, PathEvaluationContext context)
    {
        return ImmutableList.of(TypedValue.fromValueAsObject(node.type().orElseThrow(), node.value()));
    }

    @Override
    protected List<JsonItem> visitIrMemberAccessor(IrMemberAccessor node, PathEvaluationContext context)
    {
        List<JsonItem> sequence = process(node.base(), context);

        if (lax) {
            sequence = unwrapArrays(sequence);
        }

        ImmutableList.Builder<JsonItem> outputSequence = ImmutableList.builder();
        for (JsonItem item : sequence) {
            if (!lax) {
                if (!(item instanceof JsonObject)) {
                    throw itemTypeError("OBJECT", itemTypeName(item));
                }
            }

            if (item instanceof JsonObject object) {
                // handle wildcard member accessor
                if (node.key().isEmpty()) {
                    for (JsonObjectMember member : object.members()) {
                        outputSequence.add(member.value());
                    }
                }
                else {
                    boolean found = false;
                    String key = node.key().get();
                    for (JsonObjectMember member : object.members()) {
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
    protected List<JsonItem> visitIrNamedJsonVariable(IrNamedJsonVariable node, PathEvaluationContext context)
    {
        JsonItem value = parameters[node.index()];
        checkState(value != null, "missing value for parameter");

        return switch (value) {
            case JsonEmptySequence _ -> ImmutableList.of();
            case JsonNull _ -> ImmutableList.of(value);
            case JsonPathParameter parameter -> ImmutableList.of(parameter.item());
            default -> throw new IllegalStateException("expected JSON, got SQL value");
        };
    }

    @Override
    protected List<JsonItem> visitIrNamedValueVariable(IrNamedValueVariable node, PathEvaluationContext context)
    {
        JsonItem value = parameters[node.index()];
        checkState(value != null, "missing value for parameter");
        checkState(value instanceof TypedValue || value == JsonNull.JSON_NULL, "expected SQL value or JSON null, got non-null JSON");

        return ImmutableList.of(value);
    }

    @Override
    protected List<JsonItem> visitIrPredicateCurrentItemVariable(IrPredicateCurrentItemVariable node, PathEvaluationContext context)
    {
        return ImmutableList.of(context.getCurrentItem());
    }

    @Override
    protected List<JsonItem> visitIrSizeMethod(IrSizeMethod node, PathEvaluationContext context)
    {
        List<JsonItem> sequence = process(node.base(), context);

        ImmutableList.Builder<JsonItem> outputSequence = ImmutableList.builder();
        for (JsonItem item : sequence) {
            if (item instanceof JsonArray array) {
                outputSequence.add(new TypedValue(INTEGER, (long) array.elements().size()));
            }
            else if (lax) {
                outputSequence.add(new TypedValue(INTEGER, 1));
            }
            else {
                throw itemTypeError("ARRAY", itemTypeName(item));
            }
        }

        return outputSequence.build();
    }

    @Override
    protected List<JsonItem> visitIrTypeMethod(IrTypeMethod node, PathEvaluationContext context)
    {
        List<JsonItem> sequence = process(node.base(), context);

        Type resultType = node.type().orElseThrow();
        ImmutableList.Builder<JsonItem> outputSequence = ImmutableList.builder();

        // In case when a new type is supported in JSON path, it might be necessary to update the
        // constant JsonPathAnalyzer.TYPE_METHOD_RESULT_TYPE, which determines the resultType.
        // Today it is only enough to fit the longest of the result strings below.
        for (JsonItem item : sequence) {
            outputSequence.add(new TypedValue(resultType, switch (item) {
                case JsonNull _ -> utf8Slice("null");
                case JsonArray _ -> utf8Slice("array");
                case JsonObject _ -> utf8Slice("object");
                case TypedValue(BigintType _, _),
                     TypedValue(IntegerType _, _),
                     TypedValue(SmallintType _, _),
                     TypedValue(TinyintType _, _),
                     TypedValue(DoubleType _, _),
                     TypedValue(RealType _, _),
                     TypedValue(DecimalType _, _) -> utf8Slice("number");
                case TypedValue(VarcharType _, _), TypedValue(CharType _, _) -> utf8Slice("string");
                case TypedValue(BooleanType _, _) -> utf8Slice("boolean");
                case TypedValue(DateType _, _) -> utf8Slice("date");
                case TypedValue(TimeType _, _) -> utf8Slice("time without time zone");
                case TypedValue(TimeWithTimeZoneType _, _) -> utf8Slice("time with time zone");
                case TypedValue(TimestampType _, _) -> utf8Slice("timestamp without time zone");
                case TypedValue(TimestampWithTimeZoneType _, _) -> utf8Slice("timestamp with time zone");
                case TypedValue(Type type, _) -> utf8Slice(type.getDisplayName());
                default -> throw new IllegalStateException("Unsupported SQL/JSON item: " + item.getClass().getSimpleName());
            }));
        }

        return outputSequence.build();
    }

    private static Optional<TypedValue> tryGetNumericTypedValue(JsonItem object)
    {
        if (!(object instanceof TypedValue typedValue)) {
            return Optional.empty();
        }
        if (isNumericType(typedValue.getType())) {
            return Optional.of(typedValue);
        }
        return Optional.empty();
    }

    private static boolean isNumericType(Type type)
    {
        return type.equals(BIGINT)
                || type.equals(INTEGER)
                || type.equals(SMALLINT)
                || type.equals(TINYINT)
                || type.equals(DOUBLE)
                || type.equals(REAL)
                || type instanceof DecimalType;
    }

    private static TypedValue getNumericTypedValue(JsonItem object)
    {
        return tryGetNumericTypedValue(object)
                .orElseThrow(() -> itemTypeError("NUMBER", itemTypeName(object)));
    }

    private static Optional<TypedValue> getTextTypedValue(JsonItem object)
    {
        if (!(object instanceof TypedValue typedValue)) {
            return Optional.empty();
        }
        Type type = typedValue.getType();
        if (type instanceof VarcharType || type instanceof CharType) {
            return Optional.of(typedValue);
        }
        return Optional.empty();
    }

    private static TypedValue requireScalar(JsonItem item)
    {
        if (item instanceof TypedValue value) {
            return value;
        }
        throw itemTypeError("scalar value", itemTypeName(item));
    }

    private static String itemTypeName(JsonItem item)
    {
        return switch (item) {
            case JsonNull _ -> "NULL";
            case JsonArray _ -> "ARRAY";
            case JsonObject _ -> "OBJECT";
            case TypedValue(BigintType _, _),
                 TypedValue(IntegerType _, _),
                 TypedValue(SmallintType _, _),
                 TypedValue(TinyintType _, _),
                 TypedValue(DoubleType _, _),
                 TypedValue(RealType _, _),
                 TypedValue(DecimalType _, _) -> "NUMBER";
            case TypedValue(VarcharType _, _), TypedValue(CharType _, _) -> "STRING";
            case TypedValue(BooleanType _, _) -> "BOOLEAN";
            case TypedValue(Type type, _) -> type.getDisplayName();
            default -> item.getClass().getSimpleName();
        };
    }
}
