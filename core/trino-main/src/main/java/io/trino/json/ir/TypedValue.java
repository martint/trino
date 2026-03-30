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
package io.trino.json.ir;

import com.google.common.primitives.Primitives;
import io.trino.spi.type.Type;

import static com.google.common.base.Preconditions.checkArgument;
import static java.util.Objects.requireNonNull;

public record TypedValue(Type type, Object value)
{
    public TypedValue
    {
        requireNonNull(type, "type is null");
        requireNonNull(value, "value is null");
        checkArgument(Primitives.wrap(type.getJavaType()).isInstance(value), "%s value does not match the type %s", value.getClass(), type);
    }

    public TypedValue(Type type, long longValue)
    {
        this(type, Long.valueOf(longValue));
    }

    public TypedValue(Type type, double doubleValue)
    {
        this(type, Double.valueOf(doubleValue));
    }

    public TypedValue(Type type, boolean booleanValue)
    {
        this(type, Boolean.valueOf(booleanValue));
    }

    public static TypedValue fromValueAsObject(Type type, Object valueAsObject)
    {
        return new TypedValue(type, valueAsObject);
    }

    public Type getType()
    {
        return type;
    }

    public Object getObjectValue()
    {
        checkArgument(!type.getJavaType().isPrimitive(), "the type %s is represented as %s. call another method to retrieve the value", type, type.getJavaType());
        return value;
    }

    public Object getValueAsObject()
    {
        return value;
    }

    public long getLongValue()
    {
        checkArgument(long.class.equals(type.getJavaType()), "long value does not match the type %s", type);
        return (Long) value;
    }

    public double getDoubleValue()
    {
        checkArgument(double.class.equals(type.getJavaType()), "double value does not match the type %s", type);
        return (Double) value;
    }

    public boolean getBooleanValue()
    {
        checkArgument(boolean.class.equals(type.getJavaType()), "boolean value does not match the type %s", type);
        return (Boolean) value;
    }
}
