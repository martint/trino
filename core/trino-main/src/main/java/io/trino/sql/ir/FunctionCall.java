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
import io.trino.sql.tree.FunctionCall.NullTreatment;

import javax.annotation.concurrent.Immutable;

import java.util.List;
import java.util.Objects;
import java.util.Optional;

import static com.google.common.base.Preconditions.checkArgument;
import static java.util.Objects.requireNonNull;

@Immutable
public class FunctionCall
        extends Expression
{
    private final QualifiedName name;
    private final Optional<Window> window;
    private final Optional<Expression> filter;
    private final boolean distinct;
    private final Optional<NullTreatment> nullTreatment;
    private final List<Expression> arguments;

    public FunctionCall(QualifiedName name, List<Expression> arguments)
    {
        this(name, Optional.empty(), Optional.empty(), Optional.empty(), false, Optional.empty(), Optional.empty(), arguments);
    }

    @JsonCreator
    public FunctionCall(
            @JsonProperty("name") QualifiedName name,
            @JsonProperty("window") Optional<Window> window,
            @JsonProperty("filter") Optional<Expression> filter,
            @JsonProperty("distinct") boolean distinct,
            @JsonProperty("nullTreatment") Optional<NullTreatment> nullTreatment,
            @JsonProperty("arguments") List<Expression> arguments)
    {
        requireNonNull(name, "name is null");
        requireNonNull(window, "window is null");
        window.ifPresent(node -> checkArgument(node instanceof WindowReference || node instanceof WindowSpecification, "unexpected window: " + node.getClass().getSimpleName()));
        requireNonNull(filter, "filter is null");
        requireNonNull(nullTreatment, "nullTreatment is null");
        requireNonNull(arguments, "arguments is null");

        this.name = name;
        this.window = window;
        this.filter = filter;
        this.distinct = distinct;
        this.nullTreatment = nullTreatment;
        this.arguments = arguments;
    }

    @JsonProperty
    public QualifiedName getName()
    {
        return name;
    }

    @JsonProperty
    public boolean isDistinct()
    {
        return distinct;
    }

    @JsonProperty
    public Optional<NullTreatment> getNullTreatment()
    {
        return nullTreatment;
    }

    @JsonProperty
    public List<Expression> getArguments()
    {
        return arguments;
    }

    @JsonProperty
    public Optional<Expression> getFilter()
    {
        return filter;
    }

    @Override
    public <R, C> R accept(IrVisitor<R, C> visitor, C context)
    {
        return visitor.visitFunctionCall(this, context);
    }

    @Override
    public List<? extends Node> getChildren()
    {
        ImmutableList.Builder<Node> nodes = ImmutableList.builder();
        window.ifPresent(window -> nodes.add((Node) window));
        filter.ifPresent(nodes::add);
        nodes.addAll(arguments);
        return nodes.build();
    }

    @Override
    public boolean equals(Object obj)
    {
        if (this == obj) {
            return true;
        }
        if ((obj == null) || (getClass() != obj.getClass())) {
            return false;
        }
        FunctionCall o = (FunctionCall) obj;
        return Objects.equals(name, o.name) &&
                Objects.equals(window, o.window) &&
                Objects.equals(filter, o.filter) &&
                Objects.equals(distinct, o.distinct) &&
                Objects.equals(nullTreatment, o.nullTreatment) &&
                Objects.equals(arguments, o.arguments);
    }

    @Override
    public int hashCode()
    {
        return Objects.hash(name, distinct, nullTreatment, window, filter, arguments);
    }

    // TODO: make this a proper Tree node so that we can report error
    // locations more accurately

    @Override
    public boolean shallowEquals(Node other)
    {
        if (!sameClass(this, other)) {
            return false;
        }

        FunctionCall otherFunction = (FunctionCall) other;

        return name.equals(otherFunction.name) &&
                distinct == otherFunction.distinct &&
                nullTreatment.equals(otherFunction.nullTreatment);
    }
}
