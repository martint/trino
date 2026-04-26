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
package io.trino.spi.block;

import io.airlift.slice.DynamicSliceOutput;
import io.airlift.slice.Slices;
import org.junit.jupiter.api.Test;

import static org.assertj.core.api.Assertions.assertThat;

final class TestJsonBlockEncoding
{
    @Test
    public void testRoundTrip()
    {
        JsonBlockBuilder blockBuilder = new JsonBlockBuilder(null, 4);
        blockBuilder.writeEntry(Slices.utf8Slice("typed-a"));
        blockBuilder.writeEntry(Slices.utf8Slice("{\"b\":2}"));
        blockBuilder.appendNull();
        blockBuilder.writeEntry(Slices.utf8Slice("typed-c"));

        JsonBlock expected = blockBuilder.buildValueBlock();

        TestingBlockEncodingSerde serde = new TestingBlockEncodingSerde();
        DynamicSliceOutput output = new DynamicSliceOutput(256);
        serde.writeBlock(output, expected);

        JsonBlock actual = (JsonBlock) serde.readBlock(output.slice().getInput());

        assertThat(actual.getPositionCount()).isEqualTo(expected.getPositionCount());
        assertThat(actual.getParsedItemSlice(0).toStringUtf8()).isEqualTo("typed-a");
        assertThat(actual.getParsedItemSlice(1).toStringUtf8()).isEqualTo("{\"b\":2}");
        assertThat(actual.isNull(2)).isTrue();
        assertThat(actual.getParsedItemSlice(3).toStringUtf8()).isEqualTo("typed-c");
    }
}
