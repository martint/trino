#import "/lib/trino-docs.typ": *

#anchor("doc-release-release-0-196")
= Release 0.196

== General

- Fix behavior of #raw("JOIN ... USING") to conform to standard SQL semantics. The old behavior can be restored by setting the #raw("deprecated.legacy-join-using") configuration option or the #raw("legacy_join_using") session property.
- Fix memory leak for queries with #raw("ORDER BY").
- Fix tracking of query peak memory usage.
- Fix skew in dynamic writer scaling by eagerly freeing memory in the source output buffers. This can be disabled by setting #raw("exchange.acknowledge-pages=false").
- Fix planning failure for lambda with capture in rare cases.
- Fix decimal precision of #raw("round(x, d)") when #raw("x") is a #raw("DECIMAL").
- Fix returned value from #raw("round(x, d)") when #raw("x") is a #raw("DECIMAL") with scale #raw("0") and #raw("d") is a negative integer. Previously, no rounding was done in this case.
- Improve performance of the #link(label("fn-array-join"), raw("array_join")) function.
- Improve performance of the #link(label("fn-st-envelope"), raw("ST_Envelope")) function.
- Optimize #link(label("fn-min-by"), raw("min_by")) and #link(label("fn-max-by"), raw("max_by")) by avoiding unnecessary object creation in order to reduce GC overhead.
- Show join partitioning explicitly in #raw("EXPLAIN").
- Add #link(label("fn-is-json-scalar"), raw("is_json_scalar")) function.
- Add #link(label("fn-regexp-replace"), raw("regexp_replace")) function variant that executes a lambda for each replacement.

== Security

- Add rules to the #raw("file") #link(label("doc-security-built-in-system-access-control"))[System access control] to enforce a specific matching between authentication credentials and a executing username.

== Hive

- Fix a correctness issue where non-null values can be treated as null values when writing dictionary-encoded strings to ORC files with the new ORC writer.
- Fix invalid failure due to string statistics mismatch while validating ORC files after they have been written with the new ORC writer. This happens when the written strings contain invalid UTF-8 code points.
- Add support for reading array, map, or row type columns from partitions where the partition schema is different from the table schema. This can occur when the table schema was updated after the partition was created. The changed column types must be compatible. For rows types, trailing fields may be added or dropped, but the corresponding fields \(by ordinal\) must have the same name.
- Add #raw("hive.non-managed-table-creates-enabled") configuration option that controls whether or not users may create non-managed \(external\) tables. The default value is #raw("true").
