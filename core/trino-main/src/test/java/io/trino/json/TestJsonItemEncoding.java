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
package io.trino.json;

import io.trino.json.JsonItemEncoding.ItemTag;
import io.trino.json.JsonItemEncoding.TypeTag;
import org.junit.jupiter.api.Test;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;

public class TestJsonItemEncoding
{
    @Test
    public void testItemTagRoundTrip()
    {
        for (ItemTag tag : ItemTag.values()) {
            assertThat(ItemTag.fromEncoded(tag.encoded())).isEqualTo(tag);
        }
    }

    @Test
    public void testItemTagFromEncodedRejectsUnknown()
    {
        assertThatThrownBy(() -> ItemTag.fromEncoded((byte) 0))
                .isInstanceOf(IllegalArgumentException.class);
        assertThatThrownBy(() -> ItemTag.fromEncoded((byte) 99))
                .isInstanceOf(IllegalArgumentException.class);
    }

    @Test
    public void testTypeTagRoundTrip()
    {
        for (TypeTag tag : TypeTag.values()) {
            assertThat(TypeTag.fromEncoded(tag.encoded())).isEqualTo(tag);
        }
    }

    @Test
    public void testTypeTagFromEncodedRejectsUnknown()
    {
        assertThatThrownBy(() -> TypeTag.fromEncoded((byte) 0))
                .isInstanceOf(IllegalArgumentException.class);
        assertThatThrownBy(() -> TypeTag.fromEncoded((byte) 99))
                .isInstanceOf(IllegalArgumentException.class);
    }
}
