#import "/lib/trino-docs.typ": *

#anchor("doc-functions-map")
= Map functions and operators

Map functions and operators use the #link(label("ref-map-type"))[MAP type]. Create a map with the data type constructor using an #link(label("ref-array-type"))[array] of keys and another array of values in the same order. Keys must be character-based and can not be null.

Create an array with integer values

#code-block("sql", "SELECT MAP(ARRAY['key1', 'key2', 'key3' ], ARRAY[2373, 3463, 45837]);
-- {key1=2373, key2=3463, key3=45837}")

Create an array of character values:

#code-block("sql", "SELECT MAP(ARRAY['key1', 'key2', 'key3' ], ARRAY['v1', 'v2', 'v3']);
-- {key1=v1, key2=v2, key3=v3}")

Values must use the same type or it must be possible to coerce values to a common type. The following example uses integer and decimal values and the resulting array contains decimals:

#code-block("sql", "SELECT MAP(ARRAY['key1', 'key2', 'key3' ], ARRAY[23, 34.63, 45.837]);
-- {key1=23.000, key2=34.630, key3=45.837}")

Null values are allowed:

#code-block("sql", "SELECT MAP(ARRAY['key1', 'key2', 'key3' ], ARRAY['v1', NULL, 'v3']);
-- {key1=v1, key2=NULL, key3=v3}")

== Subscript operator: \[\]

The #raw("[]") operator is used to retrieve the value corresponding to a given key from a map. This operator throws an error if the key is not contained in the map. See also #raw("element_at") function that returns #raw("NULL") in such case.

#code-block(none, "SELECT name_to_age_map['Bob'] AS bob_age;")

The following example constructs a map and then accesses the element with the key #raw("key2"):

#code-block("sql", "SELECT MAP(ARRAY['key1', 'key2', 'key3' ], ARRAY['v1', 'v2', 'v3'])['key2'];
-- v2")

== Map functions

#function-def("fn-cardinality-3", "cardinality(x)", "bigint", ref: false)[
Returns the cardinality \(size\) of the map #raw("x").
]

#function-def("fn-element-at-2", "element_at(map(K,V), key)", "V", ref: false)[
Returns value for given #raw("key"), or #raw("NULL") if the key is not contained in the map.
]

#function-def("fn-map", "map()", "map<unknown, unknown>")[
Returns an empty map.

#code-block(none, "SELECT map();
-- {}")
]

#function-def("fn-map-2", "map(array(K), array(V))", "map(K,V)", ref: false)[
Returns a map created using the given key\/value arrays.

#code-block(none, "SELECT map(ARRAY[1,3], ARRAY[2,4]);
-- {1 -> 2, 3 -> 4}")

See also #link(label("fn-map-agg"), raw("map_agg")) and #link(label("fn-multimap-agg"), raw("multimap_agg")) for creating a map as an aggregation.
]

#function-def("fn-map-from-entries", "map_from_entries(array(row(K,V)))", "map(K,V)")[
Returns a map created from the given array of entries.

#code-block(none, "SELECT map_from_entries(ARRAY[(1, 'x'), (2, 'y')]);
-- {1 -> 'x', 2 -> 'y'}")
]

#function-def("fn-multimap-from-entries", "multimap_from_entries(array(row(K,V)))", "map(K,array(V))")[
Returns a multimap created from the given array of entries. Each key can be associated with multiple values.

#code-block(none, "SELECT multimap_from_entries(ARRAY[(1, 'x'), (2, 'y'), (1, 'z')]);
-- {1 -> ['x', 'z'], 2 -> ['y']}")
]

#function-def("fn-map-entries", "map_entries(map(K,V))", "array(row(K,V))")[
Returns an array of all entries in the given map.

#code-block(none, "SELECT map_entries(MAP(ARRAY[1, 2], ARRAY['x', 'y']));
-- [ROW(1, 'x'), ROW(2, 'y')]")
]

#function-def("fn-map-concat", "map_concat(map1(K,V), map2(K,V), ..., mapN(K,V))", "map(K,V)")[
Returns the union of all the given maps. If a key is found in multiple given maps, that key's value in the resulting map comes from the last one of those maps.
]

#function-def("fn-map-filter", "map_filter(map(K,V), function(K,V,boolean))", "map(K,V)")[
Constructs a map from those entries of #raw("map") for which #raw("function") returns true:

#code-block(none, "SELECT map_filter(MAP(ARRAY[], ARRAY[]), (k, v) -> true);
-- {}

SELECT map_filter(MAP(ARRAY[10, 20, 30], ARRAY['a', NULL, 'c']),
                  (k, v) -> v IS NOT NULL);
-- {10 -> a, 30 -> c}

SELECT map_filter(MAP(ARRAY['k1', 'k2', 'k3'], ARRAY[20, 3, 15]),
                  (k, v) -> v > 10);
-- {k1 -> 20, k3 -> 15}")
]

#function-def("fn-map-keys", "map_keys(x(K,V))", "array(K)")[
Returns all the keys in the map #raw("x").
]

#function-def("fn-map-values", "map_values(x(K,V))", "array(V)")[
Returns all the values in the map #raw("x").
]

#function-def("fn-map-zip-with", "map_zip_with(map(K,V1), map(K,V2), function(K,V1,V2,V3))", "map(K,V3)")[
Merges the two given maps into a single map by applying #raw("function") to the pair of values with the same key. For keys only presented in one map, NULL will be passed as the value for the missing key.

#code-block(none, "SELECT map_zip_with(MAP(ARRAY[1, 2, 3], ARRAY['a', 'b', 'c']),
                    MAP(ARRAY[1, 2, 3], ARRAY['d', 'e', 'f']),
                    (k, v1, v2) -> concat(v1, v2));
-- {1 -> ad, 2 -> be, 3 -> cf}

SELECT map_zip_with(MAP(ARRAY['k1', 'k2'], ARRAY[1, 2]),
                    MAP(ARRAY['k2', 'k3'], ARRAY[4, 9]),
                    (k, v1, v2) -> (v1, v2));
-- {k1 -> ROW(1, null), k2 -> ROW(2, 4), k3 -> ROW(null, 9)}

SELECT map_zip_with(MAP(ARRAY['a', 'b', 'c'], ARRAY[1, 8, 27]),
                    MAP(ARRAY['a', 'b', 'c'], ARRAY[1, 2, 3]),
                    (k, v1, v2) -> k || CAST(v1 / v2 AS VARCHAR));
-- {a -> a1, b -> b4, c -> c9}")
]

#function-def("fn-transform-keys", "transform_keys(map(K1,V), function(K1,V,K2))", "map(K2,V)")[
Returns a map that applies #raw("function") to each entry of #raw("map") and transforms the keys:

#code-block(none, "SELECT transform_keys(MAP(ARRAY[], ARRAY[]), (k, v) -> k + 1);
-- {}

SELECT transform_keys(MAP(ARRAY [1, 2, 3], ARRAY ['a', 'b', 'c']),
                      (k, v) -> k + 1);
-- {2 -> a, 3 -> b, 4 -> c}

SELECT transform_keys(MAP(ARRAY ['a', 'b', 'c'], ARRAY [1, 2, 3]),
                      (k, v) -> v * v);
-- {1 -> 1, 4 -> 2, 9 -> 3}

SELECT transform_keys(MAP(ARRAY ['a', 'b'], ARRAY [1, 2]),
                      (k, v) -> k || CAST(v as VARCHAR));
-- {a1 -> 1, b2 -> 2}

SELECT transform_keys(MAP(ARRAY [1, 2], ARRAY [1.0, 1.4]),
                      (k, v) -> MAP(ARRAY[1, 2], ARRAY['one', 'two'])[k]);
-- {one -> 1.0, two -> 1.4}")
]

#function-def("fn-transform-values", "transform_values(map(K,V1), function(K,V1,V2))", "map(K,V2)")[
Returns a map that applies #raw("function") to each entry of #raw("map") and transforms the values:

#code-block(none, "SELECT transform_values(MAP(ARRAY[], ARRAY[]), (k, v) -> v + 1);
-- {}

SELECT transform_values(MAP(ARRAY [1, 2, 3], ARRAY [10, 20, 30]),
                        (k, v) -> v + k);
-- {1 -> 11, 2 -> 22, 3 -> 33}

SELECT transform_values(MAP(ARRAY [1, 2, 3], ARRAY ['a', 'b', 'c']),
                        (k, v) -> k * k);
-- {1 -> 1, 2 -> 4, 3 -> 9}

SELECT transform_values(MAP(ARRAY ['a', 'b'], ARRAY [1, 2]),
                        (k, v) -> k || CAST(v as VARCHAR));
-- {a -> a1, b -> b2}

SELECT transform_values(MAP(ARRAY [1, 2], ARRAY [1.0, 1.4]),
                        (k, v) -> MAP(ARRAY[1, 2], ARRAY['one', 'two'])[k]
                          || '_' || CAST(v AS VARCHAR));
-- {1 -> one_1.0, 2 -> two_1.4}")
]
