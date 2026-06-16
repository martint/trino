#import "/lib/trino-docs.typ": *

#anchor("doc-develop-example-http")
= Example HTTP connector

The Example HTTP connector has a simple goal: it reads comma-separated data over HTTP. For example, if you have a large amount of data in a CSV format, you can point the example HTTP connector at this data and write a query to process it.

== Installation

The example HTTP connector plugin is optional and therefore not included in the default #link(label("doc-installation-deployment"))[tarball] and the default #link(label("doc-installation-containers"))[Docker image].

Follow the #link(label("ref-plugins-installation"))[plugin installation instructions] and optionally use the #link("https://github.com/trinodb/trino-packages")[trino-packages project] or manually download the plugin archive #raw("example-http").

== Code

The Example HTTP connector can be found in the #link("https://github.com/trinodb/trino/tree/master/plugin/trino-example-http")[trino-example-http] directory within the Trino source tree.

== Plugin implementation

The plugin implementation in the Example HTTP connector looks very similar to other plugin implementations.  Most of the implementation is devoted to handling optional configuration and the only function of interest is the following:

#code-block("java", "@Override
public Iterable<ConnectorFactory> getConnectorFactories()
{
    return ImmutableList.of(new ExampleConnectorFactory());
}")

Note that the #raw("ImmutableList") class is a utility class from Guava.

As with all connectors, this plugin overrides the #raw("getConnectorFactories()") method and returns an #raw("ExampleConnectorFactory").

== ConnectorFactory implementation

In Trino, the primary object that handles the connection between Trino and a particular type of data source is the #raw("Connector") object, which are created using #raw("ConnectorFactory").

This implementation is available in the class #raw("ExampleConnectorFactory"). The first thing the connector factory implementation does is specify the name of this connector. This is the same string used to reference this connector in Trino configuration.

#code-block("java", "@Override
public String getName()
{
    return \"example_http\";
}")

The real work in a connector factory happens in the #raw("create()") method. In the #raw("ExampleConnectorFactory") class, the #raw("create()") method configures the connector and then asks Guice to create the object. This is the meat of the #raw("create()") method without parameter validation and exception handling:

#code-block("java", "// A plugin is not required to use Guice; it is just very convenient
Bootstrap app = new Bootstrap(
        new JsonModule(),
        new ExampleModule(catalogName));

Injector injector = app
        .doNotInitializeLogging()
        .setRequiredConfigurationProperties(requiredConfig)
        .initialize();

return injector.getInstance(ExampleConnector.class);")

=== Connector: ExampleConnector

This class allows Trino to obtain references to the various services provided by the connector.

=== Metadata: ExampleMetadata

This class is responsible for reporting table names, table metadata, column names, column metadata and other information about the schemas that are provided by this connector. #raw("ConnectorMetadata") is also called by Trino to ensure that a particular connector can understand and handle a given table name.

The #raw("ExampleMetadata") implementation delegates many of these calls to #raw("ExampleClient"), a class that implements much of the core functionality of the connector.

=== Split manager: ExampleSplitManager

The split manager partitions the data for a table into the individual chunks that Trino will distribute to workers for processing. In the case of the Example HTTP connector, each table contains one or more URIs pointing at the actual data. One split is created per URI.

=== Record set provider: ExampleRecordSetProvider

The record set provider creates a record set which in turn creates a record cursor that returns the actual data to Trino. #raw("ExampleRecordCursor") reads data from a URI via HTTP. Each line corresponds to a single row. Lines are split on comma into individual field values which are then returned to Trino.
