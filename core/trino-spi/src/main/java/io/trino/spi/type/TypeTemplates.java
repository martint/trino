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
     * Lifts a ground type signature into a variable-free template. Fails if the signature carries a variable.
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
            case TypeParameter.Variable variable -> throw new IllegalArgumentException("Cannot lift a signature with a variable parameter: " + variable);
        };
    }
}
