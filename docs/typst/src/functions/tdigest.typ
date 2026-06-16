#import "/lib/trino-docs.typ": *

#anchor("doc-functions-tdigest")
= T-Digest functions

== Data structures

A T-digest is a data sketch which stores approximate percentile information.  The Trino type for this data structure is called #raw("tdigest"). T-digests can be merged, and for storage and retrieval they can be cast to and from #raw("VARBINARY").

== Functions

#function-def("fn-merge-6", "merge(tdigest)", "tdigest", ref: false)[
Aggregates all inputs into a single #raw("tdigest").
]

#function-def("fn-value-at-quantile-2", "value_at_quantile(tdigest, quantile)", "double", ref: false)[
Returns the approximate percentile value from the T-digest, given the number #raw("quantile") between 0 and 1.
]

#function-def("fn-values-at-quantiles-2", "values_at_quantiles(tdigest, quantiles)", "array(double)", ref: false)[
Returns the approximate percentile values as an array, given the input T-digest and an array of values between 0 and 1, which represent the quantiles to return.
]

#function-def("fn-tdigest-agg-3", "tdigest_agg(x)", "tdigest", ref: false)[
Composes all input values of #raw("x") into a #raw("tdigest"). #raw("x") can be of any numeric type.
]

#function-def("fn-tdigest-agg-4", "tdigest_agg(x, w)", "tdigest", ref: false)[
Composes all input values of #raw("x") into a #raw("tdigest") using the per-item weight #raw("w"). #raw("w") must be greater or equal than 1. #raw("x") and #raw("w") can be of any numeric type.
]
