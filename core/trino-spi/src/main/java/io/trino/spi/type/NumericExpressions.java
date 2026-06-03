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
package io.trino.spi.type;

import io.trino.spi.type.NumericExpression.Literal;
import io.trino.spi.type.NumericExpression.Operation;
import io.trino.spi.type.NumericExpression.Operator;
import io.trino.spi.type.NumericExpression.Variable;

import java.math.BigInteger;
import java.util.Map;

/**
 * Operations over {@link NumericExpression}.
 */
public final class NumericExpressions
{
    private NumericExpressions() {}

    /**
     * Renders the expression in type-parameter syntax, e.g. {@code min(38, (p + 1))}.
     */
    public static String render(NumericExpression expression)
    {
        return switch (expression) {
            case Literal(long value) -> Long.toString(value);
            case Variable(String name) -> name;
            case Operation(Operator operator, NumericExpression left, NumericExpression right) -> switch (operator) {
                case MIN -> "min(" + render(left) + ", " + render(right) + ")";
                case MAX -> "max(" + render(left) + ", " + render(right) + ")";
                case ADD -> "(" + render(left) + " + " + render(right) + ")";
                case SUBTRACT -> "(" + render(left) + " - " + render(right) + ")";
                case MULTIPLY -> "(" + render(left) + " * " + render(right) + ")";
                case DIVIDE -> "(" + render(left) + " / " + render(right) + ")";
            };
        };
    }

    /**
     * Evaluates the expression against the given numeric-variable bindings. The result is a
     * {@link BigInteger}: a calculated parameter such as {@code min(2147483647, x + max(x * y / 2, y) * (x + 1))}
     * relies on a large intermediate being clamped back into range, so the intermediate must be computed
     * exactly rather than wrapping in long. Callers narrow with {@code longValueExact()} at the boundary.
     */
    public static BigInteger evaluate(NumericExpression expression, Map<String, Long> bindings)
    {
        return switch (expression) {
            case Literal(long value) -> BigInteger.valueOf(value);
            case Variable(String name) -> {
                Long value = bindings.get(name);
                if (value == null) {
                    throw new IllegalArgumentException("No binding for numeric variable " + name);
                }
                yield BigInteger.valueOf(value);
            }
            case Operation(Operator operator, NumericExpression left, NumericExpression right) -> {
                BigInteger leftValue = evaluate(left, bindings);
                BigInteger rightValue = evaluate(right, bindings);
                yield switch (operator) {
                    case ADD -> leftValue.add(rightValue);
                    case SUBTRACT -> leftValue.subtract(rightValue);
                    case MULTIPLY -> leftValue.multiply(rightValue);
                    case DIVIDE -> leftValue.divide(rightValue);
                    case MIN -> leftValue.min(rightValue);
                    case MAX -> leftValue.max(rightValue);
                };
            }
        };
    }
}
