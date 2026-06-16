#import "/lib/trino-docs.typ": *

#anchor("doc-functions-list")
= List of functions and operators

== \#

- #link(label("ref-subscript-operator"))[\[\] substring operator]
- #link(label("ref-concatenation-operator"))[|| concatenation operator]
- #link(label("ref-comparison-operators"))[\< comparison operator]
- #link(label("ref-comparison-operators"))[\> comparison operator]
- #link(label("ref-comparison-operators"))[\<= comparison operator]
- #link(label("ref-comparison-operators"))[\>= comparison operator]
- #link(label("ref-comparison-operators"))[= comparison operator]
- #link(label("ref-comparison-operators"))[\<\> comparison operator]
- #link(label("ref-comparison-operators"))[!= comparison operator]
- #link(label("ref-lambda-expressions"))[-\> lambda expression]
- #link(label("ref-mathematical-operators"))[+ mathematical operator]
- #link(label("ref-mathematical-operators"))[- mathematical operator]
- #link(label("ref-mathematical-operators"))[\* mathematical operator]
- #link(label("ref-mathematical-operators"))[\/ mathematical operator]
- #link(label("ref-mathematical-operators"))[% mathematical operator]

== A

- #link(label("fn-abs"), raw("abs"))
- #link(label("fn-acos"), raw("acos"))
- #link(label("ref-quantified-comparison-predicates"))[ALL]
- #link(label("fn-all-match"), raw("all_match"))
- #link(label("ref-logical-operators"))[AND]
- #link(label("ref-quantified-comparison-predicates"))[ANY]
- #link(label("fn-any-match"), raw("any_match"))
- #link(label("fn-any-value"), raw("any_value"))
- #link(label("fn-approx-distinct"), raw("approx_distinct"))
- #link(label("fn-approx-most-frequent"), raw("approx_most_frequent"))
- #link(label("fn-approx-percentile"), raw("approx_percentile"))
- #link(label("fn-approx-set"), raw("approx_set"))
- #link(label("fn-arbitrary"), raw("arbitrary"))
- #link(label("fn-array-agg"), raw("array_agg"))
- #link(label("fn-array-distinct"), raw("array_distinct"))
- #link(label("fn-array-except"), raw("array_except"))
- #link(label("fn-array-first"), raw("array_first"))
- #link(label("fn-array-histogram"), raw("array_histogram"))
- #link(label("fn-array-intersect"), raw("array_intersect"))
- #link(label("fn-array-join"), raw("array_join"))
- #link(label("fn-array-last"), raw("array_last"))
- #link(label("fn-array-max"), raw("array_max"))
- #link(label("fn-array-min"), raw("array_min"))
- #link(label("fn-array-position"), raw("array_position"))
- #link(label("fn-array-remove"), raw("array_remove"))
- #link(label("fn-array-sort"), raw("array_sort"))
- #link(label("fn-array-union"), raw("array_union"))
- #link(label("fn-arrays-overlap"), raw("arrays_overlap"))
- #link(label("fn-asin"), raw("asin"))
- #link(label("ref-at-time-zone-operator"))[AT TIME ZONE]
- #link(label("fn-at-timezone"), raw("at_timezone"))
- #link(label("fn-atan"), raw("atan"))
- #link(label("fn-atan2"), raw("atan2"))
- #link(label("fn-avg"), raw("avg"))

== B

- #link(label("fn-bar"), raw("bar"))
- #link(label("fn-beta-cdf"), raw("beta_cdf"))
- #link(label("ref-range-operator"))[BETWEEN]
- #link(label("fn-bing-tile"), raw("bing_tile"))
- #link(label("fn-bing-tile-at"), raw("bing_tile_at"))
- #link(label("fn-bing-tile-coordinates"), raw("bing_tile_coordinates"))
- #link(label("fn-bing-tile-polygon"), raw("bing_tile_polygon"))
- #link(label("fn-bing-tile-quadkey"), raw("bing_tile_quadkey"))
- #link(label("fn-bing-tile-zoom-level"), raw("bing_tile_zoom_level"))
- #link(label("fn-bing-tiles-around"), raw("bing_tiles_around"))
- #link(label("fn-bit-count"), raw("bit_count"))
- #link(label("fn-bitwise-and"), raw("bitwise_and"))
- #link(label("fn-bitwise-and-agg"), raw("bitwise_and_agg"))
- #link(label("fn-bitwise-left-shift"), raw("bitwise_left_shift"))
- #link(label("fn-bitwise-not"), raw("bitwise_not"))
- #link(label("fn-bitwise-or"), raw("bitwise_or"))
- #link(label("fn-bitwise-or-agg"), raw("bitwise_or_agg"))
- #link(label("fn-bitwise-right-shift"), raw("bitwise_right_shift"))
- #link(label("fn-bitwise-right-shift-arithmetic"), raw("bitwise_right_shift_arithmetic"))
- #link(label("fn-bitwise-xor"), raw("bitwise_xor"))
- #link(label("fn-bool-and"), raw("bool_and"))
- #link(label("fn-bool-or"), raw("bool_or"))

== C

- #link(label("fn-cardinality"), raw("cardinality"))
- #link(label("ref-case-expression"))[CASE]
- #link(label("fn-cast"), raw("cast"))
- #link(label("fn-cbrt"), raw("cbrt"))
- #link(label("fn-ceil"), raw("ceil"))
- #link(label("fn-ceiling"), raw("ceiling"))
- #link(label("fn-char2hexint"), raw("char2hexint"))
- #link(label("fn-checksum"), raw("checksum"))
- #link(label("fn-chr"), raw("chr"))
- #link(label("fn-classify"), raw("classify"))
- #link(label("ref-classifier-function"))[classifier]
- #link(label("ref-coalesce-function"))[coalesce]
- #link(label("fn-codepoint"), raw("codepoint"))
- #link(label("fn-color"), raw("color"))
- #link(label("fn-combinations"), raw("combinations"))
- #link(label("fn-concat"), raw("concat"))
- #link(label("fn-concat-ws"), raw("concat_ws"))
- #link(label("fn-contains"), raw("contains"))
- #link(label("fn-contains-sequence"), raw("contains_sequence"))
- #link(label("fn-convex-hull-agg"), raw("convex_hull_agg"))
- #link(label("fn-corr"), raw("corr"))
- #link(label("fn-cos"), raw("cos"))
- #link(label("fn-cosh"), raw("cosh"))
- #link(label("fn-cosine-distance"), raw("cosine_distance"))
- #link(label("fn-cosine-similarity"), raw("cosine_similarity"))
- #link(label("fn-count"), raw("count"))
- #link(label("fn-count-if"), raw("count_if"))
- #link(label("fn-covar-pop"), raw("covar_pop"))
- #link(label("fn-covar-samp"), raw("covar_samp"))
- #link(label("fn-crc32"), raw("crc32"))
- #link(label("fn-cume-dist"), raw("cume_dist"))
- #link(label("fn-current-date"), raw("current_date"))
- #link(label("fn-current-groups"), raw("current_groups"))
- #link(label("fn-current-time"), raw("current_time"))
- #link(label("fn-current-timestamp"), raw("current_timestamp"))
- #link(label("fn-current-timezone"), raw("current_timezone"))
- #link(label("fn-current-user"), raw("current_user"))

== D

- #link(label("fn-date"), raw("date"))
- #link(label("fn-date-add"), raw("date_add"))
- #link(label("fn-date-diff"), raw("date_diff"))
- #link(label("fn-date-format"), raw("date_format"))
- #raw("date_parse")
- #link(label("fn-date-trunc"), raw("date_trunc"))
- #link(label("fn-day"), raw("day"))
- #link(label("fn-day-of-month"), raw("day_of_month"))
- #link(label("fn-day-of-week"), raw("day_of_week"))
- #link(label("fn-day-of-year"), raw("day_of_year"))
- #link(label("ref-decimal-literal"))[DECIMAL]
- #link(label("fn-degrees"), raw("degrees"))
- #link(label("fn-dense-rank"), raw("dense_rank"))
- #link(label("fn-dow"), raw("dow"))
- #link(label("fn-doy"), raw("doy"))

== E

- #link(label("fn-e"), raw("e"))
- #link(label("fn-element-at"), raw("element_at"))
- #link(label("fn-empty-approx-set"), raw("empty_approx_set"))
- #raw("evaluate_classifier_predictions")
- #link(label("fn-every"), raw("every"))
- #link(label("fn-exclude-columns"), raw("exclude_columns"))
- #link(label("fn-extract"), raw("extract"))
- #link(label("fn-exp"), raw("exp"))

== F

- #link(label("fn-features"), raw("features"))
- #link(label("fn-filter"), raw("filter"))
- #link(label("ref-logical-navigation-functions"))[first]
- #link(label("fn-first-value"), raw("first_value"))
- #link(label("fn-flatten"), raw("flatten"))
- #link(label("fn-floor"), raw("floor"))
- #link(label("fn-format"), raw("format"))
- #link(label("fn-format-datetime"), raw("format_datetime"))
- #link(label("fn-format-number"), raw("format_number"))
- #link(label("fn-from-base"), raw("from_base"))
- #link(label("fn-from-base32"), raw("from_base32"))
- #link(label("fn-from-base64"), raw("from_base64"))
- #link(label("fn-from-base64url"), raw("from_base64url"))
- #link(label("fn-from-big-endian-32"), raw("from_big_endian_32"))
- #link(label("fn-from-big-endian-64"), raw("from_big_endian_64"))
- #link(label("fn-from-encoded-polyline"), raw("from_encoded_polyline"))
- #raw("from_geojson_geometry")
- #link(label("fn-from-hex"), raw("from_hex"))
- #link(label("fn-from-ieee754-32"), raw("from_ieee754_32"))
- #link(label("fn-from-ieee754-64"), raw("from_ieee754_64"))
- #link(label("fn-from-iso8601-date"), raw("from_iso8601_date"))
- #link(label("fn-from-iso8601-timestamp"), raw("from_iso8601_timestamp"))
- #link(label("fn-from-iso8601-timestamp-nanos"), raw("from_iso8601_timestamp_nanos"))
- #link(label("fn-from-unixtime"), raw("from_unixtime"))
- #link(label("fn-from-unixtime-nanos"), raw("from_unixtime_nanos"))
- #link(label("fn-from-utf8"), raw("from_utf8"))

== G

- #link(label("fn-geometric-mean"), raw("geometric_mean"))
- #link(label("fn-geometry-from-hadoop-shape"), raw("geometry_from_hadoop_shape"))
- #link(label("fn-geometry-invalid-reason"), raw("geometry_invalid_reason"))
- #link(label("fn-geometry-nearest-points"), raw("geometry_nearest_points"))
- #link(label("fn-geometry-to-bing-tiles"), raw("geometry_to_bing_tiles"))
- #link(label("fn-geometry-union"), raw("geometry_union"))
- #link(label("fn-geometry-union-agg"), raw("geometry_union_agg"))
- #link(label("fn-great-circle-distance"), raw("great_circle_distance"))
- #link(label("fn-greatest"), raw("greatest"))

== H

- #link(label("fn-hamming-distance"), raw("hamming_distance"))
- #link(label("fn-hash-counts"), raw("hash_counts"))
- #link(label("fn-histogram"), raw("histogram"))
- #link(label("fn-hmac-md5"), raw("hmac_md5"))
- #link(label("fn-hmac-sha1"), raw("hmac_sha1"))
- #link(label("fn-hmac-sha256"), raw("hmac_sha256"))
- #link(label("fn-hmac-sha512"), raw("hmac_sha512"))
- #link(label("fn-hour"), raw("hour"))
- #link(label("fn-human-readable-seconds"), raw("human_readable_seconds"))

== I

- #link(label("ref-if-expression"))[if]
- #link(label("fn-index"), raw("index"))
- #link(label("fn-infinity"), raw("infinity"))
- #link(label("fn-intersection-cardinality"), raw("intersection_cardinality"))
- #link(label("fn-inverse-beta-cdf"), raw("inverse_beta_cdf"))
- #link(label("fn-inverse-normal-cdf"), raw("inverse_normal_cdf"))
- #link(label("fn-is-finite"), raw("is_finite"))
- #link(label("fn-is-infinite"), raw("is_infinite"))
- #link(label("fn-is-json-scalar"), raw("is_json_scalar"))
- #link(label("fn-is-nan"), raw("is_nan"))
- #link(label("ref-is-distinct-operator"))[IS NOT DISTINCT]
- #link(label("ref-is-null-operator"))[IS NOT NULL]
- #link(label("ref-is-distinct-operator"))[IS DISTINCT]
- #link(label("ref-is-null-operator"))[IS NULL]

== J

- #link(label("fn-jaccard-index"), raw("jaccard_index"))
- #link(label("ref-json-array"))[json\_array\(\)]
- #link(label("fn-json-array-contains"), raw("json_array_contains"))
- #link(label("fn-json-array-get"), raw("json_array_get"))
- #link(label("fn-json-array-length"), raw("json_array_length"))
- #link(label("ref-json-exists"))[json\_exists\(\)]
- #link(label("fn-json-extract"), raw("json_extract"))
- #link(label("fn-json-extract-scalar"), raw("json_extract_scalar"))
- #link(label("fn-json-format"), raw("json_format"))
- #link(label("ref-json-object"))[json\_object\(\)]
- #link(label("fn-json-parse"), raw("json_parse"))
- #link(label("ref-json-query"))[json\_query\(\)]
- #link(label("fn-json-size"), raw("json_size"))
- #link(label("ref-json-value"))[json\_value\(\)]

== K

- #link(label("fn-kurtosis"), raw("kurtosis"))

== L

- #link(label("fn-lag"), raw("lag"))
- #link(label("ref-logical-navigation-functions"))[last]
- #link(label("fn-last-day-of-month"), raw("last_day_of_month"))
- #link(label("fn-last-value"), raw("last_value"))
- #link(label("fn-lead"), raw("lead"))
- #link(label("fn-learn-classifier"), raw("learn_classifier"))
- #link(label("fn-learn-libsvm-classifier"), raw("learn_libsvm_classifier"))
- #link(label("fn-learn-libsvm-regressor"), raw("learn_libsvm_regressor"))
- #link(label("fn-learn-regressor"), raw("learn_regressor"))
- #link(label("fn-least"), raw("least"))
- #link(label("fn-length"), raw("length"))
- #link(label("fn-levenshtein-distance"), raw("levenshtein_distance"))
- #link(label("fn-line-interpolate-point"), raw("line_interpolate_point"))
- #link(label("fn-line-interpolate-points"), raw("line_interpolate_points"))
- #link(label("fn-line-locate-point"), raw("line_locate_point"))
- #link(label("fn-listagg"), raw("listagg"))
- #link(label("fn-ln"), raw("ln"))
- #link(label("fn-localtime"), raw("localtime"))
- #link(label("fn-localtimestamp"), raw("localtimestamp"))
- #link(label("fn-log"), raw("log"))
- #link(label("fn-log10"), raw("log10"))
- #link(label("fn-log2"), raw("log2"))
- #link(label("fn-lower"), raw("lower"))
- #link(label("fn-lpad"), raw("lpad"))
- #link(label("fn-ltrim"), raw("ltrim"))
- #link(label("fn-luhn-check"), raw("luhn_check"))

== M

- #link(label("fn-make-set-digest"), raw("make_set_digest"))
- #link(label("fn-map"), raw("map"))
- #link(label("fn-map-agg"), raw("map_agg"))
- #link(label("fn-map-concat"), raw("map_concat"))
- #link(label("fn-map-entries"), raw("map_entries"))
- #link(label("fn-map-filter"), raw("map_filter"))
- #link(label("fn-map-from-entries"), raw("map_from_entries"))
- #link(label("fn-map-keys"), raw("map_keys"))
- #link(label("fn-map-union"), raw("map_union"))
- #link(label("fn-map-values"), raw("map_values"))
- #link(label("fn-map-zip-with"), raw("map_zip_with"))
- #link(label("ref-match-number-function"))[match\_number]
- #link(label("fn-max"), raw("max"))
- #link(label("fn-max-by"), raw("max_by"))
- #link(label("fn-md5"), raw("md5"))
- #link(label("fn-merge"), raw("merge"))
- #link(label("fn-merge-set-digest"), raw("merge_set_digest"))
- #link(label("fn-millisecond"), raw("millisecond"))
- #link(label("fn-min"), raw("min"))
- #link(label("fn-min-by"), raw("min_by"))
- #link(label("fn-minute"), raw("minute"))
- #link(label("fn-mod"), raw("mod"))
- #link(label("fn-month"), raw("month"))
- #link(label("fn-multimap-agg"), raw("multimap_agg"))
- #link(label("fn-multimap-from-entries"), raw("multimap_from_entries"))
- #link(label("fn-murmur3"), raw("murmur3"))

== N

- #link(label("fn-nan"), raw("nan"))
- #link(label("ref-physical-navigation-functions"))[next]
- #link(label("fn-ngrams"), raw("ngrams"))
- #link(label("fn-none-match"), raw("none_match"))
- #link(label("fn-normal-cdf"), raw("normal_cdf"))
- #link(label("fn-normalize"), raw("normalize"))
- #link(label("ref-logical-operators"))[NOT]
- #link(label("ref-range-operator"))[NOT BETWEEN]
- #link(label("fn-now"), raw("now"))
- #link(label("fn-nth-value"), raw("nth_value"))
- #link(label("fn-ntile"), raw("ntile"))
- #link(label("ref-nullif-function"))[nullif]
- #link(label("fn-numeric-histogram"), raw("numeric_histogram"))

== O

- #raw("objectid")
- #link(label("fn-objectid-timestamp"), raw("objectid_timestamp"))
- #link(label("ref-logical-operators"))[OR]

== P

- #link(label("fn-parse-datetime"), raw("parse_datetime"))
- #link(label("fn-parse-duration"), raw("parse_duration"))
- #link(label("fn-parse-data-size"), raw("parse_data_size"))
- #link(label("fn-percent-rank"), raw("percent_rank"))
- #link(label("ref-permute-function"))[permute]
- #link(label("fn-pi"), raw("pi"))
- #link(label("fn-position"), raw("position"))
- #link(label("fn-pow"), raw("pow"))
- #link(label("fn-power"), raw("power"))
- #link(label("ref-physical-navigation-functions"))[prev]

== Q

- #link(label("fn-qdigest-agg"), raw("qdigest_agg"))
- #link(label("fn-quarter"), raw("quarter"))

== R

- #link(label("fn-radians"), raw("radians"))
- #link(label("fn-rand"), raw("rand"))
- #link(label("fn-random"), raw("random"))
- #link(label("fn-random-string"), raw("random_string")), catalog function of the #link(label("doc-connector-faker"))[Faker connector]
- #link(label("fn-rank"), raw("rank"))
- #link(label("fn-reduce"), raw("reduce"))
- #link(label("fn-reduce-agg"), raw("reduce_agg"))
- #link(label("fn-regexp-count"), raw("regexp_count"))
- #link(label("fn-regexp-extract"), raw("regexp_extract"))
- #link(label("fn-regexp-extract-all"), raw("regexp_extract_all"))
- #link(label("fn-regexp-like"), raw("regexp_like"))
- #link(label("fn-regexp-position"), raw("regexp_position"))
- #link(label("fn-regexp-replace"), raw("regexp_replace"))
- #link(label("fn-regexp-split"), raw("regexp_split"))
- #link(label("fn-regress"), raw("regress"))
- #link(label("fn-regr-intercept"), raw("regr_intercept"))
- #link(label("fn-regr-slope"), raw("regr_slope"))
- #link(label("fn-render"), raw("render"))
- #link(label("fn-repeat"), raw("repeat"))
- #link(label("fn-replace"), raw("replace"))
- #link(label("fn-reverse"), raw("reverse"))
- #link(label("fn-rgb"), raw("rgb"))
- #link(label("fn-round"), raw("round"))
- #link(label("fn-row-number"), raw("row_number"))
- #link(label("fn-rpad"), raw("rpad"))
- #link(label("fn-rtrim"), raw("rtrim"))

== S

- #link(label("fn-second"), raw("second"))
- #link(label("fn-sequence"), raw("sequence")) \(scalar function\)
- #link(label("ref-sequence-table-function"))[sequence\(\)] \(table function\)
- #link(label("fn-sha1"), raw("sha1"))
- #link(label("fn-sha256"), raw("sha256"))
- #link(label("fn-sha512"), raw("sha512"))
- #link(label("fn-shuffle"), raw("shuffle"))
- #link(label("fn-sign"), raw("sign"))
- #link(label("fn-simplify-geometry"), raw("simplify_geometry"))
- #link(label("fn-sin"), raw("sin"))
- #link(label("fn-sinh"), raw("sinh"))
- #link(label("fn-skewness"), raw("skewness"))
- #link(label("fn-slice"), raw("slice"))
- #link(label("ref-quantified-comparison-predicates"))[SOME]
- #link(label("fn-soundex"), raw("soundex"))
- #raw("spatial_partitioning")
- #raw("spatial_partitions")
- #link(label("fn-split"), raw("split"))
- #link(label("fn-split-part"), raw("split_part"))
- #link(label("fn-split-to-map"), raw("split_to_map"))
- #link(label("fn-split-to-multimap"), raw("split_to_multimap"))
- #link(label("fn-spooky-hash-v2-32"), raw("spooky_hash_v2_32"))
- #link(label("fn-spooky-hash-v2-64"), raw("spooky_hash_v2_64"))
- #link(label("fn-sqrt"), raw("sqrt"))
- #link(label("fn-st-area"), raw("ST_Area"))
- #link(label("fn-st-asbinary"), raw("ST_AsBinary"))
- #link(label("fn-st-astext"), raw("ST_AsText"))
- #link(label("fn-st-boundary"), raw("ST_Boundary"))
- #link(label("fn-st-buffer"), raw("ST_Buffer"))
- #link(label("fn-st-centroid"), raw("ST_Centroid"))
- #link(label("fn-st-contains"), raw("ST_Contains"))
- #link(label("fn-st-convexhull"), raw("ST_ConvexHull"))
- #link(label("fn-st-coorddim"), raw("ST_CoordDim"))
- #link(label("fn-st-crosses"), raw("ST_Crosses"))
- #link(label("fn-st-difference"), raw("ST_Difference"))
- #link(label("fn-st-dimension"), raw("ST_Dimension"))
- #link(label("fn-st-disjoint"), raw("ST_Disjoint"))
- #link(label("fn-st-distance"), raw("ST_Distance"))
- #link(label("fn-st-endpoint"), raw("ST_EndPoint"))
- #link(label("fn-st-envelope"), raw("ST_Envelope"))
- #link(label("fn-st-envelopeaspts"), raw("ST_EnvelopeAsPts"))
- #link(label("fn-st-equals"), raw("ST_Equals"))
- #link(label("fn-st-exteriorring"), raw("ST_ExteriorRing"))
- #link(label("fn-st-geometries"), raw("ST_Geometries"))
- #link(label("fn-st-geometryfromtext"), raw("ST_GeometryFromText"))
- #link(label("fn-st-geometryn"), raw("ST_GeometryN"))
- #link(label("fn-st-geometrytype"), raw("ST_GeometryType"))
- #link(label("fn-st-geomfrombinary"), raw("ST_GeomFromBinary"))
- #link(label("fn-st-interiorringn"), raw("ST_InteriorRingN"))
- #link(label("fn-st-interiorrings"), raw("ST_InteriorRings"))
- #link(label("fn-st-intersection"), raw("ST_Intersection"))
- #link(label("fn-st-intersects"), raw("ST_Intersects"))
- #link(label("fn-st-isclosed"), raw("ST_IsClosed"))
- #link(label("fn-st-isempty"), raw("ST_IsEmpty"))
- #link(label("fn-st-isring"), raw("ST_IsRing"))
- #link(label("fn-st-issimple"), raw("ST_IsSimple"))
- #link(label("fn-st-isvalid"), raw("ST_IsValid"))
- #link(label("fn-st-length"), raw("ST_Length"))
- #link(label("fn-st-linefromtext"), raw("ST_LineFromText"))
- #link(label("fn-st-linestring"), raw("ST_LineString"))
- #link(label("fn-st-multipoint"), raw("ST_MultiPoint"))
- #link(label("fn-st-numgeometries"), raw("ST_NumGeometries"))
- #raw("ST_NumInteriorRing")
- #link(label("fn-st-numpoints"), raw("ST_NumPoints"))
- #link(label("fn-st-overlaps"), raw("ST_Overlaps"))
- #link(label("fn-st-point"), raw("ST_Point"))
- #link(label("fn-st-pointn"), raw("ST_PointN"))
- #link(label("fn-st-points"), raw("ST_Points"))
- #link(label("fn-st-polygon"), raw("ST_Polygon"))
- #link(label("fn-st-relate"), raw("ST_Relate"))
- #link(label("fn-st-startpoint"), raw("ST_StartPoint"))
- #link(label("fn-st-symdifference"), raw("ST_SymDifference"))
- #link(label("fn-st-touches"), raw("ST_Touches"))
- #link(label("fn-st-union"), raw("ST_Union"))
- #link(label("fn-st-within"), raw("ST_Within"))
- #link(label("fn-st-x"), raw("ST_X"))
- #link(label("fn-st-xmax"), raw("ST_XMax"))
- #link(label("fn-st-xmin"), raw("ST_XMin"))
- #link(label("fn-st-y"), raw("ST_Y"))
- #link(label("fn-st-ymax"), raw("ST_YMax"))
- #link(label("fn-st-ymin"), raw("ST_YMin"))
- #link(label("fn-starts-with"), raw("starts_with"))
- #link(label("fn-stddev"), raw("stddev"))
- #link(label("fn-stddev-pop"), raw("stddev_pop"))
- #link(label("fn-stddev-samp"), raw("stddev_samp"))
- #link(label("fn-strpos"), raw("strpos"))
- #link(label("fn-substr"), raw("substr"))
- #link(label("fn-substring"), raw("substring"))
- #link(label("fn-sum"), raw("sum"))

== T

- #link(label("fn-tan"), raw("tan"))
- #link(label("fn-tanh"), raw("tanh"))
- #link(label("fn-tdigest-agg"), raw("tdigest_agg"))
- #link(label("fn-theta-sketch-cardinality"), raw("theta_sketch_cardinality"))
- #link(label("fn-theta-sketch-union"), raw("theta_sketch_union"))
- #link(label("fn-timestamp-objectid"), raw("timestamp_objectid"))
- #link(label("fn-timezone"), raw("timezone"))
- #link(label("fn-timezone-hour"), raw("timezone_hour"))
- #link(label("fn-timezone-minute"), raw("timezone_minute"))
- #link(label("fn-to-base"), raw("to_base"))
- #link(label("fn-to-base32"), raw("to_base32"))
- #link(label("fn-to-base64"), raw("to_base64"))
- #link(label("fn-to-base64url"), raw("to_base64url"))
- #link(label("fn-to-big-endian-32"), raw("to_big_endian_32"))
- #link(label("fn-to-big-endian-64"), raw("to_big_endian_64"))
- #link(label("fn-to-char"), raw("to_char"))
- #link(label("fn-to-date"), raw("to_date"))
- #link(label("fn-to-encoded-polyline"), raw("to_encoded_polyline"))
- #raw("to_geojson_geometry")
- #link(label("fn-to-geometry"), raw("to_geometry"))
- #link(label("fn-to-hex"), raw("to_hex"))
- #link(label("fn-to-ieee754-32"), raw("to_ieee754_32"))
- #link(label("fn-to-ieee754-64"), raw("to_ieee754_64"))
- #link(label("fn-to-iso8601"), raw("to_iso8601"))
- #link(label("fn-to-milliseconds"), raw("to_milliseconds"))
- #link(label("fn-to-spherical-geography"), raw("to_spherical_geography"))
- #link(label("fn-to-timestamp"), raw("to_timestamp"))
- #link(label("fn-to-unixtime"), raw("to_unixtime"))
- #link(label("fn-to-utf8"), raw("to_utf8"))
- #link(label("fn-transform"), raw("transform"))
- #link(label("fn-transform-keys"), raw("transform_keys"))
- #link(label("fn-transform-values"), raw("transform_values"))
- #link(label("fn-translate"), raw("translate"))
- #link(label("fn-trim"), raw("trim"))
- #link(label("fn-trim-array"), raw("trim_array"))
- #link(label("fn-truncate"), raw("truncate"))
- #link(label("ref-try-function"))[try]
- #link(label("fn-try-cast"), raw("try_cast"))
- #link(label("fn-typeof"), raw("typeof"))

== U

- #link(label("fn-upper"), raw("upper"))
- #link(label("fn-url-decode"), raw("url_decode"))
- #link(label("fn-url-encode"), raw("url_encode"))
- #link(label("fn-url-extract-fragment"), raw("url_extract_fragment"))
- #link(label("fn-url-extract-host"), raw("url_extract_host"))
- #link(label("fn-url-extract-parameter"), raw("url_extract_parameter"))
- #link(label("fn-url-extract-path"), raw("url_extract_path"))
- #link(label("fn-url-extract-protocol"), raw("url_extract_protocol"))
- #link(label("fn-url-extract-port"), raw("url_extract_port"))
- #link(label("fn-url-extract-query"), raw("url_extract_query"))
- #link(label("fn-uuid"), raw("uuid"))

== V

- #link(label("fn-value-at-quantile"), raw("value_at_quantile"))
- #link(label("fn-values-at-quantiles"), raw("values_at_quantiles"))
- #link(label("fn-var-pop"), raw("var_pop"))
- #link(label("fn-var-samp"), raw("var_samp"))
- #link(label("fn-variance"), raw("variance"))
- #link(label("fn-version"), raw("version"))

== W

- #link(label("fn-week"), raw("week"))
- #link(label("fn-week-of-year"), raw("week_of_year"))
- #link(label("fn-width-bucket"), raw("width_bucket"))
- #link(label("fn-wilson-interval-lower"), raw("wilson_interval_lower"))
- #link(label("fn-wilson-interval-upper"), raw("wilson_interval_upper"))
- #link(label("fn-with-timezone"), raw("with_timezone"))
- #link(label("fn-word-stem"), raw("word_stem"))

== X

- #link(label("fn-xxhash64"), raw("xxhash64"))

== Y

- #link(label("fn-year"), raw("year"))
- #link(label("fn-year-of-week"), raw("year_of_week"))
- #link(label("fn-yow"), raw("yow"))

== Z

- #link(label("fn-zip"), raw("zip"))
- #link(label("fn-zip-with"), raw("zip_with"))
