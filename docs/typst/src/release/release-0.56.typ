#import "/lib/trino-docs.typ": *

#anchor("doc-release-release-0-56")
= Release 0.56

== Table creation

Tables can be created from the result of a query:

#code-block(none, "CREATE TABLE orders_by_date AS
SELECT orderdate, sum(totalprice) AS price
FROM orders
GROUP BY orderdate")

Tables are created in Hive without partitions \(unpartitioned\) and use RCFile with the Binary SerDe \(#raw("LazyBinaryColumnarSerDe")\) as this is currently the best format for Presto.

#note[
This is a backwards incompatible change to #raw("ConnectorMetadata") in the SPI, so if you have written a connector, you will need to update your code before deploying this release. We recommend changing your connector to extend from the new #raw("ReadOnlyConnectorMetadata") abstract base class unless you want to support table creation.
]

== Cross joins

Cross joins are supported using the standard ANSI SQL syntax:

#code-block(none, "SELECT *
FROM a
CROSS JOIN b")

Inner joins that result in a cross join due to the join criteria evaluating to true at analysis time are also supported.
