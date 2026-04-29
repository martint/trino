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
package io.trino.json.ir;

import com.fasterxml.jackson.annotation.JsonCreator;
import com.fasterxml.jackson.annotation.JsonProperty;
import com.google.common.collect.ImmutableList;
import io.airlift.slice.Slices;
import io.trino.json.JsonItemEncoding;
import io.trino.json.MaterializedJsonValue;
import io.trino.spi.type.Type;

import java.util.Base64;
import java.util.List;
import java.util.Objects;
import java.util.Optional;

import static com.google.common.collect.ImmutableList.toImmutableList;
import static java.util.Objects.requireNonNull;

public final class IrConstantJsonSequence
        implements IrPathNode
{
    private static final Base64.Encoder BASE64_ENCODER = Base64.getEncoder();
    private static final Base64.Decoder BASE64_DECODER = Base64.getDecoder();

    public static final IrConstantJsonSequence EMPTY_SEQUENCE = new IrConstantJsonSequence(ImmutableList.of(), Optional.empty());

    private final List<MaterializedJsonValue> sequence;
    private final Optional<Type> type;

    public static IrConstantJsonSequence singletonSequence(MaterializedJsonValue item, Optional<Type> type)
    {
        return new IrConstantJsonSequence(ImmutableList.of(item), type);
    }

    @JsonCreator
    public static IrConstantJsonSequence fromJson(@JsonProperty("sequence") List<String> sequence, @JsonProperty("type") Type type)
    {
        return new IrConstantJsonSequence(
                requireNonNull(sequence, "sequence is null").stream()
                        .map(IrConstantJsonSequence::decodeItem)
                        .collect(toImmutableList()),
                Optional.ofNullable(type));
    }

    public IrConstantJsonSequence(List<MaterializedJsonValue> sequence, Optional<Type> type)
    {
        this.sequence = ImmutableList.copyOf(requireNonNull(sequence, "sequence is null"));
        this.type = requireNonNull(type, "type is null");
    }

    public List<MaterializedJsonValue> sequence()
    {
        return sequence;
    }

    @Override
    public Optional<Type> type()
    {
        return type;
    }

    @JsonProperty("sequence")
    public List<String> getSequenceAsJson()
    {
        return sequence.stream()
                .map(IrConstantJsonSequence::encodeItem)
                .collect(toImmutableList());
    }

    @JsonProperty
    public Type getType()
    {
        return type.orElse(null);
    }

    @Override
    public <R, C> R accept(IrJsonPathVisitor<R, C> visitor, C context)
    {
        return visitor.visitIrConstantJsonSequence(this, context);
    }

    @Override
    public boolean equals(Object obj)
    {
        if (this == obj) {
            return true;
        }
        if (!(obj instanceof IrConstantJsonSequence other)) {
            return false;
        }
        return Objects.equals(sequence, other.sequence) &&
                Objects.equals(type, other.type);
    }

    @Override
    public int hashCode()
    {
        return Objects.hash(sequence, type);
    }

    private static String encodeItem(MaterializedJsonValue item)
    {
        return BASE64_ENCODER.encodeToString(JsonItemEncoding.encode(item).getBytes());
    }

    private static MaterializedJsonValue decodeItem(String value)
    {
        return JsonItemEncoding.decodeValue(Slices.wrappedBuffer(BASE64_DECODER.decode(requireNonNull(value, "value is null"))));
    }
}
