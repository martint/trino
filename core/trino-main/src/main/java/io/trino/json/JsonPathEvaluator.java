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
import io.trino.spi.type.TypeManager;
import io.trino.sql.InterpretedFunctionInvoker;

import java.util.ArrayList;
import java.util.Collections;
import java.util.List;
import java.util.Optional;

import static io.trino.json.PathEvaluationException.itemTypeError;
import static io.trino.json.PathEvaluationException.structuralError;
import static io.trino.json.PathEvaluationUtil.normalize;
import static io.trino.json.PathEvaluationVisitor.itemTypeName;
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
    private final ConnectorSession session;
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
        this.session = session;
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
                session,
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
            for (JsonItem item : current) {
                nextSequence.addAll(selectMemberValues(item, key, lax));
            }
            current = nextSequence;
        }
        return current;
    }

    /**
     * Returns every JsonItem matching {@code key} within {@code item}. An empty result means MISSING
     * (an absent member, possibly after lax-mode unwrapping). In strict mode, structural mismatches throw
     * a PathEvaluationException.
     */
    private static List<JsonItem> selectMemberValues(JsonItem item, String key, boolean lax)
    {
        Optional<JsonValueView> view = JsonValueView.fromItem(item);
        if (view.isPresent()) {
            JsonValueView jsonView = view.orElseThrow();
            if (lax && jsonView.isArray()) {
                List<JsonItem> result = new ArrayList<>();
                jsonView.forEachArrayElement(element -> result.addAll(selectMemberValues(element, key, lax)));
                return result;
            }

            if (!jsonView.isObject()) {
                if (!lax) {
                    throw itemTypeError("OBJECT", itemTypeName(item));
                }
                return List.of();
            }

            // Use objectMembers(key, consumer) so OBJECT_INDEXED payloads dispatch to
            // O(log n + d) binary-search lookup. Duplicate keys (allowed under
            // WITHOUT UNIQUE KEYS) are emitted in insertion order.
            List<JsonItem> result = new ArrayList<>();
            jsonView.objectMembers(key, result::add);
            if (result.isEmpty() && !lax) {
                throw structuralError("missing member '%s' in JSON object", key);
            }
            return result;
        }

        item = normalize(item);
        if (lax && item instanceof JsonArray array) {
            List<JsonItem> result = new ArrayList<>();
            for (JsonValue element : array.elements()) {
                result.addAll(selectMemberValues((JsonItem) element, key, lax));
            }
            return result;
        }

        if (!(item instanceof JsonObject object)) {
            if (!lax) {
                throw itemTypeError("OBJECT", itemTypeName(item));
            }
            return List.of();
        }

        List<JsonItem> result = new ArrayList<>();
        for (JsonObjectMember member : object.members()) {
            if (member.key().equals(key)) {
                result.add(member.value());
            }
        }
        if (result.isEmpty() && !lax) {
            throw structuralError("missing member '%s' in JSON object", key);
        }
        return result;
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
