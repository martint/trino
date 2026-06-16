#import "/lib/trino-docs.typ": *

#anchor("doc-release-release-0-168")
= Release 0.168

== General

- Fix correctness issues for certain #raw("JOIN") queries that require implicit coercions for terms in the join criteria.
- Fix invalid "No more locations already set" error.
- Fix invalid "No more buffers already set" error.
- Temporarily revert empty join short-circuit optimization due to issue with hanging queries.
- Improve performance of #raw("DECIMAL") type and operators.
- Optimize window frame computation for empty frames.
- #link(label("fn-json-extract"), raw("json_extract")) and #link(label("fn-json-extract-scalar"), raw("json_extract_scalar")) now support escaping double quotes or backslashes using a backslash with a JSON path subscript. This changes the semantics of any invocation using a backslash, as backslashes were previously treated as normal characters.
- Improve performance of #link(label("fn-filter"), raw("filter")) and #link(label("fn-map-filter"), raw("map_filter")) lambda functions.
- Add #link(label("doc-connector-memory"))[Memory connector].
- Add #link(label("fn-arrays-overlap"), raw("arrays_overlap")) and #link(label("fn-array-except"), raw("array_except")) functions.
- Allow concatenating more than two arrays with #raw("concat()") or maps with #link(label("fn-map-concat"), raw("map_concat")).
- Add a time limit for the iterative optimizer. It can be adjusted via the #raw("iterative_optimizer_timeout") session property or #raw("experimental.iterative-optimizer-timeout") configuration option.
- #raw("ROW") types are now orderable if all of the field types are orderable. This allows using them in comparison expressions, #raw("ORDER BY") and functions that require orderable types \(e.g., #link(label("fn-max"), raw("max"))\).

== JDBC driver

- Update #raw("DatabaseMetaData") to reflect features that are now supported.
- Update advertised JDBC version to 4.2, which part of Java 8.
- Return correct driver and server versions rather than #raw("1.0").

== Hive

- Fix reading decimals for RCFile text format using non-optimized reader.
- Fix bug which prevented the file based metastore from being used.
- Enable optimized RCFile reader by default.
- Common user errors are now correctly categorized.
- Add new, experimental, RCFile writer optimized for Presto.  The new writer can be enabled with the #raw("rcfile_optimized_writer_enabled") session property or the #raw("hive.rcfile-optimized-writer.enabled") Hive catalog property.

== Cassandra

- Add predicate pushdown for clustering key.

== MongoDB

- Allow SSL connections using the #raw("mongodb.ssl.enabled") config flag.

== SPI

- ConnectorIndex now returns #raw("ConnectorPageSource") instead of #raw("RecordSet").  Existing connectors that support index join can use the #raw("RecordPageSource") to adapt to the new API.
