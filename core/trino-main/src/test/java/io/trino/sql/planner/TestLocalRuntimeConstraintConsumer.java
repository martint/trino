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
package io.trino.sql.planner;

import com.google.common.collect.ImmutableList;
import io.airlift.units.DataSize;
import io.trino.operator.RuntimeConstraintSourceConsumer.Observation;
import io.trino.spi.predicate.Domain;
import org.junit.jupiter.api.Test;

import java.util.List;
import java.util.concurrent.atomic.AtomicReference;

import static io.airlift.units.DataSize.Unit.KILOBYTE;
import static io.trino.spi.type.IntegerType.INTEGER;
import static org.assertj.core.api.Assertions.assertThat;

public class TestLocalRuntimeConstraintConsumer
{
    @Test
    public void testAggregatesPartitionsAndObservationsByLane()
    {
        AtomicReference<List<Domain>> domains = new AtomicReference<>();
        AtomicReference<Observation> observation = new AtomicReference<>();
        LocalRuntimeConstraintConsumer consumer = new LocalRuntimeConstraintConsumer(
                ImmutableList.of(3, 7),
                ImmutableList.of(INTEGER, INTEGER),
                (result, observed) -> {
                    domains.set(result);
                    observation.set(observed);
                },
                DataSize.of(100, KILOBYTE));
        consumer.setPartitionCount(2);

        consumer.addPartition(
                ImmutableList.of(
                        Domain.singleValue(INTEGER, 10L),
                        Domain.singleValue(INTEGER, 15L)),
                new Observation(true, ImmutableList.of(false, true)));
        assertThat(domains).hasValue(null);

        consumer.addPartition(
                ImmutableList.of(
                        Domain.singleValue(INTEGER, 20L),
                        Domain.singleValue(INTEGER, 30L)),
                new Observation(true, ImmutableList.of(true, false)));

        assertThat(domains).hasValue(ImmutableList.of(
                Domain.multipleValues(INTEGER, ImmutableList.of(10L, 20L)),
                Domain.multipleValues(INTEGER, ImmutableList.of(15L, 30L))));
        assertThat(observation).hasValue(new Observation(true, ImmutableList.of(true, true)));
    }

    @Test
    public void testNoneLaneDoesNotDiscardSiblingLane()
    {
        AtomicReference<List<Domain>> domains = new AtomicReference<>();
        LocalRuntimeConstraintConsumer consumer = new LocalRuntimeConstraintConsumer(
                ImmutableList.of(0, 1),
                ImmutableList.of(INTEGER, INTEGER),
                (result, _) -> domains.set(result),
                DataSize.of(100, KILOBYTE));
        consumer.setPartitionCount(1);

        consumer.addPartition(
                ImmutableList.of(Domain.none(INTEGER), Domain.singleValue(INTEGER, 7L)),
                new Observation(true, ImmutableList.of(true, false)));

        assertThat(domains).hasValue(ImmutableList.of(Domain.none(INTEGER), Domain.singleValue(INTEGER, 7L)));
    }

    @Test
    public void testNoOperatorsPublishesEmptyBuild()
    {
        AtomicReference<List<Domain>> domains = new AtomicReference<>();
        LocalRuntimeConstraintConsumer consumer = new LocalRuntimeConstraintConsumer(
                ImmutableList.of(0),
                ImmutableList.of(INTEGER),
                (result, _) -> domains.set(result),
                DataSize.of(100, KILOBYTE));

        consumer.setPartitionCount(0);

        assertThat(domains).hasValue(ImmutableList.of(Domain.none(INTEGER)));
    }
}
