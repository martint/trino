#import "/lib/trino-docs.typ": *

#anchor("doc-functions-hyperloglog")
= HyperLogLog functions

Trino implements the #link(label("fn-approx-distinct"), raw("approx_distinct")) function using the #link("https://wikipedia.org/wiki/HyperLogLog")[HyperLogLog] data structure.

== Data structures

Trino implements HyperLogLog data sketches as a set of 32-bit buckets which store a #emph[maximum hash]. They can be stored sparsely \(as a map from bucket ID to bucket\), or densely \(as a contiguous memory block\). The HyperLogLog data structure starts as the sparse representation, switching to dense when it is more efficient. The P4HyperLogLog structure is initialized densely and remains dense for its lifetime.

#link(label("ref-hyperloglog-type"))[hyperloglog-type] implicitly casts to #link(label("ref-p4hyperloglog-type"))[p4hyperloglog-type], while one can explicitly cast #raw("HyperLogLog") to #raw("P4HyperLogLog"):

#code-block(none, "cast(hll AS P4HyperLogLog)")

== Serialization

Data sketches can be serialized to and deserialized from #raw("varbinary"). This allows them to be stored for later use.  Combined with the ability to merge multiple sketches, this allows one to calculate #link(label("fn-approx-distinct"), raw("approx_distinct")) of the elements of a partition of a query, then for the entirety of a query with very little cost.

For example, calculating the #raw("HyperLogLog") for daily unique users will allow weekly or monthly unique users to be calculated incrementally by combining the dailies. This is similar to computing weekly revenue by summing daily revenue. Uses of #link(label("fn-approx-distinct"), raw("approx_distinct")) with #raw("GROUPING SETS") can be converted to use #raw("HyperLogLog").  Examples:

#code-block(none, "CREATE TABLE visit_summaries (
  visit_date date,
  hll varbinary
);

INSERT INTO visit_summaries
SELECT visit_date, cast(approx_set(user_id) AS varbinary)
FROM user_visits
GROUP BY visit_date;

SELECT cardinality(merge(cast(hll AS HyperLogLog))) AS weekly_unique_users
FROM visit_summaries
WHERE visit_date >= current_date - interval '7' day;")

== Functions

#function-def("fn-approx-set-2", "approx_set(x)", "HyperLogLog", ref: false)[
Returns the #raw("HyperLogLog") sketch of the input data set of #raw("x"). This data sketch underlies #link(label("fn-approx-distinct"), raw("approx_distinct")) and can be stored and used later by calling #raw("cardinality()").
]

#function-def("fn-cardinality-2", "cardinality(hll)", "bigint", ref: false)[
This will perform #link(label("fn-approx-distinct"), raw("approx_distinct")) on the data summarized by the #raw("hll") HyperLogLog data sketch.
]

#function-def("fn-empty-approx-set", "empty_approx_set()", "HyperLogLog")[
Returns an empty #raw("HyperLogLog").
]

#function-def("fn-merge-4", "merge(HyperLogLog)", "HyperLogLog", ref: false)[
Returns the #raw("HyperLogLog") of the aggregate union of the individual #raw("hll") HyperLogLog structures.
]
