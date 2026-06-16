#import "/lib/trino-docs.typ": *

#anchor("doc-release-release-0-137")
= Release 0.137

== General

- Fix #raw("current_date") to return correct results for all time zones.
- Fix invalid plans when scalar subqueries use #raw("GROUP BY"), #raw("DISTINCT") or #raw("JOIN").
- Do not allow creating views with a column type of #raw("UNKNOWN").
- Improve expression optimizer to remove some redundant operations.
- Add #link(label("fn-bit-count"), raw("bit_count")), #link(label("fn-bitwise-not"), raw("bitwise_not")), #link(label("fn-bitwise-and"), raw("bitwise_and")), #link(label("fn-bitwise-or"), raw("bitwise_or")), and #link(label("fn-bitwise-xor"), raw("bitwise_xor")) functions.
- Add #link(label("fn-approx-distinct"), raw("approx_distinct")) aggregation support for #raw("VARBINARY") input.
- Add create time to query detail page in UI.
- Add support for #raw("VARCHAR(length)") type.
- Track per-stage peak memory usage.
- Allow using double input for #link(label("fn-approx-percentile"), raw("approx_percentile")) with an array of percentiles.
- Add API to JDBC driver to track query progress.

== Hive

- Do not allow inserting into tables when the Hive type does not match the Presto type. Previously, Presto would insert data that did not match the table or partition type and that data could not be read by Hive. For example, Presto would write files containing #raw("BIGINT") data for a Hive column type of #raw("INT").
- Add validation to #link(label("doc-sql-create-table"))[CREATE TABLE] and #link(label("doc-sql-create-table-as"))[CREATE TABLE AS] to check that partition keys are the last columns in the table and in the same order as the table properties.
- Remove #raw("retention_days") table property. This property is not used by Hive.
- Fix Parquet decoding of #raw("MAP") containing a null value.
- Add support for accessing ORC columns by name. By default, columns in ORC files are accessed by their ordinal position in the Hive table definition. To access columns based on the names recorded in the ORC file, set #raw("hive.orc.use-column-names=true") in your Hive catalog properties file.
