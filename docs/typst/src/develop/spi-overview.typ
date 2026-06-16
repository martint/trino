#import "/lib/trino-docs.typ": *

#anchor("doc-develop-spi-overview")
= SPI overview

Trino uses a plugin architecture to extend its capabilities and integrate with various data sources and other systems. Plugins must implement the interfaces and override methods defined by the Service Provider Interface \(SPI\).

General user information about plugins is available in the #link(label("doc-installation-plugins"))[Plugin documentation], and specific details are documented in dedicated pages about each plugin.

This section details plugin development including specific pages for capabilities of different plugins. A custom plugin enables you to add further features to Trino, such as a connector for another data source.

== Code

The SPI source can be found in the #raw("core/trino-spi") directory in the Trino source tree.

== Plugin metadata

Each plugin identifies an entry point: an implementation of the #raw("Plugin") interface. This class name is provided to Trino via the standard Java #raw("ServiceLoader") interface: the classpath contains a resource file named #raw("io.trino.spi.Plugin") in the #raw("META-INF/services") directory. The content of this file is a single line listing the name of the plugin class:

#code-block("text", "com.example.plugin.ExamplePlugin")

For a built-in plugin that is included in the Trino source code, this resource file is created whenever the #raw("pom.xml") file of a plugin contains the following line:

#code-block("xml", "<packaging>trino-plugin</packaging>")

== Plugin

The #raw("Plugin") interface is a good starting place for developers looking to understand the Trino SPI. It contains access methods to retrieve various classes that a Plugin can provide. For example, the #raw("getConnectorFactories()") method is a top-level function that Trino calls to retrieve a #raw("ConnectorFactory") when Trino is ready to create an instance of a connector to back a catalog. There are similar methods for #raw("Type"), #raw("ParametricType"), #raw("Function"), #raw("SystemAccessControl"), and #raw("EventListenerFactory") objects.

== Building plugins via Maven

Plugins depend on the SPI from Trino:

#code-block("xml", "<dependency>
    <groupId>io.trino</groupId>
    <artifactId>trino-spi</artifactId>
    <scope>provided</scope>
</dependency>")

The plugin uses the Maven #raw("provided") scope because Trino provides the classes from the SPI at runtime and thus the plugin should not include them in the plugin assembly.

There are a few other dependencies that are provided by Trino, including Slice and Jackson annotations. In particular, Jackson is used for serializing connector handles and thus plugins must use the annotations version provided by Trino.

All other dependencies are based on what the plugin needs for its own implementation. Plugins are loaded in a separate class loader to provide isolation and to allow plugins to use a different version of a library that Trino uses internally.

For an example #raw("pom.xml") file, see the example HTTP connector in the #raw("plugin/trino-example-http") directory in the Trino source tree.

== Deploying a custom plugin

Trino plugins must use the #raw("trino-plugin") Maven packaging type provided by the #link("https://github.com/trinodb/trino-maven-plugin")[trino-maven-plugin]. Building a plugin generates the required service descriptor and invokes #link("https://github.com/jvanzyl/provisio")[Provisio] to create a ZIP file in the #raw("target") directory. The file contains the plugin JAR and all its dependencies as JAR files, and is suitable for #link(label("ref-plugins-installation"))[plugin installation].

#anchor("ref-spi-compatibility")

== Compatibility

Successful #link(label("ref-plugins-download"))[download], #link(label("ref-plugins-installation"))[installation], and use of a plugin depends on compatibility of the plugin with the target Trino cluster. Full compatibility is only guaranteed when using the same Trino version used for the plugin build and the deployment, and therefore using the same version is recommended.

For example, a Trino plugin compiled for Trino 470 may not work with older or newer versions of Trino such as Trino 430 or Trino 490. This is specifically important when installing plugins from other projects, vendors, or your custom development.

Trino plugins implement the SPI, which may change with every Trino release. There are no runtime checks for SPI compatibility by default, and it is up to the plugin author to verify compatibility using runtime testing.

If the source code of a plugin is available, you can confirm the Trino version by inspecting the #raw("pom.xml"). A plugin must declare a dependency to the SPI, and therefore compatibility with the Trino release specified in the #raw("version") tag:

#code-block("xml", "<dependency>
    <groupId>io.trino</groupId>
    <artifactId>trino-spi</artifactId>
    <version>470</version>
    <scope>provided</scope>
</dependency>")

A good practice for plugins is to use a property for the version value, which is then declared elsewhere in the #raw("pom.xml"):

#code-block("xml", "...
<dep.trino.version>470</dep.trino.version>
...
<dependency>
    <groupId>io.trino</groupId>
    <artifactId>trino-spi</artifactId>
    <version>${dep.trino.version}</version>
    <scope>provided</scope>
</dependency>")
