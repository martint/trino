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
import io.trino.sql.ir.IntervalLiteral.IntervalField;
import io.trino.sql.ir.IntervalLiteral.Sign;

import javax.annotation.concurrent.Immutable;

import java.util.Objects;
import java.util.Optional;

import static java.util.Objects.requireNonNull;

@Immutable
public class IntervalLiteral
        extends Literal
{
    private final String value;
    private final Sign sign;
    private final IntervalField startField;
    private final Optional<IntervalField> endField;

    public IntervalLiteral(String value, Sign sign, IntervalField startField)
    {
        this(value, sign, startField, Optional.empty());
    }

    @JsonCreator
    public IntervalLiteral(
            @JsonProperty("value") String value,
            @JsonProperty("sign") Sign sign,
            @JsonProperty("startField") IntervalField startField,
            @JsonProperty("endField") Optional<IntervalField> endField)
    {
        requireNonNull(value, "value is null");
        requireNonNull(sign, "sign is null");
        requireNonNull(startField, "startField is null");
        requireNonNull(endField, "endField is null");

        this.value = value;
        this.sign = sign;
        this.startField = startField;
        this.endField = endField;
    }

    @JsonProperty
    public String getValue()
    {
        return value;
    }

    @JsonProperty
    public Sign getSign()
    {
        return sign;
    }

    @JsonProperty
    public IntervalField getStartField()
    {
        return startField;
    }

    @JsonProperty
    public Optional<IntervalField> getEndField()
    {
        return endField;
    }

    public boolean isYearToMonth()
    {
        return startField == IntervalField.YEAR || startField == IntervalField.MONTH;
    }

    @Override
    public <R, C> R accept(IrVisitor<R, C> visitor, C context)
    {
        return visitor.visitIntervalLiteral(this, context);
    }

    @Override
    public int hashCode()
    {
        return Objects.hash(value, sign, startField, endField);
    }

    @Override
    public boolean equals(Object obj)
    {
        if (this == obj) {
            return true;
        }
        if (obj == null || getClass() != obj.getClass()) {
            return false;
        }
        IntervalLiteral other = (IntervalLiteral) obj;
        return Objects.equals(this.value, other.value) &&
                this.sign == other.sign &&
                this.startField == other.startField &&
                Objects.equals(this.endField, other.endField);
    }

    @Override
    public boolean shallowEquals(Node other)
    {
        if (!sameClass(this, other)) {
            return false;
        }

        IntervalLiteral otherLiteral = (IntervalLiteral) other;
        return Objects.equals(this.value, otherLiteral.value) &&
                this.sign == otherLiteral.sign &&
                this.startField == otherLiteral.startField &&
                Objects.equals(this.endField, otherLiteral.endField);
    }
}
