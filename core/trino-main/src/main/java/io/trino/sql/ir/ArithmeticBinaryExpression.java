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
package io.trino.sql.ir;

import com.fasterxml.jackson.annotation.JsonCreator;
import com.fasterxml.jackson.annotation.JsonProperty;
import com.google.common.collect.ImmutableList;

import javax.annotation.concurrent.Immutable;

import java.util.List;
import java.util.Objects;

@Immutable
public class ArithmeticBinaryExpression
        extends Expression
{
    private final Operator operator;
    private final Expression left;
    private final Expression right;

    @JsonCreator
    public ArithmeticBinaryExpression(
            @JsonProperty("operator") Operator operator,
            @JsonProperty("left") Expression left,
            @JsonProperty("right") Expression right)
    {
        this.operator = operator;
        this.left = left;
        this.right = right;
    }

    @JsonProperty
    public Operator getOperator()
    {
        return operator;
    }

    @JsonProperty
    public Expression getLeft()
    {
        return left;
    }

    @JsonProperty
    public Expression getRight()
    {
        return right;
    }

    @Override
    public <R, C> R accept(IrVisitor<R, C> visitor, C context)
    {
        return visitor.visitArithmeticBinary(this, context);
    }

    @Override
    public List<Node> getChildren()
    {
        return ImmutableList.of(left, right);
    }

    @Override
    public boolean equals(Object o)
    {
        if (this == o) {
            return true;
        }
        if (o == null || getClass() != o.getClass()) {
            return false;
        }

        ArithmeticBinaryExpression that = (ArithmeticBinaryExpression) o;
        return (operator == that.operator) &&
                Objects.equals(left, that.left) &&
                Objects.equals(right, that.right);
    }

    @Override
    public int hashCode()
    {
        return Objects.hash(operator, left, right);
    }

    @Override
    public boolean shallowEquals(Node other)
    {
        if (!sameClass(this, other)) {
            return false;
        }

        return operator == ((ArithmeticBinaryExpression) other).operator;
    }

    public enum Operator
    {
        ADD,
        SUBTRACT,
        MULTIPLY,
        DIVIDE,
        MODULUS
    }
}
