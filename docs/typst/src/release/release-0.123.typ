#import "/lib/trino-docs.typ": *

#anchor("doc-release-release-0-123")
= Release 0.123

== General

- Remove #raw("node-scheduler.location-aware-scheduling-enabled") config.
- Fixed query failures that occur when the #raw("optimizer.optimize-hash-generation") config is disabled.
- Fix exception when using the #raw("ResultSet") returned from the #raw("DatabaseMetaData.getColumns") method in the JDBC driver.
- Increase default value of #raw("failure-detector.threshold") config.
- Fix race in queueing system which could cause queries to fail with "Entering secondary queue failed".
- Fix issue with #link(label("fn-histogram"), raw("histogram")) that can cause failures or incorrect results when there are more than ten buckets.
- Optimize execution of cross join.
- Run Presto server as #raw("presto") user in RPM init scripts.

== Table properties

When creating tables with #link(label("doc-sql-create-table"))[CREATE TABLE] or #link(label("doc-sql-create-table-as"))[CREATE TABLE AS], you can now add connector specific properties to the new table.  For example, when creating a Hive table you can specify the file format.  To list all available table, properties, run the following query:

#code-block(none, "SELECT * FROM system.metadata.table_properties")

== Hive

We have implemented #raw("INSERT") and #raw("DELETE") for Hive.  Both #raw("INSERT") and #raw("CREATE") statements support partitioned tables.  For example, to create a partitioned table execute the following:

#code-block(none, "CREATE TABLE orders (
   order_date VARCHAR,
   order_region VARCHAR,
   order_id BIGINT,
   order_info VARCHAR
) WITH (partitioned_by = ARRAY['order_date', 'order_region'])")

To #raw("DELETE") from a Hive table, you must specify a #raw("WHERE") clause that matches entire partitions.  For example, to delete from the above table, execute the following:

#code-block(none, "DELETE FROM orders
WHERE order_date = '2015-10-15' AND order_region = 'APAC'")

#note[
Currently, Hive deletion is only supported for partitioned tables. Additionally, partition keys must be of type VARCHAR.
]
