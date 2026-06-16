#import "/lib/trino-docs.typ": *

#anchor("doc-object-storage-file-system-local")
= Local file system support

Trino includes support to access a local file system with a catalog using the Delta Lake, Hive, Hudi, or Iceberg connectors. The local file system must be a local mount point for a shared file system available on all cluster nodes.

Support for local file system is not enabled by default, but can be activated by setting the #raw("fs.local.enabled") property to #raw("true") in your catalog configuration file.

== General configuration

Use the following properties to configure general aspects of local file system support:

#list-table((
  ([Property], [Description],),
  ([#raw("fs.local.enabled")], [Activate the support for local file system access. Defaults to #raw("false"). Set to #raw("true") to use local file system and enable all other properties.],),
  ([#raw("local.location")], [Local path on all nodes to the root of the shared file system using the prefix #raw("local://") with the path to the mount point.],)
), header-rows: 1)

The following example displays the related section from a #raw("etc/catalog/example.properties") catalog configuration using the Hive connector. The coordinator and all workers nodes have an external storage mounted at #raw("/storage/datalake"), resulting in the location #raw("local:///storage/datalake").

#code-block("properties", "connector.name=hive
...
fs.local.enabled=true
local.location=local:///storage/datalake")

Creating a schema named #raw("default") results in the path #raw("/storage/datalake/default"). Tables within that schema result in separated directories such as #raw("/storage/datalake/default/table1").
