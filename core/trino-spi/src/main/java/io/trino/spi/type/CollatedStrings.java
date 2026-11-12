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
import io.airlift.slice.XxHash64;
import io.trino.spi.function.InvocationConvention;
import io.trino.spi.function.OperatorMethodHandle;
import io.trino.spi.type.CollationComparisons.Comparison;

import java.lang.invoke.MethodHandle;
import java.lang.invoke.MethodHandles;
import java.util.Iterator;
import java.util.ServiceLoader;

import static io.trino.spi.function.InvocationConvention.InvocationArgumentConvention.NEVER_NULL;
import static io.trino.spi.function.InvocationConvention.InvocationReturnConvention.FAIL_ON_NULL;
import static io.trino.spi.function.InvocationConvention.simpleConvention;
import static java.lang.invoke.MethodHandles.insertArguments;
import static java.lang.invoke.MethodType.methodType;

/// Type operators for character strings under a non-default [Collation].
///
/// Only equality, xxHash64, and comparison are declared. [TypeOperators] derives the remaining
/// operators and adapts these to the block, position, and flat calling conventions. Hashing uses
/// the collation key so that strings equal under the collation hash equally. The comparisons are
/// the engine's [CollationComparisons].
final class CollatedStrings
{
    private static final MethodHandle EQUAL;
    private static final MethodHandle XX_HASH_64;
    private static final MethodHandle COMPARISON;

    static {
        try {
            MethodHandles.Lookup lookup = MethodHandles.lookup();
            EQUAL = lookup.findStatic(CollatedStrings.class, "equal", methodType(boolean.class, Comparison.class, Slice.class, Slice.class));
            XX_HASH_64 = lookup.findStatic(CollatedStrings.class, "xxHash64", methodType(long.class, Comparison.class, Slice.class));
            COMPARISON = lookup.findStatic(CollatedStrings.class, "comparison", methodType(long.class, Comparison.class, Slice.class, Slice.class));
        }
        catch (ReflectiveOperationException e) {
            throw new ExceptionInInitializerError(e);
        }
    }

    private CollatedStrings() {}

    static TypeOperatorDeclaration operatorDeclaration(Collation collation)
    {
        Comparison comparison = comparisons().comparison(collation);
        return TypeOperatorDeclaration.builder(Slice.class)
                .addOperators(AbstractVariableWidthType.DEFAULT_READ_OPERATORS)
                .addEqualOperator(bind(EQUAL, comparison, simpleConvention(FAIL_ON_NULL, NEVER_NULL, NEVER_NULL)))
                .addXxHash64Operator(bind(XX_HASH_64, comparison, simpleConvention(FAIL_ON_NULL, NEVER_NULL)))
                .addComparisonUnorderedLastOperator(bind(COMPARISON, comparison, simpleConvention(FAIL_ON_NULL, NEVER_NULL, NEVER_NULL)))
                .build();
    }

    private static OperatorMethodHandle bind(MethodHandle method, Comparison comparison, InvocationConvention convention)
    {
        return new OperatorMethodHandle(convention, insertArguments(method, 0, comparison));
    }

    private static boolean equal(Comparison comparison, Slice left, Slice right)
    {
        return comparison.equal(left, right);
    }

    private static long xxHash64(Comparison comparison, Slice value)
    {
        return XxHash64.hash(comparison.collationKey(value));
    }

    private static long comparison(Comparison comparison, Slice left, Slice right)
    {
        return comparison.compare(left, right);
    }

    // The engine's comparisons, loaded on first use of a collated type. Loading with the SPI's own
    // class loader finds only the engine's implementation, never one in a plugin. A failure to
    // find it is reported on each use, rather than leaving the class unusable.
    private static volatile CollationComparisons comparisons;

    private static CollationComparisons comparisons()
    {
        CollationComparisons loaded = comparisons;
        if (loaded == null) {
            synchronized (CollatedStrings.class) {
                loaded = comparisons;
                if (loaded == null) {
                    loaded = load();
                    comparisons = loaded;
                }
            }
        }
        return loaded;
    }

    private static CollationComparisons load()
    {
        Iterator<CollationComparisons> implementations = ServiceLoader.load(CollationComparisons.class, CollationComparisons.class.getClassLoader()).iterator();
        if (!implementations.hasNext()) {
            throw new IllegalStateException("Collated types require the Trino engine, which provides their comparisons; none was found on the class path of the SPI");
        }
        CollationComparisons comparisons = implementations.next();
        if (implementations.hasNext()) {
            throw new IllegalStateException("Multiple implementations of collation comparisons are available");
        }
        return comparisons;
    }
}
