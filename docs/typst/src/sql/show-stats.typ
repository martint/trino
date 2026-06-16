#import "/lib/trino-docs.typ": *

#anchor("doc-sql-show-stats")
= SHOW STATS

== Synopsis

#code-block("text", "SHOW STATS FOR table
SHOW STATS FOR ( query )")

== Description

Returns approximated statistics for the named table or for the results of a query. Returns #raw("NULL") for any statistics that are not populated or unavailable on the data source.

Statistics are returned as a row for each column, plus a summary row for the table \(identifiable by a #raw("NULL") value for #raw("column_name")\). The following table lists the returned columns and what statistics they represent. Any additional statistics collected on the data source, other than those listed here, are not included.

#list-table((
  ([Column], [Description], [Notes],),
  ([#raw("column_name")], [The name of the column], [#raw("NULL") in the table summary row],),
  ([#raw("data_size")], [The total size in bytes of all the values in the column], [#raw("NULL") in the table summary row. Available for columns of #link(label("ref-string-data-types"))[string] data types with variable widths.],),
  ([#raw("distinct_values_count")], [The estimated number of distinct values in the column], [#raw("NULL") in the table summary row],),
  ([#raw("nulls_fractions")], [The portion of the values in the column that are #raw("NULL")], [#raw("NULL") in the table summary row.],),
  ([#raw("row_count")], [The estimated number of rows in the table], [#raw("NULL") in column statistic rows],),
  ([#raw("low_value")], [The lowest value found in this column], [#raw("NULL") in the table summary row. Available for columns of #link(label("ref-date-data-type"))[DATE], #link(label("ref-integer-data-types"))[integer], #link(label("ref-floating-point-data-types"))[floating-point], and #link(label("ref-exact-numeric-data-types"))[exact numeric] data types.],),
  ([#raw("high_value")], [The highest value found in this column], [#raw("NULL") in the table summary row. Available for columns of #link(label("ref-date-data-type"))[DATE], #link(label("ref-integer-data-types"))[integer], #link(label("ref-floating-point-data-types"))[floating-point], and #link(label("ref-exact-numeric-data-types"))[exact numeric] data types.],)
), header-rows: 1, title: "Statistics")
