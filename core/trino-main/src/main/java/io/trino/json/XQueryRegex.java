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

import static java.util.Objects.requireNonNull;

/**
 * Translates XQuery / SQL:2023 {@code like_regex} patterns for execution by Trino's regex engine
 * (Joni or RE2J).
 *
 * <p><b>Known dialect gaps:</b> SQL:2023 {@code like_regex} defers to XQuery F&amp;O 3.0 regex,
 * but the pattern is handed to Trino's {@code regexp_like}, which has different semantics for
 * some escapes:
 * <ul>
 * <li>{@code \s}, {@code \d}, {@code \w}: ASCII-only in both Joni and RE2J; Unicode in XQuery.
 *     Patterns relying on Unicode category matching will return unexpected results.</li>
 * <li>{@code \i} (XML name-start char), {@code \I} (complement), {@code \c} (XML name char),
 *     {@code \C} (complement): XML name-class escapes don't exist in Java regex and will raise
 *     a pattern-syntax error. Prefer explicit character classes.</li>
 * <li>{@code (?x)}: XQuery defines flag {@code x} as "whitespace is ignored, {@code #} begins a
 *     comment." Joni supports this identically to Java. RE2J does not support {@code (?x)} at
 *     all; patterns using the {@code x} flag may fail to compile under RE2J.</li>
 * </ul>
 *
 * <p><b>Flag extension:</b> the {@code q} flag ("treat pattern as a literal string") is not in
 * SQL:2023 §9.39 SR but is accepted as a Trino extension; its translation uses portable regex
 * escaping so the output compiles on both Joni and RE2J.
 */
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
            // Escape regex metacharacters manually instead of relying on Java-specific `\Q...\E`,
            // which RE2J does not recognize. Covers every ASCII metacharacter that has special
            // meaning in either Joni or RE2J so the resulting pattern is engine-portable.
            pattern = escapeAsLiteral(pattern);
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

    private static String escapeAsLiteral(String pattern)
    {
        StringBuilder builder = new StringBuilder(pattern.length() + 8);
        for (int i = 0; i < pattern.length(); i++) {
            char c = pattern.charAt(i);
            // Escape every ASCII metacharacter recognized by either Joni or RE2J. The '#' is
            // significant under the 'x' flag (starts a comment); escape it too so 'q+x' matches
            // the literal pattern. Non-ASCII characters need no escaping.
            if (c < 128 && "\\.[](){}^$|?*+-#".indexOf(c) >= 0) {
                builder.append('\\');
            }
            builder.append(c);
        }
        return builder.toString();
    }
}
