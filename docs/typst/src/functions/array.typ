#import "/lib/trino-docs.typ": *

#anchor("doc-functions-array")
= Array functions and operators

Array functions and operators use the #link(label("ref-array-type"))[ARRAY type]. Create an array with the data type constructor.

Create an array of integer numbers:

#code-block("sql", "SELECT ARRAY[1, 2, 4];
-- [1, 2, 4]")

Create an array of character values:

#code-block("sql", "SELECT ARRAY['foo', 'bar', 'bazz'];
-- [foo, bar, bazz]")

Array elements must use the same type or it must be possible to coerce values to a common type. The following example uses integer and decimal values and the resulting array contains decimals:

#code-block("sql", "SELECT ARRAY[1, 1.2, 4];
-- [1.0, 1.2, 4.0]")

Null values are allowed:

#code-block("sql", "SELECT ARRAY[1, 2, NULL, -4, NULL];
-- [1, 2, NULL, -4, NULL]")

#anchor("ref-subscript-operator")

== Subscript operator: \[\]

The #raw("[]") operator is used to access an element of an array and is indexed starting from one:

#code-block("sql", "SELECT my_array[1] AS first_element")

The following example constructs an array and then accesses the second element:

#code-block("sql", "SELECT ARRAY[1, 1.2, 4][2];
-- 1.2")

#anchor("ref-concatenation-operator")

== Concatenation operator: ||

The #raw("||") operator is used to concatenate an array with an array or an element of the same type:

#code-block(none, "SELECT ARRAY[1] || ARRAY[2];
-- [1, 2]

SELECT ARRAY[1] || 2;
-- [1, 2]

SELECT 2 || ARRAY[1];
-- [2, 1]")

== Array functions

#function-def("fn-all-match", "all_match(array(T), function(T,boolean))", "boolean")[
Returns whether all elements of an array match the given predicate. Returns #raw("true") if all the elements match the predicate \(a special case is when the array is empty\); #raw("false") if one or more elements don't match; #raw("NULL") if the predicate function returns #raw("NULL") for one or more elements and #raw("true") for all other elements.
]

#function-def("fn-any-match", "any_match(array(T), function(T,boolean))", "boolean")[
Returns whether any elements of an array match the given predicate. Returns #raw("true") if one or more elements match the predicate; #raw("false") if none of the elements matches \(a special case is when the array is empty\); #raw("NULL") if the predicate function returns #raw("NULL") for one or more elements and #raw("false") for all other elements.
]

#function-def("fn-array-distinct", "array_distinct(x)", "array")[
Remove duplicate values from the array #raw("x").
]

#function-def("fn-array-intersect", "array_intersect(x, y)", "array")[
Returns an array of the elements in the intersection of #raw("x") and #raw("y"), without duplicates.
]

#function-def("fn-array-union", "array_union(x, y)", "array")[
Returns an array of the elements in the union of #raw("x") and #raw("y"), without duplicates.
]

#function-def("fn-array-except", "array_except(x, y)", "array")[
Returns an array of elements in #raw("x") but not in #raw("y"), without duplicates.
]

#function-def("fn-array-first", "array_first(array(E))", "E")[
Returns the first element of an #raw("array"). If the array is empty, the function returns #raw("NULL"), whereas the subscript operator would fail in such a case.
]

#function-def("fn-array-first-2", "array_first(array(E), function(E, boolean))", "E", ref: false)[
Returns the first element of the #raw("array") that matches the predicate. If the array is empty or there is no match, the function returns #raw("NULL").
]

#function-def("fn-array-histogram", "array_histogram(x)", "map<K, bigint>")[
Returns a map where the keys are the unique elements in the input array #raw("x") and the values are the number of times that each element appears in #raw("x"). Null values are ignored.

#code-block(none, "SELECT array_histogram(ARRAY[42, 7, 42, NULL]);
-- {42=2, 7=1}")

Returns an empty map if the input array has no non-null elements.

#code-block(none, "SELECT array_histogram(ARRAY[NULL, NULL]);
-- {}")
]

#function-def("fn-array-join", "array_join(x, delimiter)", "varchar")[
Concatenates the elements of the given array using the delimiter. Null elements are omitted in the result.
]

#function-def("fn-array-join-2", "array_join(x, delimiter, null_replacement)", "varchar", ref: false)[
Concatenates the elements of the given array using the delimiter and an optional string to replace nulls.
]

#function-def("fn-array-last", "array_last(array(E))", "E")[
Returns the last element of an #raw("array"). If the array is empty, the function returns #raw("NULL"), whereas the subscript operator would fail in such a case.
]

#function-def("fn-array-max", "array_max(x)", "x")[
Returns the maximum value of input array.
]

#function-def("fn-array-min", "array_min(x)", "x")[
Returns the minimum value of input array.
]

#function-def("fn-array-position", "array_position(x, element)", "bigint")[
Returns the position of the first occurrence of the #raw("element") in array #raw("x") \(or 0 if not found\).
]

#function-def("fn-array-remove", "array_remove(x, element)", "array")[
Remove all elements that equal #raw("element") from array #raw("x").
]

#function-def("fn-array-sort", "array_sort(x)", "array")[
Sorts and returns the array #raw("x"). The elements of #raw("x") must be orderable. Null elements will be placed at the end of the returned array.
]

#function-def("fn-array-sort-2", "array_sort(array(T), function(T,T,int))", "array(T)", ref: false)[
Sorts and returns the #raw("array") based on the given comparator #raw("function"). The comparator will take two nullable arguments representing two nullable elements of the #raw("array"). It returns -1, 0, or 1 as the first nullable element is less than, equal to, or greater than the second nullable element. If the comparator function returns other values \(including #raw("NULL")\), the query will fail and raise an error.

#code-block(none, "SELECT array_sort(ARRAY[3, 2, 5, 1, 2],
                  (x, y) -> IF(x < y, 1, IF(x = y, 0, -1)));
-- [5, 3, 2, 2, 1]

SELECT array_sort(ARRAY['bc', 'ab', 'dc'],
                  (x, y) -> IF(x < y, 1, IF(x = y, 0, -1)));
-- ['dc', 'bc', 'ab']


SELECT array_sort(ARRAY[3, 2, null, 5, null, 1, 2],
                  -- sort null first with descending order
                  (x, y) -> CASE WHEN x IS NULL THEN -1
                                 WHEN y IS NULL THEN 1
                                 WHEN x < y THEN 1
                                 WHEN x = y THEN 0
                                 ELSE -1 END);
-- [null, null, 5, 3, 2, 2, 1]

SELECT array_sort(ARRAY[3, 2, null, 5, null, 1, 2],
                  -- sort null last with descending order
                  (x, y) -> CASE WHEN x IS NULL THEN 1
                                 WHEN y IS NULL THEN -1
                                 WHEN x < y THEN 1
                                 WHEN x = y THEN 0
                                 ELSE -1 END);
-- [5, 3, 2, 2, 1, null, null]

SELECT array_sort(ARRAY['a', 'abcd', 'abc'],
                  -- sort by string length
                  (x, y) -> IF(length(x) < length(y), -1,
                               IF(length(x) = length(y), 0, 1)));
-- ['a', 'abc', 'abcd']

SELECT array_sort(ARRAY[ARRAY[2, 3, 1], ARRAY[4, 2, 1, 4], ARRAY[1, 2]],
                  -- sort by array length
                  (x, y) -> IF(cardinality(x) < cardinality(y), -1,
                               IF(cardinality(x) = cardinality(y), 0, 1)));
-- [[1, 2], [2, 3, 1], [4, 2, 1, 4]]")
]

#function-def("fn-arrays-overlap", "arrays_overlap(x, y)", "boolean")[
Tests if arrays #raw("x") and #raw("y") have any non-null elements in common. Returns null if there are no non-null elements in common but either array contains null.
]

#function-def("fn-cardinality", "cardinality(x)", "bigint")[
Returns the cardinality \(size\) of the array #raw("x").
]

#function-def("fn-concat", "concat(array1, array2, ..., arrayN)", "array")[
Concatenates the arrays #raw("array1"), #raw("array2"), #raw("..."), #raw("arrayN"). This function provides the same functionality as the SQL-standard concatenation operator \(#raw("||")\).
]

#function-def("fn-combinations", "combinations(array(T), n)", "array(array(T))")[
Returns n-element sub-groups of input array. If the input array has no duplicates, #raw("combinations") returns n-element subsets.

#code-block(none, "SELECT combinations(ARRAY['foo', 'bar', 'baz'], 2);
-- [['foo', 'bar'], ['foo', 'baz'], ['bar', 'baz']]

SELECT combinations(ARRAY[1, 2, 3], 2);
-- [[1, 2], [1, 3], [2, 3]]

SELECT combinations(ARRAY[1, 2, 2], 2);
-- [[1, 2], [1, 2], [2, 2]]")

Order of sub-groups is deterministic but unspecified. Order of elements within a sub-group deterministic but unspecified. #raw("n") must be not be greater than 5, and the total size of sub-groups generated must be smaller than 100,000.
]

#function-def("fn-contains", "contains(x, element)", "boolean")[
Returns true if the array #raw("x") contains the #raw("element").
]

#function-def("fn-contains-sequence", "contains_sequence(x, seq)", "boolean")[
Return true if array #raw("x") contains all of array #raw("seq") as a subsequence \(all values in the same consecutive order\).
]

#function-def("fn-element-at", "element_at(array(E), index)", "E")[
Returns element of #raw("array") at given #raw("index"). If #raw("index") \> 0, this function provides the same functionality as the SQL-standard subscript operator \(#raw("[]")\), except that the function returns #raw("NULL") when accessing an #raw("index") larger than array length, whereas the subscript operator would fail in such a case. If #raw("index") \< 0, #raw("element_at") accesses elements from the last to the first.
]

#function-def("fn-filter", "filter(array(T), function(T,boolean))", "array(T)")[
Constructs an array from those elements of #raw("array") for which #raw("function") returns true:

#code-block(none, "SELECT filter(ARRAY[], x -> true);
-- []

SELECT filter(ARRAY[5, -6, NULL, 7], x -> x > 0);
-- [5, 7]

SELECT filter(ARRAY[5, NULL, 7, NULL], x -> x IS NOT NULL);
-- [5, 7]")
]

#function-def("fn-flatten", "flatten(x)", "array")[
Flattens an #raw("array(array(T))") to an #raw("array(T)") by concatenating the contained arrays.
]

#function-def("fn-ngrams", "ngrams(array(T), n)", "array(array(T))")[
Returns #raw("n")-grams \(sub-sequences of adjacent #raw("n") elements\) for the #raw("array"). The order of the #raw("n")-grams in the result is unspecified.

#code-block(none, "SELECT ngrams(ARRAY['foo', 'bar', 'baz', 'foo'], 2);
-- [['foo', 'bar'], ['bar', 'baz'], ['baz', 'foo']]

SELECT ngrams(ARRAY['foo', 'bar', 'baz', 'foo'], 3);
-- [['foo', 'bar', 'baz'], ['bar', 'baz', 'foo']]

SELECT ngrams(ARRAY['foo', 'bar', 'baz', 'foo'], 4);
-- [['foo', 'bar', 'baz', 'foo']]

SELECT ngrams(ARRAY['foo', 'bar', 'baz', 'foo'], 5);
-- [['foo', 'bar', 'baz', 'foo']]

SELECT ngrams(ARRAY[1, 2, 3, 4], 2);
-- [[1, 2], [2, 3], [3, 4]]")
]

#function-def("fn-none-match", "none_match(array(T), function(T,boolean))", "boolean")[
Returns whether no elements of an array match the given predicate. Returns #raw("true") if none of the elements matches the predicate \(a special case is when the array is empty\); #raw("false") if one or more elements match; #raw("NULL") if the predicate function returns #raw("NULL") for one or more elements and #raw("false") for all other elements.
]

#function-def("fn-reduce", "reduce(array(T), initialState S, inputFunction(S,T,S), outputFunction(S,R))", "R")[
Returns a single value reduced from #raw("array"). #raw("inputFunction") will be invoked for each element in #raw("array") in order. In addition to taking the element, #raw("inputFunction") takes the current state, initially #raw("initialState"), and returns the new state. #raw("outputFunction") will be invoked to turn the final state into the result value. It may be the identity function \(#raw("i -> i")\).

#code-block(none, "SELECT reduce(ARRAY[], 0,
              (s, x) -> s + x,
              s -> s);
-- 0

SELECT reduce(ARRAY[5, 20, 50], 0,
              (s, x) -> s + x,
              s -> s);
-- 75

SELECT reduce(ARRAY[5, 20, NULL, 50], 0,
              (s, x) -> s + x,
              s -> s);
-- NULL

SELECT reduce(ARRAY[5, 20, NULL, 50], 0,
              (s, x) -> s + coalesce(x, 0),
              s -> s);
-- 75

SELECT reduce(ARRAY[5, 20, NULL, 50], 0,
              (s, x) -> IF(x IS NULL, s, s + x),
              s -> s);
-- 75

SELECT reduce(ARRAY[2147483647, 1], BIGINT '0',
              (s, x) -> s + x,
              s -> s);
-- 2147483648

-- calculates arithmetic average
SELECT reduce(ARRAY[5, 6, 10, 20],
              CAST(ROW(0.0, 0) AS ROW(sum DOUBLE, count INTEGER)),
              (s, x) -> CAST(ROW(x + s.sum, s.count + 1) AS
                             ROW(sum DOUBLE, count INTEGER)),
              s -> IF(s.count = 0, NULL, s.sum / s.count));
-- 10.25")
]

#function-def("fn-repeat", "repeat(element, count)", "array")[
Repeat #raw("element") for #raw("count") times.
]

#function-def("fn-reverse", "reverse(x)", "array")[
Returns an array which has the reversed order of array #raw("x").
]

#function-def("fn-sequence", "sequence(start, stop)", "array(bigint)")[
Generate a sequence of integers from #raw("start") to #raw("stop"), incrementing by #raw("1") if #raw("start") is less than or equal to #raw("stop"), otherwise #raw("-1").
]

#function-def("fn-sequence-2", "sequence(start, stop, step)", "array(bigint)", ref: false)[
Generate a sequence of integers from #raw("start") to #raw("stop"), incrementing by #raw("step").
]

#function-def("fn-sequence-3", "sequence(start, stop)", "array(date)", ref: false)[
Generate a sequence of dates from #raw("start") date to #raw("stop") date, incrementing by #raw("1") day if #raw("start") date is less than or equal to #raw("stop") date, otherwise #raw("-1") day.
]

#function-def("fn-sequence-4", "sequence(start, stop, step)", "array(date)", ref: false)[
Generate a sequence of dates from #raw("start") to #raw("stop"), incrementing by #raw("step"). The type of #raw("step") can be either #raw("INTERVAL DAY TO SECOND") or #raw("INTERVAL YEAR TO MONTH").
]

#function-def("fn-sequence-5", "sequence(start, stop, step)", "array(timestamp)", ref: false)[
Generate a sequence of timestamps from #raw("start") to #raw("stop"), incrementing by #raw("step"). The type of #raw("step") can be either #raw("INTERVAL DAY TO SECOND") or #raw("INTERVAL YEAR TO MONTH").
]

#function-def("fn-shuffle", "shuffle(x)", "array")[
Generate a random permutation of the given array #raw("x").
]

#function-def("fn-slice", "slice(x, start, length)", "array")[
Subsets array #raw("x") starting from index #raw("start") \(or starting from the end if #raw("start") is negative\) with a length of #raw("length").
]

#function-def("fn-trim-array", "trim_array(x, n)", "array")[
Remove #raw("n") elements from the end of array:

#code-block(none, "SELECT trim_array(ARRAY[1, 2, 3, 4], 1);
-- [1, 2, 3]

SELECT trim_array(ARRAY[1, 2, 3, 4], 2);
-- [1, 2]")
]

#function-def("fn-transform", "transform(array(T), function(T,U))", "array(U)")[
Returns an array that is the result of applying #raw("function") to each element of #raw("array"):

#code-block(none, "SELECT transform(ARRAY[], x -> x + 1);
-- []

SELECT transform(ARRAY[5, 6], x -> x + 1);
-- [6, 7]

SELECT transform(ARRAY[5, NULL, 6], x -> coalesce(x, 0) + 1);
-- [6, 1, 7]

SELECT transform(ARRAY['x', 'abc', 'z'], x -> x || '0');
-- ['x0', 'abc0', 'z0']

SELECT transform(ARRAY[ARRAY[1, NULL, 2], ARRAY[3, NULL]],
                 a -> filter(a, x -> x IS NOT NULL));
-- [[1, 2], [3]]")
]

#function-def("fn-euclidean-distance", "euclidean_distance(array(double), array(double))", "double")[
Calculates the euclidean distance:

#code-block("sql", "SELECT euclidean_distance(ARRAY[1.0, 2.0], ARRAY[3.0, 4.0]);
-- 2.8284271247461903")
]

#function-def("fn-dot-product", "dot_product(array(double), array(double))", "double")[
Calculates the dot product:

#code-block("sql", "SELECT dot_product(ARRAY[1.0, 2.0], ARRAY[3.0, 4.0]);
-- 11.0")
]

#function-def("fn-zip", "zip(array1, array2[, ...])", "array(row)")[
Merges the given arrays, element-wise, into a single array of rows. The M-th element of the N-th argument will be the N-th field of the M-th output element. If the arguments have an uneven length, missing values are filled with #raw("NULL").

#code-block(none, "SELECT zip(ARRAY[1, 2], ARRAY['1b', null, '3b']);
-- [ROW(1, '1b'), ROW(2, null), ROW(null, '3b')]")
]

#function-def("fn-zip-with", "zip_with(array(T), array(U), function(T,U,R))", "array(R)")[
Merges the two given arrays, element-wise, into a single array using #raw("function"). If one array is shorter, nulls are appended at the end to match the length of the longer array, before applying #raw("function").

#code-block(none, "SELECT zip_with(ARRAY[1, 3, 5], ARRAY['a', 'b', 'c'],
                (x, y) -> (y, x));
-- [ROW('a', 1), ROW('b', 3), ROW('c', 5)]

SELECT zip_with(ARRAY[1, 2], ARRAY[3, 4],
                (x, y) -> x + y);
-- [4, 6]

SELECT zip_with(ARRAY['a', 'b', 'c'], ARRAY['d', 'e', 'f'],
                (x, y) -> concat(x, y));
-- ['ad', 'be', 'cf']

SELECT zip_with(ARRAY['a'], ARRAY['d', null, 'f'],
                (x, y) -> coalesce(x, y));
-- ['a', null, 'f']")
]
