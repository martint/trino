#import "/lib/trino-docs.typ": *

#anchor("doc-release-release-0-178")
= Release 0.178

== General

- Fix various memory accounting bugs, which reduces the likelihood of full GCs\/OOMs.
- Fix a regression that causes queries that use the keyword "stats" to fail to parse.
- Fix an issue where a query does not get cleaned up on the coordinator after query failure.
- Add ability to cast to #raw("JSON") from #raw("REAL"), #raw("TINYINT") or #raw("SMALLINT").
- Add support for #raw("GROUPING") operation to #link(label("ref-complex-grouping-operations"))[complex grouping operations].
- Add support for correlated subqueries in #raw("IN") predicates.
- Add #link(label("fn-to-ieee754-32"), raw("to_ieee754_32")) and #link(label("fn-to-ieee754-64"), raw("to_ieee754_64")) functions.

== Hive

- Fix high CPU usage due to schema caching when reading Avro files.
- Preserve decompression error causes when decoding ORC files.

== Memory connector

- Fix a bug that prevented creating empty tables.

== SPI

- Make environment available to resource group configuration managers.
- Add additional performance statistics to query completion event.
