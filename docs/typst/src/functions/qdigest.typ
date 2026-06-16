#import "/lib/trino-docs.typ": *

#anchor("doc-functions-qdigest")
= Quantile digest functions

== Data structures

A quantile digest is a data sketch which stores approximate percentile information.  The Trino type for this data structure is called #raw("qdigest"), and it takes a parameter which must be one of #raw("bigint"), #raw("double") or #raw("real") which represent the set of numbers that may be ingested by the #raw("qdigest").  They may be merged without losing precision, and for storage and retrieval they may be cast to\/from #raw("VARBINARY").

== Functions

#function-def("fn-merge-5", "merge(qdigest)", "qdigest", ref: false)[
Merges all input #raw("qdigest")s into a single #raw("qdigest").
]

#function-def("fn-value-at-quantile", "value_at_quantile(qdigest(T), quantile)", "T")[
Returns the approximate percentile value from the quantile digest given the number #raw("quantile") between 0 and 1.
]

#function-def("fn-quantile-at-value", "quantile_at_value(qdigest(T), T)", "quantile")[
Returns the approximate #raw("quantile") number between 0 and 1 from the quantile digest given an input value. Null is returned if the quantile digest is empty or the input value is outside the range of the quantile digest.
]

#function-def("fn-values-at-quantiles", "values_at_quantiles(qdigest(T), quantiles)", "array(T)")[
Returns the approximate percentile values as an array given the input quantile digest and array of values between 0 and 1 which represent the quantiles to return.
]

#function-def("fn-qdigest-agg-4", "qdigest_agg(x)", "qdigest([same as x])", ref: false)[
Returns the #raw("qdigest") which is composed of  all input values of #raw("x").
]

#function-def("fn-qdigest-agg-5", "qdigest_agg(x, w)", "qdigest([same as x])", ref: false)[
Returns the #raw("qdigest") which is composed of  all input values of #raw("x") using the per-item weight #raw("w").
]

#function-def("fn-qdigest-agg-6", "qdigest_agg(x, w, accuracy)", "qdigest([same as x])", ref: false)[
Returns the #raw("qdigest") which is composed of  all input values of #raw("x") using the per-item weight #raw("w") and maximum error of #raw("accuracy"). #raw("accuracy") must be a value greater than zero and less than one, and it must be constant for all input rows.
]
