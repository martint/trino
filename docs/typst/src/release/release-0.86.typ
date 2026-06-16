#import "/lib/trino-docs.typ": *

#anchor("doc-release-release-0-86")
= Release 0.86

== General

- Add support for inequality #raw("INNER JOIN") when each term of the condition refers to only one side of the join.
- Add #link(label("fn-ntile"), raw("ntile")) function.
- Add #link(label("fn-map"), raw("map")) function to create a map from arrays of keys and values.
- Add #link(label("fn-min-by"), raw("min_by")) aggregation function.
- Add support for concatenating arrays with the #raw("||") operator.
- Add support for #raw("=") and #raw("!=") to #raw("JSON") type.
- Improve error message when #raw("DISTINCT") is applied to types that are not comparable.
- Perform type validation for #raw("IN") expression where the right-hand side is a subquery expression.
- Improve error message when #raw("ORDER BY ... LIMIT") query exceeds its maximum memory allocation.
- Improve error message when types that are not orderable are used in an #raw("ORDER BY") clause.
- Improve error message when the types of the columns for subqueries of a #raw("UNION") query don't match.
- Fix a regression where queries could be expired too soon on a highly loaded cluster.
- Fix scheduling issue for queries involving tables from information\_schema, which could result in inconsistent metadata.
- Fix an issue with #link(label("fn-min-by"), raw("min_by")) and #link(label("fn-max-by"), raw("max_by")) that could result in an error when used with a variable-length type \(e.g., #raw("VARCHAR")\) in a #raw("GROUP BY") query.
- Fix rendering of array attributes in JMX connector.
- Input rows\/bytes are now tracked properly for #raw("JOIN") queries.
- Fix case-sensitivity issue when resolving names of constant table expressions.
- Fix unnesting arrays and maps that contain the #raw("ROW") type.
