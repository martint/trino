#import "/lib/trino-docs.typ": *

#anchor("doc-sql-analyze")
= ANALYZE

== Synopsis

#code-block("text", "ANALYZE table_name [ WITH ( property_name = expression [, ...] ) ]")

== Description

Collects table and column statistics for a given table.

The optional #raw("WITH") clause can be used to provide connector-specific properties. To list all available properties, run the following query:

#code-block(none, "SELECT * FROM system.metadata.analyze_properties")

== Examples

Analyze table #raw("web") to collect table and column statistics:

#code-block(none, "ANALYZE web;")

Analyze table #raw("stores") in catalog #raw("hive") and schema #raw("default"):

#code-block(none, "ANALYZE hive.default.stores;")

Analyze partitions #raw("'1992-01-01', '1992-01-02'") from a Hive partitioned table #raw("sales"):

#code-block(none, "ANALYZE hive.default.sales WITH (partitions = ARRAY[ARRAY['1992-01-01'], ARRAY['1992-01-02']]);")

Analyze partitions with complex partition key \(#raw("state") and #raw("city") columns\) from a Hive partitioned table #raw("customers"):

#code-block(none, "ANALYZE hive.default.customers WITH (partitions = ARRAY[ARRAY['CA', 'San Francisco'], ARRAY['NY', 'NY']]);")

Analyze only columns #raw("department") and #raw("product_id") for partitions #raw("'1992-01-01', '1992-01-02'") from a Hive partitioned table #raw("sales"):

#code-block(none, "ANALYZE hive.default.sales WITH (
    partitions = ARRAY[ARRAY['1992-01-01'], ARRAY['1992-01-02']],
    columns = ARRAY['department', 'product_id']);")
