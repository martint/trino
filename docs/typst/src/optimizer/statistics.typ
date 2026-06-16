#import "/lib/trino-docs.typ": *

#anchor("doc-optimizer-statistics")
= Table statistics

Trino supports statistics based optimizations for queries. For a query to take advantage of these optimizations, Trino must have statistical information for the tables in that query.

Table statistics are estimates about the stored data. They are provided to the query planner by connectors and enable performance improvements for query processing.

== Available statistics

The following statistics are available in Trino:

- For a table:
  
  - #strong[row count]: the total number of rows in the table
- For each column in a table:
  
  - #strong[data size]: the size of the data that needs to be read
  - #strong[nulls fraction]: the fraction of null values
  - #strong[distinct value count]: the number of distinct values
  - #strong[low value]: the smallest value in the column
  - #strong[high value]: the largest value in the column

The set of statistics available for a particular query depends on the connector being used and can also vary by table. For example, the Hive connector does not currently provide statistics on data size.

Table statistics can be displayed via the Trino SQL interface using the #link(label("doc-sql-show-stats"))[SHOW STATS] command.

Depending on the connector support, table statistics are updated by Trino when executing #link(label("ref-sql-data-management"))[data management statements] like #raw("INSERT"), #raw("UPDATE"), or #raw("DELETE"). For example, the #link(label("ref-delta-lake-table-statistics"))[Delta Lake connector], the #link(label("ref-hive-analyze"))[Hive connector], and the #link(label("ref-iceberg-table-statistics"))[Iceberg connector] all support table statistics management from Trino.

You can also initialize statistics collection with the #link(label("doc-sql-analyze"))[ANALYZE] command. This is needed when other systems manipulate the data without Trino, and therefore statistics tracked by Trino are out of date. Other connectors rely on the underlying data source to manage table statistics or do not support table statistics use at all.
