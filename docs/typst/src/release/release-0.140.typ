#import "/lib/trino-docs.typ": *

#anchor("doc-release-release-0-140")
= Release 0.140

== General

- Add the #raw("TRY") function to handle specific data exceptions. See #link(label("doc-functions-conditional"))[Conditional expressions].
- Optimize predicate expressions to minimize redundancies.
- Add environment name to UI.
- Fix logging of #raw("failure_host") and #raw("failure_task") fields in #raw("QueryCompletionEvent").
- Fix race which can cause queries to fail with a #raw("REMOTE_TASK_ERROR").
- Optimize #link(label("fn-array-distinct"), raw("array_distinct")) for #raw("array(bigint)").
- Optimize #raw(">") operator for #link(label("ref-array-type"))[array-type].
- Fix an optimization issue that could result in non-deterministic functions being evaluated more than once producing unexpected results.
- Fix incorrect result for rare #raw("IN") lists that contain certain combinations of non-constant expressions that are null and non-null.
- Improve performance of joins, aggregations, etc. by removing unnecessarily duplicated columns.
- Optimize #raw("NOT IN") queries to produce more compact predicates.

== Hive

- Remove bogus "from deserializer" column comments.
- Change categorization of Hive writer errors to be more specific.
- Add date and timestamp support to new Parquet Reader

== SPI

- Remove partition key from #raw("ColumnMetadata").
- Change return type of #raw("ConnectorTableLayout.getDiscretePredicates()").

#note[
This is a backwards incompatible change with the previous connector SPI. If you have written a connector, you will need to update your code before deploying this release.
]
