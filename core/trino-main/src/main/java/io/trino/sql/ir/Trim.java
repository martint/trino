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
import io.trino.sql.ir.Trim.Specification;

import javax.annotation.concurrent.Immutable;

import java.util.List;
import java.util.Objects;
import java.util.Optional;

import static java.util.Objects.requireNonNull;

@Immutable
public class Trim
        extends Expression
{
    private final Specification specification;
    private final Expression trimSource;
    private final Optional<Expression> trimCharacter;

    @JsonCreator
    public Trim(
            @JsonProperty("specification") Specification specification,
            @JsonProperty("trimSource") Expression trimSource,
            @JsonProperty("trimCharacter") Optional<Expression> trimCharacter)
    {
        this.specification = requireNonNull(specification, "specification is null");
        this.trimSource = requireNonNull(trimSource, "trimSource is null");
        this.trimCharacter = requireNonNull(trimCharacter, "trimCharacter is null");
    }

    @JsonProperty
    public Specification getSpecification()
    {
        return specification;
    }

    @JsonProperty
    public Expression getTrimSource()
    {
        return trimSource;
    }

    @JsonProperty
    public Optional<Expression> getTrimCharacter()
    {
        return trimCharacter;
    }

    @Override
    public <R, C> R accept(IrVisitor<R, C> visitor, C context)
    {
        return visitor.visitTrim(this, context);
    }

    @Override
    public List<? extends Node> getChildren()
    {
        ImmutableList.Builder<Node> nodes = ImmutableList.builder();
        nodes.add(trimSource);
        trimCharacter.ifPresent(nodes::add);
        return nodes.build();
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

        Trim that = (Trim) o;
        return specification == that.specification &&
                Objects.equals(trimSource, that.trimSource) &&
                Objects.equals(trimCharacter, that.trimCharacter);
    }

    @Override
    public int hashCode()
    {
        return Objects.hash(specification, trimSource, trimCharacter);
    }

    @Override
    public boolean shallowEquals(Node other)
    {
        if (!sameClass(this, other)) {
            return false;
        }

        Trim otherTrim = (Trim) other;
        return specification == otherTrim.specification;
    }
}
