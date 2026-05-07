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

import org.junit.jupiter.api.Test;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;

public class TestXQueryRegex
{
    @Test
    public void testPatternWithFlags()
    {
        assertThat(XQueryRegex.patternWithFlags("^a", "i"))
                .isEqualTo("(?i)^a");

        assertThat(XQueryRegex.patternWithFlags("^b$", "m"))
                .isEqualTo("(?m)^b$");

        assertThat(XQueryRegex.patternWithFlags("a.*c", "s"))
                .isEqualTo("(?s)a.*c");

        assertThat(XQueryRegex.patternWithFlags("a b c", "x"))
                .isEqualTo("(?x)a b c");

        assertThat(XQueryRegex.patternWithFlags("a.c", "q"))
                .isEqualTo("a\\.c");

        assertThat(XQueryRegex.patternWithFlags("abc", "iq"))
                .isEqualTo("(?i)abc");

        // q + x: '#' starts a comment under x, so escape it for literal matching
        assertThat(XQueryRegex.patternWithFlags("a#b", "qx"))
                .isEqualTo("(?x)a\\#b");
    }

    @Test
    public void testInvalidFlags()
    {
        assertThatThrownBy(() -> XQueryRegex.validateFlags("z"))
                .isInstanceOf(IllegalArgumentException.class)
                .hasMessage("invalid XQuery regular expression flag: z");

        assertThatThrownBy(() -> XQueryRegex.validateFlags("ii"))
                .isInstanceOf(IllegalArgumentException.class)
                .hasMessage("duplicate XQuery regular expression flag: i");
    }
}
