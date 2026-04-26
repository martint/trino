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

import com.google.common.cache.CacheBuilder;
import com.google.common.collect.ImmutableList;
import io.airlift.slice.Slices;
import io.trino.cache.NonEvictableCache;
import io.trino.json.JsonPathEvaluator.Invoker;
import io.trino.json.ir.IrLikeRegexPredicate;
import io.trino.json.ir.IrPathNode;
import io.trino.metadata.Metadata;
import io.trino.metadata.OperatorNotFoundException;
import io.trino.metadata.ResolvedFunction;
import io.trino.spi.function.BoundSignature;
import io.trino.spi.function.OperatorType;
import io.trino.spi.type.Type;
import io.trino.spi.type.VarcharType;

import java.util.Objects;
import java.util.Optional;
import java.util.concurrent.ExecutionException;

import static com.google.common.base.Preconditions.checkState;
import static io.trino.cache.SafeCaches.buildNonEvictableCache;
import static io.trino.json.CachingResolver.ResolvedOperatorAndCoercions.RESOLUTION_ERROR;
import static io.trino.json.CachingResolver.ResolvedOperatorAndCoercions.operators;
import static io.trino.sql.analyzer.TypeSignatureProvider.fromTypes;
import static java.util.Objects.requireNonNull;

/**
 * A resolver providing coercions and binary operators used for JSON path evaluation,
 * based on the operation type and the input types.
 * <p>
 * It is instantiated per-driver, and caches the resolved operators and coercions.
 * Caching is applied to IrArithmeticBinary and IrComparisonPredicate path nodes.
 * Its purpose is to avoid resolving operators and coercions on a per-row basis, assuming
 * that the input types to the JSON path operations repeat across rows.
 * <p>
 * If an operator or a component coercion cannot be resolved for certain input types,
 * it is cached as RESOLUTION_ERROR. It depends on the caller to handle this condition.
 */
public class CachingResolver
{
    private static final int MAX_CACHE_SIZE = 1000;

    private final Metadata metadata;
    private final NonEvictableCache<NodeAndTypes, ResolvedOperatorAndCoercions> operators = buildNonEvictableCache(CacheBuilder.newBuilder().maximumSize(MAX_CACHE_SIZE));
    private final NonEvictableCache<String, ResolvedFunctionAndCoercions> functions = buildNonEvictableCache(CacheBuilder.newBuilder().maximumSize(MAX_CACHE_SIZE));
    private final NonEvictableCache<IrPathNodeRef<IrLikeRegexPredicate>, Object> likeRegexPatterns = buildNonEvictableCache(CacheBuilder.newBuilder().maximumSize(MAX_CACHE_SIZE));

    public CachingResolver(Metadata metadata)
    {
        requireNonNull(metadata, "metadata is null");
        this.metadata = metadata;
    }

    public ResolvedOperatorAndCoercions getOperators(IrPathNode node, OperatorType operatorType, Type leftType, Type rightType)
    {
        try {
            return operators
                    .get(new NodeAndTypes(IrPathNodeRef.of(node), leftType, rightType), () -> resolveOperators(operatorType, leftType, rightType));
        }
        catch (ExecutionException e) {
            throw new RuntimeException(e);
        }
    }

    public ResolvedFunctionAndCoercions getRegexpLikeFunction()
    {
        try {
            return functions.get("regexp_like", this::resolveRegexpLikeFunction);
        }
        catch (ExecutionException e) {
            throw new RuntimeException(e);
        }
    }

    /**
     * Returns the translated and coerced regex pattern for a like_regex node. The XQuery-to-Java
     * translation and any coercion invocation is cached per node, since the pattern is a path literal
     * (static per IR tree) and would otherwise be recomputed per row.
     */
    public Optional<Object> getLikeRegexPattern(IrLikeRegexPredicate node, Invoker invoker, Optional<ResolvedFunction> rightCoercion)
    {
        try {
            Object cached = likeRegexPatterns.get(IrPathNodeRef.of(node), () -> {
                Object pattern = Slices.utf8Slice(XQueryRegex.patternWithFlags(node.pattern(), node.flag().orElse("")));
                if (rightCoercion.isPresent()) {
                    pattern = invoker.invoke(rightCoercion.get(), ImmutableList.of(pattern));
                }
                return pattern;
            });
            return Optional.of(cached);
        }
        catch (ExecutionException | RuntimeException e) {
            return Optional.empty();
        }
    }

    private ResolvedOperatorAndCoercions resolveOperators(OperatorType operatorType, Type leftType, Type rightType)
    {
        ResolvedFunction operator;
        try {
            operator = metadata.resolveOperator(operatorType, ImmutableList.of(leftType, rightType));
        }
        catch (OperatorNotFoundException e) {
            return RESOLUTION_ERROR;
        }

        BoundSignature signature = operator.signature();

        Optional<ResolvedFunction> leftCast = Optional.empty();
        if (!signature.getArgumentTypes().get(0).equals(leftType)) {
            try {
                leftCast = Optional.of(metadata.getCoercion(leftType, signature.getArgumentTypes().get(0)));
            }
            catch (OperatorNotFoundException e) {
                return RESOLUTION_ERROR;
            }
        }

        Optional<ResolvedFunction> rightCast = Optional.empty();
        if (!signature.getArgumentTypes().get(1).equals(rightType)) {
            try {
                rightCast = Optional.of(metadata.getCoercion(rightType, signature.getArgumentTypes().get(1)));
            }
            catch (OperatorNotFoundException e) {
                return RESOLUTION_ERROR;
            }
        }

        return operators(operator, leftCast, rightCast);
    }

    private ResolvedFunctionAndCoercions resolveRegexpLikeFunction()
    {
        ResolvedFunction function;
        try {
            function = metadata.resolveBuiltinFunction("regexp_like", fromTypes(VarcharType.VARCHAR, VarcharType.VARCHAR));
        }
        catch (RuntimeException e) {
            return ResolvedFunctionAndCoercions.RESOLUTION_ERROR;
        }
        BoundSignature signature = function.signature();

        Optional<ResolvedFunction> leftCast = Optional.empty();
        if (!signature.getArgumentTypes().get(0).equals(VarcharType.VARCHAR)) {
            try {
                leftCast = Optional.of(metadata.getCoercion(VarcharType.VARCHAR, signature.getArgumentTypes().get(0)));
            }
            catch (OperatorNotFoundException e) {
                return ResolvedFunctionAndCoercions.RESOLUTION_ERROR;
            }
        }

        Optional<ResolvedFunction> rightCast = Optional.empty();
        if (!signature.getArgumentTypes().get(1).equals(VarcharType.VARCHAR)) {
            try {
                rightCast = Optional.of(metadata.getCoercion(VarcharType.VARCHAR, signature.getArgumentTypes().get(1)));
            }
            catch (OperatorNotFoundException e) {
                return ResolvedFunctionAndCoercions.RESOLUTION_ERROR;
            }
        }

        return new ResolvedFunctionAndCoercions.Resolved(function, leftCast, rightCast);
    }

    private static class NodeAndTypes
    {
        private final IrPathNodeRef<IrPathNode> node;
        private final Type leftType;
        private final Type rightType;

        public NodeAndTypes(IrPathNodeRef<IrPathNode> node, Type leftType, Type rightType)
        {
            this.node = node;
            this.leftType = leftType;
            this.rightType = rightType;
        }

        @Override
        public boolean equals(Object o)
        {
            if (this == o) {
                return true;
            }
            if (o == null || getClass() != o.getClass()) {
                return false;
            }
            NodeAndTypes that = (NodeAndTypes) o;
            return Objects.equals(node, that.node) &&
                    Objects.equals(leftType, that.leftType) &&
                    Objects.equals(rightType, that.rightType);
        }

        @Override
        public int hashCode()
        {
            return Objects.hash(node, leftType, rightType);
        }
    }

    public static class ResolvedOperatorAndCoercions
    {
        public static final ResolvedOperatorAndCoercions RESOLUTION_ERROR = new ResolvedOperatorAndCoercions(null, Optional.empty(), Optional.empty());

        private final ResolvedFunction operator;
        private final Optional<ResolvedFunction> leftCoercion;
        private final Optional<ResolvedFunction> rightCoercion;

        public static ResolvedOperatorAndCoercions operators(ResolvedFunction operator, Optional<ResolvedFunction> leftCoercion, Optional<ResolvedFunction> rightCoercion)
        {
            return new ResolvedOperatorAndCoercions(requireNonNull(operator, "operator is null"), leftCoercion, rightCoercion);
        }

        private ResolvedOperatorAndCoercions(ResolvedFunction operator, Optional<ResolvedFunction> leftCoercion, Optional<ResolvedFunction> rightCoercion)
        {
            this.operator = operator;
            this.leftCoercion = requireNonNull(leftCoercion, "leftCoercion is null");
            this.rightCoercion = requireNonNull(rightCoercion, "rightCoercion is null");
        }

        public ResolvedFunction getOperator()
        {
            checkState(this != RESOLUTION_ERROR, "accessing operator on RESOLUTION_ERROR");
            return operator;
        }

        public Optional<ResolvedFunction> getLeftCoercion()
        {
            checkState(this != RESOLUTION_ERROR, "accessing coercion on RESOLUTION_ERROR");
            return leftCoercion;
        }

        public Optional<ResolvedFunction> getRightCoercion()
        {
            checkState(this != RESOLUTION_ERROR, "accessing coercion on RESOLUTION_ERROR");
            return rightCoercion;
        }
    }

    public sealed interface ResolvedFunctionAndCoercions
    {
        ResolvedFunctionAndCoercions RESOLUTION_ERROR = ResolutionError.INSTANCE;

        enum ResolutionError
                implements ResolvedFunctionAndCoercions
        {
            INSTANCE
        }

        record Resolved(ResolvedFunction function, Optional<ResolvedFunction> leftCoercion, Optional<ResolvedFunction> rightCoercion)
                implements ResolvedFunctionAndCoercions
        {
            public Resolved
            {
                requireNonNull(function, "function is null");
                requireNonNull(leftCoercion, "leftCoercion is null");
                requireNonNull(rightCoercion, "rightCoercion is null");
            }
        }
    }
}
