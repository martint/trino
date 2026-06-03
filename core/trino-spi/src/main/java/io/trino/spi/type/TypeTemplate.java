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

import java.util.List;

import static java.util.Objects.requireNonNull;

/**
 * The open, variable-bearing structural form of a type, used in the argument and return positions of a
 * function {@link io.trino.spi.function.Signature} — e.g. {@code array(E)}, {@code decimal(p, s)},
 * {@code char(x + y)}.
 * <p>
 * It is the counterpart to the ground {@link TypeSignature}: where a {@code TypeSignature} denotes one
 * concrete type, a {@code TypeTemplate} denotes a family parameterized by type and numeric variables.
 * Operations live in {@link TypeTemplates} — {@code bind} substitutes variables to produce a ground
 * {@link TypeSignature}, and {@code fromTypeSignature} lifts a variable-free signature back into a template.
 */
public sealed interface TypeTemplate
        permits TypeTemplate.TypeApplication, TypeTemplate.TypeVariable
{
    /**
     * A type constructor applied to template parameters, e.g. {@code array(E)} or {@code decimal(p, s)}.
     * A nullary application (no parameters) is a concrete scalar type such as {@code bigint}.
     */
    record TypeApplication(String base, List<TemplateParameter> parameters)
            implements TypeTemplate
    {
        public TypeApplication
        {
            requireNonNull(base, "base is null");
            parameters = List.copyOf(parameters);
        }
    }

    /**
     * A reference to a declared type variable, e.g. the {@code E} in {@code array(E)}.
     */
    record TypeVariable(String name)
            implements TypeTemplate
    {
        public TypeVariable
        {
            requireNonNull(name, "name is null");
        }
    }
}
