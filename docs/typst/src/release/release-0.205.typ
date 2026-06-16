#import "/lib/trino-docs.typ": *

#anchor("doc-release-release-0-205")
= Release 0.205

== General

- Fix parsing of row types where the field types contain spaces. Previously, row expressions that included spaces would fail to parse. For example: #raw("cast(row(timestamp '2018-06-01') AS row(timestamp with time zone))").
- Fix distributed planning failure for complex queries when using bucketed execution.
- Fix #link(label("fn-st-exteriorring"), raw("ST_ExteriorRing")) to only accept polygons. Previously, it erroneously accepted other geometries.
- Add the #raw("task.min-drivers-per-task") and #raw("task.max-drivers-per-task") config options. The former specifies the guaranteed minimum number of drivers a task will run concurrently given that it has enough work to do. The latter specifies the maximum number of drivers a task can run concurrently.
- Add the #raw("concurrent-lifespans-per-task") config property to control the default value of the #raw("concurrent_lifespans_per_task") session property.
- Add the #raw("query_max_total_memory") session property and the #raw("query.max-total-memory") config property. Queries will be aborted after their total \(user + system\) memory reservation exceeds this threshold.
- Improve stats calculation for outer joins and correlated subqueries.
- Reduce memory usage when a #raw("Block") contains all null or all non-null values.
- Change the internal hash function used in  #raw("approx_distinct"). The result of #raw("approx_distinct") may change in this version compared to the previous version for the same set of values. However, the standard error of the results should still be within the configured bounds.
- Improve efficiency and reduce memory usage for scalar correlated subqueries with aggregations.
- Remove the legacy local scheduler and associated configuration properties, #raw("task.legacy-scheduling-behavior") and #raw("task.level-absolute-priority").
- Do not allow using the #raw("FILTER") clause for the #raw("COALESCE"), #raw("IF"), or #raw("NULLIF") functions. The syntax was previously allowed but was otherwise ignored.

== Security

- Remove unnecessary check for #raw("SELECT") privileges for #raw("DELETE") queries. Previously, #raw("DELETE") queries could fail if the user only has #raw("DELETE") privileges but not #raw("SELECT") privileges. This only affected connectors that implement #raw("checkCanSelectFromColumns()").
- Add a check that the view owner has permission to create the view when running #raw("SELECT") queries against a view. This only affected connectors that implement #raw("checkCanCreateViewWithSelectFromColumns()").
- Change #raw("DELETE FROM <table> WHERE <condition>") to check that the user has #raw("SELECT") privileges on the objects referenced by the #raw("WHERE") condition as is required by the SQL standard.
- Improve the error message when access is denied when selecting from a view due to the view owner having insufficient permissions to create the view.

== JDBC driver

- Add support for prepared statements.
- Add partial query cancellation via #raw("partialCancel()") on #raw("PrestoStatement").
- Use #raw("VARCHAR") rather than #raw("LONGNVARCHAR") for the Presto #raw("varchar") type.
- Use #raw("VARBINARY") rather than #raw("LONGVARBINARY") for the Presto #raw("varbinary") type.

== Hive connector

- Improve the performance of #raw("INSERT") queries when all partition column values are constants.
- Improve stripe size estimation for the optimized ORC writer. This reduces the number of cases where tiny ORC stripes will be written.
- Respect the #raw("skip.footer.line.count") Hive table property.

== CLI

- Prevent the CLI from crashing when running on certain 256 color terminals.

== SPI

- Add a context parameter to the #raw("create()") method in #raw("SessionPropertyConfigurationManagerFactory").
- Disallow non-static methods to be annotated with #raw("@ScalarFunction"). Non-static SQL function implementations must now be declared in a class annotated with #raw("@ScalarFunction").
- Disallow having multiple public constructors in #raw("@ScalarFunction") classes. All non-static implementations of SQL functions will now be associated with a single constructor. This improves support for providing specialized implementations of SQL functions with generic arguments.
- Deprecate #raw("checkCanSelectFromTable/checkCanSelectFromView") and #raw("checkCanCreateViewWithSelectFromTable/checkCanCreateViewWithSelectFromView") in #raw("ConnectorAccessControl") and #raw("SystemAccessControl"). #raw("checkCanSelectFromColumns") and #raw("checkCanCreateViewWithSelectFromColumns") should be used instead.

#note[
These are backwards incompatible changes with the previous SPI. If you have written a plugin using these features, you will need to update your code before deploying this release.
]
