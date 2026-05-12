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

import java.util.List;
import java.util.Objects;

/**
 * SQL spec {@code <null predicate part 2> ::= IS [NOT] NULL}. The {@code negated} flag records
 * the user's in-place {@code NOT} (i.e. {@code IS NOT NULL}); an outer {@code NOT (x IS NULL)}
 * remains a separate {@link NotExpression} wrapping a non-negated {@code IsNullPredicate}.
 */
public final class IsNullPredicate
        extends Predicate
{
    private final boolean negated;

    public IsNullPredicate(NodeLocation location, boolean negated)
    {
        super(location);
        this.negated = negated;
    }

    @Deprecated
    public IsNullPredicate(boolean negated)
    {
        this(null, negated);
    }

    public boolean isNegated()
    {
        return negated;
    }

    @Override
    public List<? extends Node> getChildren()
    {
        return List.of();
    }

    @Override
    protected <R, C> R accept(AstVisitor<R, C> visitor, C context)
    {
        return visitor.visitIsNullPredicate(this, context);
    }

    @Override
    public boolean shallowEquals(Node other)
    {
        return sameClass(this, other) && negated == ((IsNullPredicate) other).negated;
    }

    @Override
    public boolean equals(Object o)
    {
        return o instanceof IsNullPredicate that && that.negated == negated;
    }

    @Override
    public int hashCode()
    {
        return Objects.hash(negated);
    }

    @Override
    public String toString()
    {
        return negated ? "IS NOT NULL" : "IS NULL";
    }
}
