#import "/lib/trino-docs.typ": *

#anchor("doc-release-release-0-204")
= Release 0.204

== General

- Use distributed join if one side is naturally partitioned on join keys.
- Improve performance of correlated subqueries when filters from outer query can be propagated to the subquery.
- Improve performance for correlated subqueries that contain inequalities.
- Add support for all geometry types in #link(label("fn-st-area"), raw("ST_Area")).
- Add #link(label("fn-st-envelopeaspts"), raw("ST_EnvelopeAsPts")) function.
- Add #link(label("fn-to-big-endian-32"), raw("to_big_endian_32")) and #link(label("fn-from-big-endian-32"), raw("from_big_endian_32")) functions.
- Add cast between #raw("VARBINARY") type and #raw("IPADDRESS") type.
- Make #link(label("fn-lpad"), raw("lpad")) and #link(label("fn-rpad"), raw("rpad")) functions support #raw("VARBINARY") in addition to #raw("VARCHAR").
- Allow using arrays of mismatched lengths with #link(label("fn-zip-with"), raw("zip_with")). The missing positions are filled with #raw("NULL").
- Track execution statistics of #raw("AddExchanges") and #raw("PredicatePushdown") optimizer rules.

== Event listener

- Add resource estimates to query events.

== Web UI

- Fix kill query button.
- Display resource estimates in Web UI query details page.

== Resource group

- Fix unnecessary queuing in deployments where no resource group configuration was specified.

== Hive connector

- Fix over-estimation of memory usage for scan operators when reading ORC files.
- Fix memory accounting for sort buffer used for writing sorted bucketed tables.
- Disallow creating tables with unsupported partition types.
- Support overwriting partitions for insert queries. This behavior is controlled by session property #raw("insert_existing_partitions_behavior").
- Prevent the optimized ORC writer from writing excessively large stripes for highly compressed, dictionary encoded columns.
- Enable optimized Parquet reader and predicate pushdown by default.

== Cassandra connector

- Add support for reading from materialized views.
- Optimize partition list retrieval for Cassandra 2.2+.
