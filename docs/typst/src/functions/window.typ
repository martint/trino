#import "/lib/trino-docs.typ": *

#anchor("doc-functions-window")
= Window functions

Window functions perform calculations across rows of the query result. They run after the #raw("HAVING") clause but before the #raw("ORDER BY") clause. Invoking a window function requires special syntax using the #raw("OVER") clause to specify the window. For example, the following query ranks orders for each clerk by price:

#code-block(none, "SELECT orderkey, clerk, totalprice,
       rank() OVER (PARTITION BY clerk
                    ORDER BY totalprice DESC) AS rnk
FROM orders
ORDER BY clerk, rnk")

The window can be specified in two ways \(see #link(label("ref-window-clause"))[window-clause]\):

- By a reference to a named window specification defined in the #raw("WINDOW") clause,
- By an in-line window specification which allows to define window components as well as refer to the window components pre-defined in the #raw("WINDOW") clause.

== Aggregate functions

All aggregate can be used as window functions by adding the #raw("OVER") clause. The aggregate function is computed for each row over the rows within the current row's window frame. Note that #link(label("ref-aggregate-function-ordering-during-aggregation"))[ordering during aggregation] is not supported.

For example, the following query produces a rolling sum of order prices by day for each clerk:

#code-block(none, "SELECT clerk, orderdate, orderkey, totalprice,
       sum(totalprice) OVER (PARTITION BY clerk
                             ORDER BY orderdate) AS rolling_sum
FROM orders
ORDER BY clerk, orderdate, orderkey")

== Ranking functions

#function-def("fn-cume-dist", "cume_dist()", "bigint")[
Returns the cumulative distribution of a value in a group of values. The result is the number of rows preceding or peer with the row in the window ordering of the window partition divided by the total number of rows in the window partition. Thus, any tie values in the ordering will evaluate to the same distribution value. The window frame must not be specified.
]

#function-def("fn-dense-rank", "dense_rank()", "bigint")[
Returns the rank of a value in a group of values. This is similar to #link(label("fn-rank"), raw("rank")), except that tie values do not produce gaps in the sequence. The window frame must not be specified.
]

#function-def("fn-ntile", "ntile(n)", "bigint")[
Divides the rows for each window partition into #raw("n") buckets ranging from #raw("1") to at most #raw("n"). Bucket values will differ by at most #raw("1"). If the number of rows in the partition does not divide evenly into the number of buckets, then the remainder values are distributed one per bucket, starting with the first bucket.

For example, with #raw("6") rows and #raw("4") buckets, the bucket values would be as follows: #raw("1") #raw("1") #raw("2") #raw("2") #raw("3") #raw("4")

For the #link(label("fn-ntile"), raw("ntile")) function, the window frame must not be specified.
]

#function-def("fn-percent-rank", "percent_rank()", "double")[
Returns the percentage ranking of a value in group of values. The result is #raw("(r - 1) / (n - 1)") where #raw("r") is the #link(label("fn-rank"), raw("rank")) of the row and #raw("n") is the total number of rows in the window partition. The window frame must not be specified.
]

#function-def("fn-rank", "rank()", "bigint")[
Returns the rank of a value in a group of values. The rank is one plus the number of rows preceding the row that are not peer with the row. Thus, tie values in the ordering will produce gaps in the sequence. The ranking is performed for each window partition. The window frame must not be specified.
]

#function-def("fn-row-number", "row_number()", "bigint")[
Returns a unique, sequential number for each row, starting with one, according to the ordering of rows within the window partition. The window frame must not be specified.
]

== Value functions

By default, null values are respected. If #raw("IGNORE NULLS") is specified, all rows where #raw("x") is null are excluded from the calculation. If #raw("IGNORE NULLS") is specified and #raw("x") is null for all rows, the #raw("default_value") is returned, or if it is not specified, #raw("null") is returned.

#function-def("fn-first-value", "first_value(x)", "[same as input]")[
Returns the first value of the window.
]

#function-def("fn-last-value", "last_value(x)", "[same as input]")[
Returns the last value of the window.
]

#function-def("fn-nth-value", "nth_value(x, offset)", "[same as input]")[
Returns the value at the specified offset from the beginning of the window. Offsets start at #raw("1"). The offset can be any scalar expression.  If the offset is null or greater than the number of values in the window, #raw("null") is returned.  It is an error for the offset to be zero or negative.
]

#function-def("fn-lead", "lead(x[, offset [, default_value]])", "[same as input]")[
Returns the value at #raw("offset") rows after the current row in the window partition. Offsets start at #raw("0"), which is the current row. The offset can be any scalar expression.  The default #raw("offset") is #raw("1"). If the offset is null, an error is raised. If the offset refers to a row that is not within the partition, the #raw("default_value") is returned, or if it is not specified #raw("null") is returned. The #link(label("fn-lead"), raw("lead")) function requires that the window ordering be specified. Window frame must not be specified.
]

#function-def("fn-lag", "lag(x[, offset [, default_value]])", "[same as input]")[
Returns the value at #raw("offset") rows before the current row in the window partition. Offsets start at #raw("0"), which is the current row. The offset can be any scalar expression.  The default #raw("offset") is #raw("1"). If the offset is null, an error is raised. If the offset refers to a row that is not within the partition, the #raw("default_value") is returned, or if it is not specified #raw("null") is returned. The #link(label("fn-lag"), raw("lag")) function requires that the window ordering be specified. Window frame must not be specified.
]
