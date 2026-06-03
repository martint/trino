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

import io.trino.spi.type.TemplateParameter.NumericArgument;
import io.trino.spi.type.TemplateParameter.TypeArgument;
import io.trino.spi.type.TypeTemplate.TypeApplication;
import io.trino.spi.type.TypeTemplate.TypeVariable;

import java.util.ArrayList;
import java.util.List;
import java.util.Map;
import java.util.Optional;
import java.util.Set;

import static java.util.stream.Collectors.joining;
import static java.util.stream.Collectors.toList;

/**
 * Operations over {@link TypeTemplate} — binding it to ground types, and lifting a ground
 * {@link TypeSignature} into one. Kept here rather than on the template records so the template stays a
 * pure data carrier and does not depend on {@link TypeSignature}.
 */
public final class TypeTemplates
{
    private TypeTemplates() {}

    /**
     * Substitutes the given type- and numeric-variable bindings, producing a ground type signature.
     */
    public static TypeSignature bind(TypeTemplate template, Map<String, TypeSignature> typeBindings, Map<String, Long> numericBindings)
    {
        return switch (template) {
            case TypeVariable(String name) -> {
                TypeSignature binding = typeBindings.get(name);
                if (binding == null) {
                    throw new IllegalArgumentException("No binding for type variable " + name);
                }
                yield binding;
            }
            case TypeApplication(String base, List<TemplateParameter> parameters) -> {
                List<TypeParameter> bound = new ArrayList<>(parameters.size());
                for (TemplateParameter parameter : parameters) {
                    bound.add(bind(parameter, typeBindings, numericBindings));
                }
                yield new TypeSignature(base, bound);
            }
        };
    }

    private static TypeParameter bind(TemplateParameter parameter, Map<String, TypeSignature> typeBindings, Map<String, Long> numericBindings)
    {
        return switch (parameter) {
            case TypeArgument(Optional<String> name, TypeTemplate type) -> TypeParameter.typeParameter(name, bind(type, typeBindings, numericBindings));
            case NumericArgument(NumericExpression value) -> TypeParameter.numericParameter(NumericExpressions.evaluate(value, numericBindings).longValueExact());
        };
    }

    /**
     * Lowers a ground template to a type signature. Fails if the template carries an unbound variable.
     */
    public static TypeSignature toTypeSignature(TypeTemplate template)
    {
        return bind(template, Map.of(), Map.of());
    }

    /**
     * Transitional: converts a template (which MAY contain variables) to the legacy {@link TypeSignature}
     * form the binder and operator validation still expect — a type variable becomes a bare base-string
     * signature, a numeric variable a {@link TypeParameter.Variable}. Removed once those consumers read
     * {@link TypeTemplate} natively; calculated {@link NumericExpression.Operation}s must be inlined first.
     */
    public static TypeSignature toLegacyTypeSignature(TypeTemplate template)
    {
        return switch (template) {
            case TypeVariable(String name) -> new TypeSignature(name);
            case TypeApplication(String base, List<TemplateParameter> parameters) -> new TypeSignature(
                    base,
                    parameters.stream().map(TypeTemplates::toLegacyParameter).collect(toList()));
        };
    }

    private static TypeParameter toLegacyParameter(TemplateParameter parameter)
    {
        return switch (parameter) {
            case TypeArgument(Optional<String> name, TypeTemplate type) -> TypeParameter.typeParameter(name, toLegacyTypeSignature(type));
            case NumericArgument(NumericExpression value) -> switch (value) {
                case NumericExpression.Literal(long literal) -> TypeParameter.numericParameter(literal);
                case NumericExpression.Variable(String name) -> TypeParameter.typeVariable(name);
                case NumericExpression.Operation operation -> throw new UnsupportedOperationException("Calculated numeric expression must be inlined before this conversion: " + operation);
            };
        };
    }

    /**
     * Normalizes a template so a declared type variable is always a first-class {@link TypeTemplate.TypeVariable}:
     * a parameterless {@link TypeTemplate.TypeApplication} whose base names a declared type variable (a base-string
     * variable, as the programmatic builder API produces) becomes a {@code TypeVariable}. This makes a signature
     * built programmatically equal to the same signature parsed from {@code @SqlType} syntax.
     */
    public static TypeTemplate canonicalizeTypeVariables(TypeTemplate template, Set<String> typeVariableNames)
    {
        return switch (template) {
            case TypeVariable variable -> variable;
            case TypeApplication(String base, List<TemplateParameter> parameters) -> {
                if (parameters.isEmpty() && typeVariableNames.stream().anyMatch(base::equalsIgnoreCase)) {
                    yield new TypeVariable(base);
                }
                List<TemplateParameter> canonical = new ArrayList<>(parameters.size());
                for (TemplateParameter parameter : parameters) {
                    canonical.add(canonicalizeTypeVariables(parameter, typeVariableNames));
                }
                yield new TypeApplication(base, canonical);
            }
        };
    }

    private static TemplateParameter canonicalizeTypeVariables(TemplateParameter parameter, Set<String> typeVariableNames)
    {
        return switch (parameter) {
            case TypeArgument(Optional<String> name, TypeTemplate type) -> new TypeArgument(name, canonicalizeTypeVariables(type, typeVariableNames));
            case NumericArgument numeric -> numeric;
        };
    }

    /**
     * Whether the template contains a calculated (numeric-variable or expression) parameter — i.e. a numeric
     * parameter that is not a fixed literal. A bare type variable is not "calculated" (it is generic).
     */
    public static boolean isCalculated(TypeTemplate template)
    {
        return switch (template) {
            case TypeVariable(String name) -> false;
            case TypeApplication(String base, List<TemplateParameter> parameters) -> parameters.stream().anyMatch(TypeTemplates::isCalculated);
        };
    }

    private static boolean isCalculated(TemplateParameter parameter)
    {
        return switch (parameter) {
            case TypeArgument(Optional<String> name, TypeTemplate type) -> isCalculated(type);
            case NumericArgument(NumericExpression value) -> !(value instanceof NumericExpression.Literal);
        };
    }

    /**
     * The base name of a template: the variable name for a {@link TypeTemplate.TypeVariable}, the constructor
     * name for a {@link TypeTemplate.TypeApplication}.
     */
    public static String baseName(TypeTemplate template)
    {
        return switch (template) {
            case TypeVariable(String name) -> name;
            case TypeApplication(String base, List<TemplateParameter> parameters) -> base;
        };
    }

    /**
     * Lifts a type signature into a template. A {@link TypeParameter.Variable} is taken to be a numeric
     * variable, matching the programmatic convention where a type variable is a bare base-string signature
     * and only numeric parameters (decimal precision/scale, varchar length) are written as variables.
     */
    public static TypeTemplate fromTypeSignature(TypeSignature signature)
    {
        List<TemplateParameter> parameters = new ArrayList<>(signature.getParameters().size());
        for (TypeParameter parameter : signature.getParameters()) {
            parameters.add(fromTypeParameter(parameter));
        }
        return new TypeApplication(signature.getBase(), parameters);
    }

    private static TemplateParameter fromTypeParameter(TypeParameter parameter)
    {
        return switch (parameter) {
            case TypeParameter.Type(Optional<String> name, TypeSignature type) -> new TypeArgument(name, fromTypeSignature(type));
            case TypeParameter.Numeric(long value) -> new NumericArgument(new NumericExpression.Literal(value));
            case TypeParameter.Variable(String name) -> new NumericArgument(new NumericExpression.Variable(name));
        };
    }

    public static TypeTemplate typeVariable(String name)
    {
        return new TypeVariable(name);
    }

    public static NumericExpression numericVariable(String name)
    {
        return new NumericExpression.Variable(name);
    }

    public static TypeTemplate parametricType(String base, TypeTemplate... typeArguments)
    {
        List<TemplateParameter> parameters = new ArrayList<>(typeArguments.length);
        for (TypeTemplate argument : typeArguments) {
            parameters.add(new TypeArgument(Optional.empty(), argument));
        }
        return new TypeApplication(base, parameters);
    }

    public static TypeTemplate numericType(String base, NumericExpression... values)
    {
        List<TemplateParameter> parameters = new ArrayList<>(values.length);
        for (NumericExpression value : values) {
            parameters.add(new NumericArgument(value));
        }
        return new TypeApplication(base, parameters);
    }

    public static TypeTemplate arrayType(TypeTemplate elementType)
    {
        return parametricType("array", elementType);
    }

    public static TypeTemplate mapType(TypeTemplate keyType, TypeTemplate valueType)
    {
        return parametricType("map", keyType, valueType);
    }

    public static TypeTemplate functionType(TypeTemplate first, TypeTemplate... rest)
    {
        List<TemplateParameter> parameters = new ArrayList<>(rest.length + 1);
        parameters.add(new TypeArgument(Optional.empty(), first));
        for (TypeTemplate type : rest) {
            parameters.add(new TypeArgument(Optional.empty(), type));
        }
        return new TypeApplication("function", parameters);
    }

    public static TypeTemplate rowType(List<TemplateParameter> fields)
    {
        return new TypeApplication("row", List.copyOf(fields));
    }

    /**
     * Renders the template in type syntax, e.g. {@code array(E)}, {@code decimal(p,s)}, {@code char(x + y)}.
     * Mirrors the legacy {@code TypeSignature} formatting (unbounded varchar, time-zone syntax, quoted row
     * field names) so error messages and round-trips match.
     */
    public static String render(TypeTemplate template)
    {
        return switch (template) {
            case TypeVariable(String name) -> name;
            case TypeApplication(String base, List<TemplateParameter> parameters) -> renderApplication(base, parameters);
        };
    }

    private static String renderApplication(String base, List<TemplateParameter> parameters)
    {
        if (parameters.isEmpty()) {
            return base;
        }
        if (base.equalsIgnoreCase(StandardTypes.VARCHAR)
                && parameters.size() == 1
                && parameters.getFirst() instanceof NumericArgument(NumericExpression.Literal(long length))
                && length == VarcharType.UNBOUNDED_LENGTH) {
            return base;
        }
        if (base.equalsIgnoreCase(StandardTypes.TIMESTAMP_WITH_TIME_ZONE)) {
            return "timestamp(" + render(parameters.getFirst()) + ") with time zone";
        }
        if (base.equalsIgnoreCase(StandardTypes.TIME_WITH_TIME_ZONE)) {
            return "time(" + render(parameters.getFirst()) + ") with time zone";
        }
        return base + parameters.stream().map(TypeTemplates::render).collect(joining(",", "(", ")"));
    }

    private static String render(TemplateParameter parameter)
    {
        return switch (parameter) {
            case TypeArgument(Optional<String> name, TypeTemplate type) -> name.map(fieldName -> "\"" + fieldName.replace("\"", "\"\"") + "\" ").orElse("") + render(type);
            case NumericArgument(NumericExpression value) -> NumericExpressions.render(value);
        };
    }
}
