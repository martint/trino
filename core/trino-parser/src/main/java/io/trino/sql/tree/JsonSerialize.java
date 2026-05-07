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
package io.trino.sql.tree;

import com.google.common.collect.ImmutableList;
import io.trino.sql.tree.JsonPathParameter.JsonFormat;

import java.util.List;
import java.util.Objects;
import java.util.Optional;

import static java.util.Objects.requireNonNull;

public class JsonSerialize
        extends Expression
{
    private final Expression expression;
    private final JsonFormat inputFormat;
    private final Optional<DataType> returnedType;
    private final Optional<JsonFormat> outputFormat;

    public JsonSerialize(NodeLocation location, Expression expression, JsonFormat inputFormat, Optional<DataType> returnedType, Optional<JsonFormat> outputFormat)
    {
        super(location);
        this.expression = requireNonNull(expression, "expression is null");
        this.inputFormat = requireNonNull(inputFormat, "inputFormat is null");
        this.returnedType = requireNonNull(returnedType, "returnedType is null");
        this.outputFormat = requireNonNull(outputFormat, "outputFormat is null");
    }

    public Expression getExpression()
    {
        return expression;
    }

    public JsonFormat getInputFormat()
    {
        return inputFormat;
    }

    public Optional<DataType> getReturnedType()
    {
        return returnedType;
    }

    public Optional<JsonFormat> getOutputFormat()
    {
        return outputFormat;
    }

    @Override
    public <R, C> R accept(AstVisitor<R, C> visitor, C context)
    {
        return visitor.visitJsonSerialize(this, context);
    }

    @Override
    public List<? extends Node> getChildren()
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
        JsonSerialize that = (JsonSerialize) o;
        return Objects.equals(expression, that.expression) &&
                inputFormat == that.inputFormat &&
                Objects.equals(returnedType, that.returnedType) &&
                Objects.equals(outputFormat, that.outputFormat);
    }

    @Override
    public int hashCode()
    {
        return Objects.hash(expression, inputFormat, returnedType, outputFormat);
    }

    @Override
    public boolean shallowEquals(Node other)
    {
        if (!sameClass(this, other)) {
            return false;
        }

        JsonSerialize that = (JsonSerialize) other;
        return inputFormat == that.inputFormat &&
                Objects.equals(returnedType, that.returnedType) &&
                Objects.equals(outputFormat, that.outputFormat);
    }
}
