#import "/lib/trino-docs.typ": *

#anchor("doc-develop-example-jdbc")
= Example JDBC connector

The Example JDBC connector shows how to extend the base #raw("JdbcPlugin") to read data from a source using a JDBC driver, without having to implement different Trino SPI services, like #raw("ConnectorMetadata") or #raw("ConnectorRecordSetProvider").

#note[
This connector is just an example. It supports a very limited set of data types and does not support any advanced functions, like predicate or other kind of pushdowns.
]

== Code

The Example JDBC connector can be found in the #link("https://github.com/trinodb/trino/tree/master/plugin/trino-example-jdbc")[trino-example-jdbc] directory within the Trino source tree.

== Plugin implementation

The plugin implementation in the Example JDBC connector extends the #raw("JdbcPlugin") class and uses the #raw("ExampleClientModule").

The module:

- binds the #raw("ExampleClient") class so it can be used by the base JDBC connector;
- provides a connection factory that will create new connections using a JDBC driver based on the JDBC URL specified in configuration properties.

== JdbcClient implementation

The base JDBC plugin maps the Trino SPI calls to the JDBC API. Operations like reading table and columns names are well-defined in JDBC so the base JDBC plugin can implement it in a way that works for most JDBC drivers.

One behavior that is not implemented by default is mapping of the data types when reading and writing data. The Example JDBC connector implements the #raw("JdbcClient") interface in the #raw("ExampleClient") class that extends the #raw("BaseJdbcClient") and implements two methods.

=== toColumnMapping

#raw("toColumnMapping") is used when reading data from the connector. Given a #raw("ConnectorSession"), #raw("Connection") and a #raw("JdbcTypeHandle"), it returns a #raw("ColumnMapping"), if there is a matching data type.

The column mapping includes:

- a Trino type,
- a write function, used to set query parameter values when preparing a JDBC statement to execute in the data source,
- and a read function, used to read a value from the JDBC statement result set, and return it using an internal Trino representation \(for example, a Slice\).

=== toWriteMapping

#raw("toWriteMapping") is used when writing data to the connector. Given a #raw("ConnectorSession") and a Trino type, it returns a #raw("WriteMapping").

The mapping includes:

- a data type name
- a write function
