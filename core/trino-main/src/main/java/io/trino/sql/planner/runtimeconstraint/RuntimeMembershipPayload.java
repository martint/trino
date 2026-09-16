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
package io.trino.sql.planner.runtimeconstraint;

import com.google.common.collect.ImmutableList;
import com.google.errorprone.annotations.Immutable;
import io.trino.spi.predicate.Domain;

import java.util.List;

import static com.google.common.base.Preconditions.checkArgument;
import static java.util.Objects.requireNonNull;

@Immutable
public record RuntimeMembershipPayload(
        List<Domain> scalarDomains,
        RuntimeConstraintNullMatchMode nullMatchMode,
        boolean sawInputRow,
        List<Boolean> sawNulls)
        implements RuntimeConstraintPayload
{
    public RuntimeMembershipPayload(List<Domain> scalarDomains, RuntimeConstraintNullMatchMode nullMatchMode)
    {
        this(scalarDomains,
                nullMatchMode,
                scalarDomains.stream().anyMatch(domain -> !domain.isNone()),
                scalarDomains.stream().map(Domain::isNullAllowed).toList());
    }

    public RuntimeMembershipPayload
    {
        scalarDomains = ImmutableList.copyOf(requireNonNull(scalarDomains, "scalarDomains is null"));
        checkArgument(!scalarDomains.isEmpty(), "scalarDomains is empty");
        requireNonNull(nullMatchMode, "nullMatchMode is null");
        sawNulls = ImmutableList.copyOf(requireNonNull(sawNulls, "sawNulls is null"));
        checkArgument(sawNulls.size() == scalarDomains.size(), "sawNulls and scalarDomains have different sizes");
        checkArgument(sawInputRow || sawNulls.stream().noneMatch(Boolean::booleanValue), "empty input cannot contain null");
    }

    @Override
    public long getRetainedSizeInBytes()
    {
        return scalarDomains.stream()
                .mapToLong(Domain::getRetainedSizeInBytes)
                .sum();
    }
}
