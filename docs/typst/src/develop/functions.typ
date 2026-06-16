#import "/lib/trino-docs.typ": *

#anchor("doc-develop-functions")
= Functions

== Plugin implementation

The function framework is used to implement SQL functions. Trino includes a number of built-in functions. In order to implement new functions, you can write a plugin that returns one or more functions from #raw("getFunctions()"):

#code-block("java", "public class ExampleFunctionsPlugin
        implements Plugin
{
    @Override
    public Set<Class<?>> getFunctions()
    {
        return ImmutableSet.<Class<?>>builder()
                .add(ExampleNullFunction.class)
                .add(IsNullFunction.class)
                .add(IsEqualOrNullFunction.class)
                .add(ExampleStringFunction.class)
                .add(ExampleAverageFunction.class)
                .build();
    }
}")

Note that the #raw("ImmutableSet") class is a utility class from Guava. The #raw("getFunctions()") method contains all of the classes for the functions that we will implement below in this tutorial.

For a full example in the codebase, see either the #raw("trino-ml") module for machine learning functions or the #raw("trino-teradata-functions") module for Teradata-compatible functions, both in the #raw("plugin") directory of the Trino source.

== Scalar function implementation

The function framework uses annotations to indicate relevant information about functions, including name, description, return type and parameter types. Below is a sample function which implements #raw("is_null"):

#code-block("java", "public class ExampleNullFunction
{
    @ScalarFunction(\"is_null\", deterministic = true)
    @Description(\"Returns TRUE if the argument is NULL\")
    @SqlType(StandardTypes.BOOLEAN)
    public static boolean isNull(
            @SqlNullable @SqlType(StandardTypes.VARCHAR) Slice string)
    {
        return (string == null);
    }
}")

The function #raw("is_null") takes a single #raw("VARCHAR") argument and returns a #raw("BOOLEAN") indicating if the argument was #raw("NULL"). Note that the argument to the function is of type #raw("Slice"). #raw("VARCHAR") uses #raw("Slice"), which is essentially a wrapper around #raw("byte[]"), rather than #raw("String") for its native container type.

The #raw("deterministic") argument indicates that a function has no side effects and, for subsequent calls with the same argument\(s\), the function returns the exact same value\(s\).

In Trino, deterministic functions don't rely on any changing state and don't modify any state. The #raw("deterministic") flag is optional and defaults to #raw("true").

For example, the function #link(label("fn-shuffle"), raw("shuffle")) is non-deterministic, since it uses random values. On the other hand, #link(label("fn-now"), raw("now")) is deterministic, because subsequent calls in a single query return the same timestamp.

Any function with non-deterministic behavior is required to set #raw("deterministic = false") to avoid unexpected results.

- #raw("@SqlType"):
  
  The #raw("@SqlType") annotation is used to declare the return type and the argument types. Note that the return type and arguments of the Java code must match the native container types of the corresponding annotations.
- #raw("@SqlNullable"):
  
  The #raw("@SqlNullable") annotation indicates that the argument may be #raw("NULL"). Without this annotation the framework assumes that all functions return #raw("NULL") if any of their arguments are #raw("NULL"). When working with a #raw("Type") that has a primitive native container type, such as #raw("BigintType"), use the object wrapper for the native container type when using #raw("@SqlNullable"). The method must be annotated with #raw("@SqlNullable") if it can return #raw("NULL") when the arguments are non-null.
- #raw("@Name"):
  
  The #raw("@Name") annotation declares the SQL-visible parameter name for an argument. With a declared name the function is invocable using the named-argument form #raw("f(name => value)") in addition to the positional form. Functions without #raw("@Name") annotations on their parameters can only be called positionally. For example:
  
  #code-block("java", "@ScalarFunction(\"clamp\")
  @SqlType(StandardTypes.BIGINT)
  public static long clamp(
          @Name(\"value\") @SqlType(StandardTypes.BIGINT) long value,
          @Name(\"lo\") @SqlType(StandardTypes.BIGINT) long lo,
          @Name(\"hi\") @SqlType(StandardTypes.BIGINT) long hi)
  {
      return Math.max(lo, Math.min(hi, value));
  }")
  
  After registration the function is callable both ways:
  
  #code-block("sql", "SELECT clamp(7, 0, 5);
  SELECT clamp(value => 7, hi => 5, lo => 0);")

== Parametric scalar functions

Scalar functions that have type parameters have some additional complexity. To make our previous example work with any type we need the following:

#code-block("java", "@ScalarFunction(name = \"is_null\")
@Description(\"Returns TRUE if the argument is NULL\")
public final class IsNullFunction
{
    @TypeParameter(\"T\")
    @SqlType(StandardTypes.BOOLEAN)
    public static boolean isNullSlice(@SqlNullable @SqlType(\"T\") Slice value)
    {
        return (value == null);
    }

    @TypeParameter(\"T\")
    @SqlType(StandardTypes.BOOLEAN)
    public static boolean isNullLong(@SqlNullable @SqlType(\"T\") Long value)
    {
        return (value == null);
    }

    @TypeParameter(\"T\")
    @SqlType(StandardTypes.BOOLEAN)
    public static boolean isNullDouble(@SqlNullable @SqlType(\"T\") Double value)
    {
        return (value == null);
    }

    // ...and so on for each native container type
}")

- #raw("@TypeParameter"):
  
  The #raw("@TypeParameter") annotation is used to declare a type parameter which can be used in the argument types #raw("@SqlType") annotation, or return type of the function. It can also be used to annotate a parameter of type #raw("Type"). At runtime, the engine will bind the concrete type to this parameter. #raw("@OperatorDependency") may be used to declare that an additional function for operating on the given type parameter is needed. For example, the following function will only bind to types which have an equals function defined:

#code-block("java", "@ScalarFunction(name = \"is_equal_or_null\")
@Description(\"Returns TRUE if arguments are equal or both NULL\")
public final class IsEqualOrNullFunction
{
    @TypeParameter(\"T\")
    @SqlType(StandardTypes.BOOLEAN)
    public static boolean isEqualOrNullSlice(
            @OperatorDependency(
                    operator = OperatorType.EQUAL,
                    returnType = StandardTypes.BOOLEAN,
                    argumentTypes = {\"T\", \"T\"}) MethodHandle equals,
            @SqlNullable @SqlType(\"T\") Slice value1,
            @SqlNullable @SqlType(\"T\") Slice value2)
    {
        if (value1 == null && value2 == null) {
            return true;
        }
        if (value1 == null || value2 == null) {
            return false;
        }
        return (boolean) equals.invokeExact(value1, value2);
    }

    // ...and so on for each native container type
}")

== Another scalar function example

The #raw("lowercaser") function takes a single #raw("VARCHAR") argument and returns a #raw("VARCHAR"), which is the argument converted to lower case:

#code-block("java", "public class ExampleStringFunction
{
    @ScalarFunction(\"lowercaser\")
    @Description(\"Converts the string to alternating case\")
    @SqlType(StandardTypes.VARCHAR)
    public static Slice lowercaser(@SqlType(StandardTypes.VARCHAR) Slice slice)
    {
        String argument = slice.toStringUtf8();
        return Slices.utf8Slice(argument.toLowerCase());
    }
}")

Note that for most common string functions, including converting a string to lower case, the Slice library also provides implementations that work directly on the underlying #raw("byte[]"), which have much better performance. This function has no #raw("@SqlNullable") annotations, meaning that if the argument is #raw("NULL"), the result will automatically be #raw("NULL") \(the function will not be called\).

== Aggregation function implementation

Aggregation functions use a similar framework to scalar functions, but are a bit more complex.

- #raw("AccumulatorState"):
  
  All aggregation functions accumulate input rows into a state object; this object must implement #raw("AccumulatorState"). For simple aggregations, just extend #raw("AccumulatorState") into a new interface with the getters and setters you want, and the framework will generate all the implementations and serializers for you. If you need a more complex state object, you will need to implement #raw("AccumulatorStateFactory") and #raw("AccumulatorStateSerializer") and provide these via the #raw("AccumulatorStateMetadata") annotation.

The following code implements the aggregation function #raw("avg_double") which computes the average of a #raw("DOUBLE") column:

#code-block("java", "@AggregationFunction(\"avg_double\")
public class AverageAggregation
{
    @InputFunction
    public static void input(
            LongAndDoubleState state,
            @SqlType(StandardTypes.DOUBLE) double value)
    {
        state.setLong(state.getLong() + 1);
        state.setDouble(state.getDouble() + value);
    }

    @CombineFunction
    public static void combine(
            LongAndDoubleState state,
            LongAndDoubleState otherState)
    {
        state.setLong(state.getLong() + otherState.getLong());
        state.setDouble(state.getDouble() + otherState.getDouble());
    }

    @OutputFunction(StandardTypes.DOUBLE)
    public static void output(LongAndDoubleState state, BlockBuilder out)
    {
        long count = state.getLong();
        if (count == 0) {
            out.appendNull();
        }
        else {
            double value = state.getDouble();
            DOUBLE.writeDouble(out, value / count);
        }
    }
}")

The average has two parts: the sum of the #raw("DOUBLE") in each row of the column and the #raw("LONG") count of the number of rows seen. #raw("LongAndDoubleState") is an interface which extends #raw("AccumulatorState"):

#code-block("java", "public interface LongAndDoubleState
        extends AccumulatorState
{
    long getLong();

    void setLong(long value);

    double getDouble();

    void setDouble(double value);
}")

As stated above, for simple #raw("AccumulatorState") objects, it is sufficient to just define the interface with the getters and setters, and the framework will generate the implementation for you.

An in-depth look at the various annotations relevant to writing an aggregation function follows:

- #raw("@InputFunction"):
  
  The #raw("@InputFunction") annotation declares the function which accepts input rows and stores them in the #raw("AccumulatorState"). Similar to scalar functions you must annotate the arguments with #raw("@SqlType").  Note that, unlike in the above scalar example where #raw("Slice") is used to hold #raw("VARCHAR"), the primitive #raw("double") type is used for the argument to input. In this example, the input function simply keeps track of the running count of rows \(via #raw("setLong()")\) and the running sum \(via #raw("setDouble()")\).
- #raw("@CombineFunction"):
  
  The #raw("@CombineFunction") annotation declares the function used to combine two state objects. This function is used to merge all the partial aggregation states. It takes two state objects, and merges the results into the first one \(in the above example, just by adding them together\).
- #raw("@OutputFunction"):
  
  The #raw("@OutputFunction") is the last function called when computing an aggregation. It takes the final state object \(the result of merging all partial states\) and writes the result to a #raw("BlockBuilder").
- Where does serialization happen, and what is #raw("GroupedAccumulatorState")?
  
  The #raw("@InputFunction") is usually run on a different worker from the #raw("@CombineFunction"), so the state objects are serialized and transported between these workers by the aggregation framework. #raw("GroupedAccumulatorState") is used when performing a #raw("GROUP BY") aggregation, and an implementation will be automatically generated for you, if you don't specify a #raw("AccumulatorStateFactory")

== Deprecated function

The #raw("@Deprecated") annotation has to be used on any function that should no longer be used. The annotation causes Trino to generate a warning whenever SQL statements use a deprecated function. When a function is deprecated, the #raw("@Description") needs to be replaced with a note about the deprecation and the replacement function:

#code-block("java", "public class ExampleDeprecatedFunction
{
    @Deprecated
    @ScalarFunction(\"bad_function\")
    @Description(\"(DEPRECATED) Use good_function() instead\")
    @SqlType(StandardTypes.BOOLEAN)
    public static boolean bad_function()
    {
        return false;
    }
}")
