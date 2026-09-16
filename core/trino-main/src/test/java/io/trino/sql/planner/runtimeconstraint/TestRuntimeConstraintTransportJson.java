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

import com.fasterxml.jackson.databind.json.JsonMapper;
import com.google.common.collect.ImmutableList;
import com.google.common.collect.ImmutableMap;
import io.airlift.json.JsonCodec;
import io.airlift.json.JsonCodecFactory;
import io.airlift.json.JsonMapperProvider;
import io.trino.block.BlockJsonSerde;
import io.trino.spi.block.Block;
import io.trino.spi.type.Type;
import io.trino.type.TypeDeserializer;
import org.junit.jupiter.api.Test;

import static io.trino.metadata.InternalBlockEncodingSerde.TESTING_BLOCK_ENCODING_SERDE;
import static io.trino.spi.predicate.Domain.singleValue;
import static io.trino.spi.type.BigintType.BIGINT;
import static io.trino.sql.planner.runtimeconstraint.RuntimeConstraintNullMatchMode.ORDINARY;
import static io.trino.type.InternalTypeManager.TESTING_TYPE_MANAGER;
import static org.assertj.core.api.Assertions.assertThat;

public class TestRuntimeConstraintTransportJson
{
    private static final JsonCodecFactory CODEC_FACTORY;

    static {
        JsonMapper mapper = new JsonMapperProvider()
                .withJsonDeserializers(ImmutableMap.of(
                        Type.class, new TypeDeserializer(TESTING_TYPE_MANAGER),
                        Block.class, new BlockJsonSerde.Deserializer(TESTING_BLOCK_ENCODING_SERDE)))
                .withJsonSerializers(ImmutableMap.of(
                        Block.class, new BlockJsonSerde.Serializer(TESTING_BLOCK_ENCODING_SERDE)))
                .get();
        CODEC_FACTORY = new JsonCodecFactory(mapper);
    }

    @Test
    public void testContributionResponseRoundTrip()
    {
        RuntimeConstraintContribution contribution = new RuntimeConstraintContribution(
                new ProducerGroupId("group"),
                new ProducerBindingId("binding"),
                2,
                3,
                1,
                payload(11));
        RuntimeConstraintContributionBatch batch = new RuntimeConstraintContributionBatch(RuntimeConstraintProtocol.CURRENT_FORMAT_VERSION, 4, 7, ImmutableList.of(contribution));

        JsonCodec<RuntimeConstraintContributionBatch> codec = CODEC_FACTORY.jsonCodec(RuntimeConstraintContributionBatch.class);
        RuntimeConstraintContributionBatch copy = codec.fromJson(codec.toJson(batch));

        assertThat(copy).isEqualTo(batch);
    }

    @Test
    public void testUpdateBatchRoundTrip()
    {
        RuntimeConstraintId constraintId = new RuntimeConstraintId("constraint");
        RuntimeConstraintUpdateBatch batch = new RuntimeConstraintUpdateBatch(
                1,
                9,
                7,
                ImmutableList.of(RuntimeConstraintSnapshot.finalSnapshot(constraintId, 7, 1, payload(13))));

        JsonCodec<RuntimeConstraintUpdateBatch> codec = CODEC_FACTORY.jsonCodec(RuntimeConstraintUpdateBatch.class);
        String json = codec.toJson(batch);
        assertThat(json).doesNotContain("retainedSizeInBytes");
        assertThat(codec.fromJson(json)).isEqualTo(batch);
    }

    private static RuntimeMembershipPayload payload(long value)
    {
        return new RuntimeMembershipPayload(ImmutableList.of(singleValue(BIGINT, value)), ORDINARY);
    }
}
