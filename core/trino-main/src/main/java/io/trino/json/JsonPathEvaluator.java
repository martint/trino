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

import com.google.common.collect.ImmutableList;
import io.trino.json.ir.IrJsonPath;
import io.trino.json.ir.IrMemberAccessor;
import io.trino.json.ir.IrPathNode;
import io.trino.json.ir.TypedValue;
import io.trino.metadata.FunctionManager;
import io.trino.metadata.Metadata;
import io.trino.metadata.ResolvedFunction;
import io.trino.spi.connector.ConnectorSession;
import io.trino.spi.type.CharType;
import io.trino.spi.type.DateType;
import io.trino.spi.type.DecimalType;
import io.trino.spi.type.TimeType;
import io.trino.spi.type.TimeWithTimeZoneType;
import io.trino.spi.type.TimestampType;
import io.trino.spi.type.TimestampWithTimeZoneType;
import io.trino.spi.type.Type;
import io.trino.spi.type.TypeManager;
import io.trino.sql.InterpretedFunctionInvoker;

import java.util.ArrayList;
import java.util.Collections;
import java.util.List;
import java.util.Optional;

import static io.trino.json.PathEvaluationException.itemTypeError;
import static io.trino.json.PathEvaluationException.structuralError;
import static io.trino.json.PathEvaluationUtil.normalize;
import static io.trino.spi.type.BigintType.BIGINT;
import static io.trino.spi.type.BooleanType.BOOLEAN;
import static io.trino.spi.type.DoubleType.DOUBLE;
import static io.trino.spi.type.IntegerType.INTEGER;
import static io.trino.spi.type.RealType.REAL;
import static io.trino.spi.type.SmallintType.SMALLINT;
import static io.trino.spi.type.TinyintType.TINYINT;
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
    private static final Object MISSING = new Object();

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

    public List<JsonPathItem> evaluate(JsonPathItem input, JsonPathItem[] parameters)
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
        if (!(current instanceof io.trino.json.ir.IrContextVariable)) {
            return Optional.empty();
        }
        Collections.reverse(keys);
        return Optional.of(keys);
    }

    private static List<JsonPathItem> evaluateMemberAccessorChain(JsonPathItem input, List<String> keys, boolean lax)
    {
        JsonPathItem current = input;
        List<JsonPathItem> currentSequence = null;
        for (String key : keys) {
            if (currentSequence == null) {
                Object next = selectMemberValues(current, key, lax);
                if (next == MISSING) {
                    return List.of();
                }
                if (next instanceof List<?> nextList) {
                    @SuppressWarnings("unchecked")
                    List<JsonPathItem> sequence = (List<JsonPathItem>) nextList;
                    currentSequence = sequence;
                    current = null;
                }
                else {
                    current = (JsonPathItem) next;
                }
                continue;
            }

            List<JsonPathItem> nextSequence = new ArrayList<>();
            for (JsonPathItem object : currentSequence) {
                appendMemberValues(nextSequence, object, key, lax);
            }
            if (nextSequence.isEmpty()) {
                return List.of();
            }
            if (nextSequence.size() == 1) {
                current = nextSequence.get(0);
                currentSequence = null;
            }
            else {
                currentSequence = ImmutableList.copyOf(nextSequence);
            }
        }

        if (currentSequence != null) {
            return currentSequence;
        }
        return List.of(current);
    }

    private static Object selectMemberValues(JsonPathItem object, String key, boolean lax)
    {
        Optional<JsonValueView> view = JsonValueView.fromItem(object);
        if (view.isPresent()) {
            JsonValueView jsonView = view.orElseThrow();
            if (lax && jsonView.isArray()) {
                List<JsonPathItem> outputSequence = new ArrayList<>();
                jsonView.forEachArrayElement(element -> appendMemberValues(outputSequence, element, key, lax));
                return switch (outputSequence.size()) {
                    case 0 -> MISSING;
                    case 1 -> outputSequence.get(0);
                    default -> ImmutableList.copyOf(outputSequence);
                };
            }

            if (!jsonView.isObject()) {
                if (!lax) {
                    throw itemTypeError("OBJECT", itemTypeName(object));
                }
                return MISSING;
            }

            List<JsonPathItem> outputSequence = new ArrayList<>();
            jsonView.forEachObjectMember((memberKey, memberValue) -> {
                if (memberKey.equals(key)) {
                    outputSequence.add(memberValue);
                }
            });

            if (outputSequence.isEmpty()) {
                if (!lax) {
                    throw structuralError("missing member '%s' in JSON object", key);
                }
                return MISSING;
            }
            return switch (outputSequence.size()) {
                case 1 -> outputSequence.get(0);
                default -> ImmutableList.copyOf(outputSequence);
            };
        }

        object = normalize(object);
        if (lax && object instanceof JsonArrayItem arrayItem) {
            List<JsonPathItem> outputSequence = new ArrayList<>();
            for (JsonValue element : arrayItem.elements()) {
                appendMemberValues(outputSequence, element, key, lax);
            }
            return switch (outputSequence.size()) {
                case 0 -> MISSING;
                case 1 -> outputSequence.get(0);
                default -> ImmutableList.copyOf(outputSequence);
            };
        }

        if (!(object instanceof JsonObjectItem jsonObject)) {
            if (!lax) {
                throw itemTypeError("OBJECT", itemTypeName(object));
            }
            return MISSING;
        }

        Object result = MISSING;
        List<JsonPathItem> outputSequence = null;
        boolean found = false;
        for (JsonObjectMember member : jsonObject.members()) {
            if (member.key().equals(key)) {
                if (!found) {
                    result = member.value();
                }
                else {
                    if (outputSequence == null) {
                        outputSequence = new ArrayList<>();
                        outputSequence.add((JsonPathItem) result);
                    }
                    outputSequence.add(member.value());
                }
                found = true;
            }
        }
        if (!found && !lax) {
            throw structuralError("missing member '%s' in JSON object", key);
        }
        if (outputSequence != null) {
            return ImmutableList.copyOf(outputSequence);
        }
        return result;
    }

    private static void appendMemberValues(List<JsonPathItem> outputSequence, JsonPathItem object, String key, boolean lax)
    {
        Object result = selectMemberValues(object, key, lax);
        if (result == MISSING) {
            return;
        }
        if (result instanceof List<?> sequence) {
            @SuppressWarnings("unchecked")
            List<JsonPathItem> items = (List<JsonPathItem>) sequence;
            outputSequence.addAll(items);
            return;
        }
        outputSequence.add((JsonPathItem) result);
    }

    private static String itemTypeName(JsonPathItem object)
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
        if (object == JsonNull.JSON_NULL) {
            return "NULL";
        }
        if (object instanceof JsonArrayItem) {
            return "ARRAY";
        }
        if (object instanceof JsonObjectItem) {
            return "OBJECT";
        }
        if (object instanceof io.trino.json.ir.TypedValue typedValue) {
            Type type = typedValue.getType();
            if (type.equals(BIGINT) || type.equals(INTEGER) || type.equals(SMALLINT) || type.equals(TINYINT) || type.equals(DOUBLE) || type.equals(REAL) || type instanceof DecimalType) {
                return "NUMBER";
            }
            if (type instanceof io.trino.spi.type.VarcharType || type instanceof CharType) {
                return "STRING";
            }
            if (type.equals(BOOLEAN)) {
                return "BOOLEAN";
            }
            if (type.equals(DateType.DATE)) {
                return "DATE";
            }
            if (type instanceof TimeType) {
                return "TIME";
            }
            if (type instanceof TimeWithTimeZoneType) {
                return "TIME WITH TIME ZONE";
            }
            if (type instanceof TimestampType) {
                return "TIMESTAMP";
            }
            if (type instanceof TimestampWithTimeZoneType) {
                return "TIMESTAMP WITH TIME ZONE";
            }
            return type.getDisplayName();
        }
        return object.getClass().getSimpleName();
    }

    private static String itemTypeName(TypedValue typedValue)
    {
        Type type = typedValue.getType();
        if (type.equals(BIGINT) || type.equals(INTEGER) || type.equals(SMALLINT) || type.equals(TINYINT) || type.equals(DOUBLE) || type.equals(REAL) || type instanceof DecimalType) {
            return "NUMBER";
        }
        if (type instanceof io.trino.spi.type.VarcharType || type instanceof CharType) {
            return "STRING";
        }
        if (type.equals(BOOLEAN)) {
            return "BOOLEAN";
        }
        if (type.equals(DateType.DATE)) {
            return "DATE";
        }
        if (type instanceof TimeType) {
            return "TIME";
        }
        if (type instanceof TimeWithTimeZoneType) {
            return "TIME WITH TIME ZONE";
        }
        if (type instanceof TimestampType) {
            return "TIMESTAMP";
        }
        if (type instanceof TimestampWithTimeZoneType) {
            return "TIMESTAMP WITH TIME ZONE";
        }
        return type.getDisplayName();
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
