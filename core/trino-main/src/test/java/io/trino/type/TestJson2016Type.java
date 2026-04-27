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
package io.trino.type;

import io.trino.json.JsonArray;
import io.trino.json.JsonInputError;
import io.trino.json.JsonItem;
import io.trino.json.JsonItems;
import io.trino.json.JsonValue;
import io.trino.json.TypedValue;
import io.trino.spi.block.Block;
import io.trino.spi.block.BlockBuilder;
import org.junit.jupiter.api.Test;

import java.io.IOException;
import java.io.Reader;
import java.io.UncheckedIOException;
import java.util.List;

import static io.trino.json.JsonInputError.JSON_ERROR;
import static io.trino.spi.type.IntegerType.INTEGER;
import static io.trino.type.Json2016Type.JSON_2016;
import static org.assertj.core.api.Assertions.assertThat;

class TestJson2016Type
{
    @Test
    void testStorageRoundTrip()
    {
        JsonValue duplicateObject = parseJson("{\"key\":1,\"key\":2}");
        JsonValue numericArray = new JsonArray(List.of(
                new TypedValue(INTEGER, 1L),
                parseValue("1000000000000"),
                parseValue("1.25")));

        BlockBuilder blockBuilder = JSON_2016.createBlockBuilder(null, 4);
        JSON_2016.writeObject(blockBuilder, duplicateObject);
        JSON_2016.writeObject(blockBuilder, numericArray);
        JSON_2016.writeObject(blockBuilder, JSON_ERROR);
        blockBuilder.appendNull();
        Block block = blockBuilder.buildValueBlock();

        assertThat(JsonItems.asJsonValue((JsonItem) JSON_2016.getObject(block, 0))).isEqualTo(JsonItems.asJsonValue(duplicateObject));
        assertThat(JsonItems.asJsonValue((JsonItem) JSON_2016.getObject(block, 1))).isEqualTo(JsonItems.asJsonValue(numericArray));
        assertThat(JSON_2016.getObject(block, 2) instanceof JsonInputError).isTrue();
        assertThat(JSON_2016.getObject(block, 3)).isNull();

        Block region = block.copyRegion(1, 2);
        assertThat(JsonItems.asJsonValue((JsonItem) JSON_2016.getObject(region, 0))).isEqualTo(JsonItems.asJsonValue(numericArray));
        assertThat(JSON_2016.getObject(region, 1) instanceof JsonInputError).isTrue();
    }

    @Test
    void testJsonErrorRoundTrip()
    {
        assertThat(JSON_ERROR instanceof JsonInputError).isTrue();

        BlockBuilder blockBuilder = JSON_2016.createBlockBuilder(null, 1);
        JSON_2016.writeObject(blockBuilder, JSON_ERROR);
        Block block = blockBuilder.buildValueBlock();

        assertThat(JSON_2016.getObject(block, 0) instanceof JsonInputError).isTrue();
    }

    @Test
    void testGetObjectValueReturnsMaterializedItem()
    {
        BlockBuilder blockBuilder = JSON_2016.createBlockBuilder(null, 3);
        JSON_2016.writeObject(blockBuilder, parseJson("{\"x\":[1,null,\"abc\"]}"));
        JSON_2016.writeObject(blockBuilder, JSON_ERROR);
        blockBuilder.appendNull();

        Block block = blockBuilder.buildValueBlock();

        assertThat(JSON_2016.getObjectValue(block, 0)).isEqualTo(parseValue("{\"x\":[1,null,\"abc\"]}"));
        assertThat(JSON_2016.getObjectValue(block, 1)).isEqualTo(JSON_ERROR);
        assertThat(JSON_2016.getObjectValue(block, 2)).isNull();
    }

    private static JsonValue parseJson(String json)
    {
        try {
            return JsonItems.parseJson(Reader.of(json));
        }
        catch (IOException e) {
            throw new UncheckedIOException(e);
        }
    }

    private static JsonValue parseValue(String json)
    {
        JsonValue item = parseJson(json);
        return JsonItems.asJsonValue(item);
    }
}
