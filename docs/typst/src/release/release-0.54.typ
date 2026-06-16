#import "/lib/trino-docs.typ": *

#anchor("doc-release-release-0-54")
= Release 0.54

- Restore binding for the node resource on the coordinator, which provides the state of all nodes as seen by the coordinator's failure detector. Access #raw("/v1/node") to see all nodes, or #raw("/v1/node/failed") to see failed nodes.
- Prevent the #link(label("doc-client-cli"))[Command line interface] from hanging when the server goes away.
- Add Hive connector #raw("hive-hadoop1") for Apache Hadoop 1.x.
- Add support for Snappy and LZ4 compression codecs for the #raw("hive-cdh4") connector.
- Add Example HTTP connector #raw("example-http") that reads CSV data via HTTP. The connector requires a metadata URI that returns a JSON document describing the table metadata and the CSV files to read.
  
  Its primary purpose is to serve as an example of how to write a connector, but it can also be used directly. Create #raw("etc/catalog/example.properties") with the following contents to mount the #raw("example-http") connector as the #raw("example") catalog:
  
  #code-block("text", "connector.name=example-http
  metadata-uri=http://s3.amazonaws.com/presto-example/v1/example-metadata.json")
- Show correct error message when a catalog or schema does not exist.
- Verify JVM requirements on startup.
- Log an error when the JVM code cache is full.
- Upgrade the embedded Discovery server to allow using non-UUID values for the #raw("node.id") property.
