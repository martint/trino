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
import io.trino.sql.ir.ComparisonExpression.Operator;
import io.trino.sql.ir.QuantifiedComparisonExpression.Quantifier;

import javax.annotation.concurrent.Immutable;

import java.util.List;
import java.util.Objects;

import static java.util.Objects.requireNonNull;

@Immutable
public class QuantifiedComparisonExpression
        extends Expression
{
    private final Operator operator;
    private final Quantifier quantifier;
    private final Expression value;
    private final Expression subquery;

    @JsonCreator
    public QuantifiedComparisonExpression(
            @JsonProperty("operator") Operator operator,
            @JsonProperty("quantifier") Quantifier quantifier,
            @JsonProperty("value") Expression value,
            @JsonProperty("subquery") Expression subquery)
    {
        this.operator = requireNonNull(operator, "operator is null");
        this.quantifier = requireNonNull(quantifier, "quantifier is null");
        this.value = requireNonNull(value, "value is null");
        this.subquery = requireNonNull(subquery, "subquery is null");
    }

    @JsonProperty
    public Operator getOperator()
    {
        return operator;
    }

    @JsonProperty
    public Quantifier getQuantifier()
    {
        return quantifier;
    }

    @JsonProperty
    public Expression getValue()
    {
        return value;
    }

    @JsonProperty
    public Expression getSubquery()
    {
        return subquery;
    }

    @Override
    public <R, C> R accept(IrVisitor<R, C> visitor, C context)
    {
        return visitor.visitQuantifiedComparisonExpression(this, context);
    }

    @Override
    public List<Node> getChildren()
    {
        return ImmutableList.of(value, subquery);
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

        QuantifiedComparisonExpression that = (QuantifiedComparisonExpression) o;
        return operator == that.operator &&
                quantifier == that.quantifier &&
                Objects.equals(value, that.value) &&
                Objects.equals(subquery, that.subquery);
    }

    @Override
    public int hashCode()
    {
        return Objects.hash(operator, quantifier, value, subquery);
    }

    @Override
    public boolean shallowEquals(Node other)
    {
        if (!sameClass(this, other)) {
            return false;
        }

        QuantifiedComparisonExpression otherNode = (QuantifiedComparisonExpression) other;
        return operator == otherNode.operator && quantifier == otherNode.quantifier;
    }
}
