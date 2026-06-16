#import "/lib/trino-docs.typ": *

#anchor("doc-release-release-0-197")
= Release 0.197

== General

- Fix query scheduling hang when the #raw("concurrent_lifespans_per_task") session property is set.
- Fix failure when a query contains a #raw("TIMESTAMP") literal corresponding to a local time that does not occur in the default time zone of the Presto JVM. For example, if Presto was running in a CET zone \(e.g., #raw("Europe/Brussels")\) and the client session was in UTC, an expression such as #raw("TIMESTAMP '2017-03-26 02:10:00'") would cause a failure.
- Extend predicate inference and pushdown for queries using a #raw("<symbol> IN <subquery>") predicate.
- Support predicate pushdown for the #raw("<column> IN <values list>") predicate where values in the #raw("values list") require casting to match the type of #raw("column").
- Optimize #link(label("fn-min"), raw("min")) and #link(label("fn-max"), raw("max")) to avoid unnecessary object creation in order to reduce GC overhead.
- Optimize the performance of #link(label("fn-st-xmin"), raw("ST_XMin")), #link(label("fn-st-xmax"), raw("ST_XMax")), #link(label("fn-st-ymin"), raw("ST_YMin")), and #link(label("fn-st-ymax"), raw("ST_YMax")).
- Add #raw("DATE") variant for #link(label("fn-sequence"), raw("sequence")) function.
- Add #link(label("fn-st-issimple"), raw("ST_IsSimple")) geospatial function.
- Add support for broadcast spatial joins.

== Resource groups

- Change configuration check for weights in resource group policy to validate that either all of the sub-groups or none of the sub-groups have a scheduling weight configured.
- Add support for named variables in source and user regular expressions that can be used to parameterize resource group names.
- Add support for optional fields in DB resource group exact match selectors.

== Hive

- Fix reading of Hive partition statistics with unset fields. Previously, unset fields were incorrectly interpreted as having a value of zero.
- Fix integer overflow when writing a single file greater than 2GB with optimized ORC writer.
- Fix system memory accounting to include stripe statistics size and writer validation size for the optimized ORC writer.
- Dynamically allocate the compression buffer for the optimized ORC writer to avoid unnecessary memory allocation. Add config property #raw("hive.orc.writer.max-compression-buffer-size") to limit the maximum size of the buffer.
- Add session property #raw("orc_optimized_writer_max_stripe_size") to tune the maximum stipe size for the optimized ORC writer.
- Add session property #raw("orc_string_statistics_limit") to drop the string statistics when writing ORC files if they exceed the limit.
- Use the view owner returned from the metastore at the time of the query rather than always using the user who created the view. This allows changing the owner of a view.

== CLI

- Fix hang when CLI fails to communicate with Presto server.

== SPI

- Include connector session properties for the connector metadata calls made when running #raw("SHOW") statements or querying #raw("information_schema").
- Add count and time of full GC that occurred while query was running to #raw("QueryCompletedEvent").
- Change the #raw("ResourceGroupManager") interface to include a #raw("match()") method and remove the #raw("getSelectors()") method and the #raw("ResourceGroupSelector") interface.
- Rename the existing #raw("SelectionContext") class to be #raw("SelectionCriteria") and create a new #raw("SelectionContext") class that is returned from the #raw("match()") method and contains the resource group ID and a manager-defined context field.
- Use the view owner from #raw("ConnectorViewDefinition") when present.
