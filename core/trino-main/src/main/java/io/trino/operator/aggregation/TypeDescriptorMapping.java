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
package io.trino.operator.aggregation;

import com.google.common.collect.ImmutableSet;
import io.trino.operator.annotations.CastImplementationDependency;
import io.trino.operator.annotations.FunctionImplementationDependency;
import io.trino.operator.annotations.ImplementationDependency;
import io.trino.operator.annotations.LiteralImplementationDependency;
import io.trino.operator.annotations.OperatorImplementationDependency;
import io.trino.operator.annotations.TypeImplementationDependency;
import io.trino.spi.type.TemplateParameter;
import io.trino.spi.type.TypeDescriptor;
import io.trino.spi.type.TypeParameter;
import io.trino.spi.type.TypeTemplate;

import java.util.List;
import java.util.Map;
import java.util.Optional;
import java.util.Set;
import java.util.regex.Pattern;

import static com.google.common.base.Preconditions.checkArgument;
import static com.google.common.collect.ImmutableList.toImmutableList;
import static com.google.common.collect.ImmutableSortedMap.toImmutableSortedMap;
import static com.google.common.collect.ImmutableSortedSet.toImmutableSortedSet;
import static io.trino.sql.analyzer.TypeDescriptorTranslator.parseTypeSignature;
import static io.trino.sql.analyzer.TypeDescriptorTranslator.parseTypeTemplate;
import static java.lang.String.CASE_INSENSITIVE_ORDER;

class TypeDescriptorMapping
{
    // A type variable name follows the [A-Z][A-Z0-9]* convention; anything else a state parameter is bound to
    // (varchar, bigint, array(bigint), ...) is a concrete type.
    private static final Pattern TYPE_VARIABLE = Pattern.compile("[A-Z][A-Z0-9]*");

    private final Map<String, String> mapping;
    private final Set<String> typeVariableTargets;

    public TypeDescriptorMapping(Map<String, String> mapping)
    {
        this.mapping = mapping.entrySet().stream()
                .collect(toImmutableSortedMap(CASE_INSENSITIVE_ORDER, Map.Entry::getKey, Map.Entry::getValue));
        this.typeVariableTargets = mapping.values().stream()
                .filter(target -> TYPE_VARIABLE.matcher(target).matches())
                .collect(toImmutableSortedSet(CASE_INSENSITIVE_ORDER));
    }

    public Set<String> getTypeParameters()
    {
        return ImmutableSet.copyOf(mapping.keySet());
    }

    public ImplementationDependency mapTypes(ImplementationDependency dependency)
    {
        if (mapping.isEmpty()) {
            return dependency;
        }
        if (dependency instanceof TypeImplementationDependency typeDependency) {
            return new TypeImplementationDependency(mapTypeTemplate(typeDependency.getSignature()));
        }
        if (dependency instanceof LiteralImplementationDependency) {
            return dependency;
        }
        if (dependency instanceof FunctionImplementationDependency functionDependency) {
            return new FunctionImplementationDependency(
                    functionDependency.getName(),
                    functionDependency.getArgumentTypes().stream()
                            .map(this::mapTypeTemplate)
                            .collect(toImmutableList()),
                    functionDependency.getInvocationConvention(),
                    functionDependency.getType());
        }
        if (dependency instanceof OperatorImplementationDependency operatorDependency) {
            return new OperatorImplementationDependency(
                    operatorDependency.getOperator(),
                    operatorDependency.getArgumentTypes().stream()
                            .map(this::mapTypeTemplate)
                            .collect(toImmutableList()),
                    operatorDependency.getInvocationConvention(),
                    operatorDependency.getType());
        }
        if (dependency instanceof CastImplementationDependency castDependency) {
            return new CastImplementationDependency(
                    mapTypeTemplate(castDependency.getFromType()),
                    mapTypeTemplate(castDependency.getToType()),
                    castDependency.getInvocationConvention(),
                    castDependency.getType());
        }
        throw new IllegalArgumentException("Unsupported dependency " + dependency);
    }

    public TypeTemplate mapTypeTemplate(TypeTemplate template)
    {
        if (mapping.isEmpty()) {
            return template;
        }
        return switch (template) {
            // A state parameter is bound either to a type variable of the enclosing function (keep it open) or to
            // a concrete type (close it); parsing the target against the type-variable targets resolves which.
            case TypeTemplate.TypeVariable(String name) -> mapping.containsKey(name)
                    ? parseTypeTemplate(mapping.get(name), typeVariableTargets, Set.of())
                    : template;
            case TypeTemplate.TypeApplication(String base, List<TemplateParameter> parameters) -> new TypeTemplate.TypeApplication(
                    base,
                    parameters.stream()
                            .map(this::mapTemplateParameter)
                            .collect(toImmutableList()));
        };
    }

    private TemplateParameter mapTemplateParameter(TemplateParameter parameter)
    {
        if (parameter instanceof TemplateParameter.TypeArgument(Optional<String> name, TypeTemplate type)) {
            return new TemplateParameter.TypeArgument(name, mapTypeTemplate(type));
        }
        return parameter;
    }

    public TypeDescriptor mapTypeSignature(TypeDescriptor typeSignature)
    {
        if (mapping.isEmpty()) {
            return typeSignature;
        }
        if (mapping.containsKey(typeSignature.getBase())) {
            checkArgument(typeSignature.getParameters().isEmpty(), "Type variable can not have type parameters: %s", typeSignature);
            return parseTypeSignature(mapping.get(typeSignature.getBase()));
        }
        return new TypeDescriptor(
                typeSignature.getBase(),
                typeSignature.getParameters().stream()
                        .map(this::mapTypeSignatureParameter)
                        .collect(toImmutableList()));
    }

    private TypeParameter mapTypeSignatureParameter(TypeParameter parameter)
    {
        if (parameter instanceof TypeParameter.Type(Optional<String> name, TypeDescriptor type)) {
            return TypeParameter.typeParameter(name, mapTypeSignature(type));
        }
        return parameter;
    }
}
