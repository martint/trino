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

import java.util.Set;

import static java.util.Objects.requireNonNull;

/// A named rule for comparing character strings.
///
/// A collation is a value: it names a comparison but does not implement it. The default
/// collation, [#UCS_BASIC], orders strings by Unicode code point, which for valid UTF-8 is the
/// order of their bytes. The engine implements every other collation, and plugins see collations
/// only as part of character string types. Two collations are the same collation exactly when
/// their canonical names are equal.
public final class Collation
{
    static final String UCS_BASIC_NAME = "ucs_basic";

    public static final Collation UCS_BASIC = new Collation(UCS_BASIC_NAME);

    // The words the SQL parser reserves, which a collation name must be quoted to be. The SPI
    // cannot depend on the parser, so a test verifies that this matches the parser's list.
    private static final Set<String> RESERVED_WORDS = Set.of((
            "alter and as auto between by case cast constraint create cross cube current_catalog current_date " +
                    "current_path current_role current_schema current_time current_timestamp current_user deallocate " +
                    "delete describe distinct drop else end escape except exists extract false for from full group " +
                    "grouping having in inner insert intersect into is join json_array json_exists json_object " +
                    "json_query json_serialize json_table json_value left like listagg localtime localtimestamp " +
                    "natural normalize not null on or order outer overlaps prepare recursive right rollup select skip " +
                    "table then trim true uescape union unnest using values when where with").split(" "));

    private final String name;

    private Collation(String name)
    {
        this.name = requireNonNull(name, "name is null");
    }

    /// The collation with the given canonical name, which is a lower-case letter followed by
    /// lower-case letters, digits, or underscores. Whether the engine implements the collation is
    /// decided when a type is resolved.
    public static Collation of(String name)
    {
        requireNonNull(name, "name is null");
        if (name.equals(UCS_BASIC_NAME)) {
            return UCS_BASIC;
        }
        if (!isValidName(name)) {
            throw new IllegalArgumentException("Invalid collation name: " + name);
        }
        return new Collation(name);
    }

    // Whether a name is a canonical collation name: a lower-case letter followed by lower-case
    // letters, digits, or underscores. Such a name is a valid SQL identifier, which toSql quotes
    // when it is a reserved word, so a type's COLLATE clause round-trips through the SQL type parser.
    static boolean isValidName(String name)
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

    public String name()
    {
        return name;
    }

    /// The SQL spelling of this collation's name in a `COLLATE` clause.
    public String toSql()
    {
        return toSql(name);
    }

    static String toSql(String name)
    {
        return RESERVED_WORDS.contains(name) ? "\"" + name + "\"" : name;
    }

    // Whether a collation name is a word the SQL parser reserves, which must be quoted
    static boolean isReservedWord(String name)
    {
        return RESERVED_WORDS.contains(name);
    }

    /// Whether this is the default, code-point order collation.
    public boolean isDefault()
    {
        return name.equals(UCS_BASIC_NAME);
    }

    @Override
    public boolean equals(Object o)
    {
        return o instanceof Collation that && name.equals(that.name);
    }

    @Override
    public int hashCode()
    {
        return name.hashCode();
    }

    @Override
    public String toString()
    {
        return name;
    }
}
