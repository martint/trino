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

import io.airlift.slice.Slices;
import org.junit.jupiter.api.Test;

import java.util.ArrayList;
import java.util.List;

import static org.assertj.core.api.Assertions.assertThat;

final class TestJsonBlockBuilder
        extends AbstractTestBlockBuilder<TestJsonBlockBuilder.JsonEntry>
{
    private static final int JSON_ENTRY_SIZE = Byte.BYTES;
    private static final int NULL_JSON_FIELD_ENTRY_SIZE = Integer.BYTES + Byte.BYTES;

    @Test
    public void testAppendRangeUpdatesStatus()
    {
        int length = 4;
        JsonBlock source = createAllNullSourceBlock(length + 1);
        PageBuilderStatus pageBuilderStatus = new PageBuilderStatus(Integer.MAX_VALUE);
        JsonBlockBuilder blockBuilder = new JsonBlockBuilder(pageBuilderStatus.createBlockBuilderStatus(), 1);

        blockBuilder.appendRange(source, 1, length);

        assertThat(pageBuilderStatus.getSizeInBytes())
                .isEqualTo((long) length * (JSON_ENTRY_SIZE + NULL_JSON_FIELD_ENTRY_SIZE));
    }

    @Test
    public void testAppendPositionsUpdatesStatusWithOffsetSource()
    {
        int length = 3;
        JsonBlock source = createAllNullSourceBlock(length + 3).getRegion(1, length + 1);
        PageBuilderStatus pageBuilderStatus = new PageBuilderStatus(Integer.MAX_VALUE);
        JsonBlockBuilder blockBuilder = new JsonBlockBuilder(pageBuilderStatus.createBlockBuilderStatus(), 1);

        blockBuilder.appendPositions(source, new int[] {-1, 3, 0, 2, -1}, 1, length);

        assertThat(pageBuilderStatus.getSizeInBytes())
                .isEqualTo((long) length * (JSON_ENTRY_SIZE + NULL_JSON_FIELD_ENTRY_SIZE));
    }

    @Test
    public void testResetToRecomputesNullFlags()
    {
        JsonBlockBuilder blockBuilder = new JsonBlockBuilder(null, 2);
        blockBuilder.appendNull();
        blockBuilder.resetTo(0);
        blockBuilder.writeEntry(Slices.utf8Slice("{\"x\":1}"));

        JsonBlock block = blockBuilder.buildValueBlock();

        assertThat(block.mayHaveNull()).isFalse();
        assertThat(block.isNull(0)).isFalse();
    }

    @Test
    public void testCopyWithAppendedNullOnSlicedBlock()
    {
        JsonBlockBuilder blockBuilder = new JsonBlockBuilder(null, 4);
        blockBuilder.writeEntry(Slices.utf8Slice("{\"x\":10}"));
        blockBuilder.writeEntry(Slices.utf8Slice("{\"x\":20}"));
        blockBuilder.writeEntry(Slices.utf8Slice("{\"x\":30}"));
        blockBuilder.writeEntry(Slices.utf8Slice("{\"x\":40}"));

        JsonBlock sliced = blockBuilder.buildValueBlock().getRegion(1, 2);
        JsonBlock appended = sliced.copyWithAppendedNull();

        assertThat(appended.getPositionCount()).isEqualTo(3);
        assertThat(appended.getParsedItemSlice(0).toStringUtf8()).isEqualTo("{\"x\":20}");
        assertThat(appended.getParsedItemSlice(1).toStringUtf8()).isEqualTo("{\"x\":30}");
        assertThat(appended.isNull(2)).isTrue();
    }

    @Override
    protected BlockBuilder createBlockBuilder()
    {
        return new JsonBlockBuilder(null, 1);
    }

    @Override
    protected List<JsonEntry> getTestValues()
    {
        return List.of(
                new JsonEntry("typed-a"),
                new JsonEntry("{\"b\":2}"),
                new JsonEntry("typed-c"),
                new JsonEntry("{\"d\":4}"),
                new JsonEntry("typed-e"));
    }

    @Override
    protected JsonEntry getUnusedTestValue()
    {
        return new JsonEntry("typed-unused");
    }

    @Override
    protected ValueBlock blockFromValues(Iterable<JsonEntry> values)
    {
        JsonBlockBuilder blockBuilder = new JsonBlockBuilder(null, 1);
        for (JsonEntry value : values) {
            if (value == null) {
                blockBuilder.appendNull();
            }
            else {
                blockBuilder.writeEntry(Slices.utf8Slice(value.parsedItem()));
            }
        }
        return blockBuilder.buildValueBlock();
    }

    @Override
    protected List<JsonEntry> blockToValues(ValueBlock valueBlock)
    {
        JsonBlock jsonBlock = (JsonBlock) valueBlock;
        List<JsonEntry> actualValues = new ArrayList<>(jsonBlock.getPositionCount());
        for (int i = 0; i < jsonBlock.getPositionCount(); i++) {
            if (jsonBlock.isNull(i)) {
                actualValues.add(null);
            }
            else {
                actualValues.add(new JsonEntry(jsonBlock.getParsedItemSlice(i).toStringUtf8()));
            }
        }
        return actualValues;
    }

    private static JsonBlock createAllNullSourceBlock(int positions)
    {
        JsonBlockBuilder blockBuilder = new JsonBlockBuilder(null, 1);
        for (int i = 0; i < positions; i++) {
            blockBuilder.appendNull();
        }
        return blockBuilder.buildValueBlock();
    }

    record JsonEntry(String parsedItem) {}
}
