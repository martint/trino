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

import com.google.common.collect.ImmutableList;
import io.airlift.slice.Slice;
import io.trino.annotation.UsedByGeneratedCode;
import io.trino.json.JsonArrayItem;
import io.trino.json.JsonItems;
import io.trino.json.JsonNull;
import io.trino.json.JsonObjectItem;
import io.trino.json.JsonObjectMember;
import io.trino.json.JsonValue;
import io.trino.json.JsonValueView;
import io.trino.json.ir.TypedValue;
import io.trino.metadata.SqlScalarFunction;
import io.trino.operator.scalar.ChoicesSpecializedSqlScalarFunction;
import io.trino.operator.scalar.SpecializedSqlScalarFunction;
import io.trino.spi.TrinoException;
import io.trino.spi.block.SqlRow;
import io.trino.spi.function.BoundSignature;
import io.trino.spi.function.FunctionMetadata;
import io.trino.spi.function.Signature;
import io.trino.spi.type.RowType;
import io.trino.spi.type.StandardTypes;
import io.trino.spi.type.Type;
import io.trino.spi.type.TypeSignature;
import io.trino.type.JsonType;

import java.lang.invoke.MethodHandle;
import java.util.ArrayList;
import java.util.HashSet;
import java.util.List;
import java.util.Optional;
import java.util.Set;

import static com.google.common.base.Preconditions.checkArgument;
import static com.google.common.base.Preconditions.checkState;
import static io.trino.spi.StandardErrorCode.INVALID_FUNCTION_ARGUMENT;
import static io.trino.spi.function.InvocationConvention.InvocationArgumentConvention.BOXED_NULLABLE;
import static io.trino.spi.function.InvocationConvention.InvocationArgumentConvention.NEVER_NULL;
import static io.trino.spi.function.InvocationConvention.InvocationReturnConvention.FAIL_ON_NULL;
import static io.trino.spi.type.StandardTypes.BOOLEAN;
import static io.trino.spi.type.TypeUtils.readNativeValue;
import static io.trino.sql.analyzer.ExpressionAnalyzer.JSON_NO_PARAMETERS_ROW_TYPE;
import static io.trino.util.Reflection.methodHandle;

public class JsonObjectFunction
        extends SqlScalarFunction
{
    public static final JsonObjectFunction JSON_OBJECT_FUNCTION = new JsonObjectFunction();
    public static final String JSON_OBJECT_FUNCTION_NAME = "$json_object";
    private static final MethodHandle METHOD_HANDLE = methodHandle(JsonObjectFunction.class, "jsonObject", RowType.class, RowType.class, SqlRow.class, SqlRow.class, boolean.class, boolean.class);
    private static final JsonValue EMPTY_OBJECT = new JsonObjectItem(ImmutableList.of());

    private JsonObjectFunction()
    {
        super(FunctionMetadata.scalarBuilder(JSON_OBJECT_FUNCTION_NAME)
                .signature(Signature.builder()
                        .typeVariable("K")
                        .typeVariable("V")
                        .returnType(new TypeSignature(StandardTypes.JSON))
                        .argumentTypes(ImmutableList.of(new TypeSignature("K"), new TypeSignature("V"), new TypeSignature(BOOLEAN), new TypeSignature(BOOLEAN)))
                        .build())
                .argumentNullability(true, true, false, false)
                .hidden()
                .description("Creates a JSON object from key-value pairs")
                .build());
    }

    @Override
    protected SpecializedSqlScalarFunction specialize(BoundSignature boundSignature)
    {
        RowType keysRowType = (RowType) boundSignature.getArgumentType(0);
        RowType valuesRowType = (RowType) boundSignature.getArgumentType(1);
        checkArgument(keysRowType.getFields().size() == valuesRowType.getFields().size(), "keys and values do not match");
        MethodHandle methodHandle = METHOD_HANDLE
                .bindTo(keysRowType)
                .bindTo(valuesRowType);
        return new ChoicesSpecializedSqlScalarFunction(
                boundSignature,
                FAIL_ON_NULL,
                ImmutableList.of(BOXED_NULLABLE, BOXED_NULLABLE, NEVER_NULL, NEVER_NULL),
                methodHandle);
    }

    @UsedByGeneratedCode
    public static Slice jsonObject(RowType keysRowType, RowType valuesRowType, SqlRow keysRow, SqlRow valuesRow, boolean nullOnNull, boolean uniqueKeys)
    {
        return JsonType.jsonValue(buildObject(keysRowType, valuesRowType, keysRow, valuesRow, nullOnNull, uniqueKeys));
    }

    private static JsonValue buildObject(RowType keysRowType, RowType valuesRowType, SqlRow keysRow, SqlRow valuesRow, boolean nullOnNull, boolean uniqueKeys)
    {
        if (JSON_NO_PARAMETERS_ROW_TYPE.equals(keysRowType)) {
            return EMPTY_OBJECT;
        }

        List<JsonObjectMember> members = new ArrayList<>();
        Set<String> uniqueKeyNames = uniqueKeys ? new HashSet<>() : null;
        int keysRawIndex = keysRow.getRawIndex();
        int valuesRawIndex = valuesRow.getRawIndex();

        for (int i = 0; i < keysRowType.getFields().size(); i++) {
            Type keyType = keysRowType.getFields().get(i).getType();
            Object key = readNativeValue(keyType, keysRow.getRawFieldBlock(i), keysRawIndex);
            if (key == null) {
                throw new TrinoException(INVALID_FUNCTION_ARGUMENT, "null value passed for JSON object key to JSON_OBJECT function");
            }
            String keyName = ((Slice) key).toStringUtf8();

            Type valueType = valuesRowType.getFields().get(i).getType();
            Object value = readNativeValue(valueType, valuesRow.getRawFieldBlock(i), valuesRawIndex);

            JsonValue valueNode;
            if (value == null) {
                if (nullOnNull) {
                    valueNode = JsonNull.JSON_NULL;
                }
                else { // absent on null
                    continue;
                }
            }
            else if (valueType.equals(JsonType.JSON)) {
                io.trino.json.JsonPathItem pathItem = JsonType.toPathItem((Slice) value);
                checkState(pathItem != io.trino.json.JsonInputErrorNode.JSON_ERROR, "malformed JSON error suppressed in the input function");
                if (uniqueKeys) {
                    validateUniqueKeys(pathItem);
                }
                valueNode = JsonItems.asJsonValue(pathItem);
            }
            else {
                valueNode = TypedValue.fromValueAsObject(valueType, value);
            }

            if (uniqueKeys && !uniqueKeyNames.add(keyName)) {
                throw new TrinoException(INVALID_FUNCTION_ARGUMENT, "duplicate key passed to JSON_OBJECT function");
            }
            members.add(new JsonObjectMember(keyName, valueNode));
        }

        return new JsonObjectItem(members);
    }

    // Matches Jackson's default nesting depth; guards against stack overflow on adversarial inputs.
    private static final int MAX_VALIDATION_DEPTH = 1000;

    private static void validateUniqueKeys(io.trino.json.JsonPathItem item)
    {
        validateUniqueKeys(item, 0);
    }

    private static void validateUniqueKeys(io.trino.json.JsonPathItem item, int depth)
    {
        if (depth > MAX_VALIDATION_DEPTH) {
            throw new TrinoException(INVALID_FUNCTION_ARGUMENT, "JSON value passed to JSON_OBJECT exceeds maximum nesting depth of " + MAX_VALIDATION_DEPTH);
        }
        Optional<JsonValueView> view = JsonValueView.fromItem(item);
        if (view.isPresent()) {
            JsonValueView jsonView = view.get();
            if (jsonView.isObject()) {
                Set<String> keyNames = new HashSet<>();
                jsonView.forEachObjectMember((key, memberView) -> {
                    if (!keyNames.add(key)) {
                        throw new TrinoException(INVALID_FUNCTION_ARGUMENT, "duplicate key passed to JSON_OBJECT function");
                    }
                    validateUniqueKeys(memberView, depth + 1);
                });
                return;
            }
            if (jsonView.isArray()) {
                jsonView.forEachArrayElement(element -> validateUniqueKeys(element, depth + 1));
            }
            return;
        }

        if (item instanceof JsonObjectItem objectItem) {
            Set<String> keyNames = new HashSet<>();
            for (JsonObjectMember member : objectItem.members()) {
                if (!keyNames.add(member.key())) {
                    throw new TrinoException(INVALID_FUNCTION_ARGUMENT, "duplicate key passed to JSON_OBJECT function");
                }
                validateUniqueKeys(member.value(), depth + 1);
            }
            return;
        }

        if (item instanceof JsonArrayItem arrayItem) {
            for (JsonValue element : arrayItem.elements()) {
                validateUniqueKeys(element, depth + 1);
            }
        }
    }
}
