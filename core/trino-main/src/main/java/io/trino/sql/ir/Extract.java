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
import io.trino.sql.ir.Extract.Field;

import javax.annotation.concurrent.Immutable;

import java.util.List;
import java.util.Objects;

import static java.util.Objects.requireNonNull;

@Immutable
public class Extract
        extends Expression
{
    private final Expression expression;
    private final Field field;

    @JsonCreator
    public Extract(
            @JsonProperty("expression") Expression expression,
            @JsonProperty("field") Field field)
    {
        requireNonNull(expression, "expression is null");
        requireNonNull(field, "field is null");

        this.expression = expression;
        this.field = field;
    }

    @JsonProperty
    public Expression getExpression()
    {
        return expression;
    }

    @JsonProperty
    public Field getField()
    {
        return field;
    }

    @Override
    public <R, C> R accept(IrVisitor<R, C> visitor, C context)
    {
        return visitor.visitExtract(this, context);
    }

    @Override
    public List<Node> getChildren()
    {
        return ImmutableList.of(expression);
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

        Extract that = (Extract) o;
        return Objects.equals(expression, that.expression) &&
                (field == that.field);
    }

    @Override
    public int hashCode()
    {
        return Objects.hash(expression, field);
    }

    @Override
    public boolean shallowEquals(Node other)
    {
        if (!sameClass(this, other)) {
            return false;
        }

        Extract otherExtract = (Extract) other;
        return field.equals(otherExtract.field);
    }
}
