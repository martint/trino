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
package io.trino.type.collation;

import io.trino.spi.type.Collation;

import static java.util.Locale.ENGLISH;

/// The rules for collation names in SQL.
public final class CollationNames
{
    private CollationNames() {}

    /// Canonicalizes a collation name, which is a case-insensitive identifier.
    public static String canonicalName(String name)
    {
        return name.toLowerCase(ENGLISH);
    }

    /// Whether a name is a canonical collation name: a lower-case letter followed by lower-case
    /// letters, digits, or underscores.
    public static boolean isValidName(String name)
    {
        if (name.isEmpty() || name.charAt(0) < 'a' || name.charAt(0) > 'z') {
            return false;
        }
        for (int i = 1; i < name.length(); i++) {
            char c = name.charAt(i);
            if (!((c >= 'a' && c <= 'z') || (c >= '0' && c <= '9') || c == '_')) {
                return false;
            }
        }
        return true;
    }

    /// Whether a canonical collation name must be quoted, because the SQL parser reserves it.
    public static boolean requiresQuoting(String name)
    {
        return !Collation.of(name).toSql().equals(name);
    }
}
