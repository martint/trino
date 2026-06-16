#import "/lib/trino-docs.typ": *

#anchor("doc-release-release-0-214")
= Release 0.214

== General

- Fix history leak in coordinator for failed or canceled queries.
- Fix memory leak related to query tracking in coordinator that was introduced in #link(label("doc-release-release-0-213"))[Release 0.213].
- Fix planning failures when lambdas are used in join filter expression.
- Fix responses to client for certain types of errors that are encountered during query creation.
- Improve error message when an invalid comparator is provided to the #link(label("fn-array-sort"), raw("array_sort")) function.
- Improve performance of lookup operations on map data types.
- Improve planning and query performance for queries with #raw("TINYINT"), #raw("SMALLINT") and #raw("VARBINARY") literals.
- Fix issue where queries containing distributed #raw("ORDER BY") and aggregation could sometimes fail to make progress when data was spilled.
- Make top N row number optimization work in some cases when columns are pruned.
- Add session property #raw("optimize-top-n-row-number") and configuration property #raw("optimizer.optimize-top-n-row-number") to toggle the top N row number optimization.
- Add #link(label("fn-ngrams"), raw("ngrams")) function to generate N-grams from an array.
- Add #link(label("ref-qdigest-type"))[qdigest] type and associated #link(label("doc-functions-qdigest"))[Quantile digest functions].
- Add functionality to delay query execution until a minimum number of workers nodes are available. The minimum number of workers can be set with the #raw("query-manager.required-workers") configuration property, and the max wait time with the #raw("query-manager.required-workers-max-wait") configuration property.
- Remove experimental pre-allocated memory system, and the related configuration property #raw("experimental.preallocate-memory-threshold").

== Security

- Add functionality to refresh the configuration of file-based access controllers. The refresh interval can be set using the #raw("security.refresh-period") configuration property.

== JDBC driver

- Clear update count after calling #raw("Statement.getMoreResults()").

== Web UI

- Show query warnings on the query detail page.
- Allow selecting non-default sort orders in query list view.

== Hive connector

- Prevent ORC writer from writing stripes larger than the maximum configured size.
- Add #raw("hive.s3.upload-acl-type") configuration property to specify the type of ACL to use while uploading files to S3.
- Add Hive metastore API recording tool for remote debugging purposes.
- Add support for retrying on metastore connection errors.

== Verifier

- Handle SQL execution timeouts while rewriting queries.
