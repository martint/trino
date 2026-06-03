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

import static java.util.Objects.requireNonNull;

/**
 * A numeric-valued expression over a function signature's numeric variables, used for a calculated type
 * parameter such as a decimal precision/scale or varchar length (e.g. {@code min(38, p + 1)}).
 * <p>
 * This replaces the stringly-typed {@code longVariableConstraint} expressions that were re-parsed at every
 * bind: a calculated parameter is now a structured tree. Evaluate it with
 * {@link NumericExpressions#evaluate}.
 */
public sealed interface NumericExpression
        permits NumericExpression.Literal,
                NumericExpression.Operation,
                NumericExpression.Variable
{
    /**
     * A constant, e.g. the {@code 38} in {@code min(38, p + 1)}.
     */
    record Literal(long value)
            implements NumericExpression {}

    /**
     * A reference to a numeric variable bound from an argument, e.g. the {@code p} in {@code decimal(p, s)}.
     */
    record Variable(String name)
            implements NumericExpression
    {
        public Variable
        {
            requireNonNull(name, "name is null");
        }
    }

    /**
     * A binary operation over two sub-expressions.
     */
    record Operation(Operator operator, NumericExpression left, NumericExpression right)
            implements NumericExpression
    {
        public Operation
        {
            requireNonNull(operator, "operator is null");
            requireNonNull(left, "left is null");
            requireNonNull(right, "right is null");
        }
    }

    enum Operator
    {
        ADD,
        SUBTRACT,
        MULTIPLY,
        DIVIDE,
        MIN,
        MAX,
    }
}
