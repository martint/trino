#import "/lib/trino-docs.typ": *

#anchor("doc-release-release-351")
= Release 351 \(3 Jan 2021\)

== General

- Rename client protocol headers to start with #raw("X-Trino-"). Legacy clients can be supported by setting the configuration property #raw("protocol.v1.alternate-header-name") to #raw("Presto"). This configuration property is deprecated and will be removed in a future release.

== JMX MBean naming

- Rename base domain name for server MBeans to #raw("trino"). The name can be changed using the configuration property #raw("jmx.base-name").
- Rename base domain name for the Elasticsearch, Hive, Iceberg, Raptor, and Thrift connectors to #raw("trino.plugin"). The name can be changed using the catalog configuration property #raw("jmx.base-name").

== Server RPM

- Rename installation directories from #raw("presto") to #raw("trino").

== Docker image

- Publish image as #link("https://hub.docker.com/r/trinodb/trino")[#raw("trinodb/trino")].
- Change base image to #raw("azul/zulu-openjdk-centos").
- Change configuration directory to #raw("/etc/trino").
- Rename CLI in image to #raw("trino").

== CLI

- Use new client protocol header names. The CLI is not compatible with older servers.

== JDBC driver

- Use new client protocol header names. The driver is not compatible with older servers.
- Change driver URL prefix to #raw("jdbc:trino:"). The old prefix is deprecated and will be removed in a future release.
- Change driver class to #raw("io.trino.jdbc.TrinoDriver"). The old class name is deprecated and will be removed in a future release.
- Rename Java package for all driver classes to #raw("io.trino.jdbc") and rename various driver classes such as #raw("TrinoConnection") to start with #raw("Trino").

== Hive connector

- Rename JMX name for #raw("PrestoS3FileSystem") to #raw("TrinoS3FileSystem").
- Change configuration properties #raw("hive.hdfs.presto.principal") to #raw("hive.hdfs.trino.principal") and #raw("hive.hdfs.presto.keytab") to #raw("hive.hdfs.trino.keytab"). The old names are deprecated and will be removed in a future release.

== Local file connector

- Change configuration properties #raw("presto-logs.http-request-log.location") to #raw("trino-logs.http-request-log.location") and #raw("presto-logs.http-request-log.pattern") to #raw("trino-logs.http-request-log.pattern"). The old names are deprecated and will be removed in a future release.

== Thrift connector

- Rename Thrift service method names starting with #raw("presto") to #raw("trino").
- Rename all classes in the Thrift IDL starting with #raw("Presto") to #raw("Trino").
- Rename configuration properties starting with #raw("presto") to #raw("trino").

== SPI

- Rename Java package to #raw("io.trino.spi").
- Rename #raw("PrestoException") to #raw("TrinoException").
- Rename #raw("PrestoPrincipal") to #raw("TrinoPrincipal").
- Rename #raw("PrestoWarning") to #raw("TrinoWarning").
