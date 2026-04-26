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

import io.airlift.slice.Slice;
import io.trino.json.EncodedJsonItem;
import io.trino.json.JsonInputError;
import io.trino.json.JsonItem;
import io.trino.json.JsonItemEncoding;
import io.trino.json.JsonItems;
import io.trino.json.JsonValueView;
import io.trino.spi.block.Block;
import io.trino.spi.block.BlockBuilder;
import io.trino.spi.block.VariableWidthBlock;
import io.trino.spi.block.VariableWidthBlockBuilder;
import io.trino.spi.type.AbstractVariableWidthType;
import io.trino.spi.type.TypeSignature;

import static io.trino.json.JsonInputError.JSON_ERROR;

public class Json2016Type
        extends AbstractVariableWidthType
{
    public static final String NAME = "json2016";
    public static final Json2016Type JSON_2016 = new Json2016Type();

    public Json2016Type()
    {
        super(new TypeSignature(NAME), Object.class);
    }

    @Override
    public String getDisplayName()
    {
        return NAME;
    }

    @Override
    public Object getObjectValue(Block block, int position)
    {
        Object object = getObject(block, position);
        if (object == null) {
            return null;
        }
        if (JsonInputError.matches(object)) {
            return JSON_ERROR;
        }
        return JsonItems.materialize((JsonItem) object);
    }

    @Override
    public Object getObject(Block block, int position)
    {
        if (block.isNull(position)) {
            return null;
        }

        VariableWidthBlock valueBlock = (VariableWidthBlock) block.getUnderlyingValueBlock();
        Slice encoding = valueBlock.getSlice(block.getUnderlyingValuePosition(position));
        return JsonValueView.root(encoding);
    }

    @Override
    public void writeObject(BlockBuilder blockBuilder, Object value)
    {
        Slice encoding = switch (value) {
            case JsonValueView view -> view.copyEncoding();
            case EncodedJsonItem encoded -> encoded.encoding();
            case JsonItem item -> JsonItemEncoding.encode(JsonItems.materialize(item));
            default -> throw new IllegalArgumentException("Unsupported JSON2016 value type: " + value.getClass().getName());
        };
        ((VariableWidthBlockBuilder) blockBuilder).writeEntry(encoding);
    }
}
