#import "/lib/trino-docs.typ": *

#anchor("doc-functions-aggregate")
= Aggregate functions

Aggregate functions operate on a set of values to compute a single result.

Except for #link(label("fn-count"), raw("count")), #link(label("fn-count-if"), raw("count_if")), #link(label("fn-max-by"), raw("max_by")), #link(label("fn-min-by"), raw("min_by")) and #link(label("fn-approx-distinct"), raw("approx_distinct")), all of these aggregate functions ignore null values and return null for no input rows or when all values are null. For example, #link(label("fn-sum"), raw("sum")) returns null rather than zero and #link(label("fn-avg"), raw("avg")) does not include null values in the count. The #raw("coalesce") function can be used to convert null into zero.

#anchor("ref-aggregate-function-ordering-during-aggregation")

== Ordering during aggregation

Some aggregate functions such as #link(label("fn-array-agg"), raw("array_agg")) produce different results depending on the order of input values. This ordering can be specified by writing an #link(label("ref-order-by-clause"))[order-by-clause] within the aggregate function:

#code-block(none, "array_agg(x ORDER BY y DESC)
array_agg(x ORDER BY x, y, z)")

#anchor("ref-aggregate-function-filtering-during-aggregation")

== Filtering during aggregation

The #raw("FILTER") keyword can be used to remove rows from aggregation processing with a condition expressed using a #raw("WHERE") clause. This is evaluated for each row before it is used in the aggregation and is supported for all aggregate functions.

#code-block("text", "aggregate_function(...) FILTER (WHERE <condition>)")

A common and very useful example is to use #raw("FILTER") to remove nulls from consideration when using #raw("array_agg"):

#code-block(none, "SELECT array_agg(name) FILTER (WHERE name IS NOT NULL)
FROM region;")

As another example, imagine you want to add a condition on the count for Iris flowers, modifying the following query:

#code-block(none, "SELECT species,
       count(*) AS count
FROM iris
GROUP BY species;")

#code-block("text", "species    | count
-----------+-------
setosa     |   50
virginica  |   50
versicolor |   50")

If you just use a normal #raw("WHERE") statement you lose information:

#code-block(none, "SELECT species,
    count(*) AS count
FROM iris
WHERE petal_length_cm > 4
GROUP BY species;")

#code-block("text", "species    | count
-----------+-------
virginica  |   50
versicolor |   34")

Using a filter you retain all information:

#code-block(none, "SELECT species,
       count(*) FILTER (where petal_length_cm > 4) AS count
FROM iris
GROUP BY species;")

#code-block("text", "species    | count
-----------+-------
virginica  |   50
setosa     |    0
versicolor |   34")

== General aggregate functions

#function-def("fn-any-value", "any_value(x)", "[same as input]")[
Returns an arbitrary non-null value #raw("x"), if one exists. #raw("x") can be any valid expression. This allows you to return values from columns that are not directly part of the aggregation, including expressions using these columns, in a query.

For example, the following query returns the customer name from the #raw("name") column, and returns the sum of all total prices as customer spend. The aggregation however uses the rows grouped by the customer identifier #raw("custkey") a required, since only that column is guaranteed to be unique:

#code-block(none, "SELECT sum(o.totalprice) as spend,
    any_value(c.name)
FROM tpch.tiny.orders o
JOIN tpch.tiny.customer c
ON o.custkey  = c.custkey
GROUP BY c.custkey;
ORDER BY spend;")
]

#function-def("fn-arbitrary", "arbitrary(x)", "[same as input]")[
Returns an arbitrary non-null value of #raw("x"), if one exists. Identical to #link(label("fn-any-value"), raw("any_value")).
]

#function-def("fn-array-agg", "array_agg(x)", "array<[same as input]>")[
Returns an array created from the input #raw("x") elements.
]

#function-def("fn-avg", "avg(x)", "double")[
Returns the average \(arithmetic mean\) of all input values.
]

#function-def("fn-avg-2", "avg(real)", "real", ref: false)[
Returns the average \(arithmetic mean\) of all input values.
]

#function-def("fn-avg-3", "avg(decimal)", "decimal", ref: false)[
Returns the average \(arithmetic mean\) of all input values.
]

#function-def("fn-avg-4", "avg(number)", "number", ref: false)[
Returns the average \(arithmetic mean\) of all input values.
]

#function-def("fn-avg-5", "avg(time interval type)", "time interval type", ref: false)[
Returns the average interval length of all input values.
]

#function-def("fn-bool-and", "bool_and(boolean)", "boolean")[
Returns #raw("TRUE") if every input value is #raw("TRUE"), otherwise #raw("FALSE").
]

#function-def("fn-bool-or", "bool_or(boolean)", "boolean")[
Returns #raw("TRUE") if any input value is #raw("TRUE"), otherwise #raw("FALSE").
]

#function-def("fn-checksum", "checksum(x)", "varbinary")[
Returns an order-insensitive checksum of the given values.
]

#function-def("fn-count", "count(*)", "bigint")[
Returns the number of input rows.
]

#function-def("fn-count-2", "count(x)", "bigint", ref: false)[
Returns the number of non-null input values.
]

#function-def("fn-count-if", "count_if(x)", "bigint")[
Returns the number of #raw("TRUE") input values. This function is equivalent to #raw("count(CASE WHEN x THEN 1 END)").
]

#function-def("fn-every", "every(boolean)", "boolean")[
This is an alias for #link(label("fn-bool-and"), raw("bool_and")).
]

#function-def("fn-geometric-mean", "geometric_mean(x)", "double")[
Returns the geometric mean of all input values.
]

#function-def("fn-listagg", "listagg(x, separator)", "varchar")[
Returns the concatenated input values, separated by the #raw("separator") string.

Synopsis:

#code-block(none, "LISTAGG( expression [, separator] [ON OVERFLOW overflow_behaviour])
    WITHIN GROUP (ORDER BY sort_item, [...]) [FILTER (WHERE condition)]")

#note[
The #raw("expression") value must evaluate to a string data type \(#raw("varchar")\). You must explicitly cast non-string datatypes to #raw("varchar") using #raw("CAST(expression AS VARCHAR)") before you use them with #raw("listagg").
]
]

If #raw("separator") is not specified, the empty string will be used as #raw("separator").

In its simplest form the function looks like:

#code-block(none, "SELECT listagg(value, ',') WITHIN GROUP (ORDER BY value) csv_value
FROM (VALUES 'a', 'c', 'b') t(value);")

and results in:

#code-block(none, "csv_value
-----------
'a,b,c'")

The following example casts the #raw("v") column to #raw("varchar"):

#code-block(none, "SELECT listagg(CAST(v AS VARCHAR), ',') WITHIN GROUP (ORDER BY v) csv_value
FROM (VALUES 1, 3, 2) t(v);")

and results in

#code-block(none, "csv_value
-----------
'1,2,3'")

The overflow behaviour is by default to throw an error in case that the length of the output of the function exceeds #raw("1048576") bytes:

#code-block(none, "SELECT listagg(value, ',' ON OVERFLOW ERROR) WITHIN GROUP (ORDER BY value) csv_value
FROM (VALUES 'a', 'b', 'c') t(value);")

There exists also the possibility to truncate the output #raw("WITH COUNT") or #raw("WITHOUT COUNT") of omitted non-null values in case that the length of the output of the function exceeds #raw("1048576") bytes:

#code-block(none, "SELECT listagg(value, ',' ON OVERFLOW TRUNCATE '.....' WITH COUNT) WITHIN GROUP (ORDER BY value)
FROM (VALUES 'a', 'b', 'c') t(value);")

If not specified, the truncation filler string is by default #raw("'...'").

This aggregation function can be also used in a scenario involving grouping:

#code-block(none, "SELECT id, listagg(value, ',') WITHIN GROUP (ORDER BY o) csv_value
FROM (VALUES
    (100, 1, 'a'),
    (200, 3, 'c'),
    (200, 2, 'b')
) t(id, o, value)
GROUP BY id
ORDER BY id;")

results in:

#code-block("text", " id  | csv_value
-----+-----------
 100 | a
 200 | b,c")

This aggregation function supports #link(label("ref-aggregate-function-filtering-during-aggregation"))[filtering during aggregation] for scenarios where the aggregation for the data not matching the filter condition still needs to show up in the output:

#code-block(none, "SELECT 
    country,
    listagg(city, ',')
        WITHIN GROUP (ORDER BY population DESC)
        FILTER (WHERE population >= 10_000_000) megacities
FROM (VALUES 
    ('India', 'Bangalore', 13_700_000),
    ('India', 'Chennai', 12_200_000),
    ('India', 'Ranchi', 1_547_000),
    ('Austria', 'Vienna', 1_897_000),
    ('Poland', 'Warsaw', 1_765_000)
) t(country, city, population)
GROUP BY country
ORDER BY country;")

results in:

#code-block("text", " country |    megacities     
---------+-------------------
 Austria | NULL              
 India   | Bangalore,Chennai 
 Poland  | NULL")

The current implementation of #raw("listagg") function does not support window frames.

#code-block(none, "
:::{function} max(x) -> [same as input]
Returns the maximum value of all input values.")

#function-def("fn-max", "max(x, n)", "array<[same as x]>")[
Returns #raw("n") largest values of all input values of #raw("x").
]

#function-def("fn-max-by", "max_by(x, y)", "[same as x]")[
Returns the value of #raw("x") associated with the maximum value of #raw("y") over all input values.
]

#function-def("fn-max-by-2", "max_by(x, y, n)", "array<[same as x]>", ref: false)[
Returns #raw("n") values of #raw("x") associated with the #raw("n") largest of all input values of #raw("y") in descending order of #raw("y").
]

#function-def("fn-min", "min(x)", "[same as input]")[
Returns the minimum value of all input values.
]

#function-def("fn-min-2", "min(x, n)", "array<[same as x]>", ref: false)[
Returns #raw("n") smallest values of all input values of #raw("x").
]

#function-def("fn-min-by", "min_by(x, y)", "[same as x]")[
Returns the value of #raw("x") associated with the minimum value of #raw("y") over all input values.
]

#function-def("fn-min-by-2", "min_by(x, y, n)", "array<[same as x]>", ref: false)[
Returns #raw("n") values of #raw("x") associated with the #raw("n") smallest of all input values of #raw("y") in ascending order of #raw("y").
]

#function-def("fn-sum", "sum(x)", "[same as input]")[
Returns the sum of all input values.
]

== Bitwise aggregate functions

#function-def("fn-bitwise-and-agg", "bitwise_and_agg(x)", "bigint")[
Returns the bitwise AND of all input non-NULL values in 2's complement representation. If all records inside the group are NULL, or if the group is empty, the function returns NULL.
]

#function-def("fn-bitwise-or-agg", "bitwise_or_agg(x)", "bigint")[
Returns the bitwise OR of all input non-NULL values in 2's complement representation. If all records inside the group are NULL, or if the group is empty, the function returns NULL.
]

#function-def("fn-bitwise-xor-agg", "bitwise_xor_agg(x)", "bigint")[
Returns the bitwise XOR of all input non-NULL values in 2's complement representation. If all records inside the group are NULL, or if the group is empty, the function returns NULL.
]

== Map aggregate functions

#function-def("fn-histogram", "histogram(x)", "map<K,bigint>")[
Returns a map containing the count of the number of times each input value occurs.
]

#function-def("fn-map-agg", "map_agg(key, value)", "map<K,V>")[
Returns a map created from the input #raw("key") \/ #raw("value") pairs.
]

#function-def("fn-map-union", "map_union(x(K,V))", "map<K,V>")[
Returns the union of all the input maps. If a key is found in multiple input maps, that key's value in the resulting map comes from an arbitrary input map.

For example, take the following histogram function that creates multiple maps from the Iris dataset:

#code-block(none, "SELECT histogram(floor(petal_length_cm)) petal_data
FROM memory.default.iris
GROUP BY species;

        petal_data
-- {4.0=6, 5.0=33, 6.0=11}
-- {4.0=37, 5.0=2, 3.0=11}
-- {1.0=50}")

You can combine these maps using #raw("map_union"):

#code-block(none, "SELECT map_union(petal_data) petal_data_union
FROM (
       SELECT histogram(floor(petal_length_cm)) petal_data
       FROM memory.default.iris
       GROUP BY species
       );

             petal_data_union
--{4.0=6, 5.0=2, 6.0=11, 1.0=50, 3.0=11}")
]

#function-def("fn-multimap-agg", "multimap_agg(key, value)", "map<K,array(V)>")[
Returns a multimap created from the input #raw("key") \/ #raw("value") pairs. Each key can be associated with multiple values.
]

== Approximate aggregate functions

#function-def("fn-approx-distinct", "approx_distinct(x)", "bigint")[
Returns the approximate number of distinct input values. This function provides an approximation of #raw("count(DISTINCT x)"). Zero is returned if all input values are null.

This function should produce a standard error of 2.3%, which is the standard deviation of the \(approximately normal\) error distribution over all possible sets. It does not guarantee an upper bound on the error for any specific input set.
]

#function-def("fn-approx-distinct-2", "approx_distinct(x, e)", "bigint", ref: false)[
Returns the approximate number of distinct input values. This function provides an approximation of #raw("count(DISTINCT x)"). Zero is returned if all input values are null.

This function should produce a standard error of no more than #raw("e"), which is the standard deviation of the \(approximately normal\) error distribution over all possible sets. It does not guarantee an upper bound on the error for any specific input set. The current implementation of this function requires that #raw("e") be in the range of #raw("[0.0040625, 0.26000]").
]

#function-def("fn-approx-most-frequent", "approx_most_frequent(buckets, value, capacity)", "map<[same as value], bigint>")[
Computes the top frequent values up to #raw("buckets") elements approximately. Approximate estimation of the function enables us to pick up the frequent values with less memory. Larger #raw("capacity") improves the accuracy of underlying algorithm with sacrificing the memory capacity. The returned value is a map containing the top elements with corresponding estimated frequency.

The error of the function depends on the permutation of the values and its cardinality. We can set the capacity same as the cardinality of the underlying data to achieve the least error.

#raw("buckets") and #raw("capacity") must be #raw("bigint"). #raw("value") can be numeric or string type.

The function uses the stream summary data structure proposed in the paper #link("https://www.cse.ust.hk/~raywong/comp5331/References/EfficientComputationOfFrequentAndTop-kElementsInDataStreams.pdf")[Efficient Computation of Frequent and Top-k Elements in Data Streams] by A. Metwalley, D. Agrawl and A. Abbadi.
]

#function-def("fn-approx-percentile", "approx_percentile(x, percentage)", "[same as x]")[
Returns the approximate percentile for all input values of #raw("x") at the given #raw("percentage"). The value of #raw("percentage") must be between zero and one and must be constant for all input rows.
]

#function-def("fn-approx-percentile-2", "approx_percentile(x, percentages)", "array<[same as x]>", ref: false)[
Returns the approximate percentile for all input values of #raw("x") at each of the specified percentages. Each element of the #raw("percentages") array must be between zero and one, and the array must be constant for all input rows.
]

#function-def("fn-approx-percentile-3", "approx_percentile(x, w, percentage)", "[same as x]", ref: false)[
Returns the approximate weighed percentile for all input values of #raw("x") using the per-item weight #raw("w") at the percentage #raw("percentage"). Weights must be greater or equal to 1. Integer-value weights can be thought of as a replication count for the value #raw("x") in the percentile set. The value of #raw("percentage") must be between zero and one and must be constant for all input rows.
]

#function-def("fn-approx-percentile-4", "approx_percentile(x, w, percentages)", "array<[same as x]>", ref: false)[
Returns the approximate weighed percentile for all input values of #raw("x") using the per-item weight #raw("w") at each of the given percentages specified in the array. Weights must be greater or equal to 1. Integer-value weights can be thought of as a replication count for the value #raw("x") in the percentile set. Each element of the #raw("percentages") array must be between zero and one, and the array must be constant for all input rows.
]

#function-def("fn-approx-set", "approx_set(x)", "HyperLogLog")[
See hyperloglog.
]

#function-def("fn-merge", "merge(x)", "HyperLogLog")[
See hyperloglog.
]

#function-def("fn-merge-2", "merge(qdigest(T))", "qdigest(T)", ref: false)[
See qdigest.
]

#function-def("fn-merge-3", "merge(tdigest)", "tdigest", ref: false)[
See tdigest.
]

#function-def("fn-numeric-histogram", "numeric_histogram(buckets, value)", "map<double, double>")[
Computes an approximate histogram with up to #raw("buckets") number of buckets for all #raw("value")s. This function is equivalent to the variant of #link(label("fn-numeric-histogram"), raw("numeric_histogram")) that takes a #raw("weight"), with a per-item weight of #raw("1").
]

#function-def("fn-numeric-histogram-2", "numeric_histogram(buckets, value, weight)", "map<double, double>", ref: false)[
Computes an approximate histogram with up to #raw("buckets") number of buckets for all #raw("value")s with a per-item weight of #raw("weight"). The algorithm is based loosely on:

#code-block("text", "Yael Ben-Haim and Elad Tom-Tov, \"A streaming parallel decision tree algorithm\",
J. Machine Learning Research 11 (2010), pp. 849--872.")

#raw("buckets") must be a #raw("bigint"). #raw("value") and #raw("weight") must be numeric.
]

#function-def("fn-qdigest-agg", "qdigest_agg(x)", "qdigest([same as x])")[
See qdigest.
]

#function-def("fn-qdigest-agg-2", "qdigest_agg(x, w)", "qdigest([same as x])", ref: false)[
See qdigest.
]

#function-def("fn-qdigest-agg-3", "qdigest_agg(x, w, accuracy)", "qdigest([same as x])", ref: false)[
See qdigest.
]

#function-def("fn-tdigest-agg", "tdigest_agg(x)", "tdigest")[
See tdigest.
]

#function-def("fn-tdigest-agg-2", "tdigest_agg(x, w)", "tdigest", ref: false)[
See tdigest.
]

== Statistical aggregate functions

#function-def("fn-corr", "corr(y, x)", "double")[
Returns correlation coefficient of input values.
]

#function-def("fn-covar-pop", "covar_pop(y, x)", "double")[
Returns the population covariance of input values.
]

#function-def("fn-covar-samp", "covar_samp(y, x)", "double")[
Returns the sample covariance of input values.
]

#function-def("fn-kurtosis", "kurtosis(x)", "double")[
Returns the excess kurtosis of all input values. Unbiased estimate using the following expression:

#code-block("text", "kurtosis(x) = n(n+1)/((n-1)(n-2)(n-3))sum[(x_i-mean)^4]/stddev(x)^4-3(n-1)^2/((n-2)(n-3))")
]

#function-def("fn-regr-intercept", "regr_intercept(y, x)", "double")[
Returns linear regression intercept of input values. #raw("y") is the dependent value. #raw("x") is the independent value.
]

#function-def("fn-regr-slope", "regr_slope(y, x)", "double")[
Returns linear regression slope of input values. #raw("y") is the dependent value. #raw("x") is the independent value.
]

#function-def("fn-skewness", "skewness(x)", "double")[
Returns the Fisher’s moment coefficient of #link("https://wikipedia.org/wiki/Skewness")[skewness] of all input values.
]

#function-def("fn-stddev", "stddev(x)", "double")[
This is an alias for #link(label("fn-stddev-samp"), raw("stddev_samp")).
]

#function-def("fn-stddev-pop", "stddev_pop(x)", "double")[
Returns the population standard deviation of all input values.
]

#function-def("fn-stddev-samp", "stddev_samp(x)", "double")[
Returns the sample standard deviation of all input values.
]

#function-def("fn-variance", "variance(x)", "double")[
This is an alias for #link(label("fn-var-samp"), raw("var_samp")).
]

#function-def("fn-var-pop", "var_pop(x)", "double")[
Returns the population variance of all input values.
]

#function-def("fn-var-samp", "var_samp(x)", "double")[
Returns the sample variance of all input values.
]

== Lambda aggregate functions

#function-def("fn-reduce-agg", "reduce_agg(inputValue T, initialState S, inputFunction(S, T, S), combineFunction(S, S, S))", "S")[
Reduces all input values into a single value. #raw("inputFunction") will be invoked for each non-null input value. In addition to taking the input value, #raw("inputFunction") takes the current state, initially #raw("initialState"), and returns the new state. #raw("combineFunction") will be invoked to combine two states into a new state. The final state is returned:

#code-block(none, "SELECT id, reduce_agg(value, 0, (a, b) -> a + b, (a, b) -> a + b)
FROM (
    VALUES
        (1, 3),
        (1, 4),
        (1, 5),
        (2, 6),
        (2, 7)
) AS t(id, value)
GROUP BY id;
-- (1, 12)
-- (2, 13)

SELECT id, reduce_agg(value, 1, (a, b) -> a * b, (a, b) -> a * b)
FROM (
    VALUES
        (1, 3),
        (1, 4),
        (1, 5),
        (2, 6),
        (2, 7)
) AS t(id, value)
GROUP BY id;
-- (1, 60)
-- (2, 42)")

The state type must be a boolean, integer, floating-point, char, varchar or date\/time\/interval.
]
