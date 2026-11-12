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
package io.trino.spi.type;

import org.junit.jupiter.api.Test;

import static io.trino.spi.type.VarcharType.createVarcharType;
import static org.assertj.core.api.Assertions.assertThatThrownBy;

class TestCollatedVarcharTypeWithoutEngine
{
    @Test
    void testEngineRequired()
    {
        // without the engine, which implements collations, a collated type cannot be created,
        // and each attempt reports why
        for (int attempt = 0; attempt < 2; attempt++) {
            assertThatThrownBy(() -> createVarcharType(10, Collation.of("unicode_ci")))
                    .isInstanceOf(IllegalStateException.class)
                    .hasMessageContaining("Collated types require the Trino engine");
        }
    }
}
