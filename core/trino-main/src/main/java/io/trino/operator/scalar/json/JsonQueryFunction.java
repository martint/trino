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
package io.trino.operator.scalar.json;

import com.google.common.base.VerifyException;
import com.google.common.collect.ImmutableList;
import io.airlift.slice.Slice;
import io.trino.annotation.UsedByGeneratedCode;
import io.trino.json.JsonArray;
import io.trino.json.JsonInputError;
import io.trino.json.JsonItem;
import io.trino.json.JsonItemEncoding;
import io.trino.json.JsonItems;
import io.trino.json.JsonObject;
import io.trino.json.JsonPathEvaluator;
import io.trino.json.JsonPathInvocationContext;
import io.trino.json.JsonValue;
import io.trino.json.JsonValueView;
import io.trino.json.PathEvaluationException;
import io.trino.json.TypedValue;
import io.trino.json.ir.IrJsonPath;
import io.trino.metadata.FunctionManager;
import io.trino.metadata.Metadata;
import io.trino.metadata.SqlScalarFunction;
import io.trino.operator.scalar.ChoicesSpecializedSqlScalarFunction;
import io.trino.operator.scalar.SpecializedSqlScalarFunction;
import io.trino.spi.TrinoException;
import io.trino.spi.block.SqlRow;
import io.trino.spi.connector.ConnectorSession;
import io.trino.spi.function.BoundSignature;
import io.trino.spi.function.FunctionMetadata;
import io.trino.spi.function.Signature;
import io.trino.spi.type.JsonPayload;
import io.trino.spi.type.Type;
import io.trino.spi.type.TypeManager;
import io.trino.spi.type.TypeSignature;
import io.trino.sql.tree.JsonQuery.ArrayWrapperBehavior;
import io.trino.sql.tree.JsonQuery.EmptyOrErrorBehavior;
import io.trino.type.JsonPath2016Type;
import io.trino.type.JsonType;

import java.lang.invoke.MethodHandle;
import java.util.List;
import java.util.Optional;
import java.util.function.Supplier;

import static io.trino.operator.scalar.json.ParameterUtil.getParametersArray;
import static io.trino.spi.function.InvocationConvention.InvocationArgumentConvention.BOXED_NULLABLE;
import static io.trino.spi.function.InvocationConvention.InvocationArgumentConvention.NEVER_NULL;
import static io.trino.spi.function.InvocationConvention.InvocationReturnConvention.NULLABLE_RETURN;
import static io.trino.spi.type.StandardTypes.JSON;
import static io.trino.spi.type.StandardTypes.TINYINT;
import static io.trino.util.Reflection.constructorMethodHandle;
import static io.trino.util.Reflection.methodHandle;
import static java.lang.String.format;
import static java.util.Objects.requireNonNull;

public class JsonQueryFunction
        extends SqlScalarFunction
{
    public static final String JSON_QUERY_FUNCTION_NAME = "$json_query";
    private static final MethodHandle METHOD_HANDLE = methodHandle(JsonQueryFunction.class, "jsonQuery", FunctionManager.class, Metadata.class, TypeManager.class, Type.class, JsonPathInvocationContext.class, ConnectorSession.class, Object.class, IrJsonPath.class, SqlRow.class, long.class, long.class, long.class);
    private static final JsonItem EMPTY_ARRAY_RESULT = JsonItems.encoded(new JsonArray(ImmutableList.of()));
    private static final JsonItem EMPTY_OBJECT_RESULT = JsonItems.encoded(new JsonObject(ImmutableList.of()));

    private final FunctionManager functionManager;
    private final Metadata metadata;
    private final TypeManager typeManager;

    public JsonQueryFunction(FunctionManager functionManager, Metadata metadata, TypeManager typeManager)
    {
        super(FunctionMetadata.scalarBuilder(JSON_QUERY_FUNCTION_NAME)
                .signature(Signature.builder()
                        .typeVariable("T")
                        .returnType(new TypeSignature(JSON))
                        .argumentTypes(ImmutableList.of(
                                new TypeSignature(JSON),
                                new TypeSignature(JsonPath2016Type.NAME),
                                new TypeSignature("T"),
                                new TypeSignature(TINYINT),
                                new TypeSignature(TINYINT),
                                new TypeSignature(TINYINT)))
                        .build())
                .nullable()
                .argumentNullability(false, false, true, false, false, false)
                .hidden()
                .description("Extracts a JSON value from a JSON value")
                .build());

        this.functionManager = requireNonNull(functionManager, "functionManager is null");
        this.metadata = requireNonNull(metadata, "metadata is null");
        this.typeManager = requireNonNull(typeManager, "typeManager is null");
    }

    @Override
    protected SpecializedSqlScalarFunction specialize(BoundSignature boundSignature)
    {
        Type parametersRowType = boundSignature.getArgumentType(2);
        MethodHandle methodHandle = METHOD_HANDLE
                .bindTo(functionManager)
                .bindTo(metadata)
                .bindTo(typeManager)
                .bindTo(parametersRowType);
        MethodHandle instanceFactory = constructorMethodHandle(JsonPathInvocationContext.class);
        return new ChoicesSpecializedSqlScalarFunction(
                boundSignature,
                NULLABLE_RETURN,
                ImmutableList.of(BOXED_NULLABLE, BOXED_NULLABLE, BOXED_NULLABLE, NEVER_NULL, NEVER_NULL, NEVER_NULL),
                methodHandle,
                Optional.of(instanceFactory));
    }

    @UsedByGeneratedCode
    public static JsonPayload jsonQuery(
            FunctionManager functionManager,
            Metadata metadata,
            TypeManager typeManager,
            Type parametersRowType,
            JsonPathInvocationContext invocationContext,
            ConnectorSession session,
            Object inputExpression,
            IrJsonPath jsonPath,
            SqlRow parametersRow,
            long wrapperBehavior,
            long emptyBehavior,
            long errorBehavior)
    {
        Slice payload = JsonType.fromPathItem(jsonQueryAsItem(functionManager, metadata, typeManager, parametersRowType, invocationContext, session, inputExpression, jsonPath, parametersRow, wrapperBehavior, emptyBehavior, errorBehavior));
        return payload == null ? null : JsonPayload.of(payload);
    }

    private static JsonItem jsonQueryAsItem(
            FunctionManager functionManager,
            Metadata metadata,
            TypeManager typeManager,
            Type parametersRowType,
            JsonPathInvocationContext invocationContext,
            ConnectorSession session,
            Object inputExpression,
            IrJsonPath jsonPath,
            SqlRow parametersRow,
            long wrapperBehavior,
            long emptyBehavior,
            long errorBehavior)
    {
        JsonItem inputItem = switch (inputExpression) {
            case JsonPayload jsonValue -> JsonType.toPathItem(jsonValue.payload());
            case Slice slice -> JsonType.toPathItem(slice);
            default -> (JsonItem) inputExpression;
        };
        if (inputItem == JsonInputError.JSON_ERROR) {
            return handleSpecialCase(errorBehavior, () -> new JsonInputConversionException("malformed input argument to JSON_QUERY function")); // ERROR ON ERROR was already handled by the input function
        }
        JsonItem[] parameters = getParametersArray(parametersRowType, parametersRow);
        for (JsonItem parameter : parameters) {
            if (JsonInputError.matches(parameter)) {
                return handleSpecialCase(errorBehavior, () -> new JsonInputConversionException("malformed JSON path parameter to JSON_QUERY function")); // ERROR ON ERROR was already handled by the input function
            }
        }
        // The jsonPath argument is constant for every row. We use the first incoming jsonPath argument to initialize
        // the JsonPathEvaluator, and ignore the subsequent jsonPath values. We could sanity-check that all the incoming
        // jsonPath values are equal. We deliberately skip this costly check, since this is a hidden function.
        JsonPathEvaluator evaluator = invocationContext.getEvaluator();
        if (evaluator == null) {
            evaluator = new JsonPathEvaluator(jsonPath, session, metadata, typeManager, functionManager);
            invocationContext.setEvaluator(evaluator);
        }
        List<JsonItem> pathResult;
        try {
            pathResult = evaluator.evaluate(inputItem, parameters);
        }
        catch (PathEvaluationException e) {
            return handleSpecialCase(errorBehavior, () -> e);
        }

        // handle empty sequence
        if (pathResult.isEmpty()) {
            return handleSpecialCase(emptyBehavior, () -> new JsonOutputConversionException("JSON path found no items"));
        }

        if (pathResult.size() == 1) {
            JsonItem item = pathResult.get(0);
            return switch (ArrayWrapperBehavior.values()[(int) wrapperBehavior]) {
                case WITHOUT -> toJsonResult(item);
                case CONDITIONAL -> {
                    if (isArrayOrObject(item)) {
                        yield item;
                    }
                    yield encodedResult(new JsonArray(ImmutableList.of(JsonItems.asJsonValue(item))));
                }
                case UNCONDITIONAL -> encodedResult(new JsonArray(ImmutableList.of(JsonItems.asJsonValue(item))));
            };
        }

        // translate sequence to JSON items
        ImmutableList.Builder<JsonValue> builder = ImmutableList.builderWithExpectedSize(pathResult.size());
        for (JsonItem item : pathResult) {
            if (item instanceof TypedValue typedValue && !JsonItems.canBeRepresentedAsJson(typedValue.type())) {
                return handleSpecialCase(errorBehavior, () -> new JsonOutputConversionException(format(
                        "JSON path returned a scalar SQL value of type %s that cannot be represented as JSON",
                        typedValue.type())));
            }
            builder.add(JsonItems.asJsonValue(item));
        }
        List<JsonValue> sequence = builder.build();

        // apply array wrapper behavior
        sequence = switch (ArrayWrapperBehavior.values()[(int) wrapperBehavior]) {
            case WITHOUT -> sequence;
            case UNCONDITIONAL -> ImmutableList.of(new JsonArray(sequence));
            case CONDITIONAL -> (sequence.size() == 1 && isArrayOrObject(sequence.get(0)))
                    ? sequence
                    : ImmutableList.of(new JsonArray(sequence));
        };

        // singleton sequence - return the only item
        if (sequence.size() == 1) {
            return sequence.get(0);
            // if the only item is a TextNode, need to apply the KEEP / OMIT QUOTES behavior. this is done by the JSON output function
        }

        // Per SQL:2023 §9.44 GR 4) c) iii) (RETURNING JSON) and §9.49 GR 4) c) iii) (serialization):
        // a JSON_QUERY path producing multiple items without a wrapper is a cardinality error
        // ("more than one SQL/JSON item", SQLSTATE 22034), distinct from output-conversion errors.
        return handleSpecialCase(errorBehavior, () -> new JsonQueryResultException("path produced multiple items without a wrapper"));
    }

    private static JsonItem handleSpecialCase(long behavior, Supplier<TrinoException> error)
    {
        return switch (EmptyOrErrorBehavior.values()[(int) behavior]) {
            case NULL -> null;
            case ERROR -> throw error.get();
            case EMPTY_ARRAY -> EMPTY_ARRAY_RESULT;
            case EMPTY_OBJECT -> EMPTY_OBJECT_RESULT;
        };
    }

    private static JsonItem toJsonResult(JsonItem item)
    {
        Optional<JsonValueView> view = JsonValueView.fromObject(item);
        if (view.isPresent()) {
            return view.get();
        }
        if (item instanceof JsonValue jsonValue) {
            return encodedResult(jsonValue);
        }
        throw new VerifyException(format("unexpected JSON path result item: %s", item.getClass().getName()));
    }

    private static boolean isArrayOrObject(JsonItem item)
    {
        return JsonValueView.fromObject(item)
                .map(view -> view.isArray() || view.isObject())
                .orElse(item instanceof JsonArray || item instanceof JsonObject);
    }

    private static JsonItem encodedResult(JsonValue value)
    {
        return JsonValueView.root(JsonItemEncoding.encode(value));
    }
}
