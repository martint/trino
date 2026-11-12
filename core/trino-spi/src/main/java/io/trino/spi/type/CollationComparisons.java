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

import io.airlift.slice.Slice;

/// The engine's implementation of non-default collations.
///
/// The engine provides the one implementation as a service. The SPI loads it with its own class
/// loader, so plugins cannot replace how a collation compares strings.
public interface CollationComparisons
{
    /// The comparison a collation names.
    ///
    /// @throws IllegalArgumentException if the engine does not implement the collation
    Comparison comparison(Collation collation);

    /// Compares UTF-8 strings under one collation.
    interface Comparison
    {
        /// Compares two strings.
        int compare(Slice left, Slice right);

        /// Whether two strings are equal.
        boolean equal(Slice left, Slice right);

        /// A byte string whose unsigned byte order is the collation's order. Strings equal under
        /// the collation have equal keys, so the key is suitable for hashing.
        Slice collationKey(Slice value);
    }
}
