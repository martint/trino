#import "/lib/trino-docs.typ": *

#anchor("doc-connector-tpcds")
= TPC-DS connector

The TPC-DS connector provides a set of schemas to support the #link("http://www.tpc.org/tpcds/")[TPC Benchmark™ DS \(TPC-DS\)]. TPC-DS is a database benchmark used to measure the performance of complex decision support databases.

This connector can be used to test the capabilities and query syntax of Trino without configuring access to an external data source. When you query a TPC-DS schema, the connector generates the data on the fly using a deterministic algorithm.

Use the #link(label("doc-connector-faker"))[Faker connector] to create and query arbitrary data.

== Configuration

To configure the TPC-DS connector, create a catalog properties file #raw("etc/catalog/example.properties") with the following contents:

#code-block("text", "connector.name=tpcds")

== TPC-DS schemas

The TPC-DS connector supplies several schemas:

#code-block(none, "SHOW SCHEMAS FROM example;")

#code-block("text", "       Schema
--------------------
 information_schema
 sf1
 sf10
 sf100
 sf1000
 sf10000
 sf100000
 sf300
 sf3000
 sf30000
 tiny
(11 rows)")

Ignore the standard schema #raw("information_schema"), which exists in every catalog, and is not directly provided by the TPC-DS connector.

Every TPC-DS schema provides the same set of tables. Some tables are identical in all schemas. The #emph[scale factor] of the tables in a particular schema is determined from the schema name. For example, the schema #raw("sf1") corresponds to scale factor #raw("1") and the schema #raw("sf300") corresponds to scale factor #raw("300"). Every unit in the scale factor corresponds to a gigabyte of data. For example, for scale factor #raw("300"), a total of #raw("300") gigabytes are generated. The #raw("tiny") schema is an alias for scale factor #raw("0.01"), which is a very small data set useful for testing.

#anchor("ref-tpcds-type-mapping")

== Type mapping

Trino supports all data types used within the TPC-DS schemas so no mapping is required.

#anchor("ref-tpcds-sql-support")

== SQL support

The connector provides #link(label("ref-sql-globally-available"))[globally available] and #link(label("ref-sql-read-operations"))[read operation] statements to access data and metadata in the TPC-DS dataset.
