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
package io.trino.spi.function;

import io.trino.spi.type.NumericExpression;
import io.trino.spi.type.Type;
import io.trino.spi.type.TypeSignature;
import io.trino.spi.type.TypeTemplate;
import io.trino.spi.type.TypeTemplates;

import java.util.ArrayList;
import java.util.List;
import java.util.Objects;
import java.util.Optional;
import java.util.Set;
import java.util.stream.Collectors;

import static java.util.Objects.requireNonNull;
import static java.util.stream.Collectors.joining;
import static java.util.stream.Collectors.toSet;
import static java.util.stream.Collectors.toUnmodifiableList;
import static java.util.stream.Stream.concat;

public class Signature
{
    public record Argument(TypeTemplate type, Optional<String> name)
    {
        public static Argument of(TypeTemplate type)
        {
            return new Argument(type, Optional.empty());
        }

        public static Argument of(TypeTemplate type, String name)
        {
            return new Argument(type, Optional.of(name));
        }
    }

    private final List<TypeVariableConstraint> typeVariableConstraints;
    private final List<NumericVariableConstraint> longVariableConstraints;
    private final TypeTemplate returnType;
    private final List<Argument> arguments;
    private final boolean variableArity;

    private Signature(
            List<TypeVariableConstraint> typeVariableConstraints,
            List<NumericVariableConstraint> longVariableConstraints,
            TypeTemplate returnType,
            List<Argument> arguments,
            boolean variableArity)
    {
        this.typeVariableConstraints = List.copyOf(typeVariableConstraints);
        this.longVariableConstraints = List.copyOf(longVariableConstraints);
        this.returnType = requireNonNull(returnType, "returnType is null");
        this.arguments = List.copyOf(arguments);
        this.variableArity = variableArity;
    }

    public TypeTemplate getReturnType()
    {
        return returnType;
    }

    public List<Argument> getArguments()
    {
        return arguments;
    }

    public List<TypeTemplate> getArgumentTypes()
    {
        return arguments.stream()
                .map(Argument::type)
                .collect(toUnmodifiableList());
    }

    public boolean isVariableArity()
    {
        return variableArity;
    }

    /**
     * Only parametric types with type-kinded parameters are considered "generic".
     */
    public boolean isGeneric()
    {
        return !typeVariableConstraints.isEmpty();
    }

    public List<TypeVariableConstraint> getTypeVariableConstraints()
    {
        return typeVariableConstraints;
    }

    public List<NumericVariableConstraint> getLongVariableConstraints()
    {
        return longVariableConstraints;
    }

    @Override
    public int hashCode()
    {
        return Objects.hash(typeVariableConstraints, longVariableConstraints, returnType, arguments, variableArity);
    }

    @Override
    public boolean equals(Object obj)
    {
        if (this == obj) {
            return true;
        }
        if (!(obj instanceof Signature other)) {
            return false;
        }
        return Objects.equals(this.typeVariableConstraints, other.typeVariableConstraints) &&
                Objects.equals(this.longVariableConstraints, other.longVariableConstraints) &&
                Objects.equals(this.returnType, other.returnType) &&
                Objects.equals(this.arguments, other.arguments) &&
                this.variableArity == other.variableArity;
    }

    @Override
    public String toString()
    {
        List<String> allConstraints = concat(
                typeVariableConstraints.stream().map(TypeVariableConstraint::toString),
                longVariableConstraints.stream().map(NumericVariableConstraint::toString))
                .collect(Collectors.toList());

        return (allConstraints.isEmpty() ? "" : allConstraints.stream().collect(joining(",", "<", ">"))) +
                arguments.stream().map(Argument::type).map(TypeTemplates::render).collect(joining(",", "(", ")")) +
                ":" + TypeTemplates.render(returnType);
    }

    public static Builder builder()
    {
        return new Builder();
    }

    public static Builder builder(Signature base)
    {
        Builder builder = new Builder()
                .typeVariableConstraints(base.typeVariableConstraints)
                .longVariableConstraints(base.longVariableConstraints)
                .returnType(base.returnType)
                .arguments(base.arguments);
        if (base.variableArity) {
            builder.variableArity();
        }
        return builder;
    }

    public static final class Builder
    {
        private final List<TypeVariableConstraint> typeVariableConstraints = new ArrayList<>();
        private final List<NumericVariableConstraint> longVariableConstraints = new ArrayList<>();
        private TypeTemplate returnType;
        private final List<Argument> arguments = new ArrayList<>();
        private boolean variableArity;

        private Builder() {}

        public Builder typeVariable(String name)
        {
            typeVariableConstraints.add(TypeVariableConstraint.builder(name).build());
            return this;
        }

        public Builder comparableTypeParameter(String name)
        {
            typeVariableConstraints.add(TypeVariableConstraint.builder(name)
                    .comparableRequired()
                    .build());
            return this;
        }

        public Builder orderableTypeParameter(String name)
        {
            typeVariableConstraints.add(TypeVariableConstraint.builder(name)
                    .orderableRequired()
                    .build());
            return this;
        }

        public Builder castableToTypeParameter(String name, TypeSignature toType)
        {
            typeVariableConstraints.add(TypeVariableConstraint.builder(name)
                    .castableTo(toType)
                    .build());
            return this;
        }

        public Builder castableFromTypeParameter(String name, TypeSignature fromType)
        {
            typeVariableConstraints.add(TypeVariableConstraint.builder(name)
                    .castableFrom(fromType)
                    .build());
            return this;
        }

        public Builder rowTypeParameter(String name)
        {
            typeVariableConstraints.add(TypeVariableConstraint.builder(name)
                    .rowType()
                    .build());
            return this;
        }

        public Builder typeVariableConstraint(TypeVariableConstraint typeVariableConstraint)
        {
            this.typeVariableConstraints.add(requireNonNull(typeVariableConstraint, "typeVariableConstraint is null"));
            return this;
        }

        public Builder typeVariableConstraints(List<TypeVariableConstraint> typeVariableConstraints)
        {
            this.typeVariableConstraints.addAll(requireNonNull(typeVariableConstraints, "typeVariableConstraints is null"));
            return this;
        }

        public Builder returnType(TypeTemplate returnType)
        {
            this.returnType = requireNonNull(returnType, "returnType is null");
            return this;
        }

        public Builder returnType(TypeSignature returnType)
        {
            return returnType(TypeTemplates.fromTypeSignature(returnType));
        }

        public Builder returnType(Type returnType)
        {
            return returnType(returnType.getTypeSignature());
        }

        public Builder longVariable(String name, NumericExpression expression)
        {
            this.longVariableConstraints.add(new NumericVariableConstraint(name, expression));
            return this;
        }

        public Builder longVariable(String name)
        {
            this.longVariableConstraints.add(new NumericVariableConstraint(name, new NumericExpression.Variable(name)));
            return this;
        }

        public Builder longVariableConstraints(List<NumericVariableConstraint> longVariableConstraints)
        {
            this.longVariableConstraints.addAll(longVariableConstraints);
            return this;
        }

        public Builder argumentType(TypeTemplate type)
        {
            arguments.add(Argument.of(type));
            return this;
        }

        public Builder argumentType(TypeTemplate type, String name)
        {
            arguments.add(Argument.of(type, name));
            return this;
        }

        public Builder argumentType(TypeSignature type)
        {
            return argumentType(TypeTemplates.fromTypeSignature(type));
        }

        public Builder argumentType(TypeSignature type, String name)
        {
            return argumentType(TypeTemplates.fromTypeSignature(type), name);
        }

        public Builder argumentType(Type type)
        {
            return argumentType(type.getTypeSignature());
        }

        public Builder argumentType(Type type, String name)
        {
            return argumentType(type.getTypeSignature(), name);
        }

        public Builder argumentTypes(List<TypeSignature> argumentTypes)
        {
            for (TypeSignature argumentType : argumentTypes) {
                argumentType(argumentType);
            }
            return this;
        }

        public Builder arguments(List<Argument> arguments)
        {
            this.arguments.clear();
            this.arguments.addAll(arguments);
            return this;
        }

        public Builder variableArity()
        {
            this.variableArity = true;
            return this;
        }

        public Signature build()
        {
            // Normalize base-string type variables (as the TypeSignature-based builder methods produce) into
            // first-class TypeVariable nodes, so a programmatically-built signature equals the parsed one.
            Set<String> typeVariableNames = typeVariableConstraints.stream()
                    .map(TypeVariableConstraint::getName)
                    .collect(toSet());
            TypeTemplate canonicalReturnType = TypeTemplates.canonicalizeTypeVariables(returnType, typeVariableNames);
            List<Argument> canonicalArguments = arguments.stream()
                    .map(argument -> new Argument(TypeTemplates.canonicalizeTypeVariables(argument.type(), typeVariableNames), argument.name()))
                    .collect(toUnmodifiableList());
            return new Signature(typeVariableConstraints, longVariableConstraints, canonicalReturnType, canonicalArguments, variableArity);
        }
    }
}
