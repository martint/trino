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

import java.util.List;
import java.util.Objects;
import java.util.Optional;

import static java.util.Objects.requireNonNull;

public final class GenericDataType
        extends DataType
{
    private final Identifier name;
    private final List<DataTypeParameter> arguments;
    private final Optional<Identifier> collation;
    private final Optional<PadAttribute> padAttribute;

    public GenericDataType(NodeLocation location, Identifier name, List<DataTypeParameter> arguments)
    {
        this(Optional.of(location), name, arguments, Optional.empty(), Optional.empty());
    }

    public GenericDataType(Optional<NodeLocation> location, Identifier name, List<DataTypeParameter> arguments)
    {
        this(location, name, arguments, Optional.empty(), Optional.empty());
    }

    public GenericDataType(Optional<NodeLocation> location, Identifier name, List<DataTypeParameter> arguments, Optional<Identifier> collation, Optional<PadAttribute> padAttribute)
    {
        super(location);
        this.name = requireNonNull(name, "name is null");
        this.arguments = requireNonNull(arguments, "arguments is null");
        this.collation = requireNonNull(collation, "collation is null");
        this.padAttribute = requireNonNull(padAttribute, "padAttribute is null");
        if (padAttribute.isPresent() && collation.isEmpty()) {
            throw new IllegalArgumentException("pad attribute requires a collation");
        }
    }

    public Identifier getName()
    {
        return name;
    }

    public List<DataTypeParameter> getArguments()
    {
        return arguments;
    }

    /// The collation named by a trailing `COLLATE` clause, as in `varchar(10) COLLATE unicode_ci`.
    public Optional<Identifier> getCollation()
    {
        return collation;
    }

    /// The pad attribute of the `COLLATE` clause, as in `varchar(10) COLLATE unicode PAD SPACE`.
    public Optional<PadAttribute> getPadAttribute()
    {
        return padAttribute;
    }

    @Override
    public List<? extends Node> getChildren()
    {
        ImmutableList.Builder<Node> children = ImmutableList.<Node>builder()
                .add(name)
                .addAll(arguments);
        collation.ifPresent(children::add);
        return children.build();
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
        GenericDataType that = (GenericDataType) o;
        return name.equals(that.name) &&
                arguments.equals(that.arguments) &&
                collation.equals(that.collation) &&
                padAttribute.equals(that.padAttribute);
    }

    @Override
    public int hashCode()
    {
        return Objects.hash(name, arguments, collation, padAttribute);
    }

    @Override
    public boolean shallowEquals(Node other)
    {
        return sameClass(this, other) && padAttribute.equals(((GenericDataType) other).padAttribute);
    }
}
