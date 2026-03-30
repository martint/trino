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

import java.util.LinkedHashSet;
import java.util.Set;
import java.util.regex.Pattern;

import static java.util.Objects.requireNonNull;

public final class XQueryRegex
{
    private XQueryRegex() {}

    public static void validateFlags(String flags)
    {
        requireNonNull(flags, "flags is null");

        Set<Character> seen = new LinkedHashSet<>();
        for (int i = 0; i < flags.length(); i++) {
            char flag = flags.charAt(i);
            if ("imsxq".indexOf(flag) < 0) {
                throw new IllegalArgumentException("invalid XQuery regular expression flag: " + flag);
            }
            if (!seen.add(flag)) {
                throw new IllegalArgumentException("duplicate XQuery regular expression flag: " + flag);
            }
        }
    }

    public static String patternWithFlags(String pattern, String flags)
    {
        requireNonNull(pattern, "pattern is null");
        validateFlags(flags);

        if (flags.indexOf('q') >= 0) {
            pattern = Pattern.quote(pattern);
        }

        StringBuilder inlineFlags = new StringBuilder();
        for (char flag : new char[] {'i', 'm', 's', 'x'}) {
            if (flags.indexOf(flag) >= 0) {
                inlineFlags.append(flag);
            }
        }

        if (inlineFlags.isEmpty()) {
            return pattern;
        }
        return "(?" + inlineFlags + ")" + pattern;
    }
}
