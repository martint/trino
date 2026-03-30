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

import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.node.NullNode;
import com.google.common.collect.ImmutableList;
import io.trino.json.ir.IrJsonPath;
import io.trino.json.ir.TypedValue;
import io.trino.metadata.FunctionManager;
import io.trino.metadata.Metadata;
import io.trino.metadata.ResolvedFunction;
import io.trino.spi.connector.ConnectorSession;
import io.trino.spi.type.TypeManager;
import io.trino.sql.InterpretedFunctionInvoker;

import java.util.List;

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
    }

    public List<Object> evaluate(JsonPathItem input, Object[] parameters)
    {
        List<Object> pathResult = new PathEvaluationVisitor(
                path.isLax(),
                toLegacyJsonNode(input),
                toLegacyPathParameters(parameters),
                invoker,
                resolver)
                .process(path.getRoot(), new PathEvaluationContext());

        ImmutableList.Builder<Object> builder = ImmutableList.builderWithExpectedSize(pathResult.size());
        for (Object item : pathResult) {
            if (item instanceof JsonNode jsonNode) {
                builder.add(JsonItems.fromJsonNode(jsonNode));
            }
            else {
                builder.add(item);
            }
        }
        return builder.build();
    }

    private static JsonNode toLegacyJsonNode(Object value)
    {
        if (value instanceof JsonPathItem item) {
            return toLegacyJsonNode(item);
        }
        throw new IllegalArgumentException("Expected JSON item, but got " + value.getClass().getSimpleName());
    }

    private static JsonNode toLegacyJsonNode(JsonPathItem item)
    {
        item = JsonItems.materialize(item);
        if (item instanceof JsonNode jsonNode) {
            return jsonNode;
        }
        if (item instanceof JsonValue value) {
            return JsonItems.toJsonNode(value);
        }
        throw new IllegalArgumentException("Expected JSON value, but got " + item.getClass().getSimpleName());
    }

    private static Object toLegacyPathValue(Object value)
    {
        if (value instanceof TypedValue) {
            return value;
        }
        if (value == JsonNull.JSON_NULL) {
            return NullNode.getInstance();
        }
        if (value instanceof JsonPathItem item) {
            return toLegacyJsonNode(item);
        }
        return value;
    }

    private static Object[] toLegacyPathParameters(Object[] parameters)
    {
        Object[] converted = new Object[parameters.length];
        for (int i = 0; i < parameters.length; i++) {
            converted[i] = toLegacyPathValue(parameters[i]);
        }
        return converted;
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
