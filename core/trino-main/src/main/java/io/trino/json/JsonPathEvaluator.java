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

import io.trino.json.ir.IrContextVariable;
import io.trino.json.ir.IrJsonPath;
import io.trino.json.ir.IrMemberAccessor;
import io.trino.json.ir.IrPathNode;
import io.trino.metadata.FunctionManager;
import io.trino.metadata.Metadata;
import io.trino.metadata.ResolvedFunction;
import io.trino.spi.connector.ConnectorSession;
import io.trino.spi.type.BigintType;
import io.trino.spi.type.BooleanType;
import io.trino.spi.type.CharType;
import io.trino.spi.type.DecimalType;
import io.trino.spi.type.DoubleType;
import io.trino.spi.type.IntegerType;
import io.trino.spi.type.RealType;
import io.trino.spi.type.SmallintType;
import io.trino.spi.type.TinyintType;
import io.trino.spi.type.Type;
import io.trino.spi.type.TypeManager;
import io.trino.spi.type.VarcharType;
import io.trino.sql.InterpretedFunctionInvoker;

import java.util.ArrayList;
import java.util.Collections;
import java.util.List;
import java.util.Optional;

import static io.trino.json.PathEvaluationException.itemTypeError;
import static io.trino.json.PathEvaluationException.structuralError;
import static io.trino.json.PathEvaluationUtil.normalize;
import static java.util.Objects.requireNonNull;

/**
 * Evaluates the JSON path expression using given JSON input and parameters,
 * respecting the path mode `strict` or `lax`.
 * Successful evaluation results in a sequence of objects.
 * Each object in the sequence is represented either by a JsonValueView-backed JSON item
 * or a typed scalar value.
 * Certain error conditions might be suppressed in `lax` mode.
 * Any unsuppressed error condition causes evaluation failure.
 * In such case, `PathEvaluationError` is thrown.
 */
public class JsonPathEvaluator
{
    private final IrJsonPath path;
    private final Invoker invoker;
    private final CachingResolver resolver;
    private final Optional<List<String>> memberAccessorChain;

    public JsonPathEvaluator(IrJsonPath path, ConnectorSession session, Metadata metadata, TypeManager typeManager, FunctionManager functionManager)
    {
        requireNonNull(path, "path is null");
        requireNonNull(session, "session is null");
        requireNonNull(metadata, "metadata is null");
        requireNonNull(typeManager, "typeManager is null");
        requireNonNull(functionManager, "functionManager is null");

        this.path = path;
        this.invoker = new Invoker(session, functionManager);
        this.resolver = new CachingResolver(metadata);
        this.memberAccessorChain = getMemberAccessorChain(path.getRoot());
    }

    public List<JsonItem> evaluate(JsonItem input, JsonItem[] parameters)
    {
        if (parameters.length == 0 && memberAccessorChain.isPresent()) {
            return evaluateMemberAccessorChain(input, memberAccessorChain.get(), path.isLax());
        }

        return new PathEvaluationVisitor(
                path.isLax(),
                input,
                parameters,
                invoker,
                resolver)
                .process(path.getRoot(), new PathEvaluationContext());
    }

    private static Optional<List<String>> getMemberAccessorChain(IrPathNode root)
    {
        List<String> keys = new ArrayList<>();
        IrPathNode current = root;
        while (current instanceof IrMemberAccessor accessor) {
            if (accessor.key().isEmpty()) {
                return Optional.empty();
            }
            keys.add(accessor.key().orElseThrow());
            current = accessor.base();
        }
        if (!(current instanceof IrContextVariable)) {
            return Optional.empty();
        }
        Collections.reverse(keys);
        return Optional.of(keys);
    }

    private static List<JsonItem> evaluateMemberAccessorChain(JsonItem input, List<String> keys, boolean lax)
    {
        List<JsonItem> current = List.of(input);
        for (String key : keys) {
            if (current.isEmpty()) {
                return List.of();
            }
            if (current.size() == 1) {
                current = selectMemberValues(current.get(0), key, lax);
                continue;
            }
            List<JsonItem> nextSequence = new ArrayList<>();
            for (JsonItem object : current) {
                nextSequence.addAll(selectMemberValues(object, key, lax));
            }
            current = nextSequence;
        }
        return current;
    }

    /**
     * Returns every JsonItem matching {@code key} within {@code object}. An empty result means MISSING
     * (an absent member, possibly after lax-mode unwrapping). In strict mode, structural mismatches throw
     * a PathEvaluationException.
     */
    private static List<JsonItem> selectMemberValues(JsonItem object, String key, boolean lax)
    {
        Optional<JsonValueView> view = JsonValueView.fromItem(object);
        if (view.isPresent()) {
            JsonValueView jsonView = view.orElseThrow();
            if (lax && jsonView.isArray()) {
                List<JsonItem> outputSequence = new ArrayList<>();
                jsonView.forEachArrayElement(element -> outputSequence.addAll(selectMemberValues(element, key, lax)));
                return outputSequence;
            }

            if (!jsonView.isObject()) {
                if (!lax) {
                    throw itemTypeError("OBJECT", itemTypeName(object));
                }
                return List.of();
            }

            // Use objectMembers(key, consumer) so OBJECT_INDEXED payloads dispatch to
            // O(log n + d) binary-search lookup. Duplicate keys (allowed under
            // WITHOUT UNIQUE KEYS) are emitted in insertion order.
            List<JsonItem> outputSequence = new ArrayList<>();
            jsonView.objectMembers(key, outputSequence::add);
            if (outputSequence.isEmpty() && !lax) {
                throw structuralError("missing member '%s' in JSON object", key);
            }
            return outputSequence;
        }

        object = normalize(object);
        if (lax && object instanceof JsonArray arrayItem) {
            List<JsonItem> outputSequence = new ArrayList<>();
            for (JsonValue element : arrayItem.elements()) {
                outputSequence.addAll(selectMemberValues((JsonItem) element, key, lax));
            }
            return outputSequence;
        }

        if (!(object instanceof JsonObject jsonObject)) {
            if (!lax) {
                throw itemTypeError("OBJECT", itemTypeName(object));
            }
            return List.of();
        }

        List<JsonItem> outputSequence = new ArrayList<>();
        for (JsonObjectMember member : jsonObject.members()) {
            if (member.key().equals(key)) {
                outputSequence.add(member.value());
            }
        }
        if (outputSequence.isEmpty() && !lax) {
            throw structuralError("missing member '%s' in JSON object", key);
        }
        return outputSequence;
    }

    private static String itemTypeName(JsonItem object)
    {
        Optional<JsonValueView> view = JsonValueView.fromItem(object);
        if (view.isPresent()) {
            return switch (view.orElseThrow().kind()) {
                case NULL -> "NULL";
                case ARRAY -> "ARRAY";
                case OBJECT -> "OBJECT";
                case TYPED_VALUE -> itemTypeName(view.orElseThrow().typedValue());
                case JSON_ERROR -> "ERROR";
            };
        }

        object = normalize(object);
        return switch (object) {
            case JsonNull _ -> "NULL";
            case JsonArray _ -> "ARRAY";
            case JsonObject _ -> "OBJECT";
            case TypedValue typedValue -> itemTypeName(typedValue);
            default -> object.getClass().getSimpleName();
        };
    }

    private static String itemTypeName(TypedValue typedValue)
    {
        Type type = typedValue.getType();
        return switch (type) {
            case BigintType _, IntegerType _, SmallintType _, TinyintType _, DoubleType _, RealType _, DecimalType _ -> "NUMBER";
            case VarcharType _, CharType _ -> "STRING";
            case BooleanType _ -> "BOOLEAN";
            default -> type.getDisplayName();
        };
    }

    public static class Invoker
    {
        private final ConnectorSession connectorSession;
        private final InterpretedFunctionInvoker functionInvoker;

        public Invoker(ConnectorSession connectorSession, FunctionManager functionManager)
        {
            this.connectorSession = connectorSession;
            this.functionInvoker = new InterpretedFunctionInvoker(functionManager);
        }

        public Object invoke(ResolvedFunction function, List<Object> arguments)
        {
            return functionInvoker.invoke(function, connectorSession, arguments);
        }
    }
}
