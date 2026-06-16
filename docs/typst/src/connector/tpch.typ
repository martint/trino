#import "/lib/trino-docs.typ": *

#anchor("doc-connector-tpch")
= TPC-H connector

The TPC-H connector provides a set of schemas to support the #link("http://www.tpc.org/tpch/")[TPC Benchmark™ H \(TPC-H\)]. TPC-H is a database benchmark used to measure the performance of highly-complex decision support databases.

This connector can be used to test the capabilities and query syntax of Trino without configuring access to an external data source. When you query a TPC-H schema, the connector generates the data on the fly using a deterministic algorithm.

Use the #link(label("doc-connector-faker"))[Faker connector] to create and query arbitrary data.

== Configuration

To configure the TPC-H connector, create a catalog properties file #raw("etc/catalog/example.properties") with the following contents:

#code-block("text", "connector.name=tpch")

In the TPC-H specification, each column is assigned a prefix based on its corresponding table name, such as #raw("l_") for the #raw("lineitem") table. By default, the TPC-H connector simplifies column names by excluding these prefixes with the default of #raw("tpch.column-naming") to #raw("SIMPLIFIED"). To use the long, standard column names, use the configuration in the catalog properties file:

#code-block("text", "tpch.column-naming=STANDARD")

== TPC-H schemas

The TPC-H connector supplies several schemas:

#code-block(none, "SHOW SCHEMAS FROM example;")

#code-block("text", "       Schema
--------------------
 information_schema
 sf1
 sf100
 sf1000
 sf10000
 sf100000
 sf300
 sf3000
 sf30000
 tiny
(11 rows)")

Ignore the standard schema #raw("information_schema"), which exists in every catalog, and is not directly provided by the TPC-H connector.

Every TPC-H schema provides the same set of tables. Some tables are identical in all schemas. Other tables vary based on the #emph[scale factor], which is determined based on the schema name. For example, the schema #raw("sf1") corresponds to scale factor #raw("1") and the schema #raw("sf300") corresponds to scale factor #raw("300"). The TPC-H connector provides an infinite number of schemas for any scale factor, not just the few common ones listed by #raw("SHOW SCHEMAS"). The #raw("tiny") schema is an alias for scale factor #raw("0.01"), which is a very small data set useful for testing.

#anchor("ref-tpch-type-mapping")

== Type mapping

Trino supports all data types used within the TPC-H schemas so no mapping is required.

#anchor("ref-tpch-sql-support")

== SQL support

The connector provides #link(label("ref-sql-globally-available"))[globally available] and #link(label("ref-sql-read-operations"))[read operation] statements to access data and metadata in the TPC-H dataset.
